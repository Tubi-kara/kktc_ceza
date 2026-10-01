import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

// ==========================================
// 🏛️ KKTC RESMİ KAMU ENTEGRASYON VE VERİ KÖPRÜSÜ
// ==========================================

/// Kamu Sistemi Bağlantı Durumu Modeli
class KamuSunucuDurumu {
  final String servisAdi;
  final String kurum;
  final String endpoint;
  final bool aktif;
  final int gecikmeMs;
  final String protokol;
  final String sonSenkron;

  const KamuSunucuDurumu({
    required this.servisAdi,
    required this.kurum,
    required this.endpoint,
    required this.aktif,
    required this.gecikmeMs,
    required this.protokol,
    required this.sonSenkron,
  });
}

/// Karayolları Dairesi Resmi Yol Bildirimi
class KarayollariYolBildirimi {
  final String id;
  final String baslik;
  final String baslikEn;
  final String detay;
  final String detayEn;
  final String bolge;
  final String seviye; // 'dikkat', 'bilgi', 'acil'
  final String tarih;

  const KarayollariYolBildirimi({
    required this.id,
    required this.baslik,
    required this.baslikEn,
    required this.detay,
    required this.detayEn,
    required this.bolge,
    required this.seviye,
    required this.tarih,
  });
}

/// KKTC Kamu Veri Köprüsü Singleton Servisi
class KktcGovSyncService extends ChangeNotifier {
  static final KktcGovSyncService _instance = KktcGovSyncService._internal();
  factory KktcGovSyncService() => _instance;
  KktcGovSyncService._internal() {
    _sonGuncelleme = DateTime.now();
  }

  // --- CANLI DEVLET ENTEGRASYONU CONFIG AYARLARI ---
  // Devlet API sağladığında burası true yapılır ve endpointler gerçek sunucuya bağlanır!
  bool isLiveApiMode = false;
  String pgmApiUrl = "https://api.polis.gov.ct.tr/v1/trafik";
  String maliyeApiUrl = "https://api.gelir.gov.ct.tr/v1/arac";
  String edevletAuthUrl = "https://edevlet.gov.ct.tr/oauth2";
  String sigortaHavuzuUrl = "https://api.kktcsigorta.org/v1/police";

  bool _senkronizeEdiliyor = false;
  bool get senkronizeEdiliyor => _senkronizeEdiliyor;

  DateTime _sonGuncelleme = DateTime.now();
  DateTime get sonGuncelleme => _sonGuncelleme;

  int _ortalamaPingMs = 24;
  int get ortalamaPingMs => _ortalamaPingMs;

  // Kamu Sunucuları Durum Listesi
  List<KamuSunucuDurumu> get sunucular => [
        KamuSunucuDurumu(
          servisAdi: "PGM Trafik Ceza Sorgulama",
          kurum: "Polis Genel Müdürlüğü",
          endpoint: pgmApiUrl,
          aktif: true,
          gecikmeMs: _ortalamaPingMs,
          protokol: "REST / HTTPS (TLS 1.3)",
          sonSenkron: "1 dk önce",
        ),
        KamuSunucuDurumu(
          servisAdi: "Seyrüsefer & Araç Kayıt",
          kurum: "Gelir ve Vergi Dairesi (Maliye)",
          endpoint: maliyeApiUrl,
          aktif: true,
          gecikmeMs: _ortalamaPingMs + 5,
          protokol: "SOAP XML & OAuth 2.0",
          sonSenkron: "3 dk önce",
        ),
        KamuSunucuDurumu(
          servisAdi: "e-Devlet Kimlik Doğrulama",
          kurum: "KKTC Başbakanlık Dijital Dönüşüm",
          endpoint: edevletAuthUrl,
          aktif: true,
          gecikmeMs: _ortalamaPingMs - 3,
          protokol: "OpenID Connect",
          sonSenkron: "Anlık / Canlı",
        ),
        KamuSunucuDurumu(
          servisAdi: "Trafik Sigortaları Bilgi Havuzu",
          kurum: "KKTC Sigorta ve Reasürans Birliği",
          endpoint: sigortaHavuzuUrl,
          aktif: true,
          gecikmeMs: _ortalamaPingMs + 8,
          protokol: "REST JSON API",
          sonSenkron: "10 dk önce",
        ),
      ];

  // Karayolları Dairesi Resmi Canlı Bildirimleri
  final List<KarayollariYolBildirimi> yolBildirimleri = [
    const KarayollariYolBildirimi(
      id: "YB-01",
      baslik: "Lefkoşa - Girne Boğaz Yolu Asfalt Bakımı",
      baslikEn: "Kyrenia Mountain Pass Asphalt Resurfacing",
      detay: "St. Hilarion - Boğaz piknik alanı virajlarında sağ şerit daraltılmıştır. Hız limiti 50 km/s.",
      detayEn: "Right lane narrowed near St. Hilarion curves. Speed limit reduced to 50 km/h.",
      bolge: "Girne / Boğaz",
      seviye: "dikkat",
      tarih: "Bugün 08:30",
    ),
    const KarayollariYolBildirimi(
      id: "YB-02",
      baslik: "Kuzey Çevre Yolu Haspolat Bağlantısı Açık",
      baslikEn: "North Bypass Haspolat Link Open & Clear",
      detay: "Lefkoşa Kuzey Çevre Yolu Haspolat - UKÜ viyadüğünde trafik akışı ışıksız ve kesintisizdir.",
      detayEn: "North Bypass via Haspolat is fully open without traffic lights.",
      bolge: "Lefkoşa / Haspolat",
      seviye: "bilgi",
      tarih: "Bugün 09:15",
    ),
    const KarayollariYolBildirimi(
      id: "YB-03",
      baslik: "Kalkanlı - Güzelyurt Yolunda Gece Yağış Uyarısı",
      baslikEn: "METU Kalkanli Route Wet Road Advisory",
      detay: "ODTÜ Kalkanlı güzergahında hafif yağış nedeniyle virajlarda hız sınırlarına (65 km/s) riayet ediniz.",
      detayEn: "Drive carefully on Kalkanli METU route due to wet road conditions. Observe 65 km/h.",
      bolge: "Güzelyurt / Kalkanlı",
      seviye: "dikkat",
      tarih: "Bugün 11:00",
    ),
  ];

  /// Canlı Devlet Sunucularını Sorgula & Senkronize Et Simülasyonu
  Future<bool> sunuculariSenkronizeEt() async {
    _senkronizeEdiliyor = true;
    notifyListeners();

    // 700ms - 1100ms arası gerçekçi ağ gecikmesi
    await Future.delayed(const Duration(milliseconds: 850));

    _ortalamaPingMs = 20 + math.Random().nextInt(14);
    _sonGuncelleme = DateTime.now();
    _senkronizeEdiliyor = false;
    notifyListeners();
    return true;
  }

  /// Resmi Ceza Doğrulama Kodu Üretici (Devlet Formatı)
  static String resmiCezaKoduUret() {
    final now = DateTime.now();
    final randomSayi = 1000 + math.Random().nextInt(8999);
    return "PGM-TRF-${now.year}/$randomSayi";
  }

  /// Resmi Seyrüsefer Belge Numarası Üretici (Maliye Formatı)
  static String resmiSeyruseferKoduUret(String plaka) {
    final now = DateTime.now();
    return "KKTC-MAL-${now.year}/${plaka.replaceAll(' ', '')}-OK";
  }
}

// ==========================================
// 🛡️ DEVLET SENKRONİZASYON DURUMU ÜST ŞERİDİ
// ==========================================
class KamuSunucuDurumSeridi extends StatelessWidget {
  final bool turkceMi;

  const KamuSunucuDurumSeridi({super.key, required this.turkceMi});

  @override
  Widget build(BuildContext context) {
    final gov = KktcGovSyncService();

    return AnimatedBuilder(
      animation: gov,
      builder: (context, _) {
        final dateStr =
            "${gov.sonGuncelleme.hour.toString().padLeft(2, '0')}:${gov.sonGuncelleme.minute.toString().padLeft(2, '0')}:${gov.sonGuncelleme.second.toString().padLeft(2, '0')}";

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _kamuDurumModaliniAc(context, turkceMi),
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF131A33),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: gov.senkronizeEdiliyor
                      ? const Color(0xFFFFB800).withValues(alpha: 0.4)
                      : const Color(0xFF4EDEA3).withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Durum Nabzı (Yeşil / Sarı)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: gov.senkronizeEdiliyor
                          ? const Color(0xFFFFB800)
                          : const Color(0xFF4EDEA3),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: gov.senkronizeEdiliyor
                              ? const Color(0xFFFFB800).withValues(alpha: 0.6)
                              : const Color(0xFF4EDEA3).withValues(alpha: 0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Durum Metni
                  Expanded(
                    child: Text(
                      gov.senkronizeEdiliyor
                          ? (turkceMi ? 'KKTC Kamu Ağları Eşitleniyor...' : 'Syncing TRNC Gov Networks...')
                          : (turkceMi
                              ? 'PGM & Maliye Sunucuları Aktif • $dateStr'
                              : 'PGM & Tax Servers Online • $dateStr'),
                      style: const TextStyle(
                        color: Color(0xFFDBE1FF),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Güvenlik & Ping Rozeti
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF212942),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock_rounded, size: 10, color: Color(0xFF4EDEA3)),
                            const SizedBox(width: 3),
                            Text(
                              '${gov.ortalamaPingMs}ms',
                              style: const TextStyle(
                                color: Color(0xFFBDC5E9),
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFBDC5E9)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void _kamuDurumModaliniAc(BuildContext context, bool turkceMi) {
    final gov = KktcGovSyncService();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131A33),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sürükleme Tutamacı
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Başlık & Kalkan İkonu
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD90429).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD90429).withValues(alpha: 0.3)),
                        ),
                        child: const Icon(Icons.shield_rounded, color: Color(0xFFD90429), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              turkceMi ? 'KKTC Resmi Kamu Entegrasyon Ağı' : 'TRNC Official Gov Integration',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              turkceMi
                                  ? 'Polis Genel Md. & Maliye Bakanlığı Veri Tabanı'
                                  : 'Police Headquarters & Ministry of Finance Database',
                              style: const TextStyle(
                                color: Color(0xFFBDC5E9),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Kurumsal Sunucu Listesi
                  ...gov.sunucular.map((sunucu) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF212942),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4EDEA3),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sunucu.servisAdi,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${sunucu.kurum} • ${sunucu.protokol}",
                                  style: const TextStyle(
                                    color: Color(0xFFBDC5E9),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF007C55).withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${sunucu.gecikmeMs}ms",
                              style: const TextStyle(
                                color: Color(0xFF4EDEA3),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 12),

                  // Canlı Senkronize Et Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: gov.senkronizeEdiliyor
                          ? null
                          : () async {
                              setModalState(() {});
                              await gov.sunuculariSenkronizeEt();
                              setModalState(() {});
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD90429),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                      icon: gov.senkronizeEdiliyor
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.sync_rounded, size: 20),
                      label: Text(
                        gov.senkronizeEdiliyor
                          ? (turkceMi ? 'Kamu Veritabanı Sorgulanıyor...' : 'Querying Gov Database...')
                          : (turkceMi ? 'Şimdi Kamu Verilerini Eşitle' : 'Sync Gov Data Now'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
