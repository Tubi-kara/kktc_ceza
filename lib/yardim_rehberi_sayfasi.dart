import 'package:flutter/material.dart';

// ==========================================
// 🎨 YARDIM VE REHBER SAYFASI TASARIM TOKENLARI
// ==========================================
class HelpColors {
  static const Color background = Color(0xFF0A122A);
  static const Color surfaceContainer = Color(0xFF171E37);
  static const Color surfaceContainerLow = Color(0xFF131A33);
  static const Color surfaceContainerLowest = Color(0xFF050D25);
  static const Color surfaceContainerHigh = Color(0xFF212942);
  static const Color surfaceContainerHighest = Color(0xFF2C344D);
  static const Color primaryContainer = Color(0xFFD90429); // KKTC Crimson
  static const Color primary = Color(0xFFFFB3AF);
  static const Color secondary = Color(0xFFBDC5E9);
  static const Color tertiary = Color(0xFF4EDEA3); // Emerald
  static const Color tertiaryContainer = Color(0xFF007C55);
  static const Color onSurface = Color(0xFFDBE1FF);
  static const Color warning = Color(0xFFFFB800);
}

// ==========================================
// 🧭 POPÜLER ROTA REHBERİ MODELİ
// ==========================================
class PopulerRotaRehberi {
  final String baslik;
  final String baslikEn;
  final String baslangicId;
  final String varisId;
  final String baslangicAdi;
  final String varisAdi;
  final String mesafe;
  final String sure;
  final int radarSayisi;
  final String oneriMetni;
  final String oneriMetniEn;
  final List<String> pufNoktalari;
  final List<String> pufNoktalariEn;
  final IconData ikon;

  const PopulerRotaRehberi({
    required this.baslik,
    required this.baslikEn,
    required this.baslangicId,
    required this.varisId,
    required this.baslangicAdi,
    required this.varisAdi,
    required this.mesafe,
    required this.sure,
    required this.radarSayisi,
    required this.oneriMetni,
    required this.oneriMetniEn,
    required this.pufNoktalari,
    required this.pufNoktalariEn,
    required this.ikon,
  });
}

// ==========================================
// 🚀 ANA YARDIM VE AKILLI ROTA REHBERİ SAYFASI
// ==========================================
class YardimRehberiSayfasi extends StatefulWidget {
  final bool turkceMi;
  final Function(String baslangicId, String varisId)? onRotayiAc;

  const YardimRehberiSayfasi({
    super.key,
    required this.turkceMi,
    this.onRotayiAc,
  });

  @override
  State<YardimRehberiSayfasi> createState() => _YardimRehberiSayfasiState();
}

class _YardimRehberiSayfasiState extends State<YardimRehberiSayfasi>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _aramaController = TextEditingController();
  String _aramaKelimesi = '';

  final List<PopulerRotaRehberi> _rehberRotalar = const [
    PopulerRotaRehberi(
      baslik: "Güzelyurt ➔ Gönyeli Çemberi & Lefkoşa",
      baslikEn: "Guzelyurt ➔ Gonyeli Circle & Lefkosa",
      baslangicId: "guzelyurt_merkez",
      varisId: "gonyeli_cemberi",
      baslangicAdi: "Güzelyurt Merkez",
      varisAdi: "Gönyeli Çemberi",
      mesafe: "32.5 km",
      sure: "~28 dk",
      radarSayisi: 3,
      ikon: Icons.directions_car_rounded,
      oneriMetni:
          "Güzelyurt - Lefkoşa çift şerit anayolunu takip ederek doğrudan Gönyeli Çemberi'ne bağlanın. Yılmazköy ve Alayköy mevkilerinde hız denetimleri bulunmaktadır.",
      oneriMetniEn:
          "Follow dual carriageway from Guzelyurt directly to Gonyeli Roundabout. Watch for speed checks near Yilmazkoy and Alaykoy.",
      pufNoktalari: [
        "Mevlevi ve Yılmazköy düzlüklerinde 75 km/s hız limitine dikkat edin.",
        "Gönyeli girişindeki çemberde yoğun saatlerde şerit takibini erken yapın.",
      ],
      pufNoktalariEn: [
        "Maintain 75 km/h limit on Yilmazkoy straight.",
        "Prepare lane position early when approaching Gonyeli Roundabout.",
      ],
    ),
    PopulerRotaRehberi(
      baslik: "Girne Limanı ➔ Lefkoşa Dereboyu",
      baslikEn: "Kyrenia Harbor ➔ Lefkosa Dereboyu",
      baslangicId: "girne_liman",
      varisId: "lefkosa_dereboyu",
      baslangicAdi: "Girne Liman Kavşağı",
      varisAdi: "Lefkoşa Dereboyu",
      mesafe: "26.4 km",
      sure: "~25 dk",
      radarSayisi: 3,
      ikon: Icons.alt_route_rounded,
      oneriMetni:
          "Girne - Lefkoşa dağ yolunu tırmanarak Boğaz üzerinden Lefkoşa'ya inin. Boğaz Alpet dinlenme tesisi ve Gönyeli girişi bu aks üzerindedir.",
      oneriMetniEn:
          "Ascend mountain highway via Bogaz down into Lefkosa. Bogaz rest area and Gonyeli entry are along this corridor.",
      pufNoktalari: [
        "Dağ yolu inişinde virajlara dikkat edin ve takip mesafesini koruyun.",
        "Boğaz mevkisinde sabit hız radarı bulunmaktadır (65 km/s).",
      ],
      pufNoktalariEn: [
        "Take care on mountain descent curves and maintain braking distance.",
        "Fixed 65 km/h speed camera operates at Bogaz section.",
      ],
    ),
    PopulerRotaRehberi(
      baslik: "Lefkoşa Dereboyu ➔ Ercan Yeni Havalimanı",
      baslikEn: "Lefkosa Dereboyu ➔ Ercan International Airport",
      baslangicId: "lefkosa_dereboyu",
      varisId: "ercan_havalimani",
      baslangicAdi: "Lefkoşa Dereboyu",
      varisAdi: "Ercan Yeni Havalimanı",
      mesafe: "24.8 km",
      sure: "~25 dk",
      radarSayisi: 3,
      ikon: Icons.flight_takeoff_rounded,
      oneriMetni:
          "Hamitköy Çemberi üzerinden Mağusa anayoluna çıkıp Demirhan yonca kavşağından Ercan yeni terminal yoluna bağlanın. Geniş bölünmüş yoldur.",
      oneriMetniEn:
          "Take Famagusta highway via Hamitkoy roundabout, then use Demirhan cloverleaf junction into new Ercan terminal boulevard.",
      pufNoktalari: [
        "Haspolat ve Demirhan yolunda 75 km/s sabit radarlar bulunmaktadır.",
        "Yeni Ercan terminal bulvarında hız limiti 90 km/s'e kadar çıkmaktadır.",
        "Uçuştan en az 2 saat önce havalimanında olunması tavsiye edilir.",
      ],
      pufNoktalariEn: [
        "Active 75 km/h cameras near Haspolat and Demirhan.",
        "New airport boulevard allows up to 90 km/h speed limit.",
        "Arriving at airport 2 hours before flight is advised.",
      ],
    ),
    PopulerRotaRehberi(
      baslik: "Lefkoşa Gönyeli ➔ Gazimağusa Girişi",
      baslikEn: "Lefkosa Gonyeli ➔ Famagusta Entry",
      baslangicId: "gonyeli_cemberi",
      varisId: "poi-altinbas-magusa",
      baslangicAdi: "Gönyeli Çemberi",
      varisAdi: "Altınbaş Mağusa Girişi",
      mesafe: "61.0 km",
      sure: "~50 dk",
      radarSayisi: 4,
      ikon: Icons.local_gas_station_rounded,
      oneriMetni:
          "Kuzey Çevre Yolu veya Hamitköy üzerinden Lefkoşa - Gazimağusa bölünmüş anayolunu kesintisiz takip edin. Dörtyol ve İnönü kavşaklarında radar kameraları mevcuttur.",
      oneriMetniEn:
          "Take Lefkosa - Famagusta highway via North Bypass or Hamitkoy. Watch for radar cameras at Dortyol and Inonu junctions.",
      pufNoktalari: [
        "Dörtyol ve Korkuteli mevkilerindeki hız sınırlarına dikkat edin.",
        "Gazimağusa girişinde Altınbaş ve K-Pet istasyonları yakıt ikmali için açıktır.",
      ],
      pufNoktalariEn: [
        "Observe speed limits at Dortyol and Korkuteli junctions.",
        "Altinbas and K-Pet gas stations are available upon entering Famagusta.",
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _aramaController.dispose();
    _sssSearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HelpColors.background,
      appBar: AppBar(
        backgroundColor: HelpColors.surfaceContainerLow,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: HelpColors.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: HelpColors.tertiary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.support_agent_rounded, color: HelpColors.tertiary, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.turkceMi ? 'Yardım & Rota Rehberi' : 'Help & Route Guide',
                  style: const TextStyle(
                    color: HelpColors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  widget.turkceMi ? 'Nasıl gidilir? Kurallar & Acil hatlar' : 'Directions, Traffic Rules & SOS',
                  style: const TextStyle(color: HelpColors.secondary, fontSize: 10.5),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: HelpColors.surfaceContainerLowest,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: HelpColors.tertiary,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: HelpColors.secondary,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              tabs: [
                Tab(
                  iconMargin: EdgeInsets.zero,
                  child: Row(
                    children: [
                      const Icon(Icons.alt_route_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text(widget.turkceMi ? 'Nasıl Giderim?' : 'Directions'),
                    ],
                  ),
                ),
                Tab(
                  iconMargin: EdgeInsets.zero,
                  child: Row(
                    children: [
                      const Icon(Icons.rule_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text(widget.turkceMi ? 'KKTC Kuralları' : 'Traffic Rules'),
                    ],
                  ),
                ),
                Tab(
                  iconMargin: EdgeInsets.zero,
                  child: Row(
                    children: [
                      const Icon(Icons.emergency_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text(widget.turkceMi ? 'Acil Yardım' : 'Emergency'),
                    ],
                  ),
                ),
                Tab(
                  iconMargin: EdgeInsets.zero,
                  child: Row(
                    children: [
                      const Icon(Icons.quiz_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text(widget.turkceMi ? 'Sık Sorulanlar' : 'FAQs'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNasilGiderimSekmesi(),
          _buildKktcKurallariSekmesi(),
          _buildAcilYardimSekmesi(),
          _buildSssSekmesi(),
        ],
      ),
    );
  }

  // ==========================================
  // 🧭 1. SEKME: NASIL GİDERİM? (ROTA REHBERLERİ)
  // ==========================================
  Widget _buildNasilGiderimSekmesi() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Arama Kutusu
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: HelpColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: TextField(
            controller: _aramaController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            onChanged: (v) => setState(() => _aramaKelimesi = v),
            decoration: InputDecoration(
              icon: const Icon(Icons.search_rounded, color: HelpColors.tertiary, size: 20),
              hintText: widget.turkceMi
                  ? 'Nereye gitmek istiyorsunuz? (örn: Erülkü, Lapta, Ercan...)'
                  : 'Search destination (e.g. Erulku, Lapta, Ercan...)',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Başlık Bannerı
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                HelpColors.tertiaryContainer.withValues(alpha: 0.35),
                HelpColors.surfaceContainerHigh,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HelpColors.tertiary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded, color: HelpColors.tertiary, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.turkceMi ? 'Akıllı Yol Tavsiyeleri' : 'Smart Driving Advice',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.turkceMi
                          ? 'KKTC yollarında radarlara ve çember tıkanıklıklarına takılmadan en kolay güzergahlar:'
                          : 'Top hassle-free routes bypassing speed cameras and heavy roundabouts:',
                      style: const TextStyle(color: HelpColors.secondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Rota Kartları
        ..._rehberRotalar.where((r) {
          if (_aramaKelimesi.trim().isEmpty) return true;
          final q = _aramaKelimesi.toLowerCase();
          return r.baslik.toLowerCase().contains(q) ||
              r.baslikEn.toLowerCase().contains(q) ||
              r.oneriMetni.toLowerCase().contains(q) ||
              r.baslangicAdi.toLowerCase().contains(q) ||
              r.varisAdi.toLowerCase().contains(q);
        }).map((r) => _buildRotaRehberKarti(r)),
      ],
    );
  }

  Widget _buildRotaRehberKarti(PopulerRotaRehberi rota) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: HelpColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kart Başlığı
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: HelpColors.primaryContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(rota.ikon, color: HelpColors.primaryContainer, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.turkceMi ? rota.baslik : rota.baslikEn,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${rota.mesafe} • ${rota.sure} • ${rota.radarSayisi} ${widget.turkceMi ? 'Radar' : 'Cameras'}",
                        style: const TextStyle(color: HelpColors.tertiary, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white10, height: 1),

          // Tavsiye Açıklaması
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Text(
              widget.turkceMi ? rota.oneriMetni : rota.oneriMetniEn,
              style: const TextStyle(color: HelpColors.onSurface, fontSize: 12, height: 1.4),
            ),
          ),

          // Püf Noktaları
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: (widget.turkceMi ? rota.pufNoktalari : rota.pufNoktalariEn).map((puf) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("💡 ", style: TextStyle(fontSize: 12)),
                      Expanded(
                        child: Text(
                          puf,
                          style: TextStyle(color: HelpColors.secondary.withValues(alpha: 0.9), fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 6),

          // Buton: Bu Rotayı Aç
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: HelpColors.tertiaryContainer,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                ),
                onPressed: () {
                  if (widget.onRotayiAc != null) {
                    widget.onRotayiAc!(rota.baslangicId, rota.varisId);
                  } else {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.alt_route_rounded, size: 18),
                label: Text(
                  widget.turkceMi ? '🗺️ Bu Rotayı Yol Tarifinde Aç' : '🗺️ Open Route in Navigation',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 🚗 2. SEKME: KKTC TRAFİK VE SÜRÜŞ KURALLARI
  // ==========================================
  Widget _buildKktcKurallariSekmesi() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildKuralKarti(
          ikon: Icons.swap_horiz_rounded,
          ikonRenk: HelpColors.tertiary,
          baslik: widget.turkceMi ? '🇬🇧 Soldan Akan Trafik & Çemberler' : 'Left-Hand Traffic & Roundabouts',
          icerik: widget.turkceMi
              ? "• Kuzey Kıbrıs'ta trafik SOLDAN akar, direksiyon sağdadır.\n"
                  "• ÇEMBERLERE (Döner Kavşaklara) girerken DAİMA SAĞDAN gelen araca yol verilir!\n"
                  "• Çemberin içindeki araç geçiş üstünlüğüne sahiptir. Giriş yapmadan önce sağ tarafı kontrol edin."
              : "• Traffic drives on the LEFT side of the road in Northern Cyprus.\n"
                  "• In ROUNDABOUTS, you MUST always give way to traffic coming from your RIGHT!\n"
                  "• Vehicles already circulating inside the roundabout have full right of way.",
        ),
        _buildKuralKarti(
          ikon: Icons.speed_rounded,
          ikonRenk: HelpColors.primaryContainer,
          baslik: widget.turkceMi ? '📷 Sabit Hız Radarları ve Limitler' : 'Speed Cameras & Speed Limits',
          icerik: widget.turkceMi
              ? "• Şehir İçi Yerleşim Alanları: 50 km/s\n"
                  "• Şehirlerarası Bölünmüş Anayollar: 75 km/s\n"
                  "• Lefkoşa - Gazimağusa / Ercan Otoyolu: 90 km/s\n"
                  "• Kameralar hem hız limitini hem de kırmızı ışık ihlallerini anında kaydeder ve plakaya ceza kesilir."
              : "• Urban & Town Areas: 50 km/h\n"
                  "• Intercity Dual Carriageways: 75 km/h\n"
                  "• Motorway stretches (Lefkosa - Famagusta): 90 km/h\n"
                  "• Cameras automatically capture speed and red-light violations directly to vehicle license plate.",
        ),
        _buildKuralKarti(
          ikon: Icons.assignment_late_rounded,
          ikonRenk: const Color(0xFFF59E0B),
          baslik: widget.turkceMi ? '📋 100 Ceza Puanı Sistemi' : '100 License Points Demerit System',
          icerik: widget.turkceMi
              ? "• KKTC'de ehliyet 100 tam puanla başlar.\n"
                  "• Hız sınırını %20 aşmak: -10 puan\n"
                  "• Seyir halinde cep telefonu kullanmak: -15 puan\n"
                  "• Emniyet kemeri takmamak: -10 puan\n"
                  "• Kırmızı ışıkta geçmek: -20 puan\n"
                  "• Puanınız 0'a indiğinde ehliyete 3 ay süreyle el konulur."
              : "• Drivers start with 100 full points in TRNC.\n"
                  "• Speeding over limit by 20%: -10 points\n"
                  "• Using mobile phone while driving: -15 points\n"
                  "• Not wearing seatbelt: -10 points\n"
                  "• Running red light: -20 points\n"
                  "• If points drop to zero, driver license is suspended for 3 months.",
        ),
        _buildKuralKarti(
          ikon: Icons.receipt_rounded,
          ikonRenk: const Color(0xFFA78BFA),
          baslik: widget.turkceMi ? '⏳ 15 Günlük İndirimli Ceza Ödeme' : '15-Day Fine Payment Period',
          icerik: widget.turkceMi
              ? "• Tebliğ edilen trafik cezaları 15 gün içinde ödenmelidir.\n"
                  "• Zamanında ödenmeyen cezalar mahkemeye sevk edilir ve gecikme faizi uygulanır.\n"
                  "• Uygulama üzerinden PGM ve Maliye Bakanlığı sistemine güvenli ödeme yapabilirsiniz."
              : "• Fines must be settled within 15 days of official notification.\n"
                  "• Unpaid fines are forwarded to traffic court with late surcharges.\n"
                  "• Secure online payments can be processed directly via PGM portal.",
        ),
      ],
    );
  }

  Widget _buildKuralKarti({
    required IconData ikon,
    required Color ikonRenk,
    required String baslik,
    required String icerik,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HelpColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ikonRenk.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(ikon, color: ikonRenk, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  baslik,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            icerik,
            style: const TextStyle(color: HelpColors.onSurface, fontSize: 12, height: 1.45),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 🆘 3. SEKME: ACİL YARDIM & İHBAR
  // ==========================================
  Widget _buildAcilYardimSekmesi() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: HelpColors.primaryContainer.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HelpColors.primaryContainer.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: HelpColors.primaryContainer, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.turkceMi
                      ? 'Kaza, arıza veya acil durumlarda aşağıdaki numaraları ücretsiz arayabilirsiniz.'
                      : 'In case of road accident or emergency, dial toll-free numbers below.',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        _buildAcilNumaraKarti(
          numara: "155",
          baslik: widget.turkceMi ? "Polis İmdat & Trafik Şube" : "Police Emergency & Traffic",
          aciklama: widget.turkceMi ? "Trafik kazası, radar ve yol güvenliği ihbarları" : "Traffic accidents & road safety",
          renk: HelpColors.primaryContainer,
          ikon: Icons.local_police_rounded,
        ),
        _buildAcilNumaraKarti(
          numara: "112",
          baslik: widget.turkceMi ? "Hızır Acil Ambulans" : "Emergency Ambulance",
          aciklama: widget.turkceMi ? "Tıbbi müdahale ve yaralanmalı kaza durumları" : "Medical aid & emergency trauma",
          renk: const Color(0xFFEF4444),
          ikon: Icons.medical_services_rounded,
        ),
        _buildAcilNumaraKarti(
          numara: "199",
          baslik: widget.turkceMi ? "İtfaiye Yangın İhbar" : "Fire & Rescue Department",
          aciklama: widget.turkceMi ? "Araç yangını, sıkışmalı kaza ve kurtarma" : "Vehicle fires & emergency rescue",
          renk: const Color(0xFFF59E0B),
          ikon: Icons.fire_truck_rounded,
        ),
        _buildAcilNumaraKarti(
          numara: "159",
          baslik: widget.turkceMi ? "Karayolları Yol Hasar Hattı" : "Highways Road Defect Hotline",
          aciklama: widget.turkceMi ? "Yolda çökme, dökülen yük veya tehlikeli engel bildirimi" : "Road obstruction & hazard reports",
          renk: HelpColors.tertiary,
          ikon: Icons.construction_rounded,
        ),
        _buildAcilNumaraKarti(
          numara: "0392 228 88 88",
          baslik: widget.turkceMi ? "7/24 KKTC Çekici & Yol Yardım" : "24/7 TRNC Towing & Road Assistance",
          aciklama: widget.turkceMi ? "Akü takviyesi, lastik değişimi ve oto çekici hizmeti" : "Vehicle towing & battery roadside service",
          renk: const Color(0xFF3B82F6),
          ikon: Icons.car_repair_rounded,
        ),
      ],
    );
  }

  Widget _buildAcilNumaraKarti({
    required String numara,
    required String baslik,
    required String aciklama,
    required Color renk,
    required IconData ikon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HelpColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: renk.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: renk.withValues(alpha: 0.3)),
            ),
            child: Icon(ikon, color: renk, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  baslik,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  aciklama,
                  style: const TextStyle(color: HelpColors.secondary, fontSize: 10.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: renk,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    widget.turkceMi ? '$numara aranıyor...' : 'Calling $numara...',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: renk,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                numara,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ❓ 4. SEKME: SIKÇA SORULAN SORULAR (SSS)
  // ==========================================
  String _sssKategori = 'Tümü';
  final TextEditingController _sssSearchCtrl = TextEditingController();
  String _sssSearchText = '';

  Widget _buildSssSekmesi() {
    final List<Map<String, dynamic>> tumSssListesi = [
      {
        "kategori": "Cezalar & İndirim",
        "rozet": "%30 İNDİRİM",
        "rozetRenk": const Color(0xFF10B981),
        "ikon": Icons.discount_rounded,
        "q": widget.turkceMi
            ? "Trafik cezalarında %30 erken ödeme indirimi nasıl işler? Son gün ne zamandır?"
            : "How does the 30% early payment discount on traffic fines work?",
        "a": widget.turkceMi
            ? "KKTC Trafik Yasası uyarınca, tebliğ edilen trafik cezaları 15 takvim günü içerisinde ödendiğinde %30 indirim uygulanır (Örn: ₺1.850 tutarındaki sabit radar cezası ₺1.295 olarak tahsil edilir).\n\n15 günlük yasal süre dolduğunda indirim hakkı kalkar, aylık yasal gecikme faizi eklenir ve dosya Trafik Mahkemesi'ne sevk edilir. Cezalarınızı kredi kartı veya banka kartınız ile uygulama üzerinden güvenle ödeyebilirsiniz."
            : "Under TRNC traffic law, fines settled within 15 calendar days receive a 30% discount (e.g. ₺1,850 drops to ₺1,295). After 15 days, late fees apply and the case is forwarded to traffic court.",
      },
      {
        "kategori": "Radarlar & Tolerans",
        "rozet": "%10 HIZ TOLERANSI",
        "rozetRenk": const Color(0xFFF59E0B),
        "ikon": Icons.speed_rounded,
        "q": widget.turkceMi
            ? "Sabit hız radarlarında yasal hız toleransı var mı? Hangi hızda ceza kesilir?"
            : "Is there a speed tolerance on fixed speed cameras in TRNC?",
        "a": widget.turkceMi
            ? "Evet, KKTC'deki tüm sabit hız kameralarında yasal hız sınırının üzerine %10 tolerans payı tanınmaktadır:\n\n• 50 km/s Şehir İçi: 56 km/s ve üzeri hızlarda ceza yazılır.\n• 65 km/s Çevre Yolu: 72 km/s ve üzeri hızlarda ceza yazılır.\n• 75 km/s Bölünmüş Anayol: 83 km/s ve üzeri hızlarda ceza yazılır.\n• 90 km/s Kıyı Arterleri: 99 km/s ve üzeri hızlarda ceza yazılır.\n• 100 km/s Şehirlerarası Anayol (Lefkoşa - Mağusa / İskele): 110 km/s ve üzeri hızlarda ceza yazılır.\n\nRadar kameraları hem gündüz hem gece çift yönlü telemetri ve flaşlı plaka algılama yapmaktadır."
            : "Yes, a 10% speed tolerance is officially applied. For example, in a 65 km/h zone, tickets are triggered at 72 km/h and above. Speed limits: 50 km/h (urban), 75 km/h (intercity), 90 km/h (motorway).",
      },
      {
        "kategori": "Genel",
        "rozet": "YASAL UYARI",
        "rozetRenk": const Color(0xFFEF4444),
        "ikon": Icons.gavel_rounded,
        "q": widget.turkceMi
            ? "Bu uygulama resmi bir devlet uygulaması mıdır? Veriler doğru ve güncel mi?"
            : "Is this an official government app? Is the data accurate and current?",
        "a": widget.turkceMi
            ? "Bu uygulama bilgilendirme amaçlı geliştirilmiş bağımsız bir sivil platformdur; KKTC Trafik Dairesi, Karayolları, Polis Genel Müdürlüğü veya Bayındırlık ve Ulaştırma Bakanlığı'nın resmî bir ürünü değildir. Harita, radar ve hız sınırı verileri OpenStreetMap katkıcıları ve kamuya açık kaynaklardan derlenir; hatalı veya eksik olabilir. Trafikte levhalara ve canlı trafik görevlilerinin talimatlarına uymanız yasal zorunluluktur."
            : "This is an independent informational platform, not an official product of the TRNC Traffic Department, Public Works, Police HQ or Ministry of Public Works and Transport. Map, radar and speed-limit data are compiled from OpenStreetMap contributors and public sources and may be inaccurate or incomplete. Always obey on-road signs and officers over this app.",
      },
      {
        "kategori": "E-Denetim & Polis",
        "rozet": "RESMİ BELGE",
        "rozetRenk": const Color(0xFF3B82F6),
        "ikon": Icons.qr_code_2_rounded,
        "q": widget.turkceMi
            ? "Polis çevirmesinde fiziksel ruhsat taşımak zorunda mıyım? E-Denetim QR nedir?"
            : "Do I need physical vehicle registration at police checkpoints?",
        "a": widget.turkceMi
            ? "Hayır, alt menüdeki 'E-Denetim' sekmesinden oluşturacağınız resmi karekodlu dijital sürücü ve araç belgesi, KKTC Polis Genel Müdürlüğü (PGM) ve Bayındırlık ve Ulaştırma Bakanlığı nezdinde geçerli resmi dijital belgedir.\n\nGörevli polis ekipleri bu dinamik QR kodu kendi el terminalleriyle taratarak ruhsat, muayene geçerliliği, sigorta poliçesi ve sürücü ceza puanı durumunuzu anlık olarak kamu sunucularından teyit edebilir."
            : "No, the dynamic QR document generated in the 'E-Denetim' tab is officially recognized by the TRNC Police (PGM). Officers scan this QR code to verify registration, insurance, and license points instantly.",
      },
      {
        "kategori": "Cezalar & İndirim",
        "rozet": "KRİPTOLU DELİL",
        "rozetRenk": const Color(0xFF8B5CF6),
        "ikon": Icons.camera_enhance_rounded,
        "q": widget.turkceMi
            ? "Radar kamerası fotoğrafımı ve kanıt görüntüsünü nasıl inceleyebilirim?"
            : "How can I view the radar camera violation photo and telemetry evidence?",
        "a": widget.turkceMi
            ? "Cezalar sekmesindeki ihlal kartının altında yer alan 'Delil İncele' butonuna veya Ana Menüdeki 'Radar Fotoğrafı & Kanıt İnceleme' ekranına tıklayarak ihlal anının yüksek çözünürlüklü radar fotoğrafını, araç plaka yakınlaştırmasını, radarın ölçtüğü tam hız telemetrisini ve PGM tebliğ numarasını kriptolu olarak görüntüleyebilirsiniz."
            : "Click 'Delil İncele' on your ticket card or go to Menu ➔ 'Radar Photography & Evidence' to view the camera snapshot, plate crop, measured radar speed and official teblig number.",
      },
      {
        "kategori": "Seyrüsefer & Ruhsat",
        "rozet": "ONLİNE HARÇ",
        "rozetRenk": const Color(0xFF06B6D4),
        "ikon": Icons.description_rounded,
        "q": widget.turkceMi
            ? "Seyrüsefer harcımı online ödeyebilir miyim? Gecikirse ne olur?"
            : "Can I pay vehicle road tax (seyrüsefer) online? What are late penalties?",
        "a": widget.turkceMi
            ? "Evet, 'Cezalar & Sigorta' ekranındaki 'Seyrüsefer' sekmesine geçerek kredi kartınızla güvenli resmi ödeme yapabilirsiniz. Ödeme anında barkodlu onay makbuzu üretilir.\n\nSeyrüsefer süresi geçen araçlara her ay için %2 ila %5 arasında gecikme faizi uygulanır. Seyrüsefersiz araç kullanılması halinde polis tarafından araç trafikten men edilebilir ve yüksek para cezası kesilir."
            : "Yes, you can renew your road tax online via the 'Seyrüsefer' tab. A certified barcode receipt is generated. Late renewals incur monthly interest and driving without valid road tax leads to vehicle impoundment.",
      },
      {
        "kategori": "Seyrüsefer & Ruhsat",
        "rozet": "MUAYENE TAKVİMİ",
        "rozetRenk": const Color(0xFFEAB308),
        "ikon": Icons.calendar_month_rounded,
        "q": widget.turkceMi
            ? "Araç fenni muayene tarihini nasıl takip ederim? Cezası nedir?"
            : "How do I check my vehicle technical inspection date (fenni muayene)?",
        "a": widget.turkceMi
            ? "KKTC'de araç muayeneleri plakanın son rakamına göre Trafik Dairesi'nin yayımladığı yıllık takvimle belirlenir. Uygulama, kayıtlı aracınızın muayene bitiş tarihine kaç gün kaldığını canlı olarak takip eder ve 30 gün kala uyarı bildirimi gönderir.\n\nMuayenesi geçmiş araçla trafiğe çıkmak 10 ceza puanı ve brüt asgari ücretin %10'u oranında para cezasına tabidir."
            : "Vehicle inspection schedules are organized by license plate numbers. The app tracks remaining days and sends automatic reminders 30 days prior. Driving without valid inspection results in 10 penalty points and fine.",
      },
      {
        "kategori": "Cezalar & İndirim",
        "rozet": "HAKEM HEYETİ",
        "rozetRenk": const Color(0xFFEC4899),
        "ikon": Icons.gavel_rounded,
        "q": widget.turkceMi
            ? "Hatalı yazıldığını düşündüğüm bir trafik cezasına nasıl itiraz edebilirim?"
            : "How can I dispute an incorrect traffic ticket or radar violation?",
        "a": widget.turkceMi
            ? "Menü ➔ 'İtiraz & Dilekçe İşlemleri' bölümüne giderek ceza tutanağı numarasını, itiraz gerekçenizi (örn: araç satışı, çalıntı/ikiz plaka, acil sağlık durumu, radar cihazı kalibrasyon hatası) belirterek ve kanıt fotoğraflarınızı ekleyerek Trafik İhtilaf Hakem Kurulu'na online resmi itiraz başvurusu yapabilirsiniz. İtiraz süresince ceza faizi durdurulur."
            : "Go to Menu ➔ 'Dispute & Petitions' to submit an official appeal to the Traffic Dispute Commission with ticket number, reason and supporting photos. Penalties are frozen during review.",
      },
      {
        "kategori": "Giriş & Puan",
        "rozet": "100 TAM PUAN",
        "rozetRenk": const Color(0xFF6366F1),
        "ikon": Icons.assignment_late_rounded,
        "q": widget.turkceMi
            ? "KKTC 100 Ceza Puanı sistemi nasıl çalışır? Puanım biterse ne olur?"
            : "How does the TRNC 100 demerit points system work? What if points hit zero?",
        "a": widget.turkceMi
            ? "Tüm KKTC ve geçerli yabancı ehliyet sahipleri 100 tam puanla sürüşe başlar. Her kural ihlalinde katsayıya göre ceza puanı düşülür:\n\n• Hız sınırını %20 aşmak: -10 puan\n• Seyir halinde telefonla konuşmak: -15 puan\n• Kırmızı ışık ihlali: -20 puan\n• Emniyet kemeri takmamak: -10 puan\n• Alkollü araç kullanmak: -50 ila -100 puan\n\nPuanı 0'a inen sürücülerin ehliyetine 3 ay el konulur. İhlal tarihinden sonraki 12 ay içinde yeni ceza alınmazsa puanlar eski haline döner."
            : "Drivers start with 100 points. Points are deducted based on severity (speeding: 10, mobile phone: 15, red light: 20). If points drop to zero, driving license is suspended for 3 months.",
      },
      {
        "kategori": "Giriş & Puan",
        "rozet": "EHLİYET NO İLE GİRİŞ",
        "rozetRenk": const Color(0xFF14B8A6),
        "ikon": Icons.badge_rounded,
        "q": widget.turkceMi
            ? "Sisteme nasıl giriş yapılır? Hangi bilgiler gereklidir?"
            : "How do I log in to the system? What credentials are required?",
        "a": widget.turkceMi
            ? "Uygulamamıza KKTC Sürüş Ehliyet Numaranız (örn: D-849201 veya Kimlik Numaranız) ve şifreniz ile güvenli bir şekilde giriş yapabilirsiniz.\n\nİlk kez kullanıyorsanız giriş ekranındaki 'Yeni Kayıt' sekmesinden Ehliyet Numaranızı, son kullanma tarihini ve telefon numaranızı girerek saniyeler içinde hesabınızı oluşturabilirsiniz. Giriş yaptıktan sonra adınıza kayıtlı araçlar, bekleyen radar cezaları, seyrüsefer ve muayene durumunuz otomatik olarak yüklenir."
            : "You can securely log in using your Driving License Number (e.g. D-849201 or ID Number) and password.\n\nFirst-time users can create an account via the 'Register' tab by entering their license number, expiry date, and mobile phone. All registered vehicles, radar fines, road tax, and inspection records will load automatically.",
      },
      {
        "kategori": "Radarlar & Tolerans",
        "rozet": "ÇEVRİMDIŞI GPS",
        "rozetRenk": const Color(0xFF64748B),
        "ikon": Icons.signal_wifi_off_rounded,
        "q": widget.turkceMi
            ? "İnternetim kapalıyken sabit hız radarları beni sesli olarak uyarır mı?"
            : "Do speed camera voice warnings work without an active internet connection?",
        "a": widget.turkceMi
            ? "Evet! KKTC genelindeki 142 adet sabit radar, tepe kamerası ve ışık sensörünün koordinatları uygulamanın dahili veritabanında çevrimdışı olarak saklanır. Cihazınızın GPS'i açık olduğu sürece internet paketiniz olmasa dahi radarlara 500m ve 250m kala sesli ve titreşimli olarak uyarılırsınız."
            : "Yes! Coordinates of all 142 fixed cameras are stored locally on your device. Proximity warnings (at 500m and 250m) work offline using device GPS sensors.",
      },
      {
        "kategori": "E-Denetim & Polis",
        "rozet": "7/24 DESTEK",
        "rozetRenk": const Color(0xFFEF4444),
        "ikon": Icons.car_crash_rounded,
        "q": widget.turkceMi
            ? "Trafik kazası, yol hasarı veya araç arızasında hangi numaraları aramalıyım?"
            : "Which numbers should I call in case of accident, roadside breakdown or damage?",
        "a": widget.turkceMi
            ? "Acil durumlarda uygulamadaki 'Acil Yardım' sekmesinden ücretsiz aranabilen resmi hatlar:\n\n• 155: Polis İmdat & Trafik Şube (Trafik kazaları ve adli bildirimler)\n• 112: Hızır Acil Ambulans (Yaralanma ve tıbbi yardım)\n• 199: İtfaiye Yangın & Kurtarma (Sıkışmalı kaza ve yangın)\n• 159: Karayolları Yol Hasar Hattı (Yoldaki çökme, dökülen yük veya engeller)\n• 0392 228 88 88: 7/24 KKTC Çekici ve Yol Yardım Servisi"
            : "Emergency contacts available: 155 (Police), 112 (Ambulance), 199 (Fire & Rescue), 159 (Highways Road Damage), 0392 228 88 88 (24/7 Roadside Towing).",
      },
      {
        "kategori": "Cezalar & İndirim",
        "rozet": "2026/2027 MEVZUAT",
        "rozetRenk": const Color(0xFF059669),
        "ikon": Icons.sync_rounded,
        "q": widget.turkceMi
            ? "Ceza miktarları ve asgari ücret katsayıları ne sıklıkla güncellenir?"
            : "How often are fine amounts and minimum wage multipliers updated?",
        "a": widget.turkceMi
            ? "KKTC'de trafik para cezaları brüt asgari ücrete endekslidir. Asgari ücret tespit komisyonu yeni tutarı yayımladığında, uygulamanın 'Otomatik Güncelleme Servisi' arka planda resmi kamu veritabanına bağlanır ve tüm ceza tutarlarını en güncel tarifeye göre yeniler. Menü ➔ 'Mevzuat & Veri Eşitleme' butonundan da dilediğiniz zaman manuel kontrol sağlayabilirsiniz."
            : "TRNC traffic fines are indexed to the statutory gross minimum wage. The app automatically fetches updated tariff coefficients from official servers upon launch.",
      },
    ];

    // Filtreleme
    final filtrelenmisListesi = tumSssListesi.where((item) {
      final matchesCategory = _sssKategori == 'Tümü' || item['kategori'] == _sssKategori;
      final qText = (item['q'] as String).toLowerCase();
      final aText = (item['a'] as String).toLowerCase();
      final sText = _sssSearchText.toLowerCase();
      final matchesSearch = sText.isEmpty || qText.contains(sText) || aText.contains(sText);
      return matchesCategory && matchesSearch;
    }).toList();

    final kategoriler = [
      'Tümü',
      'Cezalar & İndirim',
      'Radarlar & Tolerans',
      'E-Denetim & Polis',
      'Seyrüsefer & Ruhsat',
      'Giriş & Puan',
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Arama Kutusu
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: HelpColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: TextField(
            controller: _sssSearchCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            onChanged: (v) => setState(() => _sssSearchText = v),
            decoration: InputDecoration(
              icon: const Icon(Icons.search_rounded, color: HelpColors.tertiary, size: 20),
              hintText: widget.turkceMi
                  ? 'Soru, ceza veya kural ara... (örn: %30 indirim, tolerans, QR)'
                  : 'Search FAQs... (e.g. 30% discount, radar tolerance, QR)',
              hintStyle: TextStyle(color: HelpColors.secondary.withValues(alpha: 0.6), fontSize: 12),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              suffixIcon: _sssSearchText.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: HelpColors.secondary, size: 18),
                      onPressed: () {
                        _sssSearchCtrl.clear();
                        setState(() => _sssSearchText = '');
                      },
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Kategori Çipleri (Yatay Kaydırma)
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: kategoriler.map((kat) {
              final bool isSelected = _sssKategori == kat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(kat),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() => _sssKategori = kat);
                  },
                  backgroundColor: HelpColors.surfaceContainerHigh,
                  selectedColor: HelpColors.tertiary.withValues(alpha: 0.25),
                  checkmarkColor: HelpColors.tertiary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : HelpColors.secondary,
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: isSelected ? HelpColors.tertiary : Colors.white12,
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),

        // Sonuç Sayacı / Başlık
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.turkceMi ? 'SIKÇA SORULAN SORULAR' : 'FREQUENTLY ASKED QUESTIONS',
              style: const TextStyle(
                color: HelpColors.secondary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: HelpColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${filtrelenmisListesi.length} Soru',
                style: const TextStyle(
                  color: HelpColors.tertiary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Soru Listesi
        if (filtrelenmisListesi.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: HelpColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.search_off_rounded, size: 40, color: HelpColors.secondary),
                const SizedBox(height: 10),
                Text(
                  widget.turkceMi ? 'Aramanızla eşleşen soru bulunamadı.' : 'No questions matching your search.',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...filtrelenmisListesi.map((item) {
            final Color rozetRenk = item["rozetRenk"] as Color;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: HelpColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: ExpansionTile(
                shape: const RoundedRectangleBorder(side: BorderSide.none),
                collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: rozetRenk.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item["ikon"] as IconData, color: rozetRenk, size: 20),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: rozetRenk.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item["rozet"] as String,
                        style: TextStyle(
                          color: rozetRenk,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    item["q"] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  const Divider(color: Colors.white10, height: 1),
                  const SizedBox(height: 12),
                  Text(
                    item["a"] as String,
                    style: const TextStyle(
                      color: HelpColors.onSurface,
                      fontSize: 12.5,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
