import 'dart:async';
import 'package:flutter/material.dart';

// ==========================================
// 📍 RADAR & HIZ KAMERASI VERİ MODELİ
// ==========================================
class RadarKamerasi {
  final String id;
  final String ad;
  final String adEn;
  final String sehir;
  final int hizLimiti; // 50, 65, 75, 80
  final String tur;
  final String turEn;
  final String yon;
  final String yonEn;
  final String aciklama;
  final String aciklamaEn;
  final bool aktif;
  final double mapX;
  final double mapY;
  final double posX; // 0 - 700 piksel konumu
  final double posY; // 0 - 340 piksel konumu
  final String mesafe;

  const RadarKamerasi({
    required this.id,
    required this.ad,
    required this.adEn,
    required this.sehir,
    required this.hizLimiti,
    required this.tur,
    required this.turEn,
    required this.yon,
    required this.yonEn,
    required this.aciklama,
    required this.aciklamaEn,
    required this.aktif,
    required this.mapX,
    required this.mapY,
    required this.posX,
    required this.posY,
    required this.mesafe,
  });
}

// ==========================================
// 🗄️ GERÇEK KKTC SABİT RADAR LİSTESİ (18 ADET)
// ==========================================
final List<RadarKamerasi> kktcRadarListesi = [
  // LEFKOŞA BÖLGESİ
  const RadarKamerasi(
    id: "RAD-01",
    ad: "Gönyeli Çemberi Girişi",
    adEn: "Gonyeli Roundabout Entrance",
    sehir: "Lefkoşa",
    hizLimiti: 50,
    tur: "Sabit Hız & Kırmızı Işık",
    turEn: "Fixed Speed & Red Light",
    yon: "Lefkoşa Giriş Yönü (Çift Şerit)",
    yonEn: "Lefkosa Entrance (Dual Lane)",
    aciklama: "Gönyeli çemberine 250m kala, Lefkoşa ana arteri üzerinde.",
    aciklamaEn: "250m before Gonyeli roundabout on main Lefkosa artery.",
    aktif: true,
    mapX: 0.38,
    mapY: 0.52,
    posX: 252,
    posY: 195,
    mesafe: "1.4 km",
  ),
  const RadarKamerasi(
    id: "RAD-02",
    ad: "Dr. Burhan Nalbantoğlu Hastane Yolu",
    adEn: "State Hospital Road",
    sehir: "Lefkoşa",
    hizLimiti: 50,
    tur: "Sabit Hız Radarı",
    turEn: "Fixed Speed Camera",
    yon: "Ortaköy - Hastane İstikameti",
    yonEn: "Ortakoy - Hospital Direction",
    aciklama: "Devlet hastanesi kavşağı civarı, yoğun yaya bölgesi.",
    aciklamaEn: "Near State Hospital junction, high pedestrian zone.",
    aktif: true,
    mapX: 0.40,
    mapY: 0.54,
    posX: 262,
    posY: 205,
    mesafe: "2.1 km",
  ),
  const RadarKamerasi(
    id: "RAD-03",
    ad: "Hamitköy Çevre Yolu",
    adEn: "Hamitkoy Ring Road",
    sehir: "Lefkoşa",
    hizLimiti: 65,
    tur: "Sabit Hız Radarı",
    turEn: "Fixed Speed Camera",
    yon: "Lefkoşa - Gazimağusa Anayolu",
    yonEn: "Lefkosa - Famagusta Highway",
    aciklama: "Hamitköy ışıkları sonrası çevre yolu bağlantısı.",
    aciklamaEn: "Ring road link past Hamitkoy junction lights.",
    aktif: true,
    mapX: 0.44,
    mapY: 0.52,
    posX: 290,
    posY: 210,
    mesafe: "4.3 km",
  ),
  const RadarKamerasi(
    id: "RAD-04",
    ad: "Haspolat - UKÜ Kavşağı",
    adEn: "Haspolat - CIU Junction",
    sehir: "Lefkoşa",
    hizLimiti: 65,
    tur: "Sabit Hız Radarı",
    turEn: "Fixed Speed Camera",
    yon: "Çift Yönlü",
    yonEn: "Both Directions",
    aciklama: "Uluslararası Kıbrıs Üniversitesi alt geçidi yakını.",
    aciklamaEn: "Near Cyprus International University underpass.",
    aktif: true,
    mapX: 0.48,
    mapY: 0.53,
    posX: 325,
    posY: 212,
    mesafe: "6.7 km",
  ),
  const RadarKamerasi(
    id: "RAD-05",
    ad: "Metehan Sınır Kapısı Yolu",
    adEn: "Metehan Border Crossing Road",
    sehir: "Lefkoşa",
    hizLimiti: 50,
    tur: "Sabit Hız & Güvenlik",
    turEn: "Speed & Surveillance",
    yon: "Kermiya - Metehan Yolu",
    yonEn: "Kermiya - Metehan Road",
    aciklama: "Sınır kapısına gidiş güzergahında hız denetimi.",
    aciklamaEn: "Speed control route leading to the crossing.",
    aktif: true,
    mapX: 0.37,
    mapY: 0.56,
    posX: 265,
    posY: 222,
    mesafe: "3.2 km",
  ),

  // GİRNE BÖLGESİ
  const RadarKamerasi(
    id: "RAD-06",
    ad: "Boğaz Yolu (St. Hilarion Kavşağı)",
    adEn: "Bogaz Highway (St. Hilarion)",
    sehir: "Girne",
    hizLimiti: 65,
    tur: "Sabit Hız Radarı",
    turEn: "Fixed Speed Camera",
    yon: "Lefkoşa - Girne Çift Yön",
    yonEn: "Lefkosa - Kyrenia Both Ways",
    aciklama: "Boğaz dağ yolu viraj çıkışı, piknik alanı civarı.",
    aciklamaEn: "Bogaz mountain road curve exit, picnic area.",
    aktif: true,
    mapX: 0.41,
    mapY: 0.38,
    posX: 255,
    posY: 155,
    mesafe: "11.2 km",
  ),
  const RadarKamerasi(
    id: "RAD-07",
    ad: "Girne Çevre Yolu (Alsancak Girişi)",
    adEn: "Kyrenia Ring Road (Alsancak Entry)",
    sehir: "Girne",
    hizLimiti: 50,
    tur: "Sabit Hız Radarı",
    turEn: "Fixed Speed Camera",
    yon: "Alsancak - Girne İstikameti",
    yonEn: "Alsancak - Kyrenia Direction",
    aciklama: "Çevre yolu batı kavşağı bağlantısı.",
    aciklamaEn: "Ring road west intersection link.",
    aktif: true,
    mapX: 0.33,
    mapY: 0.33,
    posX: 205,
    posY: 125,
    mesafe: "16.4 km",
  ),
  const RadarKamerasi(
    id: "RAD-08",
    ad: "Karaoğlanoğlu Caddesi (GAÜ Girişi)",
    adEn: "Karaoglanoglu Ave (GAU Entry)",
    sehir: "Girne",
    hizLimiti: 50,
    tur: "Kırmızı Işık & Hız Kamerası",
    turEn: "Red Light & Speed Camera",
    yon: "Girne Merkez - Karaoğlanoğlu",
    yonEn: "Kyrenia Center - Karaoglanoglu",
    aciklama: "Girne Amerikan Üniversitesi kavşak ışıkları.",
    aciklamaEn: "Girne American University intersection signals.",
    aktif: true,
    mapX: 0.36,
    mapY: 0.34,
    posX: 235,
    posY: 127,
    mesafe: "14.8 km",
  ),
  const RadarKamerasi(
    id: "RAD-09",
    ad: "Doğanköy - Bellapais Yolu",
    adEn: "Dogankoy - Bellapais Road",
    sehir: "Girne",
    hizLimiti: 50,
    tur: "Sabit Hız Radarı",
    turEn: "Fixed Speed Camera",
    yon: "Doğanköy Çıkışı",
    yonEn: "Dogankoy Exit",
    aciklama: "Bellapais manastırı yönündeki tırmanış arteri.",
    aciklamaEn: "Climbing artery towards Bellapais Abbey.",
    aktif: true,
    mapX: 0.43,
    mapY: 0.35,
    posX: 280,
    posY: 140,
    mesafe: "15.9 km",
  ),

  // GAZİMAĞUSA BÖLGESİ
  const RadarKamerasi(
    id: "RAD-10",
    ad: "DAÜ Girişi - Salamis Yolu",
    adEn: "EMU Entry - Salamis Road",
    sehir: "Gazimağusa",
    hizLimiti: 50,
    tur: "Kırmızı Işık & Hız Kamerası",
    turEn: "Red Light & Speed Camera",
    yon: "Salamis Yolu - DAÜ Çemberi",
    yonEn: "Salamis Road - EMU Circle",
    aciklama: "Doğu Akdeniz Üniversitesi ana giriş ışıkları.",
    aciklamaEn: "Eastern Mediterranean University main entrance lights.",
    aktif: true,
    mapX: 0.70,
    mapY: 0.55,
    posX: 465,
    posY: 218,
    mesafe: "48.0 km",
  ),
  const RadarKamerasi(
    id: "RAD-11",
    ad: "Dörtyol Çemberi (Anayol)",
    adEn: "Dortyol Roundabout (Highway)",
    sehir: "Gazimağusa",
    hizLimiti: 65,
    tur: "Sabit Hız Radarı",
    turEn: "Fixed Speed Camera",
    yon: "Lefkoşa - Mağusa Çift Yön",
    yonEn: "Lefkosa - Famagusta Both Ways",
    aciklama: "Dörtyol kavşağı öncesi hız düşürme radarı.",
    aciklamaEn: "Speed reduction radar prior to Dortyol junction.",
    aktif: true,
    mapX: 0.60,
    mapY: 0.53,
    posX: 410,
    posY: 222,
    mesafe: "32.5 km",
  ),
  const RadarKamerasi(
    id: "RAD-12",
    ad: "Glapsides Çemberi Girişi",
    adEn: "Glapsides Beach Entrance",
    sehir: "Gazimağusa",
    hizLimiti: 50,
    tur: "Sabit Hız Radarı",
    turEn: "Fixed Speed Camera",
    yon: "Mağusa - İskele Sahil Yolu",
    yonEn: "Famagusta - Iskele Coast Road",
    aciklama: "Glapsides plaj kavşağı sahil ana arteri.",
    aciklamaEn: "Coast artery near Glapsides beach junction.",
    aktif: true,
    mapX: 0.71,
    mapY: 0.50,
    posX: 460,
    posY: 195,
    mesafe: "51.2 km",
  ),
  const RadarKamerasi(
    id: "RAD-13",
    ad: "Geçitkale - Tatlısu Yol Ayrımı",
    adEn: "Gecitkale - Tatlisu Junction",
    sehir: "Gazimağusa",
    hizLimiti: 75,
    tur: "Sabit Hız Radarı",
    turEn: "Fixed Speed Camera",
    yon: "Kuzey Sahil Yolu Bağlantısı",
    yonEn: "North Coast Link",
    aciklama: "Tatlısu sahil yoluna inen virajlı geçit.",
    aciklamaEn: "Pass connecting towards Tatlisu northern coast.",
    aktif: true,
    mapX: 0.57,
    mapY: 0.44,
    posX: 395,
    posY: 165,
    mesafe: "38.0 km",
  ),

  // GÜZELYURT & LEFKE BÖLGESİ
  const RadarKamerasi(
    id: "RAD-14",
    ad: "Yılmazköy Düzlüğü",
    adEn: "Yilmazkoy Straight",
    sehir: "Güzelyurt",
    hizLimiti: 75,
    tur: "Sabit Hız Radarı",
    turEn: "Fixed Speed Camera",
    yon: "Lefkoşa - Güzelyurt Çift Yön",
    yonEn: "Lefkosa - Guzelyurt Both Ways",
    aciklama: "Uzun düzlük güzergahında çift yönlü hız denetimi.",
    aciklamaEn: "Dual-direction speed enforcement on the long straight.",
    aktif: true,
    mapX: 0.28,
    mapY: 0.54,
    posX: 205,
    posY: 205,
    mesafe: "18.3 km",
  ),
  const RadarKamerasi(
    id: "RAD-15",
    ad: "Kalkanlı Yolu (ODTÜ Güzergahı)",
    adEn: "Kalkanli Road (METU Route)",
    sehir: "Güzelyurt",
    hizLimiti: 65,
    tur: "Sabit Hız Radarı",
    turEn: "Fixed Speed Camera",
    yon: "Güzelyurt - Kalkanlı İstikameti",
    yonEn: "Guzelyurt - Kalkanli Route",
    aciklama: "ODTÜ Kuzey Kıbrıs Kampüsü anayolu üzeri.",
    aciklamaEn: "Along the METU Northern Cyprus campus route.",
    aktif: true,
    mapX: 0.22,
    mapY: 0.50,
    posX: 145,
    posY: 180,
    mesafe: "28.5 km",
  ),
  const RadarKamerasi(
    id: "RAD-16",
    ad: "Lefke Cengiz Topel Anıtı Yolu",
    adEn: "Lefke Cengiz Topel Memorial Road",
    sehir: "Lefke",
    hizLimiti: 50,
    tur: "Sabit Hız Radarı",
    turEn: "Fixed Speed Camera",
    yon: "Lefke Girişi",
    yonEn: "Lefke Entrance",
    aciklama: "Lefke Avrupa Üniversitesi ve sahil bağlantı yolu.",
    aciklamaEn: "European University of Lefke coastal connector.",
    aktif: true,
    mapX: 0.14,
    mapY: 0.59,
    posX: 80,
    posY: 240,
    mesafe: "44.0 km",
  ),

  // İSKELE & KARPAZ BÖLGESİ
  const RadarKamerasi(
    id: "RAD-17",
    ad: "İskele - Boğaz Sahil Yolu",
    adEn: "Iskele - Bogaz Coastal Highway",
    sehir: "İskele",
    hizLimiti: 65,
    tur: "Sabit Hız Radarı",
    turEn: "Fixed Speed Camera",
    yon: "Sahil Şeridi Çift Yön",
    yonEn: "Coast Strip Both Ways",
    aciklama: "İskele Boğaz balıkçı barınağı civarı sahil şeridi.",
    aciklamaEn: "Coastal highway near Iskele Bogaz harbor.",
    aktif: true,
    mapX: 0.73,
    mapY: 0.43,
    posX: 470,
    posY: 160,
    mesafe: "59.0 km",
  ),
  const RadarKamerasi(
    id: "RAD-18",
    ad: "Yenierenköy - Dipkarpaz Yolu",
    adEn: "Yenierenkoy - Dipkarpaz Route",
    sehir: "İskele",
    hizLimiti: 75,
    tur: "Sabit Hız Radarı",
    turEn: "Fixed Speed Camera",
    yon: "Karpaz Yarımadası Anayolu",
    yonEn: "Karpaz Peninsula Highway",
    aciklama: "Yenierenköy çıkışı, Karpaz milli park istikameti.",
    aciklamaEn: "Yenierenkoy exit heading to Karpaz National Park.",
    aktif: true,
    mapX: 0.86,
    mapY: 0.28,
    posX: 585,
    posY: 70,
    mesafe: "88.0 km",
  ),
];

// 🎨 RADAR HTML RENK PALETİ VE TASARIM TOKENLARI
// ==========================================
class RadarHtmlColors {
  static const Color background = Color(0xFF0A122A);
  static const Color surfaceContainer = Color(0xFF171E37);
  static const Color surfaceContainerLow = Color(0xFF131A33);
  static const Color surfaceContainerLowest = Color(0xFF050D25);
  static const Color surfaceContainerHigh = Color(0xFF212942);
  static const Color surfaceContainerHighest = Color(0xFF2C344D);
  static const Color surfaceBright = Color(0xFF313852);
  static const Color primaryContainer = Color(0xFFD90429);
  static const Color primary = Color(0xFFFFB3AF);
  static const Color primaryFixed = Color(0xFFFFDAD7);
  static const Color primaryFixedDim = Color(0xFFFFB3AF);
  static const Color secondary = Color(0xFFBDC5E9);
  static const Color tertiary = Color(0xFF4EDEA3);
  static const Color tertiaryContainer = Color(0xFF007C55);
  static const Color tertiaryFixed = Color(0xFF6FFBBE);
  static const Color onSurface = Color(0xFFDBE1FF);
  static const Color onPrimaryContainer = Color(0xFFFFEAE8);
  static const Color onTertiaryContainer = Color(0xFFB4FFD7);
  static const Color errorContainer = Color(0xFF93000A);
}

typedef _RadarHtmlColors = RadarHtmlColors;

// ==========================================
// 🗺️ RADAR VE KAMERA HARİTASI SAYFASI (HTML MOCKUP UYUMLU)
// ==========================================
class RadarHaritasiSayfasi extends StatefulWidget {
  final bool turkceMi;

  const RadarHaritasiSayfasi({super.key, required this.turkceMi});

  @override
  State<RadarHaritasiSayfasi> createState() => _RadarHaritasiSayfasiState();
}

class _RadarHaritasiSayfasiState extends State<RadarHaritasiSayfasi>
    with SingleTickerProviderStateMixin {
  String _secilenSehir = "Tümü";
  String _aramaMetni = "";
  bool _haritaGorunumu = true; // true = Harita, false = Liste
  RadarKamerasi? _seciliRadar;
  bool _sesliUyariAktif = true;
  int _canliHiz = 62;
  Timer? _speedTimer;

  late final AnimationController _pulseController;
  final TransformationController _transformController = TransformationController();
  final TextEditingController _searchController = TextEditingController();

  final List<String> _sehirler = [
    "Tümü",
    "Lefkoşa",
    "Girne",
    "Gazimağusa",
    "Güzelyurt",
    "İskele",
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    // Harita başlangıçta tam ortalı olarak görünür
    _transformController.value = Matrix4.identity();

    _speedTimer = Timer.periodic(const Duration(milliseconds: 2800), (t) {
      if (mounted) {
        final speeds = [61, 62, 63, 62, 64];
        setState(() {
          _canliHiz = speeds[t.tick % speeds.length];
        });
      }
    });

    if (kktcRadarListesi.isNotEmpty) {
      _seciliRadar = kktcRadarListesi.first;
    }
  }

  @override
  void dispose() {
    _speedTimer?.cancel();
    _pulseController.dispose();
    _transformController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<RadarKamerasi> get _filtrelenmisRadarlar {
    return kktcRadarListesi.where((radar) {
      bool sehirUygun = _secilenSehir == "Tümü" || radar.sehir == _secilenSehir;
      bool aramaUygun = _aramaMetni.isEmpty ||
          radar.ad.toLowerCase().contains(_aramaMetni.toLowerCase()) ||
          radar.adEn.toLowerCase().contains(_aramaMetni.toLowerCase()) ||
          radar.sehir.toLowerCase().contains(_aramaMetni.toLowerCase()) ||
          radar.aciklama.toLowerCase().contains(_aramaMetni.toLowerCase());
      return sehirUygun && aramaUygun;
    }).toList();
  }

  int _sehirdekiRadarSayisi(String sehir) {
    if (sehir == "Tümü") return kktcRadarListesi.length;
    return kktcRadarListesi.where((r) => r.sehir == sehir).length;
  }

  void _zoomIn() {
    final matrix = _transformController.value.clone();
    matrix.scaleByDouble(1.25, 1.25, 1.0, 1.0);
    _transformController.value = matrix;
  }

  void _zoomOut() {
    final matrix = _transformController.value.clone();
    matrix.scaleByDouble(0.8, 0.8, 1.0, 1.0);
    _transformController.value = matrix;
  }

  void _locateMe() {
    setState(() {
      _transformController.value = Matrix4.identity();
      if (kktcRadarListesi.isNotEmpty) {
        _seciliRadar = kktcRadarListesi.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var radarlar = _filtrelenmisRadarlar;
    final RadarKamerasi secili = _seciliRadar ?? (kktcRadarListesi.isNotEmpty ? kktcRadarListesi.first : const RadarKamerasi(
      id: "RAD-01",
      ad: "Gönyeli Çemberi Kamerası",
      adEn: "Gonyeli Camera",
      sehir: "Lefkoşa",
      hizLimiti: 65,
      tur: "Sabit Dijital Radar",
      turEn: "Fixed Digital Radar",
      yon: "Çift Yönlü",
      yonEn: "Dual Way",
      aciklama: "Sabit Sayısal Radar • KKTC Polis Genel Müd. Trafik Bölümü #04",
      aciklamaEn: "Fixed Digital Radar • TRNC Police Dept #04",
      aktif: true,
      mapX: 0.40,
      mapY: 0.52,
      posX: 252,
      posY: 195,
      mesafe: "350m",
    ));

    return Container(
      color: _RadarHtmlColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Live Telemetry & Speed Alert Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _RadarHtmlColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                FadeTransition(
                                  opacity: _pulseController,
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: _RadarHtmlColors.primaryContainer.withValues(alpha: 0.3),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _RadarHtmlColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _RadarHtmlColors.primaryContainer.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.warning_rounded,
                                    color: _RadarHtmlColors.onPrimaryContainer,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        widget.turkceMi ? 'CANLI RADAR UYARISI' : 'LIVE SPEED ALERT',
                                        style: const TextStyle(
                                          color: _RadarHtmlColors.primary,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: _RadarHtmlColors.surfaceContainerLowest,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          secili.mesafe.isNotEmpty ? '${secili.mesafe} ${widget.turkceMi ? 'Kaldı' : 'Ahead'}' : '350m Kaldı',
                                          style: const TextStyle(
                                            color: _RadarHtmlColors.tertiary,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    secili.ad,
                                    style: const TextStyle(
                                      color: _RadarHtmlColors.onSurface,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${secili.yon} • ${secili.sehir}',
                                    style: const TextStyle(
                                      color: _RadarHtmlColors.secondary,
                                      fontSize: 11,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Current Speed vs Limit Gauge Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _RadarHtmlColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  widget.turkceMi ? 'Hızınız' : 'Speed',
                                  style: const TextStyle(color: _RadarHtmlColors.secondary, fontSize: 9),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '$_canliHiz',
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        color: _RadarHtmlColors.tertiary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    const Text(
                                      'km/s',
                                      style: TextStyle(color: _RadarHtmlColors.secondary, fontSize: 9),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: _RadarHtmlColors.surfaceContainerHighest,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${secili.hizLimiti}',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    color: _RadarHtmlColors.onSurface,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Micro Progress Strip
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: 0.76,
                      minHeight: 5,
                      backgroundColor: _RadarHtmlColors.surfaceContainerLowest,
                      valueColor: const AlwaysStoppedAnimation<Color>(_RadarHtmlColors.tertiary),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 2. Search & View Mode Switcher
            Row(
              children: [
                // Search Box
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: _RadarHtmlColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: _RadarHtmlColors.secondary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() => _aramaMetni = val),
                            style: const TextStyle(color: _RadarHtmlColors.onSurface, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: widget.turkceMi ? 'Radar, anayol veya bölge ara...' : 'Search radar or area...',
                              hintStyle: const TextStyle(color: _RadarHtmlColors.secondary, fontSize: 13),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        if (_aramaMetni.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _aramaMetni = '');
                            },
                            child: const Icon(Icons.close_rounded, color: _RadarHtmlColors.secondary, size: 18),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Map/List Segmented Switch
                Container(
                  height: 44,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: _RadarHtmlColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _haritaGorunumu = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: _haritaGorunumu ? _RadarHtmlColors.surfaceContainer : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _haritaGorunumu
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.map_rounded,
                                size: 16,
                                color: _haritaGorunumu ? _RadarHtmlColors.primary : _RadarHtmlColors.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.turkceMi ? 'Harita' : 'Map',
                                style: TextStyle(
                                  color: _haritaGorunumu ? _RadarHtmlColors.onSurface : _RadarHtmlColors.secondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _haritaGorunumu = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: !_haritaGorunumu ? _RadarHtmlColors.surfaceContainer : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: !_haritaGorunumu
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.format_list_bulleted_rounded,
                                size: 16,
                                color: !_haritaGorunumu ? _RadarHtmlColors.primary : _RadarHtmlColors.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.turkceMi ? 'Liste' : 'List',
                                style: TextStyle(
                                  color: !_haritaGorunumu ? _RadarHtmlColors.onSurface : _RadarHtmlColors.secondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // City Filter Horizontal Scroll Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _sehirler.map((sehir) {
                  bool seciliFiltre = _secilenSehir == sehir;
                  int adet = _sehirdekiRadarSayisi(sehir);
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => setState(() => _secilenSehir = sehir),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: seciliFiltre ? _RadarHtmlColors.primaryContainer : _RadarHtmlColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: seciliFiltre
                              ? [
                                  BoxShadow(
                                    color: _RadarHtmlColors.primaryContainer.withValues(alpha: 0.35),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          '$sehir ($adet)',
                          style: TextStyle(
                            color: seciliFiltre ? _RadarHtmlColors.onPrimaryContainer : _RadarHtmlColors.secondary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 14),

            // 3. MAP CANVAS OR LIST VIEW CONTAINER
            if (_haritaGorunumu) ...[
              // Interactive Map Canvas Container (370px height)
              Container(
                height: 370,
                decoration: BoxDecoration(
                  color: const Color(0xFF070E22),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF212942), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // KKTC Otantik Haritası (InteractiveViewer ile sürükle/yakınlaştır)
                      InteractiveViewer(
                        transformationController: _transformController,
                        minScale: 0.75,
                        maxScale: 3.0,
                        boundaryMargin: const EdgeInsets.all(80),
                        child: Center(
                          child: SizedBox(
                            width: 700,
                            height: 340,
                            child: Stack(
                              children: [
                                // 1. Kıbrıs Coğrafi Konturu, Dağlar & Yollar
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: KktcOtantikHaritaPainter(),
                                  ),
                                ),

                                // 2. KKTC Şehir İsim Rozetleri
                                ...kktcSehirleri.map((sehir) {
                                  return Positioned(
                                    left: sehir.posX - 32,
                                    top: sehir.posY - 12,
                                    child: IgnorePointer(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: (sehir.onemli ? const Color(0xFF131A33) : Colors.black).withValues(alpha: 0.85),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: sehir.onemli ? const Color(0xFF4EDEA3).withValues(alpha: 0.8) : Colors.white24,
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Text(
                                          widget.turkceMi ? sehir.ad : sehir.adEn,
                                          style: TextStyle(
                                            color: sehir.onemli ? const Color(0xFFDBE1FF) : Colors.white70,
                                            fontSize: sehir.onemli ? 9 : 8,
                                            fontWeight: sehir.onemli ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),

                                // 3. KKTC 18 Sabit Radar Pinleri (Hız Tabelaları & İkaz)
                                ...radarlar.map((radar) {
                                  final bool isFocused = secili.id == radar.id;
                                  return Positioned(
                                    left: radar.posX - 16,
                                    top: radar.posY - 16,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => setState(() => _seciliRadar = radar),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              if (isFocused) ...[
                                                FadeTransition(
                                                  opacity: _pulseController,
                                                  child: Container(
                                                    width: 44,
                                                    height: 44,
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFFFB3AF).withValues(alpha: 0.45),
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              Container(
                                                width: 26,
                                                height: 26,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: const Color(0xFFD90429),
                                                    width: 2.5,
                                                  ),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.black45,
                                                      blurRadius: 4,
                                                      offset: Offset(0, 1),
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${radar.hizLimiti}',
                                                    style: const TextStyle(
                                                      fontFamily: 'monospace',
                                                      color: Color(0xFFD90429),
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w900,
                                                      letterSpacing: -0.5,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF050D25).withValues(alpha: 0.92),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(
                                                color: isFocused ? const Color(0xFFFFB3AF) : Colors.white12,
                                                width: isFocused ? 1.0 : 0.5,
                                              ),
                                            ),
                                            child: Text(
                                              radar.ad.split(' ').first,
                                              style: TextStyle(
                                                color: isFocused ? Colors.white : const Color(0xFFBDC5E9),
                                                fontSize: 8,
                                                fontWeight: isFocused ? FontWeight.bold : FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Top Overlay: Status badge & Title
                      Positioned(
                        top: 10,
                        left: 10,
                        right: 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _RadarHtmlColors.surfaceContainerHigh.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  FadeTransition(
                                    opacity: _pulseController,
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: _RadarHtmlColors.tertiary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.turkceMi ? 'KKTC Radar Ağı Aktif' : 'TRNC Radar Network',
                                    style: const TextStyle(
                                      color: _RadarHtmlColors.onSurface,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    '| 18/18 Online',
                                    style: TextStyle(
                                      color: _RadarHtmlColors.secondary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _RadarHtmlColors.surfaceContainerHigh.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _RadarHtmlColors.tertiary.withValues(alpha: 0.4),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.explore_rounded, color: _RadarHtmlColors.tertiary, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.turkceMi ? 'Kıbrıs Haritası' : 'Cyprus Map',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bottom Overlay: GPS Precision & Floating Tools
                      Positioned(
                        bottom: 10,
                        left: 10,
                        right: 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _RadarHtmlColors.surfaceContainerHigh.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.satellite_alt_rounded, color: _RadarHtmlColors.tertiary, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.turkceMi ? 'GPS Radarları & Anayol Ağı' : 'GPS Radars & Highways',
                                    style: const TextStyle(color: _RadarHtmlColors.secondary, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            // Floating Zoom & Locate Buttons
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: _zoomIn,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: _RadarHtmlColors.surfaceContainerHigh.withValues(alpha: 0.95),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.3),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.add_rounded, color: _RadarHtmlColors.onSurface, size: 20),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                GestureDetector(
                                  onTap: _zoomOut,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: _RadarHtmlColors.surfaceContainerHigh.withValues(alpha: 0.95),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.3),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.remove_rounded, color: _RadarHtmlColors.onSurface, size: 20),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                GestureDetector(
                                  onTap: _locateMe,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: _RadarHtmlColors.primaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _RadarHtmlColors.primaryContainer.withValues(alpha: 0.4),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.my_location_rounded, color: _RadarHtmlColors.onPrimaryContainer, size: 18),
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
              ),
            ] else ...[
              // Radar List View (when Liste mode selected)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.turkceMi ? 'Kayıtlı Sabit Radarlar' : 'Registered Fixed Radars',
                        style: const TextStyle(
                          color: _RadarHtmlColors.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.turkceMi ? 'Toplam' : 'Total'} ${radarlar.length} ${widget.turkceMi ? 'Nokta' : 'Spots'}',
                        style: const TextStyle(
                          color: _RadarHtmlColors.secondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...radarlar.map((r) {
                    bool isSelected = secili.id == r.id;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? _RadarHtmlColors.surfaceContainer : _RadarHtmlColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                        border: isSelected ? Border.all(color: _RadarHtmlColors.primaryContainer, width: 1.2) : null,
                      ),
                      child: ListTile(
                        onTap: () => setState(() => _seciliRadar = r),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFD90429), width: 3),
                          ),
                          child: Center(
                            child: Text(
                              '${r.hizLimiti}',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                color: Color(0xFFD90429),
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          r.ad,
                          style: const TextStyle(
                            color: _RadarHtmlColors.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${r.sehir} - ${r.yon} • Sabit Dijital',
                          style: const TextStyle(
                            color: _RadarHtmlColors.secondary,
                            fontSize: 11,
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              r.mesafe,
                              style: const TextStyle(
                                color: _RadarHtmlColors.tertiary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.turkceMi ? 'Aktif' : 'Active',
                              style: const TextStyle(
                                color: _RadarHtmlColors.secondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // 4. SELECTED RADAR DETAIL DRAWER (Bottom Sheet Card)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _RadarHtmlColors.surfaceContainer,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Visual affordance handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _RadarHtmlColors.surfaceBright,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header: Speed sign + title + direction badge + share
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFD90429), width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFD90429).withValues(alpha: 0.35),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '${secili.hizLimiti}',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    color: Color(0xFFD90429),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          secili.ad,
                                          style: const TextStyle(
                                            color: _RadarHtmlColors.onSurface,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _RadarHtmlColors.tertiaryContainer.withValues(alpha: 0.4),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          secili.yon,
                                          style: const TextStyle(
                                            color: _RadarHtmlColors.onTertiaryContainer,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    secili.aciklama,
                                    style: const TextStyle(
                                      color: _RadarHtmlColors.secondary,
                                      fontSize: 11,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: _RadarHtmlColors.surfaceContainerHigh,
                              content: Text(
                                '${secili.ad} ${widget.turkceMi ? 'konumu paylaşıldı.' : 'location shared.'}',
                                style: const TextStyle(color: _RadarHtmlColors.onSurface),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _RadarHtmlColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.share_rounded, color: _RadarHtmlColors.secondary, size: 20),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Attributes Matrix Grid (3 Columns)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _RadarHtmlColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.turkceMi ? 'AZAMİ SÜRAT' : 'SPEED LIMIT',
                                style: const TextStyle(
                                  color: _RadarHtmlColors.secondary,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${secili.hizLimiti} km/s',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  color: _RadarHtmlColors.onSurface,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _RadarHtmlColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.turkceMi ? 'TOLERANS' : 'TOLERANCE',
                                style: const TextStyle(
                                  color: _RadarHtmlColors.secondary,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '%10 (+${(secili.hizLimiti * 0.1).toStringAsFixed(1)})',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  color: _RadarHtmlColors.tertiary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _RadarHtmlColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.turkceMi ? 'İZLEME TİPİ' : 'MONITOR TYPE',
                                style: const TextStyle(
                                  color: _RadarHtmlColors.secondary,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                'Lazer/Video',
                                style: TextStyle(
                                  color: _RadarHtmlColors.onSurface,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Audible Alert Live Setting Toggle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: _RadarHtmlColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _RadarHtmlColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.volume_up_rounded, color: _RadarHtmlColors.primary, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.turkceMi ? 'Yaklaşınca Sesli & Bip Uyarısı' : 'Audible Radar Proximity Alert',
                                  style: const TextStyle(
                                    color: _RadarHtmlColors.onSurface,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  widget.turkceMi ? 'Hız sınırını aşarsanız 500m önceden uyarır' : 'Warns 500m ahead if speed exceeded',
                                  style: const TextStyle(
                                    color: _RadarHtmlColors.secondary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: _sesliUyariAktif,
                          activeThumbColor: Colors.white,
                          activeTrackColor: _RadarHtmlColors.primaryContainer,
                          inactiveThumbColor: _RadarHtmlColors.secondary,
                          inactiveTrackColor: _RadarHtmlColors.surfaceContainerLowest,
                          onChanged: (val) {
                            setState(() => _sesliUyariAktif = val);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Action Buttons (Yol Tarifi Al & Nokta İstatistikleri)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _RadarHtmlColors.primaryContainer,
                            foregroundColor: _RadarHtmlColors.onPrimaryContainer,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            shadowColor: _RadarHtmlColors.primaryContainer.withValues(alpha: 0.4),
                            elevation: 4,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: _RadarHtmlColors.surfaceContainerHigh,
                                content: Text(
                                  '${secili.ad} ${widget.turkceMi ? 'için rota başlatılıyor...' : 'route navigation starting...'}',
                                  style: const TextStyle(color: _RadarHtmlColors.onSurface),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.turn_sharp_right_rounded, size: 20),
                          label: Text(
                            widget.turkceMi ? 'Yol Tarifi Al' : 'Get Directions',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _RadarHtmlColors.surfaceContainerHighest,
                            foregroundColor: _RadarHtmlColors.onSurface,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: _RadarHtmlColors.surfaceContainerHigh,
                                content: Text(
                                  widget.turkceMi
                                      ? 'Bu noktada son 30 günde 142 ihlal kaydedildi.'
                                      : '142 violations recorded at this point in the last 30 days.',
                                  style: const TextStyle(color: _RadarHtmlColors.onSurface),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.receipt_long_rounded, size: 20),
                          label: Text(
                            widget.turkceMi ? 'Nokta İstatistikleri' : 'Spot Analytics',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 5. Roadside Safety & Legal Fine Reminder Toast Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _RadarHtmlColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.policy_outlined, color: _RadarHtmlColors.secondary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: _RadarHtmlColors.secondary,
                          fontSize: 11,
                          height: 1.45,
                        ),
                        children: [
                          TextSpan(
                            text: widget.turkceMi
                                ? 'KKTC Trafik Yasası Bilgilendirmesi: '
                                : 'TRNC Traffic Law Notice: ',
                            style: const TextStyle(
                              color: _RadarHtmlColors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: widget.turkceMi
                                ? 'Sabit radar cihazları KKTC Bayındırlık ve Ulaştırma Bakanlığı onaylı kalibrasyona sahiptir. Hız sınırı ihlalleri doğrudan dijital ceza sicilinize yansıtılır.'
                                : 'Fixed speed cameras operate with Ministry of Transport certified calibration. Violations are instantly recorded to your digital driving record.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// ==========================================
// 📍 KKTC ŞEHİR & MERKEZ REFERANS NOKTALARI
// ==========================================
class KktcSehirNoktasi {
  final String ad;
  final String adEn;
  final double posX;
  final double posY;
  final bool onemli;

  const KktcSehirNoktasi({
    required this.ad,
    required this.adEn,
    required this.posX,
    required this.posY,
    this.onemli = false,
  });
}

final List<KktcSehirNoktasi> kktcSehirleri = [
  const KktcSehirNoktasi(ad: "🏛️ Lefkoşa", adEn: "🏛️ Nicosia", posX: 270, posY: 215, onemli: true),
  const KktcSehirNoktasi(ad: "🏰 Girne", adEn: "🏰 Kyrenia", posX: 260, posY: 130, onemli: true),
  const KktcSehirNoktasi(ad: "⚓ Gazimağusa", adEn: "⚓ Famagusta", posX: 465, posY: 230, onemli: true),
  const KktcSehirNoktasi(ad: "🍊 Güzelyurt", adEn: "🍊 Morphou", posX: 135, posY: 205, onemli: true),
  const KktcSehirNoktasi(ad: "🏖️ İskele", adEn: "🏖️ Trikomo", posX: 470, posY: 160, onemli: true),
  const KktcSehirNoktasi(ad: "🌴 Lefke", adEn: "🌴 Lefka", posX: 80, posY: 245),
  const KktcSehirNoktasi(ad: "✈️ Ercan", adEn: "✈️ Ercan", posX: 355, posY: 220, onemli: true),
  const KktcSehirNoktasi(ad: "🧭 Dipkarpaz", adEn: "🧭 Dipkarpaz", posX: 625, posY: 50),
];

// ==========================================
// 🎨 KKTC OTANTİK COĞRAFİ HARİTA ÇİZİCİSİ
// Karpaz Boynuzu, Girne Kıyıları & Anayollar
// ==========================================
class KktcOtantikHaritaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 🌊 Akdeniz Koordinat Izgarası
    final gridPaint = Paint()
      ..color = const Color(0xFF1B243F).withValues(alpha: 0.4)
      ..strokeWidth = 0.6;
    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double j = 0; j < size.height; j += 50) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), gridPaint);
    }

    // 🌊 Deniz Metinleri
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    void drawSeaText(String text, Offset pos, {double fontSize = 9}) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          color: const Color(0xFF2C385A),
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, pos);
    }

    drawSeaText("AKDENİZ (MEDITERRANEAN SEA)", const Offset(230, 20), fontSize: 10);
    drawSeaText("GÜZELYURT KÖRFEZİ", const Offset(65, 140), fontSize: 8);
    drawSeaText("MAĞUSA KÖRFEZİ", const Offset(490, 195), fontSize: 8);

    // 🏝️ 1. GÜNEY KIBRIS ARKA PLAN SILUETI (TAM KIBRIS ADASI HİSSİ)
    final southCyprusPaint = Paint()
      ..color = const Color(0xFF0F172E).withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    final southBorderPaint = Paint()
      ..color = const Color(0xFF212942)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final Path southIsland = Path();
    southIsland.moveTo(80, 255); // Lefke güneyi
    southIsland.lineTo(140, 245);
    southIsland.lineTo(210, 230);
    southIsland.lineTo(270, 225);
    southIsland.lineTo(350, 235);
    southIsland.lineTo(415, 245);
    southIsland.lineTo(465, 230); // Mağusa güneyi
    // Güney sahil kıvrımları: Larnaka, Limasol, Baf
    southIsland.lineTo(470, 270); // Ayia Napa
    southIsland.lineTo(430, 290); // Larnaka
    southIsland.lineTo(340, 320); // Limasol
    southIsland.lineTo(230, 335); // Akrotiri
    southIsland.lineTo(120, 310); // Baf
    southIsland.lineTo(70, 280);  // Poli
    southIsland.close();

    canvas.drawPath(southIsland, southCyprusPaint);
    canvas.drawPath(southIsland, southBorderPaint);

    // 🏝️ 2. KKTC COĞRAFİ ANA KARA PARÇASI (BİREBİR KUZEY KIBRIS)
    final kktcLandPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF192342), Color(0xFF131A33), Color(0xFF161E38)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final kktcBorderPaint = Paint()
      ..color = const Color(0xFF4EDEA3).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final Path kktcPath = Path();
    kktcPath.moveTo(50, 240);  // Erenköy batısı
    kktcPath.lineTo(80, 245);  // Gemikonağı / Lefke
    kktcPath.lineTo(105, 220); // Gaziveren
    kktcPath.lineTo(125, 190); // Güzelyurt Körfezi iç kıvrımı
    kktcPath.lineTo(155, 115); // Koruçam Burnu (Cape Kormakitis)
    kktcPath.lineTo(205, 125); // Lapta / Alsancak
    kktcPath.lineTo(260, 130); // Girne Limanı
    kktcPath.lineTo(310, 135); // Çatalköy
    kktcPath.lineTo(365, 140); // Esentepe
    kktcPath.lineTo(420, 135); // Tatlısu
    kktcPath.lineTo(475, 115); // Kantara / Mersinlik
    kktcPath.lineTo(515, 100); // Kaplıca
    kktcPath.lineTo(550, 85);  // Kumyalı
    kktcPath.lineTo(585, 70);  // Yenierenköy
    kktcPath.lineTo(625, 50);  // Dipkarpaz
    kktcPath.lineTo(670, 30);  // Zafer Burnu Ucu (Cape Apostolos Andreas)
    kktcPath.lineTo(668, 42);  // Zafer burnu alt dönüş
    kktcPath.lineTo(620, 68);  // Karpaz Güney Sahili (Altın Kumsal)
    kktcPath.lineTo(570, 95);  // Ziyamet güneyi
    kktcPath.lineTo(515, 130); // Bafra Çemberi
    kktcPath.lineTo(470, 160); // Boğaz & İskele Sahili
    kktcPath.lineTo(460, 195); // Salamis / Glapsides
    kktcPath.lineTo(465, 230); // Gazimağusa Liman & Surlar
    // Yeşil Hat (BM Sınır Hattı)
    kktcPath.lineTo(415, 245); // Beyarmudu / Pile
    kktcPath.lineTo(350, 235); // Ercan güneyi
    kktcPath.lineTo(270, 225); // Lefkoşa Ledra Sınırı
    kktcPath.lineTo(210, 230); // Alayköy
    kktcPath.lineTo(140, 245); // Güzelyurt güneyi
    kktcPath.lineTo(80, 255);  // Lefke güneyi
    kktcPath.close();

    canvas.drawPath(kktcPath, kktcLandPaint);
    canvas.drawPath(kktcPath, kktcBorderPaint);

    // 🏔️ 3. BEŞPARMAK DAĞLARI SIRADAĞ HATTI
    final mountainPaint = Paint()
      ..color = const Color(0xFF3B4668).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.5;

    final Path mountainRidge = Path();
    mountainRidge.moveTo(180, 135);
    mountainRidge.quadraticBezierTo(260, 145, 360, 150);
    mountainRidge.quadraticBezierTo(440, 140, 520, 105);
    canvas.drawPath(mountainRidge, mountainPaint);

    // 🛣️ 4. KKTC ANAYOL VE OTOYOL AĞI
    final roadGlow = Paint()
      ..color = const Color(0xFFFFB3AF).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;

    final roadCore = Paint()
      ..color = const Color(0xFFE53935)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.8;

    final Path roads = Path();

    // Yol 1: Lefkoşa - Girne (Boğaz Dağ Yolu)
    roads.moveTo(270, 215); // Lefkoşa
    roads.lineTo(252, 195); // Gönyeli
    roads.lineTo(255, 155); // Boğaz
    roads.lineTo(260, 130); // Girne

    // Yol 2: Lefkoşa - Gazimağusa (Duble Yol)
    roads.moveTo(270, 215); // Lefkoşa
    roads.lineTo(290, 210); // Hamitköy
    roads.lineTo(325, 212); // Haspolat / UKÜ
    roads.lineTo(355, 220); // Ercan Kavşağı
    roads.lineTo(410, 222); // Dörtyol
    roads.lineTo(465, 230); // Gazimağusa

    // Yol 3: Lefkoşa - Güzelyurt - Lefke
    roads.moveTo(252, 195); // Gönyeli
    roads.lineTo(205, 205); // Yılmazköy
    roads.lineTo(135, 205); // Güzelyurt
    roads.lineTo(80, 240);  // Lefke

    // Yol 4: Girne Sahil Yolu (Alsancak -> Girne -> Tatlısu)
    roads.moveTo(205, 125); // Alsancak
    roads.lineTo(235, 127); // Karaoğlanoğlu
    roads.lineTo(260, 130); // Girne
    roads.lineTo(280, 140); // Doğanköy / Bellapais
    roads.lineTo(310, 135); // Çatalköy
    roads.lineTo(420, 135); // Tatlısu

    // Yol 5: Gazimağusa - İskele - Karpaz Anayolu
    roads.moveTo(465, 230); // Mağusa
    roads.lineTo(460, 195); // Glapsides
    roads.lineTo(470, 160); // İskele Boğaz
    roads.lineTo(515, 130); // Bafra
    roads.lineTo(585, 70);  // Yenierenköy
    roads.lineTo(625, 50);  // Dipkarpaz
    roads.lineTo(670, 30);  // Zafer Burnu

    // Yol 6: Değirmenlik Dağ Yolu Bağlantısı
    roads.moveTo(325, 212); // Haspolat
    roads.lineTo(345, 180); // Değirmenlik
    roads.lineTo(395, 165); // Geçitkale ayrımı
    roads.lineTo(420, 135); // Tatlısu sahil

    canvas.drawPath(roads, roadGlow);
    canvas.drawPath(roads, roadCore);

    // ✈️ Ercan Havalimanı Pisti & Yonca Kavşak
    final runwayPaint = Paint()
      ..color = const Color(0xFF6FFBBE).withValues(alpha: 0.8)
      ..strokeWidth = 2.0;
    canvas.drawLine(const Offset(350, 218), const Offset(365, 224), runwayPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

