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
// 🗺️ RADAR VE KAMERA HARİTASI SAYFASI
// ==========================================
class RadarHaritasiSayfasi extends StatefulWidget {
  final bool turkceMi;

  const RadarHaritasiSayfasi({super.key, required this.turkceMi});

  @override
  State<RadarHaritasiSayfasi> createState() => _RadarHaritasiSayfasiState();
}

class _RadarHaritasiSayfasiState extends State<RadarHaritasiSayfasi> with SingleTickerProviderStateMixin {
  String _secilenSehir = "Tümü";
  String _aramaMetni = "";
  bool _haritaGorunumu = true; // true = Harita, false = Liste
  RadarKamerasi? _seciliRadar;
  bool _canliUyariAktif = false;
  late AnimationController _pulseController;

  final TransformationController _transformController = TransformationController();

  final List<String> _sehirler = [
    "Tümü",
    "Lefkoşa",
    "Girne",
    "Gazimağusa",
    "Güzelyurt",
    "İskele",
    "Lefke",
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Varsayılan olarak ilk radarı seç
    if (kktcRadarListesi.isNotEmpty) {
      _seciliRadar = kktcRadarListesi.first;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _transformController.dispose();
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

  void _radaraOdaklan(RadarKamerasi radar) {
    setState(() {
      _seciliRadar = radar;
      _haritaGorunumu = true;
    });

    // Harita merkezini radara kaydırma simülasyonu
    _detaySheetGoster(radar);
  }

  void _detaySheetGoster(RadarKamerasi radar) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _RadarDetayKarti(
        radar: radar,
        turkceMi: widget.turkceMi,
        onYaklasikUyariToggle: (val) {
          setState(() {
            _canliUyariAktif = val;
          });
        },
        canliUyariAktif: _canliUyariAktif,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var radarlar = _filtrelenmisRadarlar;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.turkceMi ? 'KKTC Radar & Kamera Haritası' : 'TRNC Radar & Speed Cameras',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            Text(
              widget.turkceMi
                  ? '${radarlar.length} Sabit Hız Tespit Kamerası Aktif'
                  : '${radarlar.length} Fixed Speed Cameras Active',
              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          // Harita / Liste Değiştirici
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _gorunumButon(
                  ikon: Icons.map_rounded,
                  secili: _haritaGorunumu,
                  onTap: () => setState(() => _haritaGorunumu = true),
                ),
                _gorunumButon(
                  ikon: Icons.format_list_bulleted_rounded,
                  secili: !_haritaGorunumu,
                  onTap: () => setState(() => _haritaGorunumu = false),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔎 Arama ve Şehir Filtresi Barı
          Container(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
            color: const Color(0xFF0F172A),
            child: Column(
              children: [
                // Arama Kutusu
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => _aramaMetni = val),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: widget.turkceMi
                          ? 'Radar veya anayol ara (Örn: Boğaz, Gönyeli, DAÜ)...'
                          : 'Search camera or road (e.g. Bogaz, Gonyeli)...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Şehir Kapsülleri
                SizedBox(
                  height: 34,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _sehirler.length,
                    itemBuilder: (context, index) {
                      String sehir = _sehirler[index];
                      bool secili = _secilenSehir == sehir;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _secilenSehir = sehir),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: secili ? const Color(0xFFDC2626) : Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: secili ? const Color(0xFFDC2626) : Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            child: Text(
                              sehir,
                              style: TextStyle(
                                color: secili ? Colors.white : Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                                fontWeight: secili ? FontWeight.w800 : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ⚠️ Canlı Sürüş & Radar Algılama Simülasyonu Banner'ı
          if (_canliUyariAktif)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.turkceMi ? '🚨 RADAR UYARISI: 350m Kaldı!' : '🚨 RADAR ALERT: 350m Ahead!',
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          widget.turkceMi
                              ? 'Boğaz Yolu Radarı • Hız Sınırı: 65 km/s'
                              : 'Bogaz Road Camera • Speed Limit: 65 km/h',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                    onPressed: () => setState(() => _canliUyariAktif = false),
                  ),
                ],
              ),
            ),

          // 🗺️ ANA İÇERİK: HARİTA VEYA LİSTE
          Expanded(
            child: _haritaGorunumu
                ? _haritaKapsayici(radarlar)
                : _listeKapsayici(radarlar),
          ),
        ],
      ),
    );
  }

  Widget _gorunumButon({required IconData ikon, required bool secili, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: secili ? const Color(0xFFDC2626) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(ikon, size: 18, color: secili ? Colors.white : Colors.white70),
      ),
    );
  }

  // --- HARİTA GÖRÜNÜMÜ ---
  Widget _haritaKapsayici(List<RadarKamerasi> radarlar) {
    return Stack(
      children: [
        // İnteraktif Yakınlaştırılabilir & Kaydırılabilir Harita Tuvali
        InteractiveViewer(
          transformationController: _transformController,
          minScale: 0.8,
          maxScale: 3.5,
          boundaryMargin: const EdgeInsets.all(80),
          child: SizedBox(
            width: 1200,
            height: 800,
            child: Stack(
              children: [
                // Arka Plan Kıbrıs Vektörel Harita Çizimi
                Positioned.fill(
                  child: CustomPaint(
                    painter: KktcHaritaPainter(),
                  ),
                ),

                // Harita Üzerindeki Şehir Etiketleri
                _sehirPin(ad: "Lefkoşa", x: 0.40, y: 0.52),
                _sehirPin(ad: "Girne", x: 0.38, y: 0.34),
                _sehirPin(ad: "Gazimağusa", x: 0.69, y: 0.53),
                _sehirPin(ad: "Güzelyurt", x: 0.25, y: 0.52),
                _sehirPin(ad: "İskele", x: 0.72, y: 0.43),
                _sehirPin(ad: "Lefke", x: 0.14, y: 0.60),
                _sehirPin(ad: "Dipkarpaz", x: 0.90, y: 0.24),

                // Radar & Hız Kamerası Pinleri
                ...radarlar.map((radar) {
                  bool secili = _seciliRadar?.id == radar.id;
                  return Positioned(
                    left: radar.mapX * 1200 - 24,
                    top: radar.mapY * 800 - 24,
                    child: GestureDetector(
                      onTap: () => _radaraOdaklan(radar),
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          double pulse = secili ? (math.sin(_pulseController.value * 2 * math.pi) * 4) : 0;
                          return Container(
                            padding: const EdgeInsets.all(4),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 38 + pulse,
                                  height: 38 + pulse,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFDC2626),
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFDC2626).withValues(alpha: secili ? 0.6 : 0.3),
                                        blurRadius: secili ? 16 : 8,
                                        spreadRadius: secili ? 4 : 1,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${radar.hizLimiti}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    radar.ad,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // 🧭 Harita Kontrolleri (Sağ Üst: Sıfırla, Yaklaş, Uzaklaş)
        Positioned(
          top: 14,
          right: 14,
          child: Column(
            children: [
              _haritaAyarButon(
                ikon: Icons.add,
                onTap: () {
                  _transformController.value = _transformController.value * Matrix4.diagonal3Values(1.2, 1.2, 1.0);
                },
              ),
              const SizedBox(height: 6),
              _haritaAyarButon(
                ikon: Icons.remove,
                onTap: () {
                  _transformController.value = _transformController.value * Matrix4.diagonal3Values(0.8, 0.8, 1.0);
                },
              ),
              const SizedBox(height: 6),
              _haritaAyarButon(
                ikon: Icons.center_focus_strong_rounded,
                onTap: () {
                  _transformController.value = Matrix4.identity();
                },
              ),
            ],
          ),
        ),

        // 📍 Seçili Radar Alt Bilgi Kapsülü (Harita Modu)
        if (_seciliRadar != null)
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => _detaySheetGoster(_seciliRadar!),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Hız Levhası İkonu
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFDC2626), width: 4.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFDC2626).withValues(alpha: 0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${_seciliRadar!.hizLimiti}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Radar Başlık & Detay
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _seciliRadar!.sehir,
                                style: const TextStyle(
                                  color: Color(0xFF38BDF8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.white38,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _seciliRadar!.tur,
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.turkceMi ? _seciliRadar!.ad : _seciliRadar!.adEn,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _seciliRadar!.yon,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Detay Butonu
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Text(
                            widget.turkceMi ? 'Detay' : 'Info',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _sehirPin({required String ad, required double x, required double y}) {
    return Positioned(
      left: x * 1200 - 30,
      top: y * 800 - 10,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF38BDF8),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                ad,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _haritaAyarButon({required IconData ikon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Icon(ikon, color: Colors.white, size: 18),
      ),
    );
  }

  // --- LİSTE GÖRÜNÜMÜ ---
  Widget _listeKapsayici(List<RadarKamerasi> radarlar) {
    if (radarlar.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.radar_rounded, size: 48, color: Colors.white38),
            const SizedBox(height: 12),
            Text(
              widget.turkceMi ? 'Aramanıza uygun radar kamerası bulunamadı.' : 'No speed cameras matching your query.',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: radarlar.length,
      itemBuilder: (context, index) {
        final radar = radarlar[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDC2626), width: 4),
              ),
              child: Center(
                child: Text(
                  '${radar.hizLimiti}',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ),
            title: Text(
              widget.turkceMi ? radar.ad : radar.adEn,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${radar.sehir} • ${radar.tur}',
                  style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  radar.yon,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
              onPressed: () => _radaraOdaklan(radar),
            ),
            onTap: () => _detaySheetGoster(radar),
          ),
        );
      },
    );
  }
}

// ==========================================
// 🎨 KKTC VEKTÖREL HARİTA ÇİZİCİ (CUSTOM PAINTER)
// ==========================================
class KktcHaritaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 🌊 Akdeniz Zemin
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0F172A), Color(0xFF0369A1), Color(0xFF0284C7), Color(0xFF0C4A6E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Grid Çizgileri (Deniz Haritası Koordinat Izgarası)
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 60) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double j = 0; j < size.height; j += 60) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), gridPaint);
    }

    // 🏝️ KKTC ve Kıbrıs Kara Parçası Silueti
    final landPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    final landBorderPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

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

    // 🛣️ Ana Karayolu Ağı (Glow & Çizgi)
    final roadGlowPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    final roadPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final Path highwayPath = Path();

    // Lefkoşa - Girne Anayolu
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
    highwayPath.lineTo(size.width * 0.25, size.height * 0.52);
    highwayPath.lineTo(size.width * 0.14, size.height * 0.60); // Lefke

    // Girne - Alsancak Sahil Yolu
    highwayPath.moveTo(size.width * 0.38, size.height * 0.34);
    highwayPath.lineTo(size.width * 0.30, size.height * 0.34);

    // Gazimağusa - İskele - Karpaz Sahil Yolu
    highwayPath.moveTo(size.width * 0.69, size.height * 0.53);
    highwayPath.lineTo(size.width * 0.72, size.height * 0.43);
    highwayPath.lineTo(size.width * 0.85, size.height * 0.28);
    highwayPath.lineTo(size.width * 0.94, size.height * 0.20);

    canvas.drawPath(highwayPath, roadGlowPaint);
    canvas.drawPath(highwayPath, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==========================================
// 📌 RADAR DETAY BOTTOM SHEET
// ==========================================
class _RadarDetayKarti extends StatelessWidget {
  final RadarKamerasi radar;
  final bool turkceMi;
  final Function(bool) onYaklasikUyariToggle;
  final bool canliUyariAktif;

  const _RadarDetayKarti({
    required this.radar,
    required this.turkceMi,
    required this.onYaklasikUyariToggle,
    required this.canliUyariAktif,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Çekmece Çizgisi
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Başlık & Hız Levhası
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFDC2626), width: 5.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFDC2626).withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${radar.hizLimiti}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${radar.sehir} • ${radar.tur}',
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      turkceMi ? radar.ad : radar.adEn,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      radar.id,
                      style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white12),

          // Bilgiler Tablosu
          _bilgiSatiri(
            ikon: Icons.navigation_rounded,
            baslik: turkceMi ? 'Denetim İstikameti' : 'Direction',
            deger: turkceMi ? radar.yon : radar.yonEn,
          ),
          _bilgiSatiri(
            ikon: Icons.place_rounded,
            baslik: turkceMi ? 'Konum Detayı' : 'Location Note',
            deger: turkceMi ? radar.aciklama : radar.aciklamaEn,
          ),
          _bilgiSatiri(
            ikon: Icons.speed_rounded,
            baslik: turkceMi ? 'Hız Sınırı' : 'Speed Limit',
            deger: '${radar.hizLimiti} km/s (Sabit Hız Radarı)',
          ),
          _bilgiSatiri(
            ikon: Icons.verified_rounded,
            baslik: turkceMi ? 'Kamera Durumu' : 'Camera Status',
            deger: radar.aktif ? (turkceMi ? '🟢 Aktif / Çift Yön Kayıt' : '🟢 Active') : '🔴 Bakımda',
          ),
          const SizedBox(height: 16),

          // Sesli Uyarı Simülasyonu Butonu
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.notifications_active_rounded, color: Color(0xFFF59E0B), size: 22),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          turkceMi ? 'Yaklaşınca Sesli Uyar' : 'Proximity Voice Alert',
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          turkceMi ? '500 metre kala hız uyarısı verir' : 'Alerts 500m before radar',
                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
                Switch(
                  activeThumbColor: const Color(0xFFDC2626),
                  value: canliUyariAktif,
                  onChanged: (val) {
                    onYaklasikUyariToggle(val);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Buton: Kapat
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                turkceMi ? 'Haritada İncelemeye Devam Et' : 'Continue on Map',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bilgiSatiri({required IconData ikon, required String baslik, required String deger}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, color: const Color(0xFF94A3B8), size: 18),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(
              baslik,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              deger,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
