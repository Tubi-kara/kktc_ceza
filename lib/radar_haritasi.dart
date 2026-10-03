import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'canli_gps_servisi.dart';
import 'yol_tarifi_sayfasi.dart';
import 'yol_forum_modeli.dart';
import 'kktc_tema_servisi.dart';

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

  RotaNoktasi toRotaNoktasi() {
    return RotaNoktasi(
      id: 'radar_$id',
      ad: '$ad ($hizLimiti km/s Radar)',
      adEn: '$adEn ($hizLimiti km/h Camera)',
      kisaAd: ad,
      bolge: sehir,
      lat: lat,
      lon: lon,
      ikon: Icons.camera_alt_rounded,
    );
  }
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
  const RadarKamerasi(
    id: "RAD-19",
    ad: "Demirhan - Erülkü Süpermarket Önü",
    adEn: "Demirhan - Erulku Supermarket Front",
    sehir: "Lefkoşa",
    hizLimiti: 65,
    tur: "Sabit Hız Radarı",
    turEn: "Fixed Speed Camera",
    yon: "Lefkoşa - Gazimağusa Çift Yön",
    yonEn: "Lefkosa - Famagusta Both Ways",
    aciklama: "Erülkü Süpermarket ana giriş kavşağı, Mağusa anayolu.",
    aciklamaEn: "Main entrance junction of Erulku Supermarket, Famagusta highway.",
    aktif: true,
    lat: 35.2185,
    lon: 33.4820,
    mesafe: "8.9 km",
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
// 📍 KKTC HARİTA POI & ÖNEMLİ NOKTA MODELİ (BENZİNLİK, SERVİS, OTOPARK, HASTANE)
// ==========================================
class KktcHaritaPoi {
  final String id;
  final String ad;
  final String marka; // 'K-Pet', 'Alpet', 'Altınbaş Petrol', etc.
  final String kategori; // 'benzin', 'tamir', 'otopark', 'hastane'
  final String sehir;
  final double lat;
  final double lon;
  final String adres;
  final String mesafe;
  final String sure;
  final String calismaSaatleri;
  final Map<String, String> yakitFiyatlari;
  final List<String> olanaklar;
  final IconData ikon;
  final Color renk;

  const KktcHaritaPoi({
    required this.id,
    required this.ad,
    required this.marka,
    required this.kategori,
    required this.sehir,
    required this.lat,
    required this.lon,
    required this.adres,
    required this.mesafe,
    required this.sure,
    this.calismaSaatleri = 'Açık • 24 Saat',
    this.yakitFiyatlari = const {},
    this.olanaklar = const ['Market', 'Hava & Su', 'WC'],
    this.ikon = Icons.local_gas_station_rounded,
    this.renk = const Color(0xFFEF4444),
  });

  RotaNoktasi toRotaNoktasi() {
    return RotaNoktasi(
      id: id,
      ad: ad,
      adEn: ad,
      kisaAd: marka.isNotEmpty ? '$marka ($sehir)' : ad,
      bolge: sehir,
      lat: lat,
      lon: lon,
      ikon: ikon,
      kategori: kategori,
    );
  }
}

// ⛽ GERÇEK VE GÜNCEL KKTC BENZİN İSTASYONLARI VE POI VERİTABANI
final List<KktcHaritaPoi> kktcHaritaPoiListesi = [
  // --- BENZİN İSTASYONLARI (K-PET, ALPET, KANİZİ, BİLKA, MACİLA, ERAY CEMİL VB.) ---
  const KktcHaritaPoi(
    id: 'poi-kpet-gonyeli',
    ad: 'K-Pet Gönyeli Çemberi İstasyonu',
    marka: 'K-Pet',
    kategori: 'benzin',
    sehir: 'Lefkoşa',
    lat: 35.2110,
    lon: 33.3090,
    adres: 'Gönyeli Çemberi Çıkışı, Lefkoşa',
    mesafe: '1.2 km',
    sure: '3 dk',
    calismaSaatleri: 'Açık • 24 Saat',
    yakitFiyatlari: {
      'Euro Diesel (Motorin)': '76.00 ₺',
      'Kurşunsuz 95': '77.12 ₺',
      'Kurşunsuz 98': '78.12 ₺',
      'Gaz Yağı': '76.00 ₺',
    },
    olanaklar: ['Market', 'Oto Yıkama', 'Hava & Su', 'ATM', 'POS'],
    ikon: Icons.local_gas_station_rounded,
    renk: Color(0xFFE11D48),
  ),
  const KktcHaritaPoi(
    id: 'poi-alpet-dereboyu',
    ad: 'Alpet Mehmet Akif Caddesi İstasyonu',
    marka: 'Alpet',
    kategori: 'benzin',
    sehir: 'Lefkoşa',
    lat: 35.1915,
    lon: 33.3480,
    adres: 'Dereboyu Caddesi, Kumsal, Lefkoşa',
    mesafe: '2.5 km',
    sure: '5 dk',
    calismaSaatleri: 'Açık • 24 Saat',
    yakitFiyatlari: {
      'Euro Diesel (Motorin)': '76.00 ₺',
      'Kurşunsuz 95': '77.12 ₺',
      'Kurşunsuz 98': '78.12 ₺',
    },
    olanaklar: ['Alpet Market', 'Kafeterya', 'Oto Yıkama', 'Hava & Su'],
    ikon: Icons.local_gas_station_rounded,
    renk: Color(0xFF0284C7),
  ),
  const KktcHaritaPoi(
    id: 'poi-kanizi-gonyeli',
    ad: 'Kanizi Petrol (K-Pet Bayi)',
    marka: 'K-Pet / Kanizi',
    kategori: 'benzin',
    sehir: 'Lefkoşa',
    lat: 35.2165,
    lon: 33.3040,
    adres: 'Gönyeli Belediye Bulvarı No:42',
    mesafe: '1.5 km',
    sure: '3 dk',
    calismaSaatleri: 'Açık • 24 Saat',
    yakitFiyatlari: {
      'Euro Diesel (Motorin)': '76.00 ₺',
      'Kurşunsuz 95': '77.12 ₺',
      'Kurşunsuz 98': '78.12 ₺',
    },
    olanaklar: ['24 Saat Market', 'Oto Süpürge', 'Hava & Su', 'POS'],
    ikon: Icons.local_gas_station_rounded,
    renk: Color(0xFFE11D48),
  ),
  const KktcHaritaPoi(
    id: 'poi-bilka-lefkosa',
    ad: 'Bilka Petrol (Alpet Bayi)',
    marka: 'Alpet / Bilka',
    kategori: 'benzin',
    sehir: 'Lefkoşa',
    lat: 35.2195,
    lon: 33.3550,
    adres: 'Organize Sanayi Bölgesi Girişi, Lefkoşa',
    mesafe: '3.3 km',
    sure: '6 dk',
    calismaSaatleri: 'Açık • 24 Saat',
    yakitFiyatlari: {
      'Euro Diesel (Motorin)': '76.00 ₺',
      'Kurşunsuz 95': '77.12 ₺',
      'Kurşunsuz 98': '78.12 ₺',
    },
    olanaklar: ['Market', 'Ağır Vasıta Pompası', 'Oto Bakım', 'ATM'],
    ikon: Icons.local_gas_station_rounded,
    renk: Color(0xFF0284C7),
  ),
  const KktcHaritaPoi(
    id: 'poi-kpet-ortakoy',
    ad: 'K-Pet Ortaköy Devlet Hastanesi İstasyonu',
    marka: 'K-Pet',
    kategori: 'benzin',
    sehir: 'Lefkoşa',
    lat: 35.2045,
    lon: 33.3340,
    adres: 'Dr. Burhan Nalbantoğlu Cad. Ortaköy',
    mesafe: '1.8 km',
    sure: '4 dk',
    calismaSaatleri: 'Açık • 24 Saat',
    yakitFiyatlari: {
      'Euro Diesel (Motorin)': '76.00 ₺',
      'Kurşunsuz 95': '77.12 ₺',
    },
    olanaklar: ['24 Saat Market', 'Hava & Su', 'WC'],
    ikon: Icons.local_gas_station_rounded,
    renk: Color(0xFFE11D48),
  ),
  const KktcHaritaPoi(
    id: 'poi-asel-taskinkoy',
    ad: 'Asel Petrol İstasyonu',
    marka: 'K-Pet / Asel',
    kategori: 'benzin',
    sehir: 'Lefkoşa',
    lat: 35.2010,
    lon: 33.3520,
    adres: 'Dr. Fazıl Küçük Bulvarı, Taşkınköy',
    mesafe: '2.8 km',
    sure: '5 dk',
    calismaSaatleri: 'Açık • 24 Saat',
    yakitFiyatlari: {
      'Euro Diesel (Motorin)': '76.00 ₺',
      'Kurşunsuz 95': '77.12 ₺',
      'Kurşunsuz 98': '78.12 ₺',
    },
    olanaklar: ['Market', 'Oto Yıkama', 'Hava & Su', 'Cafe'],
    ikon: Icons.local_gas_station_rounded,
    renk: Color(0xFFE11D48),
  ),
  const KktcHaritaPoi(
    id: 'poi-alpet-bogaz',
    ad: 'Alpet Boğaz Dağ Yolu Dinlenme Tesisi',
    marka: 'Alpet',
    kategori: 'benzin',
    sehir: 'Girne',
    lat: 35.2750,
    lon: 33.2870,
    adres: 'Lefkoşa - Girne Dağ Yolu Boğaz Mevkii',
    mesafe: '9.8 km',
    sure: '11 dk',
    calismaSaatleri: 'Açık • 24 Saat',
    yakitFiyatlari: {
      'Euro Diesel (Motorin)': '76.00 ₺',
      'Kurşunsuz 95': '77.12 ₺',
      'Kurşunsuz 98': '78.12 ₺',
    },
    olanaklar: ['Dinlenme Alanı', 'Market', 'Restoran', 'Oto Yıkama'],
    ikon: Icons.local_gas_station_rounded,
    renk: Color(0xFF0284C7),
  ),
  const KktcHaritaPoi(
    id: 'poi-eraycemil-girne',
    ad: 'Eray Cemil Petrol (Alpet Bayi)',
    marka: 'Alpet / Eray Cemil',
    kategori: 'benzin',
    sehir: 'Girne',
    lat: 35.3370,
    lon: 33.2980,
    adres: 'Karaoğlanoğlu Caddesi No:112, Girne',
    mesafe: '18.1 km',
    sure: '20 dk',
    calismaSaatleri: 'Açık • 24 Saat',
    yakitFiyatlari: {
      'Euro Diesel (Motorin)': '76.00 ₺',
      'Kurşunsuz 95': '77.12 ₺',
      'Kurşunsuz 98': '78.12 ₺',
    },
    olanaklar: ['Market', 'Oto Kuaför', 'Hava & Su', 'ATM'],
    ikon: Icons.local_gas_station_rounded,
    renk: Color(0xFF0284C7),
  ),
  const KktcHaritaPoi(
    id: 'poi-kpet-alsancak',
    ad: 'K-Pet Girne Alsancak Çevre Yolu İstasyonu',
    marka: 'K-Pet',
    kategori: 'benzin',
    sehir: 'Girne',
    lat: 35.3340,
    lon: 33.2610,
    adres: 'Alsancak Girişi Çevre Yolu Kavşağı',
    mesafe: '18.4 km',
    sure: '20 dk',
    calismaSaatleri: 'Açık • 24 Saat',
    yakitFiyatlari: {
      'Euro Diesel (Motorin)': '76.00 ₺',
      'Kurşunsuz 95': '77.12 ₺',
    },
    olanaklar: ['Market', 'Oto Yıkama', 'Elektrikli Şarj'],
    ikon: Icons.local_gas_station_rounded,
    renk: Color(0xFFE11D48),
  ),
  const KktcHaritaPoi(
    id: 'poi-alpet-dogankoy',
    ad: 'Alpet Girne Çevre Yolu Doğanköy İstasyonu',
    marka: 'Alpet',
    kategori: 'benzin',
    sehir: 'Girne',
    lat: 35.3310,
    lon: 33.3280,
    adres: 'Doğanköy Çemberi, Girne Çevre Yolu',
    mesafe: '17.2 km',
    sure: '19 dk',
    calismaSaatleri: 'Açık • 24 Saat',
    yakitFiyatlari: {
      'Euro Diesel (Motorin)': '76.00 ₺',
      'Kurşunsuz 95': '77.12 ₺',
      'Kurşunsuz 98': '78.12 ₺',
    },
    olanaklar: ['24 Saat Market', 'Lastik & Hava', 'Oto Süpürge'],
    ikon: Icons.local_gas_station_rounded,
    renk: Color(0xFF0284C7),
  ),
  const KktcHaritaPoi(
    id: 'poi-kpet-magusa',
    ad: 'K-Pet Gazimağusa Giriş (Anıt Çemberi) İstasyonu',
    marka: 'K-Pet',
    kategori: 'benzin',
    sehir: 'Gazimağusa',
    lat: 35.1290,
    lon: 33.9280,
    adres: 'İsmet İnönü Bulvarı, Anıt Çemberi Yanı',
    mesafe: '34.2 km',
    sure: '31 dk',
    calismaSaatleri: 'Açık • 24 Saat',
    yakitFiyatlari: {
      'Euro Diesel (Motorin)': '76.00 ₺',
      'Kurşunsuz 95': '77.12 ₺',
      'Gaz Yağı': '76.00 ₺',
    },
    olanaklar: ['Market', 'Oto Yıkama', 'Mescit'],
    ikon: Icons.local_gas_station_rounded,
    renk: Color(0xFFE11D48),
  ),
  const KktcHaritaPoi(
    id: 'poi-macila-magusa',
    ad: 'Hasan Macila Petrol (K-Pet Bayi)',
    marka: 'K-Pet / Macila',
    kategori: 'benzin',
    sehir: 'Gazimağusa',
    lat: 35.1380,
    lon: 33.9350,
    adres: 'Liman Yolu, Serbest Liman Bölgesi, Gazimağusa',
    mesafe: '35.1 km',
    sure: '32 dk',
    calismaSaatleri: 'Açık • 24 Saat',
    yakitFiyatlari: {
      'Euro Diesel (Motorin)': '76.00 ₺',
      'Kurşunsuz 95': '77.12 ₺',
      'Kurşunsuz 98': '78.12 ₺',
    },
    olanaklar: ['Market', 'TIR & Kamyon Pompası', 'Oto Yıkama', 'Hava & Su'],
    ikon: Icons.local_gas_station_rounded,
    renk: Color(0xFFE11D48),
  ),
  const KktcHaritaPoi(
    id: 'poi-alpet-dau',
    ad: 'Alpet Salamis Yolu DAÜ İstasyonu',
    marka: 'Alpet',
    kategori: 'benzin',
    sehir: 'Gazimağusa',
    lat: 35.1450,
    lon: 33.9160,
    adres: 'Salamis Yolu DAÜ Kampüs Girişi Karşısı',
    mesafe: '36.5 km',
    sure: '34 dk',
    calismaSaatleri: 'Açık • 24 Saat',
    yakitFiyatlari: {
      'Euro Diesel (Motorin)': '76.00 ₺',
      'Kurşunsuz 95': '77.12 ₺',
      'Kurşunsuz 98': '78.12 ₺',
    },
    olanaklar: ['Market & Cafe', 'Oto Yıkama', 'Hava & Su'],
    ikon: Icons.local_gas_station_rounded,
    renk: Color(0xFF0284C7),
  ),
  const KktcHaritaPoi(
    id: 'poi-kpet-guzelyurt',
    ad: 'K-Pet Güzelyurt Çevre Yolu İstasyonu',
    marka: 'K-Pet',
    kategori: 'benzin',
    sehir: 'Güzelyurt',
    lat: 35.1960,
    lon: 32.9910,
    adres: 'Güzelyurt Çevre Yolu ODTÜ Kavşağı',
    mesafe: '27.8 km',
    sure: '25 dk',
    calismaSaatleri: 'Açık • 24 Saat',
    yakitFiyatlari: {
      'Euro Diesel (Motorin)': '76.00 ₺',
      'Kurşunsuz 95': '77.12 ₺',
    },
    olanaklar: ['Market', 'Oto Bakım', 'Hava & Su'],
    ikon: Icons.local_gas_station_rounded,
    renk: Color(0xFFE11D48),
  ),
  const KktcHaritaPoi(
    id: 'poi-altinbas-iskele',
    ad: 'Altınbaş Petrol İskele Long Beach İstasyonu',
    marka: 'Altınbaş / Alpet',
    kategori: 'benzin',
    sehir: 'İskele',
    lat: 35.2910,
    lon: 33.9050,
    adres: 'Long Beach Sahil Yolu Kavşağı, İskele',
    mesafe: '41.5 km',
    sure: '37 dk',
    calismaSaatleri: 'Açık • 24 Saat',
    yakitFiyatlari: {
      'Euro Diesel (Motorin)': '76.00 ₺',
      'Kurşunsuz 95': '77.12 ₺',
      'Kurşunsuz 98': '78.12 ₺',
    },
    olanaklar: ['24 Saat Market', 'Oto Yıkama', 'Cafe'],
    ikon: Icons.local_gas_station_rounded,
    renk: Color(0xFFF59E0B),
  ),
  const KktcHaritaPoi(
    id: 'poi-kpet-erenkoy',
    ad: 'K-Pet Karpaz Yenierenköy İstasyonu',
    marka: 'K-Pet',
    kategori: 'benzin',
    sehir: 'İskele',
    lat: 35.5340,
    lon: 34.1890,
    adres: 'Yenierenköy Anayolu Üzeri, Karpaz',
    mesafe: '68.0 km',
    sure: '62 dk',
    calismaSaatleri: 'Açık • 24 Saat',
    yakitFiyatlari: {
      'Euro Diesel (Motorin)': '76.00 ₺',
      'Kurşunsuz 95': '77.12 ₺',
      'Gaz Yağı': '76.00 ₺',
    },
    olanaklar: ['Köy Marketi', 'Hava & Su', 'Lastik Tamir'],
    ikon: Icons.local_gas_station_rounded,
    renk: Color(0xFFE11D48),
  ),
  const KktcHaritaPoi(
    id: 'poi-kpet-ercan',
    ad: 'K-Pet Ercan Havalimanı Kavşağı İstasyonu',
    marka: 'K-Pet',
    kategori: 'benzin',
    sehir: 'Lefkoşa',
    lat: 35.1580,
    lon: 33.4920,
    adres: 'Yeni Ercan Havalimanı Anayolu Çıkışı',
    mesafe: '15.2 km',
    sure: '14 dk',
    calismaSaatleri: 'Açık • 24 Saat',
    yakitFiyatlari: {
      'Euro Diesel (Motorin)': '76.00 ₺',
      'Kurşunsuz 95': '77.12 ₺',
      'Kurşunsuz 98': '78.12 ₺',
    },
    olanaklar: ['Market', 'WC', 'Oto Yıkama'],
    ikon: Icons.local_gas_station_rounded,
    renk: Color(0xFFE11D48),
  ),
  const KktcHaritaPoi(
    id: 'poi-alpet-haspolat',
    ad: 'Alpet Haspolat UKÜ Kavşağı İstasyonu',
    marka: 'Alpet',
    kategori: 'benzin',
    sehir: 'Lefkoşa',
    lat: 35.2100,
    lon: 33.4180,
    adres: 'Lefkoşa - Mağusa Anayolu, UKÜ Kavşağı',
    mesafe: '7.8 km',
    sure: '8 dk',
    calismaSaatleri: 'Açık • 24 Saat',
    yakitFiyatlari: {
      'Euro Diesel (Motorin)': '76.00 ₺',
      'Kurşunsuz 95': '77.12 ₺',
      'Kurşunsuz 98': '78.12 ₺',
    },
    olanaklar: ['Market & Cafe', 'Oto Yıkama', 'Hava & Su'],
    ikon: Icons.local_gas_station_rounded,
    renk: Color(0xFF0284C7),
  ),
  const KktcHaritaPoi(
    id: 'poi-alpet-gemikonagi',
    ad: 'Alpet Gemikonağı LAÜ Caddesi İstasyonu',
    marka: 'Alpet',
    kategori: 'benzin',
    sehir: 'Lefke',
    lat: 35.1480,
    lon: 32.8520,
    adres: 'Ecevit Caddesi, Gemikonağı, Lefke',
    mesafe: '38.5 km',
    sure: '36 dk',
    calismaSaatleri: 'Açık • 24 Saat',
    yakitFiyatlari: {
      'Euro Diesel (Motorin)': '76.00 ₺',
      'Kurşunsuz 95': '77.12 ₺',
    },
    olanaklar: ['Market', 'Hava & Su', 'Oto Yıkama'],
    ikon: Icons.local_gas_station_rounded,
    renk: Color(0xFF0284C7),
  ),
  const KktcHaritaPoi(
    id: 'poi-kpet-lefke',
    ad: 'K-Pet Cengiz Topel Anıt İstasyonu',
    marka: 'K-Pet',
    kategori: 'benzin',
    sehir: 'Lefke',
    lat: 35.1320,
    lon: 32.8710,
    adres: 'Cengiz Topel Caddesi, Yeşilyurt - Lefke Yolu',
    mesafe: '39.8 km',
    sure: '38 dk',
    calismaSaatleri: 'Açık • 24 Saat',
    yakitFiyatlari: {
      'Euro Diesel (Motorin)': '76.00 ₺',
      'Kurşunsuz 95': '77.12 ₺',
    },
    olanaklar: ['Market', 'Hava & Su', 'WC'],
    ikon: Icons.local_gas_station_rounded,
    renk: Color(0xFFE11D48),
  ),

  // --- OTO SERVİS & LASTİK ---
  const KktcHaritaPoi(
    id: 'poi-lastik-lefkosa',
    ad: 'Lefkoşa Sanayi 7/24 Lastik & Akü Servisi',
    marka: 'Oto Servis',
    kategori: 'tamir',
    sehir: 'Lefkoşa',
    lat: 35.2180,
    lon: 33.3620,
    adres: 'Organize Sanayi Bölgesi 4. Cad. Lefkoşa',
    mesafe: '3.1 km',
    sure: '6 dk',
    calismaSaatleri: '7/24 Acil Yol Servisi',
    olanaklar: ['Mobil Lastik Değişimi', 'Akü Takviye', 'Balans'],
    ikon: Icons.build_circle_rounded,
    renk: Color(0xFF10B981),
  ),
  const KktcHaritaPoi(
    id: 'poi-lastik-girne',
    ad: 'Girne Alsancak Oto Servis & Mobil Lastikçi',
    marka: 'Oto Servis',
    kategori: 'tamir',
    sehir: 'Girne',
    lat: 35.3420,
    lon: 33.2350,
    adres: 'Alsancak Anayolu No:84, Girne',
    mesafe: '19.0 km',
    sure: '22 dk',
    calismaSaatleri: '08:00 - 20:00 (Nöbetçi Servis)',
    olanaklar: ['Lastik Satış & Tamir', 'Yol Yardım'],
    ikon: Icons.build_circle_rounded,
    renk: Color(0xFF10B981),
  ),
  const KktcHaritaPoi(
    id: 'poi-lastik-magusa',
    ad: 'Gazimağusa Sanayi Lastik & Yol Yardım Servisi',
    marka: 'Oto Servis',
    kategori: 'tamir',
    sehir: 'Gazimağusa',
    lat: 35.1320,
    lon: 33.9210,
    adres: 'Gazimağusa Küçük Sanayi Sitesi',
    mesafe: '35.0 km',
    sure: '33 dk',
    calismaSaatleri: '7/24 Acil Yol Servisi',
    olanaklar: ['Mobil Lastik', 'Çekici & Akü'],
    ikon: Icons.build_circle_rounded,
    renk: Color(0xFF10B981),
  ),
  const KktcHaritaPoi(
    id: 'poi-lastik-guzelyurt',
    ad: 'Güzelyurt Sanayi Oto Lastik & Tamir Servisi',
    marka: 'Oto Servis',
    kategori: 'tamir',
    sehir: 'Güzelyurt',
    lat: 35.2010,
    lon: 32.9960,
    adres: 'Güzelyurt Sanayi Bölgesi 2. Blok',
    mesafe: '26.5 km',
    sure: '24 dk',
    calismaSaatleri: '08:00 - 19:00 (Nöbetçi Servis)',
    olanaklar: ['Lastik Tamiri', 'Balans', 'Akü'],
    ikon: Icons.build_circle_rounded,
    renk: Color(0xFF10B981),
  ),

  // --- OTOPARK ---
  const KktcHaritaPoi(
    id: 'poi-otopark-lefkosa',
    ad: 'Lefkoşa Ledra Palace Yanı Belediye Otoparkı',
    marka: 'Belediye Otoparkı',
    kategori: 'otopark',
    sehir: 'Lefkoşa',
    lat: 35.1785,
    lon: 33.3560,
    adres: 'İkinci Selim Cad. Suriçi Girişi',
    mesafe: '2.0 km',
    sure: '4 dk',
    calismaSaatleri: 'Açık • 24 Saat',
    olanaklar: ['Güvenlik Kamerası', 'Gölge Sundurma', 'Engelli Parkı'],
    ikon: Icons.local_parking_rounded,
    renk: Color(0xFF8B5CF6),
  ),
  const KktcHaritaPoi(
    id: 'poi-otopark-girne',
    ad: 'Girne Antik Liman Katlı Otoparkı',
    marka: 'Belediye Otoparkı',
    kategori: 'otopark',
    sehir: 'Girne',
    lat: 35.3425,
    lon: 33.3205,
    adres: 'Kordonboyu Yanı, Antik Liman Girişi',
    mesafe: '16.5 km',
    sure: '18 dk',
    calismaSaatleri: 'Açık • 24 Saat',
    olanaklar: ['Kapalı Katlı', 'Güvenlik', 'Elektrikli Şarj'],
    ikon: Icons.local_parking_rounded,
    renk: Color(0xFF8B5CF6),
  ),
  const KktcHaritaPoi(
    id: 'poi-otopark-magusa',
    ad: 'Gazimağusa Suriçi Belediye Otoparkı',
    marka: 'Belediye Otoparkı',
    kategori: 'otopark',
    sehir: 'Gazimağusa',
    lat: 35.1245,
    lon: 33.9410,
    adres: 'Lala Mustafa Paşa Camii Yanı, Suriçi',
    mesafe: '36.0 km',
    sure: '34 dk',
    calismaSaatleri: 'Açık • 24 Saat',
    olanaklar: ['Açık Otopark', 'Kamera Güvenliği'],
    ikon: Icons.local_parking_rounded,
    renk: Color(0xFF8B5CF6),
  ),

  // --- HASTANELER ---
  const KktcHaritaPoi(
    id: 'poi-hastane-lefkosa',
    ad: 'Dr. Burhan Nalbantoğlu Devlet Hastanesi Acil',
    marka: 'Devlet Hastanesi',
    kategori: 'hastane',
    sehir: 'Lefkoşa',
    lat: 35.2036,
    lon: 33.3361,
    adres: 'Ortaköy, Lefkoşa',
    mesafe: '1.9 km',
    sure: '4 dk',
    calismaSaatleri: '7/24 Acil Servis (112)',
    olanaklar: ['7/24 Acil', 'Ambulans', 'Eczane Karşısı'],
    ikon: Icons.local_hospital_rounded,
    renk: Color(0xFFDC2626),
  ),
  const KktcHaritaPoi(
    id: 'poi-hastane-girne',
    ad: 'Girne Dr. Akçiçek Devlet Hastanesi',
    marka: 'Devlet Hastanesi',
    kategori: 'hastane',
    sehir: 'Girne',
    lat: 35.3360,
    lon: 33.3190,
    adres: 'Hastane Cad. Girne',
    mesafe: '16.8 km',
    sure: '19 dk',
    calismaSaatleri: '7/24 Acil Servis',
    olanaklar: ['7/24 Acil', 'Acil Otoparkı'],
    ikon: Icons.local_hospital_rounded,
    renk: Color(0xFFDC2626),
  ),
  const KktcHaritaPoi(
    id: 'poi-hastane-magusa',
    ad: 'Gazimağusa Devlet Hastanesi Acil Servis',
    marka: 'Devlet Hastanesi',
    kategori: 'hastane',
    sehir: 'Gazimağusa',
    lat: 35.1480,
    lon: 33.9080,
    adres: 'Salamis Yolu Girişi, Gazimağusa',
    mesafe: '35.5 km',
    sure: '32 dk',
    calismaSaatleri: '7/24 Acil Servis (112)',
    olanaklar: ['7/24 Acil', 'Helikopter Pisti', 'Yoğun Bakım'],
    ikon: Icons.local_hospital_rounded,
    renk: Color(0xFFDC2626),
  ),
  const KktcHaritaPoi(
    id: 'poi-hastane-cengiztopel',
    ad: 'Cengiz Topel Devlet Hastanesi Acil Servis',
    marka: 'Devlet Hastanesi',
    kategori: 'hastane',
    sehir: 'Lefke',
    lat: 35.1380,
    lon: 32.8360,
    adres: 'Yeşilyurt - Lefke Anayolu',
    mesafe: '39.0 km',
    sure: '36 dk',
    calismaSaatleri: '7/24 Acil Servis (112)',
    olanaklar: ['7/24 Acil', 'Ambulans İstasyonu'],
    ikon: Icons.local_hospital_rounded,
    renk: Color(0xFFDC2626),
  ),

  // --- AVM & ALIŞVERİŞ MERKEZLERİ ---
  const KktcHaritaPoi(
    id: 'poi-avm-citymall',
    ad: 'City Mall Gazimağusa AVM',
    marka: 'City Mall',
    kategori: 'avm',
    sehir: 'Gazimağusa',
    lat: 35.1385,
    lon: 33.9180,
    adres: 'Salamis Yolu No:114, Gazimağusa',
    mesafe: '34.2 km',
    sure: '31 dk',
    calismaSaatleri: 'Açık • 10:00 - 22:00',
    olanaklar: ['Kapalı Otopark', 'Sinema', 'Food Court', 'Market', 'Bebek Bakım', 'ATM'],
    ikon: Icons.shopping_bag_rounded,
    renk: Color(0xFF8B5CF6),
  ),
  const KktcHaritaPoi(
    id: 'poi-avm-dereboyu',
    ad: 'Avenue Dereboyu Alışveriş & Yaşam Merkezi',
    marka: 'Avenue Cinecity',
    kategori: 'avm',
    sehir: 'Lefkoşa',
    lat: 35.1930,
    lon: 33.3490,
    adres: 'Mehmet Akif Caddesi (Dereboyu), Lefkoşa',
    mesafe: '2.4 km',
    sure: '5 dk',
    calismaSaatleri: 'Açık • 10:00 - 23:00',
    olanaklar: ['Sinema Salonları', 'Kafe & Restoranlar', 'Giyim Mağazaları', 'Vale Park'],
    ikon: Icons.storefront_rounded,
    renk: Color(0xFFEC4899),
  ),
  const KktcHaritaPoi(
    id: 'poi-avm-1001',
    ad: '1001 Airport Mall & Outlet Merkezi',
    marka: '1001 Outlet',
    kategori: 'avm',
    sehir: 'Lefkoşa',
    lat: 35.1950,
    lon: 33.4350,
    adres: 'Lefkoşa - Mağusa Anayolu, Ercan Kavşağı',
    mesafe: '8.5 km',
    sure: '9 dk',
    calismaSaatleri: 'Açık • 10:00 - 22:00',
    olanaklar: ['Geniş Açık Otopark', 'Outlet Mağazalar', 'Çocuk Oyun Alanı', 'Süpermarket'],
    ikon: Icons.shopping_bag_rounded,
    renk: Color(0xFF6366F1),
  ),
  const KktcHaritaPoi(
    id: 'poi-avm-erulku',
    ad: 'Erülkü Süpermarket & Yaşam Merkezi',
    marka: 'Erülkü',
    kategori: 'avm',
    sehir: 'Lefkoşa',
    lat: 35.1840,
    lon: 33.4680,
    adres: 'Demirhan Çemberi Yanı, Lefkoşa - Gazimağusa Yolu',
    mesafe: '11.0 km',
    sure: '11 dk',
    calismaSaatleri: 'Açık • 07:30 - 22:30',
    olanaklar: ['Dev Otopark', 'Restoran & Fırın', 'Elektronik & Züccaciye', 'ATM'],
    ikon: Icons.storefront_rounded,
    renk: Color(0xFFF59E0B),
  ),
  const KktcHaritaPoi(
    id: 'poi-avm-metropol',
    ad: 'Metropol Alışveriş & Çarşı Merkezi',
    marka: 'Metropol',
    kategori: 'avm',
    sehir: 'Lefkoşa',
    lat: 35.2070,
    lon: 33.3510,
    adres: 'Metropol Bölgesi, Taşkınköy, Lefkoşa',
    mesafe: '2.8 km',
    sure: '6 dk',
    calismaSaatleri: 'Açık • 08:00 - 22:00',
    olanaklar: ['Süpermarket', 'Mağazalar', 'Otopark', 'Eczane'],
    ikon: Icons.shopping_bag_rounded,
    renk: Color(0xFF14B8A6),
  ),
  const KktcHaritaPoi(
    id: 'poi-avm-girne',
    ad: 'Bellapais Mall Alışveriş & Çarşı Merkezi',
    marka: 'Bellapais Mall',
    kategori: 'avm',
    sehir: 'Girne',
    lat: 35.3280,
    lon: 33.3420,
    adres: 'Doğu Çevre Yolu, Çatalköy Girişi, Girne',
    mesafe: '18.5 km',
    sure: '20 dk',
    calismaSaatleri: 'Açık • 09:30 - 22:00',
    olanaklar: ['Otopark', 'Restoranlar', 'Market & Butikler'],
    ikon: Icons.storefront_rounded,
    renk: Color(0xFF8B5CF6),
  ),

  // --- PLAJ, SAHİL & TATİL ---
  const KktcHaritaPoi(
    id: 'poi-plaj-escape',
    ad: 'Escape Beach Club & Koyu',
    marka: 'Escape Beach',
    kategori: 'plaj',
    sehir: 'Girne',
    lat: 35.3520,
    lon: 33.2280,
    adres: 'Yavuz Çıkarma Plajı Yanı, Alsancak, Girne',
    mesafe: '21.0 km',
    sure: '23 dk',
    calismaSaatleri: 'Açık • 09:00 - 19:00',
    olanaklar: ['Kumsal & Şezlong', 'Su Sporları', 'Beach Bar & Restoran', 'Otopark'],
    ikon: Icons.beach_access_rounded,
    renk: Color(0xFF0EA5E9),
  ),
  const KktcHaritaPoi(
    id: 'poi-plaj-glapsides',
    ad: 'Glapsides Halk Plajı & Tesisleri',
    marka: 'Glapsides',
    kategori: 'plaj',
    sehir: 'Gazimağusa',
    lat: 35.1660,
    lon: 33.9180,
    adres: 'Salamis Anayolu Üzeri, Gazimağusa Sahili',
    mesafe: '37.0 km',
    sure: '34 dk',
    calismaSaatleri: 'Açık • 24 Saat (Giriş Ücretsiz)',
    olanaklar: ['Geniş Kumsal', 'Belediye Tesisleri', 'Kamp Alanı', 'Otopark'],
    ikon: Icons.beach_access_rounded,
    renk: Color(0xFF06B6D4),
  ),
  const KktcHaritaPoi(
    id: 'poi-plaj-alagadi',
    ad: 'Alagadi Kaplumbağa Koruma Sahili',
    marka: 'Alagadi Turtle Beach',
    kategori: 'plaj',
    sehir: 'Girne',
    lat: 35.3340,
    lon: 33.4910,
    adres: 'Esentepe Sahil Yolu, Girne',
    mesafe: '28.0 km',
    sure: '29 dk',
    calismaSaatleri: 'Açık • Gün Boyu',
    olanaklar: ['Doğal Sit Alanı', 'Kum Tepeleri', 'Restoran & Büfe'],
    ikon: Icons.beach_access_rounded,
    renk: Color(0xFF10B981),
  ),
  const KktcHaritaPoi(
    id: 'poi-plaj-acapulco',
    ad: 'Acapulco Resort & Sahili',
    marka: 'Acapulco Beach',
    kategori: 'plaj',
    sehir: 'Girne',
    lat: 35.3360,
    lon: 33.4210,
    adres: 'Çatalköy Mevkii, Girne Doğu Sahili',
    mesafe: '23.5 km',
    sure: '25 dk',
    calismaSaatleri: 'Açık • 08:30 - 20:00',
    olanaklar: ['Aquapark', 'Altın Kumsal', 'Havuzlar', 'Geniş Otopark'],
    ikon: Icons.beach_access_rounded,
    renk: Color(0xFFF59E0B),
  ),

  // --- ÜNİVERSİTELER & KAMPÜSLER ---
  const KktcHaritaPoi(
    id: 'poi-uni-dau',
    ad: 'Doğu Akdeniz Üniversitesi (DAÜ) Kampüsü',
    marka: 'DAÜ (EMU)',
    kategori: 'universite',
    sehir: 'Gazimağusa',
    lat: 35.1440,
    lon: 33.9050,
    adres: 'Üniversite Bulvarı, Gazimağusa',
    mesafe: '35.0 km',
    sure: '32 dk',
    calismaSaatleri: 'Açık • 7/24 Kampüs Girişi',
    olanaklar: ['Rektörlük', 'Kütüphane', 'Spor Kompleksi', 'Yurtlar', 'ATM Çarşısı'],
    ikon: Icons.school_rounded,
    renk: Color(0xFF2563EB),
  ),
  const KktcHaritaPoi(
    id: 'poi-uni-ydu',
    ad: 'Yakın Doğu Üniversitesi (YDÜ) Kampüsü',
    marka: 'YDÜ (NEU)',
    kategori: 'universite',
    sehir: 'Lefkoşa',
    lat: 35.2260,
    lon: 33.3280,
    adres: 'Yakın Doğu Bulvarı, Lefkoşa',
    mesafe: '3.5 km',
    sure: '6 dk',
    calismaSaatleri: 'Açık • 7/24 Kampüs Girişi',
    olanaklar: ['Büyük Kütüphane', 'Tıp Fakültesi & Hastane', 'Olimpik Havuz', 'Kongre Sarayı'],
    ikon: Icons.school_rounded,
    renk: Color(0xFFDC2626),
  ),
  const KktcHaritaPoi(
    id: 'poi-uni-odtu',
    ad: 'ODTÜ Kuzey Kıbrıs Kampüsü',
    marka: 'ODTÜ KKK (METU NCC)',
    kategori: 'universite',
    sehir: 'Güzelyurt',
    lat: 35.2440,
    lon: 33.0270,
    adres: 'Kalkanlı Köyü Mevkii, Güzelyurt',
    mesafe: '29.5 km',
    sure: '28 dk',
    calismaSaatleri: 'Açık • 7/24 Kampüs Girişi',
    olanaklar: ['Kütüphane', 'Kültür ve Kongre Merkezi', 'Spor Salonu', 'Öğrenci Yurtları'],
    ikon: Icons.school_rounded,
    renk: Color(0xFFB91C1C),
  ),
  const KktcHaritaPoi(
    id: 'poi-uni-uku',
    ad: 'Uluslararası Kıbrıs Üniversitesi (UKÜ) Kampüsü',
    marka: 'UKÜ (CIU)',
    kategori: 'universite',
    sehir: 'Lefkoşa',
    lat: 35.2160,
    lon: 33.4120,
    adres: 'Haspolat Mevkii, Lefkoşa',
    mesafe: '7.5 km',
    sure: '8 dk',
    calismaSaatleri: 'Açık • 7/24 Kampüs Girişi',
    olanaklar: ['CIU Arena Spor Tesisi', 'Kütüphane', 'Yurtlar', 'Kafe Çarşısı'],
    ikon: Icons.school_rounded,
    renk: Color(0xFFF97316),
  ),
  const KktcHaritaPoi(
    id: 'poi-uni-gau',
    ad: 'Girne Amerikan Üniversitesi (GAÜ) Kampüsü',
    marka: 'GAÜ (GAU)',
    kategori: 'universite',
    sehir: 'Girne',
    lat: 35.3340,
    lon: 33.2790,
    adres: 'Üniversite Yolu, Karaoğlanoğlu, Girne',
    mesafe: '18.2 km',
    sure: '20 dk',
    calismaSaatleri: 'Açık • 7/24 Kampüs Girişi',
    olanaklar: ['Millenium Kompleksi', 'Kütüphane', 'Kafe & Restoranlar'],
    ikon: Icons.school_rounded,
    renk: Color(0xFF0284C7),
  ),

  // --- HAVALİMANI & LİMANLAR ---
  const KktcHaritaPoi(
    id: 'poi-ulasim-ercan',
    ad: 'Yeni Ercan Uluslararası Havalimanı Terminali',
    marka: 'Ercan Havalimanı (ECN)',
    kategori: 'havalimani',
    sehir: 'Lefkoşa',
    lat: 35.1585,
    lon: 33.4980,
    adres: 'Yeni Terminal Binası, Değirmenlik - Ercan Yolu',
    mesafe: '16.5 km',
    sure: '15 dk',
    calismaSaatleri: 'Açık • 7/24 Uçuş & Yolcu Hizmeti',
    olanaklar: ['Çok Katlı Otopark', 'KIBHAS Otobüsleri', 'Gümrüksüz Satış (Duty Free)', 'Taksi Durağı', 'VIP Lounge'],
    ikon: Icons.flight_takeoff_rounded,
    renk: Color(0xFF0284C7),
  ),
  const KktcHaritaPoi(
    id: 'poi-ulasim-girne-liman',
    ad: 'Girne Turizm Limanı & Yolcu Feribot Terminali',
    marka: 'Girne Limanı',
    kategori: 'havalimani',
    sehir: 'Girne',
    lat: 35.3420,
    lon: 33.3280,
    adres: 'Karakum Yolu, Girne Yeni Liman',
    mesafe: '17.2 km',
    sure: '19 dk',
    calismaSaatleri: 'Açık • 7/24 Sefer & Gümrük Hizmeti',
    olanaklar: ['Feribot İskelesi (Taşucu/Mersin)', 'Gümrük & Pasaport', 'Otopark', 'Bilet Satış'],
    ikon: Icons.directions_boat_rounded,
    renk: Color(0xFF0D9488),
  ),
];

// ==========================================
// 🎨 CANLI ROTA ÇİZİM PAINTERI (GOOGLE MAPS GLOWING POLYLINE)
// ==========================================
class KktcRoutePathPainter extends CustomPainter {
  final List<List<double>> coordinates;
  final double centerLon;
  final double centerLat;
  final double zoom;
  final double width;
  final double height;
  final Color routeColor;

  KktcRoutePathPainter({
    required this.coordinates,
    required this.centerLon,
    required this.centerLat,
    required this.zoom,
    required this.width,
    required this.height,
    this.routeColor = const Color(0xFF0284C7),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (coordinates.length < 2) return;
    final int intZoom = zoom.floor();
    final double subScale = math.pow(2.0, zoom - intZoom).toDouble();
    final double tileSize = 256.0 * subScale;

    final double centerTileX = KktcOpenStreetMapTileViewState.lonToTileX(centerLon, intZoom.toDouble());
    final double centerTileY = KktcOpenStreetMapTileViewState.latToTileY(centerLat, intZoom.toDouble());

    final path = Path();
    for (int i = 0; i < coordinates.length; i++) {
      final lat = coordinates[i][0];
      final lon = coordinates[i][1];
      final tx = KktcOpenStreetMapTileViewState.lonToTileX(lon, intZoom.toDouble());
      final ty = KktcOpenStreetMapTileViewState.latToTileY(lat, intZoom.toDouble());
      final px = width / 2.0 + (tx - centerTileX) * tileSize;
      final py = height / 2.0 + (ty - centerTileY) * tileSize;

      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }

    // Dış Parlama / Kontur Efekti
    final glowPaint = Paint()
      ..color = const Color(0xFF0284C7).withValues(alpha: 0.35)
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, glowPaint);

    // İç Canlı Rota Hattı
    final corePaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, corePaint);
  }

  @override
  bool shouldRepaint(covariant KktcRoutePathPainter oldDelegate) {
    return oldDelegate.centerLon != centerLon ||
        oldDelegate.centerLat != centerLat ||
        oldDelegate.zoom != zoom ||
        oldDelegate.coordinates != coordinates;
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
  final List<KktcHaritaPoi>? poiNoktalari;
  final KktcHaritaPoi? seciliPoi;
  final Function(KktcHaritaPoi)? onPoiSelected;
  final bool radarlariGoster;
  final List<List<double>>? rotaKoordinatlari;
  final bool gosterUstBar;
  final List<YolForumBildirimi>? yolBildirimleri;
  final YolForumBildirimi? seciliYolBildirimi;
  final Function(YolForumBildirimi)? onYolBildirimiSelected;
  final double bottomControlPadding;
  final bool gosterZoomButonlari;

  const KktcOpenStreetMapTileView({
    super.key,
    required this.radarlar,
    required this.seciliRadar,
    required this.onRadarSelected,
    this.turkceMi = true,
    this.poiNoktalari,
    this.seciliPoi,
    this.onPoiSelected,
    this.radarlariGoster = true,
    this.rotaKoordinatlari,
    this.gosterUstBar = true,
    this.yolBildirimleri,
    this.seciliYolBildirimi,
    this.onYolBildirimiSelected,
    this.bottomControlPadding = 0.0,
    this.gosterZoomButonlari = true,
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
  double _baseZoom = 9.0;

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

  final CanliGpsServisi _gps = CanliGpsServisi();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _gps.addListener(_onGpsChanged);
    _gps.servisiBaslat();
  }

  void _onGpsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _gps.removeListener(_onGpsChanged);
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
      _zoom = (_zoom + 1.0).clamp(8.0, 16.0);
    });
  }

  void zoomOut() {
    setState(() {
      _zoom = (_zoom - 1.0).clamp(8.0, 16.0);
    });
  }

  void centerOnKktc() {
    setState(() {
      _centerLat = 35.250;
      _centerLon = 33.620;
      _zoom = 9.0;
    });
  }

  void centerOnUserOrKktc() {
    final pos = _gps.sonKonum;
    if (pos != null) {
      flyToLocation(pos.latitude, pos.longitude, zoom: 12.5);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.turkceMi
                ? 'Canlı GPS konumunuza odaklanıldı (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})'
                : 'Centered on live GPS coordinates',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      _gps.servisiBaslat();
      centerOnKktc();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.turkceMi
                ? 'GPS uyduları taranıyor... Harita KKTC merkezine alındı.'
                : 'Scanning GPS satellites... Centered on TRNC.',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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

  Widget _buildCanliGpsKonumIsaretcisi(
    Position pos,
    double width,
    double height,
    double centerTileX,
    double centerTileY,
    double tileSize,
    int intZoom,
  ) {
    final double uTileX = lonToTileX(pos.longitude, intZoom.toDouble());
    final double uTileY = latToTileY(pos.latitude, intZoom.toDouble());

    final double pinX = width / 2.0 + (uTileX - centerTileX) * tileSize;
    final double pinY = height / 2.0 + (uTileY - centerTileY) * tileSize;

    if (pinX < -80 || pinX > width + 80 || pinY < -80 || pinY > height + 80) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: pinX - 32,
      top: pinY - 32,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.navigation_rounded, color: Colors.white, size: 9),
                const SizedBox(width: 3),
                Text(
                  '${_gps.gercekHizKmh.round()} km/s',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          SizedBox(
            width: 36,
            height: 36,
            child: Stack(
              alignment: Alignment.center,
              children: [
                FadeTransition(
                  opacity: _pulseController,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                      border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                    ),
                  ),
                ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0284C7),
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.6),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.circle, color: Colors.white, size: 6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ⛽ POI / BENZİN İSTASYONU & NOKTA İŞARETÇİSİ (Google Maps Tarzı Şık Rozet)
  Widget _buildSinglePoiPin({
    required KktcHaritaPoi poi,
    required bool isSelected,
    required double width,
    required double height,
    required double centerTileX,
    required double centerTileY,
    required double tileSize,
    required int intZoom,
  }) {
    final double pTileX = lonToTileX(poi.lon, intZoom.toDouble());
    final double pTileY = latToTileY(poi.lat, intZoom.toDouble());

    final double pinX = width / 2.0 + (pTileX - centerTileX) * tileSize;
    final double pinY = height / 2.0 + (pTileY - centerTileY) * tileSize;

    if (pinX < -80 || pinX > width + 80 || pinY < -80 || pinY > height + 80) {
      return const SizedBox.shrink();
    }

    final double pinSize = isSelected ? 38.0 : 32.0;

    return Positioned(
      left: pinX - (pinSize / 2.0),
      top: pinY - (pinSize / 2.0),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          widget.onPoiSelected?.call(poi);
          flyToLocation(poi.lat, poi.lon, zoom: math.max(_zoom, 12.8));
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
                      width: pinSize + 18,
                      height: pinSize + 18,
                      decoration: BoxDecoration(
                        color: poi.renk.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                Container(
                  width: pinSize,
                  height: pinSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: poi.renk,
                      width: isSelected ? 3.0 : 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: poi.renk.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      poi.ikon,
                      size: isSelected ? 20 : 17,
                      color: poi.renk,
                    ),
                  ),
                ),
              ],
            ),
            if (isSelected || _zoom >= 12.5) ...[
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? poi.renk : Colors.white24,
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
                  poi.marka.isNotEmpty ? poi.marka : poi.ad.split(' ').first,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                    fontSize: 9.0,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 🚦 YOL FORUMU İŞARETÇİSİ (Çevirme, Kaza, Çalışma Canlı Pinleri)
  Widget _buildSingleYolBildirimiPin({
    required YolForumBildirimi bildirim,
    required bool isSelected,
    required double width,
    required double height,
    required double centerTileX,
    required double centerTileY,
    required double tileSize,
    required int intZoom,
  }) {
    final double pTileX = lonToTileX(bildirim.lon, intZoom.toDouble());
    final double pTileY = latToTileY(bildirim.lat, intZoom.toDouble());

    final double pinX = width / 2.0 + (pTileX - centerTileX) * tileSize;
    final double pinY = height / 2.0 + (pTileY - centerTileY) * tileSize;

    if (pinX < -80 || pinX > width + 80 || pinY < -80 || pinY > height + 80) {
      return const SizedBox.shrink();
    }

    final double pinSize = isSelected ? 40.0 : 34.0;
    final Color pinColor = bildirim.tip.anaRenk;

    return Positioned(
      left: pinX - (pinSize / 2.0),
      top: pinY - (pinSize / 2.0),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          widget.onYolBildirimiSelected?.call(bildirim);
          flyToLocation(bildirim.lat, bildirim.lon, zoom: math.max(_zoom, 12.5));
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                FadeTransition(
                  opacity: _pulseController,
                  child: Container(
                    width: pinSize + (isSelected ? 22 : 14),
                    height: pinSize + (isSelected ? 22 : 14),
                    decoration: BoxDecoration(
                      color: pinColor.withValues(alpha: isSelected ? 0.45 : 0.25),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Container(
                  width: pinSize,
                  height: pinSize,
                  decoration: BoxDecoration(
                    color: pinColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: pinColor.withValues(alpha: 0.55),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      bildirim.tip.ikon,
                      size: isSelected ? 22 : 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            if (isSelected || _zoom >= 10.8) ...[
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? pinColor : Colors.white24,
                    width: isSelected ? 1.5 : 0.7,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      bildirim.tip.baslik,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFFFDE047) : Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (bildirim.yorumlar.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '💬 ${bildirim.yorumlar.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 📍 TEKİL RADAR HIZ TABELASI PİNİ (Zoom seviyesine göre akıllı boyut ve etiket)
  Widget _buildSingleRadarPin({
    required RadarKamerasi radar,
    required bool isSelected,
    required bool showLabel,
    required double width,
    required double height,
    required double centerTileX,
    required double centerTileY,
    required double tileSize,
    required int intZoom,
  }) {
    final double rTileX = lonToTileX(radar.lon, intZoom.toDouble());
    final double rTileY = latToTileY(radar.lat, intZoom.toDouble());

    final double pinX = width / 2.0 + (rTileX - centerTileX) * tileSize;
    final double pinY = height / 2.0 + (rTileY - centerTileY) * tileSize;

    if (pinX < -60 || pinX > width + 60 || pinY < -60 || pinY > height + 60) {
      return const SizedBox.shrink();
    }

    final double circleSize = _zoom < 11.0 ? 25.0 : 28.0;
    final double fontSize = _zoom < 11.0 ? 9.5 : 11.0;

    return Positioned(
      left: pinX - (circleSize / 2.0),
      top: pinY - (circleSize / 2.0),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          widget.onRadarSelected(radar);
          flyToLocation(radar.lat, radar.lon, zoom: math.max(_zoom, 11.8));
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
                      width: circleSize + 16,
                      height: circleSize + 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF0033).withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD90429),
                      width: isSelected ? 3.0 : 2.5,
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
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: const Color(0xFFD90429),
                        fontSize: fontSize,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (showLabel) ...[
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
          ],
        ),
      ),
    );
  }

  // 🏙️ UZAKTAN BAKIŞTA BÖLGESEL KÜMELENME (Clustering - Kalabalığı Önler)
  List<Widget> _buildCityRadarClusters({
    required double width,
    required double height,
    required double centerTileX,
    required double centerTileY,
    required double tileSize,
    required int intZoom,
  }) {
    final cityConfigs = [
      {"name": "Lefkoşa", "lat": 35.195, "lon": 33.340},
      {"name": "Girne", "lat": 35.330, "lon": 33.325},
      {"name": "Gazimağusa", "lat": 35.125, "lon": 33.935},
      {"name": "Güzelyurt", "lat": 35.200, "lon": 32.990},
      {"name": "İskele", "lat": 35.285, "lon": 33.890},
    ];

    List<Widget> clusterWidgets = [];

    for (var cfg in cityConfigs) {
      final name = cfg["name"] as String;
      final cLat = cfg["lat"] as double;
      final cLon = cfg["lon"] as double;

      final count = widget.radarlar.where((r) => r.sehir == name).length;
      if (count == 0) continue;

      final double cTileX = lonToTileX(cLon, intZoom.toDouble());
      final double cTileY = latToTileY(cLat, intZoom.toDouble());

      final double px = width / 2.0 + (cTileX - centerTileX) * tileSize;
      final double py = height / 2.0 + (cTileY - centerTileY) * tileSize;

      if (px < -60 || px > width + 60 || py < -30 || py > height + 30) {
        continue;
      }

      clusterWidgets.add(
        Positioned(
          left: px - 46,
          top: py - 14,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.lightImpact();
              flyToLocation(cLat, cLon, zoom: 11.6);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.radar_rounded, color: Colors.white, size: 10),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$name ($count)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return clusterWidgets;
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
        final bool isKoyuHarita = KktcTemaServisi().isKoyuAktif;
        final String template = _tileProviders[_mapStyleIndex];

        return GestureDetector(
          onScaleStart: (details) {
            _baseZoom = _zoom;
          },
          onScaleUpdate: (details) {
            setState(() {
              // 1. İki parmakla kıstırma / açma ile yakınlaştırma (Pinch-to-zoom)
              if (details.scale != 1.0) {
                final double logScale = math.log(details.scale) / math.ln2;
                _zoom = (_baseZoom + logScale).clamp(8.0, 16.0);
              }

              // 2. Parmakla kaydırma (Pan / Drag)
              final double dxInTiles = -details.focalPointDelta.dx / tileSize;
              final double dyInTiles = -details.focalPointDelta.dy / tileSize;

              final double newCenterTileX = centerTileX + dxInTiles;
              final double newCenterTileY = centerTileY + dyInTiles;

              _centerLon = tileXToLon(newCenterTileX, intZoom.toDouble()).clamp(32.0, 35.0);
              _centerLat = tileYToLat(newCenterTileY, intZoom.toDouble()).clamp(34.4, 36.0);
            });
          },
          onDoubleTap: () {
            HapticFeedback.lightImpact();
            zoomIn();
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
                          child: (isKoyuHarita && _mapStyleIndex == 0)
                              ? ColorFiltered(
                                  colorFilter: const ColorFilter.matrix([
                                    -0.82, 0, 0, 0, 225,
                                    0, -0.82, 0, 0, 225,
                                    0, 0, -0.82, 0, 225,
                                    0, 0, 0, 1, 0,
                                  ]),
                                  child: Image.network(
                                    template
                                        .replaceAll('{z}', '$intZoom')
                                        .replaceAll('{x}', '${((tx % numTiles) + numTiles) % numTiles}')
                                        .replaceAll('{y}', '$ty'),
                                    headers: const {'User-Agent': 'KktcTrafikCezaRadar/1.0'},
                                    fit: BoxFit.fill,
                                    errorBuilder: (c, e, s) => const SizedBox.shrink(),
                                  ),
                                )
                              : Image.network(
                                  template
                                      .replaceAll('{z}', '$intZoom')
                                      .replaceAll('{x}', '${((tx % numTiles) + numTiles) % numTiles}')
                                      .replaceAll('{y}', '$ty'),
                                  headers: const {'User-Agent': 'KktcTrafikCezaRadar/1.0'},
                                  fit: BoxFit.fill,
                                  errorBuilder: (c, e, s) => const SizedBox.shrink(),
                                ),
                        ),

                  // 3. OPENSTREETMAP ŞEHİR İSİM ROZETLERİ (Zoom seviyesine göre akıllı filtreleme)
                  ...osmCityLabels
                      .where((c) => _zoom >= 11.8 || (_zoom >= 10.0 && c.important))
                      .map((c) {
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

                  // 1.9 CANLI ROTA ÇİZGİSİ (YOL TARİFİ)
                  if (widget.rotaKoordinatlari != null && widget.rotaKoordinatlari!.length >= 2)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: KktcRoutePathPainter(
                            coordinates: widget.rotaKoordinatlari!,
                            centerLon: _centerLon,
                            centerLat: _centerLat,
                            zoom: _zoom,
                            width: width,
                            height: height,
                          ),
                        ),
                      ),
                    ),

                  // 1.9 YOL FORUMU İŞARETÇİLERİ (ÇEVİRME, KAZA, ÇALIŞMA)
                  if (widget.yolBildirimleri != null && widget.yolBildirimleri!.isNotEmpty) ...[
                    ...widget.yolBildirimleri!.map((bildirim) {
                      return _buildSingleYolBildirimiPin(
                        bildirim: bildirim,
                        isSelected: widget.seciliYolBildirimi?.id == bildirim.id,
                        width: width,
                        height: height,
                        centerTileX: centerTileX,
                        centerTileY: centerTileY,
                        tileSize: tileSize,
                        intZoom: intZoom,
                      );
                    }),
                  ],

                  // 2. POI İŞARETÇİLERİ (BENZİNLİKLER, SERVİS, OTOPARK, HASTANE)
                  if (widget.poiNoktalari != null && widget.poiNoktalari!.isNotEmpty) ...[
                    ...widget.poiNoktalari!.map((poi) {
                      return _buildSinglePoiPin(
                        poi: poi,
                        isSelected: widget.seciliPoi?.id == poi.id,
                        width: width,
                        height: height,
                        centerTileX: centerTileX,
                        centerTileY: centerTileY,
                        tileSize: tileSize,
                        intZoom: intZoom,
                      );
                    }),
                  ],

                  // 2.1 RADAR İŞARETÇİLERİ (ZOOM SEVİYESİNE GÖRE AKILLI GÖSTERİM)
                  // Kullanıcı uzaktayken (zoom < 10.3) bölgesel küme rozetleri gösterilir;
                  // Yakınlaştıkça (zoom >= 10.3) gerçek radar pinleri detaylanır, kalabalık önlenir.
                  if (widget.radarlariGoster) ...[
                    if (_zoom < 10.3) ...[
                      // 2a. Şehir Bazlı Kümelenmiş Radar Rozetleri (Clustering)
                      ..._buildCityRadarClusters(
                        width: width,
                        height: height,
                        centerTileX: centerTileX,
                        centerTileY: centerTileY,
                        tileSize: tileSize,
                        intZoom: intZoom,
                      ),
                      // 2b. Eğer seçili bir radar varsa, onu açıkça göster
                      if (widget.seciliRadar != null)
                        _buildSingleRadarPin(
                          radar: widget.seciliRadar!,
                          isSelected: true,
                          showLabel: true,
                          width: width,
                          height: height,
                          centerTileX: centerTileX,
                          centerTileY: centerTileY,
                          tileSize: tileSize,
                          intZoom: intZoom,
                        ),
                    ] else ...[
                      // 2c. Yakınlaşınca (zoom >= 10.3) radarlar yol üzerinde tek tek gösterilir
                      ...widget.radarlar.map((radar) {
                        final bool isSelected = widget.seciliRadar?.id == radar.id;
                        // İsim etiketi sadece çok yakınlaşınca (zoom >= 12.2) veya seçili radar için görünür
                        final bool showNameLabel = (_zoom >= 12.2) || isSelected;

                        return _buildSingleRadarPin(
                          radar: radar,
                          isSelected: isSelected,
                          showLabel: showNameLabel,
                          width: width,
                          height: height,
                          centerTileX: centerTileX,
                          centerTileY: centerTileY,
                          tileSize: tileSize,
                          intZoom: intZoom,
                        );
                      }),
                    ],
                  ],

                  // 2.5 GERÇEK KULLANICI CANLI GPS İŞARETÇİSİ
                  if (_gps.sonKonum != null)
                    _buildCanliGpsKonumIsaretcisi(
                      _gps.sonKonum!,
                      width,
                      height,
                      centerTileX,
                      centerTileY,
                      tileSize,
                      intZoom,
                    ),

                  // 3. ÜST BAR & ŞEHİR HIZLI ATLAMA (İSTEĞE BAĞLI GÖSTERİLİR)
                  if (widget.gosterUstBar) ...[
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
                                      decoration: BoxDecoration(
                                        color: _gps.gpsAktif ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      _gps.gpsAktif
                                          ? (_gps.sonKonum != null
                                              ? '🛰️ GPS: ${_gps.gercekHizKmh.round()} km/s'
                                              : '🛰️ GPS Aranıyor...')
                                          : (widget.turkceMi ? 'OpenStreetMap • 18 Radar' : 'OpenStreetMap • 18 Radars'),
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
                          // Canlı GPS Aç/Kapat Butonu
                          GestureDetector(
                            onTap: () {
                              if (_gps.gpsAktif) {
                                _gps.servisiDurdur();
                              } else {
                                _gps.servisiBaslat();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                              decoration: BoxDecoration(
                                color: _gps.gpsAktif
                                    ? const Color(0xFF0284C7).withValues(alpha: 0.85)
                                    : const Color(0xFF0F172A).withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _gps.gpsAktif ? const Color(0xFF38BDF8) : Colors.white24,
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _gps.gpsAktif ? Icons.gps_fixed_rounded : Icons.gps_not_fixed_rounded,
                                    color: _gps.gpsAktif ? Colors.white : const Color(0xFF94A3B8),
                                    size: 12,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    _gps.gpsAktif ? 'Canlı GPS' : 'GPS Başlat',
                                    style: TextStyle(
                                      color: _gps.gpsAktif ? Colors.white : const Color(0xFFCBD5E1),
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w600,
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
                  ],

                  // 5. SAĞ ALT: ZOOM VE MERKEZ KONTROL BUTONLARI (KARTLARLA ÇAKIŞMA ÖNLENİR)
                  if (widget.gosterZoomButonlari)
                    Positioned(
                      bottom: 12 + widget.bottomControlPadding,
                      right: 12,
                      child: Column(
                        children: [
                          _buildFloatingButton(Icons.add_rounded, zoomIn),
                          const SizedBox(height: 6),
                          _buildFloatingButton(Icons.remove_rounded, zoomOut),
                          const SizedBox(height: 6),
                          _buildFloatingButton(
                            Icons.my_location_rounded,
                            centerOnUserOrKktc,
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

  final CanliGpsServisi _gpsServisi = CanliGpsServisi();

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

    _gpsServisi.addListener(_onGpsGuncellendi);
    _gpsServisi.servisiBaslat();

    _speedTimer = Timer.periodic(const Duration(milliseconds: 2800), (t) {
      if (mounted && !_gpsServisi.gpsAktif) {
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

  void _onGpsGuncellendi() {
    if (!mounted) return;
    setState(() {
      if (_gpsServisi.gpsAktif) {
        _canliHiz = _gpsServisi.gercekHizKmh.round();
        if (_gpsServisi.enYakinRadar != null) {
          _seciliRadar = _gpsServisi.enYakinRadar;
        }
      }
    });
  }

  @override
  void dispose() {
    _gpsServisi.removeListener(_onGpsGuncellendi);
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

    final bool hizLimitiAsildi = _canliHiz > secili.hizLimiti;
    final String mesafeGosterim = _gpsServisi.gpsAktif && _gpsServisi.enYakinRadarMesafeFormatli.isNotEmpty
        ? '${_gpsServisi.enYakinRadarMesafeFormatli} ${widget.turkceMi ? 'Kaldı' : 'Ahead'}'
        : (secili.mesafe.isNotEmpty ? '${secili.mesafe} ${widget.turkceMi ? 'Kaldı' : 'Ahead'}' : '350m Kaldı');

    return Scaffold(
      backgroundColor: _RadarHtmlColors.background,
      appBar: Navigator.canPop(context)
          ? AppBar(
              backgroundColor: _RadarHtmlColors.surfaceContainerHigh,
              foregroundColor: _RadarHtmlColors.onSurface,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                widget.turkceMi ? 'KKTC Radarlar & Hız Denetimi' : 'TRNC Radars & Speed Control',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            )
          : null,
      body: Material(
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
                border: hizLimitiAsildi
                    ? Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.6), width: 1.5)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: hizLimitiAsildi
                        ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.25),
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
                                      color: (hizLimitiAsildi ? const Color(0xFFEF4444) : _RadarHtmlColors.primaryContainer).withValues(alpha: 0.3),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: hizLimitiAsildi ? const Color(0xFFEF4444) : _RadarHtmlColors.primaryContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    hizLimitiAsildi ? Icons.warning_rounded : Icons.sensors_rounded,
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
                                          style: TextStyle(
                                            color: hizLimitiAsildi ? const Color(0xFFFCA5A5) : _RadarHtmlColors.primary,
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
                                          mesafeGosterim,
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
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          '${secili.yon} • ${secili.sehir}',
                                          style: const TextStyle(
                                            color: _RadarHtmlColors.secondary,
                                            fontSize: 11,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: _gpsServisi.gpsAktif
                                              ? const Color(0xFF10B981).withValues(alpha: 0.18)
                                              : Colors.white.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _gpsServisi.gpsAktif ? Icons.gps_fixed_rounded : Icons.sensors_rounded,
                                              size: 8.5,
                                              color: _gpsServisi.gpsAktif ? const Color(0xFF10B981) : Colors.white60,
                                            ),
                                            const SizedBox(width: 2.5),
                                            Text(
                                              _gpsServisi.gpsAktif ? 'Canlı GPS' : 'Simülasyon',
                                              style: TextStyle(
                                                color: _gpsServisi.gpsAktif ? const Color(0xFF10B981) : Colors.white70,
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
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
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        color: hizLimitiAsildi ? const Color(0xFFEF4444) : _RadarHtmlColors.tertiary,
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
                      value: (_canliHiz / (secili.hizLimiti * 1.3)).clamp(0.0, 1.0),
                      minHeight: 5,
                      backgroundColor: _RadarHtmlColors.surfaceContainerLowest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        hizLimitiAsildi ? const Color(0xFFEF4444) : _RadarHtmlColors.tertiary,
                      ),
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
    ),
  );
  }
}

// ==========================================
// 🗺️ KKTC TAM EKRAN CANLI RADAR & HARİTA SAYFASI
// ==========================================
class KktcTamEkranHaritaSayfasi extends StatefulWidget {
  final bool turkceMi;
  final RadarKamerasi? baslangicRadari;

  const KktcTamEkranHaritaSayfasi({
    super.key,
    this.turkceMi = true,
    this.baslangicRadari,
  });

  @override
  State<KktcTamEkranHaritaSayfasi> createState() => _KktcTamEkranHaritaSayfasiState();
}

class _KktcTamEkranHaritaSayfasiState extends State<KktcTamEkranHaritaSayfasi> {
  late RadarKamerasi _seciliRadar;
  String _secilenSehir = "Tümü";
  bool _altKartGoster = true;
  int _canliHiz = 68;
  Timer? _telemetriTimer;

  final GlobalKey<KktcOpenStreetMapTileViewState> _osmKey =
      GlobalKey<KktcOpenStreetMapTileViewState>();

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
    _seciliRadar = widget.baslangicRadari ??
        (kktcRadarListesi.isNotEmpty ? kktcRadarListesi.first : const RadarKamerasi(
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _osmKey.currentState?.flyToLocation(_seciliRadar.lat, _seciliRadar.lon, zoom: 12.0);
    });

    _telemetriTimer = Timer.periodic(const Duration(milliseconds: 3200), (t) {
      if (mounted) {
        final speeds = [66, 68, 67, 69, 68];
        setState(() {
          _canliHiz = speeds[t.tick % speeds.length];
        });
      }
    });
  }

  @override
  void dispose() {
    _telemetriTimer?.cancel();
    super.dispose();
  }

  List<RadarKamerasi> get _filtrelenmisRadarlar {
    if (_secilenSehir == "Tümü") return kktcRadarListesi;
    return kktcRadarListesi.where((r) => r.sehir == _secilenSehir).toList();
  }

  void _sehreUc(String sehir) {
    setState(() => _secilenSehir = sehir);
    switch (sehir) {
      case "Lefkoşa":
        _osmKey.currentState?.flyToLocation(35.2132, 33.3350, zoom: 11.5);
        break;
      case "Girne":
        _osmKey.currentState?.flyToLocation(35.3340, 33.3280, zoom: 11.5);
        break;
      case "Gazimağusa":
        _osmKey.currentState?.flyToLocation(35.1250, 33.9400, zoom: 11.5);
        break;
      case "Güzelyurt":
        _osmKey.currentState?.flyToLocation(35.1980, 32.9980, zoom: 11.5);
        break;
      case "İskele":
        _osmKey.currentState?.flyToLocation(35.2850, 33.8900, zoom: 11.5);
        break;
      default:
        _osmKey.currentState?.flyToLocation(35.250, 33.620, zoom: 9.2);
    }
  }

  Future<void> _openGoogleMaps(double lat, double lon) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _yolTarifiAc(RadarKamerasi radar) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => YolTarifiSayfasi(
          turkceMi: widget.turkceMi,
          varisNoktasi: radar.toRotaNoktasi(),
          otomatikNavigasyonBaslat: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hizLimitiAsildi = _canliHiz > _seciliRadar.hizLimiti;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // 1. TAM EKRAN İNTERAKTİF OPENSTREETMAP HARİTASI
          Positioned.fill(
            child: KktcOpenStreetMapTileView(
              key: _osmKey,
              radarlar: _filtrelenmisRadarlar,
              seciliRadar: _seciliRadar,
              turkceMi: widget.turkceMi,
              onRadarSelected: (radar) {
                setState(() {
                  _seciliRadar = radar;
                  _altKartGoster = true;
                });
                _osmKey.currentState?.flyToLocation(radar.lat, radar.lon, zoom: 12.0);
              },
            ),
          ),

          // 2. ÜST YÜZEN BAŞLIK & KONTROL ŞERİDİ
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Geri Dön Butonu
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Başlık ve GPS Durumu
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.turkceMi ? 'KKTC Canlı Radar Haritası' : 'TRNC Live Speed Cameras',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.turkceMi ? 'Canlı GPS Aktif • ${_filtrelenmisRadarlar.length} Kamera' : 'Live GPS Active • ${_filtrelenmisRadarlar.length} Cameras',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 🗺️ YOL TARİFİ KISAYOL BUTONU
                      InkWell(
                        onTap: () => _yolTarifiAc(_seciliRadar),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.directions_rounded, color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                widget.turkceMi ? 'Yol Tarifi' : 'Route',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Şehir Filtre Hapları (Yatay Kaydırılabilir)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _sehirler.map((sehir) {
                      final bool isSelected = _secilenSehir == sehir;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          onTap: () => _sehreUc(sehir),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF1A73E8)
                                  : const Color(0xFF0F172A).withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : Colors.white.withValues(alpha: 0.20),
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF1A73E8).withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              sehir,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // 3. SOL ÜST: YÜZEN HIZ HUD KARTİ
          Positioned(
            top: MediaQuery.of(context).padding.top + 98,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hizLimitiAsildi
                      ? const Color(0xFFEF4444)
                      : Colors.white.withValues(alpha: 0.15),
                  width: hizLimitiAsildi ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.turkceMi ? 'HIZINIZ' : 'SPEED',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.70),
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$_canliHiz',
                            style: TextStyle(
                              color: hizLimitiAsildi ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'km/s',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.70),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFDC2626), width: 2.2),
                    ),
                    child: Center(
                      child: Text(
                        '${_seciliRadar.hizLimiti}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. SAĞ ÜST: YÜZEN HARİTA ARAÇLARI
          Positioned(
            top: MediaQuery.of(context).padding.top + 98,
            right: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFloatingTool(
                  icon: Icons.layers_rounded,
                  tooltip: 'Katman Değiştir',
                  onTap: () => _osmKey.currentState?.toggleMapStyle(),
                ),
                const SizedBox(height: 6),
                _buildFloatingTool(
                  icon: Icons.my_location_rounded,
                  tooltip: 'Konumuma Git',
                  onTap: () => _osmKey.currentState?.centerOnUserOrKktc(),
                ),
                const SizedBox(height: 6),
                _buildFloatingTool(
                  icon: Icons.add_rounded,
                  tooltip: 'Yakınlaştır',
                  onTap: () => _osmKey.currentState?.zoomIn(),
                ),
                const SizedBox(height: 6),
                _buildFloatingTool(
                  icon: Icons.remove_rounded,
                  tooltip: 'Uzaklaştır',
                  onTap: () => _osmKey.currentState?.zoomOut(),
                ),
              ],
            ),
          ),

          // 5. ALT: SEÇİLİ RADAR KARTI VE AKSİYONLAR
          if (_altKartGoster)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.50),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Kart Üst Başlık & Kapat Butonu
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hız Sınırı Yuvarlak Tabelası
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFDC2626), width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFDC2626).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${_seciliRadar.hizLimiti}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Radar Bilgisi
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      _seciliRadar.ad,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _seciliRadar.mesafe.isNotEmpty ? _seciliRadar.mesafe : '350m',
                                      style: const TextStyle(
                                        color: Color(0xFF10B981),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${_seciliRadar.sehir} • ${_seciliRadar.yon} • ${_seciliRadar.tur}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.70),
                                  fontSize: 11.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Kapatma İkonu
                        InkWell(
                          onTap: () => setState(() => _altKartGoster = false),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded, color: Colors.white70, size: 16),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // İki Büyük Aksiyon Butonu: 1. Yol Tarifi Al, 2. Google Maps ile Git
                    Row(
                      children: [
                        // Yol Tarifi Al (Canlı Rota)
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              elevation: 2,
                            ),
                            onPressed: () => _yolTarifiAc(_seciliRadar),
                            icon: const Icon(Icons.directions_rounded, size: 18),
                            label: Text(
                              widget.turkceMi ? 'Yol Tarifi Al' : 'Get Directions',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Google Maps ile Aç
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A73E8),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              elevation: 2,
                            ),
                            onPressed: () => _openGoogleMaps(_seciliRadar.lat, _seciliRadar.lon),
                            icon: const Icon(Icons.location_on_rounded, size: 18),
                            label: const Text(
                              'Google Maps',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            // Kart Kapalıyken Yeniden Açma Hapı
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 12,
              right: 12,
              child: InkWell(
                onTap: () => setState(() => _altKartGoster = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.radar_rounded, color: Color(0xFFD97706), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        _seciliRadar.ad,
                        style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingTool({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 19),
      ),
    );
  }
}
