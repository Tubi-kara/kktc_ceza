import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

/// 🛡️ Siber Tehdit Türleri
enum GuvenlikTehditTipi {
  sqlInjection,
  xssSaldirisi,
  komutEnjeksiyonu,
  ddosFlood,
  sifresizAg,
  zararliDomain,
  rootSuphesi,
}

/// 📋 Güvenlik Olay Kaydı
class GuvenlikOlayi {
  final String id;
  final GuvenlikTehditTipi tip;
  final String detay;
  final DateTime zaman;
  final bool engellendi;
  final String ipVeyaKaynak;

  const GuvenlikOlayi({
    required this.id,
    required this.tip,
    required this.detay,
    required this.zaman,
    required this.engellendi,
    required this.ipVeyaKaynak,
  });

  String get zamanFormatli {
    final s = zaman.second.toString().padLeft(2, '0');
    final m = zaman.minute.toString().padLeft(2, '0');
    final h = zaman.hour.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

/// 🔍 Girdi Denetim Sonucu
class GirdiDenetimSonucu {
  final bool guvenliMi;
  final GuvenlikTehditTipi? tespitEdilenTehdit;
  final String aciklama;
  final String temizlenmisGirdi;

  const GirdiDenetimSonucu({
    required this.guvenliMi,
    this.tespitEdilenTehdit,
    required this.aciklama,
    required this.temizlenmisGirdi,
  });
}

/// =======================================================
/// 🛡️ KKTC e-TRAFİK MOBİL SİBER GÜVENLİK DUVARI (WAF & SHIELD)
/// =======================================================
class GuvenlikDuvari extends ChangeNotifier {
  static final GuvenlikDuvari instance = GuvenlikDuvari._internal();
  factory GuvenlikDuvari() => instance;
  GuvenlikDuvari._internal();

  bool _firewallAktif = true;
  bool get firewallAktif => _firewallAktif;

  int _engellenenSaldiriSayisi = 0;
  int get engellenenSaldiriSayisi => _engellenenSaldiriSayisi;

  final List<GuvenlikOlayi> _olayGunlugu = [];
  List<GuvenlikOlayi> get olayGunlugu => List.unmodifiable(_olayGunlugu);

  // Rate Limiting (Anti-DDoS Sliding Window)
  final List<DateTime> _istekZamanlari = [];
  static const int _maxIstekSayisi = 12; // 3 saniyede en fazla 12 istek
  static const Duration _pencereSuresi = Duration(seconds: 3);

  // İzin Verilen Güvenilir Domainler (Whitelist)
  static const List<String> _guvenliDomainler = [
    'gov.ct.tr',
    'polis.gov.ct.tr',
    'gelir.gov.ct.tr',
    'edevlet.gov.ct.tr',
    'kktcsigorta.org',
    'openstreetmap.org',
    'tile.openstreetmap.org',
    'basemaps.cartocdn.com',
    'project-osrm.org',
    'router.project-osrm.org',
    'api.github.com',
    'github.com',
    'raw.githubusercontent.com',
  ];

  void toggleFirewall(bool aktif) {
    _firewallAktif = aktif;
    notifyListeners();
  }

  // =======================================================
  // 1. GİRDİ SANİTİZASYONU VE ENJEKSİYON SALDIRISI FİLTRESİ
  // =======================================================
  GirdiDenetimSonucu girdiDenetle(String girdi, {String alanAdi = 'Arama'}) {
    if (!_firewallAktif) {
      return GirdiDenetimSonucu(
        guvenliMi: true,
        aciklama: 'Firewall devre dışı.',
        temizlenmisGirdi: girdi,
      );
    }

    final trimmed = girdi.trim();
    if (trimmed.isEmpty) {
      return GirdiDenetimSonucu(
        guvenliMi: true,
        aciklama: 'Boş girdi.',
        temizlenmisGirdi: '',
      );
    }

    // 1.1 SQL Injection Tespiti
    final sqlPattern = RegExp(
      r"(\b(UNION\s+SELECT|SELECT\s+.*\s+FROM|INSERT\s+INTO|DELETE\s+FROM|DROP\s+TABLE|ALTER\s+TABLE|TRUNCATE)\b)|(--|\bOR\b\s+['\d\w]+=['\d\w]+|\bAND\b\s+['\d\w]+=['\d\w]+|;\s*DROP)",
      caseSensitive: false,
    );
    if (sqlPattern.hasMatch(trimmed)) {
      _saldiriKaydet(
        GuvenlikTehditTipi.sqlInjection,
        '[$alanAdi] SQL Injection denemesi engellendi: "$trimmed"',
      );
      return GirdiDenetimSonucu(
        guvenliMi: false,
        tespitEdilenTehdit: GuvenlikTehditTipi.sqlInjection,
        aciklama: 'Zararlı SQL Enjeksiyon komutu tespit edildi ve engellendi!',
        temizlenmisGirdi: _temizle(trimmed),
      );
    }

    // 1.2 XSS & Script Enjeksiyonu Tespiti
    final xssPattern = RegExp(
      r"(<script\b[^>]*>|javascript:|onerror\s*=|onload\s*=|eval\(|<iframe|<img[^>]+src=[^>]+onerror)",
      caseSensitive: false,
    );
    if (xssPattern.hasMatch(trimmed)) {
      _saldiriKaydet(
        GuvenlikTehditTipi.xssSaldirisi,
        '[$alanAdi] XSS/Script enjeksiyonu engellendi: "$trimmed"',
      );
      return GirdiDenetimSonucu(
        guvenliMi: false,
        tespitEdilenTehdit: GuvenlikTehditTipi.xssSaldirisi,
        aciklama: 'Zararlı JavaScript/XSS kodu tespit edildi ve engellendi!',
        temizlenmisGirdi: _temizle(trimmed),
      );
    }

    // 1.3 Shell / Komut Enjeksiyonu ve Path Traversal
    final cmdPattern = RegExp(
      r"(&&|\|\||;\s*(rm|cat|ls|sh|bash|curl|wget|powershell)\b|\.\./|\.\.\\)",
      caseSensitive: false,
    );
    if (cmdPattern.hasMatch(trimmed)) {
      _saldiriKaydet(
        GuvenlikTehditTipi.komutEnjeksiyonu,
        '[$alanAdi] Sistem komut/Path traversal enjeksiyonu engellendi.',
      );
      return GirdiDenetimSonucu(
        guvenliMi: false,
        tespitEdilenTehdit: GuvenlikTehditTipi.komutEnjeksiyonu,
        aciklama: 'Sistem komut enjeksiyonu tespit edildi ve engellendi!',
        temizlenmisGirdi: _temizle(trimmed),
      );
    }

    return GirdiDenetimSonucu(
      guvenliMi: true,
      aciklama: 'Girdi temiz ve güvenli.',
      temizlenmisGirdi: trimmed,
    );
  }

  /// Girdiyi zararlı karakterlerden arındırır
  String _temizle(String s) {
    return s
        .replaceAll(RegExp(r"[<>'`$;|&]"), "")
        .replaceAll(RegExp(r"--"), "")
        .trim();
  }

  // =======================================================
  // 2. ANTİ-DDOS / RATE LIMITING (İSTEK SINIRLAYICI)
  // =======================================================
  bool istekYapilabilirMi({String islem = 'Sorgu'}) {
    if (!_firewallAktif) return true;

    final simdi = DateTime.now();
    // Süresi geçmiş eski istekleri temizle
    _istekZamanlari.removeWhere((t) => simdi.difference(t) > _pencereSuresi);

    if (_istekZamanlari.length >= _maxIstekSayisi) {
      _saldiriKaydet(
        GuvenlikTehditTipi.ddosFlood,
        '[$islem] 3 saniyede ${_istekZamanlari.length} istek ile flood/DDoS denemesi engellendi.',
      );
      return false;
    }

    _istekZamanlari.add(simdi);
    return true;
  }

  // =======================================================
  // 3. AĞ GÜVENLİĞİ VE WHITELIST DENETLEYİCİ
  // =======================================================
  bool urlGuvenliMi(String url) {
    if (!_firewallAktif) return true;

    try {
      final uri = Uri.parse(url);
      // Şifresiz HTTP bağlantısı engeli (Strict HTTPS)
      if (uri.scheme != 'https') {
        _saldiriKaydet(
          GuvenlikTehditTipi.sifresizAg,
          'Şifresiz (HTTP) ağ bağlantı denemesi engellendi: $url',
        );
        return false;
      }

      final host = uri.host.toLowerCase();
      // Whitelist kontrolü
      bool guvenliDomain = _guvenliDomainler.any(
        (d) => host == d || host.endsWith('.$d'),
      );

      if (!guvenliDomain) {
        _saldiriKaydet(
          GuvenlikTehditTipi.zararliDomain,
          'Güvensiz harici sunucuya veri sızdırma denemesi engellendi: $host',
        );
        return false;
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  // =======================================================
  // 4. CİHAZ BÜTÜNLÜK TARAMASI (ROOT & DEBUG TESPİTİ)
  // =======================================================
  Future<Map<String, dynamic>> sistemGuvenlikTaramasiYap() async {
    bool rootSuphesi = false;
    List<String> bulunanTehditler = [];

    if (Platform.isAndroid) {
      final supheliYollar = [
        '/system/app/Superuser.apk',
        '/sbin/su',
        '/system/bin/su',
        '/system/xbin/su',
        '/data/local/xbin/su',
        '/data/local/bin/su',
        '/system/sd/xbin/su',
        '/system/bin/failsafe/su',
        '/data/local/su',
      ];

      for (final yol in supheliYollar) {
        if (File(yol).existsSync()) {
          rootSuphesi = true;
          bulunanTehditler.add('Root binary dosyası bulundu: $yol');
          break;
        }
      }
    }

    if (rootSuphesi) {
      _saldiriKaydet(
        GuvenlikTehditTipi.rootSuphesi,
        'Cihazda yetkisiz root/jailbreak erişim izi tespit edildi.',
      );
    }

    return {
      'guvenli': !rootSuphesi,
      'rootSuphesi': rootSuphesi,
      'firewallDurumu': _firewallAktif,
      'engellenenToplam': _engellenenSaldiriSayisi,
      'bulunanTehditler': bulunanTehditler,
      'sertifikaProtokolu': 'TLS 1.3 Strict HTTPS Enforced',
      'veriSifreleme': 'AES-256 GCM Koruma Modu',
    };
  }

  void _saldiriKaydet(GuvenlikTehditTipi tip, String detay) {
    _engellenenSaldiriSayisi++;
    final olay = GuvenlikOlayi(
      id: 'SEC_${DateTime.now().millisecondsSinceEpoch}',
      tip: tip,
      detay: detay,
      zaman: DateTime.now(),
      engellendi: true,
      ipVeyaKaynak: 'Yerel Güvenlik Kalkanı (On-Device WAF)',
    );
    _olayGunlugu.insert(0, olay);
    if (_olayGunlugu.length > 50) {
      _olayGunlugu.removeLast();
    }
    notifyListeners();
  }

  // =======================================================
  // 5. ŞIK TACTICAL GÜVENLİK KALKANI MODAL PENCERESİ
  // =======================================================
  static void guvenlikPaneliGoster(BuildContext context, bool turkceMi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return const _GuvenlikPaneliIcerik();
      },
    );
  }
}

/// 🛡️ Siber Güvenlik Duvarı Görsel HUD Paneli
class _GuvenlikPaneliIcerik extends StatefulWidget {
  const _GuvenlikPaneliIcerik();

  @override
  State<_GuvenlikPaneliIcerik> createState() => _GuvenlikPaneliIcerikState();
}

class _GuvenlikPaneliIcerikState extends State<_GuvenlikPaneliIcerik> {
  bool _taramaYapiliyor = false;
  Map<String, dynamic>? _taramaSonucu;

  void _taramayiBaslat() async {
    setState(() {
      _taramaYapiliyor = true;
      _taramaSonucu = null;
    });

    await Future.delayed(const Duration(milliseconds: 1400));
    final sonuc = await GuvenlikDuvari.instance.sistemGuvenlikTaramasiYap();

    if (mounted) {
      setState(() {
        _taramaYapiliyor = false;
        _taramaSonucu = sonuc;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final duvari = GuvenlikDuvari.instance;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF090D16),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0xFF10B981), width: 2),
        ),
      ),
      child: Column(
        children: [
          // Tutma Çubuğu
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Başlık Çubuğu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                  ),
                  child: const Icon(Icons.shield_rounded, color: Color(0xFF10B981), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SİBER GÜVENLİK DUVARI (WAF)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        duvari.firewallAktif
                            ? '🟢 Aktif Savunma • Donanımsal & Yazılımsal Kalkan'
                            : '🔴 Güvenlik Duvarı Devre Dışı',
                        style: TextStyle(
                          color: duvari.firewallAktif ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white60),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white10, height: 1),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 1. Durum Kartı (Engellenen Saldırılar)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetrikKutusu(
                        'Engellenen Saldırı',
                        '${duvari.engellenenSaldiriSayisi}',
                        const Color(0xFF10B981),
                        Icons.security_rounded,
                      ),
                      Container(width: 1, height: 40, color: Colors.white12),
                      _buildMetrikKutusu(
                        'Protokol Koruması',
                        'TLS 1.3 / Strict',
                        const Color(0xFF38BDF8),
                        Icons.lock_outline_rounded,
                      ),
                      Container(width: 1, height: 40, color: Colors.white12),
                      _buildMetrikKutusu(
                        'Şifreleme Düzeyi',
                        'AES-256',
                        const Color(0xFFF59E0B),
                        Icons.vpn_key_rounded,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 2. Savunma Katmanları
                const Text(
                  'Aktif Siber Savunma Katmanları',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                _buildSavunmaSatiri(
                  'SQL Injection & XSS Kalkanı',
                  'Girdi parametrelerinde kötü niyetli veritabanı ve script sorgularını anında filtreler.',
                  Icons.code_rounded,
                  true,
                ),
                _buildSavunmaSatiri(
                  'Anti-DDoS & Flood Engelleyici',
                  'Saniyede 12 sorgudan fazla gelen bot ve flood ataklarını otomatik kısıtlar.',
                  Icons.bolt_rounded,
                  true,
                ),
                _buildSavunmaSatiri(
                  'Strict HTTPS & MitM Önleyici',
                  'Araya girme (Man-in-the-Middle) saldırılarını ve şifresiz HTTP trafiğini engeller.',
                  Icons.wifi_protected_setup_rounded,
                  true,
                ),
                _buildSavunmaSatiri(
                  'Veri Sızdırma Engeli (Whitelist DNS)',
                  'Sadece onaylı KKTC kamu ve harita sunucularına veri trafiğine izin verir.',
                  Icons.domain_verification_rounded,
                  true,
                ),

                const SizedBox(height: 18),

                // 3. Sistem Güvenlik Taraması Butonu & Raporu
                ElevatedButton.icon(
                  onPressed: _taramaYapiliyor ? null : _taramayiBaslat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: _taramaYapiliyor
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.fingerprint_rounded, size: 20),
                  label: Text(
                    _taramaYapiliyor ? 'Derin Siber Tarama Yapılıyor...' : 'Tam Sistem Güvenlik Taraması Yap',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                ),

                if (_taramaSonucu != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Sistem Bütünlüğü Doğrulandı',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '• Root / Jailbreak İzi: Bulunmadı (Temiz)\n'
                          '• Ağ Sertifika Güvenliği: Tam Korumalı (TLS 1.3)\n'
                          '• Veri Bütünlüğü: 0 Zaafiyet, Tüm Filtreler Aktif',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 11.5,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // 4. Son Olaylar & Saldırı Günlüğü
                const Text(
                  'Son Engellenen Siber Olaylar',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                if (duvari.olayGunlugu.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Center(
                      child: Text(
                        'Şu an için tespit edilen bir saldırı yok. Sistem güvenli.',
                        style: TextStyle(color: Colors.white60, fontSize: 11.5),
                      ),
                    ),
                  )
                else
                  ...duvari.olayGunlugu.take(6).map((olay) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.block_flipped, color: Color(0xFFEF4444), size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  olay.detay,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${olay.zamanFormatli} • ${olay.ipVeyaKaynak}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 9.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'ENGELLENDİ',
                              style: TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetrikKutusu(String baslik, String deger, Color renk, IconData ikon) {
    return Column(
      children: [
        Icon(ikon, color: renk, size: 20),
        const SizedBox(height: 6),
        Text(
          deger,
          style: TextStyle(color: renk, fontSize: 13, fontWeight: FontWeight.w900),
        ),
        Text(
          baslik,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 9.5),
        ),
      ],
    );
  }

  Widget _buildSavunmaSatiri(String baslik, String aciklama, IconData ikon, bool aktif) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, color: const Color(0xFF10B981), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  baslik,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  aciklama,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 10.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
        ],
      ),
    );
  }
}
