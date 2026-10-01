import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'radar_haritasi.dart';
import 'kktc_gov_sync_service.dart';

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
// 📍 GERÇEK GPS VE ROTA NOKTASI MODELLERİ
// ==========================================
class OsrmRoutePoint {
  final double lat;
  final double lon;
  const OsrmRoutePoint(this.lat, this.lon);
}

class RotaNoktasi {
  final String id;
  final String ad;
  final String adEn;
  final String kisaAd;
  final String bolge;
  final double lat; // Gerçek GPS Enlem
  final double lon; // Gerçek GPS Boylam
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

// KKTC Önemli Noktalar Veritabanı (Gerçek GPS Koordinatlarıyla)
final List<RotaNoktasi> kktcNoktalari = [
  // --- ÖNCELİKLİ & POPÜLER LOKASYONLAR ---
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

  // --- 🌴 LAPTA & ALSANCAK BÖLGESİ (ÖZEL LOKASYONLAR) ---
  const RotaNoktasi(
    id: "lapta",
    ad: "Lapta Sahil & Oteller Bölgesi",
    adEn: "Lapta Coastal & Hotels Strip",
    kisaAd: "Lapta Sahili",
    bolge: "Girne",
    lat: 35.3450,
    lon: 33.1680,
    ikon: Icons.beach_access_rounded,
  ),
  const RotaNoktasi(
    id: "lapta_sahil_yolu",
    ad: "Lapta Sahil Yürüyüş Yolu (Ahşap Kordon)",
    adEn: "Lapta Coastal Walkway & Boardwalk",
    kisaAd: "Lapta Yürüyüş Yolu",
    bolge: "Girne",
    lat: 35.3482,
    lon: 33.1765,
    ikon: Icons.directions_walk_rounded,
  ),
  const RotaNoktasi(
    id: "lapta_merit",
    ad: "Lapta Merit Crystal Cove & Royal Oteller",
    adEn: "Lapta Merit Hotels & Resort",
    kisaAd: "Lapta Merit Oteller",
    bolge: "Girne",
    lat: 35.3538,
    lon: 33.2045,
    ikon: Icons.hotel_rounded,
  ),
  const RotaNoktasi(
    id: "lapta_sardunya",
    ad: "Lapta Sardunya Bay Sunset Beach",
    adEn: "Lapta Sardunya Bay & Beach",
    kisaAd: "Sardunya Bay Lapta",
    bolge: "Girne",
    lat: 35.3512,
    lon: 33.1534,
    ikon: Icons.wb_twilight_rounded,
  ),
  const RotaNoktasi(
    id: "lapta_koy",
    ad: "Lapta Tarihi Köy Meydanı & Gençlik Kampı",
    adEn: "Lapta Old Village Square & Youth Camp",
    kisaAd: "Lapta Meydanı",
    bolge: "Girne",
    lat: 35.3375,
    lon: 33.1610,
    ikon: Icons.holiday_village_rounded,
  ),
  const RotaNoktasi(
    id: "alsancak_escape",
    ad: "Alsancak Escape Beach (Yavuz Çıkarma Plajı)",
    adEn: "Alsancak Escape Beach Club",
    kisaAd: "Escape Beach Alsancak",
    bolge: "Girne",
    lat: 35.3540,
    lon: 33.2415,
    ikon: Icons.beach_access_rounded,
  ),
  const RotaNoktasi(
    id: "alsancak",
    ad: "Alsancak Merkez & Karaoğlanoğlu Caddesi",
    adEn: "Alsancak Center & Karaoglanoglu",
    kisaAd: "Alsancak Merkez",
    bolge: "Girne",
    lat: 35.3490,
    lon: 33.2320,
    ikon: Icons.wb_sunny_rounded,
  ),
  const RotaNoktasi(
    id: "alsancak_milli_park",
    ad: "Alsancak Doğa Milli Parkı",
    adEn: "Alsancak Nature National Park",
    kisaAd: "Alsancak Milli Parkı",
    bolge: "Girne",
    lat: 35.3395,
    lon: 33.2210,
    ikon: Icons.forest_rounded,
  ),
  const RotaNoktasi(
    id: "alsancak_camelot",
    ad: "Alsancak Camelot Beach Club",
    adEn: "Alsancak Camelot Beach Club",
    kisaAd: "Camelot Beach",
    bolge: "Girne",
    lat: 35.3520,
    lon: 33.2180,
    ikon: Icons.waves_rounded,
  ),

  // --- 🏖️ İSKELE & KARPAZ BÖLGESİ (ZENGİN LOKASYONLAR) ---
  const RotaNoktasi(
    id: "iskele_longbeach",
    ad: "İskele Long Beach Sahili & Kordon Bulvarı",
    adEn: "Iskele Long Beach Coast & Boulevard",
    kisaAd: "İskele Long Beach",
    bolge: "İskele",
    lat: 35.2890,
    lon: 33.8950,
    ikon: Icons.pool_rounded,
  ),
  const RotaNoktasi(
    id: "iskele_pera",
    ad: "İskele Pera Mackenzie Beach Club",
    adEn: "Iskele Pera Mackenzie Club",
    kisaAd: "Pera Mackenzie",
    bolge: "İskele",
    lat: 35.2915,
    lon: 33.8975,
    ikon: Icons.local_bar_rounded,
  ),
  const RotaNoktasi(
    id: "iskele_grandsapphire",
    ad: "İskele Grand Sapphire Resort & Rezidanslar",
    adEn: "Iskele Grand Sapphire Resort",
    kisaAd: "Grand Sapphire İskele",
    bolge: "İskele",
    lat: 35.2965,
    lon: 33.9025,
    ikon: Icons.apartment_rounded,
  ),
  const RotaNoktasi(
    id: "iskele_merkez",
    ad: "İskele İlçe Merkezi & Ecevit Meydanı",
    adEn: "Iskele Town Center & Ecevit Square",
    kisaAd: "İskele Merkez",
    bolge: "İskele",
    lat: 35.2835,
    lon: 33.8825,
    ikon: Icons.location_city_rounded,
  ),
  const RotaNoktasi(
    id: "bogaz_iskele",
    ad: "İskele Boğaz Balıkçı Restoranları & Barınağı",
    adEn: "Iskele Bogaz Fishing Harbor & Dining",
    kisaAd: "İskele Boğaz",
    bolge: "İskele",
    lat: 35.3210,
    lon: 33.9310,
    ikon: Icons.directions_boat_rounded,
  ),
  const RotaNoktasi(
    id: "bafra_turizm",
    ad: "İskele Bafra Turizm Bölgesi (Kaya Artemis / Limak)",
    adEn: "Bafra Luxury Resorts Strip (Artemis/Limak)",
    kisaAd: "Bafra Otelleri",
    bolge: "İskele",
    lat: 35.4055,
    lon: 34.0950,
    ikon: Icons.star_rounded,
  ),
  const RotaNoktasi(
    id: "karpaz_altinkumsal",
    ad: "Karpaz Altın Kumsal (Golden Beach)",
    adEn: "Karpaz Golden Beach (Natural Reserve)",
    kisaAd: "Altın Kumsal Karpaz",
    bolge: "İskele",
    lat: 35.6385,
    lon: 34.5450,
    ikon: Icons.beach_access_rounded,
  ),
  const RotaNoktasi(
    id: "karpaz_zaferburnu",
    ad: "Karpaz Zafer Burnu & Apostolos Andreas Manastırı",
    adEn: "Cape Apostolos Andreas & Zafer Burnu",
    kisaAd: "Zafer Burnu (Karpaz)",
    bolge: "İskele",
    lat: 35.6625,
    lon: 34.5770,
    ikon: Icons.church_rounded,
  ),
  const RotaNoktasi(
    id: "dipkarpaz",
    ad: "Dipkarpaz Milli Parkı & Koruma Alanı",
    adEn: "Dipkarpaz National Park & Nature Reserve",
    kisaAd: "Dipkarpaz Parkı",
    bolge: "İskele",
    lat: 35.5980,
    lon: 34.3820,
    ikon: Icons.park_rounded,
  ),
  const RotaNoktasi(
    id: "mehmetcik",
    ad: "İskele Mehmetçik & Kumyalı Balıkçı Sahili",
    adEn: "Iskele Mehmetcik & Kumyali Coastal Strip",
    kisaAd: "Mehmetçik / Kumyalı",
    bolge: "İskele",
    lat: 35.4210,
    lon: 34.0520,
    ikon: Icons.sailing_rounded,
  ),
  const RotaNoktasi(
    id: "tatlisu_zambak",
    ad: "Tatlısu Sahili & Zambak Tatil Koyu",
    adEn: "Tatlisu Coast & Zambak Bay",
    kisaAd: "Tatlısu Sahili",
    bolge: "Gazimağusa",
    lat: 35.3780,
    lon: 33.7650,
    ikon: Icons.waves_rounded,
  ),

  // --- GİRNE MERKEZ & DİĞER NOKTALAR ---
  const RotaNoktasi(
    id: "girne_liman",
    ad: "Girne Tarihi Liman & Antik Kale",
    adEn: "Kyrenia Harbor & Ancient Castle",
    kisaAd: "Girne Limanı",
    bolge: "Girne",
    lat: 35.3420,
    lon: 33.3210,
    ikon: Icons.sailing_rounded,
  ),
  const RotaNoktasi(
    id: "girne_bellapais",
    ad: "Girne Bellapais Manastırı & Köyü",
    adEn: "Bellapais Abbey & Historic Village",
    kisaAd: "Bellapais Manastırı",
    bolge: "Girne",
    lat: 35.3075,
    lon: 33.3555,
    ikon: Icons.castle_rounded,
  ),
  const RotaNoktasi(
    id: "catalkoy_esentepe",
    ad: "Çatalköy & Esentepe Sahil Yolu (Korineum Golf)",
    adEn: "Catalkoy & Esentepe Coastal Road",
    kisaAd: "Çatalköy / Esentepe",
    bolge: "Girne",
    lat: 35.3360,
    lon: 33.4150,
    ikon: Icons.landscape_rounded,
  ),

  // --- LEFKOŞA BÖLGESİ ---
  const RotaNoktasi(
    id: "lefkosa_dereboyu",
    ad: "Lefkoşa Dereboyu Caddesi (Mehmet Akif Cad.)",
    adEn: "Lefkosa Dereboyu Avenue",
    kisaAd: "Lefkoşa Dereboyu",
    bolge: "Lefkoşa",
    lat: 35.1920,
    lon: 33.3510,
    ikon: Icons.location_city_rounded,
  ),
  const RotaNoktasi(
    id: "gonyeli_cemberi",
    ad: "Gönyeli Çemberi & Lefkoşa Girişi",
    adEn: "Gonyeli Roundabout & North Entry",
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
    id: "degirmenlik",
    ad: "Değirmenlik & Dağyolu Geçidi",
    adEn: "Degirmenlik & Mountain Pass",
    kisaAd: "Değirmenlik",
    bolge: "Lefkoşa",
    lat: 35.2410,
    lon: 33.4980,
    ikon: Icons.terrain_rounded,
  ),
  const RotaNoktasi(
    id: "metehan_sinir",
    ad: "Metehan (Kermiya) Sınır Kapısı",
    adEn: "Metehan (Kermiya) Border Crossing",
    kisaAd: "Metehan Kapısı",
    bolge: "Lefkoşa",
    lat: 35.1795,
    lon: 33.3210,
    ikon: Icons.security_rounded,
  ),

  // --- GAZİMAĞUSA BÖLGESİ ---
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
    id: "yenibogazici",
    ad: "Yeniboğaziçi & Salamis Antik Kenti Harabeleri",
    adEn: "Yenibogazici & Salamis Ancient Ruins",
    kisaAd: "Yeniboğaziçi / Salamis",
    bolge: "Gazimağusa",
    lat: 35.1850,
    lon: 33.8990,
    ikon: Icons.museum_rounded,
  ),
  const RotaNoktasi(
    id: "gecitkale",
    ad: "Geçitkale & Tatlısu Yol Ayrımı",
    adEn: "Gecitkale & Tatlisu Junction",
    kisaAd: "Geçitkale",
    bolge: "Gazimağusa",
    lat: 35.2750,
    lon: 33.7520,
    ikon: Icons.signpost_rounded,
  ),

  // --- GÜZELYURT & LEFKE BÖLGESİ ---
  const RotaNoktasi(
    id: "guzelyurt_merkez",
    ad: "Güzelyurt Terminal & Kent Meydanı",
    adEn: "Guzelyurt Terminal & Center",
    kisaAd: "Güzelyurt Merkez",
    bolge: "Güzelyurt",
    lat: 35.1980,
    lon: 32.9930,
    ikon: Icons.directions_bus_rounded,
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
  const RotaNoktasi(
    id: "gemikonagi",
    ad: "Gemikonağı Limanı & LAÜ Sahili",
    adEn: "Gemikonagi Port & EUL Beach",
    kisaAd: "Gemikonağı",
    bolge: "Lefke",
    lat: 35.1480,
    lon: 32.8460,
    ikon: Icons.anchor_rounded,
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
  final List<OsrmRoutePoint> gpsNoktalari; // Gerçek Enlem/Boylam yol noktaları

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
    required this.gpsNoktalari,
  });
}

// ==========================================
// 🌐 CANLI OSRM & OPENSTREETMAP ROTA SERVİSİ
// ==========================================
class CanliOsrmServisi {
  static final Map<String, List<OsrmRoutePoint>> _onbellek = {};

  static Future<List<OsrmRoutePoint>?> rotaCek({
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
  }) async {
    final cacheKey = '$startLat,$startLon-$endLat,$endLon';
    if (_onbellek.containsKey(cacheKey)) {
      return _onbellek[cacheKey];
    }

    HttpClient? client;
    try {
      client = HttpClient()..connectionTimeout = const Duration(seconds: 4);
      client.userAgent = 'KktcCezaApp/1.0';
      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/$startLon,$startLat;$endLon,$endLat?overview=full&geometries=geojson',
      );
      final req = await client.getUrl(uri);
      final resp = await req.close().timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final body = await resp.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        final routes = json['routes'] as List<dynamic>?;
        if (routes != null && routes.isNotEmpty) {
          final geom = routes[0]['geometry'] as Map<String, dynamic>?;
          final coords = geom?['coordinates'] as List<dynamic>?;
          if (coords != null && coords.isNotEmpty) {
            final points = coords.map((c) {
              final lon = (c[0] as num).toDouble();
              final lat = (c[1] as num).toDouble();
              return OsrmRoutePoint(lat, lon);
            }).toList();
            _onbellek[cacheKey] = points;
            return points;
          }
        }
      }
    } catch (_) {
      // Çevrimdışı veya gecikme durumunda yüksek çözünürlüklü yedek koordinatlar kullanılır
    } finally {
      client?.close();
    }
    return null;
  }
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
  List<OsrmRoutePoint>? _canliGpsRotasi;
  bool _canliRotaYukleniyor = false;

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

    _canliRotayiTetikle();
  }

  @override
  void dispose() {
    _simulasyonTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _canliRotayiTetikle() async {
    setState(() => _canliRotaYukleniyor = true);
    final pts = await CanliOsrmServisi.rotaCek(
      startLat: _baslangicNoktasi.lat,
      startLon: _baslangicNoktasi.lon,
      endLat: _varisNoktasi.lat,
      endLon: _varisNoktasi.lon,
    );
    if (mounted) {
      setState(() {
        _canliGpsRotasi = pts;
        _canliRotaYukleniyor = false;
      });
    }
  }

  void _noktalariDegistir() {
    setState(() {
      final gecici = _baslangicNoktasi;
      _baslangicNoktasi = _varisNoktasi;
      _varisNoktasi = gecici;
      _durdurSimulasyon();
    });
    _canliRotayiTetikle();
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
    _canliRotayiTetikle();
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
      final defaultPoints = [
        const OsrmRoutePoint(35.2470, 33.0280), // Kalkanlı ODTÜ
        const OsrmRoutePoint(35.2340, 33.0210), // Kalkanlı Köyü
        const OsrmRoutePoint(35.2180, 33.0230), // RAD-15 Kalkanlı Radarı
        const OsrmRoutePoint(35.2040, 33.0110), // Güzelyurt Bağlantısı
        const OsrmRoutePoint(35.2010, 33.0450), // Mevlevi
        const OsrmRoutePoint(35.2030, 33.1020), // Aydınköy
        const OsrmRoutePoint(35.2065, 33.1580), // RAD-14 Yılmazköy Radarı
        const OsrmRoutePoint(35.2100, 33.2200), // Alayköy
        const OsrmRoutePoint(35.2150, 33.2850), // Kuzey Çevre Yolu Sapağı
        const OsrmRoutePoint(35.2280, 33.3250), // Sanayi Viyadüğü
        const OsrmRoutePoint(35.2220, 33.3650), // Hamitköy Kuzey
        const OsrmRoutePoint(35.2155, 33.3880), // RAD-03 Hamitköy Radarı
        const OsrmRoutePoint(35.2168, 33.4350), // RAD-04 Haspolat Radarı
        const OsrmRoutePoint(35.2185, 33.4820), // RAD-19 Erülkü Demirhan
      ];

      final pts = _canliGpsRotasi ?? defaultPoints;

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
          gpsNoktalari: pts,
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
          gpsNoktalari: pts,
        );
      }
    }

    // 🟢 KALKANLI <-> GÜZELYURT MERKEZ ÖZEL ROTASI
    bool kalkanliGuzelyurtMu = (_baslangicNoktasi.id == "kalkanli" && _varisNoktasi.id == "guzelyurt_merkez") ||
        (_baslangicNoktasi.id == "guzelyurt_merkez" && _varisNoktasi.id == "kalkanli");

    if (kalkanliGuzelyurtMu) {
      final defaultPoints = [
        const OsrmRoutePoint(35.2470, 33.0280), // Kalkanlı ODTÜ
        const OsrmRoutePoint(35.2340, 33.0210), // Kalkanlı Köy Yolu
        const OsrmRoutePoint(35.2180, 33.0230), // RAD-15 Kalkanlı Radarı
        const OsrmRoutePoint(35.2050, 33.0080), // Güzelyurt Girişi
        const OsrmRoutePoint(35.1980, 32.9930), // Güzelyurt Terminal & Merkez
      ];
      final pts = _canliGpsRotasi ?? defaultPoints;

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
        gpsNoktalari: pts,
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

    // Otomatik ara nokta interpolasyonu
    List<OsrmRoutePoint> pts = _canliGpsRotasi ?? [
      OsrmRoutePoint(_baslangicNoktasi.lat, _baslangicNoktasi.lon),
      OsrmRoutePoint(
        _baslangicNoktasi.lat + (_varisNoktasi.lat - _baslangicNoktasi.lat) * 0.33,
        _baslangicNoktasi.lon + (_varisNoktasi.lon - _baslangicNoktasi.lon) * 0.33,
      ),
      OsrmRoutePoint(
        _baslangicNoktasi.lat + (_varisNoktasi.lat - _baslangicNoktasi.lat) * 0.66,
        _baslangicNoktasi.lon + (_varisNoktasi.lon - _baslangicNoktasi.lon) * 0.66,
      ),
      OsrmRoutePoint(_varisNoktasi.lat, _varisNoktasi.lon),
    ];

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
      gpsNoktalari: pts,
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
            // 🗺️ GERÇEK OPENSTREETMAP HARİTASI & CANLI ROTA
            // ==========================================
            _buildGercekHaritaGorunumu(rota),

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
            // 📢 KARAYOLLARI DAİRESİ RESMİ BİLDİRİMLERİ
            // ==========================================
            _buildKarayollariDairesiBildirimleri(),

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
                        ? 'Canlı OpenStreetMap verisi, hız radarları ve kolay rota rehberi'
                        : 'Live OpenStreetMap data, speed cameras and smart route guide',
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
                etiket: "🏫 Kalkanlı ➔ Güzelyurt",
                seciliMi: _baslangicNoktasi.id == "kalkanli" && _varisNoktasi.id == "guzelyurt_merkez",
                onTap: () => _hazirRotaSec("kalkanli", "guzelyurt_merkez"),
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
                etiket: "🌊 Lapta ➔ Girne Limanı",
                seciliMi: _baslangicNoktasi.id == "lapta" && _varisNoktasi.id == "girne_liman",
                onTap: () => _hazirRotaSec("lapta", "girne_liman"),
                rozet: "Girne Sahil",
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                etiket: "🏖️ Lapta ➔ Alsancak",
                seciliMi: _baslangicNoktasi.id == "lapta" && _varisNoktasi.id == "alsancak",
                onTap: () => _hazirRotaSec("lapta", "alsancak"),
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                etiket: "🏖️ Lapta ➔ Alsancak Escape",
                seciliMi: _baslangicNoktasi.id == "lapta" && _varisNoktasi.id == "alsancak_escape",
                onTap: () => _hazirRotaSec("lapta", "alsancak_escape"),
                rozet: "Lapta Sahil",
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                etiket: "🍹 İskele Long Beach ➔ Boğaz Balıkçı",
                seciliMi: _baslangicNoktasi.id == "iskele_longbeach" && _varisNoktasi.id == "bogaz_iskele",
                onTap: () => _hazirRotaSec("iskele_longbeach", "bogaz_iskele"),
                rozet: "İskele Kordon",
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                etiket: "🏝️ İskele ➔ Karpaz Altın Kumsal",
                seciliMi: _baslangicNoktasi.id == "iskele_longbeach" && _varisNoktasi.id == "karpaz_altinkumsal",
                onTap: () => _hazirRotaSec("iskele_longbeach", "karpaz_altinkumsal"),
                rozet: "Doğa Turu",
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
                          _canliRotayiTetikle();
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
                          _canliRotayiTetikle();
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
    return InkWell(
      onTap: () => _noktaSecimSheetGoster(
        etiket: etiket,
        secilen: secilenNokta,
        onSecildi: onChanged,
      ),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: NavHtmlColors.primaryContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.touch_app_rounded, size: 10, color: NavHtmlColors.secondary),
                      const SizedBox(width: 2),
                      Text(
                        widget.turkceMi ? 'Listeyi Aç' : 'Browse',
                        style: const TextStyle(
                          color: NavHtmlColors.secondary,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(secilenNokta.ikon, size: 16, color: NavHtmlColors.secondary),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: NavHtmlColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    secilenNokta.bolge,
                    style: const TextStyle(
                      color: NavHtmlColors.tertiary,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.turkceMi ? secilenNokta.ad : secilenNokta.adEn,
                    style: const TextStyle(
                      color: NavHtmlColors.onSurface,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: NavHtmlColors.secondary,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _noktaSecimSheetGoster({
    required String etiket,
    required RotaNoktasi secilen,
    required ValueChanged<RotaNoktasi?> onSecildi,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _NoktaSeciciBottomSheet(
          turkceMi: widget.turkceMi,
          baslik: etiket,
          secilenNokta: secilen,
          noktalar: kktcNoktalari,
          onSecildi: (nokta) {
            Navigator.of(ctx).pop();
            onSecildi(nokta);
          },
        );
      },
    );
  }

  // --- 3. Gerçek OpenStreetMap Harita Görünümü ---
  Widget _buildGercekHaritaGorunumu(HesaplanmisRota rota) {
    return KktcRealRouteMapView(
      rota: rota,
      turkceMi: widget.turkceMi,
      canliRotaYukleniyor: _canliRotaYukleniyor,
      simulasyonAktif: _simulasyonAktif,
      simulasyonIlerleme: _simulasyonIlerleme,
      canliSurusHizi: _canliSurusHizi,
      yaklasanRadar: _yaklasanRadar,
      yaklasanRadarMesafeMetre: _yaklasanRadarMesafeMetre,
      onToggleSimulasyon: _simulasyonAktif ? _durdurSimulasyon : _baslatSimulasyon,
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

  // --- 5.1 Karayolları Dairesi Canlı Yol Bildirimleri ---
  Widget _buildKarayollariDairesiBildirimleri() {
    final gov = KktcGovSyncService();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.campaign_rounded, color: NavHtmlColors.warning, size: 18),
            const SizedBox(width: 8),
            Text(
              widget.turkceMi ? 'Karayolları Dairesi Güncel Bildirimleri' : 'Highway Dept. Live Bulletins',
              style: const TextStyle(
                color: NavHtmlColors.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...gov.yolBildirimleri.map((bildirim) {
          final isWarning = bildirim.seviye == 'dikkat';
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: NavHtmlColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isWarning
                    ? NavHtmlColors.warning.withValues(alpha: 0.3)
                    : NavHtmlColors.tertiary.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isWarning ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                  size: 16,
                  color: isWarning ? NavHtmlColors.warning : NavHtmlColors.tertiary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.turkceMi ? bildirim.baslik : bildirim.baslikEn,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            bildirim.tarih,
                            style: TextStyle(
                              color: NavHtmlColors.secondary.withValues(alpha: 0.7),
                              fontSize: 9.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.turkceMi ? bildirim.detay : bildirim.detayEn,
                        style: TextStyle(
                          color: NavHtmlColors.secondary.withValues(alpha: 0.85),
                          fontSize: 10.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
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
                            const SizedBox(width: 8),
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
// 🗺️ GERÇEK OPENSTREETMAP ROTA VE TILE GÖRÜNÜMÜ
// ==========================================
class KktcRealRouteMapView extends StatefulWidget {
  final HesaplanmisRota rota;
  final bool turkceMi;
  final bool canliRotaYukleniyor;
  final bool simulasyonAktif;
  final double simulasyonIlerleme;
  final int canliSurusHizi;
  final RadarKamerasi? yaklasanRadar;
  final double yaklasanRadarMesafeMetre;
  final VoidCallback onToggleSimulasyon;

  const KktcRealRouteMapView({
    super.key,
    required this.rota,
    required this.turkceMi,
    required this.canliRotaYukleniyor,
    required this.simulasyonAktif,
    required this.simulasyonIlerleme,
    required this.canliSurusHizi,
    required this.yaklasanRadar,
    required this.yaklasanRadarMesafeMetre,
    required this.onToggleSimulasyon,
  });

  @override
  State<KktcRealRouteMapView> createState() => _KktcRealRouteMapViewState();
}

class _KktcRealRouteMapViewState extends State<KktcRealRouteMapView>
    with SingleTickerProviderStateMixin {
  late double _centerLat;
  late double _centerLon;
  double _zoom = 10.2;
  int _mapStyleIndex = 0; // 0 = OSM Standart, 1 = CartoDB Voyager, 2 = Uydu

  late final AnimationController _pulseController;

  final List<String> _tileProviders = [
    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    'https://a.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}.jpg',
  ];

  final List<String> _tileNames = [
    'OpenStreetMap',
    'Canlı Renkli',
    'Gerçek Uydu',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _rotayaOdaklanHesapla();
  }

  @override
  void didUpdateWidget(covariant KktcRealRouteMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rota.baslangic.id != widget.rota.baslangic.id ||
        oldWidget.rota.varis.id != widget.rota.varis.id) {
      _rotayaOdaklanHesapla();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _rotayaOdaklanHesapla() {
    final b = widget.rota.baslangic;
    final v = widget.rota.varis;
    _centerLat = (b.lat + v.lat) / 2.0;
    _centerLon = (b.lon + v.lon) / 2.0;

    double dLat = (b.lat - v.lat).abs();
    double dLon = (b.lon - v.lon).abs();
    double maxSpan = math.max(dLat, dLon);

    if (maxSpan > 0.6) {
      _zoom = 9.2;
    } else if (maxSpan > 0.3) {
      _zoom = 10.0;
    } else if (maxSpan > 0.1) {
      _zoom = 10.8;
    } else {
      _zoom = 12.0;
    }
  }

  static double lonToTileX(double lon, double zoom) {
    return ((lon + 180.0) / 360.0 * math.pow(2.0, zoom));
  }

  static double latToTileY(double lat, double zoom) {
    final rad = lat * math.pi / 180.0;
    final sinVal = math.sin(rad).clamp(-0.9999, 0.9999);
    return ((1.0 - math.log((1.0 + sinVal) / (1.0 - sinVal)) / (2.0 * math.pi)) / 2.0 * math.pow(2.0, zoom));
  }

  static double tileXToLon(double x, double zoom) {
    return (x / math.pow(2.0, zoom) * 360.0 - 180.0);
  }

  static double tileYToLat(double y, double zoom) {
    final n = math.pi - 2.0 * math.pi * y / math.pow(2.0, zoom);
    final sinh = 0.5 * (math.exp(n) - math.exp(-n));
    return (180.0 / math.pi * math.atan(sinh));
  }

  void _zoomIn() {
    setState(() => _zoom = (_zoom + 0.8).clamp(8.5, 15.0));
  }

  void _zoomOut() {
    setState(() => _zoom = (_zoom - 0.8).clamp(8.5, 15.0));
  }

  void _toggleStyle() {
    setState(() => _mapStyleIndex = (_mapStyleIndex + 1) % _tileProviders.length);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NavHtmlColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 280,
          width: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              final intZoom = _zoom.floor();
              final subScale = math.pow(2.0, _zoom - intZoom).toDouble();
              final tileSize = 256.0 * subScale;

              final centerTileX = lonToTileX(_centerLon, intZoom.toDouble());
              final centerTileY = latToTileY(_centerLat, intZoom.toDouble());

              final minTileX = (centerTileX - (width / 2.0) / tileSize).floor() - 1;
              final maxTileX = (centerTileX + (width / 2.0) / tileSize).ceil() + 1;
              final minTileY = (centerTileY - (height / 2.0) / tileSize).floor() - 1;
              final maxTileY = (centerTileY + (height / 2.0) / tileSize).ceil() + 1;
              final numTiles = 1 << intZoom;
              final template = _tileProviders[_mapStyleIndex];

              return GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    final dxTiles = -details.delta.dx / tileSize;
                    final dyTiles = -details.delta.dy / tileSize;
                    _centerLon = tileXToLon(centerTileX + dxTiles, intZoom.toDouble()).clamp(32.2, 34.6);
                    _centerLat = tileYToLat(centerTileY + dyTiles, intZoom.toDouble()).clamp(34.8, 35.8);
                  });
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 1. GERÇEK OPENSTREETMAP TİLELARI
                    for (int tx = minTileX; tx <= maxTileX; tx++)
                      for (int ty = minTileY; ty <= maxTileY; ty++)
                        if (ty >= 0 && ty < numTiles)
                          Positioned(
                            left: width / 2.0 + (tx - centerTileX) * tileSize,
                            top: height / 2.0 + (ty - centerTileY) * tileSize,
                            width: tileSize + 0.6,
                            height: tileSize + 0.6,
                            child: Image.network(
                              template
                                  .replaceAll('{z}', '$intZoom')
                                  .replaceAll('{x}', '${((tx % numTiles) + numTiles) % numTiles}')
                                  .replaceAll('{y}', '$ty'),
                              headers: const {'User-Agent': 'KktcTrafikCezaRadar/1.0'},
                              fit: BoxFit.fill,
                              errorBuilder: (c, e, s) => Container(
                                color: NavHtmlColors.surfaceContainerHigh.withValues(alpha: 0.3),
                              ),
                            ),
                          ),

                    // 2. TİLELAR ÜZERİNE ÇİZİLEN GERÇEK GPS POLYLİNE KATMANI
                    CustomPaint(
                      size: Size(width, height),
                      painter: _RealGpsRoutePainter(
                        points: widget.rota.gpsNoktalari,
                        centerLon: _centerLon,
                        centerLat: _centerLat,
                        zoom: _zoom,
                        tileSize: tileSize,
                        width: width,
                        height: height,
                        simulasyonIlerleme: widget.simulasyonIlerleme,
                        simulasyonAktif: widget.simulasyonAktif,
                        pulseValue: _pulseController.value,
                      ),
                    ),

                    // 3. RADAR KAMERALARI PINLERI (GERÇEK GPS KOORDİNATLARINDA)
                    ...widget.rota.radarlar.map((radar) {
                      final rTileX = lonToTileX(radar.lon, intZoom.toDouble());
                      final rTileY = latToTileY(radar.lat, intZoom.toDouble());
                      final px = width / 2.0 + (rTileX - centerTileX) * tileSize;
                      final py = height / 2.0 + (rTileY - centerTileY) * tileSize;

                      if (px < -40 || px > width + 40 || py < -40 || py > height + 40) {
                        return const SizedBox.shrink();
                      }

                      return Positioned(
                        left: px - 15,
                        top: py - 15,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFDC2626), width: 2.8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${radar.hizLimiti}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    // 4. BAŞLANGIÇ PİNİ (ODTÜ KALKANLI - YEŞİL)
                    _buildGpsPin(
                      lat: widget.rota.baslangic.lat,
                      lon: widget.rota.baslangic.lon,
                      label: widget.rota.baslangic.kisaAd,
                      color: NavHtmlColors.tertiary,
                      icon: widget.rota.baslangic.ikon,
                      width: width,
                      height: height,
                      tileSize: tileSize,
                      centerTileX: centerTileX,
                      centerTileY: centerTileY,
                      intZoom: intZoom,
                    ),

                    // 5. VARIŞ PİNİ (ERÜLKÜ DEMİRHAN - KIRMIZI)
                    _buildGpsPin(
                      lat: widget.rota.varis.lat,
                      lon: widget.rota.varis.lon,
                      label: widget.rota.varis.kisaAd,
                      color: NavHtmlColors.primaryContainer,
                      icon: widget.rota.varis.ikon,
                      width: width,
                      height: height,
                      tileSize: tileSize,
                      centerTileX: centerTileX,
                      centerTileY: centerTileY,
                      intZoom: intZoom,
                    ),

                    // 6. SOL ÜST: HARİTA BİLGİ & CANLI OSRM ROZETİ
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: NavHtmlColors.surfaceContainerLowest.withValues(alpha: 0.90),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: widget.canliRotaYukleniyor ? NavHtmlColors.warning : NavHtmlColors.tertiary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.canliRotaYukleniyor
                                  ? (widget.turkceMi ? 'OSRM Rota Alınıyor...' : 'Fetching OSRM...')
                                  : (widget.turkceMi ? 'Canlı OpenStreetMap Verisi' : 'Live OpenStreetMap'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 7. SAĞ ÜST: HARİTA KONTROLLERİ (+ / - / Stil / Odaklan)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHaritaAksiyonButonu(
                            icon: Icons.layers_rounded,
                            tooltip: _tileNames[_mapStyleIndex],
                            onTap: _toggleStyle,
                          ),
                          const SizedBox(height: 6),
                          _buildHaritaAksiyonButonu(
                            icon: Icons.filter_center_focus_rounded,
                            tooltip: widget.turkceMi ? 'Rotaya Odaklan' : 'Fit Route',
                            onTap: () => setState(_rotayaOdaklanHesapla),
                          ),
                          const SizedBox(height: 6),
                          _buildHaritaAksiyonButonu(
                            icon: Icons.add_rounded,
                            tooltip: 'Zoom +',
                            onTap: _zoomIn,
                          ),
                          const SizedBox(height: 6),
                          _buildHaritaAksiyonButonu(
                            icon: Icons.remove_rounded,
                            tooltip: 'Zoom -',
                            onTap: _zoomOut,
                          ),
                        ],
                      ),
                    ),

                    // 8. SAĞ ALT: CANLI SÜRÜŞ SİMÜLASYON BUTONU
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: ElevatedButton.icon(
                        onPressed: widget.onToggleSimulasyon,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.simulasyonAktif
                              ? NavHtmlColors.surfaceContainerHigh
                              : NavHtmlColors.primaryContainer,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 6,
                        ),
                        icon: Icon(
                          widget.simulasyonAktif ? Icons.stop_rounded : Icons.play_arrow_rounded,
                          size: 18,
                        ),
                        label: Text(
                          widget.simulasyonAktif
                              ? (widget.turkceMi ? 'Durdur' : 'Stop')
                              : (widget.turkceMi ? 'Canlı Sürüşü Başlat' : 'Simulate Drive'),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    // 9. SOL ALT: YAKLAŞAN RADAR BİLGİ HUD ŞERİDİ
                    if (widget.simulasyonAktif && widget.yaklasanRadar != null)
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: NavHtmlColors.primaryContainer.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: NavHtmlColors.primaryContainer.withValues(alpha: 0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${widget.yaklasanRadar!.hizLimiti}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${widget.yaklasanRadar!.ad} • ${widget.yaklasanRadarMesafeMetre.toInt()}m',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    'Hızınız: ${widget.canliSurusHizi} km/s',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGpsPin({
    required double lat,
    required double lon,
    required String label,
    required Color color,
    required IconData icon,
    required double width,
    required double height,
    required double tileSize,
    required double centerTileX,
    required double centerTileY,
    required int intZoom,
  }) {
    final pTileX = lonToTileX(lon, intZoom.toDouble());
    final pTileY = latToTileY(lat, intZoom.toDouble());
    final px = width / 2.0 + (pTileX - centerTileX) * tileSize;
    final py = height / 2.0 + (pTileY - centerTileY) * tileSize;

    if (px < -60 || px > width + 60 || py < -60 || py > height + 60) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: px - 45,
      top: py - 40,
      width: 90,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: NavHtmlColors.surfaceContainerLowest.withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color, width: 1.2),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Icon(icon, size: 13, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildHaritaAksiyonButonu({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: NavHtmlColors.surfaceContainerLowest.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}

// ==========================================
// 🎨 GERÇEK GPS POLYLİNE ÇİZİCİSİ (MERCATOR DÜNYASI)
// ==========================================
class _RealGpsRoutePainter extends CustomPainter {
  final List<OsrmRoutePoint> points;
  final double centerLon;
  final double centerLat;
  final double zoom;
  final double tileSize;
  final double width;
  final double height;
  final double simulasyonIlerleme;
  final bool simulasyonAktif;
  final double pulseValue;

  _RealGpsRoutePainter({
    required this.points,
    required this.centerLon,
    required this.centerLat,
    required this.zoom,
    required this.tileSize,
    required this.width,
    required this.height,
    required this.simulasyonIlerleme,
    required this.simulasyonAktif,
    required this.pulseValue,
  });

  static double lonToTileX(double lon, double zoom) {
    return ((lon + 180.0) / 360.0 * math.pow(2.0, zoom));
  }

  static double latToTileY(double lat, double zoom) {
    final rad = lat * math.pi / 180.0;
    final sinVal = math.sin(rad).clamp(-0.9999, 0.9999);
    return ((1.0 - math.log((1.0 + sinVal) / (1.0 - sinVal)) / (2.0 * math.pi)) / 2.0 * math.pow(2.0, zoom));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final intZoom = zoom.floor().toDouble();
    final centerTileX = lonToTileX(centerLon, intZoom);
    final centerTileY = latToTileY(centerLat, intZoom);

    final screenPoints = <Offset>[];
    for (var pt in points) {
      final pTileX = lonToTileX(pt.lon, intZoom);
      final pTileY = latToTileY(pt.lat, intZoom);
      final px = width / 2.0 + (pTileX - centerTileX) * tileSize;
      final py = height / 2.0 + (pTileY - centerTileY) * tileSize;
      screenPoints.add(Offset(px, py));
    }

    // 1. Gerçek Rota Çizgisi Glow & Hat
    final routePath = Path();
    routePath.moveTo(screenPoints.first.dx, screenPoints.first.dy);
    for (int i = 1; i < screenPoints.length; i++) {
      routePath.lineTo(screenPoints[i].dx, screenPoints[i].dy);
    }

    // Glow
    final glowPaint = Paint()
      ..color = NavHtmlColors.tertiary.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(routePath, glowPaint);

    // Ana Hat
    final linePaint = Paint()
      ..color = NavHtmlColors.tertiary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(routePath, linePaint);

    // 2. Simülasyon Aracı
    if (simulasyonAktif && simulasyonIlerleme > 0.0 && screenPoints.length >= 2) {
      double t = simulasyonIlerleme.clamp(0.0, 1.0);
      int segIndex = (t * (screenPoints.length - 1)).floor();
      double segT = (t * (screenPoints.length - 1)) - segIndex;

      Offset carPos = screenPoints.last;
      if (segIndex < screenPoints.length - 1) {
        Offset p1 = screenPoints[segIndex];
        Offset p2 = screenPoints[segIndex + 1];
        carPos = Offset(p1.dx + (p2.dx - p1.dx) * segT, p1.dy + (p2.dy - p1.dy) * segT);
      }

      final carHalo = Paint()
        ..color = NavHtmlColors.primaryContainer.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(carPos, 14, carHalo);

      final carBody = Paint()
        ..color = NavHtmlColors.primaryContainer
        ..style = PaintingStyle.fill;
      canvas.drawCircle(carPos, 8, carBody);

      final carDot = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(carPos, 3.5, carDot);
    }
  }

  @override
  bool shouldRepaint(covariant _RealGpsRoutePainter oldDelegate) {
    return oldDelegate.centerLon != centerLon ||
        oldDelegate.centerLat != centerLat ||
        oldDelegate.zoom != zoom ||
        oldDelegate.simulasyonIlerleme != simulasyonIlerleme ||
        oldDelegate.simulasyonAktif != simulasyonAktif ||
        oldDelegate.points != points;
  }
}

// ==========================================
// 📍 GELİŞMİŞ NOKTA SEÇİM BOTTOM SHEETİ
// ==========================================
class _NoktaSeciciBottomSheet extends StatefulWidget {
  final bool turkceMi;
  final String baslik;
  final RotaNoktasi secilenNokta;
  final List<RotaNoktasi> noktalar;
  final ValueChanged<RotaNoktasi> onSecildi;

  const _NoktaSeciciBottomSheet({
    required this.turkceMi,
    required this.baslik,
    required this.secilenNokta,
    required this.noktalar,
    required this.onSecildi,
  });

  @override
  State<_NoktaSeciciBottomSheet> createState() => _NoktaSeciciBottomSheetState();
}

class _NoktaSeciciBottomSheetState extends State<_NoktaSeciciBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _seciliBolge = 'Tümü';
  String _aramaMetni = '';

  final List<String> _bolgeler = [
    'Tümü',
    'Girne',
    'Lefkoşa',
    'Güzelyurt',
    'Gazimağusa',
    'İskele',
    'Lefke',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _noktaSayisi(String b) {
    if (b == 'Tümü') return widget.noktalar.length;
    return widget.noktalar.where((n) => n.bolge.toLowerCase().contains(b.toLowerCase())).length;
  }

  List<RotaNoktasi> get _filtrelenmisNoktalar {
    return widget.noktalar.where((n) {
      // Bölge Filtresi
      if (_seciliBolge != 'Tümü' && !n.bolge.toLowerCase().contains(_seciliBolge.toLowerCase())) {
        return false;
      }
      // Metin Arama
      if (_aramaMetni.trim().isNotEmpty) {
        final query = _aramaMetni.trim().toLowerCase();
        final matchAd = n.ad.toLowerCase().contains(query);
        final matchEn = n.adEn.toLowerCase().contains(query);
        final matchKisa = n.kisaAd.toLowerCase().contains(query);
        final matchBolge = n.bolge.toLowerCase().contains(query);
        return matchAd || matchEn || matchKisa || matchBolge;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final sonuclar = _filtrelenmisNoktalar;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: NavHtmlColors.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tutma çubuğu
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Başlık ve Kapat Butonu
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.baslik,
                        style: const TextStyle(
                          color: NavHtmlColors.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.turkceMi
                            ? "Lapta, Alsancak, Girne ve tüm KKTC noktaları (${widget.noktalar.length} nokta)"
                            : "All TRNC locations (${widget.noktalar.length} destinations)",
                        style: const TextStyle(
                          color: NavHtmlColors.secondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: NavHtmlColors.secondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Arama Girişi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              decoration: BoxDecoration(
                color: NavHtmlColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                onChanged: (val) {
                  setState(() {
                    _aramaMetni = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: widget.turkceMi
                      ? 'Nokta veya ilçe ara (örn: Lapta, Alsancak, Girne...)'
                      : 'Search location (e.g. Lapta, Alsancak...)',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 12.5),
                  prefixIcon: const Icon(Icons.search_rounded, color: NavHtmlColors.tertiary, size: 20),
                  suffixIcon: _aramaMetni.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: Colors.white54, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _aramaMetni = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
          ),

          // Bölge Filtre Butonları (Horizontal Chips)
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              scrollDirection: Axis.horizontal,
              itemCount: _bolgeler.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final b = _bolgeler[i];
                final secili = _seciliBolge == b;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _seciliBolge = b;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: secili
                          ? NavHtmlColors.primaryContainer.withValues(alpha: 0.3)
                          : NavHtmlColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: secili ? NavHtmlColors.primaryContainer : Colors.white12,
                        width: secili ? 1.4 : 1.0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        b == 'Tümü' ? 'Tümü (${widget.noktalar.length})' : '$b (${_noktaSayisi(b)})',
                        style: TextStyle(
                          color: secili ? Colors.white : NavHtmlColors.secondary,
                          fontSize: 11.5,
                          fontWeight: secili ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(color: Colors.white10, height: 16),

          // Liste Görünümü
          Expanded(
            child: sonuclar.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_off_rounded, size: 36, color: Colors.white30),
                        const SizedBox(height: 8),
                        Text(
                          widget.turkceMi ? 'Sonuç bulunamadı' : 'No locations found',
                          style: const TextStyle(color: NavHtmlColors.secondary, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    itemCount: sonuclar.length,
                    itemBuilder: (context, idx) {
                      final nokta = sonuclar[idx];
                      final isSelected = nokta.id == widget.secilenNokta.id;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? NavHtmlColors.primaryContainer.withValues(alpha: 0.15)
                              : NavHtmlColors.surfaceContainerLowest.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? NavHtmlColors.primaryContainer.withValues(alpha: 0.8)
                                : Colors.white.withValues(alpha: 0.05),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: ListTile(
                          onTap: () => widget.onSecildi(nokta),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? NavHtmlColors.primaryContainer.withValues(alpha: 0.3)
                                  : NavHtmlColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              nokta.ikon,
                              color: isSelected ? NavHtmlColors.primaryContainer : NavHtmlColors.secondary,
                              size: 19,
                            ),
                          ),
                          title: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: NavHtmlColors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Text(
                                  nokta.bolge,
                                  style: const TextStyle(
                                    color: NavHtmlColors.tertiary,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.turkceMi ? nokta.ad : nokta.adEn,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : NavHtmlColors.onSurface,
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              nokta.kisaAd,
                              style: const TextStyle(
                                color: NavHtmlColors.secondary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          trailing: isSelected
                              ? const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: NavHtmlColors.primaryContainer,
                                  child: Icon(Icons.check_rounded, color: Colors.white, size: 16),
                                )
                              : const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.white24,
                                  size: 18,
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

