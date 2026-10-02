import 'package:flutter/material.dart';
import 'guvenlik_duvari.dart';

// ==========================================
// 🎨 HIZLI ARAMA TASARIM TOKENLARI
// ==========================================
class SearchHtmlColors {
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
  static const Color onSurface = Color(0xFFDBE1FF);
  static const Color sky = Color(0xFF38BDF8);
  static const Color amber = Color(0xFFF59E0B);
  static const Color purple = Color(0xFFA78BFA);
}

// ==========================================
// 🔍 ARAMA ÖĞESİ MODELİ
// ==========================================
class AramaOgesi {
  final String hedefId;
  final String baslik;
  final String baslikEn;
  final String aciklama;
  final String aciklamaEn;
  final String kategori;
  final String kategoriEn;
  final IconData ikon;
  final Color renk;
  final List<String> anahtarlar;
  final String rozet;

  const AramaOgesi({
    required this.hedefId,
    required this.baslik,
    required this.baslikEn,
    required this.aciklama,
    required this.aciklamaEn,
    required this.kategori,
    required this.kategoriEn,
    required this.ikon,
    required this.renk,
    required this.anahtarlar,
    this.rozet = '',
  });
}

// ==========================================
// 🚀 HIZLI ARAMA MODAL BOTTOM SHEET
// ==========================================
class HizliAramaModalSayfasi extends StatefulWidget {
  final bool turkceMi;
  final Function(String hedefId) onHedefeGit;

  const HizliAramaModalSayfasi({
    super.key,
    required this.turkceMi,
    required this.onHedefeGit,
  });

  @override
  State<HizliAramaModalSayfasi> createState() => _HizliAramaModalSayfasiState();
}

class _HizliAramaModalSayfasiState extends State<HizliAramaModalSayfasi> {
  final TextEditingController _controller = TextEditingController();
  String _aramaMetni = '';
  final String _seciliKategori = 'hepsi';

  static String _turkceKarakterleriTemizle(String metin) {
    return metin
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');
  }

  // Tüm uygulama içi arama hedefleri ve anahtar kelimeleri
  late final List<AramaOgesi> _tumOgeler = [
    // 1. SEYRÜSEFER (Kullanıcının özellikle istediği ana özellik)
    const AramaOgesi(
      hedefId: 'seyrusefer',
      baslik: 'Seyrüsefer & Araç Muayenesi',
      baslikEn: 'Road Tax & Vehicle Inspection',
      aciklama: 'Yıllık seyrüsefer harcı, muayene geçerlilik süresi, online harç ödeme ve dönem bilgisi.',
      aciklamaEn: 'Annual road tax fees, inspection validities, online payments and tax periods.',
      kategori: 'Araç & Maliye',
      kategoriEn: 'Vehicle & Tax',
      ikon: Icons.directions_car_filled_rounded,
      renk: SearchHtmlColors.sky,
      rozet: 'Popüler',
      anahtarlar: [
        'seyrusefer',
        'seyrüsefer',
        'muayene',
        'harc',
        'harç',
        'vergi',
        'ruhsat',
        'maliye',
        'road tax',
        'inspection',
        'arac',
        'araç',
        'plaka',
        'vize',
      ],
    ),

    // 2. CEZALAR
    const AramaOgesi(
      hedefId: 'ceza',
      baslik: 'Trafik Cezalarım & Ceza Puanı',
      baslikEn: 'My Traffic Fines & Demerit Points',
      aciklama: 'Ödenmemiş radar cezaları, tebliğ tutanakları, 100 ceza puanı durumu ve online ödeme.',
      aciklamaEn: 'Unpaid speed camera fines, official tickets, 100 demerit points and fast payment.',
      kategori: 'Ceza & Polis',
      kategoriEn: 'Fines & Police',
      ikon: Icons.receipt_long_rounded,
      renk: SearchHtmlColors.primaryContainer,
      rozet: 'Ceza & Puan',
      anahtarlar: [
        'ceza',
        'cezalar',
        'radar cezasi',
        'ceza puani',
        'puan',
        'tutanak',
        'borc',
        'borç',
        'odeme',
        'ödeme',
        'fines',
        'ticket',
      ],
    ),

    // 3. SİGORTA (APPLE WALLET)
    const AramaOgesi(
      hedefId: 'sigorta_wallet',
      baslik: 'Zorunlu Trafik Sigortası Poliçesi',
      baslikEn: 'Mandatory Traffic Insurance Policy',
      aciklama: 'Kıbrıs Sigorta Kooperatifi poliçesi, bitiş gün sayacı, teminatlar ve PDF indirme.',
      aciklamaEn: 'Digital motor insurance policy, expiration counter, coverage details and PDF slip.',
      kategori: 'Sigorta',
      kategoriEn: 'Insurance',
      ikon: Icons.shield_outlined,
      renk: SearchHtmlColors.tertiary,
      anahtarlar: [
        'sigorta',
        'police',
        'poliçe',
        'kasko',
        'kibris sigorta',
        'teminat',
        'wallet',
        'insurance',
        'policy',
      ],
    ),

    // 4. POLİS QR KAREKODU
    const AramaOgesi(
      hedefId: 'police_qr',
      baslik: 'Polis QR Denetim Karekodu',
      baslikEn: 'Police QR Inspection Barcode',
      aciklama: 'Trafik çevirmelerinde polise gösterilecek dinamik onaylı karekod ve OTP doğrulama.',
      aciklamaEn: 'Dynamic verified QR barcode and OTP verification code for police checkpoints.',
      kategori: 'Denetim & Polis',
      kategoriEn: 'Police & QR',
      ikon: Icons.qr_code_scanner_rounded,
      renk: SearchHtmlColors.purple,
      anahtarlar: [
        'polis qr',
        'karekod',
        'barkod',
        'cevirme',
        'çevirme',
        'denetim',
        'police qr',
        'otp',
      ],
    ),

    // 5. SABİT HIZ RADARLARI
    const AramaOgesi(
      hedefId: 'radar',
      baslik: 'Sabit Hız Radarları & Canlı Sürüş',
      baslikEn: 'Fixed Speed Cameras & Live Drive',
      aciklama: 'KKTC geneli sabit radar haritası, 50/65/75/90 km/s hız limitleri ve canlı sürüş.',
      aciklamaEn: 'All TRNC fixed speed cameras, speed limits and live interactive driving GPS view.',
      kategori: 'Radar & Sürüş',
      kategoriEn: 'Radar & Drive',
      ikon: Icons.radar_rounded,
      renk: SearchHtmlColors.amber,
      rozet: 'Canlı',
      anahtarlar: [
        'radar',
        'sabit radar',
        'hiz',
        'hız',
        'kamera',
        'hiz limiti',
        'canli surus',
        'canlı sürüş',
        'speed camera',
      ],
    ),

    // 6. YOL TARİFİ & ROTALAR
    const AramaOgesi(
      hedefId: 'yol_tarifi',
      baslik: 'Akıllı Yol Tarifi & Rota Seçimi',
      baslikEn: 'Smart Route Guide & Directions',
      aciklama: 'Kalkanlı, Lefkoşa, Erülkü, Girne, Lapta, Ercan ve İskele canlı navigasyon rotaları.',
      aciklamaEn: 'Live OpenStreetMap directions for Kalkanli, Lefkosa, Erulku, Kyrenia, Lapta.',
      kategori: 'Navigasyon',
      kategoriEn: 'Navigation',
      ikon: Icons.alt_route_rounded,
      renk: SearchHtmlColors.sky,
      anahtarlar: [
        'yol tarifi',
        'rota',
        'navigasyon',
        'harita',
        'kalkanli',
        'kalkanlı',
        'erulku',
        'erülkü',
        'lapta',
        'girne',
        'lefkosa',
        'lefkoşa',
        'ercan',
        'iskele',
        'route',
        'directions',
      ],
    ),

    // 7. YARDIM VE SÜRÜŞ REHBERİ
    const AramaOgesi(
      hedefId: 'yardim',
      baslik: 'Yardım & Nasıl Giderim Rehberi',
      baslikEn: 'Help & How to Go Driving Guide',
      aciklama: 'KKTC sol şerit sürüş kuralları, çember geçiş üstünlükleri, acil numaralar ve S.S.S.',
      aciklamaEn: 'Left-hand driving rules, roundabout priority guidelines, emergency numbers & FAQs.',
      kategori: 'Yardım & Rehber',
      kategoriEn: 'Help & Guide',
      ikon: Icons.help_center_rounded,
      renk: SearchHtmlColors.tertiary,
      rozet: 'Rehber',
      anahtarlar: [
        'yardim',
        'yardım',
        'nasil giderim',
        'nasıl giderim',
        'rehber',
        'kural',
        'kurallar',
        'cember',
        'çember',
        'sol serit',
        'sol şerit',
        'donel kavsak',
        'sss',
        'faq',
      ],
    ),

    // 8. TRAFİK HAKEM HEYETİ İTİRAZI
    const AramaOgesi(
      hedefId: 'itiraz',
      baslik: 'Trafik Hakem Heyeti İtirazı',
      baslikEn: 'Traffic Dispute & Official Petition',
      aciklama: 'Hatalı yazılan radar cezalarına online resmi itiraz dilekçesi hazırlama ve başvuru.',
      aciklamaEn: 'Prepare official dispute petition for incorrect speed fines directly online.',
      kategori: 'Hukuk & İtiraz',
      kategoriEn: 'Dispute & Law',
      ikon: Icons.gavel_rounded,
      renk: SearchHtmlColors.amber,
      anahtarlar: [
        'itiraz',
        'hakem heyeti',
        'dilekce',
        'dilekçe',
        'hatali ceza',
        'hatalı ceza',
        'mahkeme',
        'dispute',
        'petition',
      ],
    ),

    // 9. BARKODLU RESMİ SÜRÜCÜ BELGESİ
    const AramaOgesi(
      hedefId: 'ehliyet',
      baslik: 'Barkodlu Resmi Sürücü Belgesi',
      baslikEn: 'Official Barcoded Driver License',
      aciklama: 'Polis denetimlerinde gösterilebilir karekodlu ve doğrulanabilir dijital ehliyet.',
      aciklamaEn: 'Digital driver license with official QR verification for police inspections.',
      kategori: 'Ehliyet',
      kategoriEn: 'Driver License',
      ikon: Icons.qr_code_2_rounded,
      renk: SearchHtmlColors.primary,
      anahtarlar: [
        'ehliyet',
        'surucu belgesi',
        'sürücü belgesi',
        'dijital ehliyet',
        'barkodlu belge',
        'license',
      ],
    ),

    // 10. ÖDEME DEKONTLARI & GEÇMİŞ
    const AramaOgesi(
      hedefId: 'dekontlar',
      baslik: 'Ödeme Dekontlarım & Geçmiş',
      baslikEn: 'Payment Slips & Invoices',
      aciklama: 'Geçmişte ödenen cezalar, seyrüsefer ve sigorta makbuzları dökümü.',
      aciklamaEn: 'Official receipts and payment slips for past fines, taxes and insurances.',
      kategori: 'Finans & Makbuz',
      kategoriEn: 'Receipts',
      ikon: Icons.receipt_long_rounded,
      renk: SearchHtmlColors.tertiary,
      anahtarlar: [
        'dekont',
        'makbuz',
        'odeme gecmisi',
        'ödeme geçmişi',
        'fatura',
        'slip',
        'receipt',
      ],
    ),

    // 11. SESLİ UYARI & BİLDİRİM AYARLARI
    const AramaOgesi(
      hedefId: 'bildirimler',
      baslik: 'Sesli Uyarı & Radar Hatırlatıcıları',
      baslikEn: 'Audio Alerts & Radar Reminders',
      aciklama: 'Radar yaklaşım bip sesi, seyrüsefer ve sigorta yenileme uyarı ayarları.',
      aciklamaEn: 'Speed proximity sound notifications, road tax and insurance reminders.',
      kategori: 'Ayarlar',
      kategoriEn: 'Settings',
      ikon: Icons.notifications_active_outlined,
      renk: SearchHtmlColors.purple,
      anahtarlar: [
        'sesli uyari',
        'sesli uyarı',
        'radar sesi',
        'bildirim',
        'hatirlatici',
        'hatırlatıcı',
        'ayarlar',
        'audio',
        'alert',
      ],
    ),

    // 12. 7/24 ÇEKİCİ & YOL YARDIM
    const AramaOgesi(
      hedefId: 'cekici',
      baslik: '7/24 Çekici & Acil Yol Yardım',
      baslikEn: '24/7 Towing & Roadside Assistance',
      aciklama: 'Arıza, kaza ve lastik patlamalarında 7/24 KKTC geneli çekici kurtarıcı hattı.',
      aciklamaEn: '24/7 TRNC towing recovery service for breakdowns, accidents or flat tires.',
      kategori: 'Acil Durum',
      kategoriEn: 'Emergency',
      ikon: Icons.car_repair_rounded,
      renk: Color(0xFFF43F5E),
      rozet: '7/24',
      anahtarlar: [
        'cekici',
        'çekici',
        'kurtarici',
        'kurtarıcı',
        'yol yardim',
        'yol yardım',
        'ariza',
        'arıza',
        'lastik',
        'towing',
      ],
    ),
  ];

  List<AramaOgesi> get _filtrelenmisOgeler {
    final temizQuery = _turkceKarakterleriTemizle(_aramaMetni.trim());

    return _tumOgeler.where((oge) {
      // Kategori filtresi
      if (_seciliKategori != 'hepsi' && oge.kategori != _seciliKategori) {
        return false;
      }

      // Metin araması boşsa hepsini göster
      if (temizQuery.isEmpty) return true;

      final baslikT = _turkceKarakterleriTemizle(oge.baslik);
      final baslikEnT = _turkceKarakterleriTemizle(oge.baslikEn);
      final aciklamaT = _turkceKarakterleriTemizle(oge.aciklama);
      final kategoriT = _turkceKarakterleriTemizle(oge.kategori);

      if (baslikT.contains(temizQuery) ||
          baslikEnT.contains(temizQuery) ||
          aciklamaT.contains(temizQuery) ||
          kategoriT.contains(temizQuery)) {
        return true;
      }

      // Anahtarlar içinde arama
      return oge.anahtarlar.any((k) => _turkceKarakterleriTemizle(k).contains(temizQuery));
    }).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sonuclar = _filtrelenmisOgeler;

    return Container(
      height: MediaQuery.of(context).size.height * 0.84,
      decoration: const BoxDecoration(
        color: SearchHtmlColors.surfaceContainerLow,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Üst Çekme Çizgisi
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Başlık ve Kapatma Butonu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: SearchHtmlColors.sky.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.saved_search_rounded, color: SearchHtmlColors.sky, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.turkceMi ? 'Uygulama İçi Hızlı Arama' : 'In-App Instant Search',
                        style: const TextStyle(
                          color: SearchHtmlColors.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        widget.turkceMi
                            ? 'Aramak istediğin hizmeti yaz, direkt o sekmeye git'
                            : 'Type any service to navigate there instantly',
                        style: TextStyle(
                          color: SearchHtmlColors.secondary.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: SearchHtmlColors.secondary),
                  tooltip: widget.turkceMi ? 'Kapat' : 'Close',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Arama Giriş Kutusu (TextField)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: SearchHtmlColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _aramaMetni.isNotEmpty ? SearchHtmlColors.sky : Colors.white.withValues(alpha: 0.08),
                  width: 1.2,
                ),
                boxShadow: [
                  if (_aramaMetni.isNotEmpty)
                    BoxShadow(
                      color: SearchHtmlColors.sky.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                style: const TextStyle(color: SearchHtmlColors.onSurface, fontSize: 14),
                cursorColor: SearchHtmlColors.sky,
                decoration: InputDecoration(
                  hintText: widget.turkceMi
                      ? 'Örn: seyrüsefer, radar, ceza, itiraz, ehliyet...'
                      : 'E.g. road tax, radar, fine, petition...',
                  hintStyle: TextStyle(color: SearchHtmlColors.secondary.withValues(alpha: 0.5), fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: SearchHtmlColors.sky, size: 20),
                  suffixIcon: _aramaMetni.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: SearchHtmlColors.secondary, size: 18),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _aramaMetni = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onChanged: (val) {
                  final denetim = GuvenlikDuvari.instance.girdiDenetle(val, alanAdi: 'Hızlı Arama');
                  if (!denetim.guvenliMi) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.security_rounded, color: Color(0xFFEF4444)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.turkceMi
                                    ? '🛡️ Siber Güvenlik Duvarı: ${denetim.aciklama}'
                                    : '🛡️ Cyber Firewall: ${denetim.aciklama}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFF0F172A),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    _controller.text = denetim.temizlenmisGirdi;
                    _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: denetim.temizlenmisGirdi.length),
                    );
                    setState(() => _aramaMetni = denetim.temizlenmisGirdi);
                  } else {
                    setState(() => _aramaMetni = val);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Hızlı Kısayol Çipleri (Özellikle Seyrüsefer, Ceza, Radar)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildQuickChip(
                  label: widget.turkceMi ? '🚗 Seyrüsefer' : '🚗 Road Tax',
                  query: 'seyrüsefer',
                ),
                const SizedBox(width: 6),
                _buildQuickChip(
                  label: widget.turkceMi ? '⚖️ Cezalarım' : '⚖️ Fines',
                  query: 'ceza',
                ),
                const SizedBox(width: 6),
                _buildQuickChip(
                  label: widget.turkceMi ? '📸 Sabit Radarlar' : '📸 Radars',
                  query: 'radar',
                ),
                const SizedBox(width: 6),
                _buildQuickChip(
                  label: widget.turkceMi ? '🗺️ Yol Tarifi' : '🗺️ Route',
                  query: 'yol tarifi',
                ),
                const SizedBox(width: 6),
                _buildQuickChip(
                  label: widget.turkceMi ? '🛡️ Sigorta & QR' : '🛡️ Insurance',
                  query: 'sigorta',
                ),
                const SizedBox(width: 6),
                _buildQuickChip(
                  label: widget.turkceMi ? '📝 İtiraz Dilekçesi' : '📝 Dispute',
                  query: 'itiraz',
                ),
                const SizedBox(width: 6),
                _buildQuickChip(
                  label: widget.turkceMi ? '💡 Nasıl Giderim?' : '💡 Guide',
                  query: 'yardım',
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Arama Sonuç Başlığı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _aramaMetni.isEmpty
                      ? (widget.turkceMi ? 'ÖNERİLEN HIZLI KISAYOLLAR' : 'RECOMMENDED SHORTCUTS')
                      : (widget.turkceMi ? '${sonuclar.length} SONUÇ BULUNDU' : '${sonuclar.length} RESULTS FOUND'),
                  style: const TextStyle(
                    color: SearchHtmlColors.secondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                if (_aramaMetni.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _controller.clear();
                      setState(() => _aramaMetni = '');
                    },
                    child: Text(
                      widget.turkceMi ? 'Temizle' : 'Clear',
                      style: const TextStyle(
                        color: SearchHtmlColors.sky,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Arama Sonuç Listesi
          Expanded(
            child: sonuclar.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: SearchHtmlColors.secondary.withValues(alpha: 0.5)),
                        const SizedBox(height: 10),
                        Text(
                          widget.turkceMi
                              ? '"$_aramaMetni" için eşleşen hizmet bulunamadı.'
                              : 'No service found matching "$_aramaMetni".',
                          style: const TextStyle(color: SearchHtmlColors.onSurface, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.turkceMi
                              ? 'Farklı bir kelime deneyin (örn: seyrüsefer, ceza, radar)'
                              : 'Try different terms (e.g. road tax, fines, radar)',
                          style: TextStyle(color: SearchHtmlColors.secondary.withValues(alpha: 0.7), fontSize: 11),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: sonuclar.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = sonuclar[index];
                      return _buildSonucKarti(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip({required String label, required String query}) {
    final bool secili = _aramaMetni.toLowerCase() == query.toLowerCase();
    return InkWell(
      onTap: () {
        _controller.text = query;
        _controller.selection = TextSelection.fromPosition(TextPosition(offset: query.length));
        setState(() => _aramaMetni = query);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: secili ? SearchHtmlColors.sky.withValues(alpha: 0.20) : SearchHtmlColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: secili ? SearchHtmlColors.sky : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: secili ? SearchHtmlColors.sky : SearchHtmlColors.onSurface,
            fontSize: 11,
            fontWeight: secili ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSonucKarti(AramaOgesi item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onHedefeGit(item.hedefId),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SearchHtmlColors.surfaceContainerHigh.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              // Sol İkon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: item.renk.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: item.renk.withValues(alpha: 0.3)),
                ),
                child: Icon(item.ikon, color: item.renk, size: 22),
              ),
              const SizedBox(width: 12),

              // Başlık ve Açıklama
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.turkceMi ? item.baslik : item.baslikEn,
                            style: const TextStyle(
                              color: SearchHtmlColors.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.rozet.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: item.renk.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.rozet,
                              style: TextStyle(
                                color: item.renk,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.turkceMi ? item.aciklama : item.aciklamaEn,
                      style: TextStyle(
                        color: SearchHtmlColors.secondary.withValues(alpha: 0.8),
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.turkceMi ? 'Bölüm: ${item.kategori}' : 'Section: ${item.kategoriEn}',
                      style: TextStyle(
                        color: item.renk.withValues(alpha: 0.9),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Sağ Yönlendirme İkonu
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: SearchHtmlColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: SearchHtmlColors.secondary,
                  size: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
