import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'canli_gps_servisi.dart';
import 'radar_haritasi.dart';
import 'kktc_dil_servisi.dart';

/// KKTC e-Trafik Radar & Taktiksel Canlı Navigasyon Kokpiti
/// HTML / Tailwind CSS tasarımının birebir Flutter uyarlamasıdır.
class KktcETrafikRadarKokpitSayfasi extends StatefulWidget {
  final VoidCallback? onStartNavigation;
  final VoidCallback? onOpenRadarList;
  final VoidCallback? onOpenDashboard;
  final VoidCallback? onOpenFines;
  final VoidCallback? onOpenInsurance;
  final VoidCallback? onOpenProfile;

  const KktcETrafikRadarKokpitSayfasi({
    super.key,
    this.onStartNavigation,
    this.onOpenRadarList,
    this.onOpenDashboard,
    this.onOpenFines,
    this.onOpenInsurance,
    this.onOpenProfile,
  });

  @override
  State<KktcETrafikRadarKokpitSayfasi> createState() =>
      _KktcETrafikRadarKokpitSayfasiState();
}

class _KktcETrafikRadarKokpitSayfasiState
    extends State<KktcETrafikRadarKokpitSayfasi>
    with TickerProviderStateMixin {
  // Renk Paleti (HTML tasarımındaki tokenlar ile birebir)
  static const Color cBg = Color(0xFF0A122A);
  static const Color cSurface = Color(0xFF0A122A);
  static const Color cSurfaceContainer = Color(0xFF171E37);
  static const Color cSurfaceContainerHigh = Color(0xFF212942);
  static const Color cSurfaceElevated = Color(0xFF2C344D);
  static const Color cSurfaceLowest = Color(0xFF050D25);
  static const Color cOnSurface = Color(0xFFDBE1FF);
  static const Color cSecondary = Color(0xFFBDC5E9);
  static const Color cSecondaryFixed = Color(0xFFDBE1FF);
  static const Color cSecondaryFixedDim = Color(0xFFBDC5E9);
  static const Color cPrimaryContainer = Color(0xFFD90429);
  static const Color cTertiary = Color(0xFF4EDEA3);
  static const Color cAlertCrimson = Color(0xFFFF4D4F);

  // Durum Değişkenleri
  bool _isSoundOn = true;
  bool get _isEnglish => KktcDilServisi().isEnglish;
  int _selectedBottomNavIndex = 1; // 1: Radarlar aktif
  int _currentSpeed = 68;
  final int _speedLimit = 65;

  late AnimationController _radarScanController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Radar Döngü Animasyonu (Sürekli dönen tarayıcı)
    _radarScanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Nabız Yanıp Sönme Animasyonu
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Canlı Gerçek GPS Servisi Dinleyicisi
    CanliGpsServisi().addListener(_onGpsGuncellendi);
    CanliGpsServisi().servisiBaslat();
  }

  void _onGpsGuncellendi() {
    if (!mounted) return;
    final gps = CanliGpsServisi();
    if (gps.gpsAktif && gps.gercekHizKmh > 0) {
      setState(() {
        _currentSpeed = gps.gercekHizKmh.round();
      });
    }
  }

  @override
  void dispose() {
    CanliGpsServisi().removeListener(_onGpsGuncellendi);
    _radarScanController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _showInfoSheet(String title, String description) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: cSurfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  color: cSecondaryFixedDim,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cSecondaryFixed,
                    foregroundColor: cSurfaceLowest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    _isEnglish ? 'Dismiss' : 'Kapat',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: KktcDilServisi(),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: cBg,
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: cSurfaceLowest,
            ),
        child: Stack(
          children: [
            // Ana Kaydırılabilir İçerik Alanı
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 86, // Header payı
                  bottom: 96, // Bottom Nav payı
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Üst Kayan Araç ve Yol Durum Başlığı
                        _buildVehicleAndStatusCard(),
                        const SizedBox(height: 16),

                        // 2. Birincil Taktiksel Harita & Telemetri Kokpiti
                        _buildMapAndCockpitLayer(),
                        const SizedBox(height: 16),

                        // 3. Gerçek Zamanlı Yol Kenarı Radar İhlal / Uyarı Kartı
                        _buildTacticalRoadsideCard(),
                        const SizedBox(height: 14),

                        // 4. Belge ve Sigorta Hızlı Durum Çubuğu
                        _buildDocumentStatusStrip(),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Üst Sabit Header (Glassmorphic)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopHeader(),
            ),

            // Alt Sabit 5'li Navigasyon Barı
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomNav(),
            ),
          ],
        ),
      ),
    );
      },
    );
  }

  // ===========================================================================
  // 1. ÜST HEADER
  // ===========================================================================
  Widget _buildTopHeader() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: cSurface.withOpacity(0.85),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Sol: Polis Rozeti ve Logo
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cPrimaryContainer.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_police_rounded,
                          color: cPrimaryContainer,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'KKTC',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFFFB3AF),
                                  letterSpacing: 1.8,
                                ),
                              ),
                              const SizedBox(width: 5),
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) => Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: cTertiary.withOpacity(_pulseAnimation.value),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: cTertiary.withOpacity(_pulseAnimation.value * 0.7),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'e-Trafik',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: cOnSurface,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Sağ: Dil Butonu, Bildirim ve Profil
                  Row(
                    children: [
                      // Dil Seçimi (TR / EN)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            KktcDilServisi().dilDegistir(!KktcDilServisi().turkceMi);
                            setState(() {});
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: cSurfaceContainerHigh.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _isEnglish ? 'EN' : 'TR',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                color: cSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Bildirim Zili
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _showInfoSheet(
                              _isEnglish ? 'Active Radar Alerts' : 'Aktif Radar Uyarıları',
                              _isEnglish
                                  ? 'Route alerts are synchronized with official KKTC Police radars.'
                                  : 'Güzergah üzerindeki 4 radar KKTC Polis Genel Müdürlüğü sistemleri ile eşzamanlıdır.',
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: cSurfaceContainerHigh.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(
                                  Icons.notifications_rounded,
                                  color: cOnSurface,
                                  size: 22,
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: cPrimaryContainer,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: cSurface, width: 1.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Profil İkonu
                      GestureDetector(
                        onTap: () {
                          if (widget.onOpenProfile != null) {
                            widget.onOpenProfile!();
                          }
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFB3AF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Color(0xFF68000E),
                            size: 19,
                          ),
                        ),
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

  // ===========================================================================
  // 2. ÜST KAYAN ARAÇ VE YOL DURUM BAŞLIĞI
  // ===========================================================================
  Widget _buildVehicleAndStatusCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cSurfaceContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Aktif Araç ve Dönen Canlı Radar Sayacı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Araç Hapı
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: cSurfaceLowest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.directions_car_rounded,
                      color: Color(0xFFFFB3AF),
                      size: 17,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'RZ 123',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: cSecondaryFixed,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '•',
                        style: TextStyle(color: cSecondary.withOpacity(0.5)),
                      ),
                    ),
                    const Text(
                      'BMW 3.20i',
                      style: TextStyle(
                        fontSize: 12,
                        color: cSecondaryFixedDim,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: cTertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),

              // Dönen Radar ve Aktif Sayıcı
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: cSurfaceElevated,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RotationTransition(
                      turns: _radarScanController,
                      child: const Icon(
                        Icons.radar_rounded,
                        color: cOnSurface,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isEnglish ? '4 ACTIVE RADARS' : '4 AKTİF RADAR',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: cOnSurface,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Arama & Hedef Dokunma Tetikleyici Çubuğu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: cSurfaceLowest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.explore_rounded,
                  color: cOnSurface,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEnglish
                            ? 'Nicosia — Kyrenia Mountain Pass'
                            : 'Lefkoşa — Girne Boğazı',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: cSecondaryFixed,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isEnglish
                            ? 'Search destination or tap map'
                            : 'Hedef ara veya haritaya dokun',
                        style: const TextStyle(
                          fontSize: 11,
                          color: cSecondaryFixedDim,
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showInfoSheet(
                        _isEnglish ? 'Touch-to-Route' : 'Haritada Nokta Seçimi',
                        _isEnglish
                            ? 'Tap anywhere along the Kyrenia corridor to recompute safest speed paths.'
                            : 'Güzergahtaki en güvenli hız limitlerini izlemek için noktaya dokunun.',
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: cSurfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.near_me_rounded,
                        color: cOnSurface,
                        size: 19,
                      ),
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

  // ===========================================================================
  // 3. TAKTİKSEL HARİTA & TELEMETRİ KOKPİTİ
  // ===========================================================================
  Widget _buildMapAndCockpitLayer() {
    return Container(
      height: 380,
      decoration: BoxDecoration(
        color: cSurfaceLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Arka Plan Izgarası ve Yol Çizgisi (Custom Painter)
            Positioned.fill(
              child: CustomPaint(
                painter: _TacticalRoadPainter(
                  pulseValue: _pulseAnimation.value,
                ),
              ),
            ),

            // Radar İşaretçisi 1: Gönyeli 65 (Kırmızı Yanıp Sönen Rozet)
            Positioned(
              top: 175,
              left: 105,
              child: GestureDetector(
                onTap: () {
                  _showInfoSheet(
                    'Gönyeli Çemberi Kamerası',
                    'Limit: 65 km/s • Tip: Sabit Hız Radarı (Çift Yönlü). İhlal durumunda ₺1.850 ceza uygulanır.',
                  );
                },
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: cSurfaceContainer,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: cAlertCrimson,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Gönyeli 65',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: cSecondaryFixed,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: cAlertCrimson,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.photo_camera_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Radar İşaretçisi 2: Boğaz 50
            Positioned(
              top: 75,
              right: 75,
              child: GestureDetector(
                onTap: () {
                  _showInfoSheet(
                    'Girne Boğaz Radarı',
                    'Limit: 50 km/s • Tip: Viraj Güvenlik Radarı. Boğaz inişinde aktif hız kontrolü.',
                  );
                },
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: cSurfaceContainer,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Text(
                        'Boğaz 50',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: cSecondaryFixed,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: cSurfaceElevated,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.speed_rounded,
                        color: cOnSurface,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sol Üst HUD Telemetrisi: Anlık Hız ve Limit Levhası
            Positioned(
              top: 14,
              left: 14,
              child: Row(
                children: [
                  // Hız Göstergesi Rozeti
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: cSurfaceLowest.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.12)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEnglish ? 'SPEED' : 'HIZINIZ',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: cSecondaryFixedDim,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '$_currentSpeed',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: _currentSpeed > _speedLimit
                                        ? const Color(0xFFFFB3AF)
                                        : Colors.white,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                const Text(
                                  'km/s',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: cSecondaryFixedDim,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Yasal Hız Sınırı Levhası (Kırmızı Daire TRS)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD90429), width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'LİMİT',
                          style: TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFD90429),
                            height: 1.0,
                          ),
                        ),
                        Text(
                          '65',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Sağ Üst Harita Yardımcı Butonları (Ses, Katmanlar, Konum)
            Positioned(
              top: 14,
              right: 14,
              child: Column(
                children: [
                  _buildFloatingMapButton(
                    icon: _isSoundOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                    isActive: _isSoundOn,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _isSoundOn = !_isSoundOn);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildFloatingMapButton(
                    icon: Icons.layers_rounded,
                    onTap: () {
                      _showInfoSheet(
                        _isEnglish ? 'Map Layers' : 'Harita Katmanları',
                        _isEnglish
                            ? 'Satellite, Traffic Density, and Night Radar HUD active.'
                            : 'Uydu, Trafik Yoğunluğu ve Sabit Radarlar katmanı devrededir.',
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildFloatingMapButton(
                    icon: Icons.my_location_rounded,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // Simüle edilmiş hız değişimi
                      setState(() {
                        _currentSpeed = _currentSpeed == 68 ? 62 : 68;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Alt Harita Bilgi Şeridi
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: cSurfaceContainer.withOpacity(0.92),
                      border: Border(
                        top: BorderSide(color: Colors.white.withOpacity(0.08)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.navigation_rounded,
                              size: 16,
                              color: cOnSurface,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isEnglish
                                  ? 'Touch-to-Route active'
                                  : 'Touch-to-Route devrede',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: cSecondaryFixed,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          '18.4 km • 14 dk',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: cOnSurface,
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
    );
  }

  Widget _buildFloatingMapButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: cSurfaceLowest.withOpacity(0.88),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 20,
            color: isActive ? cTertiary : cSecondaryFixed,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 4. GERÇEK ZAMANLI YOL KENARI UYARI KARTI
  // ===========================================================================
  Widget _buildTacticalRoadsideCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cSurfaceContainer,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Acil Radar Uyarısı Kutusu
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cSurfaceElevated,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: cSurfaceLowest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.photo_camera_rounded,
                    color: cOnSurface,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isEnglish ? 'FIXED SPEED RADAR' : 'SABİT RADAR DENETİMİ',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: cOnSurface,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Text(
                            '500m',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: cSecondaryFixed,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Gönyeli Çemberi Kamerası',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: cSecondaryFixed,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _isEnglish
                            ? 'Speed Limit: 65 km/h'
                            : 'Yasal Hız Sınırı: 65 km/s',
                        style: const TextStyle(
                          fontSize: 11,
                          color: cSecondaryFixedDim,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 2 Sütun Trafik Akış Durumu
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cSurfaceLowest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: cTertiary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isEnglish ? 'GÖNYELİ FLOW' : 'GÖNYELİ AKIŞI',
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: cSecondaryFixedDim,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isEnglish ? 'Fluid (62 km/h)' : 'Akıcı (62 km/s)',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: cSecondaryFixed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cSurfaceLowest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: cOnSurface,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isEnglish ? 'BOGAZ PASS' : 'BOĞAZ BOĞAZI',
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: cSecondaryFixedDim,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isEnglish ? 'Moderate (38 km/h)' : 'Orta (38 km/s)',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: cSecondaryFixed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Navigasyonu Başlat Butonu & Liste İkonu
          Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      if (widget.onStartNavigation != null) {
                        widget.onStartNavigation!();
                      } else {
                        _showInfoSheet(
                          _isEnglish ? 'Starting Navigation' : 'Navigasyon Başlatılıyor',
                          _isEnglish
                              ? 'Live telemetry and radar speed traps are now active on your route.'
                              : 'Sesli radar uyarıları ve anlık hız takibi ile rota başlatıldı.',
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: cSecondaryFixed,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.turn_sharp_right_rounded,
                            color: cSurfaceLowest,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isEnglish ? 'Start Navigation' : 'Navigasyonu Başlat',
                            style: const TextStyle(
                              color: cSurfaceLowest,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (widget.onOpenRadarList != null) {
                      widget.onOpenRadarList!();
                    } else {
                      _showInfoSheet(
                        _isEnglish ? 'KKTC Radar Directory' : 'KKTC Radar Listesi',
                        'KKTC genelinde aktif 142 sabit hız radarı ve koordinat listesi.',
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: cSurfaceElevated,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.list_alt_rounded,
                      color: cSecondaryFixed,
                      size: 21,
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
  // 5. BELGE VE SİGORTA HIZLI DURUM ÇUBUĞU
  // ===========================================================================
  Widget _buildDocumentStatusStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cSurfaceContainer.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_rounded,
                color: cTertiary,
                size: 19,
              ),
              const SizedBox(width: 8),
              Text(
                _isEnglish
                    ? 'Road Tax & Insurance Valid'
                    : 'Seyrüsefer & Sigorta Geçerli',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: cSecondaryFixed,
                ),
              ),
            ],
          ),
          Text(
            _isEnglish ? '142 Days' : '142 Gün',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: cOnSurface,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 6. ALT SABİT 5'Lİ NAVİGASYON BARI
  // ===========================================================================
  Widget _buildBottomNav() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: cSurfaceLowest.withOpacity(0.92),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  _buildBottomNavItem(
                    index: 0,
                    icon: Icons.dashboard_rounded,
                    label: 'Panel',
                    onTap: widget.onOpenDashboard,
                  ),
                  _buildBottomNavItem(
                    index: 1,
                    icon: Icons.radar_rounded,
                    label: _isEnglish ? 'Radars' : 'Radarlar',
                  ),
                  _buildBottomNavItem(
                    index: 2,
                    icon: Icons.receipt_long_rounded,
                    label: _isEnglish ? 'Fines' : 'Cezalar',
                    onTap: widget.onOpenFines,
                  ),
                  _buildBottomNavItem(
                    index: 3,
                    icon: Icons.shield_rounded,
                    label: _isEnglish ? 'Insurance' : 'Sigorta',
                    onTap: widget.onOpenInsurance,
                  ),
                  _buildBottomNavItem(
                    index: 4,
                    icon: Icons.badge_rounded,
                    label: _isEnglish ? 'Profile & QR' : 'Profil & QR',
                    onTap: widget.onOpenProfile,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final bool isActive = _selectedBottomNavIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedBottomNavIndex = index);
            if (onTap != null) onTap();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: isActive ? const Color(0xFFFFB3AF) : cSecondary.withOpacity(0.7),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                  color: isActive ? const Color(0xFFFFB3AF) : cSecondary.withOpacity(0.7),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Taktiksel Harita Yol Çizicisi (CustomPainter)
/// HTML'deki SVG arterial yol eğrisini, ışık parlamasını ve araç konumunu çizer.
class _TacticalRoadPainter extends CustomPainter {
  final double pulseValue;

  _TacticalRoadPainter({required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Arka plan grid çizgileri
    final Paint gridPaint = Paint()
      ..color = const Color(0xFF171E37).withOpacity(0.4)
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Taktiksel Yol Yolu (Bézier Curve)
    final Path roadPath = Path();
    // Koordinatlar HTML SVG: M 40 370 C 90 310 110 240 180 185 C 230 145 250 90 320 20
    final double scaleX = size.width / 360.0;
    final double scaleY = size.height / 380.0;

    roadPath.moveTo(40 * scaleX, 370 * scaleY);
    roadPath.cubicTo(
      90 * scaleX, 310 * scaleY,
      110 * scaleX, 240 * scaleY,
      180 * scaleX, 185 * scaleY,
    );
    roadPath.cubicTo(
      230 * scaleX, 145 * scaleY,
      250 * scaleX, 90 * scaleY,
      320 * scaleX, 20 * scaleY,
    );

    // Sarı Glow Arka Plan Işığı
    final Paint glowPaint = Paint()
      ..color = const Color(0xFFF0E748).withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14 * scaleX
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(roadPath, glowPaint);

    // Kesikli Taktiksel Sarı Yol Çizgisi
    final Paint roadPaint = Paint()
      ..color = const Color(0xFFF0E748)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5 * scaleX
      ..strokeCap = StrokeCap.round;

    // Kesikli efekt çizimi
    _drawDashedPath(canvas, roadPath, roadPaint, 8.0, 5.0);

    // 3. Araç Konumu İşaretçisi (Ping)
    final Offset vehiclePos = Offset(120 * scaleX, 235 * scaleY);

    // Dış Halka
    final Paint outerRing = Paint()
      ..color = const Color(0xFF01081F)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(vehiclePos, 11, outerRing);

    final Paint borderRing = Paint()
      ..color = const Color(0xFFF0E748)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(vehiclePos, 11, borderRing);

    // İç Yeşil Canlı Nokta (Nabız)
    final Paint innerDot = Paint()
      ..color = const Color(0xFF34C759)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(vehiclePos, 5 + (pulseValue * 1.5), innerDot);
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double length = math.min(dashWidth, metric.length - distance);
        final Path extractPath = metric.extractPath(distance, distance + length);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TacticalRoadPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue;
  }
}
