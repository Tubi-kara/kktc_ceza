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
      baslik: "Kalkanlı / ODTÜ ➔ Erülkü Süpermarket & Lefkoşa",
      baslikEn: "Kalkanli (METU) ➔ Erulku & Lefkosa",
      baslangicId: "kalkanli",
      varisId: "erulku",
      baslangicAdi: "ODTÜ Kalkanlı Kampüsü",
      varisAdi: "Erülkü Demirhan",
      mesafe: "48.2 km",
      sure: "~41 dk",
      radarSayisi: 5,
      ikon: Icons.shopping_cart_rounded,
      oneriMetni:
          "Gönyeli şehir içi trafiğine ve 50 km/s radar kameralarına girmemek için Alayköy sonrası doğrudan Kuzey Çevre Yolu viyadüğüne bağlanın. Hamitköy üzerinden ışıksız olarak Erülkü'ye ulaşırsınız.",
      oneriMetniEn:
          "Avoid congested Gonyeli center and 50 km/h cameras by taking North Bypass at Alaykoy link. Straight traffic-light-free drive to Erulku via Hamitkoy.",
      pufNoktalari: [
        "Kalkanlı çıkışında 65 km/s hız radarına dikkat edin.",
        "Yılmazköy düzlüğünde 75 km/s hız sabitleyiciyi kurun.",
        "Kuzey Çevre Yolu Lefkoşa şehir trafiğini tamamen baypas eder.",
      ],
      pufNoktalariEn: [
        "Watch 65 km/h camera leaving Kalkanli.",
        "Set cruise control to 75 km/h on Yilmazkoy straight.",
        "North Bypass completely avoids central Lefkosa traffic.",
      ],
    ),
    PopulerRotaRehberi(
      baslik: "Girne Limanı ➔ Lapta & Alsancak Sahili",
      baslikEn: "Kyrenia Harbor ➔ Lapta & Alsancak Coast",
      baslangicId: "girne_liman",
      varisId: "lapta",
      baslangicAdi: "Girne Tarihi Liman",
      varisAdi: "Lapta Sahili & Oteller",
      mesafe: "14.5 km",
      sure: "~20 dk",
      radarSayisi: 2,
      ikon: Icons.beach_access_rounded,
      oneriMetni:
          "Karaoğlanoğlu caddesinden batıya doğru sahil şeridini takip edin. Escape Beach, Alsancak Milli Parkı ve Lapta ahşap kordon yürüyüş yolu bu güzergahtadır.",
      oneriMetniEn:
          "Head west along Karaoglanoglu coastal road. Escape Beach, Alsancak Nature Park and Lapta wooden boardwalk are along this scenic strip.",
      pufNoktalari: [
        "Alsancak ve Karaoğlanoğlu okul/market bölgelerinde hız limiti 50 km/s'dir.",
        "Lapta ahşap kordon günbatımı yürüyüşü için Kıbrıs'ın en güzel rotasıdır.",
        "Merit oteller bölgesine sahil anayolundan doğrudan sapılabilir.",
      ],
      pufNoktalariEn: [
        "Speed limit is 50 km/h in school/market zones around Alsancak.",
        "Lapta wooden boardwalk is the top sunset promenade in Cyprus.",
        "Merit resorts are accessed directly off the coastal avenue.",
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
      baslik: "İskele Long Beach ➔ Karpaz Altın Kumsal",
      baslikEn: "Iskele Long Beach ➔ Karpaz Golden Beach",
      baslangicId: "iskele_longbeach",
      varisId: "karpaz_altinkumsal",
      baslangicAdi: "İskele Long Beach",
      varisAdi: "Altın Kumsal Karpaz",
      mesafe: "68.5 km",
      sure: "~65 dk",
      radarSayisi: 2,
      ikon: Icons.landscape_rounded,
      oneriMetni:
          "İskele Boğaz balıkçı limanından geçip Kumyalı, Mehmetçik ve Dipkarpaz yönüne doğru Akdeniz manzarası eşliğinde gidin. Kıbrıs'ın en büyüleyici doğa rotasıdır.",
      oneriMetniEn:
          "Pass Iskele Bogaz harbor and drive northeast through Kumyali, Mehmetcik, and Dipkarpaz towards Golden Beach. The premier nature route.",
      pufNoktalari: [
        "Boğaz çıkışı ve Mehmetçik kavşağındaki hız radarlarına dikkat edin.",
        "Dipkarpaz Milli Parkı'nda yabani eşekler yol kenarında olabilir, yavaş sürün.",
        "Karpaz burnunda benzinlik az olduğu için İskele'de yakıt ikmali yapın.",
      ],
      pufNoktalariEn: [
        "Watch speed cameras exiting Bogaz and Mehmetcik junction.",
        "Wild donkeys roam near road in Dipkarpaz Reserve; drive carefully.",
        "Gas stations are sparse past Dipkarpaz; fuel up in Iskele.",
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            child: Text(
              numara,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ❓ 4. SEKME: SIKÇA SORULAN SORULAR (SSS)
  // ==========================================
  Widget _buildSssSekmesi() {
    final sssListesi = [
      {
        "q": widget.turkceMi ? "TC Kimlik No veya Pasaport ile nasıl giriş yapılır?" : "How to log in with Turkish ID or Passport?",
        "a": widget.turkceMi
            ? "Giriş ekranında 'TC Kimlik / Yabancı Pasaport' sekmesine geçip 11 haneli kimlik numaranızı veya pasaport numaranızı yazarak anında sorgulama yapabilirsiniz. Askeri personel ve TC vatandaşları için tam uyumludur."
            : "Select the 'TR ID / Passport' tab on the login screen, enter your 11-digit Turkish ID or passport number to access records directly.",
      },
      {
        "q": widget.turkceMi ? "Üniversite öğrenci numarasıyla ceza sorgulanabilir mi?" : "Can university students log in with student ID?",
        "a": widget.turkceMi
            ? "Evet! ODTÜ Kuzey Kıbrıs, Doğu Akdeniz Üniversitesi (DAÜ), Yakın Doğu (YDÜ), Uluslararası Kıbrıs (UKÜ) ve Lefke Avrupa Üniversitesi (LAÜ) öğrencileri 'Öğrenci Girişi' sekmesinden öğrenci numaralarıyla giriş yapabilir."
            : "Yes! Students from METU NCC, EMU, NEU, CIU and EUL can authenticate via the 'Student Login' tab using their student numbers.",
      },
      {
        "q": widget.turkceMi ? "Sabit hız radarlarını yol tarifinde nasıl takip ederim?" : "How do I monitor speed cameras on the route?",
        "a": widget.turkceMi
            ? "'Yol Tarifi' sekmesinde başlangıç ve varış noktanızı seçtiğinizde, güzergahtaki tüm sabit radarlar harita üzerinde kırmızı hız tabelası pinleriyle gösterilir. 'Canlı Sürüşü Başlat' butonuna basarak yaklaştığınız radarlar için 500m kala sesli ve görsel ikaz alabilirsiniz."
            : "In the 'Route Navigation' tab, select your start and destination points. All cameras on the path will appear on the map with red speed signs. Click 'Start Live Simulation' for real-time proximity alerts.",
      },
      {
        "q": widget.turkceMi ? "Seyrüsefer ve araç muayene süremi nasıl öğrenirim?" : "Where can I check vehicle inspection and road tax?",
        "a": widget.turkceMi
            ? "Ana menüdeki 'Cezalar & Sigorta' ekranından aracınızın plakasını seçerek seyrüsefer vergisi, zorunlu trafik sigortası ve muayene bitiş tarihine kaç gün kaldığını canlı olarak görebilirsiniz."
            : "From the 'Fines & Insurance' tab, view remaining days for road tax (seyrüsefer), mandatory third-party insurance, and technical vehicle inspection.",
      },
      {
        "q": widget.turkceMi ? "Hatalı yazılan bir cezaya nereden itiraz edebilirim?" : "How can I dispute an incorrect traffic ticket?",
        "a": widget.turkceMi
            ? "Menü ➔ 'Trafik Hakem Heyeti İtirazı' bölümüne giderek ceza tutanağının fotoğrafını yükleyebilir ve resmi itiraz dilekçenizi online olarak Trafik İhtilaf Komisyonu'na iletebilirsiniz."
            : "Go to Menu ➔ 'Traffic Dispute & Petition' to upload ticket photos and submit an official online dispute directly to the review board.",
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: sssListesi.map((item) {
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
            leading: const Icon(Icons.help_outline_rounded, color: HelpColors.tertiary, size: 20),
            title: Text(
              item["q"]!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Text(
                item["a"]!,
                style: const TextStyle(
                  color: HelpColors.secondary,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
