import 'dart:async';
import 'dart:math' as math;
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
  final double lat; // Gerçek GPS Enlem
  final double lon; // Gerçek GPS Boylam
  final double mapX;
  final double mapY;
  final double posX;
  final double posY;
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
    required this.lat,
    required this.lon,
    this.mapX = 0.5,
    this.mapY = 0.5,
    this.posX = 300,
    this.posY = 180,
    required this.mesafe,
  });
}

// ==========================================
// 🗄️ GERÇEK KKTC SABİT RADAR LİSTESİ (18 ADET - TAM KOORDİNATLI)
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
    lat: 35.2132,
    lon: 33.3085,
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
    lat: 35.2036,
    lon: 33.3361,
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
    lat: 35.2155,
    lon: 33.3880,
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
    lat: 35.2168,
    lon: 33.4350,
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
    lat: 35.1795,
    lon: 33.3210,
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
    lat: 35.2785,
    lon: 33.2845,
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
    lat: 35.3370,
    lon: 33.2510,
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
    lat: 35.3395,
    lon: 33.2980,
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
    lat: 35.3230,
    lon: 33.3540,
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
    lat: 35.1450,
    lon: 33.9140,
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
    lat: 35.1865,
    lon: 33.7510,
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
    lat: 35.1880,
    lon: 33.9050,
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
    lat: 35.2750,
    lon: 33.7520,
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
    lat: 35.2065,
    lon: 33.1580,
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
    lat: 35.2180,
    lon: 33.0230,
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
    lat: 35.1120,
    lon: 32.8520,
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
    lat: 35.3210,
    lon: 33.9310,
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
    lat: 35.5380,
    lon: 34.2250,
    mesafe: "88.0 km",
  ),
];

// ==========================================
// 🎨 RADAR RENK PALETİ VE TASARIM TOKENLARI
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
// 🌐 OPENSTREETMAP MERCATOR PROJEKSİYON FONKSİYONLARI
// ==========================================
double osmLonToTileX(double lon, double zoom) {
  return ((lon + 180.0) / 360.0 * math.pow(2.0, zoom));
}

double osmLatToTileY(double lat, double zoom) {
  final rad = lat * math.pi / 180.0;
  final sinVal = math.sin(rad).clamp(-0.9999, 0.9999);
  return ((1.0 - math.log((1.0 + sinVal) / (1.0 - sinVal)) / (2.0 * math.pi)) / 2.0 * math.pow(2.0, zoom));
}

double osmTileXToLon(double x, double zoom) {
  return (x / math.pow(2.0, zoom) * 360.0 - 180.0);
}

double osmTileYToLat(double y, double zoom) {
  final n = math.pi - 2.0 * math.pi * y / math.pow(2.0, zoom);
  final sinh = 0.5 * (math.exp(n) - math.exp(-n));
  return (180.0 / math.pi * math.atan(sinh));
}

// ==========================================
// 📍 OPENSTREETMAP ŞEHİR VE REFERANS NOKTALARI
// ==========================================
class OsmCityRef {
  final String name;
  final String nameEn;
  final double lon;
  final double lat;
  final bool important;

  const OsmCityRef({
    required this.name,
    required this.nameEn,
    required this.lon,
    required this.lat,
    this.important = false,
  });
}

final List<OsmCityRef> osmCityLabels = [
  const OsmCityRef(name: "🏛️ Lefkoşa", nameEn: "🏛️ Nicosia", lon: 33.36, lat: 35.18, important: true),
  const OsmCityRef(name: "⚓ Gazimağusa", nameEn: "⚓ Famagusta", lon: 33.93, lat: 35.13, important: true),
  const OsmCityRef(name: "🏰 Girne", nameEn: "🏰 Kyrenia", lon: 33.32, lat: 35.34, important: true),
  const OsmCityRef(name: "🏖️ İskele", nameEn: "🏖️ Iskele", lon: 33.95, lat: 35.32, important: true),
  const OsmCityRef(name: "🍊 Güzelyurt", nameEn: "🍊 Morphou", lon: 33.00, lat: 35.20, important: true),
  const OsmCityRef(name: "🌴 Lefke", nameEn: "🌴 Lefka", lon: 32.85, lat: 35.11, important: true),
  const OsmCityRef(name: "✈️ Ercan", nameEn: "✈️ Ercan", lon: 33.50, lat: 35.16, important: true),
  const OsmCityRef(name: "🧭 Dipkarpaz", nameEn: "🧭 Dipkarpaz", lon: 34.38, lat: 35.61, important: true),
  const OsmCityRef(name: "📍 Geçitkale", nameEn: "📍 Gecitkale", lon: 33.75, lat: 35.27),
  const OsmCityRef(name: "📍 Alsancak", nameEn: "📍 Alsancak", lon: 33.20, lat: 35.35),
  const OsmCityRef(name: "📍 Lapta", nameEn: "📍 Lapta", lon: 33.05, lat: 35.37),
  const OsmCityRef(name: "📍 Yenierenköy", nameEn: "📍 Yenierenkoy", lon: 34.25, lat: 35.56),
];

// ==========================================
// 🎨 OPENSTREETMAP DİNAMİK VEKTÖR TABAN ÇİZİCİSİ
// (Harita açılır açılmaz anında ve tam net görünür)
// ==========================================
class KktcOsmVectorBasePainter extends CustomPainter {
  final double centerLon;
  final double centerLat;
  final double zoom;
  final double width;
  final double height;
  final int mapStyle;

  KktcOsmVectorBasePainter({
    required this.centerLon,
    required this.centerLat,
    required this.zoom,
    required this.width,
    required this.height,
    required this.mapStyle,
  });

  Offset project(double lon, double lat) {
    final double centerTileX = osmLonToTileX(centerLon, zoom);
    final double centerTileY = osmLatToTileY(centerLat, zoom);
    final double px = width / 2.0 + (osmLonToTileX(lon, zoom) - centerTileX) * 256.0;
    final double py = height / 2.0 + (osmLatToTileY(lat, zoom) - centerTileY) * 256.0;
    return Offset(px, py);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 🌊 Akdeniz Derin Mavi Arka Planı
    final seaPaint = Paint()..color = const Color(0xFF0D223A);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), seaPaint);

    // 🌊 Akdeniz Koordinat Izgarası
    final gridPaint = Paint()
      ..color = const Color(0xFF1E3A5F).withValues(alpha: 0.6)
      ..strokeWidth = 0.8;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 🌊 Akdeniz ve Körfez İsimleri
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    void drawSeaText(String text, Offset pos, {double fontSize = 8.5}) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          color: const Color(0xFF3B6790),
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, pos);
    }

    final pAkdeniz = project(33.50, 35.50);
    drawSeaText("AKDENİZ (MEDITERRANEAN SEA)", Offset(pAkdeniz.dx - 80, pAkdeniz.dy - 35), fontSize: 9.5);
    final pGuzelyurt = project(32.88, 35.25);
    drawSeaText("GÜZELYURT KÖRFEZİ", Offset(pGuzelyurt.dx - 45, pGuzelyurt.dy), fontSize: 7.5);
    final pMagusa = project(34.05, 35.22);
    drawSeaText("MAĞUSA KÖRFEZİ", Offset(pMagusa.dx, pMagusa.dy), fontSize: 7.5);

    // 🏝️ 1. GÜNEY KIBRIS SİLUETİ
    final southPaint = Paint()
      ..color = const Color(0xFF1A2636)
      ..style = PaintingStyle.fill;
    final southBorder = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final Path southPath = Path();
    final sPts = [
      [32.84, 35.08],
      [33.00, 35.15],
      [33.20, 35.18],
      [33.36, 35.17],
      [33.50, 35.15],
      [33.72, 35.05],
      [33.92, 35.08],
      [34.05, 34.98], // Cape Greco
      [33.63, 34.91], // Larnaka
      [33.04, 34.67], // Limasol
      [32.42, 34.77], // Baf (Pafos)
      [32.32, 35.04], // Poli
      [32.75, 35.15],
    ];
    if (sPts.isNotEmpty) {
      southPath.moveTo(project(sPts[0][0], sPts[0][1]).dx, project(sPts[0][0], sPts[0][1]).dy);
      for (int i = 1; i < sPts.length; i++) {
        final p = project(sPts[i][0], sPts[i][1]);
        southPath.lineTo(p.dx, p.dy);
      }
      southPath.close();
      canvas.drawPath(southPath, southPaint);
      canvas.drawPath(southPath, southBorder);
    }

    // 🏝️ 2. KKTC COĞRAFİ ANA KARASI (OPENSTREETMAP KOORDİNATLARIYLA)
    final kktcLandPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF16382C), Color(0xFF122E24), Color(0xFF1A4234)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final kktcBorderPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Path kktcPath = Path();
    final kPts = [
      [32.75, 35.15],
      [32.84, 35.14],
      [32.90, 35.18],
      [32.93, 35.33],
      [32.92, 35.40], // Koruçam Burnu
      [33.05, 35.37], // Lapta
      [33.20, 35.35], // Alsancak
      [33.32, 35.34], // Girne
      [33.45, 35.34], // Çatalköy
      [33.60, 35.35], // Esentepe
      [33.76, 35.43], // Tatlısu
      [33.90, 35.44], // Mersinlik
      [34.02, 35.48], // Kaplıca
      [34.15, 35.52], // Kumyalı
      [34.25, 35.56], // Yenierenköy
      [34.38, 35.61], // Dipkarpaz
      [34.58, 35.70], // Zafer Burnu
      [34.55, 35.63],
      [34.35, 35.55],
      [34.15, 35.40],
      [34.02, 35.36], // Bafra
      [33.95, 35.32], // İskele Boğaz
      [33.91, 35.19], // Glapsides
      [33.94, 35.12], // Gazimağusa Liman
      [33.92, 35.08], // Derinya
      [33.72, 35.05], // Beyarmudu
      [33.50, 35.15], // Ercan güneyi
      [33.36, 35.17], // Lefkoşa Ledra
      [33.20, 35.18], // Alayköy
      [33.00, 35.15], // Güzelyurt güneyi
      [32.84, 35.08], // Lefke güneyi
    ];
    if (kPts.isNotEmpty) {
      kktcPath.moveTo(project(kPts[0][0], kPts[0][1]).dx, project(kPts[0][0], kPts[0][1]).dy);
      for (int i = 1; i < kPts.length; i++) {
        final p = project(kPts[i][0], kPts[i][1]);
        kktcPath.lineTo(p.dx, p.dy);
      }
      kktcPath.close();
      canvas.drawPath(kktcPath, kktcLandPaint);
      canvas.drawPath(kktcPath, kktcBorderPaint);
    }

    // 🏔️ 3. BEŞPARMAK DAĞLARI SIRADAĞ SİLSİLESİ
    final mountainPaint = Paint()
      ..color = const Color(0xFF334155).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;
    final Path mPath = Path();
    final mStart = project(33.15, 35.33);
    final mMid = project(33.55, 35.33);
    final mEnd = project(33.95, 35.38);
    mPath.moveTo(mStart.dx, mStart.dy);
    mPath.quadraticBezierTo(mMid.dx, mMid.dy, mEnd.dx, mEnd.dy);
    canvas.drawPath(mPath, mountainPaint);

    // 🛣️ 4. OPENSTREETMAP GERÇEK ANAYOLLAR VE DUBLE YOLLAR
    final roadGlow = Paint()
      ..color = const Color(0xFFFFB3AF).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.6;

    final roadCore = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.8;

    final highways = [
      // Lefkoşa -> Gönyeli -> Boğaz -> Girne
      [[33.36, 35.18], [33.31, 35.21], [33.28, 35.28], [33.32, 35.34]],
      // Lefkoşa -> Hamitköy -> Haspolat -> Ercan -> Dörtyol -> Gazimağusa
      [[33.36, 35.18], [33.39, 35.21], [33.44, 35.22], [33.50, 35.16], [33.75, 35.18], [33.93, 35.13]],
      // Gönyeli -> Yılmazköy -> Güzelyurt -> Kalkanlı -> Lefke
      [[33.31, 35.21], [33.16, 35.21], [33.00, 35.20], [33.02, 35.22], [32.85, 35.11]],
      // Gazimağusa -> Glapsides -> İskele Boğaz -> Bafra -> Yenierenköy -> Dipkarpaz -> Zafer Burnu
      [[33.93, 35.13], [33.90, 35.19], [33.93, 35.32], [34.02, 35.36], [34.25, 35.56], [34.38, 35.61], [34.58, 35.70]],
      // Girne -> Alsancak -> Lapta
      [[33.32, 35.34], [33.20, 35.35], [33.05, 35.37]],
      // Girne -> Çatalköy -> Esentepe -> Tatlısu
      [[33.32, 35.34], [33.45, 35.34], [33.60, 35.35], [33.76, 35.43]],
      // Haspolat -> Değirmenlik -> Geçitkale -> Tatlısu
      [[33.44, 35.22], [33.50, 35.24], [33.75, 35.27], [33.76, 35.43]],
    ];

    for (var route in highways) {
      final Path rPath = Path();
      final p0 = project(route[0][0], route[0][1]);
      rPath.moveTo(p0.dx, p0.dy);
      for (int i = 1; i < route.length; i++) {
        final p = project(route[i][0], route[i][1]);
        rPath.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(rPath, roadGlow);
      canvas.drawPath(rPath, roadCore);
    }
  }

  @override
  bool shouldRepaint(covariant KktcOsmVectorBasePainter oldDelegate) {
    return oldDelegate.centerLon != centerLon ||
        oldDelegate.centerLat != centerLat ||
        oldDelegate.zoom != zoom ||
        oldDelegate.width != width ||
        oldDelegate.height != height ||
        oldDelegate.mapStyle != mapStyle;
  }
}

// ==========================================
// 🗺️ OPENSTREETMAP VE TILE KONTROL MERKEZİ
// ==========================================
class KktcOpenStreetMapTileView extends StatefulWidget {
  final List<RadarKamerasi> radarlar;
  final RadarKamerasi? seciliRadar;
  final Function(RadarKamerasi) onRadarSelected;
  final bool turkceMi;

  const KktcOpenStreetMapTileView({
    super.key,
    required this.radarlar,
    required this.seciliRadar,
    required this.onRadarSelected,
    this.turkceMi = true,
  });

  @override
  State<KktcOpenStreetMapTileView> createState() => KktcOpenStreetMapTileViewState();
}

class KktcOpenStreetMapTileViewState extends State<KktcOpenStreetMapTileView>
    with SingleTickerProviderStateMixin {
  // Kuzey Kıbrıs tam merkez koordinatları (Lefke ile Karpaz arası tam ortası)
  double _centerLat = 35.250;
  double _centerLon = 33.620;
  double _zoom = 9.0;

  // Harita Stili: 0 = OpenStreetMap Standart, 1 = CartoDB Voyager, 2 = CartoDB Dark Matter
  int _mapStyleIndex = 0;

  late final AnimationController _pulseController;

  final List<String> _tileProviders = [
    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    'https://a.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}.jpg',
  ];

  final List<String> _tileStyleNames = [
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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // Mercator İzdüşümü Formülleri
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

  void zoomIn() {
    setState(() {
      _zoom = (_zoom + 1.0).clamp(8.0, 14.0);
    });
  }

  void zoomOut() {
    setState(() {
      _zoom = (_zoom - 1.0).clamp(8.0, 14.0);
    });
  }

  void centerOnKktc() {
    setState(() {
      _centerLat = 35.250;
      _centerLon = 33.620;
      _zoom = 9.0;
    });
  }

  void flyToLocation(double lat, double lon, {double zoom = 10.5}) {
    setState(() {
      _centerLat = lat;
      _centerLon = lon;
      _zoom = zoom;
    });
  }

  void toggleMapStyle() {
    setState(() {
      _mapStyleIndex = (_mapStyleIndex + 1) % _tileProviders.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        final int intZoom = _zoom.floor();
        final double subScale = math.pow(2.0, _zoom - intZoom).toDouble();
        final double tileSize = 256.0 * subScale;

        final double centerTileX = lonToTileX(_centerLon, intZoom.toDouble());
        final double centerTileY = latToTileY(_centerLat, intZoom.toDouble());

        final int minTileX = (centerTileX - (width / 2.0) / tileSize).floor() - 1;
        final int maxTileX = (centerTileX + (width / 2.0) / tileSize).ceil() + 1;
        final int minTileY = (centerTileY - (height / 2.0) / tileSize).floor() - 1;
        final int maxTileY = (centerTileY + (height / 2.0) / tileSize).ceil() + 1;

        final int numTiles = 1 << intZoom;
        final String template = _tileProviders[_mapStyleIndex];

        return GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              final double dxInTiles = -details.delta.dx / tileSize;
              final double dyInTiles = -details.delta.dy / tileSize;

              final double newCenterTileX = centerTileX + dxInTiles;
              final double newCenterTileY = centerTileY + dyInTiles;

              _centerLon = tileXToLon(newCenterTileX, intZoom.toDouble()).clamp(32.0, 35.0);
              _centerLat = tileYToLat(newCenterTileY, intZoom.toDouble()).clamp(34.4, 36.0);
            });
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. ANLIK VE KESİNTİSİZ OPENSTREETMAP VEKTÖR HARİTA ALTYAPISI (ANA KATMAN)
                  SizedBox.expand(
                    child: CustomPaint(
                      painter: KktcOsmVectorBasePainter(
                        centerLon: _centerLon,
                        centerLat: _centerLat,
                        zoom: _zoom,
                        width: width,
                        height: height,
                        mapStyle: _mapStyleIndex,
                      ),
                    ),
                  ),

                  // 2. OPENSTREETMAP CANLI TİLE KATMANI (DOĞRUDAN POSITIONED)
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
                            errorBuilder: (c, e, s) => const SizedBox.shrink(),
                          ),
                        ),

                  // 3. OPENSTREETMAP ŞEHİR İSİM ROZETLERİ
                  ...osmCityLabels.map((c) {
                    final double cTileX = osmLonToTileX(c.lon, intZoom.toDouble());
                    final double cTileY = osmLatToTileY(c.lat, intZoom.toDouble());
                    final double px = width / 2.0 + (cTileX - centerTileX) * tileSize;
                    final double py = height / 2.0 + (cTileY - centerTileY) * tileSize;

                    if (px < -60 || px > width + 60 || py < -30 || py > height + 30) {
                      return const SizedBox.shrink();
                    }

                    return Positioned(
                      left: px - 28,
                      top: py - 10,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: c.important ? const Color(0xFF10B981) : Colors.white24,
                              width: c.important ? 1.0 : 0.6,
                            ),
                          ),
                          child: Text(
                            widget.turkceMi ? c.name : c.nameEn,
                            style: TextStyle(
                              color: c.important ? Colors.white : const Color(0xFFCBD5E1),
                              fontSize: c.important ? 8.5 : 7.5,
                              fontWeight: c.important ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  // 2. RADAR İŞARETÇİLERİ (HIZ TABELASI PINLERI)
                  ...widget.radarlar.map((radar) {
                    final double rTileX = lonToTileX(radar.lon, intZoom.toDouble());
                    final double rTileY = latToTileY(radar.lat, intZoom.toDouble());

                    final double pinX = width / 2.0 + (rTileX - centerTileX) * tileSize;
                    final double pinY = height / 2.0 + (rTileY - centerTileY) * tileSize;

                    if (pinX < -60 || pinX > width + 60 || pinY < -60 || pinY > height + 60) {
                      return const SizedBox.shrink();
                    }

                    final bool isSelected = widget.seciliRadar?.id == radar.id;

                    return Positioned(
                      left: pinX - 22,
                      top: pinY - 26,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          widget.onRadarSelected(radar);
                          flyToLocation(radar.lat, radar.lon, zoom: math.max(_zoom, 11.5));
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                if (isSelected)
                                  FadeTransition(
                                    opacity: _pulseController,
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF0033).withValues(alpha: 0.45),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFD90429),
                                      width: 2.8,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black54,
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${radar.hizLimiti}',
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        color: Color(0xFFD90429),
                                        fontSize: 11,
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
                                color: const Color(0xFF050D25).withValues(alpha: 0.94),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFFFB3AF) : Colors.white24,
                                  width: isSelected ? 1.2 : 0.6,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black45,
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                radar.ad.split(' ').first,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : const Color(0xFFE2E8F0),
                                  fontSize: 8.5,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  // 3. ÜST BAR: OSM ROZETİ & HARİTA TÜRÜ SEÇİCİ
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white12, width: 0.8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FadeTransition(
                                  opacity: _pulseController,
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    widget.turkceMi ? 'OpenStreetMap • 18 Radar' : 'OpenStreetMap • 18 Radars',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Harita Stili Değiştirme Butonu (OSM / Carto / Gece)
                        GestureDetector(
                          onTap: toggleMapStyle,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.6), width: 0.8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.layers_rounded, color: Color(0xFF38BDF8), size: 13),
                                const SizedBox(width: 4),
                                Text(
                                  _tileStyleNames[_mapStyleIndex],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 4. HIZLI ŞEHİR KISAYOLLARI (MAĞUSA, LEFKOŞA, GİRNE, KARPAZ...)
                  Positioned(
                    top: 42,
                    left: 10,
                    right: 10,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCityChip('🧭 Tüm KKTC', () => centerOnKktc()),
                          _buildCityChip('⚓ Gazimağusa', () => flyToLocation(35.1650, 33.8800, zoom: 10.5)),
                          _buildCityChip('🏛️ Lefkoşa', () => flyToLocation(35.2132, 33.3500, zoom: 10.5)),
                          _buildCityChip('🏰 Girne', () => flyToLocation(35.3370, 33.3000, zoom: 10.5)),
                          _buildCityChip('🏖️ İskele & Karpaz', () => flyToLocation(35.3500, 33.9800, zoom: 10.0)),
                          _buildCityChip('🍊 Güzelyurt', () => flyToLocation(35.2065, 33.0500, zoom: 10.5)),
                          _buildCityChip('🌴 Lefke', () => flyToLocation(35.1120, 32.8520, zoom: 10.5)),
                        ],
                      ),
                    ),
                  ),

                  // 5. SAĞ ALT: ZOOM VE MERKEZ KONTROL BUTONLARI
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Column(
                      children: [
                        _buildFloatingButton(Icons.add_rounded, zoomIn),
                        const SizedBox(height: 6),
                        _buildFloatingButton(Icons.remove_rounded, zoomOut),
                        const SizedBox(height: 6),
                        _buildFloatingButton(
                          Icons.my_location_rounded,
                          centerOnKktc,
                          isAccent: true,
                        ),
                      ],
                    ),
                  ),

                  // 6. SOL ALT: OSM TELİF & DETAY BİLGİSİ
                  Positioned(
                    bottom: 8,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '© OpenStreetMap contributors',
                        style: TextStyle(color: Colors.white70, fontSize: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCityChip(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24, width: 0.7),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingButton(IconData icon, VoidCallback onTap, {bool isAccent = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isAccent ? const Color(0xFFD90429) : const Color(0xFF1E293B).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isAccent ? Colors.white24 : Colors.white12,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isAccent ? Colors.white : const Color(0xFFE2E8F0),
          size: 19,
        ),
      ),
    );
  }
}

// ==========================================
// 🗺️ RADAR VE KAMERA HARİTASI SAYFASI
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
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<KktcOpenStreetMapTileViewState> _osmKey = GlobalKey<KktcOpenStreetMapTileViewState>();

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

  void _onRadarSecildi(RadarKamerasi radar) {
    setState(() {
      _seciliRadar = radar;
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
      lat: 35.2132,
      lon: 33.3085,
      mesafe: "350m",
    ));

    return Container(
      color: _RadarHtmlColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Canlı Telemetri ve Hız İkaz Kutusu
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
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: _RadarHtmlColors.primaryContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.sensors_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          widget.turkceMi ? 'EN YAKIN SABİT RADAR' : 'NEAREST RADAR',
                                          style: const TextStyle(
                                            color: _RadarHtmlColors.primary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.5,
                                          ),
                                          overflow: TextOverflow.ellipsis,
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
                      // Hız ve Limit Göstergesi
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

            // 2. Arama ve Görünüm Seçici (Harita / Liste)
            Row(
              children: [
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
                              hintText: widget.turkceMi ? 'Radar, şehir veya yol ara...' : 'Search radar or area...',
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

            // Şehir Filtreleri
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _sehirler.map((sehir) {
                  bool seciliFiltre = _secilenSehir == sehir;
                  int adet = _sehirdekiRadarSayisi(sehir);
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _secilenSehir = sehir);
                        // Haritada o şehre odaklan
                        if (_osmKey.currentState != null) {
                          if (sehir == "Gazimağusa") {
                            _osmKey.currentState!.flyToLocation(35.1650, 33.8800, zoom: 10.5);
                          } else if (sehir == "Lefkoşa") {
                            _osmKey.currentState!.flyToLocation(35.2132, 33.3500, zoom: 10.5);
                          } else if (sehir == "Girne") {
                            _osmKey.currentState!.flyToLocation(35.3370, 33.3000, zoom: 10.5);
                          } else if (sehir == "Güzelyurt") {
                            _osmKey.currentState!.flyToLocation(35.2065, 33.0500, zoom: 10.5);
                          } else if (sehir == "İskele") {
                            _osmKey.currentState!.flyToLocation(35.3500, 33.9800, zoom: 10.0);
                          } else {
                            _osmKey.currentState!.centerOnKktc();
                          }
                        }
                      },
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

            // 3. HARİTA (OPENSTREETMAP TİLE ENTEGRASYONU) VEYA LİSTE GÖRÜNÜMÜ
            if (_haritaGorunumu) ...[
              Container(
                height: 380,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D223A),
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
                child: KktcOpenStreetMapTileView(
                  key: _osmKey,
                  radarlar: radarlar,
                  seciliRadar: secili,
                  onRadarSelected: _onRadarSecildi,
                  turkceMi: widget.turkceMi,
                ),
              ),
            ] else ...[
              // Radar Listesi Modu
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
                      child: Material(
                        color: isSelected ? _RadarHtmlColors.surfaceContainer : _RadarHtmlColors.surfaceContainerLow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: isSelected
                              ? const BorderSide(color: _RadarHtmlColors.primaryContainer, width: 1.2)
                              : BorderSide.none,
                        ),
                        clipBehavior: Clip.antiAlias,
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
                    ),
                  );
                  }),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // 4. SEÇİLİ RADAR DETAY KARTI (DRAWER KARTI)
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
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _RadarHtmlColors.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${secili.sehir} • ${secili.yon}',
                                      style: const TextStyle(
                                        color: _RadarHtmlColors.secondary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _sesliUyariAktif = !_sesliUyariAktif;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: _RadarHtmlColors.surfaceContainerHigh,
                              duration: const Duration(seconds: 1),
                              content: Text(
                                _sesliUyariAktif
                                    ? (widget.turkceMi ? 'Sesli radar ikazı açıldı 🔊' : 'Voice alert enabled 🔊')
                                    : (widget.turkceMi ? 'Sesli radar ikazı kapatıldı 🔇' : 'Voice alert muted 🔇'),
                                style: const TextStyle(color: _RadarHtmlColors.onSurface),
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          _sesliUyariAktif ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                          color: _sesliUyariAktif ? _RadarHtmlColors.tertiary : _RadarHtmlColors.secondary,
                          size: 22,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Radar Açıklaması ve GPS Koordinat Kartı
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _RadarHtmlColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          secili.aciklama,
                          style: const TextStyle(
                            color: _RadarHtmlColors.secondary,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: _RadarHtmlColors.tertiary),
                            const SizedBox(width: 4),
                            Text(
                              'GPS: ${secili.lat.toStringAsFixed(4)}° N, ${secili.lon.toStringAsFixed(4)}° E',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                color: _RadarHtmlColors.tertiary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Eylem Butonları
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _RadarHtmlColors.primaryContainer,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            // Haritayı bu noktaya götür
                            if (_osmKey.currentState != null) {
                              _osmKey.currentState!.flyToLocation(secili.lat, secili.lon, zoom: 12.5);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: _RadarHtmlColors.surfaceContainerHigh,
                                content: Text(
                                  '${secili.ad} ${widget.turkceMi ? 'haritada odaklandı 📍' : 'focused on map 📍'}',
                                  style: const TextStyle(color: _RadarHtmlColors.onSurface),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.turn_sharp_right_rounded, size: 20),
                          label: Text(
                            widget.turkceMi ? 'Haritada Göster' : 'Show on Map',
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
                                      ? 'Bu noktada son 30 günde 142 hız ihlali kaydedildi.'
                                      : '142 violations recorded at this point in the last 30 days.',
                                  style: const TextStyle(color: _RadarHtmlColors.onSurface),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.receipt_long_rounded, size: 20),
                          label: Text(
                            widget.turkceMi ? 'İstatistikler' : 'Analytics',
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

            // 5. Yasal Bilgilendirme
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
