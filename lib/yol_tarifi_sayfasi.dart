import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'radar_haritasi.dart';

// ==========================================
// 🎨 NAVİGASYON VE HARİTA TASARIM TOKENLARI
// ==========================================
class NavHtmlColors {
  static const Color background = Color(0xFF0A122A);
  static const Color surfaceContainer = Color(0xFF171E37);
  static const Color surfaceContainerLow = Color(0xFF131A33);
  static const Color surfaceContainerLowest = Color(0xFF050D25);
  static const Color surfaceContainerHigh = Color(0xFF212942);
  static const Color surfaceContainerHighest = Color(0xFF2C344D);
  static const Color surfaceBright = Color(0xFF313852);
  static const Color primaryContainer = Color(0xFFD90429); // Modern KKTC Crimson
  static const Color primary = Color(0xFFFFB3AF);
  static const Color primaryFixedDim = Color(0xFFFFB3AF);
  static const Color secondary = Color(0xFFBDC5E9);
  static const Color tertiary = Color(0xFF4EDEA3); // Neon Emerald
  static const Color tertiaryContainer = Color(0xFF007C55);
  static const Color onSurface = Color(0xFFDBE1FF);
  static const Color onPrimary = Color(0xFF68000F);
  static const Color warning = Color(0xFFFFB800);
}

// ==========================================
// 📍 ROTA NOKTASI MODELİ
// ==========================================
class RotaNoktasi {
  final String id;
  final String ad;
  final String adEn;
  final String kisaAd;
  final String bolge;
  final double lat;
  final double lon;
  final IconData ikon;

  const RotaNoktasi({
    required this.id,
    required this.ad,
    required this.adEn,
    required this.kisaAd,
    required this.bolge,
    required this.lat,
    required this.lon,
    required this.ikon,
  });
}

// KKTC Önemli Noktalar Veritabanı
final List<RotaNoktasi> kktcNoktalari = [
  const RotaNoktasi(
    id: "kalkanli",
    ad: "Kalkanlı (ODTÜ Kuzey Kıbrıs Kampüsü)",
    adEn: "Kalkanli (METU Northern Cyprus)",
    kisaAd: "ODTÜ Kalkanlı",
    bolge: "Güzelyurt",
    lat: 35.2470,
    lon: 33.0280,
    ikon: Icons.school_rounded,
  ),
  const RotaNoktasi(
    id: "erulku",
    ad: "Erülkü Süpermarket (Demirhan)",
    adEn: "Erulku Supermarket (Demirhan)",
    kisaAd: "Erülkü Demirhan",
    bolge: "Lefkoşa",
    lat: 35.2185,
    lon: 33.4820,
    ikon: Icons.shopping_cart_rounded,
  ),
  const RotaNoktasi(
    id: "guzelyurt_merkez",
    ad: "Güzelyurt Terminal & Merkez",
    adEn: "Guzelyurt Terminal & Center",
    kisaAd: "Güzelyurt Merkez",
    bolge: "Güzelyurt",
    lat: 35.2005,
    lon: 32.9920,
    ikon: Icons.directions_bus_rounded,
  ),
  const RotaNoktasi(
    id: "lefkosa_dereboyu",
    ad: "Lefkoşa Dereboyu Caddesi",
    adEn: "Lefkosa Dereboyu Avenue",
    kisaAd: "Lefkoşa Dereboyu",
    bolge: "Lefkoşa",
    lat: 35.1920,
    lon: 33.3510,
    ikon: Icons.location_city_rounded,
  ),
  const RotaNoktasi(
    id: "gonyeli_cemberi",
    ad: "Gönyeli Çemberi & Girişi",
    adEn: "Gonyeli Roundabout",
    kisaAd: "Gönyeli Çemberi",
    bolge: "Lefkoşa",
    lat: 35.2132,
    lon: 33.3085,
    ikon: Icons.trip_origin_rounded,
  ),
  const RotaNoktasi(
    id: "ercan_havalimani",
    ad: "Ercan Yeni Uluslararası Havalimanı",
    adEn: "Ercan International Airport",
    kisaAd: "Ercan Havalimanı",
    bolge: "Lefkoşa / Meriç",
    lat: 35.1580,
    lon: 33.5040,
    ikon: Icons.flight_takeoff_rounded,
  ),
  const RotaNoktasi(
    id: "girne_liman",
    ad: "Girne Tarihi Liman & Merkez",
    adEn: "Kyrenia Harbor & Center",
    kisaAd: "Girne Limanı",
    bolge: "Girne",
    lat: 35.3420,
    lon: 33.3210,
    ikon: Icons.sailing_rounded,
  ),
  const RotaNoktasi(
    id: "magusa_dau",
    ad: "Gazimağusa (Doğu Akdeniz Üni - DAÜ)",
    adEn: "Famagusta (EMU Campus)",
    kisaAd: "DAÜ Gazimağusa",
    bolge: "Gazimağusa",
    lat: 35.1450,
    lon: 33.9140,
    ikon: Icons.account_balance_rounded,
  ),
  const RotaNoktasi(
    id: "haspolat_uku",
    ad: "Haspolat (Uluslararası Kıbrıs Üni - UKÜ)",
    adEn: "Haspolat (CIU Campus)",
    kisaAd: "UKÜ Haspolat",
    bolge: "Lefkoşa",
    lat: 35.2168,
    lon: 33.4350,
    ikon: Icons.school_outlined,
  ),
  const RotaNoktasi(
    id: "lefke_lau",
    ad: "Lefke Avrupa Üniversitesi (LAÜ)",
    adEn: "European University of Lefke (EUL)",
    kisaAd: "LAÜ Lefke",
    bolge: "Lefke",
    lat: 35.1120,
    lon: 32.8520,
    ikon: Icons.school_rounded,
  ),
];

// ==========================================
// 🛣️ ADIM ADIM MANEVRA MODELİ
// ==========================================
class RotaManevraAdimi {
  final IconData ikon;
  final String baslik;
  final String baslikEn;
  final String aciklama;
  final String aciklamaEn;
  final String mesafe;
  final RadarKamerasi? bagliRadar;
  final bool onemliMi;

  const RotaManevraAdimi({
    required this.ikon,
    required this.baslik,
    required this.baslikEn,
    required this.aciklama,
    required this.aciklamaEn,
    required this.mesafe,
    this.bagliRadar,
    this.onemliMi = false,
  });
}

// ==========================================
// 🗺️ HESAPLANMIŞ ROTA VERİSİ
// ==========================================
class HesaplanmisRota {
  final RotaNoktasi baslangic;
  final RotaNoktasi varis;
  final String secenekAdi;
  final String secenekAdiEn;
  final double mesafeKm;
  final int tahminiDakika;
  final String kolaylikOzeti;
  final String kolaylikOzetiEn;
  final List<RadarKamerasi> radarlar;
  final List<RotaManevraAdimi> manevralar;
  final List<Offset> haritaYolNoktalari; // Göreli normalize koordinatlar (0.0 - 1.0)

  const HesaplanmisRota({
    required this.baslangic,
    required this.varis,
    required this.secenekAdi,
    required this.secenekAdiEn,
    required this.mesafeKm,
    required this.tahminiDakika,
    required this.kolaylikOzeti,
    required this.kolaylikOzetiEn,
    required this.radarlar,
    required this.manevralar,
    required this.haritaYolNoktalari,
  });
}

// ==========================================
// 🚀 ANA YOL TARİFİ VE NAVİGASYON SAYFASI
// ==========================================
class YolTarifiSayfasi extends StatefulWidget {
  final bool turkceMi;

  const YolTarifiSayfasi({super.key, required this.turkceMi});

  @override
  State<YolTarifiSayfasi> createState() => _YolTarifiSayfasiState();
}

class _YolTarifiSayfasiState extends State<YolTarifiSayfasi>
    with SingleTickerProviderStateMixin {
  late RotaNoktasi _baslangicNoktasi;
  late RotaNoktasi _varisNoktasi;
  int _secilenRotaModu = 0; // 0 = En Kolay & Hızlı (Çevre Yolu), 1 = Şehir İçi Alternatif

  // Canlı Simülasyon Durumları
  bool _simulasyonAktif = false;
  double _simulasyonIlerleme = 0.0;
  Timer? _simulasyonTimer;
  int _canliSurusHizi = 64;
  RadarKamerasi? _yaklasanRadar;
  double _yaklasanRadarMesafeMetre = 0.0;

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    // Varsayılan: Kullanıcının özel istediği Kalkanlı -> Erülkü rotası!
    _baslangicNoktasi = kktcNoktalari.firstWhere(
      (n) => n.id == "kalkanli",
      orElse: () => kktcNoktalari[0],
    );
    _varisNoktasi = kktcNoktalari.firstWhere(
      (n) => n.id == "erulku",
      orElse: () => kktcNoktalari[1],
    );
  }

  @override
  void dispose() {
    _simulasyonTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _noktalariDegistir() {
    setState(() {
      final gecici = _baslangicNoktasi;
      _baslangicNoktasi = _varisNoktasi;
      _varisNoktasi = gecici;
      _durdurSimulasyon();
    });
  }

  void _hazirRotaSec(String baslangicId, String varisId) {
    setState(() {
      _baslangicNoktasi = kktcNoktalari.firstWhere(
        (n) => n.id == baslangicId,
        orElse: () => kktcNoktalari[0],
      );
      _varisNoktasi = kktcNoktalari.firstWhere(
        (n) => n.id == varisId,
        orElse: () => kktcNoktalari[1],
      );
      _secilenRotaModu = 0;
      _durdurSimulasyon();
    });
  }

  void _baslatSimulasyon() {
    setState(() {
      _simulasyonAktif = true;
      _simulasyonIlerleme = 0.0;
    });

    _simulasyonTimer?.cancel();
    _simulasyonTimer = Timer.periodic(const Duration(milliseconds: 200), (t) {
      if (!mounted) return;
      setState(() {
        _simulasyonIlerleme += 0.007; // ~30 saniyede rotayı tamamlar
        if (_simulasyonIlerleme >= 1.0) {
          _simulasyonIlerleme = 1.0;
          _durdurSimulasyon();
          _gosterHedefeUlasildi();
          return;
        }

        // Hız dalgalanması
        final speeds = [64, 65, 66, 68, 63, 65, 62, 72, 70];
        _canliSurusHizi = speeds[(t.tick) % speeds.length];

        // Yaklaşan radar tespiti
        final rota = _rotaHesapla();
        if (rota.radarlar.isNotEmpty) {
          int radarIndex = ((_simulasyonIlerleme * rota.radarlar.length)).clamp(0, rota.radarlar.length - 1).toInt();
          _yaklasanRadar = rota.radarlar[radarIndex];
          double kalanKmMesafesi = (1.0 - _simulasyonIlerleme) * rota.mesafeKm;
          _yaklasanRadarMesafeMetre = (kalanKmMesafesi * 250).clamp(150, 4800);
        }
      });
    });
  }

  void _durdurSimulasyon() {
    _simulasyonTimer?.cancel();
    setState(() {
      _simulasyonAktif = false;
      _simulasyonIlerleme = 0.0;
      _yaklasanRadar = null;
    });
  }

  void _gosterHedefeUlasildi() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: NavHtmlColors.tertiary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.turkceMi
                    ? 'Tebrikler! Güzergahtaki tüm radarlar aşıldı ve hedefe ulaşıldı.'
                    : 'Congratulations! All radars cleared and destination reached.',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: NavHtmlColors.surfaceContainerHighest,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // Akıllı Rota Hesaplayıcı (TRNC Yol Ağı ve Radarlarını Analiz Eder)
  HesaplanmisRota _rotaHesapla() {
    bool kalkanliErulkuMu = (_baslangicNoktasi.id == "kalkanli" && _varisNoktasi.id == "erulku") ||
        (_baslangicNoktasi.id == "erulku" && _varisNoktasi.id == "kalkanli");

    RadarKamerasi kalkanliRadar = kktcRadarListesi.firstWhere(
      (r) => r.id == "RAD-15",
      orElse: () => kktcRadarListesi.first,
    );
    RadarKamerasi yilmazkoyRadar = kktcRadarListesi.firstWhere(
      (r) => r.id == "RAD-14",
      orElse: () => kktcRadarListesi.first,
    );
    RadarKamerasi gonyeliRadar = kktcRadarListesi.firstWhere(
      (r) => r.id == "RAD-01",
      orElse: () => kktcRadarListesi.first,
    );
    RadarKamerasi hamitkoyRadar = kktcRadarListesi.firstWhere(
      (r) => r.id == "RAD-03",
      orElse: () => kktcRadarListesi.first,
    );
    RadarKamerasi haspolatRadar = kktcRadarListesi.firstWhere(
      (r) => r.id == "RAD-04",
      orElse: () => kktcRadarListesi.first,
    );
    RadarKamerasi erulkuRadar = kktcRadarListesi.firstWhere(
      (r) => r.id == "RAD-19",
      orElse: () => kktcRadarListesi.first,
    );

    if (kalkanliErulkuMu) {
      if (_secilenRotaModu == 0) {
        // EN KOLAY & EN HIZLI: ODTÜ Kalkanlı -> Güzelyurt -> Lefkoşa Kuzey Çevre Yolu -> Haspolat -> Erülkü
        return HesaplanmisRota(
          baslangic: _baslangicNoktasi,
          varis: _varisNoktasi,
          secenekAdi: "Kuzey Çevre Yolu Üzerinden (En Rahat & Kolay)",
          secenekAdiEn: "Via North Bypass Road (Easiest & Fastest)",
          mesafeKm: 48.2,
          tahminiDakika: 41,
          kolaylikOzeti:
              "Gönyeli şehir trafiğine ve 50 km/s hız radarlarına girmeden Kuzey Çevre Yolu'ndan kesintisiz, ışıksız olarak Erülkü Demirhan'a varış.",
          kolaylikOzetiEn:
              "Bypasses congested Gonyeli center and 50 km/h cameras via uninterrupted North Bypass directly to Erulku Demirhan.",
          radarlar: [
            kalkanliRadar,
            yilmazkoyRadar,
            hamitkoyRadar,
            haspolatRadar,
            erulkuRadar,
          ],
          manevralar: [
            RotaManevraAdimi(
              ikon: Icons.navigation_rounded,
              baslik: "Kalkanlı ODTÜ Nizamiyesi'nden Çıkış",
              baslikEn: "Exit METU Kalkanli Campus Gates",
              aciklama: "Kampüs ana güvenlik kapısından çıkıp Güzelyurt anayoluna bağlanın.",
              aciklamaEn: "Leave main security gates and join Guzelyurt highway.",
              mesafe: "3.2 km",
              bagliRadar: kalkanliRadar,
              onemliMi: true,
            ),
            RotaManevraAdimi(
              ikon: Icons.roundabout_right_rounded,
              baslik: "Güzelyurt Çemberi - Lefkoşa Anayolu",
              baslikEn: "Guzelyurt Roundabout - Lefkosa Highway",
              aciklama: "Çemberin 2. çıkışından çift şerit bölünmüş Lefkoşa anayoluna katılın.",
              aciklamaEn: "Take 2nd exit into dual-lane divided Lefkosa highway.",
              mesafe: "14.5 km",
            ),
            RotaManevraAdimi(
              ikon: Icons.speed_rounded,
              baslik: "Yılmazköy Düzlüğü Hız Kontrolü",
              baslikEn: "Yilmazkoy Straight Speed Control",
              aciklama: "Uzun düzlükte 75 km/s sabit radar aktiftir. Hız sabitleyiciyi 75 km/s'e kurun.",
              aciklamaEn: "75 km/h speed camera active on the long straight. Keep under limit.",
              mesafe: "9.8 km",
              bagliRadar: yilmazkoyRadar,
              onemliMi: true,
            ),
            RotaManevraAdimi(
              ikon: Icons.alt_route_rounded,
              baslik: "Kuzey Çevre Yolu Sapağı (En Kolay Yol Tavsiyesi)",
              baslikEn: "North Bypass Exit (Easiest Route Advice)",
              aciklama: "Gönyeli çemberine girmeden sağ sapaktan yeni Lefkoşa Kuzey Çevre Yolu'na girin.",
              aciklamaEn: "Veer right before Gonyeli roundabout onto the new Lefkosa North Bypass.",
              mesafe: "11.4 km",
              bagliRadar: hamitkoyRadar,
              onemliMi: true,
            ),
            RotaManevraAdimi(
              ikon: Icons.merge_type_rounded,
              baslik: "Haspolat - UKÜ Bağlantısı",
              baslikEn: "Haspolat - CIU Highway Connection",
              aciklama: "Çevre yolundan Gazimağusa anayoluna sorunsuz bağlanın. UKÜ alt geçit radarını geçin.",
              aciklamaEn: "Merge seamlessly onto Famagusta highway past CIU underpass radar.",
              mesafe: "5.5 km",
              bagliRadar: haspolatRadar,
              onemliMi: true,
            ),
            RotaManevraAdimi(
              ikon: Icons.storefront_rounded,
              baslik: "Demirhan - Erülkü Süpermarket Varış",
              baslikEn: "Demirhan - Erulku Supermarket Arrival",
              aciklama: "Sağ tarafta Erülkü Süpermarket ana otopark girişine yanaşın. Radara dikkat edin!",
              aciklamaEn: "Pull into Erulku Supermarket parking lot on right. Watch 65 km/h camera!",
              mesafe: "3.8 km",
              bagliRadar: erulkuRadar,
              onemliMi: true,
            ),
          ],
          haritaYolNoktalari: const [
            Offset(0.18, 0.46), // Kalkanlı
            Offset(0.24, 0.52), // Güzelyurt
            Offset(0.36, 0.52), // Yılmazköy
            Offset(0.48, 0.47), // Gönyeli Kuzey Çevre Sapağı
            Offset(0.58, 0.44), // Hamitköy Viyadüğü
            Offset(0.68, 0.47), // Haspolat UKÜ
            Offset(0.76, 0.48), // Erülkü Demirhan
          ],
        );
      } else {
        // ALTERNATİF: Gönyeli Merkez & Lefkoşa Şehir İçi (Daha yoğun trafik ve 50 km/s radarlar)
        return HesaplanmisRota(
          baslangic: _baslangicNoktasi,
          varis: _varisNoktasi,
          secenekAdi: "Gönyeli & Lefkoşa Şehir İçi (Işıklı & Yoğun)",
          secenekAdiEn: "Via Gonyeli & Lefkosa City (High Traffic)",
          mesafeKm: 51.6,
          tahminiDakika: 58,
          kolaylikOzeti:
              "Gönyeli çemberi ve Lefkoşa içi ışıklardan geçer. Trafik saatlerinde yavaştır ve 50 km/s hız radarları yoğundur.",
          kolaylikOzetiEn:
              "Passes through Gonyeli roundabout and city signals. Slower during rush hour with 50 km/h speed cameras.",
          radarlar: [
            kalkanliRadar,
            yilmazkoyRadar,
            gonyeliRadar,
            hamitkoyRadar,
            haspolatRadar,
            erulkuRadar,
          ],
          manevralar: [
            RotaManevraAdimi(
              ikon: Icons.navigation_rounded,
              baslik: "Kalkanlı ODTÜ'den Çıkış",
              baslikEn: "Exit METU Kalkanli",
              aciklama: "Güzelyurt istikametine devam edin.",
              aciklamaEn: "Head towards Guzelyurt.",
              mesafe: "3.2 km",
              bagliRadar: kalkanliRadar,
            ),
            RotaManevraAdimi(
              ikon: Icons.straight_rounded,
              baslik: "Güzelyurt - Lefkoşa Anayolu",
              baslikEn: "Guzelyurt - Lefkosa Highway",
              aciklama: "Yılmazköy radarını 75 km/s ile geçin.",
              aciklamaEn: "Pass Yilmazkoy radar under 75 km/h.",
              mesafe: "24.0 km",
              bagliRadar: yilmazkoyRadar,
            ),
            RotaManevraAdimi(
              ikon: Icons.warning_amber_rounded,
              baslik: "Gönyeli Çemberi Şehir İçi Girişi",
              baslikEn: "Gonyeli Roundabout City Entry",
              aciklama: "⚠️ 50 km/s kırmızı ışık ve hız radarı mevcuttur! Yoğun kavşak.",
              aciklamaEn: "⚠️ 50 km/h red light and speed camera! Heavy congestion.",
              mesafe: "7.4 km",
              bagliRadar: gonyeliRadar,
              onemliMi: true,
            ),
            RotaManevraAdimi(
              ikon: Icons.storefront_rounded,
              baslik: "Hamitköy & Haspolat Üzerinden Erülkü'ye Varış",
              baslikEn: "Arrival at Erulku via Hamitkoy & Haspolat",
              aciklama: "Mağusa anayoluna çıkıp Erülkü Demirhan'a ulaşın.",
              aciklamaEn: "Take Famagusta highway to Erulku Demirhan.",
              mesafe: "17.0 km",
              bagliRadar: erulkuRadar,
            ),
          ],
          haritaYolNoktalari: const [
            Offset(0.18, 0.46), // Kalkanlı
            Offset(0.24, 0.52), // Güzelyurt
            Offset(0.36, 0.52), // Yılmazköy
            Offset(0.50, 0.53), // Gönyeli Merkez
            Offset(0.56, 0.52), // Hamitköy
            Offset(0.68, 0.48), // Haspolat
            Offset(0.76, 0.48), // Erülkü
          ],
        );
      }
    }

    // 🟢 KALKANLI <-> GÜZELYURT MERKEZ ÖZEL ROTASI
    bool kalkanliGuzelyurtMu = (_baslangicNoktasi.id == "kalkanli" && _varisNoktasi.id == "guzelyurt_merkez") ||
        (_baslangicNoktasi.id == "guzelyurt_merkez" && _varisNoktasi.id == "kalkanli");

    if (kalkanliGuzelyurtMu) {
      return HesaplanmisRota(
        baslangic: _baslangicNoktasi,
        varis: _varisNoktasi,
        secenekAdi: "Kalkanlı - Güzelyurt Anayolu",
        secenekAdiEn: "Kalkanli - Guzelyurt Highway",
        mesafeKm: 6.2,
        tahminiDakika: 8,
        kolaylikOzeti:
            "ODTÜ Kalkanlı nizamiyesinden Güzelyurt anayolunu takip ederek doğrudan şehir merkezine ve terminale varış. Hızlı ve rahattır.",
        kolaylikOzetiEn:
            "Direct route from METU Kalkanli gates along Guzelyurt highway straight to town center & terminal.",
        radarlar: [kalkanliRadar],
        manevralar: [
          RotaManevraAdimi(
            ikon: Icons.navigation_rounded,
            baslik: "Kalkanlı ODTÜ Kampüs Çıkışı",
            baslikEn: "Exit METU Kalkanli Campus",
            aciklama: "Nizamiyeden ayrılarak Güzelyurt istikametine katılın.",
            aciklamaEn: "Depart security gates and join Guzelyurt highway.",
            mesafe: "1.2 km",
          ),
          RotaManevraAdimi(
            ikon: Icons.speed_rounded,
            baslik: "Kalkanlı Yolu Radar Denetimi",
            baslikEn: "Kalkanli Road Speed Camera",
            aciklama: "⚠️ Hız limiti: 65 km/s. ODTÜ güzergahındaki sabit hız radarına dikkat edin.",
            aciklamaEn: "⚠️ Speed limit: 65 km/h. Watch fixed speed camera on METU route.",
            mesafe: "3.2 km",
            bagliRadar: kalkanliRadar,
            onemliMi: true,
          ),
          RotaManevraAdimi(
            ikon: Icons.place_rounded,
            baslik: "Güzelyurt Terminal & Merkez Varış",
            baslikEn: "Guzelyurt Center & Terminal Arrival",
            aciklama: "Hedefinize ulaştınız. Çarşı ve terminal otoparkına yanaşın.",
            aciklamaEn: "Destination reached. Proceed to center/terminal parking.",
            mesafe: "1.8 km",
            onemliMi: true,
          ),
        ],
        haritaYolNoktalari: const [
          Offset(0.18, 0.46), // Kalkanlı
          Offset(0.20, 0.48),
          Offset(0.22, 0.50),
          Offset(0.24, 0.52), // Güzelyurt
        ],
      );
    }

    // DİĞER ROTALAR İÇİN GENEL HESAPLAMA (Örn: Girne -> Lefkoşa, Gazimağusa -> Erülkü vb.)
    double dx = (_varisNoktasi.lon - _baslangicNoktasi.lon).abs();
    double dy = (_varisNoktasi.lat - _baslangicNoktasi.lat).abs();
    double rawDist = math.sqrt(dx * dx + dy * dy) * 111.0;
    double distKm = (rawDist * 1.25).clamp(4.0, 110.0);
    int durationMin = (distKm * 1.15).round();

    // Rota çevresindeki radarları filtrele
    double minLat = math.min(_baslangicNoktasi.lat, _varisNoktasi.lat) - 0.05;
    double maxLat = math.max(_baslangicNoktasi.lat, _varisNoktasi.lat) + 0.05;
    double minLon = math.min(_baslangicNoktasi.lon, _varisNoktasi.lon) - 0.05;
    double maxLon = math.max(_baslangicNoktasi.lon, _varisNoktasi.lon) + 0.05;

    List<RadarKamerasi> yolRadarlari = kktcRadarListesi.where((r) {
      return r.lat >= minLat && r.lat <= maxLat && r.lon >= minLon && r.lon <= maxLon;
    }).toList();

    List<RotaManevraAdimi> dinamikManevralar = [
      RotaManevraAdimi(
        ikon: Icons.trip_origin_rounded,
        baslik: "${_baslangicNoktasi.kisaAd}'dan Çıkış Yapın",
        baslikEn: "Depart from ${_baslangicNoktasi.kisaAd}",
        aciklama: "Ana caddeye katılarak navigasyon güzergahını takip edin.",
        aciklamaEn: "Join main thoroughfare and follow route.",
        mesafe: "${(distKm * 0.2).clamp(1.0, 4.0).toStringAsFixed(1)} km",
      ),
    ];

    if (yolRadarlari.isNotEmpty) {
      dinamikManevralar.add(
        RotaManevraAdimi(
          ikon: Icons.speed_rounded,
          baslik: "${yolRadarlari.first.ad} (Hız Kontrolü)",
          baslikEn: "${yolRadarlari.first.adEn} (Speed Check)",
          aciklama:
              "⚠️ Hız limiti: ${yolRadarlari.first.hizLimiti} km/s. Güzergahtaki sabit denetim noktası.",
          aciklamaEn: "⚠️ Speed limit: ${yolRadarlari.first.hizLimiti} km/h. Fixed speed point.",
          mesafe: "${(distKm * 0.5).clamp(1.5, 35.0).toStringAsFixed(1)} km",
          bagliRadar: yolRadarlari.first,
          onemliMi: true,
        ),
      );
    }

    dinamikManevralar.add(
      RotaManevraAdimi(
        ikon: Icons.place_rounded,
        baslik: "${_varisNoktasi.kisaAd} Varış",
        baslikEn: "Arrive at ${_varisNoktasi.kisaAd}",
        aciklama: "Hedefinize ulaştınız. Güvenli park alanına yanaşın.",
        aciklamaEn: "Destination reached. Proceed to designated parking.",
        mesafe: "${(distKm * 0.3).clamp(1.0, 8.0).toStringAsFixed(1)} km",
        onemliMi: true,
      ),
    );

    return HesaplanmisRota(
      baslangic: _baslangicNoktasi,
      varis: _varisNoktasi,
      secenekAdi: "En Hızlı Anayol Güzergahı",
      secenekAdiEn: "Fastest Highway Route",
      mesafeKm: double.parse(distKm.toStringAsFixed(1)),
      tahminiDakika: durationMin,
      kolaylikOzeti:
          "${_baslangicNoktasi.kisaAd} noktasından ${_varisNoktasi.kisaAd} varışına ana arterler ve çevre yolları kullanılarak en rahat güzergah.",
      kolaylikOzetiEn:
          "Optimal route from ${_baslangicNoktasi.kisaAd} to ${_varisNoktasi.kisaAd} using primary bypass corridors.",
      radarlar: yolRadarlari,
      manevralar: dinamikManevralar,
      haritaYolNoktalari: const [
        Offset(0.20, 0.40),
        Offset(0.35, 0.48),
        Offset(0.50, 0.50),
        Offset(0.65, 0.52),
        Offset(0.80, 0.55),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final rota = _rotaHesapla();

    return Scaffold(
      backgroundColor: NavHtmlColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 🎯 BAŞLIK VE HIZLI HAZIR ROTALAR
            // ==========================================
            _buildUstBilgiVePresetler(),

            const SizedBox(height: 14),

            // ==========================================
            // 🚗 KALKIŞ & VARIŞ SEÇİCİ KARTI
            // ==========================================
            _buildGuzergahSeciciKarti(),

            const SizedBox(height: 14),

            // ==========================================
            // 🗺️ İNTERAKTİF ROTA VE RADAR HARİTASI
            // ==========================================
            _buildHaritaGorseli(rota),

            const SizedBox(height: 14),

            // ==========================================
            // 📊 ROTA ÖZETİ VE METRİKLER (Mesafe, Süre, Radar)
            // ==========================================
            _buildMetrikOzetKartlari(rota),

            const SizedBox(height: 14),

            // ==========================================
            // 💡 "NEREDEN KOLAY GİDEBİLİRİM?" TAVSİYE KARTI
            // ==========================================
            _buildKolaylikRehberiKarti(rota),

            const SizedBox(height: 14),

            // ==========================================
            // 📷 GÜZERGAHTAKİ SABİT RADARLAR LİSTESİ
            // ==========================================
            _buildGuzergahRadarlari(rota),

            const SizedBox(height: 14),

            // ==========================================
            // 🧭 ADIM ADIM MANEVRA VE YOL TARİFİ
            // ==========================================
            _buildAdimAdimManevralar(rota),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // --- 1. Üst Bilgi ve Popüler Rota Kısayolları ---
  Widget _buildUstBilgiVePresetler() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: NavHtmlColors.primaryContainer.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: NavHtmlColors.primaryContainer.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.alt_route_rounded, color: NavHtmlColors.primaryContainer, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.turkceMi ? 'KKTC Akıllı Yol Tarifi & Radar Rehberi' : 'TRNC Smart Route & Radar Guide',
                    style: const TextStyle(
                      color: NavHtmlColors.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    widget.turkceMi
                        ? 'Güzergahtaki tüm hız radarları ve en kolay yol tavsiyesi'
                        : 'Speed cameras on route and easiest travel recommendations',
                    style: TextStyle(
                      color: NavHtmlColors.secondary.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Popüler Rota Çipleri (Kalkanlı -> Erülkü vurgulu!)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPresetChip(
                etiket: "📍 Kalkanlı ➔ Erülkü (Demirhan)",
                seciliMi: _baslangicNoktasi.id == "kalkanli" && _varisNoktasi.id == "erulku",
                onTap: () => _hazirRotaSec("kalkanli", "erulku"),
                rozet: "En Popüler",
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                etiket: "✈️ Kalkanlı ➔ Ercan Havalimanı",
                seciliMi: _baslangicNoktasi.id == "kalkanli" && _varisNoktasi.id == "ercan_havalimani",
                onTap: () => _hazirRotaSec("kalkanli", "ercan_havalimani"),
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                etiket: "🛒 Lefkoşa ➔ Erülkü Süpermarket",
                seciliMi: _baslangicNoktasi.id == "lefkosa_dereboyu" && _varisNoktasi.id == "erulku",
                onTap: () => _hazirRotaSec("lefkosa_dereboyu", "erulku"),
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                etiket: "🌊 Girne ➔ Lefkoşa Dereboyu",
                seciliMi: _baslangicNoktasi.id == "girne_liman" && _varisNoktasi.id == "lefkosa_dereboyu",
                onTap: () => _hazirRotaSec("girne_liman", "lefkosa_dereboyu"),
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                etiket: "🎓 DAÜ Mağusa ➔ Ercan",
                seciliMi: _baslangicNoktasi.id == "magusa_dau" && _varisNoktasi.id == "ercan_havalimani",
                onTap: () => _hazirRotaSec("magusa_dau", "ercan_havalimani"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPresetChip({
    required String etiket,
    required bool seciliMi,
    required VoidCallback onTap,
    String? rozet,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: seciliMi
              ? NavHtmlColors.primaryContainer.withValues(alpha: 0.25)
              : NavHtmlColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: seciliMi ? NavHtmlColors.primaryContainer : Colors.white.withValues(alpha: 0.08),
            width: seciliMi ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              etiket,
              style: TextStyle(
                color: seciliMi ? Colors.white : NavHtmlColors.secondary,
                fontSize: 12,
                fontWeight: seciliMi ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (rozet != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: NavHtmlColors.tertiary.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  rozet,
                  style: const TextStyle(
                    color: NavHtmlColors.tertiary,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- 2. Kalkış ve Varış Noktası Seçici Kartı ---
  Widget _buildGuzergahSeciciKarti() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NavHtmlColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Sol dikey rota çizgisi (Yeşil -> Kırmızı)
              Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: NavHtmlColors.tertiary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: NavHtmlColors.tertiary.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 38,
                    color: NavHtmlColors.secondary.withValues(alpha: 0.3),
                  ),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: NavHtmlColors.primaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: NavHtmlColors.primaryContainer.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Nokta Seçim Dropdownları
              Expanded(
                child: Column(
                  children: [
                    // Başlangıç Noktası
                    _buildNoktaSecici(
                      etiket: widget.turkceMi ? 'Kalkış Noktası' : 'Starting Point',
                      secilenNokta: _baslangicNoktasi,
                      onChanged: (yeniNokta) {
                        if (yeniNokta != null) {
                          setState(() {
                            _baslangicNoktasi = yeniNokta;
                            _durdurSimulasyon();
                          });
                        }
                      },
                    ),
                    const Divider(color: Colors.white12, height: 16),
                    // Varış Noktası
                    _buildNoktaSecici(
                      etiket: widget.turkceMi ? 'Varış Noktası (Hedef)' : 'Destination',
                      secilenNokta: _varisNoktasi,
                      onChanged: (yeniNokta) {
                        if (yeniNokta != null) {
                          setState(() {
                            _varisNoktasi = yeniNokta;
                            _durdurSimulasyon();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Yön Değiştirme Butonu (⇄)
              GestureDetector(
                onTap: _noktalariDegistir,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: NavHtmlColors.surfaceContainerLowest,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: const Icon(
                    Icons.swap_vert_rounded,
                    color: NavHtmlColors.onSurface,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Rota Alternatifi Seçici Butonları (Kuzey Çevre Yolu vs Şehir İçi)
          if ((_baslangicNoktasi.id == "kalkanli" && _varisNoktasi.id == "erulku") ||
              (_baslangicNoktasi.id == "erulku" && _varisNoktasi.id == "kalkanli"))
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: NavHtmlColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _secilenRotaModu = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _secilenRotaModu == 0
                              ? NavHtmlColors.tertiaryContainer.withValues(alpha: 0.45)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: _secilenRotaModu == 0
                                ? NavHtmlColors.tertiary
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 15,
                              color: _secilenRotaModu == 0
                                  ? NavHtmlColors.tertiary
                                  : NavHtmlColors.secondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.turkceMi ? 'Kuzey Çevre Yolu (Önerilen)' : 'North Bypass (Rec.)',
                              style: TextStyle(
                                color: _secilenRotaModu == 0 ? Colors.white : NavHtmlColors.secondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _secilenRotaModu = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _secilenRotaModu == 1
                              ? NavHtmlColors.surfaceContainerHighest
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: _secilenRotaModu == 1
                                ? Colors.white30
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.traffic_rounded,
                              size: 15,
                              color: _secilenRotaModu == 1
                                  ? NavHtmlColors.warning
                                  : NavHtmlColors.secondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.turkceMi ? 'Gönyeli Şehir İçi' : 'City Center Route',
                              style: TextStyle(
                                color: _secilenRotaModu == 1 ? Colors.white : NavHtmlColors.secondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoktaSecici({
    required String etiket,
    required RotaNoktasi secilenNokta,
    required ValueChanged<RotaNoktasi?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiket.toUpperCase(),
          style: const TextStyle(
            color: NavHtmlColors.primaryFixedDim,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton<RotaNoktasi>(
            value: secilenNokta,
            isDense: true,
            isExpanded: true,
            dropdownColor: NavHtmlColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            icon: const Icon(Icons.arrow_drop_down_rounded, color: NavHtmlColors.secondary),
            items: kktcNoktalari.map((nokta) {
              return DropdownMenuItem<RotaNoktasi>(
                value: nokta,
                child: Row(
                  children: [
                    Icon(nokta.ikon, size: 16, color: NavHtmlColors.secondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.turkceMi ? nokta.ad : nokta.adEn,
                        style: const TextStyle(
                          color: NavHtmlColors.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  // --- 3. İnteraktif Rota ve Radar Haritası Canvası ---
  Widget _buildHaritaGorseli(HesaplanmisRota rota) {
    return Container(
      decoration: BoxDecoration(
        color: NavHtmlColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.40),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Özel Vektör Harita ve Rota Çizgisi
            SizedBox(
              height: 240,
              width: double.infinity,
              child: CustomPaint(
                painter: _KktcRotaMapPainter(
                  rotaNoktalari: rota.haritaYolNoktalari,
                  radarlar: rota.radarlar,
                  simulasyonIlerleme: _simulasyonIlerleme,
                  simulasyonAktif: _simulasyonAktif,
                  pulseValue: _pulseController.value,
                  baslangicAdi: rota.baslangic.kisaAd,
                  varisAdi: rota.varis.kisaAd,
                ),
              ),
            ),

            // Üst Sol: Canlı Hız Limiti & Sürüş HUD
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: NavHtmlColors.surfaceContainerHighest.withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _simulasyonAktif ? NavHtmlColors.tertiary : NavHtmlColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _simulasyonAktif
                          ? (widget.turkceMi ? 'Canlı Sürüş: $_canliSurusHizi km/s' : 'Driving: $_canliSurusHizi km/h')
                          : (widget.turkceMi ? 'Sabit Harita Modu' : 'Static Map Mode'),
                      style: const TextStyle(
                        color: NavHtmlColors.onSurface,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Üst Sağ: Canlı Simülasyon Butonu
            Positioned(
              top: 10,
              right: 10,
              child: ElevatedButton.icon(
                onPressed: _simulasyonAktif ? _durdurSimulasyon : _baslatSimulasyon,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _simulasyonAktif
                      ? NavHtmlColors.surfaceContainerHigh
                      : NavHtmlColors.primaryContainer,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                icon: Icon(
                  _simulasyonAktif ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  size: 18,
                ),
                label: Text(
                  _simulasyonAktif
                      ? (widget.turkceMi ? 'Durdur' : 'Stop')
                      : (widget.turkceMi ? 'Sürüşü Başlat' : 'Simulate Drive'),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Alt Kısım: Yaklaşan Radar Uyarı Şeridi
            if (_simulasyonAktif && _yaklasanRadar != null)
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: NavHtmlColors.primaryContainer.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: NavHtmlColors.primaryContainer.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Trafik Hız Tabelası Rozeti
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.red, width: 3),
                        ),
                        child: Center(
                          child: Text(
                            '${_yaklasanRadar!.hizLimiti}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.turkceMi ? '⚠️ RADAR UYARISI YAKLAŞIYOR' : '⚠️ SPEED CAMERA AHEAD',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              '${_yaklasanRadar!.ad} • ${_yaklasanRadarMesafeMetre.toInt()}m kaldı',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Limit: ${_yaklasanRadar!.hizLimiti}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- 4. Metrik Özet Kartları (Mesafe, Süre, Radar Sayısı, Kolaylık) ---
  Widget _buildMetrikOzetKartlari(HesaplanmisRota rota) {
    return Row(
      children: [
        // Mesafe
        Expanded(
          child: _buildKucukMetrikKarti(
            ikon: Icons.straighten_rounded,
            baslik: widget.turkceMi ? 'Mesafe' : 'Distance',
            deger: '${rota.mesafeKm} km',
            renk: NavHtmlColors.secondary,
          ),
        ),
        const SizedBox(width: 8),
        // Tahmini Süre
        Expanded(
          child: _buildKucukMetrikKarti(
            ikon: Icons.schedule_rounded,
            baslik: widget.turkceMi ? 'Süre' : 'Est. Time',
            deger: '${rota.tahminiDakika} dk',
            renk: NavHtmlColors.tertiary,
          ),
        ),
        const SizedBox(width: 8),
        // Radar Sayısı
        Expanded(
          child: _buildKucukMetrikKarti(
            ikon: Icons.camera_alt_rounded,
            baslik: widget.turkceMi ? 'Sabit Radar' : 'Radars',
            deger: '${rota.radarlar.length} Adet',
            renk: NavHtmlColors.primaryContainer,
            vurguluMu: true,
          ),
        ),
      ],
    );
  }

  Widget _buildKucukMetrikKarti({
    required IconData ikon,
    required String baslik,
    required String deger,
    required Color renk,
    bool vurguluMu = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: NavHtmlColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: vurguluMu ? renk.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.06),
          width: vurguluMu ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ikon, size: 15, color: renk),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  baslik,
                  style: TextStyle(
                    color: NavHtmlColors.secondary.withValues(alpha: 0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            deger,
            style: TextStyle(
              color: vurguluMu ? Colors.white : NavHtmlColors.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // --- 5. "Nereden Kolay Gidebilirim?" Tavsiye Kartı ---
  Widget _buildKolaylikRehberiKarti(HesaplanmisRota rota) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            NavHtmlColors.tertiaryContainer.withValues(alpha: 0.25),
            NavHtmlColors.surfaceContainerHigh,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: NavHtmlColors.tertiary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: NavHtmlColors.tertiary.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: NavHtmlColors.tertiary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.turkceMi ? '💡 Nereden Kolay Gidebilirim? (Tavsiye)' : '💡 Easiest Route Advice',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: NavHtmlColors.tertiaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.turkceMi ? 'Hızlı & Işıksız' : 'Fast & Smooth',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.turkceMi ? rota.kolaylikOzeti : rota.kolaylikOzetiEn,
            style: const TextStyle(
              color: NavHtmlColors.onSurface,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: NavHtmlColors.surfaceContainerLowest.withValues(alpha: 0.70),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: NavHtmlColors.tertiary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.turkceMi
                        ? 'Tavsiye Edilen Güzergah: ${rota.baslangic.kisaAd} ➔ ${rota.secenekAdi} ➔ ${rota.varis.kisaAd}'
                        : 'Recommended: ${rota.baslangic.kisaAd} ➔ ${rota.secenekAdiEn} ➔ ${rota.varis.kisaAd}',
                    style: const TextStyle(
                      color: NavHtmlColors.secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 6. Güzergahtaki Sabit Radarlar Listesi ---
  Widget _buildGuzergahRadarlari(HesaplanmisRota rota) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.shield_outlined, color: NavHtmlColors.primaryContainer, size: 18),
                const SizedBox(width: 8),
                Text(
                  widget.turkceMi ? 'Güzergahtaki Sabit Radarlar' : 'Speed Cameras on Route',
                  style: const TextStyle(
                    color: NavHtmlColors.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            Text(
              '${rota.radarlar.length} ${widget.turkceMi ? 'Kamera' : 'Cameras'}',
              style: TextStyle(
                color: NavHtmlColors.secondary.withValues(alpha: 0.8),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (rota.radarlar.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NavHtmlColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                widget.turkceMi ? 'Bu güzergahta sabit radar bulunmuyor.' : 'No speed cameras on this path.',
                style: const TextStyle(color: NavHtmlColors.secondary, fontSize: 12),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rota.radarlar.length,
            separatorBuilder: (c, i) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final radar = rota.radarlar[index];
              return _buildRadarKarti(radar, index + 1);
            },
          ),
      ],
    );
  }

  Widget _buildRadarKarti(RadarKamerasi radar, int sira) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: NavHtmlColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          // Sıra & Trafik Tabelası
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFDC2626), width: 3.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.25),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${radar.hizLimiti}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Radar Bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '#$sira',
                      style: const TextStyle(
                        color: NavHtmlColors.primaryFixedDim,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.turkceMi ? radar.ad : radar.adEn,
                        style: const TextStyle(
                          color: NavHtmlColors.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  widget.turkceMi ? radar.yon : radar.yonEn,
                  style: TextStyle(
                    color: NavHtmlColors.secondary.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.turkceMi ? radar.aciklama : radar.aciklamaEn,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.60),
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Hız Limiti Etiketi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: NavHtmlColors.primaryContainer.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: NavHtmlColors.primaryContainer.withValues(alpha: 0.3)),
            ),
            child: Text(
              '${radar.hizLimiti} km/s',
              style: const TextStyle(
                color: NavHtmlColors.primaryContainer,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 7. Adım Adım Manevralar ve Yol Tarifi ---
  Widget _buildAdimAdimManevralar(HesaplanmisRota rota) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.turn_right_rounded, color: NavHtmlColors.tertiary, size: 20),
            const SizedBox(width: 8),
            Text(
              widget.turkceMi ? 'Adım Adım Yol Tarifi & Manevralar' : 'Turn-by-Turn Directions',
              style: const TextStyle(
                color: NavHtmlColors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: NavHtmlColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rota.manevralar.length,
            separatorBuilder: (c, i) => const Divider(color: Colors.white10, height: 20),
            itemBuilder: (context, index) {
              final adim = rota.manevralar[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: adim.onemliMi
                          ? NavHtmlColors.primaryContainer.withValues(alpha: 0.20)
                          : NavHtmlColors.surfaceContainerLowest,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: adim.onemliMi ? NavHtmlColors.primaryContainer : Colors.white12,
                      ),
                    ),
                    child: Icon(
                      adim.ikon,
                      size: 16,
                      color: adim.onemliMi ? NavHtmlColors.primaryContainer : NavHtmlColors.tertiary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.turkceMi ? adim.baslik : adim.baslikEn,
                                style: const TextStyle(
                                  color: NavHtmlColors.onSurface,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              adim.mesafe,
                              style: const TextStyle(
                                color: NavHtmlColors.tertiary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.turkceMi ? adim.aciklama : adim.aciklamaEn,
                          style: TextStyle(
                            color: NavHtmlColors.secondary.withValues(alpha: 0.8),
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                        if (adim.bagliRadar != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: NavHtmlColors.primaryContainer.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: NavHtmlColors.primaryContainer.withValues(alpha: 0.25)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.camera_alt_rounded, size: 12, color: NavHtmlColors.primaryContainer),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${widget.turkceMi ? 'Radar Uyarısı' : 'Camera'}: ${adim.bagliRadar!.hizLimiti} km/s Limit (${adim.bagliRadar!.ad})',
                                    style: const TextStyle(
                                      color: NavHtmlColors.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 🎨 İNTERAKTİF ROTA VE RADAR VEKTÖR ÇİZİCİSİ
// ==========================================
class _KktcRotaMapPainter extends CustomPainter {
  final List<Offset> rotaNoktalari;
  final List<RadarKamerasi> radarlar;
  final double simulasyonIlerleme;
  final bool simulasyonAktif;
  final double pulseValue;
  final String baslangicAdi;
  final String varisAdi;

  _KktcRotaMapPainter({
    required this.rotaNoktalari,
    required this.radarlar,
    required this.simulasyonIlerleme,
    required this.simulasyonAktif,
    required this.pulseValue,
    required this.baslangicAdi,
    required this.varisAdi,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Arka Plan Vektör Izgarası
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. KKTC Temsili Kıyı / Ada Silüeti
    final landPaint = Paint()
      ..color = NavHtmlColors.surfaceContainerHigh.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final islandPath = Path();
    islandPath.moveTo(size.width * 0.05, size.height * 0.55);
    islandPath.quadraticBezierTo(size.width * 0.20, size.height * 0.25, size.width * 0.45, size.height * 0.30);
    islandPath.quadraticBezierTo(size.width * 0.70, size.height * 0.20, size.width * 0.95, size.height * 0.40);
    islandPath.quadraticBezierTo(size.width * 0.75, size.height * 0.75, size.width * 0.45, size.height * 0.70);
    islandPath.quadraticBezierTo(size.width * 0.20, size.height * 0.75, size.width * 0.05, size.height * 0.55);
    islandPath.close();
    canvas.drawPath(islandPath, landPaint);

    if (rotaNoktalari.isEmpty) return;

    // Koordinatları ekran boyutuna uyarla
    final screenPoints = rotaNoktalari.map((p) {
      return Offset(p.dx * size.width, p.dy * size.height);
    }).toList();

    // 3. Rota Yolu (Glow & Ana Çizgi)
    final routePath = Path();
    routePath.moveTo(screenPoints.first.dx, screenPoints.first.dy);
    for (int i = 1; i < screenPoints.length; i++) {
      routePath.lineTo(screenPoints[i].dx, screenPoints[i].dy);
    }

    // Glow Effect
    final glowPaint = Paint()
      ..color = NavHtmlColors.tertiary.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(routePath, glowPaint);

    // Ana Rota Çizgisi
    final linePaint = Paint()
      ..color = NavHtmlColors.tertiary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(routePath, linePaint);

    // 4. Güzergahtaki Radar Kameralarını Çiz
    int radarCount = radarlar.length;
    for (int i = 0; i < radarCount; i++) {
      double t = (i + 1) / (radarCount + 1);
      int segIndex = ((t * (screenPoints.length - 1))).floor();
      double segT = (t * (screenPoints.length - 1)) - segIndex;
      if (segIndex < screenPoints.length - 1) {
        Offset p1 = screenPoints[segIndex];
        Offset p2 = screenPoints[segIndex + 1];
        Offset radarPos = Offset(
          p1.dx + (p2.dx - p1.dx) * segT,
          p1.dy + (p2.dy - p1.dy) * segT,
        );

        // Radar Radar Halkası (Pulsing)
        final pulsePaint = Paint()
          ..color = NavHtmlColors.primaryContainer.withValues(alpha: 0.3 * (1.0 - pulseValue))
          ..style = PaintingStyle.fill;
        canvas.drawCircle(radarPos, 12 + 6 * pulseValue, pulsePaint);

        // Radar Tabelası (Beyaz daire + Kırmızı çerçeve)
        final bgSign = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(radarPos, 9, bgSign);

        final borderSign = Paint()
          ..color = const Color(0xFFDC2626)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        canvas.drawCircle(radarPos, 9, borderSign);

        // Limit Metni
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${radarlar[i].hizLimiti}',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 7.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          Offset(radarPos.dx - textPainter.width / 2, radarPos.dy - textPainter.height / 2),
        );
      }
    }

    // 5. Başlangıç Noktası (Yeşil Pin)
    final startPos = screenPoints.first;
    final startHalo = Paint()
      ..color = NavHtmlColors.tertiary.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(startPos, 14, startHalo);

    final startPin = Paint()
      ..color = NavHtmlColors.tertiary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(startPos, 7, startPin);

    final startInner = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(startPos, 3, startInner);

    // Başlangıç Etiketi
    _drawLabel(canvas, baslangicAdi, startPos + const Offset(0, -16), NavHtmlColors.tertiary);

    // 6. Varış Noktası (Kırmızı Pin)
    final endPos = screenPoints.last;
    final endHalo = Paint()
      ..color = NavHtmlColors.primaryContainer.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(endPos, 14, endHalo);

    final endPin = Paint()
      ..color = NavHtmlColors.primaryContainer
      ..style = PaintingStyle.fill;
    canvas.drawCircle(endPos, 8, endPin);

    final endInner = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(endPos, 3.5, endInner);

    // Varış Etiketi
    _drawLabel(canvas, varisAdi, endPos + const Offset(0, 16), NavHtmlColors.primaryContainer);

    // 7. Simülasyon Sırasındaki Araç (Car Icon)
    if (simulasyonAktif && simulasyonIlerleme > 0.0) {
      double t = simulasyonIlerleme.clamp(0.0, 1.0);
      int segIndex = (t * (screenPoints.length - 1)).floor();
      double segT = (t * (screenPoints.length - 1)) - segIndex;

      Offset carPos = screenPoints.last;
      if (segIndex < screenPoints.length - 1) {
        Offset p1 = screenPoints[segIndex];
        Offset p2 = screenPoints[segIndex + 1];
        carPos = Offset(p1.dx + (p2.dx - p1.dx) * segT, p1.dy + (p2.dy - p1.dy) * segT);
      }

      // Araç Vurgu Işığı
      final carHalo = Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(carPos, 14, carHalo);

      final carBody = Paint()
        ..color = NavHtmlColors.primaryContainer
        ..style = PaintingStyle.fill;
      canvas.drawCircle(carPos, 9, carBody);

      final carDot = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(carPos, 4, carDot);
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset pos, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          backgroundColor: NavHtmlColors.surfaceContainerLowest.withValues(alpha: 0.75),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _KktcRotaMapPainter oldDelegate) {
    return oldDelegate.simulasyonIlerleme != simulasyonIlerleme ||
        oldDelegate.simulasyonAktif != simulasyonAktif ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.rotaNoktalari != rotaNoktalari;
  }
}
