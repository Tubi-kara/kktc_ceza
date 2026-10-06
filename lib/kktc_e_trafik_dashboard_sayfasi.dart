import 'kktc_favori_noktalar_servisi.dart';
import 'kktc_tema_servisi.dart';
import 'kktc_dil_servisi.dart';
import 'dart:ui';
import 'dart:async';
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
import 'adres_arama_servisi.dart';
import 'canli_gps_servisi.dart';
import 'kktc_akaryakit_servisi.dart';
import 'yol_forum_modeli.dart';
import 'package:geolocator/geolocator.dart';
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
  // Renk Paleti (HTML tasarımındaki tokenlar ile birebir & Koyu Tema Uyumlu)
  static const Color cNavy = Color(0xFF010E3C);
  // 🌙 Koyu tema uyumlu dinamik metin & yüzey renkleri
  bool get isKoyu => KktcTemaServisi().isKoyuAktif;
  Color get cInk => KktcTemaServisi().isKoyuAktif ? const Color(0xFFF1F5F9) : cNavy;
  Color get cSurface => KktcTemaServisi().isKoyuAktif ? const Color(0xFF151D30) : Colors.white;
  Color get cSoftSurface => KktcTemaServisi().isKoyuAktif ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
  Color get cMuted => KktcTemaServisi().isKoyuAktif ? const Color(0xFF94A3B8) : cSlate;
  Color get cLine => KktcTemaServisi().isKoyuAktif ? const Color(0xFF243048) : const Color(0xFFE2E8F0);
  static const Color cSlate = Color(0xFF747675);
  Color get cSoft => KktcTemaServisi().isKoyuAktif ? const Color(0xFF243048) : const Color(0xFFE3E3E3);
  Color get cBg => KktcTemaServisi().isKoyuAktif ? const Color(0xFF0F172A) : const Color(0xFFF4F5F7);
  Color get cCard => KktcTemaServisi().isKoyuAktif ? const Color(0xFF151D30) : const Color(0xFFFFFFFF);
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
  DateTime _sigortaBitis = DateTime(2026, 10, 14);
  DateTime _fenniMuayeneBitis = DateTime(2026, 11, 2);
  bool _cezaOdendi = false;
  bool _seyruseferYenilendi = false;
  // Radarlar Sekmesi Durumları (HTML Şablonu ile Birebir)
  bool _sesliUyariAcik = true;
  int _radarFiltreIndex = 0;
  // Harita Modu: 1 = Canlı OpenStreetMap (Varsayılan), 0 = Taktiksel Vektör
  int _radarHaritaModu = 1;
  RadarKamerasi? _seciliRadarKamerasi;
  final GlobalKey<KktcOpenStreetMapTileViewState> _osmKey = GlobalKey<KktcOpenStreetMapTileViewState>();

  // 🗺️ HARİTALAR SEKMESİ - POI DURUMLARI
  final GlobalKey<KktcOpenStreetMapTileViewState> _haritaOsmKey = GlobalKey<KktcOpenStreetMapTileViewState>();
  final GlobalKey<KktcOpenStreetMapTileViewState> _dashboardMapKey = GlobalKey<KktcOpenStreetMapTileViewState>();
  String _seciliPoiKategori = 'tumu'; // 'tumu', 'avm', 'plaj', 'universite', 'havalimani', 'benzin', 'tamir', 'otopark', 'hastane'
  // 🏠 HIZLI GÜNLÜK NAVİGASYON (EV & İŞ)
  String _evimAdres = 'Evim (Gönyeli / Lefkoşa)';
  double _evimLat = 35.2130;
  double _evimLon = 33.3120;
  String _isimAdres = 'İşim (Dereboyu / Lefkoşa)';
  double _isimLat = 35.1915;
  double _isimLon = 33.3480;
  KktcHaritaPoi? _seciliPoi;
  final KktcAkaryakitServisi _akaryakitServisi = KktcAkaryakitServisi();

  // 🚦 YOL FORUMU DURUMLARI (Topluluk Bildirimleri, Çevirme, Kaza, Çalışma)
  List<YolForumBildirimi> _yolBildirimleri = getKktcBaslangicYolBildirimleri();
  YolForumBildirimi? _seciliYolBildirimi;
  String _seciliYolFiltresi = 'tumu'; // 'tumu', 'cevirme', 'kaza', 'calisma'
  final GlobalKey<KktcOpenStreetMapTileViewState> _yolForumOsmKey = GlobalKey<KktcOpenStreetMapTileViewState>();

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
    KktcFavoriNoktalarServisi().baslat();
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
        backgroundColor: cSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: TextStyle(
            color: cInk,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(color: cMuted, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Tamam',
              style: TextStyle(color: cInk, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([KktcTemaServisi(), KktcDilServisi()]),
      builder: (context, _) {
        final tema = KktcTemaServisi();
        final bool koyuMu = tema.isKoyu(context);

        return Scaffold(
          backgroundColor: tema.bg,
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: (koyuMu ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: tema.navBarBg,
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

                // Üst Header / Karşılama Barı (Sadece Panel ve Cezalar sekmelerinde gösterilir)
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
      },
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
        KamuSunucuDurumSeridi(turkceMi: KktcDilServisi().turkceMi),
        const SizedBox(height: 12),

        // 3. 🗺️ CANLI KKTC TRAFİK & RADAR HARİTASI (Doğrudan Ana Ekranda)
        _buildDashboardLiveMapCard(),
        const SizedBox(height: 18),

        // 4. 2x2 Ferah Hızlı Erişim Grid Kartları
        _buildQuickActionGrid(),
        const SizedBox(height: 20),

        // 5. Son Durum / Canlı Uyarı Kartı
        _buildLiveViolationCard(),
        const SizedBox(height: 12),
      ],
    );
  }

  // 🗺️ ANA PANEL CANLI İNTERAKTİF HARİTA KARTI
  Widget _buildDashboardLiveMapCard() {
    return Container(
      decoration: BoxDecoration(
        color: cSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cLine),
        boxShadow: [
          BoxShadow(
            color: cNavy.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık Satırı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.map_rounded,
                      color: Color(0xFF0284C7),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                            dil('CANLI KKTC TRAFİK & RADAR', 'LIVE TRNC TRAFFIC & RADAR'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: cMuted,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        dil('Canlı Yol & Harita', 'Live Traffic & Map'),
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: cInk,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedTabIndex = 1);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: cNavy.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cNavy.withOpacity(0.12)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fullscreen_rounded, size: 16, color: cInk),
                      SizedBox(width: 4),
                      Text(
                        dil('Tam Ekran', 'Full Screen'),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: cInk,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Harita Çerçevesi (OpenStreetMap Tile View)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EEF5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFCBD5E1).withOpacity(0.6)),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: KktcOpenStreetMapTileView(
                      key: _dashboardMapKey,
                      radarlar: kktcRadarListesi,
                      seciliRadar: null,
                      turkceMi: KktcDilServisi().turkceMi,
                      radarlariGoster: true,
                      poiNoktalari: kktcHaritaPoiListesi,
                      gosterUstBar: false,
                      onRadarSelected: (radar) {
                        HapticFeedback.lightImpact();
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
                      onPoiSelected: (poi) {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _seciliPoi = poi;
                          _selectedTabIndex = 1;
                        });
                      },
                    ),
                  ),

                  // Sağ Üst: Konumuma Git
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildMiniMapBtn(
                      icon: Icons.my_location_rounded,
                      tooltip: 'Konumuma Odaklan',
                      iconColor: const Color(0xFF0284C7),
                      onTap: () => _dashboardMapKey.currentState?.centerOnUserOrKktc(),
                    ),
                  ),

                  // Sol Alt: Canlı Durum Rozeti
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.camera_alt_rounded, size: 12, color: Color(0xFFE11D48)),
                              SizedBox(width: 4),
                              Text(
                                '28 Radar',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: cInk,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text('•', style: TextStyle(color: Colors.grey, fontSize: 10)),
                              SizedBox(width: 6),
                              Icon(Icons.local_gas_station_rounded, size: 12, color: Color(0xFF0284C7)),
                              SizedBox(width: 4),
                              Text(
                                '22 İstasyon',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: cInk,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMapBtn({
    required IconData icon,
    required String tooltip,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(99),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.94),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFCBD5E1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(icon, size: 16, color: iconColor ?? cInk),
        ),
      ),
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
        turkceMi: KktcDilServisi().turkceMi,
        onHedefeGit: (hedefId) {},
      ),
    );
  }

  // 🗺️ POI Konum Arama Modalı (Haritalar Sekmesi)
  void _openPoiAramaModal() {
    HapticFeedback.lightImpact();
    final TextEditingController aramaCtrl = TextEditingController();
    List<KktcHaritaPoi> sonuclar = List.from(kktcHaritaPoiListesi);
    List<RotaNoktasi> uzakSonuclar = [];
    bool uzakAraniyor = false;
    Timer? uzakTimer;
    bool modalAcik = true;

    final sheetFuture = showModalBottomSheet(
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
              decoration: BoxDecoration(
                color: cSurface,
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
                        Icon(Icons.search_rounded, color: cInk, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            dil('Konum Ara', 'Search Location'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: cInk,
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
                        color: cSoftSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: cLine),
                      ),
                      child: TextField(
                        controller: aramaCtrl,
                        autofocus: false,
                        decoration: InputDecoration(
                          hintText: dil('Evim, İşim, AVM, Plaj, Benzinlik, Üniversite ara...', 'Search Home, Work, Mall, Beach, Gas, University...'),
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
                                        p.kategori.toLowerCase().contains(q) ||
                                        p.marka.toLowerCase().contains(q) ||
                                        p.sehir.toLowerCase().contains(q))
                                    .toList();
                            if (q.length < 2) {
                              uzakSonuclar = [];
                              uzakAraniyor = false;
                            }
                          });
                          uzakTimer?.cancel();
                          final q = val.trim();
                          if (q.length < 2) return;
                          uzakTimer = Timer(const Duration(milliseconds: 450), () async {
                            if (modalAcik) setModalState(() => uzakAraniyor = true);
                            final dil = KktcDilServisi().turkceMi ? 'tr' : 'en';
                            final r = await KktcAdresAramaServisi.ara(q, dil: dil);
                            if (modalAcik) {
                              setModalState(() {
                                uzakSonuclar = r;
                                uzakAraniyor = false;
                              });
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Hızlı Kısayollar
                  SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildSearchFilterChip(
                          icon: Icons.home_rounded,
                          label: dil('Evim', 'Home'),
                          color: const Color(0xFF10B981),
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => YolTarifiSayfasi(
                                  turkceMi: KktcDilServisi().turkceMi,
                                  varisNoktasi: RotaNoktasi(
                                    id: 'evim',
                                    ad: _evimAdres,
                                    adEn: _evimAdres,
                                    kisaAd: 'Evim',
                                    bolge: 'Lefkoşa',
                                    lat: _evimLat,
                                    lon: _evimLon,
                                    ikon: Icons.home_rounded,
                                  ),
                                  otomatikNavigasyonBaslat: true,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        _buildSearchFilterChip(
                          icon: Icons.work_rounded,
                          label: dil('İşim', 'Work'),
                          color: const Color(0xFF2563EB),
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => YolTarifiSayfasi(
                                  turkceMi: KktcDilServisi().turkceMi,
                                  varisNoktasi: RotaNoktasi(
                                    id: 'isim',
                                    ad: _isimAdres,
                                    adEn: _isimAdres,
                                    kisaAd: 'İşim',
                                    bolge: 'Lefkoşa',
                                    lat: _isimLat,
                                    lon: _isimLon,
                                    ikon: Icons.work_rounded,
                                  ),
                                  otomatikNavigasyonBaslat: true,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        _buildSearchFilterChip(
                          icon: Icons.shopping_bag_rounded,
                          label: '🛍️ AVM',
                          color: const Color(0xFF8B5CF6),
                          onTap: () {
                            setModalState(() {
                              sonuclar = kktcHaritaPoiListesi.where((p) => p.kategori == 'avm').toList();
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        _buildSearchFilterChip(
                          icon: Icons.beach_access_rounded,
                          label: '🏖️ Plaj',
                          color: const Color(0xFF0EA5E9),
                          onTap: () {
                            setModalState(() {
                              sonuclar = kktcHaritaPoiListesi.where((p) => p.kategori == 'plaj').toList();
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        _buildSearchFilterChip(
                          icon: Icons.local_gas_station_rounded,
                          label: '⛽ Benzin',
                          color: const Color(0xFFE11D48),
                          onTap: () {
                            setModalState(() {
                              sonuclar = kktcHaritaPoiListesi.where((p) => p.kategori == 'benzin').toList();
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        _buildSearchFilterChip(
                          icon: Icons.school_rounded,
                          label: '🎓 Üniversite',
                          color: const Color(0xFFD97706),
                          onTap: () {
                            setModalState(() {
                              sonuclar = kktcHaritaPoiListesi.where((p) => p.kategori == 'universite').toList();
                            });
                          },
                        ),
                      ],
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
                                Text(dil('Sonuç bulunamadı', 'No results found'), style: TextStyle(color: Colors.grey.shade500)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: sonuclar.length +
                                ((aramaCtrl.text.trim().length >= 2)
                                    ? 1 + (uzakAraniyor ? 1 : (uzakSonuclar.isEmpty ? 1 : uzakSonuclar.length))
                                    : 0),
                            itemBuilder: (_, i) {
                              if (i >= sonuclar.length) {
                                final uIdx = i - sonuclar.length;
                                if (uIdx == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(8, 14, 8, 6),
                                    child: Text(
                                      dil('İNTERNETTE ARA (TÜM KKTC)', 'SEARCH THE WEB (ALL TRNC)'),
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 0.6),
                                    ),
                                  );
                                }
                                if (uzakAraniyor) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 18),
                                    child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
                                  );
                                }
                                if (uzakSonuclar.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    child: Center(
                                      child: Text(dil('İnternette sonuç bulunamadı', 'No results found online'), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                    ),
                                  );
                                }
                                final nokta = uzakSonuclar[uIdx - 1];
                                return Material(
                                  color: Colors.transparent,
                                  child: ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(color: const Color(0xFF2563EB).withValues(alpha: 0.12), shape: BoxShape.circle),
                                    child: Icon(nokta.ikon, color: const Color(0xFF2563EB), size: 20),
                                  ),
                                  title: Text(nokta.ad, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                  subtitle: Text(nokta.kisaAd, style: TextStyle(fontSize: 11, color: Colors.grey.shade600), overflow: TextOverflow.ellipsis),
                                  trailing: const Icon(Icons.directions_rounded, color: Color(0xFF2563EB), size: 20),
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => YolTarifiSayfasi(
                                          turkceMi: KktcDilServisi().turkceMi,
                                          varisNoktasi: nokta,
                                          otomatikNavigasyonBaslat: true,
                                        ),
                                      ),
                                    );
                                  },
                                  ),
                                );
                              }
                              final poi = sonuclar[i];
                              return Material(
                                color: Colors.transparent,
                                child: ListTile(
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
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cInk),
                                ),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  setState(() {
                                    _seciliPoiKategori = poi.kategori;
                                    _seciliPoi = poi;
                                  });
                                  _haritaOsmKey.currentState?.flyToLocation(poi.lat, poi.lon, zoom: 14.0);
                                },
                                ),
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
    sheetFuture.whenComplete(() {
      modalAcik = false;
      uzakTimer?.cancel();
    });
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
            color: cSurface,
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
              Icon(Icons.search_rounded, size: 20, color: cMuted),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  dil('Ceza, radar veya kanun maddesi ara...', 'Search fine, radar or law article...'),
                  style: TextStyle(
                    color: cMuted,
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
                child: Text(
                  '2026',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: cInk,
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
  // 🚦 YOL FORUMU TABI (TAB 3: ÇEVİRME, KAZA, ÇALIŞMA VE CANLI SÜRÜCÜ FORUMU)
  // ===========================================================================
  // 🗺️ GOOGLE MAPS TARZI TAM EKRAN CANLI HARİTA & YOL TARİFİ (TAB 1: YOL TARİFİ)
  // ===========================================================================
  Widget _buildFullScreenHaritalarTab() {
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
            turkceMi: KktcDilServisi().turkceMi,
            radarlariGoster: false,
            gosterUstBar: false,
            gosterZoomButonlari: false, // Kartlarla çakışmayı önlemek için sağda özel konumlandırılır
            poiNoktalari: gosterilecekPoiler,
            seciliPoi: _seciliPoi,
            onPoiSelected: (poi) {
              setState(() => _seciliPoi = poi);
              HapticFeedback.mediumImpact();
            },
            yolBildirimleri: _yolBildirimleri,
            onYolBildirimiSelected: (bildirim) {
              _showYolBildirimiDetayBottomSheet(bildirim);
            },
          ),
        ),

        // 2. ÜST: ARAMA ÇUBUĞU VE YOL TARİFİ KISAYOLU
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 14,
          right: 14,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Arama Kartı (Beyaz Glassmorphism)
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: cSurface,
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
                          Icon(Icons.search_rounded, color: cInk, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              dil('Nereye gitmek istiyorsunuz? Yol tarifi ara...', 'Where do you want to go? Search routes...'),
                              style: TextStyle(
                                color: cMuted,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Hızlı Navigasyon / Yol Tarifi Başlat Butonu
                          InkWell(
                            onTap: () {
                              HapticFeedback.heavyImpact();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => YolTarifiSayfasi(turkceMi: KktcDilServisi().turkceMi),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.directions_rounded, size: 14, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'Yol Tarifi',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // 🚗 HIZLI GÜNLÜK NAVİGASYON ŞERİDİ (EVİM, İŞİM, AVM, BENZİN)
              Row(
                children: [
                  Expanded(
                    child: _buildQuickNavButton(
                      icon: Icons.home_rounded,
                      label: dil('Evim', 'Home'),
                      color: const Color(0xFF10B981),
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => YolTarifiSayfasi(
                              turkceMi: KktcDilServisi().turkceMi,
                              varisNoktasi: KktcFavoriNoktalarServisi().evimRotaNoktasi,
                              otomatikNavigasyonBaslat: true,
                            ),
                          ),
                        );
                      },
                      onEditTap: () {
                        showEvIsDuzenleModal(
                          context: context,
                          isEv: true,
                          onKaydedildi: () => setState(() {}),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildQuickNavButton(
                      icon: Icons.work_rounded,
                      label: dil('İşim', 'Work'),
                      color: const Color(0xFF2563EB),
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => YolTarifiSayfasi(
                              turkceMi: KktcDilServisi().turkceMi,
                              varisNoktasi: KktcFavoriNoktalarServisi().isimRotaNoktasi,
                              otomatikNavigasyonBaslat: true,
                            ),
                          ),
                        );
                      },
                      onEditTap: () {
                        showEvIsDuzenleModal(
                          context: context,
                          isEv: false,
                          onKaydedildi: () => setState(() {}),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildQuickNavButton(
                      icon: Icons.shopping_bag_rounded,
                      label: 'AVM',
                      color: const Color(0xFF8B5CF6),
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        setState(() {
                          _seciliPoiKategori = 'avm';
                          _seciliPoi = kktcHaritaPoiListesi.firstWhere(
                            (p) => p.kategori == 'avm',
                            orElse: () => kktcHaritaPoiListesi.first,
                          );
                        });
                        if (_seciliPoi != null) {
                          _haritaOsmKey.currentState?.flyToLocation(_seciliPoi!.lat, _seciliPoi!.lon, zoom: 13.5);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildQuickNavButton(
                      icon: Icons.local_gas_station_rounded,
                      label: 'Benzin',
                      color: const Color(0xFFE11D48),
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        setState(() {
                          _seciliPoiKategori = 'benzin';
                          _seciliPoi = kktcHaritaPoiListesi.firstWhere(
                            (p) => p.kategori == 'benzin',
                            orElse: () => kktcHaritaPoiListesi.first,
                          );
                        });
                        if (_seciliPoi != null) {
                          _haritaOsmKey.currentState?.flyToLocation(_seciliPoi!.lat, _seciliPoi!.lon, zoom: 13.5);
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // 🗂️ POI KATEGORİ HAPLARI
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildPoiCategoryChip(
                      id: 'tumu',
                      label: dil('Tüm KKTC', 'All TRNC'),
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
                      id: 'avm',
                      label: dil('🛍️ AVM & Çarşı', '🛍️ Malls & Bazaars'),
                      icon: Icons.shopping_bag_rounded,
                      onTap: () {
                        setState(() {
                          _seciliPoiKategori = 'avm';
                          _seciliPoi = null;
                        });
                        _haritaOsmKey.currentState?.centerOnKktc();
                      },
                    ),
                    _buildPoiCategoryChip(
                      id: 'plaj',
                      label: dil('🏖️ Plaj & Tatil', '🏖️ Beaches & Resorts'),
                      icon: Icons.beach_access_rounded,
                      onTap: () {
                        setState(() {
                          _seciliPoiKategori = 'plaj';
                          _seciliPoi = null;
                        });
                        _haritaOsmKey.currentState?.centerOnKktc();
                      },
                    ),
                    _buildPoiCategoryChip(
                      id: 'benzin',
                      label: dil('⛽ Benzinlikler', '⛽ Gas Stations'),
                      icon: Icons.local_gas_station_rounded,
                      onTap: () {
                        setState(() {
                          _seciliPoiKategori = 'benzin';
                          _seciliPoi = null;
                        });
                        _haritaOsmKey.currentState?.centerOnKktc();
                      },
                    ),
                    _buildPoiCategoryChip(
                      id: 'universite',
                      label: dil('🎓 Üniversiteler', '🎓 Universities'),
                      icon: Icons.school_rounded,
                      onTap: () {
                        setState(() {
                          _seciliPoiKategori = 'universite';
                          _seciliPoi = null;
                        });
                        _haritaOsmKey.currentState?.centerOnKktc();
                      },
                    ),
                    _buildPoiCategoryChip(
                      id: 'havalimani',
                      label: dil('✈️ Ulaşım & Liman', '✈️ Transport & Ports'),
                      icon: Icons.flight_takeoff_rounded,
                      onTap: () {
                        setState(() {
                          _seciliPoiKategori = 'havalimani';
                          _seciliPoi = null;
                        });
                        _haritaOsmKey.currentState?.centerOnKktc();
                      },
                    ),
                    _buildPoiCategoryChip(
                      id: 'tamir',
                      label: dil('🔧 Tamir & Servis', '🔧 Repairs & Service'),
                      icon: Icons.build_rounded,
                      onTap: () {
                        setState(() {
                          _seciliPoiKategori = 'tamir';
                          _seciliPoi = null;
                        });
                        _haritaOsmKey.currentState?.centerOnKktc();
                      },
                    ),
                    _buildPoiCategoryChip(
                      id: 'otopark',
                      label: dil('🅿️ Otoparklar', '🅿️ Parking'),
                      icon: Icons.local_parking_rounded,
                      onTap: () {
                        setState(() {
                          _seciliPoiKategori = 'otopark';
                          _seciliPoi = null;
                        });
                        _haritaOsmKey.currentState?.centerOnKktc();
                      },
                    ),
                    _buildPoiCategoryChip(
                      id: 'hastane',
                      label: dil('🏥 Acil & Hastane', '🏥 Hospital & Emergency'),
                      icon: Icons.local_hospital_rounded,
                      onTap: () {
                        setState(() {
                          _seciliPoiKategori = 'hastane';
                          _seciliPoi = null;
                        });
                        _haritaOsmKey.currentState?.centerOnKktc();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 3. SAĞ ORTA: ZOOM + - VE KONUM BUTONLARI (KARTLARLA ASLA ÇAKIŞMAZ)
        Positioned(
          right: 14,
          bottom: _seciliPoi != null ? 220 : 108,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: 'map_zoom_in',
                backgroundColor: cSurface,
                elevation: 4,
                onPressed: () => _haritaOsmKey.currentState?.zoomIn(),
                child: Icon(Icons.add_rounded, color: cInk, size: 20),
              ),
              const SizedBox(height: 6),
              FloatingActionButton.small(
                heroTag: 'map_zoom_out',
                backgroundColor: cSurface,
                elevation: 4,
                onPressed: () => _haritaOsmKey.currentState?.zoomOut(),
                child: Icon(Icons.remove_rounded, color: cInk, size: 20),
              ),
              const SizedBox(height: 6),
              FloatingActionButton.small(
                heroTag: 'map_poi_loc',
                backgroundColor: cSurface,
                elevation: 4,
                onPressed: () => _haritaOsmKey.currentState?.centerOnUserOrKktc(),
                child: const Icon(Icons.my_location_rounded, color: Color(0xFF0284C7), size: 20),
              ),
              const SizedBox(height: 6),
              FloatingActionButton.small(
                heroTag: 'map_poi_kktc',
                backgroundColor: isKoyu ? const Color(0xFF1E293B) : cNavy,
                elevation: 4,
                onPressed: () => _haritaOsmKey.currentState?.centerOnKktc(),
                child: const Icon(Icons.center_focus_strong_rounded, color: cLime, size: 20),
              ),
            ],
          ),
        ),

        // 4. ALT ŞERİT: RESMİ GAZETE AKARYAKIT TAVAN FİYATLARI ŞERİDİ
        Positioned(
          left: 14,
          right: 14,
          bottom: 12,
          child: _buildLiveAkaryakitFiyatBanner(),
        ),

        // 5. ALT: SEÇİLİ POI BİLGİ KARTI ("Yol Tarifi Al" butonu ile)
        if (_seciliPoi != null)
          Positioned(
            left: 14,
            right: 14,
            bottom: 74,
            child: _buildPoiDetayKarti(_seciliPoi!),
          ),
      ],
    );
  }

  // ===========================================================================
  // 🚦 PANELDEKİ YOL FORUM KARTINA TIKLAYINCA AÇILAN CANLI FORUM SAYFASI
  // ===========================================================================
  void _openYolForumModal() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final List<YolForumBildirimi> filtrelenmisBildirimler = _seciliYolFiltresi == 'tumu'
                ? _yolBildirimleri
                : _yolBildirimleri.where((b) {
                    if (_seciliYolFiltresi == 'cevirme') return b.tip == YolForumTipi.cevirme;
                    if (_seciliYolFiltresi == 'kaza') return b.tip == YolForumTipi.kaza;
                    if (_seciliYolFiltresi == 'calisma') return b.tip == YolForumTipi.calisma;
                    return true;
                  }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.90,
              decoration: BoxDecoration(
                color: cSurface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Stack(
                  children: [
                    // 1. Zemin Harita
                    Positioned.fill(
                      child: KktcOpenStreetMapTileView(
                        key: _yolForumOsmKey,
                        radarlar: const [],
                        seciliRadar: null,
                        onRadarSelected: (_) {},
                        turkceMi: KktcDilServisi().turkceMi,
                        radarlariGoster: false,
                        gosterUstBar: false,
                        gosterZoomButonlari: false, // Alttaki kartlarla çakışma önlendi
                        yolBildirimleri: filtrelenmisBildirimler,
                        seciliYolBildirimi: _seciliYolBildirimi,
                        onYolBildirimiSelected: (bildirim) {
                          _showYolBildirimiDetayBottomSheet(bildirim);
                        },
                      ),
                    ),

                    // 2. Üst Bar: Başlık, "+ Bildir", Kapat
                    Positioned(
                      top: 12,
                      left: 14,
                      right: 14,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: cSurface,
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(color: cLine),
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
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2563EB).withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.forum_rounded, color: Color(0xFF2563EB), size: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            dil('KKTC Yol Forumu', 'TRNC Road Forum'),
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w800,
                                              color: cInk,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(Icons.fiber_manual_record, color: Color(0xFF10B981), size: 10),
                                        ],
                                      ),
                                      Text(
                                        dil('${filtrelenmisBildirimler.length} aktif yol olayı bildirildi', '${filtrelenmisBildirimler.length} active road reports'),
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          color: cMuted,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // "+ Bildir" Butonu
                                InkWell(
                                  onTap: () {
                                    HapticFeedback.heavyImpact();
                                    _openYeniBildirimModali();
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.add_location_alt_rounded, size: 14, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text(
                                          dil('+ Bildir', '+ Report'),
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: Icon(Icons.close_rounded, size: 20, color: cMuted),
                                  onPressed: () => Navigator.pop(modalCtx),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Filtre Hapları
                          SizedBox(
                            height: 36,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              children: [
                                _buildYolFiltreChip(
                                  id: 'tumu',
                                  label: dil('Tümü (${_yolBildirimleri.length})', 'All (${_yolBildirimleri.length})'),
                                  icon: Icons.alt_route_rounded,
                                  renk: isKoyu ? const Color(0xFF2563EB) : const Color(0xFF0F172A),
                                  onSelect: () => setSheetState(() => _seciliYolFiltresi = 'tumu'),
                                ),
                                _buildYolFiltreChip(
                                  id: 'cevirme',
                                  label: dil('🚓 Çevirme (${_yolBildirimleri.where((b) => b.tip == YolForumTipi.cevirme).length})', '🚓 Police (${_yolBildirimleri.where((b) => b.tip == YolForumTipi.cevirme).length})'),
                                  icon: Icons.local_police_rounded,
                                  renk: const Color(0xFF2563EB),
                                  onSelect: () => setSheetState(() => _seciliYolFiltresi = 'cevirme'),
                                ),
                                _buildYolFiltreChip(
                                  id: 'kaza',
                                  label: dil('💥 Kaza (${_yolBildirimleri.where((b) => b.tip == YolForumTipi.kaza).length})', '💥 Accident (${_yolBildirimleri.where((b) => b.tip == YolForumTipi.kaza).length})'),
                                  icon: Icons.car_crash_rounded,
                                  renk: const Color(0xFFEF4444),
                                  onSelect: () => setSheetState(() => _seciliYolFiltresi = 'kaza'),
                                ),
                                _buildYolFiltreChip(
                                  id: 'calisma',
                                  label: dil('🚧 Çalışma (${_yolBildirimleri.where((b) => b.tip == YolForumTipi.calisma).length})', '🚧 Work (${_yolBildirimleri.where((b) => b.tip == YolForumTipi.calisma).length})'),
                                  icon: Icons.construction_rounded,
                                  renk: const Color(0xFFF59E0B),
                                  onSelect: () => setSheetState(() => _seciliYolFiltresi = 'calisma'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 3. SAĞ: ZOOM + - VE KONUM BUTONLARI (KARTLARIN TAM ÜSTÜNDE, ASLA ÇAKIŞMAZ!)
                    Positioned(
                      right: 14,
                      bottom: 100,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FloatingActionButton.small(
                            heroTag: 'yf_zoom_in',
                            backgroundColor: cSurface,
                            elevation: 4,
                            onPressed: () => _yolForumOsmKey.currentState?.zoomIn(),
                            child: Icon(Icons.add_rounded, color: cInk, size: 20),
                          ),
                          const SizedBox(height: 6),
                          FloatingActionButton.small(
                            heroTag: 'yf_zoom_out',
                            backgroundColor: cSurface,
                            elevation: 4,
                            onPressed: () => _yolForumOsmKey.currentState?.zoomOut(),
                            child: Icon(Icons.remove_rounded, color: cInk, size: 20),
                          ),
                          const SizedBox(height: 6),
                          FloatingActionButton.small(
                            heroTag: 'yf_loc',
                            backgroundColor: cSurface,
                            elevation: 4,
                            onPressed: () => _yolForumOsmKey.currentState?.centerOnUserOrKktc(),
                            child: const Icon(Icons.my_location_rounded, color: Color(0xFF0284C7), size: 20),
                          ),
                          const SizedBox(height: 6),
                          FloatingActionButton.small(
                            heroTag: 'yf_kktc',
                            backgroundColor: isKoyu ? const Color(0xFF1E293B) : cNavy,
                            elevation: 4,
                            onPressed: () => _yolForumOsmKey.currentState?.centerOnKktc(),
                            child: const Icon(Icons.center_focus_strong_rounded, color: cLime, size: 20),
                          ),
                        ],
                      ),
                    ),

                    // 4. ALT ŞERİT: AKTİF BİLDİRİMLER MİNİ CAROUSEL (DOKUNUNCA DETAY AÇILIR)
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 14,
                      child: SizedBox(
                        height: 72,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: filtrelenmisBildirimler.length + 1,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            if (index == filtrelenmisBildirimler.length) {
                              return InkWell(
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  _openYeniBildirimModali();
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 140,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: cSurface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.3), width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_circle_outline_rounded, color: Color(0xFF2563EB), size: 22),
                                      SizedBox(height: 4),
                                      Text(
                                        '+ Yeni Olay Bildir',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF2563EB),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final b = filtrelenmisBildirimler[index];
                            return InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _yolForumOsmKey.currentState?.flyToLocation(b.lat, b.lon, zoom: 12.8);
                                _showYolBildirimiDetayBottomSheet(b);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: 250,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: cSurface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: cLine),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.09),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: b.tip.acikRenk,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: b.tip.kenarRenk, width: 1.2),
                                      ),
                                      child: Icon(b.tip.ikon, color: b.tip.anaRenk, size: 19),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            b.baslik,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: cInk,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Text(
                                                b.zaman,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: cMuted,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: cSoftSurface,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  '💬 ${b.yorumlar.length} Yorum',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w700,
                                                    color: cInk,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.chevron_right_rounded, size: 18, color: cMuted),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildYolFiltreChip({
    required String id,
    required String label,
    required IconData icon,
    required Color renk,
    VoidCallback? onSelect,
  }) {
    final bool isSelected = _seciliYolFiltresi == id;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            HapticFeedback.selectionClick();
            if (onSelect != null) {
              onSelect();
            } else {
              setState(() {
                _seciliYolFiltresi = id;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? renk : cSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? renk : cLine,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isSelected ? 0.15 : 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isSelected ? Colors.white : (isKoyu && renk == const Color(0xFF0F172A) ? cInk : renk),
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : cInk,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // ===========================================================================
  // 💬 YOL FORUMU DETAY & YORUM MODAL SAYFASI (AŞAĞIDAN GELEN ÇOK YER KAPLAMAYAN SHEET)
  // ===========================================================================
  void _showYolBildirimiDetayBottomSheet(YolForumBildirimi bildirim) {
    final TextEditingController yorumController = TextEditingController();
    final ScrollController scrollController = ScrollController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.58,
              decoration: BoxDecoration(
                color: cSurface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 1. Üst Tutacak (Drag Handle)
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 6),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isKoyu ? const Color(0xFF334155) : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // 2. Başlık ve Kategori Rozeti
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Tip Rozeti
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: bildirim.tip.acikRenk,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: bildirim.tip.kenarRenk),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(bildirim.tip.ikon, size: 14, color: bildirim.tip.anaRenk),
                              const SizedBox(width: 5),
                              Text(
                                bildirim.tip.baslik,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: bildirim.tip.anaRenk,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Doğrulama Rozeti
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isKoyu ? const Color(0xFF064E3B).withOpacity(0.4) : const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isKoyu ? const Color(0xFF059669) : const Color(0xFFA7F3D0)),
                          ),
                          child: Text(
                            '👍 ${bildirim.dogrulamaSayisi} Doğrulama',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isKoyu ? const Color(0xFF34D399) : const Color(0xFF059669),
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.close_rounded, size: 20, color: cMuted),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                  ),

                  // 3. Konum ve Açıklama Bilgisi
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bildirim.baslik,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: cInk,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.location_on_rounded, size: 13, color: cMuted),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                '${bildirim.konumAdi} • ${bildirim.zaman}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: cMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Olay Notu ve Hızlı Doğrulama Butonları
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cSoftSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: cLine),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bildirim.aciklama,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: cInk,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  // Hâlâ Aktif mi? Doğrula
                                  InkWell(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      setModalState(() {
                                        bildirim.dogrulamaSayisi++;
                                      });
                                      setState(() {});
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Teşekkürler, bildirim bilginiz kaydedildi.'),
                                          duration: Duration(seconds: 1),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isKoyu ? const Color(0xFF064E3B).withOpacity(0.4) : const Color(0xFFECFDF5),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.thumb_up_alt_rounded, size: 12, color: isKoyu ? const Color(0xFF34D399) : const Color(0xFF059669)),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Hâlâ Aktif (${bildirim.dogrulamaSayisi})',
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              color: isKoyu ? const Color(0xFF34D399) : const Color(0xFF059669),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Yol Temizlendi / Kalktı
                                  InkWell(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      setModalState(() {
                                        bildirim.yanlisSayisi++;
                                      });
                                      setState(() {});
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isKoyu ? const Color(0xFF7F1D1D).withOpacity(0.4) : const Color(0xFFFEF2F2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.4)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle_outline_rounded, size: 12, color: isKoyu ? const Color(0xFFF87171) : const Color(0xFFDC2626)),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Kalktı (${bildirim.yanlisSayisi})',
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              color: isKoyu ? const Color(0xFFF87171) : const Color(0xFFDC2626),
                                            ),
                                          ),
                                        ],
                                      ),
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

                  const SizedBox(height: 8),

                  // 4. Sürücü Yorumları Başlığı
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: Color(0xFF2563EB)),
                        const SizedBox(width: 5),
                        Text(
                          'Yol Forum Yorumları (${bildirim.yorumlar.length})',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: cInk,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 5. Yorumlar Listesi
                  Expanded(
                    child: bildirim.yorumlar.isEmpty
                        ? Center(
                            child: Text(
                              'Bu olay için henüz yorum yok.\nİlk bilgiyi aşağıdan siz paylaşın!',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11.5, color: cMuted),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            itemCount: bildirim.yorumlar.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 6),
                            itemBuilder: (context, index) {
                              final y = bildirim.yorumlar[index];
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: cSoftSurface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: cLine),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 10,
                                          backgroundColor: const Color(0xFF2563EB).withOpacity(0.15),
                                          child: Text(
                                            y.yazar.isNotEmpty ? y.yazar[0] : 'S',
                                            style: const TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF2563EB),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          y.yazar,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: cInk,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          y.zaman,
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            color: cMuted,
                                          ),
                                        ),
                                        const Spacer(),
                                        InkWell(
                                          onTap: () {
                                            HapticFeedback.selectionClick();
                                            setModalState(() {
                                              y.begeniSayisi++;
                                            });
                                            setState(() {});
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.thumb_up_alt_outlined, size: 11, color: cMuted),
                                              const SizedBox(width: 3),
                                              Text(
                                                '${y.begeniSayisi}',
                                                style: TextStyle(fontSize: 10, color: cMuted),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      y.yorum,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: cInk,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),

                  // 6. En Altta Sabit Yorum Ekleme Çubuğu
                  Container(
                    padding: EdgeInsets.only(
                      left: 14,
                      right: 14,
                      top: 8,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                    ),
                    decoration: BoxDecoration(
                      color: cSurface,
                      border: Border(top: BorderSide(color: cLine)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: cSoftSurface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: cLine),
                            ),
                            child: TextField(
                              controller: yorumController,
                              style: TextStyle(fontSize: 12, color: cInk),
                              decoration: InputDecoration(
                                hintText: 'Bu yol durumu hakkında yorum yaz...',
                                hintStyle: TextStyle(fontSize: 11, color: cMuted),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            final text = yorumController.text.trim();
                            if (text.isEmpty) return;
                            HapticFeedback.mediumImpact();
                            final yeniYorum = YolForumYorum(
                              id: 'y_${DateTime.now().millisecondsSinceEpoch}',
                              yazar: _girisYapildiMi ? _kullaniciAdi : 'Sürücü (KKTC)',
                              zaman: 'Az önce',
                              yorum: text,
                            );
                            setModalState(() {
                              bildirim.yorumlar.add(yeniYorum);
                            });
                            setState(() {});
                            yorumController.clear();
                            // Listeyi en alta kaydır
                            Future.delayed(const Duration(milliseconds: 100), () {
                              if (scrollController.hasClients) {
                                scrollController.animateTo(
                                  scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                );
                              }
                            });
                          },
                          icon: Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2563EB),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
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
      },
    );
  }

  // ===========================================================================
  // ➕ YENİ YOL BİLDİRİMİ EKLEME MODALI (3 SEÇENEK: ÇEVİRME, KAZA, ÇALIŞMA)
  // ===========================================================================
  void _openYeniBildirimModali({double? lat, double? lon}) {
    YolForumTipi seciliTip = YolForumTipi.cevirme;
    final TextEditingController konumController = TextEditingController();
    final TextEditingController aciklamaController = TextEditingController();
    double bildirilecekLat = lat ?? 35.2150;
    double bildirilecekLon = lon ?? 33.3280;
    bool gpsYukleniyor = false;
    bool gpsKilitlendi = lat != null;

    // KKTC Popüler Konum Önerileri
    final List<Map<String, dynamic>> oneriKonumlar = [
      {'ad': '📍 Canlı GPS Konumum', 'lat': 0.0, 'lon': 0.0, 'bolge': 'GPS'},
      {'ad': 'Gönyeli Çemberi', 'lat': 35.2150, 'lon': 33.3280, 'bolge': 'Lefkoşa'},
      {'ad': 'Girne Dağ Yolu', 'lat': 35.2780, 'lon': 33.3950, 'bolge': 'Girne'},
      {'ad': 'Balıkesir Kavşağı', 'lat': 35.1894, 'lon': 33.4478, 'bolge': 'Lefkoşa / Balıkesir'},
      {'ad': 'Alsancak Çevre Yolu', 'lat': 35.3420, 'lon': 33.2510, 'bolge': 'Girne'},
      {'ad': 'Dörtyol Çemberi', 'lat': 35.1950, 'lon': 33.7450, 'bolge': 'Gazimağusa'},
      {'ad': 'Dereboyu Caddesi', 'lat': 35.1850, 'lon': 33.3550, 'bolge': 'Lefkoşa'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: cSurface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tutacak
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isKoyu ? const Color(0xFF334155) : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Başlık
                    Row(
                      children: [
                        const Icon(Icons.campaign_rounded, color: Color(0xFF2563EB), size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Yol Durumu Bildir',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: cInk,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.close_rounded, size: 20, color: cMuted),
                          onPressed: () => Navigator.pop(modalContext),
                        ),
                      ],
                    ),

                    Text(
                      '3 seçenekten birini seçerek diğer sürücüleri bilgilendirin:',
                      style: TextStyle(fontSize: 11.5, color: cMuted),
                    ),
                    const SizedBox(height: 12),

                    // ⭐ 3 ANA SEÇENEK KARTI: 1. ÇEVİRME VAR | 2. KAZA VAR | 3. ÇALIŞMA VAR
                    Row(
                      children: [
                        // 1. Çevirme Var
                        Expanded(
                          child: _buildSecenekKarti(
                            tip: YolForumTipi.cevirme,
                            seciliTip: seciliTip,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setModalState(() => seciliTip = YolForumTipi.cevirme);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 2. Kaza Var
                        Expanded(
                          child: _buildSecenekKarti(
                            tip: YolForumTipi.kaza,
                            seciliTip: seciliTip,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setModalState(() => seciliTip = YolForumTipi.kaza);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 3. Çalışma Var
                        Expanded(
                          child: _buildSecenekKarti(
                            tip: YolForumTipi.calisma,
                            seciliTip: seciliTip,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setModalState(() => seciliTip = YolForumTipi.calisma);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // 🛰️ CANLI GPS İLE BİLDİR KARTI (KULLANICININ ANLIK KONUMU)
                    InkWell(
                      onTap: () async {
                        HapticFeedback.heavyImpact();
                        setModalState(() => gpsYukleniyor = true);
                        try {
                          Position? pos = _gps.sonKonum;
                          if (pos == null) {
                            pos = await Geolocator.getCurrentPosition(
                              desiredAccuracy: LocationAccuracy.high,
                              timeLimit: const Duration(seconds: 4),
                            );
                          }
                          if (pos != null) {
                            bildirilecekLat = pos.latitude;
                            bildirilecekLon = pos.longitude;
                            gpsKilitlendi = true;
                            konumController.text = 'Mevcut Konumum (Canlı GPS: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})';
                          } else {
                            bildirilecekLat = 35.2150;
                            bildirilecekLon = 33.3280;
                            gpsKilitlendi = true;
                            konumController.text = 'Mevcut Konumum (Canlı GPS)';
                          }
                        } catch (_) {
                          bildirilecekLat = 35.2150;
                          bildirilecekLon = 33.3280;
                          gpsKilitlendi = true;
                          konumController.text = 'Mevcut Konumum (Canlı GPS)';
                        } finally {
                          setModalState(() => gpsYukleniyor = false);
                        }
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: gpsKilitlendi
                                ? (isKoyu ? [const Color(0xFF064E3B), const Color(0xFF022C22)] : [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)])
                                : (isKoyu ? [const Color(0xFF1E293B), const Color(0xFF0F172A)] : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)]),
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: gpsKilitlendi ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (gpsKilitlendi ? const Color(0xFF10B981) : const Color(0xFF3B82F6)).withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: gpsKilitlendi ? const Color(0xFF10B981) : const Color(0xFF2563EB),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                gpsKilitlendi ? Icons.gps_fixed_rounded : Icons.my_location_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        gpsKilitlendi ? '📍 Canlı GPS Konumunuz Seçildi' : '📡 Şu Anki Konumuma Bildir (GPS)',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w800,
                                          color: gpsKilitlendi
                                              ? (isKoyu ? const Color(0xFF34D399) : const Color(0xFF065F46))
                                              : (isKoyu ? const Color(0xFF60A5FA) : const Color(0xFF1E40AF)),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      if (gpsKilitlendi)
                                        const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 14),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    gpsKilitlendi
                                        ? 'Koordinat: ${bildirilecekLat.toStringAsFixed(4)}, ${bildirilecekLon.toStringAsFixed(4)} (Doğrulandı)'
                                        : 'Tek dokunuşla bulunduğunuz yere olay bildirimi ekleyin',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: gpsKilitlendi
                                          ? (isKoyu ? const Color(0xFF6EE7B7) : const Color(0xFF047857))
                                          : (isKoyu ? const Color(0xFF93C5FD) : const Color(0xFF3B82F6)),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (gpsYukleniyor)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                decoration: BoxDecoration(
                                  color: gpsKilitlendi ? const Color(0xFF10B981) : const Color(0xFF2563EB),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  gpsKilitlendi ? 'SEÇİLDİ' : 'GPS KULLAN',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Konum Başlığı ve Öneri Hapları
                    Text(
                      'Veya Öneri Konumlardan Seçin',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: cInk,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 30,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: oneriKonumlar.map((loc) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: InkWell(
                              onTap: () async {
                                HapticFeedback.lightImpact();
                                if ((loc['ad'] as String).contains('GPS')) {
                                  setModalState(() => gpsYukleniyor = true);
                                  try {
                                    Position? pos = _gps.sonKonum;
                                    if (pos == null) {
                                      pos = await Geolocator.getCurrentPosition(
                                        desiredAccuracy: LocationAccuracy.high,
                                        timeLimit: const Duration(seconds: 4),
                                      );
                                    }
                                    setModalState(() {
                                      if (pos != null) {
                                        bildirilecekLat = pos.latitude;
                                        bildirilecekLon = pos.longitude;
                                      } else {
                                        bildirilecekLat = 35.2150;
                                        bildirilecekLon = 33.3280;
                                      }
                                      gpsKilitlendi = true;
                                      konumController.text = 'Mevcut Konumum (Canlı GPS)';
                                    });
                                  } catch (_) {
                                    setModalState(() {
                                      bildirilecekLat = 35.2150;
                                      bildirilecekLon = 33.3280;
                                      gpsKilitlendi = true;
                                      konumController.text = 'Mevcut Konumum (Canlı GPS)';
                                    });
                                  } finally {
                                    setModalState(() => gpsYukleniyor = false);
                                  }
                                } else {
                                  setModalState(() {
                                    konumController.text = loc['ad'] as String;
                                    bildirilecekLat = loc['lat'] as double;
                                    bildirilecekLon = loc['lon'] as double;
                                    gpsKilitlendi = false;
                                  });
                                }
                              },
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: cSoftSurface,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: cLine),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.place_rounded, size: 11, color: Color(0xFF2563EB)),
                                    const SizedBox(width: 4),
                                    Text(
                                      loc['ad'] as String,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: cInk,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Özel Konum Adı Girişi
                    Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: cSoftSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cLine),
                      ),
                      child: TextField(
                        controller: konumController,
                        style: TextStyle(fontSize: 12, color: cInk),
                        decoration: InputDecoration(
                          hintText: 'Cadde / kavşak adını yazınız...',
                          hintStyle: TextStyle(fontSize: 11.5, color: cMuted),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Açıklama Notu
                    Text(
                      'Kısa Açıklama (İsteğe bağlı)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: cInk,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: cSoftSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cLine),
                      ),
                      child: TextField(
                        controller: aciklamaController,
                        style: TextStyle(fontSize: 12, color: cInk),
                        decoration: InputDecoration(
                          hintText: 'Örn: Sağ şerit kapalı, trafik yavaş ilerliyor...',
                          hintStyle: TextStyle(fontSize: 11.5, color: cMuted),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // "Bildirimi Paylaş" Butonu
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          final String konum = konumController.text.trim().isEmpty
                              ? 'Lefkoşa Çevre Yolu'
                              : konumController.text.trim();
                          final String aciklama = aciklamaController.text.trim().isEmpty
                              ? '${seciliTip.baslik} bildirildi. Sürücülerin dikkatli olması rica olunur.'
                              : aciklamaController.text.trim();

                          HapticFeedback.heavyImpact();

                          final yeniBildirim = YolForumBildirimi(
                            id: 'yf_${DateTime.now().millisecondsSinceEpoch}',
                            tip: seciliTip,
                            baslik: '$konum ${seciliTip.baslik}',
                            bolge: 'KKTC',
                            konumAdi: konum,
                            aciklama: aciklama,
                            lat: bildirilecekLat,
                            lon: bildirilecekLon,
                            zaman: 'Şimdi',
                            olusturmaTarihi: DateTime.now(),
                            dogrulamaSayisi: 1,
                            yanlisSayisi: 0,
                            bildiren: _girisYapildiMi ? _kullaniciAdi : 'Sürücü',
                            yorumlar: [],
                          );

                          setState(() {
                            _yolBildirimleri.insert(0, yeniBildirim);
                            _seciliYolBildirimi = yeniBildirim;
                          });

                          Navigator.pop(modalContext);

                          _yolForumOsmKey.currentState?.flyToLocation(
                            yeniBildirim.lat,
                            yeniBildirim.lon,
                            zoom: 13.0,
                          );

                          // Bildirim açıldıktan sonra detay modalını göster
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (mounted) {
                              _showYolBildirimiDetayBottomSheet(yeniBildirim);
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: seciliTip.anaRenk,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(seciliTip.ikon, size: 18, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              '${seciliTip.baslik} Bildir',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 📦 3 SEÇENEK KARTI WİDGETI
  Widget _buildSecenekKarti({
    required YolForumTipi tip,
    required YolForumTipi seciliTip,
    required VoidCallback onTap,
  }) {
    final bool isSelected = seciliTip == tip;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? tip.acikRenk : cSoftSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? tip.anaRenk : cLine,
            width: isSelected ? 2.2 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: tip.anaRenk.withOpacity(0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? tip.anaRenk : cSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : tip.kenarRenk,
                  width: 1.2,
                ),
              ),
              child: Icon(
                tip.ikon,
                color: isSelected ? Colors.white : tip.anaRenk,
                size: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              tip.baslik,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: isSelected ? tip.anaRenk : cInk,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tip == YolForumTipi.cevirme
                  ? 'Polis/Radar'
                  : (tip == YolForumTipi.kaza ? 'Kaza/Hasar' : 'Yol Bakım'),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: isSelected ? tip.anaRenk.withOpacity(0.8) : cMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

    // ⛽ CANLI AKARYAKIT FİYATLARI ŞERİDİ (Resmi Gazete / Bakanlar Kurulu Tavan Fiyatları)
  // 🧭 HIZLI GÜNLÜK NAVİGASYON BUTONU (EVİM, İŞİM, AVM, BENZİN)
  Widget _buildQuickNavButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    VoidCallback? onEditTap,
  }) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
        decoration: BoxDecoration(
          color: cSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.35), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            if (onEditTap != null) ...[
              const SizedBox(width: 3),
              GestureDetector(
                onTap: onEditTap,
                child: Icon(Icons.edit_location_alt_rounded, size: 12, color: color.withOpacity(0.8)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 🔍 ARAMA MODALI FİLTRE HAPI
  Widget _buildSearchFilterChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveAkaryakitFiyatBanner() {
    final fiyatlar = _akaryakitServisi.fiyatlar;
    return Container(
      decoration: BoxDecoration(
        color: cSurface,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dil('KKTC RESMİ AKARYAKIT TARİFESİ', 'TRNC OFFICIAL FUEL TARIFF'),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: cInk,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      'Bakanlar Kurulu / Resmi Gazete Azami Tavan Tarifesi',
                      style: TextStyle(
                        fontSize: 9,
                        color: cMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (_akaryakitServisi.yukleniyor)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: cInk),
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
                    child: Row(
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
        color: vurgulu ? const Color(0xFF047857).withOpacity(0.1) : cSoftSurface,
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
              color: vurgulu ? const Color(0xFF065F46) : cInk,
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
        color: isSelected ? (isKoyu ? const Color(0xFF2563EB) : cNavy) : cSurface,
        borderRadius: BorderRadius.circular(99),
        elevation: isSelected ? 4 : 2,
        shadowColor: isSelected ? (isKoyu ? const Color(0xFF2563EB).withOpacity(0.4) : cNavy.withOpacity(0.4)) : Colors.black.withOpacity(0.12),
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
                color: isSelected ? Colors.white : cInk,
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
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: cInk,
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
        color: cSurface,
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
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: cInk,
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
                          color: cSoftSurface,
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
                      Text(
                        'Akaryakıt',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: cInk,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _akaryakitServisi.fiyatlar.kaynak.contains('Canlı')
                                ? 'CANLI TARİFE'
                                : 'K-PET / RESMİ',
                            style: const TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF047857),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          final ok = await _akaryakitServisi.canliFiyatlariGuncelle();
                          if (mounted) {
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok
                                      ? '✅ Akaryakıt fiyatları güncellendi (K-Pet & Resmi Gazete: 95 Oktan ${_akaryakitServisi.fiyatlar.kursunsuz95.toStringAsFixed(2)} ₺, Euro Diesel ${_akaryakitServisi.fiyatlar.euroDiesel.toStringAsFixed(2)} ₺)'
                                      : '⚠️ Fiyatlar kontrol edildi (Mevcut resmi tarife geçerli)',
                                ),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: cNavy.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh_rounded, size: 12, color: cInk),
                              SizedBox(width: 3),
                              Text(
                                'Yenile',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: cInk),
                              ),
                            ],
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
                                  color: isMotorin ? const Color(0xFF047857) : cInk,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                e.value,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isMotorin ? const Color(0xFF065F46) : cInk,
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
                        color: cSoftSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: cLine),
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
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF0284C7)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.navigation_rounded, size: 18),
                          label: Text(
                            '🚀 Navigasyonu Başlat (${poi.sure})',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                          ),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => YolTarifiSayfasi(
                                  turkceMi: KktcDilServisi().turkceMi,
                                  varisNoktasi: poi.toRotaNoktasi(),
                                  otomatikNavigasyonBaslat: true,
                                ),
                              ),
                            );
                          },
                        ),
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
                          color: cSoftSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: cLine),
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
        color: cSurface,
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
          icon: Icon(icon, size: 20, color: iconColor ?? cInk),
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
      backgroundColor: cSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Harita Katmanı Seçin',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cInk),
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
                      color: cSurface,
                      shape: BoxShape.circle,
                      border: Border.all(color: cLine),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: cInk),
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
                        Text(
                          'KKTC CANLI TRAFİK',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: cMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Radarlar & Kameralar',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: cInk,
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
                  color: cSurface,
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
                      color: _sesliUyariAcik ? const Color(0xFF059669) : cMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _sesliUyariAcik ? 'Ses: Açık' : 'Ses: Kapalı',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: _sesliUyariAcik ? const Color(0xFF059669) : cMuted,
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
                Text(
                  'Hassas GPS Sinyali Aktif',
                  style: TextStyle(fontSize: 12, color: cMuted, fontWeight: FontWeight.w600),
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
        color: cSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cLine),
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
                      color: _radarHaritaModu == 1 ? const Color(0xFF10B981) : cInk,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _radarHaritaModu == 1 ? 'Canlı OpenStreetMap & GPS' : 'Lefkoşa - Girne Çevre Yolu',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: cInk),
                    ),
                  ],
                ),
                // Mod Seçici: Canlı OSM / Vektör
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: cSoftSurface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: cLine),
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
                              color: _radarHaritaModu == 1 ? Colors.white : cMuted,
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
                              color: _radarHaritaModu == 0 ? Colors.white : cMuted,
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
                            turkceMi: KktcDilServisi().turkceMi,
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
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: cInk,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Sağ Üst: Harita Kontrol Düğmeleri (GPS & Katman)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Column(
                      children: [
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
                        const SizedBox(height: 8),
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
                                border: Border.all(color: cLine),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2)),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'HIZINIZ',
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      color: cMuted,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        '68',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: cInk,
                                          height: 1,
                                        ),
                                      ),
                                      SizedBox(width: 2),
                                      Text('km/s', style: TextStyle(fontSize: 9, color: cMuted, fontWeight: FontWeight.bold)),
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
                            color: cSurface,
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
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: cInk, height: 1.1),
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
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: cInk),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Kamera: ${(_seciliRadarKamerasi ?? kktcRadarListesi.first).mesafe} • Limit: ${(_seciliRadarKamerasi ?? kktcRadarListesi.first).hizLimiti} km/s',
                            style: TextStyle(fontSize: 11, color: cMuted),
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
                        turkceMi: KktcDilServisi().turkceMi,
                        varisNoktasi: hedef,
                        otomatikNavigasyonBaslat: true,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.directions_rounded, size: 15, color: Colors.white),
                label: Text(
                  dil('Yol Tarifi', 'Directions'),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
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
                        turkceMi: KktcDilServisi().turkceMi,
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
          child: Icon(icon, size: 16, color: cInk),
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
                  color: isSelected ? cNavy : cSurface,
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
                    color: isSelected ? Colors.white : cInk,
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
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: cMuted,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
            Text(
              '${displayedRadars.length} Kayıt',
              style: TextStyle(fontSize: 11, color: cMuted, fontWeight: FontWeight.w600),
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
          color: cSurface,
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
                color: hizKutuRengi ?? (isWarning ? const Color(0xFFFEF3C7) : cSoftSurface),
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
                      color: hizYaziRengi ?? (isWarning ? const Color(0xFFB45309) : cMuted),
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hizLimiti,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: hizYaziRengi ?? (isWarning ? const Color(0xFF92400E) : cInk),
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
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: cInk),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: isPulsingDistance ? const Color(0xFFFEE2E8) : cSoftSurface,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          mesafe,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: isPulsingDistance ? const Color(0xFFB91C1C) : cMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    guzergah,
                    style: TextStyle(fontSize: 11, color: cMuted),
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
                        style: TextStyle(fontSize: 10, color: cMuted),
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
        color: cSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cLine),
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
                Text(
                  'KKTC RADAR HIZ TOLERANS & CEZA BİLGİSİ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: cInk,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Sabit hız radarlarında yasal hız limitine +%10 tolerans uygulanır. Hız aşımı cezaları KKTC brüt asgari ücret katsayısına ve aşım oranına göre (5 ila 25 ceza puanı) işlenmektedir.',
                  style: TextStyle(fontSize: 11.5, color: cMuted, height: 1.4),
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
      backgroundColor: cSurface,
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
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: cInk),
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
                            turkceMi: KktcDilServisi().turkceMi,
                            varisNoktasi: hedefRota,
                            otomatikNavigasyonBaslat: true,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.directions_rounded, size: 18, color: Colors.white),
                    label: Text(dil('Yol Tarifi Al', 'Get Directions'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
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
                  foregroundColor: cInk,
                  side: BorderSide(color: cInk, width: 1.5),
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
                        turkceMi: KktcDilServisi().turkceMi,
                        baslangicRadari: hedefKamera,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.fullscreen_rounded, size: 20),
                label: Text(dil('Tam Ekran Haritada Odaklan', 'Focus on Fullscreen Map'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
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
        backgroundColor: cSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'KKTC Hız Cezaları Tarifesi',
          style: TextStyle(fontWeight: FontWeight.w800, color: cInk, fontSize: 17),
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
            Text(
              '* Yasal hız limitinin %10\'una kadar tolerans tanınır. 15 gün içerisinde ödenen cezalarda %30 indirim uygulanır.',
              style: TextStyle(fontSize: 11.5, color: cMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Anladım', style: TextStyle(fontWeight: FontWeight.bold, color: cInk)),
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
            color: cSurface,
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
                child: Icon(
                  Icons.lock_rounded,
                  size: 32,
                  color: cInk,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                dil('Giriş Yapılması Gerekiyor', 'Authentication Required'),
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: cInk,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                dil('Kişisel radar cezalarınızı, seyrüsefer harçlarınızı, fenni muayene ve araç sigorta dökümlerinizi görüntülemek için KKTC Kimlik veya Ehliyet numaranız ile giriş yapmalısınız.', 'To view your personal radar fines, road tax fees, vehicle inspections and insurance policies, please log in with your TRNC ID or Driver License.'),
                style: TextStyle(
                  fontSize: 13,
                  color: cMuted,
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
                  label: Text(
                    dil('Kimlik / Ehliyet ile Giriş Yap', 'Sign In with ID / Driving License'),
                    style: const TextStyle(
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
                child: Text(
                  dil('Ana Panele Geri Dön', 'Back to Dashboard'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: cMuted,
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
                Text(
                  dil('Cezalar & Sigorta', 'Fines & Insurance'),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: cInk,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _cezaSigortaSubTab == 0
                      ? dil('Radar & Trafik İhlal Takibi', 'Radar & Violation Tracking')
                      : (_cezaSigortaSubTab == 1
                          ? dil('Seyrüsefer Harcı & Ruhsat Durumu', 'Road Tax & Registration Status')
                          : dil('Poliçeler & Fenni Muayene', 'Insurance & Inspections')),
                  style: TextStyle(fontSize: 12, color: cMuted),
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
                title: dil('Cezalarım', 'My Fines'),
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
            color: isSelected ? cSurface : Colors.transparent,
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
                color: isSelected ? cInk : cMuted,
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
                    color: isSelected ? cInk : cMuted,
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
                        foregroundColor: cInk,
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
                  child: Row(
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
                      Text(
                        '18 Mayıs 2024 • 14:22',
                        style: TextStyle(fontSize: 11, color: cMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Gönyeli Çemberi Radarı',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: cInk,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tespit Edilen Hız: 78 km/s (Yasal Limit: 65 km/s)',
                    style: TextStyle(fontSize: 12.5, color: cMuted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ceza Puanı: +10 Puan • Tebliğ No: PGM-2024-8841',
                    style: TextStyle(fontSize: 11.5, color: cMuted),
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
                                      child: Text(
                                        'KRİPTOLU DELİL',
                                        style: TextStyle(
                                          color: cInk,
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
                        text: TextSpan(
                          style: TextStyle(fontSize: 12, color: cMuted),
                          children: [
                            TextSpan(text: 'Tutar: '),
                            TextSpan(
                              text: '₺1.850,00',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                color: cInk,
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
                              foregroundColor: cInk,
                              side: BorderSide(color: cInk),
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
                        builder: (context) => BarkodluBelgeSayfasi(
                          kullanici: 'Ahmet Demir',
                          puan: 95,
                          turkceMi: KktcDilServisi().turkceMi,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.qr_code_rounded, size: 16),
                  label: Text(dil('Son Tahsilat Makbuzunu / QR İndir', 'Download Last Receipt / QR'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),

        // Ödenmiş Geçmiş Cezalar
        Text(
          dil('Ödenmiş Geçmiş Cezalar', 'Paid Past Fines'),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: cInk,
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
                    children: [
                      Text(
                        dil('Haspolat Çevre Yolu Radarı', 'Haspolat Bypass Radar'),
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: cInk),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dil('24 Ocak 2024 • #KKTC-2024-110294', '24 Jan 2024 • #KKTC-2024-110294'),
                        style: TextStyle(fontSize: 11, color: cMuted),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₺1.200,00',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w900,
                      color: cInk,
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
                          builder: (context) => DekontlarSayfasi(
                            dekontlar: const [
                              {
                                'cezaId': 'PGM-2024-110294',
                                'cezaAdi': 'Haspolat Çevre Yolu Radarı',
                                'tarih': '24 Ocak 2024',
                                'tutar': '₺1.200,00',
                                'plaka': 'RZ 123',
                                'dekontNo': 'DK-9921',
                              },
                            ],
                            turkceMi: KktcDilServisi().turkceMi,
                          ),
                        ),
                      );
                    },
                    child: Text(dil('Makbuz', 'Receipt'), style: TextStyle(fontSize: 11, color: cInk, fontWeight: FontWeight.bold)),
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
              foregroundColor: cInk,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ItirazSayfasi(turkceMi: KktcDilServisi().turkceMi),
                ),
              );
            },
            icon: const Icon(Icons.gavel_rounded, size: 18),
            label: Text(
              dil('Cezaya İtiraz Talebi Oluştur', 'File a Fine Appeal'),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
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
                      child: Icon(Icons.directions_car_rounded, color: cInk, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RZ 123 • BMW 3.20i M-Sport',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: cInk),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Şasi: WBA319084 • 2022 Model',
                            style: TextStyle(fontSize: 10.5, color: cMuted),
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
                  Text(
                    'Seyrüsefer Harcı Durumu',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: cInk),
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
                  color: cSoftSurface,
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
                      foregroundColor: cInk,
                      side: BorderSide(color: cInk),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BarkodluBelgeSayfasi(
                            kullanici: 'Ahmet Demir',
                            puan: 85,
                            turkceMi: KktcDilServisi().turkceMi,
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
                  Text(
                    dil('Dijital Araç Ruhsatı (Koçan)', 'Digital Vehicle Logbook'),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: cInk),
                  ),
                  IconButton(
                    icon: Icon(Icons.open_in_new_rounded, size: 18, color: cInk),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BarkodluBelgeSayfasi(
                            kullanici: 'Ahmet Demir',
                            puan: 85,
                            turkceMi: KktcDilServisi().turkceMi,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                dil(
                  'KKTC Bayındırlık ve Ulaştırma Bakanlığı Trafik Dairesi onaylı resmi e-Ruhsat belgenizi barkodlu olarak görüntüleyebilirsiniz.',
                  'View your official digital vehicle license approved by the TRNC Traffic Department with barcode verification.',
                ),
                style: TextStyle(fontSize: 12, color: cMuted),
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
                      children: [
                        Text(
                          'Zorunlu Trafik Sigortası',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: cInk),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Dağlı Sigorta A.Ş. • #DGL-2026-TRF-9921',
                          style: TextStyle(fontSize: 10.5, color: cMuted),
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
                    child: Text(
                      () {
                        final kalan = _sigortaBitis.difference(DateTime.now()).inDays;
                        return kalan >= 0 ? '$kalan GÜN KALDI' : 'SÜRESİ DOLDU';
                      }(),
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFFD97706)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Poliçenizin son geçerlilik tarihi 14 Ekim 2026\'dır. Cezai duruma düşmemek için süresi dolmadan acenteniz ile yenileyiniz.',
                style: TextStyle(fontSize: 12, color: cMuted),
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
                      children: [
                        Text(
                          'Genişletilmiş Kasko',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: cInk),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Kıbrıs Sigorta Koop. • #KSK-4102',
                          style: TextStyle(fontSize: 10.5, color: cMuted),
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
              Text(
                'Tam Kapsamlı (Çarpma, Yangın, Çalınma, Ferdi Kaza, 7/24 Yol Yardım Dahil).',
                style: TextStyle(fontSize: 12, color: cMuted),
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
                  Text(
                    'Araç Fenni Muayene Takvimi',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: cInk),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: cSoftSurface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '48 GÜN KALDI',
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: cInk),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Son Muayene: 09 Mayıs 2026 • İstasyon: Lefkoşa Sanayi Muayene Şubesi',
                style: TextStyle(fontSize: 12, color: cMuted),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cInk,
                    side: BorderSide(color: cInk),
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
        Text(title, style: TextStyle(fontSize: 12.5, color: cMuted)),
        Text(
          val,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: cInk,
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
            decoration: BoxDecoration(
              color: cSurface,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ceza Tebliği & Güvenli Ödeme',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: cInk,
                            ),
                          ),
                          Text(
                            'Tebliğ No: PGM-2024-8841 • KKTC Polis Gn. Md.',
                            style: TextStyle(fontSize: 11, color: cMuted),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: Icon(Icons.close_rounded, color: cMuted),
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
                                            child: Text(
                                              'KRİPTOLU DELİL',
                                              style: TextStyle(
                                                color: cInk,
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
                            color: cSoftSurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: cLine),
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
                        Text(
                          'Ödeme Yöntemi Seçin',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: cInk),
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
                    color: cSurface,
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
          color: isSelected ? const Color(0xFFF0FDF4) : cSoftSurface,
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
                  color: isSelected ? cEmerald : cMuted,
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
                        color: cInk,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11, color: cMuted),
                    ),
                  ],
                ),
              ],
            ),
            Icon(Icons.credit_card_rounded, color: cInk, size: 20),
          ],
        ),
      ),
    );
  }

  void _showOdemeBasariliDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cSurface,
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
            Text(
              'Ödeme Başarıyla Alındı!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: cInk,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'PGM-2024-8841 numaralı ceza tutarı (₺1.295,00) tahsil edilerek resmi kamu veri tabanından düşülmüştür.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: cMuted),
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
                      builder: (context) => BarkodluBelgeSayfasi(
                        kullanici: 'Ahmet Demir',
                        puan: 95,
                        turkceMi: KktcDilServisi().turkceMi,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.receipt_rounded, size: 16),
                label: Text(dil('Resmi Makbuz & Barkodlu Belge', 'Official Receipt & Barcode Doc'), style: const TextStyle(fontWeight: FontWeight.bold)),
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
            decoration: BoxDecoration(
              color: cSurface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dil('Seyrüsefer Harcı Erken Yenileme', 'Road Tax Early Renewal'),
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: cInk),
                          ),
                          Text(
                            dil('Bayındırlık ve Ulaştırma Bakanlığı • RZ 123', 'Ministry of Transport • RZ 123'),
                            style: TextStyle(fontSize: 11, color: cMuted),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: Icon(Icons.close_rounded, color: cMuted),
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
                        Text(
                          dil('Yenileme Dönemi Seçin', 'Select Renewal Period'),
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: cInk),
                        ),
                        const SizedBox(height: 10),

                        InkWell(
                          onTap: () => setModalState(() => selectedDonem = 0),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selectedDonem == 0 ? const Color(0xFFF0FDF4) : cSoftSurface,
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
                                      color: selectedDonem == 0 ? cEmerald : cMuted,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dil('1 Yıllık Tam Dönem (2027)', '1-Year Full Period (2027)'),
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: cInk),
                                        ),
                                        Text(
                                          dil('Erken ödemede %10 kamu indirimi', '10% public discount on early payment'),
                                          style: const TextStyle(fontSize: 11, color: cEmerald),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Text(
                                  '₺3.105,00',
                                  style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, color: cInk, fontSize: 14),
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
                              color: selectedDonem == 1 ? const Color(0xFFF0FDF4) : cSoftSurface,
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
                                      color: selectedDonem == 1 ? cEmerald : cMuted,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dil('6 Aylık Yarı Dönem', '6-Month Semi-Annual'),
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: cInk),
                                        ),
                                        Text(
                                          dil('Erken yenileme harcı', 'Early renewal tax'),
                                          style: TextStyle(fontSize: 11, color: cMuted),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Text(
                                  '₺1.665,00',
                                  style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, color: cInk, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        Text(
                          dil('Ödeme Kartı: Garanti BBVA Bonus (•••• 4412)', 'Payment Card: Garanti BBVA Bonus (•••• 4412)'),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cMuted),
                        ),
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
                                    SnackBar(
                                      backgroundColor: cEmerald,
                                      content: Text(dil('Seyrüsefer harcınız yenilendi ve dijital pul üretildi!', 'Road tax renewed and digital tax disc issued!')),
                                    ),
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BarkodluBelgeSayfasi(
                                        kullanici: 'Ahmet Demir',
                                        puan: 85,
                                        turkceMi: KktcDilServisi().turkceMi,
                                      ),
                                    ),
                                  );
                                }
                              },
                        child: isProcessing
                            ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                            : Text(
                                selectedDonem == 0
                                    ? dil('Ödeme Yap & Pulu Üret (₺3.105,00)', 'Pay & Generate Disc (₺3,105.00)')
                                    : dil('Ödeme Yap & Pulu Üret (₺1.665,00)', 'Pay & Generate Disc (₺1,665.00)'),
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
      backgroundColor: cSurface,
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
                Text(
                  'Zorunlu Trafik Sigortası Detayı',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: cInk),
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
      backgroundColor: cSurface,
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
                Text(
                  'Online Fenni Muayene Randevusu',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: cInk),
                ),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Lefkoşa Sanayi Polis Muayene Şubesi için müsait saatler taranıyor.',
              style: TextStyle(fontSize: 12, color: cMuted),
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
        Text(
          'Dijital Sürücü Belgesi & Profil',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: cInk,
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
                    child: Text(
                      'ONAYLI',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: cInk,
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
                  color: cSurface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Icon(
                    Icons.qr_code_2_rounded,
                    size: 116,
                    color: cInk,
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
                leading: Icon(Icons.file_download_outlined, color: cInk),
                title: const Text('Dijital Ehliyet PDF İndir', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: cMuted),
                onTap: () => _showInfoDialog(title: 'PDF İndirme', message: 'Resmi karekodlu ehliyet belgeniz cihaza indirildi.'),
              ),
              Divider(height: 1, color: cSoft),
              ListTile(
                leading: Icon(Icons.security_rounded, color: cInk),
                title: const Text('Polis Doğrulama Modu', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: cMuted),
                onTap: () => _showInfoDialog(title: 'Polis Denetim Modu', message: 'Karekod tam parlaklıkta ekrana yansıtılıyor.'),
              ),
              Divider(height: 1, color: cSoft),
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
        title: Text('Çıkış Yapılsın mı?', style: TextStyle(fontWeight: FontWeight.w800, color: cInk)),
        content: const Text('Oturumunuz kapatılacak ve misafir moduna geçilecektir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('İptal', style: TextStyle(color: cMuted)),
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
    final tema = KktcTemaServisi();
    final bool koyuMu = tema.isKoyu(context);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: (koyuMu ? const Color(0xFF0D1424) : cSurface).withValues(alpha: 0.97),
            border: Border(
              bottom: BorderSide(
                color: koyuMu ? const Color(0xFF1E293B) : cSoft.withValues(alpha: 0.7),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Sol: Profil Avatarı ve Karşılama
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      _girisYapildiMi ? 'KKTC e-TRAFİK' : dil('KKTC e-TRAFİK • MİSAFİR', 'TRNC e-TRAFFIC • GUEST'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: cInk,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
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
                                _girisYapildiMi ? dil('Merhaba, $_kullaniciAdi', 'Hello, $_kullaniciAdi') : dil('Hoş Geldiniz', 'Welcome'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: koyuMu ? Colors.white : cInk,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Sağ: Giriş Yap Butonu (Giriş Yapılmadıysa) VEYA Oturum / Bildirim İkonları
                  if (!_girisYapildiMi)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeaderLanguageButton(),
                        const SizedBox(width: 4),
                        _buildHeaderIconButton(
                          icon: koyuMu ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          onTap: () => tema.showTemaSecimDialog(context),
                        ),
                        const SizedBox(width: 4),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _girisEkraniniAc();
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6.5),
                              decoration: BoxDecoration(
                                color: koyuMu ? const Color(0xFF1E293B) : cNavy,
                                borderRadius: BorderRadius.circular(16),
                                border: koyuMu ? Border.all(color: const Color(0xFF334155)) : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: (koyuMu ? Colors.black : cNavy).withValues(alpha: 0.22),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.login_rounded, size: 14, color: cLime),
                                  const SizedBox(width: 4),
                                  Text(
                                    dil('Giriş Yap', 'Sign In'),
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeaderLanguageButton(),
                        const SizedBox(width: 4),
                        _buildHeaderIconButton(
                          icon: koyuMu ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          onTap: () => tema.showTemaSecimDialog(context),
                        ),
                        const SizedBox(width: 4),
                        _buildHeaderIconButton(
                          icon: Icons.car_repair_rounded,
                          onTap: () {
                            _showYolYardimBottomSheet();
                          },
                        ),
                        const SizedBox(width: 4),
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
                        const SizedBox(width: 4),
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

    Widget _buildHeaderLanguageButton() {
    final koyuMu = KktcTemaServisi().isKoyu(context);
    final bool isEn = KktcDilServisi().isEnglish;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          KktcDilServisi().showDilSecimDialog(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 7),
          decoration: BoxDecoration(
            color: koyuMu ? const Color(0xFF16203B) : cSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: koyuMu ? const Color(0xFF263354) : cSoft),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: koyuMu ? 0.25 : 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEn ? '🇬🇧' : '🇹🇷',
                style: const TextStyle(fontSize: 12.5),
              ),
              const SizedBox(width: 3),
              Text(
                isEn ? 'EN' : 'TR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: koyuMu ? const Color(0xFF38BDF8) : cInk,
                ),
              ),
            ],
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
    final koyuMu = KktcTemaServisi().isKoyu(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: koyuMu ? const Color(0xFF16203B) : cSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: koyuMu ? const Color(0xFF263354) : cSoft),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: koyuMu ? 0.25 : 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 20, color: koyuMu ? const Color(0xFF38BDF8) : cInk),
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
                            _girisYapildiMi ? dil('EHLİYET SAĞLIK PUANI', 'DRIVER LICENSE SCORE') : dil('EHLİYET SAĞLIK PUANI (KİLİTLİ)', 'LICENSE SCORE (LOCKED)'),
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: cMuted,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _girisYapildiMi ? dil('Güvenli Sürücü Seviyesi', 'Safe Driver Level') : dil('Puanınızı Görmek İçin Giriş Yapın', 'Sign In to View Score'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: cInk,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_girisYapildiMi)
                      Row(
                        children: [
                          RichText(
                            text: TextSpan(
                              style: TextStyle(fontSize: 11.5, color: cMuted),
                              children: [
                                TextSpan(text: dil('Toplam Ceza: ', 'Penalty: ')),
                                TextSpan(
                                  text: dil('15 Puan', '15 Points'),
                                  style: TextStyle(
                                    color: cInk,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text('•', style: TextStyle(color: cMuted, fontSize: 11)),
                          ),
                          Text(
                            dil('Sınıf: A2, B, D', 'Class: A2, B, D'),
                            style: TextStyle(fontSize: 11.5, color: cMuted),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Icon(Icons.lock_outline_rounded, size: 13, color: cMuted),
                          SizedBox(width: 4),
                          Text(
                            dil('Ceza ve ehliyet sınıfı dökümü için tıklayın', 'Tap for penalty and license breakdown'),
                            style: TextStyle(fontSize: 11.5, color: cMuted, fontWeight: FontWeight.w500),
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
                    ? Column(
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
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_rounded, color: cLime, size: 22),
                          const SizedBox(height: 2),
                          Text(
                            dil('GİRİŞ', 'SIGN IN'),
                            style: const TextStyle(
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
              _girisYapildiMi ? dil('KAYITLI ARAÇLARIM (${_vehicles.length})', 'MY VEHICLES (${_vehicles.length})') : dil('KAYITLI ARAÇLARIM (GİRİŞ GEREKLİ)', 'MY VEHICLES (LOGIN REQUIRED)'),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: cMuted,
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
              child: Text(
                dil('Tümünü Yönet', 'Manage All'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cInk,
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
                  color: isSelected && _girisYapildiMi ? Colors.white : cMuted,
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
                          color: isSelected && _girisYapildiMi ? Colors.white : cInk,
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
                          child: Text(
                            dil('AKTİF', 'ACTIVE'),
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              color: cInk,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _girisYapildiMi ? model : dil('Giriş Yapın', 'Sign In'),
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected && _girisYapildiMi ? Colors.white.withOpacity(0.8) : cMuted,
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
          child: Row(
            children: [
              Icon(Icons.add_circle_outline_rounded, size: 19, color: cMuted),
              SizedBox(width: 6),
              Text(
                dil('Araç Ekle', 'Add Vehicle'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cMuted,
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
        Text(
          dil('HIZLI İŞLEMLER & DURUM', 'QUICK ACTIONS & STATUS'),
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: cMuted,
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
            // 1. Yol Forum Kartı (Önceden Cezalarım olan konum: Çevirme, Kaza, Çalışma)
            _buildGridActionCard(
              icon: Icons.forum_rounded,
              badgeWidget: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFF93C5FD)),
                ),
                child: Text(
                  dil('CANLI BİLDİRİM', 'LIVE REPORTS'),
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2563EB),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              title: dil('Yol Forum', 'Road Forum'),
              subtitle: dil('Çevirme, Kaza & Yol Olayı', 'Checkpoints, Accidents & Events'),
              onTap: _openYolForumModal,
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
                      ? (_seyruseferYenilendi ? dil('Güncel', 'Up to date') : dil('86 Gün Kaldı', '86 Days Left'))
                      : dil('GİRİŞ GEREKLİ', 'LOGIN REQUIRED'),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: _girisYapildiMi
                        ? (_seyruseferYenilendi ? cEmerald : cInk)
                        : cMuted,
                  ),
                ),
              ),
              title: dil('Seyrüsefer & Sigorta', 'Road Tax & Insurance'),
              subtitle: _girisYapildiMi
                  ? (_seyruseferYenilendi ? dil('2027 Harcı Ödendi', '2027 Fee Paid') : dil('2026/2. Dönem', '2026 / Term 2'))
                  : dil('Araç Harç Durumu', 'Vehicle Fee Status'),
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

            // 3. Cezalarım Kartı (Önceden Haritalar & GPS olan konum)
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
                      ? (_cezaOdendi ? dil('TEMİZ', 'CLEAR') : dil('1 ÖDENMEMİŞ', '1 UNPAID'))
                      : dil('GİRİŞ GEREKLİ', 'LOGIN REQUIRED'),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: _girisYapildiMi ? cInk : cMuted,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              title: dil('Cezalarım', 'My Fines'),
              bottomLabel: _girisYapildiMi ? dil('Toplam Borç', 'Total Due') : dil('Sorgula', 'Inquire'),
              bottomValue: _girisYapildiMi ? (_cezaOdendi ? '₺0' : '₺1.850') : dil('Giriş Yap', 'Sign In'),
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

            // 4. 7/24 Yol Yardımı Kartı
            _buildGridActionCard(
              icon: Icons.car_repair_rounded,
              badgeWidget: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  dil('7/24 ACİL', '24/7 SOS'),
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              title: dil('7/24 Yol Yardımı', '24/7 Road Assistance'),
              subtitle: dil('Çekici, Akü & Acil Destek', 'Towing, Battery & SOS'),
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
                    child: Icon(icon, size: 21, color: cInk),
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
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: cInk,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: cMuted,
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
                            style: TextStyle(
                              fontSize: 10.5,
                              color: cMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          bottomValue,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: cInk,
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
                    Text(
                      dil('CEZA & İHLAL SORGULAMA', 'FINE & VIOLATION INQUIRY'),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: cInk,
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
                  child: Text(
                    dil('MİSAFİR MODU', 'GUEST MODE'),
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: cMuted,
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
                      color: cSurface,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 20,
                      color: cInk,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dil('Radar ve İhlal Bildirimleri', 'Radar & Violation Alerts'),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: cInk,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          dil('Adınıza kayıtlı araçların cezalarını görmek için giriş yapın.', 'Log in to view fines registered to your vehicles.'),
                          style: TextStyle(
                            fontSize: 11,
                            color: cMuted,
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
                label: Text(
                  dil('Kimlik / Ehliyet ile Giriş Yap', 'Sign In with ID / Driving License'),
                  style: const TextStyle(
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
                  Text(
                    dil('SON İHLAL BİLDİRİMİ', 'LATEST VIOLATION REPORT'),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: cInk,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              Text(
                '18 Mayıs 2024',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: cMuted,
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
                        color: cSurface,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.speed_rounded,
                        size: 20,
                        color: cInk,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gönyeli Çemberi Radarı',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: cInk,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '78 km/s (Limit: 65 km/s)',
                          style: TextStyle(
                            fontSize: 11,
                            color: cMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₺1.850,00',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: cInk,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Son 15 gün',
                      style: TextStyle(
                        fontSize: 10,
                        color: cMuted,
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
                text: TextSpan(
                  style: TextStyle(fontSize: 12, color: cMuted),
                  children: [
                    TextSpan(text: 'Plaka: '),
                    TextSpan(
                      text: 'RZ 123',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: cInk,
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
                    child: Row(
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
    final tema = KktcTemaServisi();
    final bool koyuMu = tema.isKoyu(context);

    return Container(
      decoration: BoxDecoration(
        color: tema.navBarBg,
        border: Border(
          top: BorderSide(
            color: tema.navBarBorder,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: koyuMu ? 0.35 : 0.08),
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
                label: dil('Panel', 'Dashboard'),
              ),
              // 2. Yol Tarifi (Tab 1 - Panelin Yanındaki Konum)
              _buildBottomNavItem(
                index: 1,
                icon: Icons.navigation_rounded,
                label: dil('Yol Tarifi', 'Route'),
                hasActiveYellowBadge: true,
                onCustomTap: () {
                  setState(() {
                    _selectedTabIndex = 1;
                  });
                },
              ),
              // 3. E-Denetim (Orta Yükseltilmiş Hızlı Buton)
              _buildCenterActionItem(
                label: dil('E-Denetim', 'E-Pass'),
                onTap: () {
                  HapticFeedback.heavyImpact();
                  _girisKontrolEt(
                    islemAdi: dil('E-Denetim barkodlu dijital belge oluşturmak', 'Creating E-Pass digital document'),
                    onGirisSonrasi: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BarkodluBelgeSayfasi(
                            kullanici: _kullaniciAdi,
                            puan: 85,
                            turkceMi: KktcDilServisi().turkceMi,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              // 4. Cezalar & Sigorta (Tab 3 - E-Denetimin Sağındaki Konum)
              _buildBottomNavItem(
                index: 3,
                icon: Icons.receipt_long_rounded,
                label: dil('Cezalar', 'Fines'),
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
                label: dil('Menü', 'Menu'),
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
    final tema = KktcTemaServisi();
    final bool koyuMu = tema.isKoyu(context);
    final activeCol = koyuMu ? const Color(0xFF38BDF8) : cNavy;
    final inactiveCol = koyuMu ? const Color(0xFF64748B) : cSlate;

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
                    color: activeCol.withValues(alpha: koyuMu ? 0.2 : 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 20, color: activeCol),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: activeCol,
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
                          color: isActive ? activeCol : inactiveCol,
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
                                border: Border.all(color: koyuMu ? const Color(0xFF0D1424) : Colors.white, width: 1.5),
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
                                border: Border.all(color: koyuMu ? const Color(0xFF0D1424) : Colors.white, width: 1.5),
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
                            color: isActive ? activeCol : inactiveCol,
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
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: cInk,
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

