import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// 🚀 Otomatik Güncelleme Bilgi Modeli
class GuncellemeBilgisi {
  final bool guncellemeVar;
  final String mevcutSurum;
  final String yeniSurum;
  final String baslik;
  final String aciklama;
  final String apkUrl;

  const GuncellemeBilgisi({
    required this.guncellemeVar,
    required this.mevcutSurum,
    required this.yeniSurum,
    required this.baslik,
    required this.aciklama,
    required this.apkUrl,
  });
}

/// 📲 KKTC Trafik & Ceza - Kablosuz OTA Güncelleme Servisi
class GuncellemeServisi {
  // Mevcut uygulama sürümü (Cihazdaki taban sürüm)
  static const String mevcutSurum = "1.0.3";
  static const String _repoApiUrl =
      "https://api.github.com/repos/Tubi-kara/kktc_ceza/releases/latest";
  static const String _varsayilanApkUrl =
      "https://github.com/Tubi-kara/kktc_ceza/releases/latest/download/kktc_ceza_app.apk";

  /// 🔍 GitHub Releases Üzerinden Yeni Sürüm Var mı Kontrol Eder
  static Future<GuncellemeBilgisi?> guncellemeKontrolEt() async {
    // Web/PWA (iPhone ana ekran) sürümü her açılışta sunucudan güncel yüklenir
    if (kIsWeb) return null;
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 7);
      final request = await client.getUrl(Uri.parse(_repoApiUrl));
      request.headers.set('User-Agent', 'KKTC-Ceza-App');
      request.headers.set('Accept', 'application/vnd.github.v3+json');

      final response = await request.close();
      if (response.statusCode != 200) {
        return null;
      }

      final body = await response.transform(utf8.decoder).join();
      final data = json.decode(body) as Map<String, dynamic>;

      final tagName = (data['tag_name'] ?? '').toString();
      final releaseName = (data['name'] ?? 'Yeni Güncelleme').toString();
      final releaseBody = (data['body'] ?? '').toString();

      // Sürüm numarasını temizle (örn: 'v1.0.2' -> '1.0.2')
      String temizYeniSurum = tagName.replaceAll(RegExp(r'[^0-9.]'), '');
      if (temizYeniSurum.isEmpty) {
        final match = RegExp(r'v?(\d+\.\d+(\.\d+)?)').firstMatch('$releaseName $releaseBody');
        if (match != null) {
          temizYeniSurum = match.group(1) ?? '';
        }
      }
      if (temizYeniSurum.isEmpty) {
        temizYeniSurum = "1.0.2";
      }

      final temizMevcutSurum = mevcutSurum.replaceAll(RegExp(r'[^0-9.]'), '');

      // APK İndirme URL'sini bul
      String indirmeUrl = _varsayilanApkUrl;
      if (data['assets'] is List) {
        final assets = data['assets'] as List;
        for (final asset in assets) {
          final assetName = (asset['name'] ?? '').toString().toLowerCase();
          if (assetName.endsWith('.apk')) {
            indirmeUrl = asset['browser_download_url'] ?? indirmeUrl;
            break;
          }
        }
      }

      final bool yeniVar = _surumBuyukMu(temizYeniSurum, temizMevcutSurum) ||
          (tagName.toLowerCase() == 'latest' && temizYeniSurum != temizMevcutSurum);

      return GuncellemeBilgisi(
        guncellemeVar: yeniVar,
        mevcutSurum: mevcutSurum,
        yeniSurum: temizYeniSurum.isNotEmpty ? temizYeniSurum : tagName,
        baslik: releaseName,
        aciklama: releaseBody,
        apkUrl: indirmeUrl,
      );
    } catch (_) {
      return null;
    }
  }

  /// Semver karşılaştırma: yeni > mevcut ise true döner
  static bool _surumBuyukMu(String yeni, String mevcut) {
    if (yeni.isEmpty) return false;
    final yeniParcalar = yeni.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final mevcutParcalar = mevcut.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    while (yeniParcalar.length < 3) {
      yeniParcalar.add(0);
    }
    while (mevcutParcalar.length < 3) {
      mevcutParcalar.add(0);
    }

    for (int i = 0; i < 3; i++) {
      if (yeniParcalar[i] > mevcutParcalar[i]) return true;
      if (yeniParcalar[i] < mevcutParcalar[i]) return false;
    }
    return false;
  }

  /// 🔔 Uygulama Açılışında Otomatik Kontrol
  static Future<void> otomatikKontrolEt(BuildContext context, bool turkceMi) async {
    final bilgi = await guncellemeKontrolEt();
    if (bilgi != null && bilgi.guncellemeVar && context.mounted) {
      guncellemeDiyaloguGoster(context, bilgi, turkceMi);
    }
  }

  /// ⚙️ Ayarlar / Profil Menüsünden Manuel Kontrol
  static Future<void> manuelKontrolEt(BuildContext context, bool turkceMi) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              turkceMi
                  ? 'Güncellemeler denetleniyor...'
                  : 'Checking for updates...',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    final bilgi = await guncellemeKontrolEt();
    if (!context.mounted) return;

    if (bilgi != null && bilgi.guncellemeVar) {
      guncellemeDiyaloguGoster(context, bilgi, turkceMi);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  turkceMi
                      ? 'Harika! Uygulamanız en güncel sürümde (v$mevcutSurum).'
                      : 'You are on the latest version (v$mevcutSurum).',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0F172A),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 🚀 Yeni Sürüm Bulunduğunda Açılan Modern Glassmorphism İletişim Kutusu
  static void guncellemeDiyaloguGoster(
    BuildContext context,
    GuncellemeBilgisi bilgi,
    bool turkceMi,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.35), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Başlık & İkon Alanı
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.10),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              turkceMi ? 'Yeni Güncelleme Yayında!' : 'New Update Available!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              turkceMi ? 'Uygulama içinden direkt indirin' : 'Download directly in-app',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // İçerik & Sürüm Karşılaştırması
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sürüm Karşılaştırma Rozetleri
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  turkceMi ? 'Mevcut Sürüm' : 'Current',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'v${bilgi.mevcutSurum}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.arrow_forward_rounded, color: Color(0xFF10B981), size: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  turkceMi ? 'Yeni Sürüm' : 'New Version',
                                  style: const TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'v${bilgi.yeniSurum}',
                                  style: const TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Yenilikler Başlığı & Açıklaması
                      Text(
                        turkceMi ? 'Yenilikler & İyileştirmeler:' : "What's New:",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 110),
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            bilgi.aciklama.isNotEmpty
                                ? bilgi.aciklama
                                : (turkceMi
                                    ? '• Haritaya dokunarak rota belirleme (Touch-to-Route)\n• Canlı Google Maps dönüş manevraları & HUD\n• Canlı KKTC radar hız uyarısı ve performans geliştirmeleri'
                                    : '• Interactive touch-to-route point selection\n• Live turn-by-turn navigation HUD\n• Live speed camera warnings and fixes'),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 11.5,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Aksiyon Butonları
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white70,
                                side: const BorderSide(color: Colors.white24),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                turkceMi ? 'Daha Sonra' : 'Later',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                if (Platform.isIOS) {
                                  iosGuncellemeDiyaloguGoster(context, bilgi, turkceMi);
                                } else {
                                  indirmeDiyaloguGoster(context, bilgi, turkceMi);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 6,
                                shadowColor: const Color(0xFF10B981).withValues(alpha: 0.5),
                              ),
                              icon: Icon(
                                Platform.isIOS ? Icons.apple_rounded : Icons.download_rounded,
                                size: 18,
                              ),
                              label: Text(
                                Platform.isIOS
                                    ? (turkceMi ? 'iOS Güncellemesi' : 'iOS Update')
                                    : (turkceMi ? 'Direkt İndir & Kur' : 'Download & Install'),
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 📲 Uygulama İçi Canlı İndirme & Otomatik Paket Yükleyici Modalı (Android)
  static void indirmeDiyaloguGoster(
    BuildContext context,
    GuncellemeBilgisi bilgi,
    bool turkceMi,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GuncellemeIndirmeDiyalogu(bilgi: bilgi, turkceMi: turkceMi),
    );
  }

  /// 🍏 iOS (iPhone & iPad) Özel Güncelleme & Yükleme Modalı
  static void iosGuncellemeDiyaloguGoster(
    BuildContext context,
    GuncellemeBilgisi bilgi,
    bool turkceMi,
  ) {
    const String ipaUrl =
        "https://github.com/Tubi-kara/kktc_ceza/releases/latest/download/KKTC_Ceza_iOS.ipa";
    const String releasePageUrl =
        "https://github.com/Tubi-kara/kktc_ceza/releases/latest";

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white24, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Apple İkonu
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Center(
                    child: Icon(Icons.apple_rounded, color: Colors.white, size: 36),
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  turkceMi ? 'iOS (iPhone) Güncellemesi' : 'iOS (iPhone) Update',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'v${bilgi.yeniSurum}',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),

                // Seçenek 1: IPA İndir
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.download_rounded, color: Color(0xFF38BDF8), size: 22),
                    ),
                    title: Text(
                      turkceMi ? 'iOS IPA Paketini İndir' : 'Download iOS IPA',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      turkceMi
                          ? 'Sideloadly, AltStore, Scarlet veya TrollStore ile kurun'
                          : 'Install via Sideloadly, AltStore, Scarlet or TrollStore',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10.5),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 12),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await launchUrl(Uri.parse(ipaUrl), mode: LaunchMode.externalApplication);
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // Seçenek 2: Safari Web PWA
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.language_rounded, color: Color(0xFF10B981), size: 22),
                    ),
                    title: Text(
                      turkceMi ? 'Safari Web Uygulaması (PWA)' : 'Safari Web App (PWA)',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      turkceMi
                          ? "Safari'de açıp 'Paylaş ➔ Ana Ekrana Ekle' diyerek kurun"
                          : "Open in Safari & tap 'Share ➔ Add to Home Screen'",
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10.5),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 12),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await launchUrl(
                        Uri.parse("https://tubi-kara.github.io/kktc_ceza/"),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // Seçenek 3: GitHub Releases
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.code_rounded, color: Colors.white70, size: 22),
                    ),
                    title: Text(
                      turkceMi ? 'GitHub Sürüm Sayfası' : 'GitHub Releases Page',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      turkceMi ? 'Tüm kaynak kodlar ve paketler' : 'All source code & binaries',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10.5),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 12),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await launchUrl(Uri.parse(releasePageUrl), mode: LaunchMode.externalApplication);
                    },
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(turkceMi ? 'Kapat' : 'Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 📥 Canlı İndirme İlerlemesi ve Kurulum Penceresi
class GuncellemeIndirmeDiyalogu extends StatefulWidget {
  final GuncellemeBilgisi bilgi;
  final bool turkceMi;

  const GuncellemeIndirmeDiyalogu({
    super.key,
    required this.bilgi,
    required this.turkceMi,
  });

  @override
  State<GuncellemeIndirmeDiyalogu> createState() => _GuncellemeIndirmeDiyaloguState();
}

class _GuncellemeIndirmeDiyaloguState extends State<GuncellemeIndirmeDiyalogu> {
  double _ilerleme = 0.0;
  int _indirilenBayt = 0;
  int _toplamBayt = 0;
  bool _tamamlandi = false;
  bool _hata = false;
  String _hataMesaji = "";
  String _durumMetni = "";
  String? _indirilenDosyaYolu;
  HttpClientRequest? _aktifIstek;
  StreamSubscription<List<int>>? _aktifAkim;

  @override
  void initState() {
    super.initState();
    _durumMetni = widget.turkceMi ? "Sunucuya bağlanılıyor..." : "Connecting to server...";
    _indirmeyiBaslat();
  }

  @override
  void dispose() {
    _aktifAkim?.cancel();
    _aktifIstek?.abort();
    super.dispose();
  }

  Future<void> _indirmeyiBaslat() async {
    setState(() {
      _ilerleme = 0.0;
      _indirilenBayt = 0;
      _toplamBayt = 0;
      _tamamlandi = false;
      _hata = false;
      _durumMetni = widget.turkceMi ? "APK dosyası indiriliyor..." : "Downloading APK...";
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final dosyaAdi = "kktc_ceza_v${widget.bilgi.yeniSurum.replaceAll(RegExp(r'[^0-9.]'), '')}.apk";
      final hedefDosya = File("${tempDir.path}/$dosyaAdi");

      if (await hedefDosya.exists()) {
        try {
          await hedefDosya.delete();
        } catch (_) {}
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 15);
      
      final uri = Uri.parse(widget.bilgi.apkUrl);
      final request = await client.getUrl(uri);
      _aktifIstek = request;
      
      request.followRedirects = true;
      request.maxRedirects = 5;
      request.headers.set('User-Agent', 'KKTC-Trafik-OTA-Downloader');
      request.headers.set('Accept', '*/*');

      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception("HTTP ${response.statusCode}: ${response.reasonPhrase}");
      }

      final contentLength = response.contentLength;
      setState(() {
        _toplamBayt = contentLength > 0 ? contentLength : 29 * 1024 * 1024; // ~29 MB tahmini
      });

      final sink = hedefDosya.openWrite();

      _aktifAkim = response.listen(
        (chunk) {
          sink.add(chunk);
          _indirilenBayt += chunk.length;
          if (mounted) {
            setState(() {
              if (_toplamBayt > 0) {
                _ilerleme = (_indirilenBayt / _toplamBayt).clamp(0.0, 1.0);
              }
            });
          }
        },
        onDone: () async {
          await sink.flush();
          await sink.close();
          if (mounted) {
            setState(() {
              _tamamlandi = true;
              _ilerleme = 1.0;
              _indirilenDosyaYolu = hedefDosya.path;
              _durumMetni = widget.turkceMi
                  ? "✅ İndirme Tamamlandı! Paket Yükleyici Başlatılıyor..."
                  : "✅ Download Complete! Starting Package Installer...";
            });
            // İndirme bittiğinde doğrudan sistem paket yükleyicisini aç
            await Future.delayed(const Duration(milliseconds: 400));
            _kurulumuBaslat();
          }
        },
        onError: (e) {
          sink.close();
          if (mounted) {
            setState(() {
              _hata = true;
              _hataMesaji = e.toString();
              _durumMetni = widget.turkceMi ? "İndirme sırasında hata oluştu" : "Download failed";
            });
          }
        },
        cancelOnError: true,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _hata = true;
          _hataMesaji = e.toString();
          _durumMetni = widget.turkceMi ? "Bağlantı hatası oluştu" : "Connection error";
        });
      }
    }
  }

  Future<void> _kurulumuBaslat() async {
    if (_indirilenDosyaYolu == null) return;
    try {
      final res = await OpenFilex.open(
        _indirilenDosyaYolu!,
        type: 'application/vnd.android.package-archive',
      );
      if (res.type != ResultType.done && mounted) {
        // İzin veya başka bir durum varsa kullanıcıyı bilgilendir
        setState(() {
          _durumMetni = widget.turkceMi
              ? "Yükleme ekranı açıldı. Devam etmek için onay veriniz."
              : "Installer launched. Confirm to proceed.";
        });
      }
    } catch (_) {
      // Alternatif olarak harici başlatma dene
      if (_indirilenDosyaYolu != null) {
        await launchUrl(Uri.file(_indirilenDosyaYolu!), mode: LaunchMode.externalApplication);
      }
    }
  }

  String _formatBoyut(int bayt) {
    if (bayt <= 0) return "0 MB";
    final mb = bayt / (1024 * 1024);
    return "${mb.toStringAsFixed(1)} MB";
  }

  @override
  Widget build(BuildContext context) {
    final yuzde = (_ilerleme * 100).toInt();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _hata
                ? const Color(0xFFEF4444).withValues(alpha: 0.5)
                : (_tamamlandi
                    ? const Color(0xFF10B981).withValues(alpha: 0.6)
                    : const Color(0xFF38BDF8).withValues(alpha: 0.4)),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Üst İkon & Durum
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _hata
                        ? [const Color(0xFFDC2626), const Color(0xFFEF4444)]
                        : (_tamamlandi
                            ? [const Color(0xFF059669), const Color(0xFF10B981)]
                            : [const Color(0xFF0284C7), const Color(0xFF38BDF8)]),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_tamamlandi ? const Color(0xFF10B981) : const Color(0xFF0284C7))
                          .withValues(alpha: 0.4),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    _hata
                        ? Icons.error_outline_rounded
                        : (_tamamlandi
                            ? Icons.check_circle_rounded
                            : Icons.cloud_download_rounded),
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Başlık
              Text(
                _tamamlandi
                    ? (widget.turkceMi ? 'Güncelleme Hazır!' : 'Update Ready!')
                    : (_hata
                        ? (widget.turkceMi ? 'İndirme Başarısız' : 'Download Failed')
                        : (widget.turkceMi ? 'KKTC e-Trafik İndiriliyor' : 'Downloading Update')),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),

              Text(
                _durumMetni,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),

              // İlerleme Çubuğu ve Sayaç
              if (!_hata) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _ilerleme > 0 ? _ilerleme : null,
                    minHeight: 12,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _tamamlandi ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Boyut ve Yüzde Bilgisi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${_formatBoyut(_indirilenBayt)} / ${_formatBoyut(_toplamBayt)}",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "%$yuzde",
                      style: TextStyle(
                        color: _tamamlandi ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],

              if (_hata) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _hataMesaji,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 11),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              const SizedBox(height: 16),

              // 🛡️ Google Play Protect & Güvenlik Kılavuz Kartı
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.25)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.security_rounded, color: Color(0xFF10B981), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.turkceMi
                            ? "Google Play Protect uyarısı çıkarsa korkmayın; 'Daha Fazla Ayrıntı' ➔ 'Yine de Yükle'ye basmanız yeterlidir. Uygulama resmi açık kaynaklı ve güvenlidir."
                            : "If Play Protect alerts you; tap 'More Details' ➔ 'Install Anyway'. The update is official, verified & safe.",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 10.5,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Aksiyon Butonları
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _aktifAkim?.cancel();
                        _aktifIstek?.abort();
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white60,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        widget.turkceMi ? 'Kapat' : 'Close',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  if (_tamamlandi) ...[
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _kurulumuBaslat,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 6,
                        ),
                        icon: const Icon(Icons.install_mobile_rounded, size: 18),
                        label: Text(
                          widget.turkceMi ? 'Yüklemeyi Başlat' : 'Install APK',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                        ),
                      ),
                    ),
                  ] else if (_hata) ...[
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // Tarayıcı ile indirmeyi fallback olarak aç
                          final uri = Uri.parse(widget.bilgi.apkUrl);
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                        label: Text(
                          widget.turkceMi ? 'Tarayıcıda İndir' : 'Download in Browser',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF38BDF8),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.turkceMi ? 'İndiriliyor...' : 'Downloading...',
                                style: const TextStyle(
                                  color: Color(0xFF38BDF8),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
