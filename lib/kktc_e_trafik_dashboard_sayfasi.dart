import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'kktc_e_trafik_giris_sayfasi.dart';
import 'kktc_e_trafik_radar_kokpit_sayfasi.dart';
import 'kktc_e_trafik_menu_sayfasi.dart';
import 'kktc_gov_sync_service.dart';
import 'hizli_arama_modali.dart';
import 'radar_haritasi.dart';
import 'guncelleme_servisi.dart';
import 'yol_tarifi_sayfasi.dart';
import 'canli_gps_servisi.dart';
import 'kktc_akaryakit_servisi.dart';
import 'main.dart' show BarkodluBelgeSayfasi, ItirazSayfasi, DekontlarSayfasi;

/// KKTC e-Trafik Modern Dashboard (Kullanıcı Paneli)
/// HTML / Tailwind CSS tasarımının birebir Flutter uyarlamasıdır.
class KktcETrafikDashboardSayfasi extends StatefulWidget {
  final VoidCallback? onOpenRadars;
  final VoidCallback? onOpenFines;
  final VoidCallback? onOpenQrDocument;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onCikisYap;
  final bool initialGirisYapildiMi;
  final String? initialKullaniciAdi;
  final VoidCallback? onGirisYapIstegi;

  const KktcETrafikDashboardSayfasi({
    super.key,
    this.onOpenRadars,
    this.onOpenFines,
    this.onOpenQrDocument,
    this.onOpenProfile,
    this.onCikisYap,
    this.initialGirisYapildiMi = false,
    this.initialKullaniciAdi,
    this.onGirisYapIstegi,
  });

  @override
  State<KktcETrafikDashboardSayfasi> createState() =>
      _KktcETrafikDashboardSayfasiState();
}

class _KktcETrafikDashboardSayfasiState
    extends State<KktcETrafikDashboardSayfasi>
    with SingleTickerProviderStateMixin {
  // Renk Paleti (HTML tasarımındaki tokenlar ile birebir)
  static const Color cNavy = Color(0xFF010E3C);
  static const Color cSlate = Color(0xFF747675);
  static const Color cSoft = Color(0xFFE3E3E3);
  static const Color cBg = Color(0xFFF4F5F7);
  static const Color cCard = Color(0xFFFFFFFF);
  static const Color cLime = Color(0xFFD1C929);
  static const Color cLimeDark = Color(0xFF948D08);
  static const Color cEmerald = Color(0xFF10B981);

  // Kullanıcı Giriş Durumu
  bool _girisYapildiMi = false;
  String _kullaniciAdi = 'Ahmet Demir';

  void _girisEkraniniAc({VoidCallback? onSuccess}) {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => KktcETrafikGirisSayfasi(
          onLoginSuccess: () {
            setState(() {
              _girisYapildiMi = true;
              _kullaniciAdi = 'Ahmet Demir';
            });
            if (Navigator.canPop(ctx)) {
              Navigator.pop(ctx);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Giriş başarılı! Hoş geldiniz.'),
                backgroundColor: Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
              ),
            );
            if (onSuccess != null) {
              onSuccess();
            }
          },
        ),
      ),
    );
  }

  bool _girisKontrolEt({required String islemAdi, VoidCallback? onGirisSonrasi}) {
    if (_girisYapildiMi) {
      if (onGirisSonrasi != null) {
        onGirisSonrasi();
      }
      return true;
    }

    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$islemAdi için lütfen giriş yapın.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
    _girisEkraniniAc(onSuccess: onGirisSonrasi);
    return false;
  }

  // Seçili Tab İndeksi: 0: Panel, 1: Radarlar, 2: E-Denetim, 3: Cezalar & Sigorta, 4: Menü
  int _selectedTabIndex = 0;

  // Cezalar & Sigorta Alt Sekmesi: 0: Trafik Cezaları, 1: Seyrüsefer & Ruhsat, 2: Sigorta & Muayene
  int _cezaSigortaSubTab = 0;
  bool _cezaOdendi = false;
  bool _seyruseferYenilendi = false;
  // Radarlar Sekmesi Durumları (HTML Şablonu ile Birebir)
  bool _sesliUyariAcik = true;
  int _radarFiltreIndex = 0;
  // Harita Modu: 1 = Canlı OpenStreetMap (Varsayılan), 0 = Taktiksel Vektör
  int _radarHaritaModu = 1;
  RadarKamerasi? _seciliRadarKamerasi;
  int _canliHiz = 62;
  final GlobalKey<KktcOpenStreetMapTileViewState> _osmKey = GlobalKey<KktcOpenStreetMapTileViewState>();

  // 🗺️ HARİTALAR SEKMESİ - POI DURUMLARI
  final GlobalKey<KktcOpenStreetMapTileViewState> _haritaOsmKey = GlobalKey<KktcOpenStreetMapTileViewState>();
  String _seciliPoiKategori = 'tumu'; // 'tumu', 'benzin', 'tamir', 'otopark', 'hastane'
  KktcHaritaPoi? _seciliPoi;
  final KktcAkaryakitServisi _akaryakitServisi = KktcAkaryakitServisi();

  // 🚗 ARAÇ MODU
  final CanliGpsServisi _gps = CanliGpsServisi();
  bool _aracModu = false;
  bool _aracModuManuelKapandi = false; // Kullanıcı manuel kapattıysa otomatik açılmasın

  Future<void> _openGoogleMaps({double lat = 35.2132, double lon = 33.3085, String? title}) async {
    HapticFeedback.mediumImpact();
    final Uri uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Maps açılamadı: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Seçili Araç: 0: RZ 123, 1: LZ 555
  int _selectedVehicleIndex = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseScaleAnimation;
  late Animation<double> _pulseOpacityAnimation;

  final List<Map<String, dynamic>> _vehicles = [
    {
      'plate': 'RZ 123',
      'model': 'BMW 3.20i (2022)',
      'isActive': true,
    },
    {
      'plate': 'LZ 555',
      'model': 'Mercedes C200',
      'isActive': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _girisYapildiMi = widget.initialGirisYapildiMi;
    if (widget.initialKullaniciAdi != null && widget.initialKullaniciAdi!.isNotEmpty) {
      _kullaniciAdi = widget.initialKullaniciAdi!;
    }
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _pulseScaleAnimation = Tween<double>(begin: 1.0, end: 2.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _pulseOpacityAnimation = Tween<double>(begin: 0.8, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    // GPS Dinleyici — Araç Modu Otomatik Tetikleyici
    _gps.addListener(_gpsGuncellendi);
    _gps.servisiBaslat();

    // Canlı Akaryakıt Fiyatları Dinleyici
    _akaryakitServisi.addListener(_akaryakitGuncellendi);

    // Otomatik resmi kamu mevzuat ve ceza katsayıları kontrolü
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          GuncellemeServisi.otomatikKontrolEt(context, true);
        }
      });
    });
  }

  @override
  void didUpdateWidget(covariant KktcETrafikDashboardSayfasi oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialGirisYapildiMi != oldWidget.initialGirisYapildiMi) {
      setState(() {
        _girisYapildiMi = widget.initialGirisYapildiMi;
      });
    }
    if (widget.initialKullaniciAdi != oldWidget.initialKullaniciAdi &&
        widget.initialKullaniciAdi != null) {
      setState(() {
        _kullaniciAdi = widget.initialKullaniciAdi!;
      });
    }
  }

  void _gpsGuncellendi() {
    if (!mounted) return;
    final hiz = _gps.gercekHizKmh;
    final konum = _gps.sonKonum;

    // Hız > 10 km/s → Araç Modu AÇ (Manuel kapatılmadıysa)
    if (hiz > 10 && !_aracModu && !_aracModuManuelKapandi) {
      setState(() => _aracModu = true);
      HapticFeedback.mediumImpact();
      // Radarlar sekmesine geç ve haritaya zoom yap
      if (_selectedTabIndex != 1) setState(() => _selectedTabIndex = 1);
    }

    // Hız < 5 km/s (durdu) → Araç Modu KAPAT ve manuel kilidi sıfırla
    if (hiz < 5 && _aracModu) {
      setState(() {
        _aracModu = false;
        _aracModuManuelKapandi = false;
      });
    }

    // Araç modundayken haritayı konuma otomatik takip et (zoom 14)
    if (_aracModu && konum != null) {
      _osmKey.currentState?.flyToLocation(konum.latitude, konum.longitude, zoom: 14.0);
    }
  }

  @override
  void dispose() {
    _akaryakitServisi.removeListener(_akaryakitGuncellendi);
    _gps.removeListener(_gpsGuncellendi);
    _pulseController.dispose();
    super.dispose();
  }

  void _akaryakitGuncellendi() {
    if (mounted) setState(() {});
  }

  void _showInfoDialog({required String title, required String message}) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(
            color: cNavy,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: cSlate, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Tamam',
              style: TextStyle(color: cNavy, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cBg,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.white,
        ),
        child: Stack(
          children: [
            // Ana İçerik Alanı
            if (_selectedTabIndex == 1)
              Positioned.fill(
                bottom: 68, // Alt Navigasyon Barı için boşluk
                child: _buildFullScreenHaritalarTab(),
              )
            else
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: _selectedTabIndex == 4 ? 18 : 20,
                    right: _selectedTabIndex == 4 ? 18 : 20,
                    top: _selectedTabIndex == 4
                        ? (MediaQuery.of(context).padding.top + 16)
                        : (MediaQuery.of(context).padding.top + 84),
                    bottom: 120, // Bottom navigation bar boşluğu (içerik arkada kalmaz)
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: _selectedTabIndex == 3
                          ? _buildCezalarVeSigortaTab()
                          : (_selectedTabIndex == 4
                              ? KktcETrafikMenuSayfasi(
                                  onOpenPanel: () => setState(() => _selectedTabIndex = 0),
                                  onOpenRadars: () => setState(() => _selectedTabIndex = 1),
                                  onOpenFines: () {
                                    _girisKontrolEt(
                                      islemAdi: 'Cezalar ve harçlar sekmesini açmak',
                                      onGirisSonrasi: () {
                                        setState(() {
                                          _selectedTabIndex = 3;
                                          _cezaSigortaSubTab = 0;
                                        });
                                      },
                                    );
                                  },
                                  onCikisYap: () {
                                    setState(() {
                                      _girisYapildiMi = false;
                                      _kullaniciAdi = 'Misafir Kullanıcı';
                                    });
                                    if (widget.onCikisYap != null) {
                                      widget.onCikisYap!();
                                    }
                                  },
                                  girisYapildiMi: _girisYapildiMi,
                                  kullaniciAdi: _kullaniciAdi,
                                  onGirisYap: () => _girisEkraniniAc(),
                                )
                              : _buildDashboardTab()),
                    ),
                  ),
                ),
              ),

            // Üst Header / Karşılama Barı (Sadece Panel ve Ceza sekmelerinde gösterilir)
            if (_selectedTabIndex == 0 || _selectedTabIndex == 3)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildTopHeaderBar(),
              ),

            // 5 Sekmeli Modern Alt Navigasyon Barı (E-Denetim + Menü Rozeti)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomNavigationBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Hızlı Ceza & Radar Arama Barı (EN ÜSTTE)
        _buildQuickSearchBar(),
        const SizedBox(height: 10),

        // 2. Resmi KKTC Kamu Ağı ve Sunucu Durum Şeridi (Canlı Bağlantı)
        const KamuSunucuDurumSeridi(turkceMi: true),
        const SizedBox(height: 12),

        // 3. Ehliyet & Sağlık Skoru Özet Kartı
        _buildDriverScoreCard(),
        const SizedBox(height: 20),

        // 4. Kayıtlı Araç Seçici (Yatay Kaydırma)
        _buildVehicleSelector(),
        const SizedBox(height: 20),

        // 5. 2x2 Ferah Hızlı Erişim Grid Kartları
        _buildQuickActionGrid(),
        const SizedBox(height: 20),

        // 6. Son Durum / Canlı Uyarı Kartı
        _buildLiveViolationCard(),
        const SizedBox(height: 12),
      ],
    );
  }

  // Hızlı Arama Modalı Açıcı
  void _openSearchModal() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HizliAramaModalSayfasi(
        turkceMi: true,
        onHedefeGit: (hedefId) {},
      ),
    );
  }

  // 🗺️ POI Konum Arama Modalı (Haritalar Sekmesi)
  void _openPoiAramaModal() {
    HapticFeedback.lightImpact();
    final TextEditingController aramaCtrl = TextEditingController();
    List<KktcHaritaPoi> sonuclar = List.from(kktcHaritaPoiListesi);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
          return Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Container(
              height: MediaQuery.of(ctx).size.height * 0.70,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Tutamaç
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 4),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: cNavy, size: 22),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Konum Ara',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: cNavy,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.grey),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  // Arama Kutusu
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: aramaCtrl,
                        autofocus: false,
                        decoration: const InputDecoration(
                          hintText: 'Benzinlik, hastane, otopark...',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey, size: 20),
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            final q = val.toLowerCase().trim();
                            sonuclar = q.isEmpty
                                ? List.from(kktcHaritaPoiListesi)
                                : kktcHaritaPoiListesi
                                    .where((p) =>
                                        p.ad.toLowerCase().contains(q) ||
                                        p.adres.toLowerCase().contains(q) ||
                                        p.kategori.toLowerCase().contains(q))
                                    .toList();
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Sonuçlar
                  Expanded(
                    child: sonuclar.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                Text('Sonuç bulunamadı', style: TextStyle(color: Colors.grey.shade500)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: sonuclar.length,
                            itemBuilder: (_, i) {
                              final poi = sonuclar[i];
                              return ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: poi.renk.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(poi.ikon, color: poi.renk, size: 20),
                                ),
                                title: Text(
                                  poi.ad,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                                subtitle: Text(
                                  poi.adres,
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Text(
                                  poi.mesafe,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cNavy),
                                ),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  setState(() {
                                    _seciliPoiKategori = poi.kategori;
                                    _seciliPoi = poi;
                                  });
                                  _haritaOsmKey.currentState?.flyToLocation(poi.lat, poi.lon, zoom: 14.0);
                                },
                              );
                            },
                          ),
                  ),
                  SizedBox(height: MediaQuery.of(ctx).padding.bottom + 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Hızlı Ceza, Radar ve Mevzuat Arama Çubuğu
  Widget _buildQuickSearchBar() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openSearchModal,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cSoft),
            boxShadow: [
              BoxShadow(
                color: cNavy.withOpacity(0.025),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, size: 20, color: cSlate),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Ceza, radar veya kanun maddesi ara...',
                  style: TextStyle(
                    color: cSlate,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: cBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cSoft),
                ),
                child: const Text(
                  '2026',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: cNavy,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 🗺️ GOOGLE MAPS TARZI TAM EKRAN CANLI HARİTA (TAB 1: HARİTALAR)
  // ===========================================================================
  Widget _buildFullScreenHaritalarTab() {
    // Seçili kategoriye göre POI filtrele
    final List<KktcHaritaPoi> gosterilecekPoiler = _seciliPoiKategori == 'tumu'
        ? []
        : kktcHaritaPoiListesi.where((p) => p.kategori == _seciliPoiKategori).toList();

    return Stack(
      children: [
        // 1. ZEMİN: TAM EKRAN ETKİLEŞİMLİ OPENSTREETMAP HARİTASI
        Positioned.fill(
          child: KktcOpenStreetMapTileView(
            key: _haritaOsmKey,
            radarlar: const [],
            seciliRadar: null,
            onRadarSelected: (_) {},
            turkceMi: true,
            radarlariGoster: false,
            gosterUstBar: false,
            poiNoktalari: gosterilecekPoiler,
            seciliPoi: _seciliPoi,
            onPoiSelected: (poi) {
              setState(() => _seciliPoi = poi);
              HapticFeedback.mediumImpact();
            },
          ),
        ),

        // 2. ÜST: ARAMA ÇUBUĞU
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 14,
          right: 14,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Arama Kartı (Beyaz Glassmorphism, Yuvarlatılmış Köşeler)
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black.withOpacity(0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: _openPoiAramaModal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: Color(0xFF1E293B), size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Benzinlik, otopark, hastane ara...',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 20,
                            color: Colors.grey.shade300,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                          IconButton(
                            icon: const Icon(Icons.my_location_rounded, color: Color(0xFF0284C7), size: 20),
                            tooltip: 'Konumuma Git',
                            onPressed: () => _haritaOsmKey.currentState?.centerOnUserOrKktc(),
                          ),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: cNavy,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                'TRNC',
                                style: TextStyle(
                                  color: cLime,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // 🗂️ POI KATEGORİ HAPLARI (GOOGLE MAPS TARZI)
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildPoiCategoryChip(
                      id: 'tumu',
                      label: 'Tüm KKTC',
                      icon: Icons.map_rounded,
                      onTap: () {
                        setState(() {
                          _seciliPoiKategori = 'tumu';
                          _seciliPoi = null;
                        });
                        _haritaOsmKey.currentState?.centerOnKktc();
                      },
                    ),
                    _buildPoiCategoryChip(
                      id: 'benzin',
                      label: '⛽ Benzinlikler',
                      icon: Icons.local_gas_station_rounded,
                      onTap: () {
                        setState(() {
                          _seciliPoiKategori = 'benzin';
                          _seciliPoi = null;
                        });
                      },
                    ),
                    _buildPoiCategoryChip(
                      id: 'tamir',
                      label: '🔧 Lastik & Tamir',
                      icon: Icons.build_circle_rounded,
                      onTap: () {
                        setState(() {
                          _seciliPoiKategori = 'tamir';
                          _seciliPoi = null;
                        });
                      },
                    ),
                    _buildPoiCategoryChip(
                      id: 'otopark',
                      label: '🅿️ Otoparklar',
                      icon: Icons.local_parking_rounded,
                      onTap: () {
                        setState(() {
                          _seciliPoiKategori = 'otopark';
                          _seciliPoi = null;
                        });
                      },
                    ),
                    _buildPoiCategoryChip(
                      id: 'hastane',
                      label: '🏥 Hastaneler',
                      icon: Icons.local_hospital_rounded,
                      onTap: () {
                        setState(() {
                          _seciliPoiKategori = 'hastane';
                          _seciliPoi = null;
                        });
                      },
                    ),
                    _buildPoiCategoryChip(
                      id: '__yol',
                      label: '🧭 Yol Tarifi',
                      icon: Icons.directions_rounded,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        final hedef = _seciliPoi?.toRotaNoktasi() ??
                            _seciliRadarKamerasi?.toRotaNoktasi();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => YolTarifiSayfasi(
                              turkceMi: true,
                              varisNoktasi: hedef,
                              otomatikNavigasyonBaslat: hedef != null,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // ⛽ CANLI AKARYAKIT FİYATLARI BİLGİ ŞERİDİ (Benzinlikler seçiliyken)
              if (_seciliPoiKategori == 'benzin') ...[
                const SizedBox(height: 8),
                _buildLiveAkaryakitFiyatBanner(),
              ],
            ],
          ),
        ),

        // 3. SAĞ: ZOOM KONTROL BUTONLARI
        Positioned(
          right: 14,
          top: MediaQuery.of(context).padding.top + (_seciliPoiKategori == 'benzin' ? 185 : 108),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFloatingMapButton(
                icon: Icons.layers_rounded,
                tooltip: 'Harita Katmanı',
                onTap: () {
                  HapticFeedback.selectionClick();
                  _showHaritaKatmaniSheet();
                },
              ),
              const SizedBox(height: 10),
              _buildFloatingMapButton(
                icon: Icons.add_rounded,
                tooltip: 'Yakınlaştır',
                onTap: () {
                  HapticFeedback.selectionClick();
                  _haritaOsmKey.currentState?.zoomIn();
                },
              ),
              const SizedBox(height: 8),
              _buildFloatingMapButton(
                icon: Icons.remove_rounded,
                tooltip: 'Uzaklaştır',
                onTap: () {
                  HapticFeedback.selectionClick();
                  _haritaOsmKey.currentState?.zoomOut();
                },
              ),
              const SizedBox(height: 10),
              _buildFloatingMapButton(
                icon: Icons.my_location_rounded,
                tooltip: 'Canlı GPS Konumum',
                iconColor: const Color(0xFF0284C7),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _haritaOsmKey.currentState?.centerOnUserOrKktc();
                },
              ),
            ],
          ),
        ),

        // 4. ŞEHIR HIZLI ATLAMA (sol altta, küçük)
        Positioned(
          bottom: _seciliPoi != null ? 220 : 14,
          left: 14,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMiniCityJumpButton('🏛 Lefkoşa', () => _haritaOsmKey.currentState?.flyToLocation(35.1856, 33.3823, zoom: 12.0)),
              const SizedBox(height: 6),
              _buildMiniCityJumpButton('🏰 Girne', () => _haritaOsmKey.currentState?.flyToLocation(35.3387, 33.3175, zoom: 12.0)),
              const SizedBox(height: 6),
              _buildMiniCityJumpButton('⚓ Gazimağusa', () => _haritaOsmKey.currentState?.flyToLocation(35.1250, 33.9400, zoom: 12.0)),
            ],
          ),
        ),

        // 5. ALT: SEÇİLİ POI DETAY KARTI (Google Maps tarzı alt panel)
        if (_seciliPoi != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildPoiDetayKarti(_seciliPoi!),
          ),

        // 6. KATEGORİ YOKSA KARŞILAMA MESAJI
        if (_seciliPoiKategori == 'tumu')
          Positioned(
            bottom: 28,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cNavy.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.explore_rounded, color: cNavy, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Harita Keşfi',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: cNavy,
                          ),
                        ),
                        Text(
                          'Üstteki kategorileri seçerek KKTC\'deki benzinlikleri, servisleri ve daha fazlasını keşfedin',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ⛽ CANLI AKARYAKIT FİYATLARI ŞERİDİ (Resmi Gazete / Bakanlar Kurulu Tavan Fiyatları)
  Widget _buildLiveAkaryakitFiyatBanner() {
    final fiyatlar = _akaryakitServisi.fiyatlar;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE11D48).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_gas_station_rounded,
                  color: Color(0xFFE11D48),
                  size: 15,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KKTC RESMİ AKARYAKIT TARİFESİ',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: cNavy,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      'Bakanlar Kurulu / Resmi Gazete Azami Tavan Tarifesi',
                      style: TextStyle(
                        fontSize: 9,
                        color: cSlate,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (_akaryakitServisi.yukleniyor)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: cNavy),
                )
              else
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    final ok = await _akaryakitServisi.canliFiyatlariGuncelle();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok
                              ? 'Canlı akaryakıt verileri güncellendi.'
                              : 'Güncel 2026 tavan fiyat tarifesi devrede.'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF10B981).withOpacity(0.25)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sync_rounded, size: 12, color: Color(0xFF10B981)),
                        SizedBox(width: 4),
                        Text(
                          'CANLI',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF047857),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildYakitMiniFiyatChip(
                  etiket: 'Euro Diesel (Motorin)',
                  fiyat: '${fiyatlar.euroDiesel.toStringAsFixed(2)} ₺',
                  vurgulu: true,
                ),
                const SizedBox(width: 6),
                _buildYakitMiniFiyatChip(
                  etiket: 'Kurşunsuz 95',
                  fiyat: '${fiyatlar.kursunsuz95.toStringAsFixed(2)} ₺',
                ),
                const SizedBox(width: 6),
                _buildYakitMiniFiyatChip(
                  etiket: 'Kurşunsuz 98',
                  fiyat: '${fiyatlar.kursunsuz98.toStringAsFixed(2)} ₺',
                ),
                const SizedBox(width: 6),
                _buildYakitMiniFiyatChip(
                  etiket: 'Gaz Yağı',
                  fiyat: '${fiyatlar.gazYagi.toStringAsFixed(2)} ₺',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYakitMiniFiyatChip({
    required String etiket,
    required String fiyat,
    bool vurgulu = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: vurgulu ? const Color(0xFF047857).withOpacity(0.1) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: vurgulu ? const Color(0xFF10B981).withOpacity(0.35) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiket,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: vurgulu ? FontWeight.w700 : FontWeight.w500,
              color: vurgulu ? const Color(0xFF047857) : const Color(0xFF64748B),
            ),
          ),
          Text(
            fiyat,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: vurgulu ? const Color(0xFF065F46) : cNavy,
            ),
          ),
        ],
      ),
    );
  }

  // ─── POI KATEGORİ HAP (GOOGLE MAPS STYLE CHIP) ───────────────────────────
  Widget _buildPoiCategoryChip({
    required String id,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final bool isActive = _seciliPoiKategori == id || (id == '__yol');
    final bool isSelected = _seciliPoiKategori == id;
    return Container(
      margin: const EdgeInsets.only(right: 7),
      child: Material(
        color: isSelected ? cNavy : Colors.white,
        borderRadius: BorderRadius.circular(99),
        elevation: isSelected ? 4 : 2,
        shadowColor: isSelected ? cNavy.withOpacity(0.4) : Colors.black.withOpacity(0.12),
        child: InkWell(
          borderRadius: BorderRadius.circular(99),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── MİNİ ŞEHİR ATLAMA BUTONU ─────────────────────────────────────────────
  Widget _buildMiniCityJumpButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: cNavy,
          ),
        ),
      ),
    );
  }

  // ─── SEÇİLİ POI DETAY ALTI KARTI ──────────────────────────────────────────
  Widget _buildPoiDetayKarti(KktcHaritaPoi poi) {
    return Container(
      margin: const EdgeInsets.only(left: 0, right: 0, bottom: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sürükleme Göstergesi
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 2),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık Satırı
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: poi.renk.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: poi.renk.withOpacity(0.4), width: 1.5),
                      ),
                      child: Center(
                        child: Icon(poi.ikon, color: poi.renk, size: 22),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            poi.ad,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: cNavy,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  poi.calismaSaatleri,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF047857),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${poi.mesafe} • ${poi.sure}',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _seciliPoi = null),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, size: 16, color: Colors.grey),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Adres
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 13, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        poi.adres,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Yakıt Fiyatları (benzinlik ise göster)
                if (poi.kategori == 'benzin' || poi.yakitFiyatlari.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text(
                        'Akaryakıt Tarifesi',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: cNavy,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'CANLI TARİFE',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF047857),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: (poi.kategori == 'benzin'
                              ? _akaryakitServisi.guncelYakitFiyatlariMap
                              : poi.yakitFiyatlari)
                          .entries
                          .map((e) {
                        final bool isMotorin = e.key.toLowerCase().contains('diesel') ||
                            e.key.toLowerCase().contains('motorin');
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isMotorin
                                ? const Color(0xFF047857).withOpacity(0.08)
                                : cNavy.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isMotorin
                                  ? const Color(0xFF10B981).withOpacity(0.35)
                                  : cNavy.withOpacity(0.12),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                e.key,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: isMotorin ? const Color(0xFF047857) : cNavy,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                e.value,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isMotorin ? const Color(0xFF065F46) : cNavy,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],

                // Olanaklar
                if (poi.olanaklar.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: poi.olanaklar.map((o) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        o,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )).toList(),
                  ),
                ],

                const SizedBox(height: 12),

                // Aksyon Butonları
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.directions_rounded, size: 18),
                        label: const Text(
                          'Yol Tarifi Al',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => YolTarifiSayfasi(
                                turkceMi: true,
                                varisNoktasi: poi.toRotaNoktasi(),
                                otomatikNavigasyonBaslat: true,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Google Maps'te Aç
                    GestureDetector(
                      onTap: () => _openGoogleMaps(lat: poi.lat, lon: poi.lon, title: poi.ad),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                        ),
                        child: const Center(
                          child: Icon(Icons.open_in_new_rounded, color: Color(0xFF059669), size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Kapat
                    GestureDetector(
                      onTap: () => setState(() => _seciliPoi = null),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: const Center(
                          child: Icon(Icons.close_rounded, color: Colors.grey, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingMapButton({
    required IconData icon,
    required String tooltip,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: IconButton(
          icon: Icon(icon, size: 20, color: iconColor ?? const Color(0xFF1E293B)),
          tooltip: tooltip,
          onPressed: onTap,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  void _showHaritaKatmaniSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Harita Katmanı Seçin',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cNavy),
                ),
                const SizedBox(height: 14),
                ListTile(
                  leading: const Icon(Icons.map_outlined, color: Color(0xFF0284C7)),
                  title: const Text('OpenStreetMap Standart', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Tüm KKTC yolları, caddeler ve hız radarları'),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _radarHaritaModu = 1);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.satellite_alt_rounded, color: Color(0xFF10B981)),
                  title: const Text('Canlı GPS & Hız Radarları Katmanı', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Sabit kameralar, yönler ve hız toleransları'),
                  trailing: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
                  onTap: () {
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // RADARLAR & HIZ DENETİMİ TABI (HTML / TAILWIND ŞABLONUNUN BİREBİR UYARLAMASI)
  // ===========================================================================
  Widget _buildRadarlarTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Üst Başlık Barı (Geri Butonu, Canlı Trafik Rozeti ve Ses Açık/Kapalı Hapı)
        _buildRadarlarHeader(),
        const SizedBox(height: 14),

        // 2. Canlı Vektörel Harita Kartı (HUD ve Hız Limiti Overlay)
        _buildLiveMapCard(),
        const SizedBox(height: 16),

        // 3. Bölge & Kategori Filtre Hapları (Yatay Kaydırılabilir)
        _buildRadarFilterPills(),
        const SizedBox(height: 16),

        // 4. Sabit Radar Listesi
        _buildRadarListSection(),
        const SizedBox(height: 18),

        // 5. KKTC Radar Hız Tolerans & Ceza Bilgisi Kartı
        _buildSpeedPenaltyInfoCard(),
        const SizedBox(height: 10),
      ],
    );
  }

  // 1. ÜST BAŞLIK BARI
  Widget _buildRadarlarHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Sol: Geri Butonu + Başlık
            Row(
              children: [
                InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedTabIndex = 0);
                  },
                  borderRadius: BorderRadius.circular(99),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE8ECF2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: cNavy),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: cEmerald,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'KKTC CANLI TRAFİK',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: cSlate,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Radarlar & Kameralar',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: cNavy,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Sağ: Ses Açık / Kapalı Hap Butonu
            InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _sesliUyariAcik = !_sesliUyariAcik);
              },
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: _sesliUyariAcik ? const Color(0xFFD1FAE5) : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _sesliUyariAcik ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                      size: 16,
                      color: _sesliUyariAcik ? const Color(0xFF059669) : cSlate,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _sesliUyariAcik ? 'Ses: Açık' : 'Ses: Kapalı',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: _sesliUyariAcik ? const Color(0xFF059669) : cSlate,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // GPS Alt Durum Şeridi
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: cEmerald.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: cEmerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
                const Text(
                  'Hassas GPS Sinyali Aktif',
                  style: TextStyle(fontSize: 12, color: cSlate, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF8E9),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFD5ECC2)),
              ),
              child: const Text(
                'Rotada 4 Radar Var',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF065F46),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 2. CANLI VEKTÖREL HARİTA KARTI
  Widget _buildLiveMapCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8ECF2)),
        boxShadow: [
          BoxShadow(
            color: cNavy.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Harita Başlık Meta Şeridi & Mod Değiştirici
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _radarHaritaModu == 1 ? Icons.public_rounded : Icons.near_me_rounded,
                      size: 16,
                      color: _radarHaritaModu == 1 ? const Color(0xFF10B981) : cNavy,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _radarHaritaModu == 1 ? 'Canlı OpenStreetMap & GPS' : 'Lefkoşa - Girne Çevre Yolu',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: cNavy),
                    ),
                  ],
                ),
                // Mod Seçici: Canlı OSM / Vektör
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _radarHaritaModu = 1);
                        },
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _radarHaritaModu == 1 ? cNavy : Colors.transparent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'OSM Canlı',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _radarHaritaModu == 1 ? Colors.white : cSlate,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _radarHaritaModu = 0);
                        },
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _radarHaritaModu == 0 ? cNavy : Colors.transparent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Vektör',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _radarHaritaModu == 0 ? Colors.white : cSlate,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Harita Çerçevesi
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EEF5),
                border: Border.all(color: const Color(0xFFCBD5E1).withValues(alpha: 0.6)),
              ),
              child: Stack(
                children: [
                  // 1. Harita Katmanı (OpenStreetMap Tile View veya Vektör Harita)
                  Positioned.fill(
                    child: _radarHaritaModu == 1
                        ? KktcOpenStreetMapTileView(
                            key: _osmKey,
                            radarlar: kktcRadarListesi,
                            seciliRadar: _seciliRadarKamerasi ?? kktcRadarListesi.first,
                            turkceMi: true,
                            onRadarSelected: (radar) {
                              setState(() => _seciliRadarKamerasi = radar);
                              _showRadarDetailSheet(
                                radarAdi: radar.ad,
                                hiz: radar.hizLimiti.toString(),
                                mesafe: radar.mesafe,
                                tolerans: '${(radar.hizLimiti * 1.1).round()} km/s',
                                guzergah: radar.yon,
                                kameraTipi: radar.tur,
                                lat: radar.lat,
                                lon: radar.lon,
                              );
                            },
                          )
                        : AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: RadarVectorMapPainter(
                                  pulseValue: _pulseScaleAnimation.value,
                                ),
                              );
                            },
                          ),
                  ),

                  // Sol Üst: Güzergah / Radar Bilgi Etiketi (Glassmorphism)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: cEmerald,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _radarHaritaModu == 1
                                    ? (_seciliRadarKamerasi?.ad ?? 'KKTC Radar Ağı')
                                    : 'Lefkoşa ➔ Girne',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Sağ Üst: Harita Kontrol Düğmeleri
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Column(
                      children: [
                        if (_radarHaritaModu == 1) ...[
                          _buildMapToolButton(
                            Icons.add_rounded,
                            tooltip: 'Yakınlaştır',
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _osmKey.currentState?.zoomIn();
                            },
                          ),
                          const SizedBox(height: 5),
                          _buildMapToolButton(
                            Icons.remove_rounded,
                            tooltip: 'Uzaklaştır',
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _osmKey.currentState?.zoomOut();
                            },
                          ),
                          const SizedBox(height: 5),
                        ],
                        _buildMapToolButton(
                          Icons.my_location_rounded,
                          tooltip: 'Konuma Odaklan',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            if (_radarHaritaModu == 1) {
                              _osmKey.currentState?.centerOnUserOrKktc();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Harita mevcut konumunuza ve güzergaha odaklandı.'),
                                  duration: Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 5),
                        _buildMapToolButton(
                          Icons.layers_rounded,
                          tooltip: 'Katman Değiştir',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            if (_radarHaritaModu == 1) {
                              _osmKey.currentState?.toggleMapStyle();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Harita katmanı değiştirildi (OSM / Uydu / Canlı).'),
                                  duration: Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } else {
                              setState(() => _radarHaritaModu = 1);
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  // Ortadaki Gönyeli Radar Tooltip Etiketi (Yalnızca Vektör Modunda)
                  if (_radarHaritaModu == 0)
                    Positioned(
                      top: 80,
                      left: 140,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: cNavy,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 2)),
                          ],
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFACC15),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'Gönyeli 500m',
                              style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Sağ Alt: Entegre Hız HUD ve LİMİT Tabelası
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Hız Kartı
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2)),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'HIZINIZ',
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      color: cSlate,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: const [
                                      Text(
                                        '68',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: cNavy,
                                          height: 1,
                                        ),
                                      ),
                                      SizedBox(width: 2),
                                      Text('km/s', style: TextStyle(fontSize: 9, color: cSlate, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Resmi Kırmızı Halka Hız Sınırı Tabelası
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFEF4444), width: 3.5),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 3)),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('LİMİT', style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w900, color: Color(0xFF334155), height: 1)),
                              Text(
                                '${(_seciliRadarKamerasi ?? kktcRadarListesi.first).hizLimiti}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: cNavy, height: 1.1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Harita Altı Hızlı Aksiyon Şeridi (Google Maps & Tam Ekran)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: const Icon(Icons.radar_rounded, color: Color(0xFFD97706), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _seciliRadarKamerasi != null
                                ? 'Seçili: ${_seciliRadarKamerasi!.ad}'
                                : 'En Yakın: Gönyeli Çemberi',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: cNavy),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Kamera: ${(_seciliRadarKamerasi ?? kktcRadarListesi.first).mesafe} • Limit: ${(_seciliRadarKamerasi ?? kktcRadarListesi.first).hizLimiti} km/s',
                            style: const TextStyle(fontSize: 11, color: cSlate),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // 🌟 YOL TARİFİ BUTONU (Akıllı Rota & Navigasyon)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981), // Emerald Green
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  elevation: 2,
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  final hedef = _seciliPoi?.toRotaNoktasi() ??
                      (_seciliRadarKamerasi ?? kktcRadarListesi.first).toRotaNoktasi();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => YolTarifiSayfasi(
                        turkceMi: true,
                        varisNoktasi: hedef,
                        otomatikNavigasyonBaslat: true,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.directions_rounded, size: 15, color: Colors.white),
                label: const Text(
                  'Yol Tarifi',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
                ),
              ),
              const SizedBox(width: 6),

              // 🌟 GOOGLE MAPS İLE AÇ BUTONU (Doğrudan Google Maps Uygulaması / Tarayıcısına Bağlar)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A73E8), // Google Blue
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  elevation: 2,
                ),
                onPressed: () {
                  final radar = _seciliRadarKamerasi ?? kktcRadarListesi.first;
                  _openGoogleMaps(
                    lat: radar.lat,
                    lon: radar.lon,
                    title: radar.ad,
                  );
                },
                icon: const Icon(Icons.location_on_rounded, size: 15, color: Colors.white),
                label: const Text(
                  'Google Maps',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
                ),
              ),
              const SizedBox(width: 6),

              // 🌟 TAM EKRAN HARİTA BUTONU (Gerçek Tam Ekran OpenStreetMap & Canlı Radar Denetimi)
              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KktcTamEkranHaritaSayfasi(
                        turkceMi: true,
                        baslangicRadari: _seciliRadarKamerasi,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: cNavy,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: cNavy.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapToolButton(IconData icon, {VoidCallback? onTap, String? tooltip}) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFCBD5E1)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 1)),
            ],
          ),
          child: Icon(icon, size: 16, color: cNavy),
        ),
      ),
    );
  }

  // 3. FİLTRE HAPLARI
  Widget _buildRadarFilterPills() {
    final filters = [
      'Yakınımdakiler (4)',
      'Tümü (28)',
      'Lefkoşa (11)',
      'Girne (9)',
      'Gazimağusa (5)',
      'Mobil Çevirme (3)',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = _radarFiltreIndex == index;
          return Padding(
            padding: EdgeInsets.only(right: index == filters.length - 1 ? 0 : 8),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _radarFiltreIndex = index);
              },
              borderRadius: BorderRadius.circular(999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? cNavy : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected ? cNavy : const Color(0xFFE8ECF2),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: cNavy.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  filters[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : cNavy,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // 4. RADAR LİSTESİ BÖLÜMÜ
  Widget _buildRadarListSection() {
    final List<Map<String, dynamic>> allRadars = [
      {
        'hiz': '65',
        'ad': 'Gönyeli Çemberi Kamerası',
        'mesafe': '500 m',
        'guzergah': 'Lefkoşa - Girne Çıkışı • Çift Yönlü',
        'durum': 'Aktif ve Denetimde',
        'tolerans': '71 km/s',
        'tip': 'Çift Yönlü Sabit Radar',
        'bolge': 'Lefkoşa',
        'lat': 35.2132,
        'lon': 33.3085,
        'isWarning': true,
        'isPulsing': true,
        'isNear': true,
      },
      {
        'hiz': '50',
        'ad': 'Boğaz Tepe Radar Noktası',
        'mesafe': '1.8 km',
        'guzergah': 'Viraj Girişi • Girne Yönü Tek Taraflı',
        'durum': 'Sabit Kutu Kamera',
        'tolerans': '55 km/s',
        'tip': 'Kutu Tipi Sabit Kamera',
        'bolge': 'Girne',
        'lat': 35.2785,
        'lon': 33.2845,
        'isNear': true,
      },
      {
        'hiz': '90',
        'ad': 'Gönyeli - Alayköy Çevre Yolu',
        'mesafe': '3.5 km',
        'guzergah': 'Bölünmüş Anayol • Çift Yönlü Geniş Açı',
        'durum': 'Dijital Direk Radar',
        'tolerans': '99 km/s',
        'tip': 'Dijital Direk Radar',
        'bolge': 'Lefkoşa',
        'lat': 35.2105,
        'lon': 33.2750,
        'isNear': true,
        'hizKutuRengi': const Color(0xFFEFF6FF),
        'hizYaziRengi': const Color(0xFF1E40AF),
      },
      {
        'hiz': '65',
        'ad': 'Değirmenlik Dağyolu Virajı',
        'mesafe': '5.2 km',
        'guzergah': 'Ağır Vasıta & Otomobil Takip Noktası',
        'durum': 'Aktif Kutu',
        'tolerans': '71 km/s',
        'tip': 'Ağır Vasıta Denetim Radarı',
        'bolge': 'Lefkoşa',
        'lat': 35.2600,
        'lon': 33.4500,
        'isNear': true,
      },
      {
        'hiz': '65',
        'ad': 'Ciklos Virajı Radar Noktası',
        'mesafe': '7.9 km',
        'guzergah': 'Lefkoşa - Girne Dağ Yolu İnişi',
        'durum': 'Aktif ve Denetimde',
        'tolerans': '71 km/s',
        'tip': 'Geniş Açı Sabit Radar',
        'bolge': 'Girne',
        'lat': 35.3050,
        'lon': 33.3100,
      },
      {
        'hiz': '50',
        'ad': 'Girne Alsancak Çevre Yolu',
        'mesafe': '13.4 km',
        'guzergah': 'Karaoğlanoğlu Caddesi Girişi',
        'durum': 'Aktif Kutu',
        'tolerans': '55 km/s',
        'tip': 'Sabit Kutu Kamera',
        'bolge': 'Girne',
        'lat': 35.3370,
        'lon': 33.2510,
      },
      {
        'hiz': '65',
        'ad': 'DAÜ Kampüs Girişi Radarı',
        'mesafe': '21.5 km',
        'guzergah': 'Gazimağusa İsmet İnönü Bulvarı',
        'durum': 'Aktif ve Denetimde',
        'tolerans': '71 km/s',
        'tip': 'Çift Yönlü Sabit Radar',
        'bolge': 'Gazimağusa',
        'lat': 35.1450,
        'lon': 33.9140,
      },
      {
        'hiz': '80',
        'ad': 'Gazimağusa Salamis Yolu',
        'mesafe': '25.8 km',
        'guzergah': 'Glapsides Kavşağı • Çift Yönlü',
        'durum': 'Dijital Direk Radar',
        'tolerans': '88 km/s',
        'tip': 'Dijital Radar',
        'bolge': 'Gazimağusa',
        'lat': 35.1865,
        'lon': 33.7510,
        'hizKutuRengi': const Color(0xFFEFF6FF),
        'hizYaziRengi': const Color(0xFF1E40AF),
      },
      {
        'hiz': '65',
        'ad': 'Haspolat Kavşağı Mobil Radar',
        'mesafe': '6.4 km',
        'guzergah': 'Ercan Havalimanı Yolu Çıkışı',
        'durum': 'Mobil Polis Ekibi',
        'tolerans': '71 km/s',
        'tip': 'Mobil Çevirme & Lazer Radar',
        'bolge': 'Mobil Çevirme',
        'lat': 35.2185,
        'lon': 33.4820,
        'isWarning': true,
      },
      {
        'hiz': '50',
        'ad': 'Karşıyaka Sahil Mobil Çevirme',
        'mesafe': '17.2 km',
        'guzergah': 'Lapta - Karşıyaka Sahil Güzergahı',
        'durum': 'Mobil Ekip',
        'tolerans': '55 km/s',
        'tip': 'Mobil Radar Denetimi',
        'bolge': 'Mobil Çevirme',
        'lat': 35.3520,
        'lon': 33.1580,
      },
    ];

    List<Map<String, dynamic>> displayedRadars;
    switch (_radarFiltreIndex) {
      case 0: // Yakınımdakiler
        displayedRadars = allRadars.where((r) => r['isNear'] == true).toList();
        break;
      case 1: // Tümü
        displayedRadars = allRadars;
        break;
      case 2: // Lefkoşa
        displayedRadars = allRadars.where((r) => r['bolge'] == 'Lefkoşa').toList();
        break;
      case 3: // Girne
        displayedRadars = allRadars.where((r) => r['bolge'] == 'Girne').toList();
        break;
      case 4: // Gazimağusa
        displayedRadars = allRadars.where((r) => r['bolge'] == 'Gazimağusa').toList();
        break;
      case 5: // Mobil Çevirme
        displayedRadars = allRadars.where((r) => r['bolge'] == 'Mobil Çevirme').toList();
        break;
      default:
        displayedRadars = allRadars.where((r) => r['isNear'] == true).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.circle, size: 8, color: Color(0xFFF59E0B)),
                const SizedBox(width: 6),
                Text(
                  _radarFiltreIndex == 5 ? 'MOBİL ÇEVİRME NOKTALARI' : 'GÜZERGAHTAKİ SABİT RADARLAR',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: cSlate,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
            Text(
              '${displayedRadars.length} Kayıt',
              style: const TextStyle(fontSize: 11, color: cSlate, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...displayedRadars.map((radar) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildRadarCardItem(
              hizLimiti: radar['hiz'] as String,
              radarAdi: radar['ad'] as String,
              mesafe: radar['mesafe'] as String,
              guzergah: radar['guzergah'] as String,
              durum: radar['durum'] as String,
              tolerans: radar['tolerans'] as String,
              kameraTipi: radar['tip'] as String,
              lat: radar['lat'] as double?,
              lon: radar['lon'] as double?,
              isWarning: radar['isWarning'] == true,
              isPulsingDistance: radar['isPulsing'] == true,
              hizKutuRengi: radar['hizKutuRengi'] as Color?,
              hizYaziRengi: radar['hizYaziRengi'] as Color?,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRadarCardItem({
    required String hizLimiti,
    required String radarAdi,
    required String mesafe,
    required String guzergah,
    required String durum,
    required String tolerans,
    required String kameraTipi,
    double? lat,
    double? lon,
    bool isWarning = false,
    bool isPulsingDistance = false,
    Color? hizKutuRengi,
    Color? hizYaziRengi,
  }) {
    return InkWell(
      onTap: () {
        // İlgili radara tıklandığında haritayı oraya odakla
        if (lat != null && lon != null) {
          _osmKey.currentState?.flyToLocation(lat, lon, zoom: 12.5);
        }
        _showRadarDetailSheet(
          radarAdi: radarAdi,
          hiz: hizLimiti,
          mesafe: mesafe,
          tolerans: tolerans,
          guzergah: guzergah,
          kameraTipi: kameraTipi,
          lat: lat,
          lon: lon,
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isWarning ? const Color(0xFFFCD34D) : const Color(0xFFE8ECF2),
            width: isWarning ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isWarning ? const Color(0xFFF59E0B).withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Hız Kutusu
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: hizKutuRengi ?? (isWarning ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isWarning ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'HIZ',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      color: hizYaziRengi ?? (isWarning ? const Color(0xFFB45309) : cSlate),
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hizLimiti,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: hizYaziRengi ?? (isWarning ? const Color(0xFF92400E) : cNavy),
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Orta Bilgi Alanı
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          radarAdi,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: cNavy),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: isPulsingDistance ? const Color(0xFFFEE2E8) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          mesafe,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: isPulsingDistance ? const Color(0xFFB91C1C) : cSlate,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    guzergah,
                    style: const TextStyle(fontSize: 11, color: cSlate),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 12, color: cEmerald),
                      const SizedBox(width: 4),
                      Text(
                        durum,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                      ),
                      const SizedBox(width: 6),
                      const Text('•', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 10)),
                      const SizedBox(width: 6),
                      Text(
                        'Tolerans: $tolerans',
                        style: const TextStyle(fontSize: 10, color: cSlate),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),

            // Sağ Aksiyon Düğmesi (Google Maps İkonu)
            InkWell(
              onTap: () {
                if (lat != null && lon != null) {
                  _openGoogleMaps(lat: lat, lon: lon, title: radarAdi);
                } else {
                  _openGoogleMaps(title: radarAdi);
                }
              },
              borderRadius: BorderRadius.circular(99),
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.near_me_rounded, size: 18, color: Color(0xFF1D4ED8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5. KKTC RADAR CEZA BİLGİSİ REHBERİ
  Widget _buildSpeedPenaltyInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8ECF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDBEAFE)),
            ),
            child: const Icon(Icons.info_outline_rounded, color: Color(0xFF1D4ED8), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KKTC RADAR HIZ TOLERANS & CEZA BİLGİSİ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: cNavy,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Sabit hız radarlarında yasal hız limitine +%10 tolerans uygulanır. Hız aşımı cezaları KKTC brüt asgari ücret katsayısına ve aşım oranına göre (5 ila 25 ceza puanı) işlenmektedir.',
                  style: TextStyle(fontSize: 11.5, color: cSlate, height: 1.4),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _showTarifeDetayDialog(),
                  child: const Text(
                    'Tarife Detaylarını Görüntüle',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                      decoration: TextDecoration.underline,
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

  void _showRadarDetailSheet({
    required String radarAdi,
    required String hiz,
    required String mesafe,
    required String tolerans,
    required String guzergah,
    required String kameraTipi,
    double? lat,
    double? lon,
  }) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    radarAdi,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: cNavy),
                  ),
                ),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 10),
            _buildInfoRow('Yasal Hız Limiti:', '$hiz km/s', isBold: true),
            const SizedBox(height: 8),
            _buildInfoRow('Fotoğraf Çekim Toleransı:', tolerans),
            const SizedBox(height: 8),
            _buildInfoRow('Şu Anki Mesafe:', mesafe),
            const SizedBox(height: 8),
            _buildInfoRow('Kamera Tipi:', kameraTipi),
            const SizedBox(height: 8),
            _buildInfoRow('Konum Hattı:', guzergah),
            const SizedBox(height: 18),
            Row(
              children: [
                // 🌟 YOL TARİFİ AL BUTONU
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981), // Emerald Green
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 2,
                    ),
                    onPressed: () {
                      final hedefRota = RotaNoktasi(
                        id: 'radar_sheet_${radarAdi.hashCode}',
                        ad: '$radarAdi ($hiz km/s)',
                        adEn: '$radarAdi ($hiz km/h)',
                        kisaAd: radarAdi,
                        bolge: guzergah,
                        lat: lat ?? 35.1856,
                        lon: lon ?? 33.3823,
                        ikon: Icons.camera_alt_rounded,
                      );
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => YolTarifiSayfasi(
                            turkceMi: true,
                            varisNoktasi: hedefRota,
                            otomatikNavigasyonBaslat: true,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.directions_rounded, size: 18, color: Colors.white),
                    label: const Text('Yol Tarifi Al', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 8),

                // 🌟 GOOGLE MAPS İLE AÇ BUTONU
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A73E8), // Google Blue
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 2,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _openGoogleMaps(
                        lat: lat ?? 35.2132,
                        lon: lon ?? 33.3085,
                        title: radarAdi,
                      );
                    },
                    icon: const Icon(Icons.location_on_rounded, size: 18, color: Colors.white),
                    label: const Text('Google Maps', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 🌟 TAM EKRAN HARİTADA GÖSTER
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: cNavy,
                  side: const BorderSide(color: cNavy, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  RadarKamerasi? hedefKamera;
                  try {
                    hedefKamera = kktcRadarListesi.firstWhere((r) => r.ad == radarAdi);
                  } catch (_) {}
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KktcTamEkranHaritaSayfasi(
                        turkceMi: true,
                        baslangicRadari: hedefKamera,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.fullscreen_rounded, size: 20),
                label: const Text('Tam Ekran Haritada Odaklan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTarifeDetayDialog() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'KKTC Hız Cezaları Tarifesi',
          style: TextStyle(fontWeight: FontWeight.w800, color: cNavy, fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('1 - 20 km/s Aşım:', '₺1.850,00 (5 Puan)'),
            const Divider(height: 16),
            _buildInfoRow('21 - 40 km/s Aşım:', '₺3.700,00 (10 Puan)'),
            const Divider(height: 16),
            _buildInfoRow('41 km/s ve Üzeri:', '₺7.400,00 (25 Puan)'),
            const SizedBox(height: 12),
            const Text(
              '* Yasal hız limitinin %10\'una kadar tolerans tanınır. 15 gün içerisinde ödenen cezalarda %30 indirim uygulanır.',
              style: TextStyle(fontSize: 11.5, color: cSlate),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anladım', style: TextStyle(fontWeight: FontWeight.bold, color: cNavy)),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // CEZALAR & SİGORTA TABI (TAM İNTERAKTİF, DETAYLI VE ÖDEME DESTEKLİ)
  // ===========================================================================
  Widget _buildCezalarVeSigortaTab() {
    if (!_girisYapildiMi) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: cSoft),
            boxShadow: [
              BoxShadow(
                color: cNavy.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: cNavy.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 32,
                  color: cNavy,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Giriş Yapılması Gerekiyor',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: cNavy,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Kişisel radar cezalarınızı, seyrüsefer harçlarınızı, fenni muayene ve araç sigorta dökümlerinizi görüntülemek için KKTC Kimlik veya Ehliyet numaranız ile giriş yapmalısınız.',
                style: TextStyle(
                  fontSize: 13,
                  color: cSlate,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _girisEkraniniAc(
                      onSuccess: () {
                        setState(() {
                          _selectedTabIndex = 3;
                        });
                      },
                    );
                  },
                  icon: const Icon(Icons.login_rounded, size: 18, color: cLime),
                  label: const Text(
                    'Kimlik / Ehliyet ile Giriş Yap',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cNavy,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  setState(() => _selectedTabIndex = 0);
                },
                child: const Text(
                  'Ana Panele Geri Dön',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: cSlate,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // Üst Başlık & Dinamik Rozet
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cezalar & Sigorta',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: cNavy,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _cezaSigortaSubTab == 0
                      ? 'Radar & Trafik İhlal Takibi'
                      : (_cezaSigortaSubTab == 1
                          ? 'Seyrüsefer Harcı & Ruhsat Durumu'
                          : 'Poliçeler & Fenni Muayene'),
                  style: const TextStyle(fontSize: 12, color: cSlate),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _cezaOdendi ? const Color(0xFFECFDF5) : const Color(0xFFFFECEB),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: _cezaOdendi ? cEmerald : const Color(0xFFD90429),
                  width: 1.2,
                ),
              ),
              child: Text(
                _cezaOdendi ? 'TÜMÜ GÜNCEL' : '1 ÖDENMEMİŞ',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: _cezaOdendi ? cEmerald : const Color(0xFFD90429),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Segmented Sub-Tab Switcher (3 Sekmeli Şık Hap Kapsül)
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0).withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _buildSubTabItem(
                title: 'Cezalarım',
                badgeText: _cezaOdendi ? null : '1',
                index: 0,
                icon: Icons.receipt_long_rounded,
              ),
              _buildSubTabItem(
                title: 'Seyrüsefer',
                badgeText: _seyruseferYenilendi ? '✓' : '86g',
                index: 1,
                icon: Icons.directions_car_filled_rounded,
              ),
              _buildSubTabItem(
                title: 'Sigorta',
                badgeText: null,
                index: 2,
                icon: Icons.shield_rounded,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Alt Sekme İçeriği
        if (_cezaSigortaSubTab == 0)
          _buildCezalarSubTabContent()
        else if (_cezaSigortaSubTab == 1)
          _buildSeyruseferSubTabContent()
        else
          _buildSigortaVeMuayeneSubTabContent(),
      ],
    );
  }

  Widget _buildSubTabItem({
    required String title,
    required String? badgeText,
    required int index,
    required IconData icon,
  }) {
    final bool isSelected = _cezaSigortaSubTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _cezaSigortaSubTab = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8.5, horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13.5,
                color: isSelected ? cNavy : cSlate,
              ),
              const SizedBox(width: 3.5),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? cNavy : cSlate,
                  ),
                ),
              ),
              if (badgeText != null) ...[
                const SizedBox(width: 3.5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1),
                  decoration: BoxDecoration(
                    color: index == 0
                        ? (isSelected ? const Color(0xFFD90429) : const Color(0xFFD90429).withOpacity(0.85))
                        : (isSelected ? cNavy : cSlate),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 1. TRAFİK CEZALARI İÇERİĞİ
  Widget _buildCezalarSubTabContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_cezaOdendi) ...[
          // Özet Banner Kartı (Hemen Öde ve %30 İndirim Vurgusu)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [cNavy, Color(0xFF071B5C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: cNavy.withOpacity(0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Toplam Ödenecek Ceza',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '₺1.850,00',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cLime,
                        foregroundColor: cNavy,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onPressed: () => _openCezaDetayVeOdemeModal(),
                      icon: const Icon(Icons.flash_on_rounded, size: 18),
                      label: const Text(
                        'Hemen Öde',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.timer_outlined, color: cLime, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Erken ödemede %30 indirim (Kalan 4 Gün): ₺1.295,00',
                          style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Aktif Ceza Kartı (Gönyeli Çemberi Radarı)
          InkWell(
            onTap: () => _openCezaDetayVeOdemeModal(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFCA5A5).withOpacity(0.6), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFECEB),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'SABİT RADAR İHLALİ',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFD90429),
                          ),
                        ),
                      ),
                      const Text(
                        '18 Mayıs 2024 • 14:22',
                        style: TextStyle(fontSize: 11, color: cSlate),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Gönyeli Çemberi Radarı',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: cNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tespit Edilen Hız: 78 km/s (Yasal Limit: 65 km/s)',
                    style: TextStyle(fontSize: 12.5, color: cSlate),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ceza Puanı: +10 Puan • Tebliğ No: PGM-2024-8841',
                    style: TextStyle(fontSize: 11.5, color: cSlate),
                  ),
                  const SizedBox(height: 12),

                  // Radar Delil Fotoğrafı Önizlemesi (İçine girilebilir)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        SizedBox(
                          height: 110,
                          width: double.infinity,
                          child: Image.network(
                            'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=800',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFF1E293B),
                              child: const Center(
                                child: Icon(Icons.videocam_rounded, color: Colors.white54, size: 36),
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.5),
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.8),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'CAM-04-GONYELI',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: cLime,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'KRİPTOLU DELİL',
                                        style: TextStyle(
                                          color: cNavy,
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'PLAKA: RZ 123 [TRNC]',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: const [
                                        Icon(Icons.zoom_in_rounded, color: Colors.white, size: 14),
                                        SizedBox(width: 4),
                                        Text(
                                          'Büyüt',
                                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Alt Aksiyon Butonları (Öde & İncele)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 12, color: cSlate),
                          children: [
                            TextSpan(text: 'Tutar: '),
                            TextSpan(
                              text: '₺1.850,00',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                color: cNavy,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: cNavy,
                              side: const BorderSide(color: cNavy),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            onPressed: () => _delilDosyasiGoster(),
                            icon: const Icon(Icons.image_search_rounded, size: 15),
                            label: const Text('Delil İncele', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cNavy,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            onPressed: () => _openCezaDetayVeOdemeModal(),
                            icon: const Icon(Icons.credit_card_rounded, size: 15),
                            label: const Text('Öde', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          // Ceza Ödendikten Sonraki Başarı Durumu
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: cEmerald.withOpacity(0.5), width: 1.2),
            ),
            child: Column(
              children: [
                const Icon(Icons.verified_rounded, color: cEmerald, size: 48),
                const SizedBox(height: 10),
                const Text(
                  'Tebrikler! Borcunuz Bulunmuyor',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF065F46),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Adınıza kayıtlı tüm radar ve trafik cezaları ödenmiş ve PGM veri tabanında ibra edilmiştir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF047857)),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cEmerald,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BarkodluBelgeSayfasi(
                          kullanici: 'Ahmet Demir',
                          puan: 95,
                          turkceMi: true,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.qr_code_rounded, size: 16),
                  label: const Text('Son Tahsilat Makbuzunu / QR İndir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),

        // Ödenmiş Geçmiş Cezalar
        const Text(
          'Ödenmiş Geçmiş Cezalar',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: cNavy,
          ),
        ),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cSoft),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: cEmerald, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Haspolat Çevre Yolu Radarı',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: cNavy),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '24 Ocak 2024 • #KKTC-2024-110294',
                        style: TextStyle(fontSize: 11, color: cSlate),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '₺1.200,00',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w900,
                      color: cNavy,
                      fontSize: 13,
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(40, 20),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DekontlarSayfasi(
                            dekontlar: [
                              {
                                'cezaId': 'PGM-2024-110294',
                                'cezaAdi': 'Haspolat Çevre Yolu Radarı',
                                'tarih': '24 Ocak 2024',
                                'tutar': '₺1.200,00',
                                'plaka': 'RZ 123',
                                'dekontNo': 'DK-9921',
                              },
                            ],
                            turkceMi: true,
                          ),
                        ),
                      );
                    },
                    child: const Text('Makbuz', style: TextStyle(fontSize: 11, color: cNavy, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // İtiraz Talebi Oluştur Butonu
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              foregroundColor: cNavy,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ItirazSayfasi(turkceMi: true),
                ),
              );
            },
            icon: const Icon(Icons.gavel_rounded, size: 18),
            label: const Text(
              'Cezaya İtiraz Talebi Oluştur',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  // 2. SEYRÜSEFER & RUHSAT İÇERİĞİ
  Widget _buildSeyruseferSubTabContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Aktif Araç Bilgi Şeridi
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cSoft),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: cNavy.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.directions_car_rounded, color: cNavy, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'RZ 123 • BMW 3.20i M-Sport',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: cNavy),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Şasi: WBA319084 • 2022 Model',
                            style: TextStyle(fontSize: 10.5, color: cSlate),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'KAYITLI',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: cEmerald),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Seyrüsefer Durum Kartı (İçine girilip yenilenebilir)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cSoft),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Seyrüsefer Harcı Durumu',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: cNavy),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _seyruseferYenilendi ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _seyruseferYenilendi ? 'GÜNCEL (365 GÜN)' : '86 GÜN KALDI',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: _seyruseferYenilendi ? cEmerald : const Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Dönem:', _seyruseferYenilendi ? '2027 / 1. Yıllık Dönem' : '2026 / 2. Dönem'),
                    const Divider(height: 16, color: Color(0xFFE2E8F0)),
                    _buildInfoRow('Son Geçerlilik:', _seyruseferYenilendi ? '26 Aralık 2027' : '26 Aralık 2026'),
                    const Divider(height: 16, color: Color(0xFFE2E8F0)),
                    _buildInfoRow(
                      'Harç Tutarı:',
                      _seyruseferYenilendi ? '₺0,00 (Ödendi)' : '₺3.450,00 (İndirimli ₺3.105)',
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Yenileme ve Belge Butonları
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cNavy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _openSeyruseferYenilemeModal(),
                      icon: const Icon(Icons.autorenew_rounded, size: 16),
                      label: Text(
                        _seyruseferYenilendi ? 'Yeniden İncele' : 'Erken Yenile (%10 İndirim)',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cNavy,
                      side: const BorderSide(color: cNavy),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BarkodluBelgeSayfasi(
                            kullanici: 'Ahmet Demir',
                            puan: 85,
                            turkceMi: true,
                          ),
                        ),
                      );
                    },
                    child: const Icon(Icons.qr_code_2_rounded, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Dijital Araç Ruhsatı
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cSoft),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dijital Araç Ruhsatı (Koçan)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: cNavy),
                  ),
                  IconButton(
                    icon: const Icon(Icons.open_in_new_rounded, size: 18, color: cNavy),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BarkodluBelgeSayfasi(
                            kullanici: 'Ahmet Demir',
                            puan: 85,
                            turkceMi: true,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'KKTC Bayındırlık ve Ulaştırma Bakanlığı Trafik Dairesi onaylı resmi e-Ruhsat belgenizi barkodlu olarak görüntüleyebilirsiniz.',
                style: TextStyle(fontSize: 12, color: cSlate),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 3. SİGORTA & MUAYENE İÇERİĞİ
  Widget _buildSigortaVeMuayeneSubTabContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Zorunlu Trafik Sigortası Kartı
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFCD34D), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.shield_rounded, color: Color(0xFFD97706), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Zorunlu Trafik Sigortası',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: cNavy),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Dağlı Sigorta A.Ş. • #DGL-2026-TRF-9921',
                          style: TextStyle(fontSize: 10.5, color: cSlate),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '12 GÜN KALDI',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFFD97706)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Poliçenizin son geçerlilik tarihi 14 Ekim 2026\'dır. Cezai duruma düşmemek için süresi dolmadan acenteniz ile yenileyiniz.',
                style: TextStyle(fontSize: 12, color: cSlate),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cNavy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () => _openSigortaDetayModal(),
                      icon: const Icon(Icons.description_rounded, size: 16),
                      label: const Text('Poliçe Detayları & Acente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Kasko Poliçesi Kartı
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cSoft),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.verified_user_rounded, color: cEmerald, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Genişletilmiş Kasko',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: cNavy),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Kıbrıs Sigorta Koop. • #KSK-4102',
                          style: TextStyle(fontSize: 10.5, color: cSlate),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '248 GÜN',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: cEmerald),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Tam Kapsamlı (Çarpma, Yangın, Çalınma, Ferdi Kaza, 7/24 Yol Yardım Dahil).',
                style: TextStyle(fontSize: 12, color: cSlate),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Fenni Muayene Takvimi Kartı
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cSoft),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Araç Fenni Muayene Takvimi',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: cNavy),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '48 GÜN KALDI',
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: cNavy),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Son Muayene: 09 Mayıs 2026 • İstasyon: Lefkoşa Sanayi Muayene Şubesi',
                style: TextStyle(fontSize: 12, color: cSlate),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cNavy,
                    side: const BorderSide(color: cNavy),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () => _openMuayeneRandevuModal(),
                  icon: const Icon(Icons.calendar_today_rounded, size: 16),
                  label: const Text('Online Muayene Randevusu Al', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String title, String val, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 12.5, color: cSlate)),
        Text(
          val,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: isBold ? cNavy : const Color(0xFF1E293B),
            fontFamily: isBold ? 'monospace' : null,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // İNTERAKTİF MODALLAR: CEZA ÖDEME, DELİL GÖRÜNTÜLEME & SEYRÜSEFER YENİLEME
  // ===========================================================================

  // 1. TAM TEŞEKKÜLLÜ CEZA DETAY & ÖDEME MODALI
  void _openCezaDetayVeOdemeModal() {
    HapticFeedback.mediumImpact();
    bool isProcessing = false;
    int selectedCard = 0; // 0: Garanti Bonus, 1: Cardplus

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.88,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                // Modal Tutamacı
                Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),

                // Başlık
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ceza Tebliği & Güvenli Ödeme',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: cNavy,
                            ),
                          ),
                          Text(
                            'Tebliğ No: PGM-2024-8841 • KKTC Polis Gn. Md.',
                            style: TextStyle(fontSize: 11, color: cSlate),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded, color: cSlate),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                // Kaydırılabilir Detay Alanı
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kriptolu Radar Görseli
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 160,
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=800',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: const Color(0xFF0F172A),
                                    child: const Center(
                                      child: Icon(Icons.speed_rounded, color: Colors.white54, size: 48),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.6),
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.85),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.65),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'CAM-04-GONYELI',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontFamily: 'monospace',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: cLime,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'KRİPTOLU DELİL',
                                              style: TextStyle(
                                                color: cNavy,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'PLAKA: RZ 123 [TRNC]',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontFamily: 'monospace',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Text(
                                            'HIZ: 78 km/s (LİMİT: 65)',
                                            style: TextStyle(
                                              color: Color(0xFFFCA5A5),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
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
                        ),
                        const SizedBox(height: 16),

                        // Ceza Parametreleri Tablosu
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow('İhlal Yeri:', 'Gönyeli Çemberi Sabit Radarı'),
                              const Divider(height: 14, color: Color(0xFFE2E8F0)),
                              _buildInfoRow('İhlal Türü:', 'Sürat Sınırını 1-20 km/s Aşmak'),
                              const Divider(height: 14, color: Color(0xFFE2E8F0)),
                              _buildInfoRow('Ceza Puanı:', '+10 Puan'),
                              const Divider(height: 14, color: Color(0xFFE2E8F0)),
                              _buildInfoRow('Yasal Tutar:', '₺1.850,00'),
                              const Divider(height: 14, color: Color(0xFFE2E8F0)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    '15 Gün Erken Ödeme İndirimi (%30):',
                                    style: TextStyle(fontSize: 11.5, color: Color(0xFF059669), fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '-₺555,00',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Ödeme Kartı Seçici
                        const Text(
                          'Ödeme Yöntemi Seçin',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: cNavy),
                        ),
                        const SizedBox(height: 8),

                        _buildCardOption(
                          title: 'Garanti BBVA Bonus •••• 4412',
                          subtitle: 'KKTC / Türkiye Kredi Kartı • 3D Secure',
                          isSelected: selectedCard == 0,
                          onTap: () => setModalState(() => selectedCard = 0),
                        ),
                        const SizedBox(height: 8),
                        _buildCardOption(
                          title: 'KKTC Cardplus •••• 8820',
                          subtitle: 'Yerel Banka Kartı • Tek Çekim',
                          isSelected: selectedCard == 1,
                          onTap: () => setModalState(() => selectedCard = 1),
                        ),
                      ],
                    ),
                  ),
                ),

                // Alt Ödeme Butonu Çubuğu
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cNavy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: isProcessing
                            ? null
                            : () async {
                                setModalState(() => isProcessing = true);
                                await Future.delayed(const Duration(milliseconds: 1200));
                                if (mounted) {
                                  Navigator.pop(ctx);
                                  setState(() {
                                    _cezaOdendi = true;
                                  });
                                  HapticFeedback.heavyImpact();
                                  _showOdemeBasariliDialog();
                                }
                              },
                        child: isProcessing
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  ),
                                  SizedBox(width: 10),
                                  Text('Güvenli Tahsilat İşleniyor...', style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              )
                            : const Text(
                                'İndirimli Güvenli Ödeme Yap (₺1.295,00)',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? cEmerald : const Color(0xFFCBD5E1),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  color: isSelected ? cEmerald : cSlate,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: cNavy,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: cSlate),
                    ),
                  ],
                ),
              ],
            ),
            const Icon(Icons.credit_card_rounded, color: cNavy, size: 20),
          ],
        ),
      ),
    );
  }

  void _showOdemeBasariliDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: cEmerald, size: 36),
            ),
            const SizedBox(height: 14),
            const Text(
              'Ödeme Başarıyla Alındı!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: cNavy,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'PGM-2024-8841 numaralı ceza tutarı (₺1.295,00) tahsil edilerek resmi kamu veri tabanından düşülmüştür.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: cSlate),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BarkodluBelgeSayfasi(
                        kullanici: 'Ahmet Demir',
                        puan: 95,
                        turkceMi: true,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.receipt_rounded, size: 16),
                label: const Text('Resmi Makbuz & Barkodlu Belge', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. SEYRÜSEFER YENİLEME MODALI
  void _openSeyruseferYenilemeModal() {
    HapticFeedback.mediumImpact();
    bool isProcessing = false;
    int selectedDonem = 0; // 0: 1 Yıllık (₺3.105), 1: 6 Aylık (₺1.665)

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.78,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seyrüsefer Harcı Erken Yenileme',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: cNavy),
                          ),
                          Text('Bayındırlık ve Ulaştırma Bakanlığı • RZ 123', style: TextStyle(fontSize: 11, color: cSlate)),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded, color: cSlate),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Yenileme Dönemi Seçin',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: cNavy),
                        ),
                        const SizedBox(height: 10),

                        InkWell(
                          onTap: () => setModalState(() => selectedDonem = 0),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selectedDonem == 0 ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selectedDonem == 0 ? cEmerald : const Color(0xFFCBD5E1),
                                width: selectedDonem == 0 ? 1.8 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      selectedDonem == 0 ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                      color: selectedDonem == 0 ? cEmerald : cSlate,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text('1 Yıllık Tam Dönem (2027)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: cNavy)),
                                        Text('Erken ödemede %10 kamu indirimi', style: TextStyle(fontSize: 11, color: cEmerald)),
                                      ],
                                    ),
                                  ],
                                ),
                                const Text(
                                  '₺3.105,00',
                                  style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, color: cNavy, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        InkWell(
                          onTap: () => setModalState(() => selectedDonem = 1),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selectedDonem == 1 ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selectedDonem == 1 ? cEmerald : const Color(0xFFCBD5E1),
                                width: selectedDonem == 1 ? 1.8 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      selectedDonem == 1 ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                      color: selectedDonem == 1 ? cEmerald : cSlate,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text('6 Aylık Yarı Dönem', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: cNavy)),
                                        Text('Erken yenileme harcı', style: TextStyle(fontSize: 11, color: cSlate)),
                                      ],
                                    ),
                                  ],
                                ),
                                const Text(
                                  '₺1.665,00',
                                  style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, color: cNavy, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        const Text('Ödeme Kartı: Garanti BBVA Bonus (•••• 4412)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cSlate)),
                      ],
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(18),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cNavy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: isProcessing
                            ? null
                            : () async {
                                setModalState(() => isProcessing = true);
                                await Future.delayed(const Duration(milliseconds: 1100));
                                if (mounted) {
                                  Navigator.pop(ctx);
                                  setState(() {
                                    _seyruseferYenilendi = true;
                                  });
                                  HapticFeedback.heavyImpact();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: cEmerald,
                                      content: Text('Seyrüsefer harcınız yenilendi ve dijital pul üretildi!'),
                                    ),
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const BarkodluBelgeSayfasi(
                                        kullanici: 'Ahmet Demir',
                                        puan: 85,
                                        turkceMi: true,
                                      ),
                                    ),
                                  );
                                }
                              },
                        child: isProcessing
                            ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                            : Text(
                                selectedDonem == 0 ? 'Ödeme Yap & Pulu Üret (₺3.105,00)' : 'Ödeme Yap & Pulu Üret (₺1.665,00)',
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 3. SİGORTA DETAY MODALI
  void _openSigortaDetayModal() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Zorunlu Trafik Sigortası Detayı',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: cNavy),
                ),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 10),
            _buildInfoRow('Sigorta Şirketi:', 'Dağlı Sigorta A.Ş.'),
            const SizedBox(height: 8),
            _buildInfoRow('Poliçe No:', 'DGL-2026-TRF-9921'),
            const SizedBox(height: 8),
            _buildInfoRow('Bitiş Tarihi:', '14 Ekim 2026 (12 Gün Kaldı)'),
            const SizedBox(height: 8),
            _buildInfoRow('Teminat Kapsamı:', '₺1.000.000 3. Şahıs Mali Mes.'),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cNavy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dağlı Sigorta Lefkoşa Acentesi Aranıyor: 0392 228 11 22')),
                      );
                    },
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                    label: const Text('Acenteyi Ara (0392 228 11 22)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 4. MUAYENE RANDEVU MODALI
  void _openMuayeneRandevuModal() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Online Fenni Muayene Randevusu',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: cNavy),
                ),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Lefkoşa Sanayi Polis Muayene Şubesi için müsait saatler taranıyor.',
              style: TextStyle(fontSize: 12, color: cSlate),
            ),
            const SizedBox(height: 14),
            _buildInfoRow('Seçili İstasyon:', 'Lefkoşa Sanayi Muayene Şubesi'),
            const SizedBox(height: 8),
            _buildInfoRow('En Erken Tarih:', '12 Mayıs 2026 • 10:30'),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: cEmerald,
                      content: Text('Muayene randevunuz 12 Mayıs 2026 Saat 10:30 olarak onaylandı!'),
                    ),
                  );
                },
                icon: const Icon(Icons.event_available_rounded, size: 16),
                label: const Text('Randevuyu Onayla & Takvime Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5. TAM EKRAN RADAR DELİL GÖRÜNTÜLEME
  void _delilDosyasiGoster() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kriptolu Radar Delil Kaydı',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=1200',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 250,
                  color: Colors.black45,
                  child: const Center(
                    child: Icon(Icons.speed_rounded, color: Colors.white54, size: 64),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'CAM-04-GONYELI • 18.05.2024 14:22:08',
                    style: TextStyle(fontFamily: 'monospace', color: cLime, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tespit: 78 km/s (Azami Hız Sınırı: 65 km/s) • Plaka: RZ 123',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildHesabimTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        const Text(
          'Dijital Sürücü Belgesi & Profil',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: cNavy,
          ),
        ),
        const SizedBox(height: 14),

        // Ehliyet QR Kartı (Resmi Polis Doğrulama)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [cNavy, Color(0xFF071B5C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: cNavy.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield_rounded, color: cLime, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'KKTC POLİS GENEL MD.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: cLime,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'ONAYLI',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: cNavy,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // QR Kodu Görseli / Konteyneri
              Container(
                width: 140,
                height: 140,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Icon(
                    Icons.qr_code_2_rounded,
                    size: 116,
                    color: cNavy,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Ahmet Demir',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'TC/KKTC No: 21894019284 • Ehliyet No: TRNC-2024-8841',
                style: TextStyle(color: Colors.white70, fontSize: 11.5),
              ),
              const SizedBox(height: 4),
              const Text(
                'Ehliyet Sınıfları: A2, B, D • Geçerlilik: 2032',
                style: TextStyle(color: cLime, fontSize: 11.5, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Hızlı İşlem Satırları
        Container(
          decoration: BoxDecoration(
            color: cCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cSoft),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.file_download_outlined, color: cNavy),
                title: const Text('Dijital Ehliyet PDF İndir', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: cSlate),
                onTap: () => _showInfoDialog(title: 'PDF İndirme', message: 'Resmi karekodlu ehliyet belgeniz cihaza indirildi.'),
              ),
              const Divider(height: 1, color: cSoft),
              ListTile(
                leading: const Icon(Icons.security_rounded, color: cNavy),
                title: const Text('Polis Doğrulama Modu', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: cSlate),
                onTap: () => _showInfoDialog(title: 'Polis Denetim Modu', message: 'Karekod tam parlaklıkta ekrana yansıtılıyor.'),
              ),
              const Divider(height: 1, color: cSoft),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Color(0xFFD90429)),
                title: const Text('Güvenli Çıkış Yap', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: Color(0xFFD90429))),
                onTap: () {
                  setState(() {
                    _girisYapildiMi = false;
                    _kullaniciAdi = 'Misafir Kullanıcı';
                  });
                  if (widget.onCikisYap != null) {
                    widget.onCikisYap!();
                  } else {
                    _showInfoDialog(title: 'Çıkış Yapıldı', message: 'Güvenli oturumunuz sonlandırıldı, misafir modundasınız.');
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Çıkış Yapılsın mı?', style: TextStyle(fontWeight: FontWeight.w800, color: cNavy)),
        content: const Text('Oturumunuz kapatılacak ve misafir moduna geçilecektir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal', style: TextStyle(color: cSlate)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _girisYapildiMi = false;
                _kullaniciAdi = 'Misafir Kullanıcı';
              });
              if (widget.onCikisYap != null) {
                widget.onCikisYap!();
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Oturum kapatıldı, misafir modundasınız.'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 1. ÜST HEADER / KARŞILAMA BARI
  // ===========================================================================
  Widget _buildTopHeaderBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.97),
            border: Border(
              bottom: BorderSide(
                color: cSoft.withOpacity(0.7),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Sol: Profil Avatarı ve Karşılama
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: cNavy,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: cNavy.withOpacity(0.18),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _girisYapildiMi
                                ? Text(
                                    _kullaniciAdi.isNotEmpty
                                        ? (_kullaniciAdi.length >= 2
                                            ? _kullaniciAdi.substring(0, 2).toUpperCase()
                                            : _kullaniciAdi.toUpperCase())
                                        : 'AD',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      letterSpacing: 0.5,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person_outline_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _girisYapildiMi ? 'KKTC e-TRAFİK' : 'KKTC e-TRAFİK • MİSAFİR',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: cNavy,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: _girisYapildiMi ? cEmerald : cLimeDark,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _girisYapildiMi ? 'Merhaba, $_kullaniciAdi' : 'Hoş Geldiniz',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: cNavy,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Sağ: Giriş Yap Butonu (Giriş Yapılmadıysa) VEYA Oturum / Bildirim İkonları
                  if (!_girisYapildiMi)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _girisEkraniniAc();
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7.5),
                          decoration: BoxDecoration(
                            color: cNavy,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: cNavy.withOpacity(0.22),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.login_rounded, size: 15, color: cLime),
                              SizedBox(width: 5),
                              Text(
                                'Giriş Yap',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeaderIconButton(
                          icon: Icons.car_repair_rounded,
                          onTap: () {
                            _showYolYardimBottomSheet();
                          },
                        ),
                        const SizedBox(width: 6),
                        _buildHeaderIconButton(
                          icon: Icons.notifications_rounded,
                          showDot: !_cezaOdendi,
                          onTap: () {
                            _showInfoDialog(
                              title: 'Bildirimler',
                              message: _cezaOdendi
                                  ? 'Okunmamış yeni bildiriminiz bulunmuyor.'
                                  : '1 adet yeni radar ihlal bildiriminiz bulunmaktadır.',
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        _buildHeaderIconButton(
                          icon: Icons.logout_rounded,
                          onTap: () {
                            _showLogoutConfirmDialog();
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool showDot = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 37,
          height: 37,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cSoft),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 20, color: cNavy),
              if (showDot)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: cLime,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 2. EHLİYET & SAĞLIK SKORU ÖZET KARTI
  // ===========================================================================
  Widget _buildDriverScoreCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _girisKontrolEt(
            islemAdi: 'Ehliyet sağlık puanı ve sürücü ceza dökümünü görüntülemek',
            onGirisSonrasi: () {
              _showInfoDialog(
                title: 'Ehliyet Sağlık Durumu',
                message: 'Puanınız: 85/100. Son 12 ayda 1 adet hız ihlalinden 15 ceza puanınız bulunmaktadır.',
              );
            },
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cSoft.withOpacity(0.85)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Sol Açıklama
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: cBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _girisYapildiMi ? cEmerald : cLimeDark,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _girisYapildiMi ? 'EHLİYET SAĞLIK PUANI' : 'EHLİYET SAĞLIK PUANI (KİLİTLİ)',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: cSlate,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _girisYapildiMi ? 'Güvenli Sürücü Seviyesi' : 'Puanınızı Görmek İçin Giriş Yapın',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: cNavy,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_girisYapildiMi)
                      Row(
                        children: [
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(fontSize: 11.5, color: cSlate),
                              children: [
                                TextSpan(text: 'Toplam Ceza: '),
                                TextSpan(
                                  text: '15 Puan',
                                  style: TextStyle(
                                    color: cNavy,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text('•', style: TextStyle(color: cSlate, fontSize: 11)),
                          ),
                          const Text(
                            'Sınıf: A2, B, D',
                            style: TextStyle(fontSize: 11.5, color: cSlate),
                          ),
                        ],
                      )
                    else
                      const Row(
                        children: [
                          Icon(Icons.lock_outline_rounded, size: 13, color: cSlate),
                          SizedBox(width: 4),
                          Text(
                            'Ceza ve ehliyet sınıfı dökümü için tıklayın',
                            style: TextStyle(fontSize: 11.5, color: cSlate, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Sağ Skor Rozeti
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: cNavy,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: cNavy.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _girisYapildiMi
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '85',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '/ 100',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: cSoft,
                            ),
                          ),
                        ],
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_rounded, color: cLime, size: 22),
                          SizedBox(height: 2),
                          Text(
                            'GİRİŞ',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 3. KAYITLI ARAÇ SEÇİCİ (YATAY SCROLL)
  // ===========================================================================
  Widget _buildVehicleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _girisYapildiMi
                  ? 'KAYITLI ARAÇLARIM (${_vehicles.length})'
                  : 'KAYITLI ARAÇLARIM (GİRİŞ GEREKLİ)',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: cSlate,
                letterSpacing: 0.6,
              ),
            ),
            GestureDetector(
              onTap: () {
                _girisKontrolEt(
                  islemAdi: 'Araç yönetim paneline erişmek',
                  onGirisSonrasi: () {
                    _showInfoDialog(
                      title: 'Araç Yönetimi',
                      message: 'Kayıtlı araçlarınızın muayene, sigorta ve seyrüsefer bilgilerini buradan yönetebilirsiniz.',
                    );
                  },
                );
              },
              child: const Text(
                'Tümünü Yönet',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cNavy,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 58,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              // Araç 1 (Aktif)
              _buildVehicleItem(
                index: 0,
                plate: _vehicles[0]['plate'],
                model: _vehicles[0]['model'],
                isSelected: _selectedVehicleIndex == 0,
              ),
              const SizedBox(width: 10),

              // Araç 2
              _buildVehicleItem(
                index: 1,
                plate: _vehicles[1]['plate'],
                model: _vehicles[1]['model'],
                isSelected: _selectedVehicleIndex == 1,
              ),
              const SizedBox(width: 10),

              // Araç Ekle Butonu
              _buildAddVehicleButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleItem({
    required int index,
    required String plate,
    required String model,
    required bool isSelected,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          _girisKontrolEt(
            islemAdi: 'Araç bilgilerini ve seyrüsefer durumunu görüntülemek',
            onGirisSonrasi: () {
              setState(() => _selectedVehicleIndex = index);
            },
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected && _girisYapildiMi ? cNavy : cCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected && _girisYapildiMi ? Colors.transparent : cSoft,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isSelected && _girisYapildiMi ? 0.12 : 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isSelected && _girisYapildiMi ? Colors.white.withOpacity(0.12) : cBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.directions_car_rounded,
                  size: 19,
                  color: isSelected && _girisYapildiMi ? Colors.white : cSlate,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        _girisYapildiMi ? plate : '*** ***',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isSelected && _girisYapildiMi ? Colors.white : cNavy,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (isSelected && _girisYapildiMi) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: cLime,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'AKTİF',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              color: cNavy,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _girisYapildiMi ? model : 'Giriş Yapın',
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected && _girisYapildiMi ? Colors.white.withOpacity(0.8) : cSlate,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddVehicleButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _girisKontrolEt(
            islemAdi: 'Yeni araç kaydetmek',
            onGirisSonrasi: () {
              _showInfoDialog(
                title: 'Yeni Araç Ekle',
                message: 'Plaka ve Koçan seri numaranızı girerek sisteme yeni araç kaydedebilirsiniz.',
              );
            },
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: cCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: cSoft,
              style: BorderStyle.solid,
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.add_circle_outline_rounded, size: 19, color: cSlate),
              SizedBox(width: 6),
              Text(
                'Araç Ekle',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cSlate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 4. 2x2 FERAH HIZLI ERİŞİM GRID KARTLARI
  // ===========================================================================
  Widget _buildQuickActionGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HIZLI İŞLEMLER & DURUM',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: cSlate,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.10,
          children: [
            // 1. Cezalarım Kartı
            _buildGridActionCard(
              icon: Icons.receipt_long_rounded,
              badgeWidget: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: _girisYapildiMi ? cLime : cSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _girisYapildiMi
                      ? (_cezaOdendi ? 'TEMİZ' : '1 ÖDENMEMİŞ')
                      : 'GİRİŞ GEREKLİ',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: _girisYapildiMi ? cNavy : cSlate,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              title: 'Cezalarım',
              bottomLabel: _girisYapildiMi ? 'Toplam Borç' : 'Sorgula',
              bottomValue: _girisYapildiMi ? (_cezaOdendi ? '₺0' : '₺1.850') : 'Giriş Yap',
              onTap: () {
                _girisKontrolEt(
                  islemAdi: 'Trafik cezalarınızı görüntülemek ve ödemek',
                  onGirisSonrasi: () {
                    setState(() {
                      _selectedTabIndex = 3;
                      _cezaSigortaSubTab = 0;
                    });
                    if (widget.onOpenFines != null) {
                      widget.onOpenFines!();
                    }
                  },
                );
              },
            ),

            // 2. Sigorta & Seyrüsefer Kartı
            _buildGridActionCard(
              icon: Icons.directions_car_filled_rounded,
              badgeWidget: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: _girisYapildiMi
                      ? (_seyruseferYenilendi ? const Color(0xFFECFDF5) : cSoft)
                      : cSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _girisYapildiMi
                      ? (_seyruseferYenilendi ? 'Güncel' : '86 Gün Kaldı')
                      : 'GİRİŞ GEREKLİ',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: _girisYapildiMi
                        ? (_seyruseferYenilendi ? cEmerald : cNavy)
                        : cSlate,
                  ),
                ),
              ),
              title: 'Seyrüsefer & Sigorta',
              subtitle: _girisYapildiMi
                  ? (_seyruseferYenilendi ? '2027 Harcı Ödendi' : '2026/2. Dönem')
                  : 'Araç Harç Durumu',
              onTap: () {
                _girisKontrolEt(
                  islemAdi: 'Seyrüsefer harcı ve sigorta poliçelerini görüntülemek',
                  onGirisSonrasi: () {
                    setState(() {
                      _selectedTabIndex = 3;
                      _cezaSigortaSubTab = 1;
                    });
                  },
                );
              },
            ),

            // 3. Sabit Radarlar Kartı
            _buildGridActionCard(
              icon: Icons.radar_rounded,
              badgeWidget: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: cLime,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: cLime.withOpacity(0.5),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              title: 'Haritalar & GPS',
              subtitle: 'Tam Ekran Canlı Harita',
              onTap: () {
                setState(() => _selectedTabIndex = 1);
              },
            ),

            // 4. 7/24 Yol Yardımı Kartı
            _buildGridActionCard(
              icon: Icons.car_repair_rounded,
              badgeWidget: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '7/24 ACİL',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              title: '7/24 Yol Yardımı',
              subtitle: 'Çekici, Akü & Acil Destek',
              onTap: _showYolYardimBottomSheet,
            ),
          ],
        ),
      ],
    );
  }

  // 🚗 7/24 Yol Yardımı ve Acil Çekici Modalı
  void _showYolYardimBottomSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white12),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tutamaç
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Başlık & 7/24 Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.18),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.4)),
                        ),
                        child: const Icon(
                          Icons.car_repair_rounded,
                          color: Color(0xFFEF4444),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '7/24 KKTC Yol Yardımı',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Acil Çekici, Akü, Lastik & Kurtarma',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.20),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.fiber_manual_record, color: Color(0xFF10B981), size: 9),
                        SizedBox(width: 5),
                        Text(
                          '7/24 AKTİF',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Anlık Canlı GPS Konum Kartı
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.my_location_rounded, color: Color(0xFF38BDF8), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Mevcut Konumunuz (Canlı GPS):',
                            style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Lefkoşa - Girne Çevre Yolu, Boğaz Mevkii',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_location_rounded, color: Color(0xFF38BDF8), size: 22),
                      tooltip: 'Konumu Ekiplere İlet',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('📍 GPS koordinatları yol yardım ekibine başarıyla iletildi.'),
                            backgroundColor: const Color(0xFF0284C7),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Hızlı Acil Butonları (Çekici Çağır & Polis 155)
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.phone_in_talk_rounded, size: 20),
                      label: const Text(
                        '0392 228 88 88 Ara',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                      onPressed: () async {
                        final Uri telUri = Uri.parse('tel:03922288888');
                        if (await canLaunchUrl(telUri)) {
                          await launchUrl(telUri);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.local_police_rounded, color: Color(0xFF38BDF8), size: 18),
                      label: const Text(
                        '155 Polis',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      onPressed: () async {
                        final Uri telUri = Uri.parse('tel:155');
                        if (await canLaunchUrl(telUri)) {
                          await launchUrl(telUri);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Hizmet Seçenekleri Izgarası
              const Text(
                'Hızlı Yardım Hizmetleri',
                style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildYolYardimActionTile(
                    icon: Icons.fire_truck_rounded,
                    title: 'Oto Çekici',
                    subtitle: '12 dk içinde',
                    color: const Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 8),
                  _buildYolYardimActionTile(
                    icon: Icons.battery_charging_full_rounded,
                    title: 'Akü Takviye',
                    subtitle: 'Yerinde servis',
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 8),
                  _buildYolYardimActionTile(
                    icon: Icons.tire_repair_rounded,
                    title: 'Lastik Onarım',
                    subtitle: 'Stepne & tamir',
                    color: const Color(0xFF38BDF8),
                  ),
                  const SizedBox(width: 8),
                  _buildYolYardimActionTile(
                    icon: Icons.local_gas_station_rounded,
                    title: 'Acil Yakıt',
                    subtitle: '5 Litre takviye',
                    color: const Color(0xFFA855F7),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Teminat & Ücretsiz Kapsam Bilgisi
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.25)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.shield_outlined, color: Color(0xFF10B981), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'KKTC Zorunlu Sigorta & Seyrüsefer kapsamında yılda 3 defa yol yardımı ve çekici tamamen ücretsizdir.',
                        style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildYolYardimActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: color.withOpacity(0.85), fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridActionCard({
    required IconData icon,
    required Widget badgeWidget,
    required String title,
    String? subtitle,
    String? bottomLabel,
    String? bottomValue,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cSoft.withOpacity(0.9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.025),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Üst Kısım: İkon ve Rozet
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: cBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 21, color: cNavy),
                  ),
                  badgeWidget,
                ],
              ),

              // Alt Kısım: Başlık ve Değer/Açıklama
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: cNavy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: cSlate,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  else if (bottomLabel != null && bottomValue != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            bottomLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: cSlate,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          bottomValue,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: cNavy,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 5. SON DURUM / CANLI UYARI KARTI
  // ===========================================================================
  Widget _buildLiveViolationCard() {
    if (!_girisYapildiMi) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cSoft.withOpacity(0.9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: cNavy,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'CEZA & İHLAL SORGULAMA',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: cNavy,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: cSoft,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'MİSAFİR MODU',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: cSlate,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      size: 20,
                      color: cNavy,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Radar ve İhlal Bildirimleri',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: cNavy,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Adınıza kayıtlı araçların cezalarını görmek için giriş yapın.',
                          style: TextStyle(
                            fontSize: 11,
                            color: cSlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _girisEkraniniAc();
                },
                icon: const Icon(Icons.login_rounded, size: 16, color: cLime),
                label: const Text(
                  'Kimlik / Ehliyet ile Giriş Yap',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cNavy,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cSoft.withOpacity(0.9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve Yanıp Sönen Canlı İndikatör
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) => Transform.scale(
                            scale: _pulseScaleAnimation.value,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: cLime.withOpacity(
                                    _pulseOpacityAnimation.value),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: cLimeDark,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'SON İHLAL BİLDİRİMİ',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: cNavy,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              const Text(
                '18 Mayıs 2024',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: cSlate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // İç Bilgi Kutusu (Açık Gri Arka Plan)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cBg,
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.speed_rounded,
                        size: 20,
                        color: cNavy,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gönyeli Çemberi Radarı',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: cNavy,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '78 km/s (Limit: 65 km/s)',
                          style: TextStyle(
                            fontSize: 11,
                            color: cSlate,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₺1.850,00',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: cNavy,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Son 15 gün',
                      style: TextStyle(
                        fontSize: 10,
                        color: cSlate,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Alt Detay ve Öde Aksiyon Satırı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 12, color: cSlate),
                  children: [
                    TextSpan(text: 'Plaka: '),
                    TextSpan(
                      text: 'RZ 123',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: cNavy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _showInfoDialog(
                      title: 'Ceza Ödeme Adımı',
                      message: 'Gönyeli Çemberi Radarı ₺1.850,00 tutarındaki cezanız için banka/kredi kartı ödeme ekranı açılıyor...',
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: cNavy,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Detay ve Öde',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 6. ALT NAVİGASYON BARI (5 SEKMELİ E-DENETİM & AKTİF MENÜ ROZETLİ)
  // ===========================================================================
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: cSoft.withOpacity(0.9),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: cNavy.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Panel
              _buildBottomNavItem(
                index: 0,
                icon: Icons.grid_view_rounded,
                label: 'Panel',
              ),
              // 2. Haritalar (Tab 1 - Google Maps Tarzı Tam Ekran Canlı Harita)
              _buildBottomNavItem(
                index: 1,
                icon: Icons.map_rounded,
                label: 'Haritalar',
                hasActiveYellowBadge: true,
              ),
              // 3. E-Denetim (Orta Yükseltilmiş Hızlı Buton)
              _buildCenterActionItem(
                label: 'E-Denetim',
                onTap: () {
                  HapticFeedback.heavyImpact();
                  _girisKontrolEt(
                    islemAdi: 'E-Denetim barkodlu dijital belge oluşturmak',
                    onGirisSonrasi: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BarkodluBelgeSayfasi(
                            kullanici: _kullaniciAdi,
                            puan: 85,
                            turkceMi: true,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              // 4. Ceza & Sigorta (Kırmızı Bildirim Noktalı)
              _buildBottomNavItem(
                index: 3,
                icon: Icons.receipt_long_rounded,
                label: 'Ceza & Sigorta',
                hasNotificationBadge: _girisYapildiMi && !_cezaOdendi,
                onCustomTap: () {
                  setState(() {
                    _selectedTabIndex = 3;
                    _cezaSigortaSubTab = 0;
                  });
                  if (widget.onOpenFines != null) {
                    widget.onOpenFines!();
                  }
                },
              ),
              // 5. Menü (Referans Tasarımdaki Vurgulu Hap Kapsülü)
              _buildBottomNavItem(
                index: 4,
                icon: Icons.menu_rounded,
                label: 'Menü',
                isMenuPill: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    required IconData icon,
    required String label,
    bool hasNotificationBadge = false,
    bool hasActiveYellowBadge = false,
    bool isMenuPill = false,
    VoidCallback? onCustomTap,
  }) {
    final bool isActive = _selectedTabIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            if (onCustomTap != null) {
              onCustomTap();
            } else {
              setState(() => _selectedTabIndex = index);
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isMenuPill && isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: cNavy.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 20, color: cNavy),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: cNavy,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          icon,
                          size: 21,
                          color: isActive ? cNavy : cSlate,
                        ),
                        if (hasNotificationBadge)
                          Positioned(
                            top: -1,
                            right: -3,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF43F5E),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                            ),
                          ),
                        if (hasActiveYellowBadge && isActive)
                          Positioned(
                            top: -1,
                            right: -3,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: cLime,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                            color: isActive ? cNavy : cSlate,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterActionItem({
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Transform.translate(
          offset: const Offset(0, -11),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cNavy,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF4F5F8), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: cNavy.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    color: cLime,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: cNavy,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// KKTC Radarlar & Kameralar Vektörel Harita Çizicisi
/// HTML SVG vektör harita tasarımının birebir CustomPainter karşılığıdır.
class RadarVectorMapPainter extends CustomPainter {
  final double pulseValue;

  RadarVectorMapPainter({required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    // 360 x 220 viewBox baz alınarak ölçeklendirme
    final double sx = size.width / 360.0;
    final double sy = size.height / 220.0;

    canvas.save();
    canvas.scale(sx, sy);

    // 1. Zemin Arka Planı (#EBF0F6)
    final bgPaint = Paint()..color = const Color(0xFFEBF0F6);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 360, 220), bgPaint);

    // 2. Arka Plan Yolları / Zemin Eğrileri (#DFE6EE)
    final landPathPaint1 = Paint()
      ..color = const Color(0xFFDFE6EE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final p1 = Path()
      ..moveTo(-20, 60)
      ..cubicTo(80, 50, 160, 80, 380, 40);
    canvas.drawPath(p1, landPathPaint1);

    final landPathPaint2 = Paint()
      ..color = const Color(0xFFDFE6EE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;

    final p2 = Path()
      ..moveTo(40, 240)
      ..cubicTo(120, 180, 240, 160, 390, 190);
    canvas.drawPath(p2, landPathPaint2);

    // 3. İkincil Bağlantı Yolları (#CBD5E1)
    final secRoadPaint1 = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final p3 = Path()
      ..moveTo(60, -10)
      ..lineTo(140, 230);
    canvas.drawPath(p3, secRoadPaint1);

    final secRoadPaint2 = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final p4 = Path()
      ..moveTo(280, -10)
      ..lineTo(210, 230);
    canvas.drawPath(p4, secRoadPaint2);

    // Beyaz İkincil Yol (#FFFFFF, strokeWidth 16)
    final whiteRoadPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    final p5 = Path()
      ..moveTo(-10, 140)
      ..quadraticBezierTo(180, 120, 370, 70);
    canvas.drawPath(p5, whiteRoadPaint);

    // 4. Ana Takip Edilen Güzergah (Yeşil Vurgu Koridoru)
    final routeCorridorPaint = Paint()
      ..color = const Color(0xFFA7F3D0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final routeMainPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final routePath = Path()
      ..moveTo(40, 210)
      ..quadraticBezierTo(140, 140, 330, 65);

    canvas.drawPath(routePath, routeCorridorPaint);
    canvas.drawPath(routePath, routeMainPaint);

    // 5. Radar Düğümü 1: Gönyeli Çemberi (210, 115) - En Yakın Radar
    final radar1Center = const Offset(210, 115);

    // Canlı Titreşen Halka (Pulsing Radar Ring)
    final double pulseRadius = 14.0 + (pulseValue * 7.0);
    final double pulseOpacity = ((2.4 - pulseValue) / 1.4).clamp(0.0, 0.6);
    final pulsePaint = Paint()
      ..color = const Color(0xFFFEF08A).withOpacity(pulseOpacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(radar1Center, pulseRadius, pulsePaint);

    // Sarı Radar Çemberi
    final radar1BasePaint = Paint()
      ..color = const Color(0xFFEAB308)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(radar1Center, 14, radar1BasePaint);

    // Beyaz Çerçeve
    final radar1BorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(radar1Center, 14, radar1BorderPaint);

    // Kahverengi Merkez Noktası
    final radar1CorePaint = Paint()
      ..color = const Color(0xFF713F12)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(radar1Center, 6, radar1CorePaint);

    // 6. Radar Düğümü 2: Boğaz Tepe Radarı (295, 78) - Mesafe 1.8 km
    final radar2Center = const Offset(295, 78);

    final radar2BasePaint = Paint()
      ..color = const Color(0xFF010E3C)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(radar2Center, 12, radar2BasePaint);

    final radar2BorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(radar2Center, 12, radar2BorderPaint);

    final radar2CorePaint = Paint()
      ..color = const Color(0xFFE6FB53)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(radar2Center, 4, radar2CorePaint);

    // 7. Kullanıcı Araç Pozisyon Düğümü (85, 175)
    final vehicleCenter = const Offset(85, 175);

    // Sarı Hare
    final vehicleAuraPaint = Paint()
      ..color = const Color(0xFFFACC15).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(vehicleCenter, 18, vehicleAuraPaint);

    // Araç Merkez Dairesi
    final vehicleBasePaint = Paint()
      ..color = const Color(0xFF010E3C)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(vehicleCenter, 13, vehicleBasePaint);

    final vehicleBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(vehicleCenter, 13, vehicleBorderPaint);

    // Yön Oku (Heading Indicator -40 derece)
    canvas.save();
    canvas.translate(85, 175);
    canvas.rotate(-40 * 3.141592653589793 / 180);

    final arrowPaint = Paint()
      ..color = const Color(0xFFE6FB53)
      ..style = PaintingStyle.fill;

    final arrowPath = Path()
      ..moveTo(-4, -3)
      ..lineTo(5, 0)
      ..lineTo(-4, 3)
      ..close();

    canvas.drawPath(arrowPath, arrowPaint);
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant RadarVectorMapPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue;
  }
}
