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
  final double mapX; // 0.0 - 1.0 (Harita üzerindeki bağıl X konumu)
  final double mapY; // 0.0 - 1.0 (Harita üzerindeki bağıl Y konumu)
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
    required this.mesafe,
  });
}

// ==========================================
// 🗄️ GERÇEK KKTC SABİT RADAR LİSTESİ
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
    mesafe: "88.0 km",
  ),
];

// ==========================================
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
    _transformController.value = Matrix4.identity();
    if (kktcRadarListesi.isNotEmpty) {
      setState(() => _seciliRadar = kktcRadarListesi.first);
    }
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
                  color: _RadarHtmlColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Vector Cyprus Island Map & Highways SVG simulation
                      InteractiveViewer(
                        transformationController: _transformController,
                        minScale: 0.8,
                        maxScale: 3.5,
                        boundaryMargin: const EdgeInsets.all(50),
                        child: SizedBox(
                          width: 760,
                          height: 380,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: KktcHaritaPainter(),
                                ),
                              ),
                              // Radar Speed Limit Pins
                              ...radarlar.map((radar) {
                                bool isFocused = secili.id == radar.id;
                                return Positioned(
                                  left: radar.mapX * 760 - 18,
                                  top: radar.mapY * 380 - 18,
                                  child: GestureDetector(
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
                                                    color: _RadarHtmlColors.primaryContainer.withValues(alpha: 0.4),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  color: _RadarHtmlColors.primaryContainer.withValues(alpha: 0.45),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ],
                                            // Speed sign pin
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
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.3),
                                                    blurRadius: 4,
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
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: _RadarHtmlColors.surfaceContainerLowest.withValues(alpha: 0.90),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            radar.ad.split(' ').first,
                                            style: TextStyle(
                                              color: isFocused ? _RadarHtmlColors.onSurface : _RadarHtmlColors.secondary,
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

                      // Top Overlay: Status badge & Compass
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
                                    widget.turkceMi ? 'Radar Ağı Aktif' : 'Radar Network Online',
                                    style: const TextStyle(
                                      color: _RadarHtmlColors.onSurface,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    '| 24/24 Online',
                                    style: TextStyle(
                                      color: _RadarHtmlColors.secondary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: _RadarHtmlColors.surfaceContainerHigh.withValues(alpha: 0.92),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.explore_rounded, color: _RadarHtmlColors.primary, size: 18),
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
                                  const Icon(Icons.sensors_rounded, color: _RadarHtmlColors.tertiary, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.turkceMi ? 'GPS Hassasiyeti: 4m' : 'GPS Accuracy: 4m',
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
// 🎨 KKTC KIBRIS VEKTÖREL HARİTA ÇİZİCİSİ (CYPRUS TACTICAL MAP)
// ==========================================
class KktcHaritaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 🌊 Akdeniz Zemin
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF171E37), Color(0xFF131A33), Color(0xFF0A122A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Grid Çizgileri (Deniz Haritası Koordinat Izgarası)
    final gridPaint = Paint()
      ..color = const Color(0xFF212942).withValues(alpha: 0.4)
      ..strokeWidth = 0.5;
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double j = 0; j < size.height; j += 40) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), gridPaint);
    }

    // 🏝️ KKTC ve Kıbrıs Kara Parçası Silueti
    final landPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF171E37), Color(0xFF131A33), Color(0xFF0A122A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final landBorderPaint = Paint()
      ..color = const Color(0xFF212942)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final Path cyprusPath = Path();

    // Kıbrıs / KKTC Coğrafi Konturu
    cyprusPath.moveTo(size.width * 0.10, size.height * 0.62); // Erenköy / Lefke
    cyprusPath.lineTo(size.width * 0.16, size.height * 0.58);
    cyprusPath.lineTo(size.width * 0.22, size.height * 0.50); // Güzelyurt Körfezi
    cyprusPath.lineTo(size.width * 0.30, size.height * 0.35); // Koruçam Burnu
    cyprusPath.lineTo(size.width * 0.38, size.height * 0.33); // Girne Sahili
    cyprusPath.lineTo(size.width * 0.50, size.height * 0.36); // Esentepe
    cyprusPath.lineTo(size.width * 0.62, size.height * 0.38); // Tatlısu
    cyprusPath.lineTo(size.width * 0.74, size.height * 0.32); // Kantara
    cyprusPath.lineTo(size.width * 0.88, size.height * 0.24); // Karpaz Burnu Giriş
    cyprusPath.lineTo(size.width * 0.95, size.height * 0.20); // Zafer Burnu Ucu
    cyprusPath.lineTo(size.width * 0.93, size.height * 0.25);
    cyprusPath.lineTo(size.width * 0.82, size.height * 0.35);
    cyprusPath.lineTo(size.width * 0.75, size.height * 0.42); // Boğaz İskele
    cyprusPath.lineTo(size.width * 0.71, size.height * 0.55); // Gazimağusa Körfezi
    cyprusPath.lineTo(size.width * 0.60, size.height * 0.60); // Mesarya Ovası
    cyprusPath.lineTo(size.width * 0.45, size.height * 0.58); // Lefkoşa Hattı
    cyprusPath.lineTo(size.width * 0.30, size.height * 0.64);
    cyprusPath.lineTo(size.width * 0.18, size.height * 0.65);
    cyprusPath.close();

    canvas.drawPath(cyprusPath, landPaint);
    canvas.drawPath(cyprusPath, landBorderPaint);

    // Beşparmak Dağları Sırt Çizgisi
    final ridgePaint = Paint()
      ..color = const Color(0xFF3D4664).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5;
    final Path ridgePath = Path();
    ridgePath.moveTo(size.width * 0.28, size.height * 0.34);
    ridgePath.quadraticBezierTo(size.width * 0.45, size.height * 0.30, size.width * 0.65, size.height * 0.32);
    canvas.drawPath(ridgePath, ridgePaint);

    // 🛣️ Ana Karayolu Ağı (Glow & Çizgi)
    final roadGlowPaint = Paint()
      ..color = const Color(0xFFFFB3AF).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;

    final roadPaint = Paint()
      ..color = const Color(0xFFD90429)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.8;

    final Path highwayPath = Path();

    // Lefkoşa - Girne Dağ Yolu
    highwayPath.moveTo(size.width * 0.40, size.height * 0.52);
    highwayPath.lineTo(size.width * 0.41, size.height * 0.42);
    highwayPath.lineTo(size.width * 0.38, size.height * 0.34);

    // Lefkoşa - Gazimağusa Anayolu
    highwayPath.moveTo(size.width * 0.40, size.height * 0.52);
    highwayPath.lineTo(size.width * 0.48, size.height * 0.53);
    highwayPath.lineTo(size.width * 0.60, size.height * 0.53);
    highwayPath.lineTo(size.width * 0.69, size.height * 0.53);

    // Lefkoşa - Güzelyurt Anayolu
    highwayPath.moveTo(size.width * 0.40, size.height * 0.52);
    highwayPath.lineTo(size.width * 0.32, size.height * 0.53);
    highwayPath.lineTo(size.width * 0.22, size.height * 0.52);

    canvas.drawPath(highwayPath, roadGlowPaint);
    canvas.drawPath(highwayPath, roadPaint);

    // Territorial Sea Text Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    
    textPainter.text = const TextSpan(
      text: 'AKDENİZ (MEDITERRANEAN SEA)',
      style: TextStyle(
        color: Color(0xFF3D4664),
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.5,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width * 0.35, 16));

    textPainter.text = const TextSpan(
      text: 'MAĞUSA KÖRFEZİ',
      style: TextStyle(
        color: Color(0xFF3D4664),
        fontSize: 8,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width * 0.70, size.height * 0.60));

    textPainter.text = const TextSpan(
      text: 'GÜZELYURT KÖRFEZİ',
      style: TextStyle(
        color: Color(0xFF3D4664),
        fontSize: 8,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width * 0.12, size.height * 0.42));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
