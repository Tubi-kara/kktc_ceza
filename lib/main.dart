import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'radar_haritasi.dart';
import 'yol_tarifi_sayfasi.dart';
import 'kktc_gov_sync_service.dart';
import 'yardim_rehberi_sayfasi.dart';
import 'hizli_arama_modali.dart';
import 'guncelleme_servisi.dart';
import 'guvenlik_duvari.dart';
import 'kktc_e_trafik_dashboard_sayfasi.dart';
import 'kktc_tema_servisi.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const KktcCezaApp());
}

// ==========================================
// 🎨 MODERN DESIGN TOKENS & THEME
// ==========================================
class AppColors {
  static const Color primary = Color(0xFFDC2626); // Modern Crimson
  static const Color primaryDark = Color(0xFF991B1B);
  static const Color primaryLight = Color(0xFFFEE2E2);
  static const Color accent = Color(0xFFE11D48);

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9);

  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate200 = Color(0xFFE2E8F0);

  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF0EA5E9);
  static const Color infoLight = Color(0xFFE0F2FE);
}

class KktcCezaApp extends StatefulWidget {
  const KktcCezaApp({super.key});

  @override
  State<KktcCezaApp> createState() => _KktcCezaAppState();
}

class _KktcCezaAppState extends State<KktcCezaApp> {
  bool _splashGosteriliyor = true; // Sinematik açılış animasyonu devrede
  final bool _turkceMi = true;
  bool _girisYapildiMi = false; // Doğrudan misafir modunda başlar
  String _kullaniciAdi = "Misafir Kullanıcı";

  void _cikisYap() {
    setState(() {
      _girisYapildiMi = false;
      _kullaniciAdi = "Misafir Kullanıcı";
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: KktcTemaServisi(),
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'KKTC e-Trafik',
          themeMode: KktcTemaServisi().flutterThemeMode,
          theme: KktcTemaServisi.acikTemaData,
          darkTheme: KktcTemaServisi.koyuTemaData,
          home: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _splashGosteriliyor
                ? AcilisAnimasyonuSayfasi(
                    key: const ValueKey('splash_screen'),
                    turkceMi: _turkceMi,
                    onTamamlandi: () {
                      setState(() => _splashGosteriliyor = false);
                    },
                  )
                : KktcETrafikDashboardSayfasi(
                    key: const ValueKey('kktc_modern_dashboard'),
                    onCikisYap: _cikisYap,
                    initialGirisYapildiMi: _girisYapildiMi,
                    initialKullaniciAdi: _kullaniciAdi,
                  ),
          ),
        );
      },
    );
  }
}

// ==========================================
// 🌟 SİNEMATİK AÇILIŞ ANİMASYONU (SPLASH SCREEN)
// ==========================================
class AcilisAnimasyonuSayfasi extends StatefulWidget {
  final bool turkceMi;
  final VoidCallback onTamamlandi;

  const AcilisAnimasyonuSayfasi({
    super.key,
    required this.turkceMi,
    required this.onTamamlandi,
  });

  @override
  State<AcilisAnimasyonuSayfasi> createState() => _AcilisAnimasyonuSayfasiState();
}

class _AcilisAnimasyonuSayfasiState extends State<AcilisAnimasyonuSayfasi>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;

  late final AnimationController _pulseController;
  late final AnimationController _textController;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  late final AnimationController _progressController;
  String _durumMetni = "";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _durumMetni = widget.turkceMi
        ? "Güvenli kamu ağına bağlanılıyor..."
        : "Connecting to secure network...";

    // Logo animasyonu (Büyüme & Parlama)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );
    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    );

    // Radar dalgaları
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    // Metin animasyonu
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textFade = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    // Yükleme çubuğu
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Animasyon zincirini başlat
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _textController.forward();
    });
    _progressController.forward();

    // Telemetri durum güncellemeleri
    Future.delayed(const Duration(milliseconds: 750), () {
      if (mounted) {
        setState(() {
          _durumMetni = widget.turkceMi
              ? "WAF Siber Güvenlik Duvarı devrede..."
              : "WAF Cyber Security Shield active...";
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _durumMetni = widget.turkceMi
              ? "Trafik & radar verileri eşitlendi..."
              : "Traffic & radar telemetry synced...";
        });
      }
    });

    // Açılış tamamlandığında giriş ekranına geçiş yap
    _timer = Timer(const Duration(milliseconds: 2350), () {
      if (mounted) widget.onTamamlandi();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _logoController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF060B19),
      body: Stack(
        children: [
          // ── Arka Plan Siber Glow Işıkları ──
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFDC2626).withValues(alpha: 0.18),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0284C7).withValues(alpha: 0.16),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.40,
            left: size.width * 0.25,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10B981).withValues(alpha: 0.10),
              ),
            ),
          ),

          // ── Hızlı Geçiş (Atla) Butonu ──
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 16),
                child: TextButton(
                  onPressed: widget.onTamamlandi,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.turkceMi ? 'Atla' : 'Skip',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Ana İçerik (Logo, Başlık & Yükleme Göstergesi) ──
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // 🛡️ Dönen / Parlayan Radar Halka & 3D Logo Arması
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // 1. Radar Dalga Halkası
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final v = _pulseController.value;
                          return Container(
                            width: 120 + 80 * v,
                            height: 120 + 80 * v,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF38BDF8).withValues(alpha: (1 - v) * 0.35),
                                width: 1.5,
                              ),
                            ),
                          );
                        },
                      ),

                      // 2. İkinci Dış Dalga Halkası
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final v = (_pulseController.value + 0.5) % 1.0;
                          return Container(
                            width: 120 + 80 * v,
                            height: 120 + 80 * v,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF10B981).withValues(alpha: (1 - v) * 0.30),
                                width: 1.2,
                              ),
                            ),
                          );
                        },
                      ),

                      // 3. Merkezdeki Resmi KKTC e-Trafik Logosu
                      FadeTransition(
                        opacity: _logoFade,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0284C7).withValues(alpha: 0.45),
                                  blurRadius: 32,
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.70),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Image.asset(
                                'assets/app_logo.png',
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: const Color(0xFF1E293B),
                                  child: const Icon(
                                    Icons.shield_rounded,
                                    color: Color(0xFF38BDF8),
                                    size: 54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // 📝 Kurumsal Başlık & Tipografi (Slide & Fade)
                  FadeTransition(
                    opacity: _textFade,
                    child: SlideTransition(
                      position: _textSlide,
                      child: Column(
                        children: [
                          // Üst Resmi Kurum Etiketi
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'KUZEY KIBRIS TÜRK CUMHURİYETİ',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Uygulama Adı
                          const Text(
                            'KKTC e-Trafik',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Açıklama
                          Text(
                            widget.turkceMi
                                ? 'KKTC e-TRAFİK • Akıllı Trafik & Güvenli Kamu Portalı'
                                : 'TRNC e-TRAFFIC • Smart Traffic & Secure Public Portal',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // ⚡ Alt Telemetri & Canlı İlerleme Çubuğu
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AnimatedBuilder(
                            animation: _progressController,
                            builder: (context, child) {
                              return LinearProgressIndicator(
                                value: _progressController.value,
                                minHeight: 4,
                                backgroundColor: Colors.white.withValues(alpha: 0.08),
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Durum Metni ve Yanıp Sönen Yeşil Nokta
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _durumMetni,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.55),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 🔒 SSL Şifreleme Bilgisi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_rounded, color: Colors.white.withValues(alpha: 0.35), size: 12),
                      const SizedBox(width: 5),
                      Text(
                        '256-Bit SSL • Resmi Kamu Ağı',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 🚀 1. MODERN GİRİŞ SAYFASI (HTML Tasarım Uyumu)
// ==========================================

// Design tokens — HTML renk paletine birebir eşleştirildi
class _HtmlColors {
  static const Color background = Color(0xFF0A122A);
  static const Color surfaceContainer = Color(0xFF171E37);
  static const Color surfaceContainerLow = Color(0xFF131A33);
  static const Color surfaceContainerHigh = Color(0xFF212942);
  static const Color surfaceBright = Color(0xFF313852);
  static const Color primaryContainer = Color(0xFFD90429); // kırmızı buton
  static const Color primary = Color(0xFFFFB3AF);
  static const Color secondary = Color(0xFFBDC5E9);
  static const Color tertiary = Color(0xFF4EDEA3);
  static const Color onSurface = Color(0xFFDBE1FF);
  static const Color surfaceContainerLowest = Color(0xFF050D25);
  static const Color surfaceContainerHighest = Color(0xFF2C344D);
  static const Color tertiaryContainer = Color(0xFF007C55);
  static const Color tertiaryFixed = Color(0xFF6FFBBE);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color primaryFixedDim = Color(0xFFFFB3AF);
  static const Color onPrimary = Color(0xFF68000E);
  static const Color onPrimaryContainer = Color(0xFFFFEAE8);
  // onSurfaceVariant ve outlineVariant gelecekte kullanılmak üzere kaldırıldı
  static const Color onSecondaryContainer = Color(0xFFABB4D7);
  static const Color tertiaryFixedDim = Color(0xFF4EDEA3);
}

enum KullaniciTuru {
  kktcVatandas,
  tcVatandas,
  ogrenci,
  uluslararasi,
  admin, // 🛡️ PGM Bilgi İşlem / Siber Operasyon Merkezi Yöneticisi
}

class GirisSayfasi extends StatefulWidget {
  final bool turkceMi;
  final Function(bool) onDilDegistir;
  final Function(String, List<String>, String) onGirisBasarili;

  const GirisSayfasi({
    super.key,
    required this.turkceMi,
    required this.onDilDegistir,
    required this.onGirisBasarili,
  });

  @override
  State<GirisSayfasi> createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends State<GirisSayfasi>
    with TickerProviderStateMixin {
  // 0 = Giriş Yap, 1 = Kayıt Ol
  int _seciliSegment = 0;

  // Giriş Controllerları
  final TextEditingController _girisController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();

  // Kayıt Controllerları
  final TextEditingController _kayitAdSoyadController = TextEditingController();
  final TextEditingController _kayitKimlikController = TextEditingController();
  final TextEditingController _kayitTelefonController = TextEditingController();
  final TextEditingController _kayitPlakaController = TextEditingController();
  final TextEditingController _kayitSifreController = TextEditingController();

  bool _sifreGizli = true;
  bool _kayitSifreGizli = true;
  bool _biyometrikYukleniyor = false;
  bool _biyometrikBasarili = false;
  bool _girisYukleniyor = false;
  bool _girisBasariliAnimasyon = false;

  // Kayıt: Kullanıcı Tipi Seçimi (0=KKTC, 1=TC, 2=Öğrenci, 3=Uluslararası)
  int _secilenKullaniciTipi = 0;
  // Kayıt: Öğrenci için üniversite seçimi
  int _secilenUni = 0;

  late final AnimationController _pingController;

  @override
  void initState() {
    super.initState();
    _pingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _girisController.dispose();
    _sifreController.dispose();
    _kayitAdSoyadController.dispose();
    _kayitKimlikController.dispose();
    _kayitTelefonController.dispose();
    _kayitPlakaController.dispose();
    _kayitSifreController.dispose();
    _pingController.dispose();
    super.dispose();
  }

  void _girisYap() {
    String numara = _girisController.text.trim();
    String sifre = _sifreController.text.trim();

    if (numara.isEmpty || sifre.isEmpty) {
      _snack(
        widget.turkceMi
            ? 'Lütfen kimlik/kullanıcı adı ve şifrenizi girin.'
            : 'Please enter your ID/username and password.',
        isError: true,
      );
      return;
    }

    // 🛡️ ÖZEL SİSTEM YÖNETİCİSİ GİRİŞİ: Kullanıcı Adı: "tubi" • Şifre: "1907"
    if (numara.toLowerCase() == 'tubi' && sifre == '1907') {
      setState(() => _girisYukleniyor = true);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() {
          _girisYukleniyor = false;
          _girisBasariliAnimasyon = true;
        });
        Future.delayed(const Duration(milliseconds: 350), () {
          widget.onGirisBasarili(
            widget.turkceMi ? "Tubi (Sistem Yöneticisi)" : "Tubi (System Admin)",
            ["PGM 001", "POLIS 155", "ST 999"],
            "PGM Siber Operasyon Merkezi (SOC / Admin)",
          );
        });
      });
      return;
    }

    setState(() => _girisYukleniyor = true);

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      setState(() {
        _girisYukleniyor = false;
        _girisBasariliAnimasyon = true;
      });

      Future.delayed(const Duration(milliseconds: 400), () {
        widget.onGirisBasarili(
          widget.turkceMi ? "Ahmet Demir" : "Ahmet Demir",
          ["KY 987", "LZ 555"],
          widget.turkceMi ? "Kayıtlı Sürücü (KKTC)" : "Registered Driver (TRNC)",
        );
      });
    });
  }

  void _kayitOl() {
    String adSoyad = _kayitAdSoyadController.text.trim();
    String kimlik = _kayitKimlikController.text.trim();
    final _ = _kayitTelefonController.text.trim(); // telefon ileride backend için kullanılacak
    String plaka = _kayitPlakaController.text.trim().toUpperCase();
    String sifre = _kayitSifreController.text.trim();

    if (adSoyad.isEmpty || kimlik.isEmpty || sifre.isEmpty) {
      _snack(
        widget.turkceMi
            ? 'Lütfen Ad Soyad, Kimlik No ve Şifre alanlarını doldurun.'
            : 'Please fill in Full Name, ID and Password.',
        isError: true,
      );
      return;
    }

    final String seciliRol;
    switch (_secilenKullaniciTipi) {
      case 0:
        seciliRol = widget.turkceMi ? 'KKTC Vatandaşı (Kayıtlı Sürücü)' : 'TRNC Citizen (Registered Driver)';
        break;
      case 1:
        seciliRol = widget.turkceMi ? 'T.C. Vatandaşı / İkamet' : 'TR Citizen / Resident';
        break;
      case 2:
        final List<String> uniAdlari = [
          'ODTÜ KKK', 'YDÜ', 'DAÜ (EMU)', 'GAÜ', 'UKÜ', 'LAÜ', 'Beykent KKK', 'Diğer',
        ];
        final String uni = (_secilenUni >= 0 && _secilenUni < uniAdlari.length)
            ? uniAdlari[_secilenUni]
            : 'KKTC Üniversitesi';
        seciliRol = widget.turkceMi
            ? 'Öğrenci • $uni'
            : 'Student • $uni';
        break;
      case 3:
        seciliRol = widget.turkceMi ? 'Uluslararası Sürücü / Turist' : 'International Driver / Tourist';
        break;
      default:
        seciliRol = widget.turkceMi ? 'Kayıtlı Sürücü' : 'Registered Driver';
    }

    if (plaka.isEmpty) {
      plaka = "KY 987";
    }

    setState(() => _girisYukleniyor = true);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _girisYukleniyor = false;
        _girisBasariliAnimasyon = true;
      });

      _snack(
        widget.turkceMi
            ? 'Tebrikler! Kaydınız oluşturuldu, güvenli giriş yapılıyor...'
            : 'Congratulations! Account created, logging in...',
      );

      Future.delayed(const Duration(milliseconds: 450), () {
        widget.onGirisBasarili(
          adSoyad,
          [plaka],
          seciliRol,
        );
      });
    });
  }

  void _biyometrikGiris() async {
    setState(() {
      _biyometrikYukleniyor = true;
      _biyometrikBasarili = false;
    });
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _biyometrikYukleniyor = false;
      _biyometrikBasarili = true;
      _girisController.text = '123456';
      _sifreController.text = '••••••••••••';
    });
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _biyometrikBasarili = false);
    _girisYap();
  }

  void _demoGirisSec(String isim, String plaka, String rol) {
    setState(() => _girisYukleniyor = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      widget.onGirisBasarili(isim, [plaka], rol);
    });
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _demoSecimSheetGoster() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.turkceMi ? 'Hızlı Test Profili Seçin' : 'Select Quick Demo Profile',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _demoSecimTile(
                  icon: Icons.badge_outlined,
                  ad: 'Ahmet Demir (KKTC Vatandaşı)',
                  plaka: 'KY 987',
                  rol: 'KKTC Vatandaşı',
                  onTap: () {
                    Navigator.pop(ctx);
                    _demoGirisSec('Ahmet Demir', 'KY 987', 'KKTC Vatandaşı');
                  },
                ),
                _demoSecimTile(
                  icon: Icons.credit_card_rounded,
                  ad: 'Mehmet Yılmaz (T.C. İkamet)',
                  plaka: 'RZ 123',
                  rol: 'T.C. İkamet / Görevli',
                  onTap: () {
                    Navigator.pop(ctx);
                    _demoGirisSec('Mehmet Yılmaz', 'RZ 123', 'T.C. Vatandaşı');
                  },
                ),
                _demoSecimTile(
                  icon: Icons.school_rounded,
                  ad: 'Caner Yıldız (ODTÜ Öğrencisi)',
                  plaka: 'ST 999',
                  rol: 'ODTÜ KKK Öğrenci',
                  onTap: () {
                    Navigator.pop(ctx);
                    _demoGirisSec('Caner Yıldız (ODTÜ)', 'ST 999', 'ODTÜ Öğrenci');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _demoSecimTile({
    required IconData icon,
    required String ad,
    required String plaka,
    required String rol,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.20),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF10B981), size: 20),
        ),
        title: Text(ad, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        subtitle: Text('Plaka: $plaka • $rol', style: const TextStyle(color: Colors.white54, fontSize: 11)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 14),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          // ── Ambient Glassmorphism Orbs ──
          Positioned(
            top: -60,
            left: -50,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00C853).withValues(alpha: 0.14),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.40,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0284C7).withValues(alpha: 0.16),
              ),
            ),
          ),

          // ── Ana İçerik ──
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Üst Çubuk (Kamu Ağı Rozeti + Dil Değiştirici)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF172033),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FadeTransition(
                                  opacity: _pingController,
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.turkceMi ? 'Resmi e-Trafik Portalı' : 'Official Portal',
                                  style: const TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // TR / EN Toggle
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF172033),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              children: [
                                _langButton('TR', widget.turkceMi, () => widget.onDilDegistir(true)),
                                _langButton('EN', !widget.turkceMi, () => widget.onDilDegistir(false)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 🛡️ Resmi 3D KKTC Logosu
                      Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00C853).withValues(alpha: 0.25),
                              blurRadius: 28,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.50),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.asset(
                            'assets/app_logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: const Color(0xFF1E293B),
                              child: const Icon(Icons.shield_rounded, color: Color(0xFF10B981), size: 40),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      Text(
                        widget.turkceMi ? 'KKTC e-Trafik' : 'TRNC e-Traffic',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.turkceMi
                            ? 'Polis Genel Müdürlüğü • Akıllı Sürüş ve Ceza Sistemi'
                            : 'Police HQ • Smart Traffic & Enforcement System',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.60),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ==========================================
                      // 🌟 APPLE SEGMENTED CONTROL: [ Giriş Yap | Kayıt Ol ]
                      // ==========================================
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161F33),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _seciliSegment = 0),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _seciliSegment == 0 ? const Color(0xFF243248) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: _seciliSegment == 0
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.35),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      widget.turkceMi ? 'Giriş Yap' : 'Sign In',
                                      style: TextStyle(
                                        color: _seciliSegment == 0 ? Colors.white : Colors.white60,
                                        fontSize: 13,
                                        fontWeight: _seciliSegment == 0 ? FontWeight.w800 : FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _seciliSegment = 1),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _seciliSegment == 1 ? const Color(0xFF243248) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: _seciliSegment == 1
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.35),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      widget.turkceMi ? 'Kayıt Ol' : 'Sign Up',
                                      style: TextStyle(
                                        color: _seciliSegment == 1 ? Colors.white : Colors.white60,
                                        fontSize: 13,
                                        fontWeight: _seciliSegment == 1 ? FontWeight.w800 : FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // ==========================================
                      // 📄 FORM GÖVDESİ (Giriş Yap vs Kayıt Ol)
                      // ==========================================
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _seciliSegment == 0 ? _buildGirisFormu() : _buildKayitFormu(),
                      ),

                      const SizedBox(height: 18),

                      // Gizli Demo Butonu & Yardım
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            onPressed: _demoSecimSheetGoster,
                            icon: const Icon(Icons.flash_on_rounded, color: Color(0xFF10B981), size: 14),
                            label: Text(
                              widget.turkceMi ? 'Hızlı Demo Girişi' : 'Quick Demo',
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.25)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Trafik Acil: 155',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
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
        ],
      ),
    );
  }

  // ── Giriş Formu ──
  Widget _buildGirisFormu() {
    return Container(
      key: const ValueKey('form_giris'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _inputLabel(widget.turkceMi ? 'E-POSTA, KİMLİK VEYA TELEFON' : 'EMAIL, ID OR PHONE'),
          const SizedBox(height: 6),
          _appleInputField(
            controller: _girisController,
            hint: widget.turkceMi ? 'Örn: 123456 veya Telefon' : 'E.g.: 123456 or Phone',
            prefixIcon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 14),

          _inputLabel(widget.turkceMi ? 'ŞİFRE' : 'PASSWORD'),
          const SizedBox(height: 6),
          _appleInputField(
            controller: _sifreController,
            hint: '••••••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            obscure: _sifreGizli,
            suffixIcon: IconButton(
              icon: Icon(
                _sifreGizli ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.white54,
                size: 20,
              ),
              onPressed: () => setState(() => _sifreGizli = !_sifreGizli),
            ),
          ),
          const SizedBox(height: 18),

          // Giriş Yap Butonu
          _actionButton(
            label: widget.turkceMi ? 'Giriş Yap' : 'Sign In',
            isLoading: _girisYukleniyor,
            isSuccess: _girisBasariliAnimasyon,
            onTap: _girisYap,
          ),
          const SizedBox(height: 10),

          // Face ID Butonu
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFF1A243B).withValues(alpha: 0.60),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _biyometrikYukleniyor ? null : _biyometrikGiris,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_biyometrikYukleniyor)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981)),
                    )
                  else
                    Icon(
                      _biyometrikBasarili ? Icons.check_circle : Icons.face,
                      color: _biyometrikBasarili ? const Color(0xFF10B981) : Colors.white70,
                      size: 22,
                    ),
                  const SizedBox(width: 8),
                  Text(
                    _biyometrikYukleniyor
                        ? (widget.turkceMi ? 'Kimlik Doğrulanıyor...' : 'Verifying...')
                        : (widget.turkceMi ? 'Face ID ile Giriş' : 'Sign in with Face ID'),
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Kayıt Ol Formu ──
  Widget _buildKayitFormu() {
    // Kullanıcı tipi tanımları
    final List<Map<String, dynamic>> kullaniciTipleri = [
      {
        'ikon': Icons.flag_rounded,
        'renk': const Color(0xFF10B981),
        'etiket': widget.turkceMi ? 'KKTC Vatandaşı' : 'TRNC Citizen',
        'aciklama': widget.turkceMi ? 'KKTC kimlik belgesi' : 'TRNC ID card',
      },
      {
        'ikon': Icons.credit_card_rounded,
        'renk': const Color(0xFF38BDF8),
        'etiket': widget.turkceMi ? 'T.C. Vatandaşı' : 'TR Citizen',
        'aciklama': widget.turkceMi ? 'T.C. kimlik / pasaport' : 'TR ID / passport',
      },
      {
        'ikon': Icons.school_rounded,
        'renk': const Color(0xFFA78BFA),
        'etiket': widget.turkceMi ? 'Üniversite Öğrencisi' : 'University Student',
        'aciklama': widget.turkceMi ? 'KKTC üniv. öğrenci kimliği' : 'TRNC student card',
      },
      {
        'ikon': Icons.public_rounded,
        'renk': const Color(0xFFF59E0B),
        'etiket': widget.turkceMi ? 'Uluslararası / Turist' : 'International / Tourist',
        'aciklama': widget.turkceMi ? 'Pasaport veya sürücü belgesi' : 'Passport or foreign license',
      },
    ];

    return Container(
      key: const ValueKey('form_kayit'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── KULLANICI TİPİ SEÇİCİ ──
          _inputLabel(widget.turkceMi ? 'HESAP TÜRÜNÜZÜ SEÇİN' : 'SELECT YOUR ACCOUNT TYPE'),
          const SizedBox(height: 8),
          Row(
            children: List.generate(kullaniciTipleri.length, (i) {
              final tip = kullaniciTipleri[i];
              final secili = _secilenKullaniciTipi == i;
              final renk = tip['renk'] as Color;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _secilenKullaniciTipi = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: secili ? renk.withValues(alpha: 0.18) : const Color(0xFF0F172A).withValues(alpha: 0.60),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: secili ? renk : Colors.white.withValues(alpha: 0.08),
                        width: secili ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tip['ikon'] as IconData,
                          color: secili ? renk : Colors.white38,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            tip['etiket'] as String,
                            style: TextStyle(
                              color: secili ? renk : Colors.white38,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),

          // Seçilen tip açıklaması
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: (kullaniciTipleri[_secilenKullaniciTipi]['renk'] as Color).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  kullaniciTipleri[_secilenKullaniciTipi]['ikon'] as IconData,
                  color: kullaniciTipleri[_secilenKullaniciTipi]['renk'] as Color,
                  size: 13,
                ),
                const SizedBox(width: 6),
                Text(
                  kullaniciTipleri[_secilenKullaniciTipi]['aciklama'] as String,
                  style: TextStyle(
                    color: (kullaniciTipleri[_secilenKullaniciTipi]['renk'] as Color),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── ÜNİVERSİTE SEÇİCİ: Sadece Öğrenci seçilince görünür ──
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            child: _secilenKullaniciTipi == 2
                ? _buildUniSecici()
                : const SizedBox.shrink(),
          ),

          _inputLabel(widget.turkceMi ? 'AD SOYAD' : 'FULL NAME'),
          const SizedBox(height: 6),
          _appleInputField(
            controller: _kayitAdSoyadController,
            hint: widget.turkceMi ? 'Örn: Ahmet Demir' : 'E.g.: John Doe',
            prefixIcon: Icons.badge_outlined,
          ),
          const SizedBox(height: 12),

          // Kimlik label türe göre değişiyor
          _inputLabel(
            _secilenKullaniciTipi == 0
                ? (widget.turkceMi ? 'KKTC KİMLİK NUMARASI' : 'TRNC ID NUMBER')
                : _secilenKullaniciTipi == 1
                    ? (widget.turkceMi ? 'T.C. KİMLİK NUMARASI (11 hane)' : 'TR ID NUMBER (11 digits)')
                    : _secilenKullaniciTipi == 2
                        ? (widget.turkceMi ? 'ÖĞRENCİ NUMARASI' : 'STUDENT ID')
                        : (widget.turkceMi ? 'PASAPORT NUMARASI' : 'PASSPORT NUMBER'),
          ),
          const SizedBox(height: 6),
          _appleInputField(
            controller: _kayitKimlikController,
            hint: _secilenKullaniciTipi == 0
                ? 'Örn: 123456'
                : _secilenKullaniciTipi == 1
                    ? 'Örn: 12345678901'
                    : _secilenKullaniciTipi == 2
                        ? 'Örn: 2023120001'
                        : 'Örn: A1234567',
            prefixIcon: _secilenKullaniciTipi == 3
                ? Icons.airplane_ticket_rounded
                : Icons.credit_card_rounded,
          ),
          const SizedBox(height: 12),

          _inputLabel(widget.turkceMi ? 'TELEFON NUMARASI' : 'PHONE NUMBER'),
          const SizedBox(height: 6),
          _appleInputField(
            controller: _kayitTelefonController,
            hint: '0533 800 00 00',
            prefixIcon: Icons.phone_android_rounded,
          ),
          const SizedBox(height: 12),

          _inputLabel(widget.turkceMi ? 'ARAÇ PLAKANIZ (İSTEĞE BAĞLI)' : 'VEHICLE LICENSE PLATE (OPTIONAL)'),
          const SizedBox(height: 6),
          _appleInputField(
            controller: _kayitPlakaController,
            hint: _secilenKullaniciTipi == 3 ? 'Örn: YU 123 (Yabancı plaka)' : 'Örn: KY 987',
            prefixIcon: Icons.directions_car_rounded,
          ),
          const SizedBox(height: 12),

          _inputLabel(widget.turkceMi ? 'ŞİFRE BELİRLEYİN' : 'CREATE PASSWORD'),
          const SizedBox(height: 6),
          _appleInputField(
            controller: _kayitSifreController,
            hint: '••••••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            obscure: _kayitSifreGizli,
            suffixIcon: IconButton(
              icon: Icon(
                _kayitSifreGizli ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.white54,
                size: 20,
              ),
              onPressed: () => setState(() => _kayitSifreGizli = !_kayitSifreGizli),
            ),
          ),
          const SizedBox(height: 18),

          // Kayıt Ol Butonu
          _actionButton(
            label: widget.turkceMi ? 'Hesap Oluştur ve Başla' : 'Create Account & Start',
            isLoading: _girisYukleniyor,
            isSuccess: _girisBasariliAnimasyon,
            onTap: _kayitOl,
          ),
        ],
      ),
    );
  }

  // ── Yardımcı Bileşenler ──
  Widget _inputLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.65),
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _appleInputField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13),
          prefixIcon: Icon(prefixIcon, color: const Color(0xFF10B981), size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required bool isLoading,
    required bool isSuccess,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00C853), Color(0xFF10B981)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00C853).withValues(alpha: 0.40),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: isLoading ? null : onTap,
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(isSuccess ? Icons.check_circle_rounded : Icons.arrow_forward_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _langButton(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF243248) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // ── ÜNİVERSİTE SEÇİCİ WIDGET ──
  Widget _buildUniSecici() {
    final List<Map<String, dynamic>> uniler = [
      {
        'kisaAd': 'ODTÜ KKK',
        'tamAd': 'Orta Doğu Teknik Üni. KKK',
        'renk': const Color(0xFF10B981),
        'ikon': Icons.science_rounded,
      },
      {
        'kisaAd': 'YDÜ',
        'tamAd': 'Yakın Doğu Üniversitesi',
        'renk': const Color(0xFF38BDF8),
        'ikon': Icons.account_balance_rounded,
      },
      {
        'kisaAd': 'DAÜ',
        'tamAd': 'Doğu Akdeniz Üni. (EMU)',
        'renk': const Color(0xFFF59E0B),
        'ikon': Icons.school_rounded,
      },
      {
        'kisaAd': 'GAÜ',
        'tamAd': 'Girne Amerikan Üniversitesi',
        'renk': const Color(0xFFA78BFA),
        'ikon': Icons.castle_rounded,
      },
      {
        'kisaAd': 'UKÜ',
        'tamAd': 'Uluslararası Kıbrıs Üni.',
        'renk': const Color(0xFFE11D48),
        'ikon': Icons.public_rounded,
      },
      {
        'kisaAd': 'LAÜ',
        'tamAd': 'Lefke Avrupa Üniversitesi',
        'renk': const Color(0xFF06B6D4),
        'ikon': Icons.local_library_rounded,
      },
      {
        'kisaAd': 'Beykent KKK',
        'tamAd': 'Beykent Üni. KKTC Kampüsü',
        'renk': const Color(0xFFFF6B35),
        'ikon': Icons.emoji_objects_rounded,
      },
      {
        'kisaAd': 'Diğer',
        'tamAd': 'Diğer KKTC Üniversitesi',
        'renk': const Color(0xFF64748B),
        'ikon': Icons.more_horiz_rounded,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _inputLabel(widget.turkceMi ? 'ÜNİVERSİTENİZİ SEÇİN' : 'SELECT YOUR UNIVERSITY'),
        const SizedBox(height: 8),
        // Yatay kaydırmalı chip listesi
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(uniler.length, (i) {
              final uni = uniler[i];
              final secili = _secilenUni == i;
              final renk = uni['renk'] as Color;
              return GestureDetector(
                onTap: () => setState(() => _secilenUni = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: EdgeInsets.only(right: i < uniler.length - 1 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: secili ? renk.withValues(alpha: 0.20) : const Color(0xFF0F172A).withValues(alpha: 0.60),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: secili ? renk : Colors.white.withValues(alpha: 0.08),
                      width: secili ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        uni['ikon'] as IconData,
                        color: secili ? renk : Colors.white30,
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        uni['kisaAd'] as String,
                        style: TextStyle(
                          color: secili ? renk : Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        // Seçilen üniversite tam adı
        if (_secilenUni >= 0 && _secilenUni < uniler.length)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: (uniler[_secilenUni]['renk'] as Color).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    uniler[_secilenUni]['ikon'] as IconData,
                    color: uniler[_secilenUni]['renk'] as Color,
                    size: 12,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    uniler[_secilenUni]['tamAd'] as String,
                    style: TextStyle(
                      color: uniler[_secilenUni]['renk'] as Color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 14),
      ],
    );
  }
}


// ==========================================
// 🏠 2. MODERN ANA SAYFA & TABS
// ==========================================
class AnaSayfaTabs extends StatefulWidget {
  final String kullaniciAdi;
  final String kullaniciRolu;
  final List<String> araclar;
  final bool turkceMi;
  final Function(bool) onDilDegistir;
  final VoidCallback onCikisYap;

  const AnaSayfaTabs({
    super.key,
    required this.kullaniciAdi,
    this.kullaniciRolu = "",
    required this.araclar,
    required this.turkceMi,
    required this.onDilDegistir,
    required this.onCikisYap,
  });

  @override
  State<AnaSayfaTabs> createState() => _AnaSayfaTabsState();
}

class _AnaSayfaTabsState extends State<AnaSayfaTabs>
    with TickerProviderStateMixin {
  int _seciliIndex = 0;
  String _secilenPlaka = "";
  String _cezaFiltre = "hepsi"; // hepsi, odenmedi, odendi
  bool _cezaOdeniyor = false;
  String _sigortaSekmesi = "wallet"; // 'wallet' or 'police'
  bool _sigortaQrBuyuk = false;
  String _sigortaOtpKodu = "KKTC-TRF-9921-OK";
  String _cezaSigortaAltSekme = "ceza"; // 'ceza' or 'sigorta'
  bool _gizliAdminModuAcik = false;
  int _gizliTikSayisi = 0;
  bool _tamEkranNavigasyon = false;

  bool get _adminYetkisiVarMi {
    final r = widget.kullaniciRolu.toLowerCase();
    return r.contains('admin') ||
           r.contains('yönetici') ||
           r.contains('polis') ||
           r.contains('bilgi işlem') ||
           r.contains('pgm') ||
           r.contains('soc') ||
           _gizliAdminModuAcik;
  }

  void _adminPinDiyaloguAc() {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF10B981)),
              const SizedBox(width: 8),
              Text(
                widget.turkceMi ? 'Yönetici / SOC Girişi' : 'Admin / SOC Access',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.turkceMi
                    ? 'Siber Güvenlik Duvarı & Olay Günlüğünü açmak için 4 haneli yönetici PIN kodunu giriniz:'
                    : 'Enter 4-digit admin PIN to access Cyber Firewall & SOC Logs:',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 8),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '••••',
                  hintStyle: const TextStyle(color: Colors.white24),
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(widget.turkceMi ? 'İptal' : 'Cancel', style: const TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              onPressed: () {
                if (pinController.text == "1907" || pinController.text == "1974" || pinController.text == "9999") {
                  Navigator.pop(ctx);
                  setState(() => _gizliAdminModuAcik = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.verified_user_rounded, color: Color(0xFF10B981)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.turkceMi
                                  ? '✅ Yönetici & Siber Güvenlik Merkezi (SOC) yetkisi aktif!'
                                  : '✅ Admin & Cyber Security SOC access unlocked!',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: const Color(0xFF0F172A),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  GuvenlikDuvari.guvenlikPaneliGoster(context, widget.turkceMi);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(widget.turkceMi ? '❌ Hatalı Yönetici PIN Kodu!' : '❌ Incorrect Admin PIN!'),
                      backgroundColor: const Color(0xFFEF4444),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Text(widget.turkceMi ? 'Doğrula' : 'Verify', style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  late final AnimationController _pingController;

  @override
  void initState() {
    super.initState();
    _pingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    if (widget.araclar.isNotEmpty) {
      _secilenPlaka = widget.araclar.first;
    }
    // 🚀 Uygulama Açılışında Sessizce Güncelleme Kontrolü
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          GuncellemeServisi.otomatikKontrolEt(context, widget.turkceMi);
        }
      });
    });
  }

  @override
  void dispose() {
    _pingController.dispose();
    super.dispose();
  }

  // Canlı Bildirimler Listesi
  final List<Map<String, dynamic>> _bildirimler = [
    {
      "id": "b1",
      "baslik": "Yeni Radar Cezası Tebliği",
      "baslikEn": "New Speed Camera Ticket",
      "detay": "Kalkanlı - Güzelyurt Anayolu 65 km/s kamerasında hız aşımı tespit edildi (₺2.850 - 5 Ceza Puanı).",
      "detayEn": "Speed limit violation recorded on Kalkanli - Guzelyurt highway camera (₺2,850 - 5 Demerit Points).",
      "zaman": "Bugün 13:42",
      "zamanEn": "Today 13:42",
      "okundu": false,
      "hedef": "ceza",
      "ikon": Icons.receipt_long_rounded,
      "renk": const Color(0xFFD90429),
    },
    {
      "id": "b2",
      "baslik": "Seyrüsefer Yenileme Dönemi",
      "baslikEn": "Road Tax Renewal Period",
      "detay": "Aracınızın 2026/2. dönem seyrüsefer harcının son 60 günü kaldı. Online ödeme ile gecikme cezasından korunun.",
      "detayEn": "60 days remaining for 2026/2 vehicle road tax period. Pay online to avoid late penalties.",
      "zaman": "Dün 10:15",
      "zamanEn": "Yesterday 10:15",
      "okundu": false,
      "hedef": "seyrusefer",
      "ikon": Icons.directions_car_filled_rounded,
      "renk": const Color(0xFF38BDF8),
    },
    {
      "id": "b3",
      "baslik": "Zorunlu Trafik Sigortası Aktif",
      "baslikEn": "Traffic Insurance Active",
      "detay": "Kıbrıs Sigorta Kooperatifi poliçeniz Apple Wallet kartınıza başarıyla senkronize edildi.",
      "detayEn": "Your Cyprus Insurance Cooperative policy is synced with your Apple Wallet card.",
      "zaman": "3 gün önce",
      "zamanEn": "3 days ago",
      "okundu": true,
      "hedef": "sigorta_wallet",
      "ikon": Icons.shield_outlined,
      "renk": const Color(0xFF4EDEA3),
    },
  ];

  int get _okunmamisBildirimSayisi => _bildirimler.where((b) => b['okundu'] == false).length;

  final Map<String, Map<String, dynamic>> _aracBilgileriVeritabani = {
    "RZ 123": {
      "markaModel": "BMW 3.20i (2022)",
      "sigortaKalanGun": 45,
      "muayeneKalanGun": 120,
      "ehliyetPuani": 85,
      "sigortaAktif": true,
      "seyruseferKalanGun": 86,
      "seyruseferBitisTarihi": "26 Aralık 2026",
      "seyruseferHarc": "₺3.450,00",
      "seyruseferHarcMiktar": 3450,
      "seyruseferDonem": "2026/2. Dönem",
      "sasiNo": "TRNC-BM-2022-8192",
      "motorHacmi": "1998 cc / Benzin",
      "cezalar": [
        {
          "id": "1",
          "tarih": "15.05.2026",
          "tur": "Hız Sınırı Aşımı (Radar)",
          "turEn": "Speed Limit Violation (Radar)",
          "kategori": "Hız",
          "tutar": "2450 TL",
          "odendi": false,
          "konum": "Lefkoşa - Güzelyurt Anayolu",
          "puan": "10 Ceza Puanı",
          "polis": "Trafik Ekipleri",
          "kanit": "https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=800"
        },
      ]
    },
    "LZ 555": {
      "markaModel": "Mercedes-Benz C200 (2023)",
      "sigortaKalanGun": 180,
      "muayeneKalanGun": 200,
      "ehliyetPuani": 95,
      "sigortaAktif": true,
      "seyruseferKalanGun": 142,
      "seyruseferBitisTarihi": "20 Şubat 2027",
      "seyruseferHarc": "₺3.850,00",
      "seyruseferHarcMiktar": 3850,
      "seyruseferDonem": "2026/2. Dönem",
      "sasiNo": "TRNC-MB-2023-4412",
      "motorHacmi": "1496 cc / Hibrit",
      "cezalar": []
    },
    "ST 999": {
      "markaModel": "Volkswagen Polo (2021)",
      "sigortaKalanGun": 4,
      "muayeneKalanGun": 5,
      "ehliyetPuani": 70,
      "sigortaAktif": false,
      "seyruseferKalanGun": 12,
      "seyruseferBitisTarihi": "13 Ekim 2026",
      "seyruseferHarc": "₺2.650,00",
      "seyruseferHarcMiktar": 2650,
      "seyruseferDonem": "2026/1. Dönem",
      "sasiNo": "TRNC-VW-2021-9014",
      "motorHacmi": "999 cc / Benzin",
      "cezalar": [
        {
          "id": "2",
          "tarih": "20.04.2026",
          "tur": "Muayenesiz Araç Kullanımı",
          "turEn": "Driving Uninspected Vehicle",
          "kategori": "Evrak",
          "tutar": "1850 TL",
          "odendi": false,
          "konum": "Güzelyurt Kalkanlı Yolu",
          "puan": "5 Ceza Puanı",
          "polis": "Trafik Denetleme Ekipleri",
          "kanit": "https://images.unsplash.com/photo-1486006920555-c77dce18193b?w=800"
        }
      ]
    },
    "GM 202": {
      "markaModel": "Toyota Corolla (2020)",
      "sigortaKalanGun": 90,
      "muayeneKalanGun": 60,
      "ehliyetPuani": 80,
      "sigortaAktif": true,
      "seyruseferKalanGun": 215,
      "seyruseferBitisTarihi": "04 Mayıs 2027",
      "seyruseferHarc": "₺3.100,00",
      "seyruseferHarcMiktar": 3100,
      "seyruseferDonem": "2026/2. Dönem",
      "sasiNo": "TRNC-TY-2020-5620",
      "motorHacmi": "1598 cc / Benzin",
      "cezalar": []
    },
    "KT 1974": {
      "markaModel": "Ford Ranger 4x4 (KTBK Garnizon/Şahsi)",
      "sigortaKalanGun": 285,
      "muayeneKalanGun": 320,
      "ehliyetPuani": 100,
      "sigortaAktif": true,
      "seyruseferKalanGun": 298,
      "seyruseferBitisTarihi": "26 Temmuz 2027",
      "seyruseferHarc": "₺0,00 (Askeri Protokol)",
      "seyruseferHarcMiktar": 0,
      "seyruseferDonem": "2026/KTBK-GKK Özel",
      "sasiNo": "KTBK-FR-2023-7712",
      "motorHacmi": "1996 cc / Dizel",
      "cezalar": []
    },
    "ODTU 107": {
      "markaModel": "Honda Civic VTEC (ODTÜ Kampüs Pulu)",
      "sigortaKalanGun": 60,
      "muayeneKalanGun": 140,
      "ehliyetPuani": 90,
      "sigortaAktif": true,
      "seyruseferKalanGun": 45,
      "seyruseferBitisTarihi": "15 Kasım 2026",
      "seyruseferHarc": "₺2.450,00",
      "seyruseferHarcMiktar": 2450,
      "seyruseferDonem": "2026/2. Dönem",
      "sasiNo": "TRNC-HC-2022-3310",
      "motorHacmi": "1498 cc / Benzin",
      "cezalar": []
    },
    "KY 440": {
      "markaModel": "Renault Megane Sedan (T.C. İkamet/YKN)",
      "sigortaKalanGun": 110,
      "muayeneKalanGun": 95,
      "ehliyetPuani": 95,
      "sigortaAktif": true,
      "seyruseferKalanGun": 120,
      "seyruseferBitisTarihi": "29 Ocak 2027",
      "seyruseferHarc": "₺3.200,00",
      "seyruseferHarcMiktar": 3200,
      "seyruseferDonem": "2026/2. Dönem",
      "sasiNo": "TRNC-RN-2021-9921",
      "motorHacmi": "1332 cc / Benzin",
      "cezalar": []
    },
  };

  final List<Map<String, String>> _dekontlar = [
    {
      "islem": "Yanlış Park Cezası Ödemesi",
      "islemEn": "Illegal Parking Fine Payment",
      "tarih": "10.02.2026",
      "tutar": "1200 TL",
      "kod": "DEKONT-99821",
      "kurum": "KKTC Maliye Bakanlığı Veznesi",
      "durum": "Onaylandı / Başarılı"
    },
  ];

  void _sigortaYenile(String plaka) {
    setState(() {
      if (_aracBilgileriVeritabani.containsKey(plaka)) {
        _aracBilgileriVeritabani[plaka]!['sigortaKalanGun'] = 365;
        _aracBilgileriVeritabani[plaka]!['sigortaAktif'] = true;
      }
      _dekontlar.insert(0, {
        "islem": "$plaka Nolu Araç Zorunlu Sigorta Yenileme",
        "islemEn": "$plaka Vehicle Mandatory Insurance Renewal",
        "tarih": "Bugün / Today",
        "tutar": "4500 TL",
        "kod": "SIGORTA-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
        "kurum": "KKTC Sigortalar Birliği Havuzu",
        "durum": "Onaylandı / Poliçe Aktif"
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.verified, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.turkceMi
                    ? 'Poliçe 365 gün olarak başarıyla yenilendi!'
                    : 'Insurance successfully renewed for 365 days!',
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _cezaOdemeGuncelle(String plaka, String cezaId, String cezaAdi, String cezaAdiEn, String tutar) {
    setState(() {
      if (_aracBilgileriVeritabani.containsKey(plaka)) {
        List cezalar = _aracBilgileriVeritabani[plaka]!['cezalar'];
        for (var ceza in cezalar) {
          if (ceza['id'] == cezaId) {
            ceza['odendi'] = true;
          }
        }
      }
      _dekontlar.insert(0, {
        "islem": cezaAdi,
        "islemEn": cezaAdiEn,
        "tarih": "Bugün / Today",
        "tutar": tutar,
        "kod": "DEKONT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
        "kurum": "KKTC Polis Genel Müdürlüğü Maliyesi",
        "durum": "Ödendi / Arşivlendi"
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var aracVerisi = _aracBilgileriVeritabani[_secilenPlaka] ?? {};
    String markaModel = aracVerisi['markaModel'] ?? '';
    List cezalar = aracVerisi['cezalar'] ?? [];
    int sigortaGun = aracVerisi['sigortaKalanGun'] ?? 0;
    int muayeneGun = aracVerisi['muayeneKalanGun'] ?? 0;
    int ehliyetPuani = aracVerisi['ehliyetPuani'] ?? 100;

    int odenmemisCezaSayisi = cezalar.where((c) => c['odendi'] == false).length;
    int toplamBorc = cezalar
        .where((c) => c['odendi'] == false)
        .fold(0, (sum, c) => sum + (int.tryParse(c['tutar'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0));

    final List<Widget> sayfalar = [
      _radarSurusEkrani(
        odenmemisCezaSayisi: odenmemisCezaSayisi,
        toplamBorc: toplamBorc,
        sigortaGun: sigortaGun,
      ),
      YolTarifiSayfasi(
        turkceMi: widget.turkceMi,
        onTamEkranDegisti: (tamEkran) {
          setState(() {
            _tamEkranNavigasyon = tamEkran;
            // Navigasyon başladığında otomatik olarak Yol Tarifi sekmesine geç
            if (tamEkran) _seciliIndex = 1;
          });
        },
      ),
      _cezaVeSigortaEkrani(
        markaModel: markaModel,
        cezalar: cezalar,
        sigortaGun: sigortaGun,
        muayeneGun: muayeneGun,
        ehliyetPuani: ehliyetPuani,
      ),
      _kullaniciProfiliEkrani(
        ehliyetPuani: ehliyetPuani,
        markaModel: markaModel,
      ),
    ];

    return Scaffold(
      backgroundColor: _HtmlColors.background,
      appBar: _tamEkranNavigasyon ? null : PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: _HtmlColors.background.withValues(alpha: 0.90),
            border: Border(
              bottom: BorderSide(color: _HtmlColors.surfaceContainerHigh.withValues(alpha: 0.6), width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.30),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  // KKTC e-Trafik brand logo & pulse (Responsive Expanded)
                  Expanded(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _gizliTikSayisi++;
                            if (_gizliTikSayisi >= 5) {
                              _gizliTikSayisi = 0;
                              _adminPinDiyaloguAc();
                            }
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _HtmlColors.primaryContainer.withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.local_police_rounded,
                              color: _HtmlColors.primaryContainer,
                              size: 21,
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
                                children: [
                                  const Text(
                                    'KKTC',
                                    style: TextStyle(
                                      color: _HtmlColors.primaryFixedDim,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  FadeTransition(
                                    opacity: _pingController,
                                    child: Container(
                                      width: 5,
                                      height: 5,
                                      decoration: const BoxDecoration(
                                        color: _HtmlColors.tertiary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _seciliIndex == 0 ? 'e-Trafik' : _baslikDondur(_seciliIndex),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: _HtmlColors.onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Actions: Language + Notifications + Help + Profile Avatar
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Language button
                      PopupMenuButton<bool>(
                        tooltip: widget.turkceMi ? 'Dil Değiştir' : 'Change Language',
                        onSelected: (bool yeniTurkceMi) => widget.onDilDegistir(yeniTurkceMi),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        color: _HtmlColors.surfaceContainerHigh,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
                          decoration: BoxDecoration(
                            color: _HtmlColors.surfaceContainerHigh.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.turkceMi ? 'TR' : 'EN',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: _HtmlColors.secondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        itemBuilder: (context) => [
                          const PopupMenuItem<bool>(
                            value: true,
                            child: Text('🇹🇷 Türkçe', style: TextStyle(color: _HtmlColors.onSurface)),
                          ),
                          const PopupMenuItem<bool>(
                            value: false,
                            child: Text('🇬🇧 English', style: TextStyle(color: _HtmlColors.onSurface)),
                          ),
                        ],
                      ),
                      const SizedBox(width: 6),

                      // Notification bell with unread dot
                      GestureDetector(
                        onTap: () => _bildirimlerModaliniAc(ehliyetPuani: ehliyetPuani),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: _HtmlColors.surfaceContainerHigh.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(Icons.notifications_none_rounded, color: _HtmlColors.onSurface, size: 19),
                              if (_okunmamisBildirimSayisi > 0)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: _HtmlColors.primaryContainer,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: _HtmlColors.background, width: 1.2),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Help & Smart Route Assistant
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => YardimRehberiSayfasi(
                                turkceMi: widget.turkceMi,
                                onRotayiAc: (baslangicId, varisId) {
                                  Navigator.pop(context);
                                  setState(() => _seciliIndex = 1);
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: _HtmlColors.tertiary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _HtmlColors.tertiary.withValues(alpha: 0.35)),
                          ),
                          child: const Icon(Icons.help_outline_rounded, color: _HtmlColors.tertiary, size: 18),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // OTA Güncelleme Kontrolü (Kablosuz Sürüm Denetleme)
                      GestureDetector(
                        onTap: () => GuncellemeServisi.manuelKontrolEt(context, widget.turkceMi),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.35)),
                          ),
                          child: const Icon(Icons.cloud_sync_rounded, color: Color(0xFF38BDF8), size: 18),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // 🛡️ Siber Güvenlik Duvarı (WAF) Durum Paneli (SADECE ADMİN VE YÖNETİCİLER GÖRÜR)
                      if (_adminYetkisiVarMi) ...[
                        GestureDetector(
                          onTap: () => GuvenlikDuvari.guvenlikPaneliGoster(context, widget.turkceMi),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35)),
                            ),
                            child: const Icon(Icons.security_rounded, color: Color(0xFF10B981), size: 18),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],

                      // Avatar circle
                      GestureDetector(
                        onTap: () => setState(() => _seciliIndex = 3),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: _HtmlColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: _HtmlColors.onPrimary,
                            size: 20,
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
    ),
  ),
  body: _tamEkranNavigasyon
        ? sayfalar[_seciliIndex]
        : Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  KamuSunucuDurumSeridi(turkceMi: widget.turkceMi),
                  _hizliAramaCubugu(ehliyetPuani: ehliyetPuani),
                  Expanded(
                    child: sayfalar[_seciliIndex],
                  ),
                ],
              ),
            ),
          ),
      bottomNavigationBar: _tamEkranNavigasyon
          ? null
          : Container(
              decoration: BoxDecoration(
                color: _HtmlColors.surfaceContainerLowest.withValues(alpha: 0.95),
                border: Border(
                  top: BorderSide(color: _HtmlColors.surfaceContainerHigh.withValues(alpha: 0.4), width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 24,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 64,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _navItem(
                              0,
                              Icons.radar_rounded,
                              widget.turkceMi ? 'Radar & Sürüş' : 'Radar & Drive',
                            ),
                            _navItem(
                              1,
                              Icons.alt_route_rounded,
                              widget.turkceMi ? 'Yol Tarifi' : 'Route & Radar',
                            ),
                            _navItem(
                              2,
                              Icons.receipt_long_rounded,
                              widget.turkceMi ? 'Cezalar & Sigorta' : 'Fines & Insurance',
                              rozet: odenmemisCezaSayisi,
                            ),
                            _navItem(
                              3,
                              Icons.person_rounded,
                              widget.turkceMi ? 'Profil' : 'Profile',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _navItem(int index, IconData ikon, String etiket, {int rozet = 0}) {
    bool secili = _seciliIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _seciliIndex = index),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 56,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    ikon,
                    size: 22,
                    color: secili ? _HtmlColors.primaryContainer : _HtmlColors.secondary,
                  ),
                  if (rozet > 0)
                    Positioned(
                      top: -4,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: const BoxDecoration(
                          color: _HtmlColors.primaryContainer,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Text(
                          '$rozet',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    etiket,
                    style: TextStyle(
                      color: secili ? _HtmlColors.primaryContainer : _HtmlColors.secondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HIZLI ARAMA ÇUBUĞU (SPOTLIGHT SEARCH) ---
  Widget _hizliAramaCubugu({required int ehliyetPuani}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _hizliAramaPenceresiniAc(ehliyetPuani),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _HtmlColors.surfaceContainerHigh.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: Color(0xFF38BDF8), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.turkceMi
                        ? 'Seyrüsefer, ceza, radar veya hizmet ara...'
                        : 'Search road tax, fines, radar or services...',
                    style: TextStyle(
                      color: _HtmlColors.secondary.withValues(alpha: 0.75),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: _HtmlColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.touch_app_rounded, color: _HtmlColors.tertiary, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        widget.turkceMi ? 'Hızlı Git' : 'Quick Go',
                        style: const TextStyle(
                          color: _HtmlColors.tertiary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _hizliAramaPenceresiniAc(int ehliyetPuani) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HizliAramaModalSayfasi(
        turkceMi: widget.turkceMi,
        onHedefeGit: (hedefId) {
          Navigator.pop(context);
          _aramaHedefiniUygula(hedefId, ehliyetPuani);
        },
      ),
    );
  }

  // --- BİLDİRİMLER VE TEBLİGATLAR MERKEZİ ---
  void _bildirimlerModaliniAc({required int ehliyetPuani}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.78,
            decoration: const BoxDecoration(
              color: _HtmlColors.surfaceContainerLow,
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

                // Başlık Alanı
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _HtmlColors.primaryContainer.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.notifications_active_rounded, color: _HtmlColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.turkceMi ? 'Bildirimler & Tebligatlar' : 'Notifications & Notices',
                              style: const TextStyle(
                                color: _HtmlColors.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              widget.turkceMi
                                  ? '$_okunmamisBildirimSayisi okunmamış bildiriminiz var'
                                  : '$_okunmamisBildirimSayisi unread notifications',
                              style: TextStyle(
                                color: _HtmlColors.secondary.withValues(alpha: 0.8),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_okunmamisBildirimSayisi > 0)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              for (var b in _bildirimler) {
                                b['okundu'] = true;
                              }
                            });
                            setModalState(() {});
                          },
                          child: Text(
                            widget.turkceMi ? 'Tümünü Oku' : 'Mark All Read',
                            style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: _HtmlColors.secondary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Canlı Test & Simülasyon Butonu
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InkWell(
                    onTap: () {
                      final yeniId = "b_${DateTime.now().millisecondsSinceEpoch}";
                      final yeniBildirim = {
                        "id": yeniId,
                        "baslik": widget.turkceMi ? "⚡ Yeni Radar Cezası Bildirimi" : "⚡ New Radar Fine Alert",
                        "baslikEn": "⚡ New Radar Fine Alert",
                        "detay": widget.turkceMi
                            ? "Yeni radar cezası sisteme yansıdı! 15 gün içinde ödeyerek %15 indirimden faydalanın."
                            : "New speed ticket registered! Pay within 15 days to get 15% discount.",
                        "detayEn": "New speed ticket registered! Pay within 15 days to get 15% discount.",
                        "zaman": widget.turkceMi ? "Şimdi" : "Just now",
                        "zamanEn": "Just now",
                        "okundu": false,
                        "hedef": "ceza",
                        "ikon": Icons.receipt_long_rounded,
                        "renk": const Color(0xFFD90429),
                      };

                      setState(() {
                        _bildirimler.insert(0, yeniBildirim);
                      });
                      setModalState(() {});

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFFD90429),
                          content: Row(
                            children: [
                              const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.turkceMi
                                      ? "Mobil bildirim simüle edildi: Yeni ceza bildirimi eklendi!"
                                      : "Mobile notification simulated: New fine alert added!",
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _HtmlColors.primaryContainer.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _HtmlColors.primaryContainer.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.flash_on_rounded, color: _HtmlColors.primary, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.turkceMi
                                  ? 'Test Et: Yeni Ceza Bildirimi Düşür (Simülasyon)'
                                  : 'Test: Trigger New Fine Notification (Simulation)',
                              style: const TextStyle(
                                color: _HtmlColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: _HtmlColors.primary, size: 11),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Bildirim Listesi
                Expanded(
                  child: _bildirimler.isEmpty
                      ? Center(
                          child: Text(
                            widget.turkceMi ? 'Henüz bildiriminiz bulunmuyor.' : 'No notifications yet.',
                            style: const TextStyle(color: _HtmlColors.secondary),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                          physics: const BouncingScrollPhysics(),
                          itemCount: _bildirimler.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final b = _bildirimler[index];
                            final bool okundu = b['okundu'] == true;
                            final Color renk = b['renk'] as Color;

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    b['okundu'] = true;
                                  });
                                  Navigator.pop(context);
                                  _aramaHedefiniUygula(b['hedef'] as String, ehliyetPuani);
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: okundu
                                        ? _HtmlColors.surfaceContainerHigh.withValues(alpha: 0.45)
                                        : _HtmlColors.surfaceContainerHigh.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: okundu
                                          ? Colors.white.withValues(alpha: 0.04)
                                          : renk.withValues(alpha: 0.4),
                                      width: okundu ? 1 : 1.3,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: renk.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(b['ikon'] as IconData, color: renk, size: 20),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    widget.turkceMi ? b['baslik'] : b['baslikEn'],
                                                    style: TextStyle(
                                                      color: _HtmlColors.onSurface,
                                                      fontSize: 13,
                                                      fontWeight: okundu ? FontWeight.w600 : FontWeight.w800,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  widget.turkceMi ? b['zaman'] : b['zamanEn'],
                                                  style: TextStyle(
                                                    color: _HtmlColors.secondary.withValues(alpha: 0.6),
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              widget.turkceMi ? b['detay'] : b['detayEn'],
                                              style: TextStyle(
                                                color: _HtmlColors.secondary.withValues(alpha: 0.85),
                                                fontSize: 11,
                                                height: 1.3,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Text(
                                                  widget.turkceMi ? 'Görüntülemek için dokunun ➔' : 'Tap to view ➔',
                                                  style: TextStyle(
                                                    color: renk,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                if (!okundu) ...[
                                                  const Spacer(),
                                                  Container(
                                                    width: 7,
                                                    height: 7,
                                                    decoration: BoxDecoration(
                                                      color: renk,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _aramaHedefiniUygula(String hedefId, int ehliyetPuani) {
    switch (hedefId) {
      case 'seyrusefer':
        setState(() {
          _seciliIndex = 2;
          _cezaSigortaAltSekme = 'sigorta';
          _sigortaSekmesi = 'seyrusefer';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF0284C7),
            content: Row(
              children: [
                const Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.turkceMi
                        ? 'Seyrüsefer & Araç Muayenesi sekmesine gidildi.'
                        : 'Navigated to Road Tax & Vehicle Inspection.',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        break;

      case 'ceza':
        setState(() {
          _seciliIndex = 2;
          _cezaSigortaAltSekme = 'ceza';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: _HtmlColors.primaryContainer,
            content: Row(
              children: [
                const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.turkceMi
                        ? 'Trafik Cezalarım sekmesine gidildi.'
                        : 'Navigated to Traffic Fines.',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        break;

      case 'sigorta_wallet':
        setState(() {
          _seciliIndex = 2;
          _cezaSigortaAltSekme = 'sigorta';
          _sigortaSekmesi = 'wallet';
        });
        break;

      case 'police_qr':
        setState(() {
          _seciliIndex = 2;
          _cezaSigortaAltSekme = 'sigorta';
          _sigortaSekmesi = 'police';
        });
        break;

      case 'radar':
        setState(() => _seciliIndex = 0);
        break;

      case 'yol_tarifi':
        setState(() => _seciliIndex = 1);
        break;

      case 'yardim':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => YardimRehberiSayfasi(
              turkceMi: widget.turkceMi,
              onRotayiAc: (bId, vId) {
                Navigator.pop(context);
                setState(() => _seciliIndex = 1);
              },
            ),
          ),
        );
        break;

      case 'itiraz':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItirazSayfasi(turkceMi: widget.turkceMi),
          ),
        );
        break;

      case 'ehliyet':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BarkodluBelgeSayfasi(
              kullanici: widget.kullaniciAdi,
              puan: ehliyetPuani,
              turkceMi: widget.turkceMi,
            ),
          ),
        );
        break;

      case 'dekontlar':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DekontlarSayfasi(
              dekontlar: _dekontlar,
              turkceMi: widget.turkceMi,
            ),
          ),
        );
        break;

      case 'bildirimler':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BildirimAyarlariSayfasi(turkceMi: widget.turkceMi),
          ),
        );
        break;

      case 'cekici':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFFF43F5E),
            content: Row(
              children: [
                const Icon(Icons.car_repair_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.turkceMi
                        ? '7/24 KKTC Yol Yardım Hattı: 0392 228 88 88'
                        : '24/7 TRNC Roadside Assistance: 0392 228 88 88',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
        break;
    }
  }

  void _aracDegistirSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _HtmlColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.turkceMi ? 'Aktif Araç Seçimi' : 'Select Active Vehicle',
                  style: const TextStyle(
                    color: _HtmlColors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close, color: _HtmlColors.secondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...widget.araclar.map((p) {
              bool aktif = p == _secilenPlaka;
              String model = _aracBilgileriVeritabani[p]?['markaModel'] ?? p;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: aktif ? _HtmlColors.primaryContainer : _HtmlColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                  leading: Icon(
                    Icons.directions_car_rounded,
                    color: aktif ? _HtmlColors.onPrimaryContainer : _HtmlColors.secondary,
                  ),
                  title: Text(
                    p,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: aktif ? _HtmlColors.onPrimaryContainer : _HtmlColors.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    model,
                    style: TextStyle(
                      fontSize: 12,
                      color: aktif
                          ? _HtmlColors.onPrimaryContainer.withValues(alpha: 0.8)
                          : _HtmlColors.secondary,
                    ),
                  ),
                  trailing: aktif
                      ? const Icon(Icons.check_circle_rounded, color: Colors.white)
                      : null,
                  onTap: () {
                    setState(() => _secilenPlaka = p);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            );
          }),
          ],
        ),
      ),
    );
  }

  void _delilDosyasiGoster() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _HtmlColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_rounded, color: _HtmlColors.primary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      widget.turkceMi ? 'Sertifikalı MOBESE Kanıtı' : 'Certified MOBESE Evidence',
                      style: const TextStyle(
                        color: _HtmlColors.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close, color: _HtmlColors.secondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: double.infinity,
                height: 200,
                child: Image.network(
                  'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=800',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: _HtmlColors.surfaceContainerLowest,
                    child: const Center(
                      child: Icon(Icons.camera_alt_outlined, color: _HtmlColors.secondary, size: 48),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _HtmlColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.turkceMi ? 'Kamera Model:' : 'Camera Model:',
                        style: const TextStyle(color: _HtmlColors.secondary, fontSize: 12),
                      ),
                      const Text(
                        'Truvelo D-Cam Pro 4K',
                        style: TextStyle(color: _HtmlColors.onSurface, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.turkceMi ? 'Kalibrasyon Tarihi:' : 'Calibration Date:',
                        style: const TextStyle(color: _HtmlColors.secondary, fontSize: 12),
                      ),
                      Text(
                        widget.turkceMi ? '12.03.2024 (Geçerli)' : '12.03.2024 (Valid)',
                        style: const TextStyle(color: _HtmlColors.onSurface, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Dijital İmza (SHA-256):',
                        style: TextStyle(color: _HtmlColors.secondary, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _HtmlColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              'e3b0c44298fc1c149afbf4c8996fb92427ae41e4',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                color: _HtmlColors.tertiaryFixed,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _HtmlColors.surfaceBright,
                  foregroundColor: _HtmlColors.onSurface,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: _HtmlColors.surfaceContainerHigh,
                      content: Row(
                        children: [
                          const Icon(Icons.download_done_rounded, color: _HtmlColors.tertiary),
                          const SizedBox(width: 8),
                          Text(
                            widget.turkceMi
                                ? 'Resmi Delil Zaptı (PDF) cihazınıza indirildi.'
                                : 'Official Evidence Report (PDF) downloaded.',
                            style: const TextStyle(color: _HtmlColors.onSurface),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.download_rounded, size: 20),
                label: Text(
                  widget.turkceMi ? 'Resmi Delil Zaptını İndir (.PDF)' : 'Download Official Evidence (.PDF)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 2: CEZALARIM GÖRÜNÜMÜ (HTML MOCKUP UYUMLU) ---
  Widget _cezalarimGorunumu({required List cezalar}) {
    final odenmemisler = cezalar.where((c) => c['odendi'] == false).toList();
    final odenmisler = cezalar.where((c) => c['odendi'] == true).toList();

    int toplamSayi = cezalar.length;
    int odenmemisSayi = odenmemisler.length;
    int odenmisSayi = odenmisler.length;

    final List<Map<String, dynamic>> gecmisOdenenCezalar = [
      {
        "baslik": "Haspolat Çevre Yolu Radarı",
        "tarih": "24 Ocak 2024",
        "kod": "#KKTC-2024-110294",
        "tutar": "₺1.200,00",
        "dekontNo": "#891",
      },
    ];

    String seciliModel = _aracBilgileriVeritabani[_secilenPlaka]?['markaModel'] ?? 'BMW 3.20i M-Sport (2022)';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Active Vehicle Selector Pill & Quick Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _HtmlColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _HtmlColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.directions_car_rounded,
                          color: _HtmlColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _HtmlColors.surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _secilenPlaka.isNotEmpty ? _secilenPlaka : "RZ 123",
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      color: _HtmlColors.onSurface,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FadeTransition(
                                        opacity: _pingController,
                                        child: Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: _HtmlColors.tertiary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Flexible(
                                        child: Text(
                                          widget.turkceMi ? 'Aktif Kayıt' : 'Active Record',
                                          style: const TextStyle(
                                            color: _HtmlColors.tertiaryFixed,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              seciliModel,
                              style: const TextStyle(
                                color: _HtmlColors.secondary,
                                fontSize: 12,
                              ),
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
                GestureDetector(
                  onTap: _aracDegistirSheet,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _HtmlColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.swap_horiz_rounded,
                      color: _HtmlColors.secondary,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 2. Segmented Violation Filter Tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _HtmlColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _segmentedFilterButton(
                  deger: "hepsi",
                  baslik: widget.turkceMi ? 'Tümü' : 'All',
                  adet: toplamSayi,
                ),
                const SizedBox(width: 4),
                _segmentedFilterButton(
                  deger: "odenmedi",
                  baslik: widget.turkceMi ? 'Ödenmemiş' : 'Unpaid',
                  adet: odenmemisSayi,
                  hasDot: true,
                ),
                const SizedBox(width: 4),
                _segmentedFilterButton(
                  deger: "odendi",
                  baslik: widget.turkceMi ? 'Ödenmiş' : 'Paid',
                  adet: odenmisSayi,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. Main Active Violation Dossier Card
          if (_cezaFiltre != "odendi" && odenmemisler.isNotEmpty) ...[
            ...odenmemisler.map((ceza) => _aktifCezaDosyaKarti(ceza)),
          ] else if (_cezaFiltre == "odenmedi" && odenmemisler.isEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: _HtmlColors.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _HtmlColors.tertiaryContainer.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_outline_rounded, color: _HtmlColors.tertiary, size: 40),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.turkceMi ? 'Ödenmemiş cezanız bulunmamaktadır!' : 'No unpaid fines found!',
                    style: const TextStyle(color: _HtmlColors.onSurface, fontWeight: FontWeight.bold, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.turkceMi ? 'Tüm trafik kurallarına uyduğunuz için teşekkür ederiz.' : 'Thank you for following all traffic regulations.',
                    style: const TextStyle(color: _HtmlColors.secondary, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // 4. Past Settled Fines Section (Ödenmiş Geçmiş Cezalar)
          if (_cezaFiltre != "odenmedi") ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history_rounded, color: _HtmlColors.tertiary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      widget.turkceMi ? 'Ödenmiş Geçmiş Cezalar' : 'Settled Past Fines',
                      style: const TextStyle(
                        color: _HtmlColors.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.turkceMi ? 'Son 12 Ay' : 'Last 12 Months',
                  style: const TextStyle(
                    color: _HtmlColors.secondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...gecmisOdenenCezalar.map((g) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _HtmlColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
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
                          color: _HtmlColors.tertiaryContainer.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.check, color: _HtmlColors.tertiary, size: 20),
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
                                    g['baslik'],
                                    style: const TextStyle(
                                      color: _HtmlColors.onSurface,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: _HtmlColors.tertiaryContainer.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'ÖDENDİ',
                                    style: TextStyle(
                                      color: _HtmlColors.tertiaryFixed,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Text(
                                  g['tarih']!,
                                  style: const TextStyle(
                                    color: _HtmlColors.secondary,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text('•', style: TextStyle(color: _HtmlColors.secondary, fontSize: 10)),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: _HtmlColors.surfaceContainerLowest,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      g['kod']!,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        color: _HtmlColors.tertiaryFixed,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            g['tutar'],
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: _HtmlColors.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Dekont: ${g['dekontNo']}',
                            style: const TextStyle(
                              color: _HtmlColors.secondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DekontlarSayfasi(dekontlar: _dekontlar, turkceMi: widget.turkceMi),
                            ),
                          );
                        },
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: _HtmlColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.receipt_long_rounded, color: _HtmlColors.secondary, size: 18),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _segmentedFilterButton({
    required String deger,
    required String baslik,
    required int adet,
    bool hasDot = false,
  }) {
    bool secili = _cezaFiltre == deger;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _cezaFiltre = deger),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: secili ? _HtmlColors.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: secili
                ? [
                    BoxShadow(
                      color: _HtmlColors.primaryContainer.withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                baslik,
                style: TextStyle(
                  color: secili ? _HtmlColors.onPrimaryContainer : _HtmlColors.secondary,
                  fontSize: 12,
                  fontWeight: secili ? FontWeight.bold : FontWeight.w600,
                ),
              ),
              if (hasDot && secili) ...[
                const SizedBox(width: 5),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: _HtmlColors.onPrimaryContainer,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: secili
                      ? Colors.white.withValues(alpha: 0.20)
                      : _HtmlColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$adet',
                  style: TextStyle(
                    color: secili ? _HtmlColors.onPrimaryContainer : _HtmlColors.secondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _aktifCezaDosyaKarti(Map<String, dynamic> ceza) {
    // Dinamik Ceza Tutarı ve %15 Erken Ödeme İndirimi Hesabı
    String tutarStr = ceza['tutar']?.toString() ?? '1850 TL';
    String sayisalStr = tutarStr.replaceAll(RegExp(r'[^0-9,\.]'), '');
    if (sayisalStr.contains(',') && sayisalStr.contains('.')) {
      sayisalStr = sayisalStr.replaceAll('.', '').replaceAll(',', '.');
    } else if (sayisalStr.contains(',')) {
      sayisalStr = sayisalStr.replaceAll(',', '.');
    }
    double anaTutar = double.tryParse(sayisalStr) ?? 1850.0;
    double indirimliTutar = anaTutar * 0.85; // %15 Erken İndirim

    String formatPara(double miktar) {
      List<String> parts = miktar.toStringAsFixed(2).split('.');
      String tam = parts[0];
      String kurus = parts[1];
      RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      tam = tam.replaceAllMapped(reg, (Match m) => '${m[1]}.');
      return '₺$tam,$kurus';
    }

    String gorunenIndirimliTutar = formatPara(indirimliTutar);
    String odenenTutarStr = '${indirimliTutar.toStringAsFixed(2)} TL';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _HtmlColors.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ambient Alert Gradient Bar
            Container(
              height: 4,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _HtmlColors.primaryContainer,
                    _HtmlColors.errorContainer,
                    _HtmlColors.primaryContainer,
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header & Reference Number
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _HtmlColors.errorContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.warning_rounded, color: _HtmlColors.onPrimaryContainer, size: 13),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.turkceMi ? 'HIZ İHLALİ' : 'SPEED VIOLATION',
                                        style: const TextStyle(
                                          color: _HtmlColors.onPrimaryContainer,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    widget.turkceMi ? 'Trafik Sicil Şubesi' : 'Traffic Records Dept.',
                                    style: const TextStyle(
                                      color: _HtmlColors.secondary,
                                      fontSize: 11,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ceza['tur'] ?? 'Sabit Radar Kameralı Tespit',
                              style: const TextStyle(
                                color: _HtmlColors.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _HtmlColors.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: _HtmlColors.primaryFixedDim.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  ceza['kod'] ?? '#KKTC-2024-884912',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    color: _HtmlColors.primaryFixedDim,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.turkceMi ? 'CEZA PUANI' : 'PENALTY PTS',
                            style: const TextStyle(
                              color: _HtmlColors.secondary,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: _HtmlColors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.gavel_rounded, color: _HtmlColors.primary, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  ceza['puan'] != null && ceza['puan'].toString().contains('Puan')
                                      ? '+${ceza['puan'].toString().replaceAll(RegExp(r'[^0-9]'), '')}'
                                      : '+5',
                                  style: const TextStyle(
                                    color: _HtmlColors.primary,
                                    fontSize: 16,
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

                  const SizedBox(height: 14),

                  // Violation Data Grid
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _HtmlColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 14, color: _HtmlColors.secondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.turkceMi ? 'İhlal Noktası' : 'Violation Spot',
                                    style: const TextStyle(color: _HtmlColors.secondary, fontSize: 11),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                ceza['konum'] ?? 'Gönyeli Çemberi Girişi',
                                style: const TextStyle(
                                  color: _HtmlColors.onSurface,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                widget.turkceMi ? '2. Şerit / Lefkoşa' : 'Lane 2 / Nicosia',
                                style: const TextStyle(color: _HtmlColors.secondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 38, color: _HtmlColors.surfaceContainerHigh),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.schedule_rounded, size: 14, color: _HtmlColors.secondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.turkceMi ? 'İhlal Zamanı' : 'Violation Time',
                                    style: const TextStyle(color: _HtmlColors.secondary, fontSize: 11),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                ceza['tarih'] ?? '18 Mayıs 2024',
                                style: const TextStyle(
                                  color: _HtmlColors.onSurface,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                '14:32:08 TSİ',
                                style: TextStyle(color: _HtmlColors.secondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Telemetry & Speed Comparison Meter
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _HtmlColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    const Icon(Icons.speed_rounded, color: _HtmlColors.primaryContainer, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      widget.turkceMi ? 'Ölçülen Radar Hızı:' : 'Recorded Speed:',
                                      style: const TextStyle(color: _HtmlColors.secondary, fontSize: 11),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      '78 km/h',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        color: _HtmlColors.primaryContainer,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _HtmlColors.tertiaryContainer.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Limit: 65 km/h',
                                  style: TextStyle(
                                    color: _HtmlColors.tertiaryFixed,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            height: 7,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 65,
                                  child: Container(color: _HtmlColors.tertiaryContainer),
                                ),
                                Expanded(
                                  flex: 35,
                                  child: FadeTransition(
                                    opacity: _pingController,
                                    child: Container(color: _HtmlColors.primaryContainer),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width: 320,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('0 km/h', style: TextStyle(color: _HtmlColors.secondary, fontSize: 10)),
                                const Text(
                                  'Yasal Limit 65 km/h',
                                  style: TextStyle(color: _HtmlColors.tertiaryFixed, fontSize: 10, fontWeight: FontWeight.w600),
                                ),
                                const Text(
                                  '+13 km/h Aşım',
                                  style: TextStyle(color: _HtmlColors.primaryContainer, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Official Radar Camera Evidence Showcase
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.camera_alt_outlined, color: _HtmlColors.primary, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            widget.turkceMi ? 'MOBESE / Radar Kanıt Kaydı' : 'Traffic Camera Evidence',
                            style: const TextStyle(
                              color: _HtmlColors.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _HtmlColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: _HtmlColors.tertiary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'KRİPTOLU DELİL',
                              style: TextStyle(
                                color: _HtmlColors.tertiaryFixed,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Evidence Stage with Telemetry Stamp
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 180,
                          child: Image.network(
                            'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=800',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: _HtmlColors.surfaceContainerLowest,
                              child: const Center(
                                child: Icon(Icons.speed_rounded, color: _HtmlColors.secondary, size: 48),
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _HtmlColors.background.withValues(alpha: 0.85),
                                  Colors.transparent,
                                  _HtmlColors.background.withValues(alpha: 0.90),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: _HtmlColors.surfaceContainerLowest.withValues(alpha: 0.85),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.verified_user_rounded, color: _HtmlColors.tertiary, size: 12),
                                              SizedBox(width: 4),
                                              Text(
                                                'CAM-04-GONYELI',
                                                style: TextStyle(
                                                  fontFamily: 'monospace',
                                                  color: _HtmlColors.secondary,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: _HtmlColors.primaryContainer.withValues(alpha: 0.9),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            'DELİL NO: #884912',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _HtmlColors.surfaceContainerLowest.withValues(alpha: 0.9),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.zoom_in_rounded, color: _HtmlColors.onSurface, size: 14),
                                              const SizedBox(width: 4),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text(
                                                    'PLAKA ONAYI',
                                                    style: TextStyle(color: _HtmlColors.secondary, fontSize: 8),
                                                  ),
                                                  Text(
                                                    '${_secilenPlaka.isNotEmpty ? _secilenPlaka : "RZ 123"} [TRNC]',
                                                    style: const TextStyle(
                                                      fontFamily: 'monospace',
                                                      color: _HtmlColors.onSurface,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: _HtmlColors.surfaceContainerLowest.withValues(alpha: 0.8),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            '2024-05-18 14:32:08',
                                            style: TextStyle(
                                              fontFamily: 'monospace',
                                              color: _HtmlColors.secondary,
                                              fontSize: 9,
                                            ),
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Inspect Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _HtmlColors.surfaceContainerHigh,
                        foregroundColor: _HtmlColors.onSurface,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _delilDosyasiGoster,
                      icon: const Icon(Icons.search_rounded, size: 17),
                      label: Text(
                        widget.turkceMi
                            ? 'Yüksek Çözünürlüklü Delil Dosyasını İncele (PDF & Fotoğraf)'
                            : 'Inspect High-Res Evidence File (PDF & Photo)',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Pricing, Discount & Settlement Deadline
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _HtmlColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.turkceMi ? 'Standart Ceza Tutarı' : 'Standard Fine Amount',
                                  style: const TextStyle(color: _HtmlColors.secondary, fontSize: 11),
                                ),
                                Text(
                                  ceza['tutar'] ?? '₺1.850,00',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    color: _HtmlColors.secondary,
                                    fontSize: 13,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _HtmlColors.tertiaryContainer.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.local_offer_rounded, color: _HtmlColors.tertiaryFixed, size: 12),
                                      const SizedBox(width: 3),
                                      Text(
                                        widget.turkceMi ? '%15 Erken İndirimi' : '15% Early Discount',
                                        style: const TextStyle(
                                          color: _HtmlColors.tertiaryFixed,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  gorunenIndirimliTutar,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    color: _HtmlColors.onSurface,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: _HtmlColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.hourglass_top_rounded, color: _HtmlColors.primary, size: 15),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.turkceMi
                                      ? 'Son İndirimli Gün: 02 Haziran 2024 (14 Gün Kaldı)'
                                      : 'Early Discount Deadline: June 02, 2024 (14 Days Left)',
                                  style: const TextStyle(color: _HtmlColors.secondary, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Payment Simulation & Card Selection Tray
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.turkceMi ? 'Ödeme Yöntemi' : 'Payment Method',
                        style: const TextStyle(
                          color: _HtmlColors.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: _HtmlColors.surfaceContainerHigh,
                              content: Text(
                                widget.turkceMi ? 'Yeni kart ekleme ekranı açılıyor...' : 'Opening add card screen...',
                                style: const TextStyle(color: _HtmlColors.onSurface),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline_rounded, color: _HtmlColors.primary, size: 14),
                        label: Text(
                          widget.turkceMi ? 'Yeni Kart Ekle' : 'Add Card',
                          style: const TextStyle(color: _HtmlColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Selectable Stored Card Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _HtmlColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 28,
                              decoration: BoxDecoration(
                                color: _HtmlColors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Center(
                                child: Text(
                                  'BONUS',
                                  style: TextStyle(
                                    color: _HtmlColors.tertiaryFixed,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Garanti BBVA Bonus',
                                  style: TextStyle(
                                    color: _HtmlColors.onSurface,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '•••• 4412 | 09/27',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    color: _HtmlColors.secondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Icon(Icons.check_circle_rounded, color: _HtmlColors.tertiary, size: 20),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Sovereign CTA Pay Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            _HtmlColors.primaryContainer,
                            _HtmlColors.errorContainer,
                            _HtmlColors.primaryContainer,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _HtmlColors.primaryContainer.withValues(alpha: 0.45),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _cezaOdeniyor
                            ? null
                            : () async {
                                setState(() => _cezaOdeniyor = true);
                                await Future.delayed(const Duration(milliseconds: 900));
                                if (mounted) {
                                  _cezaOdemeGuncelle(
                                    _secilenPlaka,
                                    ceza['id'] ?? '1',
                                    ceza['tur'] ?? 'Sabit Radar Kameralı Tespit',
                                    ceza['turEn'] ?? 'Speed Limit Violation',
                                    odenenTutarStr,
                                  );
                                  setState(() => _cezaOdeniyor = false);
                                }
                              },
                        child: _cezaOdeniyor
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'İşleniyor...',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.lock_rounded, color: _HtmlColors.onPrimaryContainer, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.turkceMi
                                        ? 'Güvenli Ödeme Yap ($gorunenIndirimliTutar)'
                                        : 'Pay Securely ($gorunenIndirimliTutar)',
                                    style: const TextStyle(
                                      color: _HtmlColors.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Dispute / Appeal Button
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItirazSayfasi(turkceMi: widget.turkceMi),
                          ),
                        );
                      },
                      icon: const Icon(Icons.assignment_turned_in_outlined, color: _HtmlColors.secondary, size: 16),
                      label: Text(
                        widget.turkceMi
                            ? 'Bu Cezaya Resmi İtiraz Dilekçesi Ver (Trafik Hakem Heyeti)'
                            : 'Submit Official Dispute for this Fine',
                        style: const TextStyle(
                          color: _HtmlColors.secondary,
                          fontSize: 11,
                          decoration: TextDecoration.underline,
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
    );
  }

  // --- TAB 3: SİGORTA VE POLİÇE YÖNETİMİ / POLİS QR DENETİM ---
  Widget _sigortaGorunumu({
    required String markaModel,
    required int sigortaGun,
    required int muayeneGun,
  }) {
    final bool aktif = sigortaGun > 0;
    final String plakaGosterim = _secilenPlaka.isNotEmpty ? _secilenPlaka : "RZ 123";
    final aracVerisi = _aracBilgileriVeritabani[_secilenPlaka] ?? {};
    final int seyruseferKalanGun = aracVerisi['seyruseferKalanGun'] ?? 90;
    final String seyruseferBitisTarihi = aracVerisi['seyruseferBitisTarihi'] ?? "20 Şubat 2027";
    final String seyruseferHarc = aracVerisi['seyruseferHarc'] ?? "₺3.850,00";
    final int seyruseferHarcMiktar = aracVerisi['seyruseferHarcMiktar'] ?? 3850;
    final String seyruseferDonem = aracVerisi['seyruseferDonem'] ?? "2026 / 2. Yıllık Dönem";
    final String sasiNo = aracVerisi['sasiNo'] ?? "TRNC-••••-8812";
    final String motorHacmi = aracVerisi['motorHacmi'] ?? "1598 cc / Benzin";

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst Segment Switcher (Dijital Sigorta & Seyrüsefer Ruhsatı & Polis QR Denetim)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _HtmlColors.surfaceContainerHigh.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                _sigortaSegmentBtn(
                  key: 'wallet',
                  icon: Icons.shield_outlined,
                  title: widget.turkceMi ? 'Sigorta' : 'Insurance',
                ),
                _sigortaSegmentBtn(
                  key: 'seyrusefer',
                  icon: Icons.directions_car_filled_rounded,
                  title: widget.turkceMi ? 'Seyrüsefer' : 'Road Tax',
                  badge: seyruseferKalanGun <= 15 ? '!' : null,
                ),
                _sigortaSegmentBtn(
                  key: 'police',
                  icon: Icons.qr_code_scanner_rounded,
                  title: widget.turkceMi ? 'Polis QR' : 'Police QR',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // SEÇİLEN SEKMEYE GÖRE İÇERİK
          if (_sigortaSekmesi == 'wallet') ...[
            // 1. APPLE WALLET DİJİTAL SİGORTA KARTI
            Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1C274C),
                    Color(0xFF0E1630),
                    Color(0xFF070B1A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.40),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Kıbrıs Harita Watermark Silüeti
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _KibrisWatermarkPainter(),
                    ),
                  ),
                  // Sağ üst yumuşak glowing blur
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _HtmlColors.primary.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  // Kart İçeriği
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Başlık & Logo Satırı
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: _HtmlColors.surfaceBright.withValues(alpha: 0.40),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                                  ),
                                  child: const Icon(
                                    Icons.shield_outlined,
                                    color: _HtmlColors.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.turkceMi ? 'KKTC ZORUNLU TRAFİK SİGORTASI' : 'TRNC MANDATORY MOTOR INSURANCE',
                                      style: const TextStyle(
                                        color: Color(0xFFD4AF37),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.turkceMi ? 'Kıbrıs Sigorta Kooperatifi A.Ş.' : 'Cyprus Insurance Co-op Ltd.',
                                      style: const TextStyle(
                                        color: _HtmlColors.secondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _HtmlColors.surfaceContainerHighest.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: aktif ? _HtmlColors.tertiary.withValues(alpha: 0.3) : _HtmlColors.primary.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                aktif ? (widget.turkceMi ? 'AKTİF' : 'ACTIVE') : (widget.turkceMi ? 'SÜRESİ DOLDU' : 'EXPIRED'),
                                style: TextStyle(
                                  color: aktif ? _HtmlColors.tertiary : _HtmlColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),

                        // Plaka & Geri Sayım Satırı
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.turkceMi ? 'ARAÇ PLAKASI' : 'LICENSE PLATE',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                    color: _HtmlColors.secondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  plakaGosterim,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.0,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  markaModel,
                                  style: const TextStyle(
                                    color: _HtmlColors.onSecondaryContainer,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD97706).withValues(alpha: 0.20),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: const Color(0xFFFBBF24).withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.timer_outlined, size: 14, color: Color(0xFFFBBF24)),
                                      const SizedBox(width: 4),
                                      Text(
                                        aktif
                                            ? '$sigortaGun ${widget.turkceMi ? 'GÜN KALDI' : 'DAYS LEFT'}'
                                            : (widget.turkceMi ? 'SÜRESİ BİTTİ' : 'EXPIRED'),
                                        style: const TextStyle(
                                          color: Color(0xFFFBBF24),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.turkceMi ? 'Bitiş: 30 Mayıs 2026' : 'Expiry: May 30, 2026',
                                  style: const TextStyle(
                                    color: _HtmlColors.secondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Alt Bilgi Şeridi: Poliçe No & Azami Hasar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: _HtmlColors.surfaceContainerLowest.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.turkceMi ? 'POLİÇE NO' : 'POLICY NO',
                                    style: const TextStyle(
                                      color: _HtmlColors.secondary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'POL-2023-889102-K',
                                    style: TextStyle(
                                      color: _HtmlColors.onSurface,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    widget.turkceMi ? 'AZAMİ HASAR' : 'MAX COVERAGE',
                                    style: const TextStyle(
                                      color: _HtmlColors.secondary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    '₺1.500.000',
                                    style: TextStyle(
                                      color: _HtmlColors.tertiary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'monospace',
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
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 2. İKİLİ HIZLI AKSİYON BUTONLARI
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _HtmlColors.surfaceContainerHigh,
                        foregroundColor: _HtmlColors.onSurface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                        ),
                      ),
                      onPressed: () {
                        _showSigortaToast(
                          widget.turkceMi
                              ? "Resmi Sigorta Poliçesi (PDF) cihazınıza indirildi!"
                              : "Official Insurance Policy (PDF) downloaded!",
                          Icons.download_done_rounded,
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf_rounded, size: 19, color: Colors.white),
                      label: Text(
                        widget.turkceMi ? "Poliçeyi İndir (PDF)" : "Download Policy (PDF)",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_HtmlColors.primaryContainer, Color(0xFFB50220)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _HtmlColors.primaryContainer.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _sigortaYenile(_secilenPlaka),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.autorenew, size: 18, color: _HtmlColors.onPrimaryContainer),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                widget.turkceMi ? '365 Gün Yenile (₺4.500)' : 'Renew 365 Days (₺4,500)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: _HtmlColors.onPrimaryContainer,
                                ),
                                overflow: TextOverflow.ellipsis,
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
            const SizedBox(height: 14),

            // 3. POLİÇE TEMİNAT & ASİSTANLIK KARTI
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _HtmlColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.turkceMi ? 'Poliçe Teminat & Asistanlık' : 'Coverage & Assistance',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _HtmlColors.onSurface,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _HtmlColors.tertiaryContainer.withValues(alpha: 0.30),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          widget.turkceMi ? 'TAM KORUMA' : 'FULL COVERAGE',
                          style: const TextStyle(
                            color: _HtmlColors.tertiaryFixedDim,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _sigortaTeminatRow(
                    icon: Icons.directions_car_outlined,
                    baslik: widget.turkceMi ? '3. Şahıs Maddi Zararlar' : '3rd Party Property Damage',
                    aciklama: widget.turkceMi ? 'Kaza başı yasal zorunlu azami teminat' : 'Statutory mandatory coverage per accident',
                    deger: '₺500.000',
                  ),
                  const SizedBox(height: 10),
                  _sigortaTeminatRow(
                    icon: Icons.medical_services_outlined,
                    baslik: widget.turkceMi ? 'Bedeni Tedavi & Kaza' : 'Bodily Injury & Medical',
                    aciklama: widget.turkceMi ? 'Yolcu ve sürücü tam sağlık kapsamı' : 'Full medical coverage for passenger and driver',
                    deger: '₺1.000.000',
                  ),
                  const SizedBox(height: 10),
                  _sigortaTeminatRow(
                    icon: Icons.car_repair_outlined,
                    baslik: widget.turkceMi ? 'KKTC Geneli 7/24 Yol Yardım' : 'TRNC 24/7 Roadside Assistance',
                    aciklama: widget.turkceMi ? 'Girne, Lefkoşa, Gazimağusa, İskele' : 'Kyrenia, Nicosia, Famagusta, Iskele',
                    deger: widget.turkceMi ? 'Ücretsiz / Sınırsız' : 'Free / Unlimited',
                    isBadge: true,
                  ),
                ],
              ),
            ),
          ] else if (_sigortaSekmesi == 'seyrusefer') ...[
            _seyruseferGorunumu(
              markaModel: markaModel,
              plakaGosterim: plakaGosterim,
              kalanGun: seyruseferKalanGun,
              bitisTarihi: seyruseferBitisTarihi,
              harc: seyruseferHarc,
              harcMiktar: seyruseferHarcMiktar,
              donem: seyruseferDonem,
              muayeneGun: muayeneGun,
              sasiNo: sasiNo,
              motorHacmi: motorHacmi,
            ),
          ] else ...[
            // 3. POLİS QR DENETİM EKRANI
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _HtmlColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Başlık & Canlı Senkron Durumu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _HtmlColors.primaryContainer.withValues(alpha: 0.20),
                            ),
                            child: const Icon(
                              Icons.badge_outlined,
                              color: _HtmlColors.primaryContainer,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.turkceMi ? 'Trafik Denetim Ekranı' : 'Traffic Inspection Screen',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _HtmlColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.turkceMi ? 'KKTC Polis Genel Müdürlüğü' : 'TRNC Police General Directorate',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: _HtmlColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _HtmlColors.tertiaryContainer.withValues(alpha: 0.30),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _pingController,
                              builder: (context, child) {
                                return Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _HtmlColors.tertiary.withValues(
                                      alpha: 0.4 + (_pingController.value * 0.6),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 5),
                            Text(
                              widget.turkceMi ? 'CANLI SENKRON' : 'LIVE SYNC',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: _HtmlColors.tertiaryFixedDim,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Beyaz QR Kod Kartı
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      size: Size(_sigortaQrBuyuk ? 230 : 180, _sigortaQrBuyuk ? 230 : 180),
                      painter: _PolisQrPainter(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dinamik Kod & Onay İkonu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _HtmlColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _sigortaOtpKodu,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _HtmlColors.onSurface,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.verified,
                                size: 18,
                                color: _HtmlColors.tertiary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Canlı Denetim Verisi Tablosu
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _HtmlColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.turkceMi ? 'Canlı Denetim Verisi' : 'Live Inspection Data',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _HtmlColors.onSurface,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _HtmlColors.tertiaryContainer.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.turkceMi ? 'UYGUN / GEÇERLİ' : 'VALID / COMPLIANT',
                                style: const TextStyle(
                                  color: _HtmlColors.tertiary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _polisDenetimMaddesi(
                                widget.turkceMi ? 'Seyrüsefer' : 'Road Tax',
                                seyruseferKalanGun > 0
                                    ? (widget.turkceMi ? 'Aktif (${seyruseferKalanGun}G)' : 'Active (${seyruseferKalanGun}D)')
                                    : (widget.turkceMi ? 'Gecikmiş' : 'Expired'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _polisDenetimMaddesi(
                                widget.turkceMi ? 'Sigorta' : 'Insurance',
                                sigortaGun > 0
                                    ? (widget.turkceMi ? 'Aktif (${sigortaGun}G)' : 'Active (${sigortaGun}D)')
                                    : (widget.turkceMi ? 'Geçersiz' : 'Expired'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _polisDenetimMaddesi(
                                widget.turkceMi ? 'Muayene' : 'Inspection',
                                muayeneGun > 0
                                    ? (widget.turkceMi ? 'Geçerli (${muayeneGun}G)' : 'Valid (${muayeneGun}D)')
                                    : (widget.turkceMi ? 'Muayenesiz' : 'Expired'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _polisDenetimMaddesi(
                                widget.turkceMi ? 'Ceza Puanı' : 'Demerit Points',
                                widget.turkceMi ? '0 Puan' : '0 Pts',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Alt Butonlar: QR Büyüt & OTP Yenile
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _HtmlColors.surfaceContainerHigh,
                              foregroundColor: _HtmlColors.onSurface,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _sigortaQrBuyuk = !_sigortaQrBuyuk;
                              });
                            },
                            icon: Icon(
                              _sigortaQrBuyuk ? Icons.zoom_out : Icons.zoom_in,
                              size: 18,
                              color: Colors.white,
                            ),
                            label: Text(
                              _sigortaQrBuyuk
                                  ? (widget.turkceMi ? 'Normale Döndür' : 'Normal Size')
                                  : (widget.turkceMi ? 'QR Kodu Büyüt' : 'Zoom QR Code'),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _HtmlColors.surfaceContainerHigh,
                            foregroundColor: _HtmlColors.onSurface,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              final rnd = (1000 + Random().nextInt(8999)).toString();
                              _sigortaOtpKodu = "KKTC-TRF-$rnd-OK";
                            });
                            _showSigortaToast(
                              widget.turkceMi ? "Canlı QR Güvenlik Kodu Yenilendi" : "Live QR Security Code Refreshed",
                              Icons.sync,
                            );
                          },
                          child: const Icon(Icons.sync, size: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Floating Toast Bildirim Helper
  void _showSigortaToast(String message, IconData icon) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2C344D),
        elevation: 12,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 84, left: 24, right: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.12), width: 1),
        ),
        duration: const Duration(milliseconds: 2800),
        content: Row(
          children: [
            Icon(icon, color: const Color(0xFF4EDEA3), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Color(0xFFDBE1FF),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Segment Geçiş Butonu Helper
  Widget _sigortaSegmentBtn({
    required String key,
    required IconData icon,
    required String title,
    String? badge,
  }) {
    bool secili = _sigortaSekmesi == key;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_sigortaSekmesi != key) {
            setState(() => _sigortaSekmesi = key);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: secili ? _HtmlColors.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: secili
                ? [
                    BoxShadow(
                      color: _HtmlColors.primaryContainer.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: secili ? _HtmlColors.onPrimaryContainer : _HtmlColors.secondary,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: secili ? _HtmlColors.onPrimaryContainer : _HtmlColors.secondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('!', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --- SEYRÜSEFER RUHSATI VE HARÇ YÖNETİMİ GÖRÜNÜMÜ ---
  Widget _seyruseferGorunumu({
    required String markaModel,
    required String plakaGosterim,
    required int kalanGun,
    required String bitisTarihi,
    required String harc,
    required int harcMiktar,
    required String donem,
    required int muayeneGun,
    required String sasiNo,
    required String motorHacmi,
  }) {
    final bool gecerli = kalanGun > 0;
    final bool acil = kalanGun <= 15 && kalanGun > 0;
    final double dolulukOrani = (kalanGun / 365.0).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. RESMİ SEYRÜSEFER RUHSAT KARTI
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF132B45),
                Color(0xFF0C1D33),
                Color(0xFF071120),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mavi Üst Çizgi
              Container(
                height: 4,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8), Color(0xFF0284C7)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık ve Durum Rozeti (Responsive Expanded)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFF0EA5E9).withValues(alpha: 0.3)),
                                ),
                                child: const Icon(
                                  Icons.account_balance_rounded,
                                  color: Color(0xFF38BDF8),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        widget.turkceMi ? 'KKTC MALİYE BAKANLIĞI' : 'TRNC MINISTRY OF FINANCE',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFFE0F2FE),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.turkceMi ? 'Gelir ve Vergi Dairesi • Araç Kayıt' : 'Revenue & Tax Dept. • Vehicle Reg.',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: _HtmlColors.secondary,
                                      ),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: gecerli
                                ? (acil
                                    ? Colors.amber.withValues(alpha: 0.2)
                                    : _HtmlColors.tertiaryContainer.withValues(alpha: 0.25))
                                : _HtmlColors.errorContainer.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: gecerli
                                  ? (acil ? Colors.amber : _HtmlColors.tertiary.withValues(alpha: 0.4))
                                  : _HtmlColors.primaryContainer,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            gecerli
                                ? (acil
                                    ? (widget.turkceMi ? 'YENİLEME YAKLAŞTI' : 'EXPIRING SOON')
                                    : (widget.turkceMi ? 'AKTİF RUHSAT' : 'ACTIVE TAX'))
                                : (widget.turkceMi ? 'SÜRESİ DOLMUŞ' : 'EXPIRED'),
                            style: TextStyle(
                              color: gecerli ? (acil ? Colors.amber : _HtmlColors.tertiaryFixed) : Colors.redAccent,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Araç Plaka ve Model
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.turkceMi ? 'KAYITLI PLAKA' : 'REGISTERED PLATE',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: _HtmlColors.secondary,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _HtmlColors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    plakaGosterim,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: _HtmlColors.primaryContainer.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'TRNC',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              widget.turkceMi ? 'YILLIK HARÇ' : 'ANNUAL TAX',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: _HtmlColors.secondary,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              harc,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: _HtmlColors.tertiaryFixed,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),
                    Text(
                      markaModel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _HtmlColors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Kalan Gün & Bitiş Tarihi Sayacı Box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _HtmlColors.surfaceContainerLowest.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.hourglass_top_rounded,
                                      size: 18,
                                      color: acil ? Colors.amber : const Color(0xFF38BDF8),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.turkceMi ? 'SEYRÜSEFER DURUMU' : 'ROAD TAX STATUS',
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: _HtmlColors.secondary,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              gecerli
                                                  ? (widget.turkceMi ? '$kalanGun Gün Kaldı' : '$kalanGun Days Left')
                                                  : (widget.turkceMi ? 'Süresi Doldu!' : 'Expired!'),
                                              style: TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 15,
                                                fontWeight: FontWeight.w900,
                                                color: gecerli ? (acil ? Colors.amber : Colors.white) : Colors.redAccent,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    widget.turkceMi ? 'Bitiş Tarihi' : 'Expiry Date',
                                    style: const TextStyle(fontSize: 10, color: _HtmlColors.secondary),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    bitisTarihi,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: _HtmlColors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // İlerleme Çubuğu (Progress Bar)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              height: 6,
                              child: LinearProgressIndicator(
                                value: dolulukOrani,
                                backgroundColor: Colors.white.withValues(alpha: 0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  acil
                                      ? Colors.amber
                                      : (gecerli ? const Color(0xFF38BDF8) : _HtmlColors.primaryContainer),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                donem,
                                style: const TextStyle(color: _HtmlColors.secondary, fontSize: 10),
                              ),
                              Text(
                                widget.turkceMi ? '%${(dolulukOrani * 100).toInt()} Geçerlilik' : '%${(dolulukOrani * 100).toInt()} Validity',
                                style: const TextStyle(
                                  color: Color(0xFF38BDF8),
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

                    // Teknik & Ruhsat Detay Bilgi Grid
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: _HtmlColors.surfaceContainerHigh.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _seyruseferBilgiRow(
                            widget.turkceMi ? 'Araç Muayenesi' : 'Vehicle Inspection',
                            muayeneGun > 0
                                ? (widget.turkceMi ? 'Geçerli ($muayeneGun Gün Kaldı)' : 'Valid ($muayeneGun Days)')
                                : (widget.turkceMi ? 'Muayene Süresi Dolmuş!' : 'Inspection Expired!'),
                            isAlert: muayeneGun <= 0,
                          ),
                          const Divider(color: Colors.white10, height: 12),
                          _seyruseferBilgiRow(
                            widget.turkceMi ? 'Motor / Silindir' : 'Engine Spec',
                            motorHacmi,
                          ),
                          const Divider(color: Colors.white10, height: 12),
                          _seyruseferBilgiRow(
                            widget.turkceMi ? 'Şasi Numarası' : 'Chassis Number',
                            sasiNo,
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

        const SizedBox(height: 12),

        // 2. İKİLİ HIZLI AKSİYON BUTONLARI
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _HtmlColors.surfaceContainerHigh,
                    foregroundColor: _HtmlColors.onSurface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                  ),
                  onPressed: () {
                    _showSigortaToast(
                      widget.turkceMi
                          ? "Resmi Seyrüsefer Ruhsatı (PDF) cihazınıza indirildi!"
                          : "Official Road Tax License (PDF) downloaded!",
                      Icons.download_done_rounded,
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 19, color: Colors.white),
                  label: Text(
                    widget.turkceMi ? "Ruhsatı İndir (PDF)" : "Download Tax PDF",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_HtmlColors.primaryContainer, Color(0xFFB50220)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _HtmlColors.primaryContainer.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _seyruseferYenileSheet(plakaGosterim, markaModel, harcMiktar, harc, muayeneGun),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.autorenew_rounded, size: 18, color: Colors.white),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              widget.turkceMi ? "Seyrüsefer Yenile" : "Renew Road Tax",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // 3. YASAL BİLGİLENDİRME VE REHBER KARTI
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _HtmlColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFF38BDF8), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    widget.turkceMi ? 'KKTC Seyrüsefer ve Yol Trafik Esasları' : 'TRNC Road Tax Regulations',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _HtmlColors.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _seyruseferRehberMaddesi(
                widget.turkceMi
                    ? 'Tüm motorlu araçlar KKTC sınırlarında güncel seyrüsefer ruhsatına sahip olmakla yükümlüdür.'
                    : 'All vehicles must possess an active road tax license in TRNC.',
              ),
              const SizedBox(height: 8),
              _seyruseferRehberMaddesi(
                widget.turkceMi
                    ? 'Muayenesi tamamlanmamış veya geçmiş araçların seyrüseferi Gelir ve Vergi Dairesi tarafından yenilenemez.'
                    : 'Road tax cannot be renewed without a valid vehicle inspection.',
              ),
              const SizedBox(height: 8),
              _seyruseferRehberMaddesi(
                widget.turkceMi
                    ? 'Seyrüsefersiz trafiğe çıkılması durumunda polis tarafından asgari ücretin %20\'si oranında ceza tanzim edilir.'
                    : 'Driving without road tax incurs a 20% minimum wage fine and potential vehicle impoundment.',
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 4. E-ARŞİV VE GEÇMİŞ MAKBUZ BİLGİSİ
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _HtmlColors.surfaceContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _HtmlColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.receipt_rounded, size: 16, color: _HtmlColors.secondary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.turkceMi ? 'Son Dönem Seyrüsefer Makbuzu' : 'Previous Period Receipt',
                            style: const TextStyle(color: _HtmlColors.onSurface, fontSize: 12, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.turkceMi ? '2025/2. Yıllık Dönem • Makbuz: #SYR-89210' : '2025/2 Period • Receipt: #SYR-89210',
                              style: const TextStyle(
                                color: _HtmlColors.secondary,
                                fontSize: 10,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: _HtmlColors.tertiaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ÖDENDİ',
                  style: TextStyle(color: _HtmlColors.tertiaryFixed, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Seyrüsefer Yenileme Bottom Sheet
  void _seyruseferYenileSheet(String plaka, String markaModel, int harcMiktar, String harcStr, int muayeneGun) {
    if (muayeneGun <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _HtmlColors.errorContainer,
          content: Text(
            widget.turkceMi
                ? 'Araç muayenenizin süresi dolduğu için seyrüsefer yenilenemez! Önce muayene yaptırınız.'
                : 'Road tax cannot be renewed because vehicle inspection has expired!',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        bool isProcessing = false;
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: _HtmlColors.surfaceContainer,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _HtmlColors.secondary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0EA5E9).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.account_balance_rounded, color: Color(0xFF38BDF8)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.turkceMi ? 'Online Seyrüsefer Harcı Ödeme' : 'Online Road Tax Payment',
                                style: const TextStyle(
                                  color: _HtmlColors.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.turkceMi ? 'KKTC Gelir ve Vergi Dairesi Sistemi' : 'TRNC Revenue & Tax Dept.',
                                style: const TextStyle(color: _HtmlColors.secondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _HtmlColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Column(
                        children: [
                          _bilgiSatiri(widget.turkceMi ? 'Plaka' : 'Plate', '$plaka [TRNC]'),
                          const Divider(color: Colors.white10),
                          _bilgiSatiri(widget.turkceMi ? 'Araç Modeli' : 'Vehicle Model', markaModel),
                          const Divider(color: Colors.white10),
                          _bilgiSatiri(widget.turkceMi ? 'Ruhsat Süresi' : 'Validity', widget.turkceMi ? '+365 Gün (1 Yıl)' : '+365 Days (1 Year)'),
                          const Divider(color: Colors.white10),
                          _bilgiSatiri(widget.turkceMi ? 'Muayene Uygunluğu' : 'Inspection Check', widget.turkceMi ? '✅ Onaylandı' : '✅ Verified'),
                          const Divider(color: Colors.white10),
                          _bilgiSatiri(widget.turkceMi ? 'Yıllık Harç Bedeli' : 'Total Amount', harcStr, vurgulu: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _HtmlColors.primaryContainer,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: isProcessing
                            ? null
                            : () async {
                                setModalState(() => isProcessing = true);
                                await Future.delayed(const Duration(milliseconds: 900));
                                if (!mounted) return;
                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                }
                                setState(() {
                                  if (_aracBilgileriVeritabani.containsKey(plaka)) {
                                    _aracBilgileriVeritabani[plaka]!['seyruseferKalanGun'] =
                                        (_aracBilgileriVeritabani[plaka]!['seyruseferKalanGun'] ?? 0) + 365;
                                    _aracBilgileriVeritabani[plaka]!['seyruseferBitisTarihi'] = "01 Ekim 2027";
                                  }
                                  _dekontlar.insert(0, {
                                    "islem": "Seyrüsefer Harcı Yenileme ($plaka)",
                                    "islemEn": "Road Tax Renewal ($plaka)",
                                    "tarih": "Bugün / Today",
                                    "tutar": harcStr,
                                    "kod": "SYR-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
                                    "kurum": "KKTC Maliye Bakanlığı Gelir ve Vergi Dairesi",
                                    "durum": "Ödendi / 365 Gün Geçerli"
                                  });
                                });
                                _showSigortaToast(
                                  widget.turkceMi
                                      ? "Seyrüsefer harcınız 365 gün süreyle başarıyla ödendi!"
                                      : "Road tax successfully renewed for 365 days!",
                                  Icons.check_circle_rounded,
                                );
                              },
                        child: isProcessing
                            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.lock_rounded, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.turkceMi ? 'Güvenli Öde & 1 Yıl Yenile ($harcStr)' : 'Pay Securely & Renew ($harcStr)',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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

  Widget _seyruseferBilgiRow(String baslik, String deger, {bool isAlert = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(baslik, style: const TextStyle(color: _HtmlColors.secondary, fontSize: 11)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            deger,
            style: TextStyle(
              color: isAlert ? Colors.redAccent : _HtmlColors.onSurface,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _seyruseferRehberMaddesi(String metin) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Icon(Icons.check_circle_rounded, color: Color(0xFF38BDF8), size: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            metin,
            style: const TextStyle(color: _HtmlColors.secondary, fontSize: 11, height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _bilgiSatiri(String baslik, String deger, {bool vurgulu = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: const TextStyle(color: _HtmlColors.secondary, fontSize: 12)),
          Text(
            deger,
            style: TextStyle(
              color: vurgulu ? _HtmlColors.tertiaryFixed : _HtmlColors.onSurface,
              fontSize: vurgulu ? 14 : 12,
              fontWeight: vurgulu ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Poliçe Teminat Satırı Helper
  Widget _sigortaTeminatRow({
    required IconData icon,
    required String baslik,
    required String aciklama,
    required String deger,
    bool isBadge = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _HtmlColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _HtmlColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: _HtmlColors.secondary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  baslik,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _HtmlColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  aciklama,
                  style: const TextStyle(
                    fontSize: 10,
                    color: _HtmlColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _HtmlColors.tertiaryContainer.withValues(alpha: 0.30),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                deger,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: _HtmlColors.tertiary,
                ),
              ),
            )
          else
            Text(
              deger,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _HtmlColors.onSurface,
                fontFamily: 'monospace',
              ),
            ),
        ],
      ),
    );
  }

  // Polis Denetim Maddesi Helper
  Widget _polisDenetimMaddesi(String etiket, String deger) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: _HtmlColors.tertiary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 11, color: _HtmlColors.secondary),
                children: [
                  TextSpan(text: '$etiket: '),
                  TextSpan(
                    text: deger,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _HtmlColors.onSurface,
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

  // --- TAB 0: RADAR & CANLI SÜRÜŞ EKRANI (Ana Sayfa Açılışı) ---
  Widget _radarSurusEkrani({
    required int odenmemisCezaSayisi,
    required int toplamBorc,
    required int sigortaGun,
  }) {
    final aracVerisi = _aracBilgileriVeritabani[_secilenPlaka] ?? {};
    final markaModel = (aracVerisi['markaModel'] as String? ?? '').split('(').first.trim();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      physics: const BouncingScrollPhysics(),
      children: [

        // ═══════════════════════════════════════════════
        // 1. ARAç DURUMU + AKTİF RADAR + ARAMA ÇUBUĞU
        // ═══════════════════════════════════════════════
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _HtmlColors.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.40), blurRadius: 14, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              // Araç Pill + Radar Pill
              Row(
                children: [
                  // Aktif araç
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: _HtmlColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.directions_car_rounded, color: _HtmlColors.primary, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            _secilenPlaka.isNotEmpty ? _secilenPlaka : 'KY 987',
                            style: const TextStyle(
                              color: _HtmlColors.secondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const Text(' • ', style: TextStyle(color: _HtmlColors.secondary)),
                          Flexible(
                            child: Text(
                              markaModel.isNotEmpty ? markaModel : 'BMW',
                              style: const TextStyle(color: _HtmlColors.secondary, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          FadeTransition(
                            opacity: _pingController,
                            child: Container(
                              width: 7, height: 7,
                              decoration: const BoxDecoration(color: _HtmlColors.tertiary, shape: BoxShape.circle),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Aktif Radar Sayacı
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: _HtmlColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.radar_rounded, color: _HtmlColors.onSurface, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          widget.turkceMi ? '4 Aktif Radar' : '4 Active Radars',
                          style: const TextStyle(
                            color: _HtmlColors.onSurface,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Arama + Rota Çubuğu
              GestureDetector(
                onTap: () => setState(() => _seciliIndex = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: _HtmlColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.explore_rounded, color: _HtmlColors.onSurface, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.turkceMi ? 'Lefkoşa — Girne Boğazı' : 'Nicosia — Kyrenia Pass',
                              style: const TextStyle(
                                color: _HtmlColors.secondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              widget.turkceMi ? 'Hedef ara veya haritaya dokun' : 'Search destination or tap map',
                              style: const TextStyle(color: _HtmlColors.secondary, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: _HtmlColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.near_me_rounded, color: _HtmlColors.onSurface, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // ═══════════════════════════════════════════════
        // 2. HARİTA & TELEMETRİ KOKPİT KATMANI
        // ═══════════════════════════════════════════════
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: const Color(0xFF0B1424),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.60), blurRadius: 20, offset: const Offset(0, 6)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Harita içeriği
              Positioned.fill(
                child: RadarHaritasiSayfasi(turkceMi: widget.turkceMi),
              ),

              // HUD: Sol Üst — Hızometre + Hız Limiti
              Positioned(
                top: 12, left: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hızometre
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.turkceMi ? 'HIZINIZ' : 'YOUR SPEED',
                            style: const TextStyle(color: _HtmlColors.secondary, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              const Text(
                                '68',
                                style: TextStyle(color: _HtmlColors.onSurface, fontSize: 28, fontWeight: FontWeight.w900, height: 1.0),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.turkceMi ? 'km/s' : 'km/h',
                                style: const TextStyle(color: _HtmlColors.secondary, fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Hız Limiti Tabelası
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFDC2626), width: 3.5),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.40), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('LİMİT', style: TextStyle(color: Color(0xFFDC2626), fontSize: 7, fontWeight: FontWeight.w800, height: 1.0)),
                          Text('65', style: TextStyle(color: Color(0xFF0A0E1A), fontSize: 16, fontWeight: FontWeight.w900, height: 1.1)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // HUD: Sağ Üst — Hızlı Kontroller
              Positioned(
                top: 12, right: 12,
                child: Column(
                  children: [
                    _mapHudButon(Icons.volume_up_rounded),
                    const SizedBox(height: 6),
                    _mapHudButon(Icons.layers_rounded),
                    const SizedBox(height: 6),
                    _mapHudButon(Icons.my_location_rounded),
                  ],
                ),
              ),

              // Alt Şerit: Mesafe + Süre
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _HtmlColors.surfaceContainer.withValues(alpha: 0.95),
                    border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.navigation_rounded, color: _HtmlColors.onSurface, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        widget.turkceMi ? 'Touch-to-Route devrede' : 'Touch-to-Route active',
                        style: const TextStyle(color: _HtmlColors.secondary, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      const Text(
                        '18.4 km • 14 dk',
                        style: TextStyle(color: _HtmlColors.onSurface, fontSize: 12, fontWeight: FontWeight.w800, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // ═══════════════════════════════════════════════
        // 3. TAKTİKSEL YOL KARTI
        // ═══════════════════════════════════════════════
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _HtmlColors.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.40), blurRadius: 14, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              // Anlık Tehlike / Radar Uyarısı
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _HtmlColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: _HtmlColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.photo_camera_rounded, color: _HtmlColors.onSurface, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.turkceMi ? 'SABİT RADAR DENETİMİ' : 'FIXED SPEED CAMERA',
                                style: const TextStyle(color: _HtmlColors.onSurface, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                              ),
                              const Text(
                                '500m',
                                style: TextStyle(color: _HtmlColors.secondary, fontSize: 12, fontWeight: FontWeight.w800, fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.turkceMi ? 'Gönyeli Çemberi Kamerası' : 'Gonyeli Roundabout Camera',
                            style: const TextStyle(color: _HtmlColors.secondary, fontSize: 13, fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.turkceMi ? 'Yasal Hız Sınırı: 65 km/s' : 'Speed Limit: 65 km/h',
                            style: const TextStyle(color: _HtmlColors.secondary, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Trafik Yoğunluğu Grid
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _HtmlColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(width: 8, height: 8, decoration: const BoxDecoration(color: _HtmlColors.tertiary, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text(widget.turkceMi ? 'GÖNYELI' : 'GONYELI', style: const TextStyle(color: _HtmlColors.secondary, fontSize: 8, fontWeight: FontWeight.w800)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.turkceMi ? 'Akıcı (62 km/s)' : 'Clear (62 km/h)',
                            style: const TextStyle(color: _HtmlColors.secondary, fontSize: 12, fontWeight: FontWeight.w600),
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
                        color: _HtmlColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text(widget.turkceMi ? 'BOĞAZ' : 'BOGAZ PASS', style: const TextStyle(color: _HtmlColors.secondary, fontSize: 8, fontWeight: FontWeight.w800)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.turkceMi ? 'Orta (38 km/s)' : 'Moderate (38 km/h)',
                            style: const TextStyle(color: _HtmlColors.secondary, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Aksiyon Barı: Navigasyonu Başlat + Radar Listesi
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _seciliIndex = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _HtmlColors.secondary,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(color: _HtmlColors.secondary.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.turn_sharp_right_rounded, color: _HtmlColors.surfaceContainerLowest, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              widget.turkceMi ? 'Navigasyonu Başlat' : 'Start Navigation',
                              style: const TextStyle(color: _HtmlColors.surfaceContainerLowest, fontSize: 14, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _seciliIndex = 1),
                    child: Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: _HtmlColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.list_alt_rounded, color: _HtmlColors.secondary, size: 22),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // ═══════════════════════════════════════════════
        // 4. SİGORTA & SEYRÜSEFER DURUM ŞERİDİ
        // ═══════════════════════════════════════════════
        GestureDetector(
          onTap: () => setState(() {
            _seciliIndex = 2;
            _cezaSigortaAltSekme = 'sigorta';
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _HtmlColors.surfaceContainer.withValues(alpha: 0.60),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, color: _HtmlColors.tertiary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.turkceMi
                        ? (odenmemisCezaSayisi > 0
                            ? '$odenmemisCezaSayisi ödenmemiş ceza • Sigorta aktif ($sigortaGun gün)'
                            : 'Seyrüsefer & Sigorta Geçerli')
                        : (odenmemisCezaSayisi > 0
                            ? '$odenmemisCezaSayisi unpaid fine(s) • Insurance active ($sigortaGun days)'
                            : 'Road Tax & Insurance Valid'),
                    style: const TextStyle(color: _HtmlColors.secondary, fontSize: 12, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '$sigortaGun ${widget.turkceMi ? "Gün" : "Days"}',
                  style: const TextStyle(color: _HtmlColors.onSurface, fontSize: 12, fontWeight: FontWeight.w800, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Harita HUD yuvarlak buton yardımcısı
  Widget _mapHudButon(IconData ikon) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.30), blurRadius: 8)],
      ),
      child: Icon(ikon, color: _HtmlColors.onSurface, size: 18),
    );
  }

  // --- TAB 1: CEZALAR & SİGORTAM EKRANI (Aylık Resmi İşlemler) ---
  Widget _cezaVeSigortaEkrani({
    required String markaModel,
    required List cezalar,
    required int sigortaGun,
    required int muayeneGun,
    required int ehliyetPuani,
  }) {
    return Column(
      children: [
        // 2'li Büyük ve Belirgin Sekme Değiştirici
        Container(
          margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _HtmlColors.surfaceContainerHigh.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (_cezaSigortaAltSekme != 'ceza') {
                      setState(() => _cezaSigortaAltSekme = 'ceza');
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _cezaSigortaAltSekme == 'ceza' ? _HtmlColors.primaryContainer : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: _cezaSigortaAltSekme == 'ceza'
                          ? [
                              BoxShadow(
                                color: _HtmlColors.primaryContainer.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 20,
                          color: _cezaSigortaAltSekme == 'ceza' ? Colors.white : _HtmlColors.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.turkceMi ? 'Trafik Cezalarım' : 'My Traffic Fines',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: _cezaSigortaAltSekme == 'ceza' ? Colors.white : _HtmlColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (_cezaSigortaAltSekme != 'sigorta') {
                      setState(() => _cezaSigortaAltSekme = 'sigorta');
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _cezaSigortaAltSekme == 'sigorta' ? _HtmlColors.primaryContainer : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: _cezaSigortaAltSekme == 'sigorta'
                          ? [
                              BoxShadow(
                                color: _HtmlColors.primaryContainer.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shield_rounded,
                          size: 20,
                          color: _cezaSigortaAltSekme == 'sigorta' ? Colors.white : _HtmlColors.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.turkceMi ? 'Sigorta & Seyrüsefer' : 'Insurance & Road Tax',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: _cezaSigortaAltSekme == 'sigorta' ? Colors.white : _HtmlColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Seçili Sayfa
        Expanded(
          child: _cezaSigortaAltSekme == 'ceza'
              ? _cezalarimGorunumu(cezalar: cezalar)
              : _sigortaGorunumu(
                  markaModel: markaModel,
                  sigortaGun: sigortaGun,
                  muayeneGun: muayeneGun,
                ),
        ),
      ],
    );
  }

  // ==========================================
  // 👤 KİŞİSEL KULLANICI & SÜRÜCÜ PROFİLİ KOKPİTİ (TESLA & APPLE DİLİ)
  // ==========================================
  Widget _kullaniciProfiliEkrani({
    required int ehliyetPuani,
    required String markaModel,
  }) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      physics: const BouncingScrollPhysics(),
      children: [
        // 1. SÜRÜCÜ PUANI DAİRESEL GÖSTERGE KARTI (Apple & Tesla Kokpit)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF131B2E).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Yeşil Işıltılı Halka Widget'ı
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0F172A),
                  border: Border.all(color: const Color(0xFF10B981), width: 5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.35),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$ehliyetPuani',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            TextSpan(
                              text: ' / 100',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.50),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.turkceMi ? 'Sürücü Puanı' : 'Driver Score',
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Icon(Icons.directions_car_rounded, color: Color(0xFF10B981), size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Kullanıcı Kimliği & Rozet
              Text(
                widget.kullaniciAdi.isNotEmpty ? widget.kullaniciAdi : 'Ahmet Demir',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.verified, color: Color(0xFF10B981), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    widget.kullaniciRolu.isNotEmpty ? widget.kullaniciRolu : 'KKTC Onaylı Sürücü Sicili',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. ARAÇ GARAJIM (Tesla / CarPlay Stili Kayıtlı Araçlar)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.garage_rounded, color: Color(0xFF38BDF8), size: 18),
                const SizedBox(width: 8),
                Text(
                  widget.turkceMi ? 'Araç Garajım' : 'My Vehicles',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: _yeniAracEkleModaliniAc,
              icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: Color(0xFF10B981)),
              label: Text(
                widget.turkceMi ? 'Araç Ekle' : 'Add Car',
                style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Araç Kartı
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF131B2E).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              // Plaka Rozeti
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF0284C7),
                      ),
                      child: const Center(
                        child: Text(
                          '🇨🇾',
                          style: TextStyle(fontSize: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _secilenPlaka.isNotEmpty ? _secilenPlaka : "KY 987",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      markaModel.isNotEmpty ? markaModel : "Tesla Model 3 / BMW",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.turkceMi ? 'Sigorta & Muayene Aktif' : 'Insurance & Inspection OK',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 3. SÜRÜŞ MENÜSÜ & HİZMETLER
        _menuAyarSatiri(
          icon: Icons.history_rounded,
          iconColor: const Color(0xFF38BDF8),
          baslik: widget.turkceMi ? 'Sürüş & Radar Geçmişi' : 'Drive & Radar History',
          subtitle: widget.turkceMi ? 'Son güzergahlar ve kamera kayıtları' : 'Recent routes and camera alerts',
          onTap: () {
            setState(() => _seciliIndex = 1);
          },
        ),
        const SizedBox(height: 8),

        _menuAyarSatiri(
          icon: Icons.qr_code_rounded,
          iconColor: const Color(0xFF10B981),
          baslik: widget.turkceMi ? 'Barkodlu Dijital Sürücü Belgesi' : 'Digital License with Barcode',
          subtitle: widget.turkceMi ? 'Polis kontrolünde geçerli onaylı belge' : 'Valid for official traffic checks',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BarkodluBelgeSayfasi(
                kullanici: widget.kullaniciAdi,
                puan: ehliyetPuani,
                turkceMi: widget.turkceMi,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        _menuAyarSatiri(
          icon: Icons.receipt_long_rounded,
          iconColor: const Color(0xFFA78BFA),
          baslik: widget.turkceMi ? 'Ödemeler & Dekontlarım' : 'Payments & Invoices',
          subtitle: widget.turkceMi ? 'Ödenen seyrüsefer ve ceza makbuzları' : 'Official payment receipts',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DekontlarSayfasi(dekontlar: _dekontlar, turkceMi: widget.turkceMi),
            ),
          ),
        ),
        const SizedBox(height: 8),

        _menuAyarSatiri(
          icon: Icons.security_rounded,
          iconColor: const Color(0xFFF59E0B),
          baslik: widget.turkceMi ? 'Siber Güvenlik & Bildirim Ayarları' : 'Security & Notifications',
          subtitle: widget.turkceMi ? 'Radar yaklaşım sesi, SSL koruması' : 'Speed alerts, sound & SSL security',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BildirimAyarlariSayfasi(turkceMi: widget.turkceMi),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Güvenli Çıkış Yap Butonu
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.12),
              side: BorderSide(color: const Color(0xFFEF4444).withValues(alpha: 0.40)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: widget.onCikisYap,
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 18),
            label: Text(
              widget.turkceMi ? 'Güvenli Çıkış Yap' : 'Secure Sign Out',
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _yeniAracEkleModaliniAc() {
    final plakaCtrl = TextEditingController();
    final modelCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.turkceMi ? 'Yeni Araç Kaydı' : 'Register Vehicle',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.turkceMi ? 'ARAÇ PLAKASI' : 'PLATE NUMBER',
                style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: plakaCtrl,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: widget.turkceMi ? 'Örn: KY 987' : 'E.g. KY 987',
                    hintStyle: const TextStyle(color: Colors.white30),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.turkceMi ? 'MARKA VE MODEL' : 'MAKE & MODEL',
                style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: modelCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: widget.turkceMi ? 'Örn: Tesla Model 3' : 'E.g. Tesla Model 3',
                    hintStyle: const TextStyle(color: Colors.white30),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final plk = plakaCtrl.text.trim().toUpperCase();
                    final mdl = modelCtrl.text.trim();
                    if (plk.isNotEmpty) {
                      setState(() {
                        _secilenPlaka = plk;
                        _aracBilgileriVeritabani[plk] = {
                          "markaModel": mdl.isNotEmpty ? mdl : "Yeni Kayıtlı Araç",
                          "sigortaKalanGun": 365,
                          "muayeneKalanGun": 365,
                          "ehliyetPuani": 100,
                          "sigortaAktif": true,
                          "seyruseferKalanGun": 365,
                          "seyruseferBitisTarihi": "01 Ekim 2027",
                          "seyruseferHarc": "₺3.500,00",
                          "seyruseferHarcMiktar": 3500,
                          "seyruseferDonem": "2026/2. Dönem",
                          "sasiNo": "TRNC-$plk-2026",
                          "motorHacmi": "1600 cc",
                          "cezalar": [],
                        };
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            widget.turkceMi ? '✅ $plk plakalı araç başarıyla eklendi!' : '✅ Vehicle $plk added successfully!',
                          ),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    }
                  },
                  child: Text(
                    widget.turkceMi ? 'Aracı Garaja Ekle' : 'Add Vehicle to Garage',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _menuAyarSatiri({
    required IconData icon,
    required Color iconColor,
    required String baslik,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          baslik,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.50), fontSize: 11),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 14),
      ),
    );
  }

  // _acilButon ve _buyukMenuKarti: İleride menü genişlemesi için rezerve edildi

  String _baslikDondur(int index) {
    if (widget.turkceMi) {
      switch (index) {
        case 0:
          return 'Radar & Canlı Sürüş';
        case 1:
          return 'Yol Tarifi & Akıllı Rota';
        case 2:
          return _cezaSigortaAltSekme == 'ceza' ? 'Trafik Cezalarım' : 'Sigorta & Polis QR';
        case 3:
          return 'Menü & Hizmetler';
        default:
          return 'e-Trafik';
      }
    } else {
      switch (index) {
        case 0:
          return 'Radar & Live Driving';
        case 1:
          return 'Smart Route & Radars';
        case 2:
          return _cezaSigortaAltSekme == 'ceza' ? 'My Traffic Fines' : 'Insurance & Police QR';
        case 3:
          return 'Menu & Services';
        default:
          return 'e-Traffic';
      }
    }
  }
}


// ==========================================
// 🔍 3. MODERN CEZA DETAY SAYFASI
// ==========================================
class CezaDetaySayfasi extends StatelessWidget {
  final Map<String, dynamic> ceza;
  final bool turkceMi;
  final VoidCallback onOdemeYap;

  const CezaDetaySayfasi({
    super.key,
    required this.ceza,
    required this.turkceMi,
    required this.onOdemeYap,
  });

  @override
  Widget build(BuildContext context) {
    bool odendiMi = ceza['odendi'] == true;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          turkceMi ? 'Ceza ve Kanıt Detayı' : 'Violation & Evidence',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kamera / Kanıt Görseli Kartı
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    Image.network(
                      ceza['kanit'],
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 220,
                        color: AppColors.slate200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.camera_alt_outlined, size: 40, color: AppColors.slate500),
                              const SizedBox(height: 8),
                              Text(
                                turkceMi ? 'Radar Kanıt Görseli' : 'Radar Evidence Image',
                                style: const TextStyle(color: AppColors.slate500, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              turkceMi ? 'RADAR / MOBESE KAYDI' : 'SPEED CAMERA RECORD',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Bilgi Kartı
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: odendiMi ? AppColors.successLight : AppColors.dangerLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          odendiMi ? (turkceMi ? 'ÖDENDİ' : 'PAID') : (turkceMi ? 'ÖDENMEDİ' : 'UNPAID'),
                          style: TextStyle(
                            color: odendiMi ? AppColors.success : AppColors.danger,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        ceza['tutar'],
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    turkceMi ? ceza['tur'] : ceza['turEn'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.slate900),
                  ),
                  const Divider(height: 28, color: AppColors.slate200),
                  _detaySatiri(turkceMi ? 'İhlal Tarihi' : 'Date', ceza['tarih']),
                  _detaySatiri(turkceMi ? 'Konum' : 'Location', ceza['konum']),
                  _detaySatiri(turkceMi ? 'Ceza Puanı Etkisi' : 'Penalty Points', ceza['puan']),
                  _detaySatiri(turkceMi ? 'Yetkili Birim' : 'Enforcing Unit', ceza['polis']),
                  _detaySatiri(turkceMi ? 'Kategori' : 'Category', ceza['kategori']),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Ödeme Butonu
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: odendiMi ? AppColors.success : AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: odendiMi
                    ? null
                    : () {
                        onOdemeYap();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    turkceMi
                                        ? 'Ödeme simülasyonu başarılı! Dekontlar sayfasına makbuz eklendi.'
                                        : 'Payment completed! Receipt added to your records.',
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                        Navigator.pop(context);
                      },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(odendiMi ? Icons.check_circle_rounded : Icons.credit_card_rounded),
                    const SizedBox(width: 8),
                    Text(
                      odendiMi
                          ? (turkceMi ? 'Bu Ceza Ödenmiş' : 'This Fine is Paid')
                          : (turkceMi ? 'Şimdi Öde (Kart ile Simülasyon)' : 'Pay Now (Card Simulation)'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detaySatiri(String baslik, String deger) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: const TextStyle(fontSize: 13, color: AppColors.slate500)),
          Text(deger, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.slate900)),
        ],
      ),
    );
  }
}

// ==========================================
// 🆔 4. MODERN BARKODLU SÜRÜCÜ BELGESİ & ÇALIŞIR QR
// ==========================================
class BarkodluBelgeSayfasi extends StatefulWidget {
  final String kullanici;
  final int puan;
  final bool turkceMi;

  const BarkodluBelgeSayfasi({super.key, required this.kullanici, required this.puan, required this.turkceMi});

  @override
  State<BarkodluBelgeSayfasi> createState() => _BarkodluBelgeSayfasiState();
}

class _BarkodluBelgeSayfasiState extends State<BarkodluBelgeSayfasi> {
  bool _qrTaraniyor = false;

  void _qriDogrula() {
    setState(() {
      _qrTaraniyor = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _qrTaraniyor = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                const Icon(Icons.verified_rounded, color: AppColors.success, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.turkceMi ? 'Resmi Doğrulama Başarılı' : 'Verification Successful',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            content: Text(
              widget.turkceMi
                  ? 'Bu belge KKTC Polis Genel Müdürlüğü merkezi veri tabanında resmi olarak doğrulanmıştır. Ehliyet puanı ve kayıt durumu onaylıdır.'
                  : 'This certificate has been officially validated in the TRNC Police Headquarters central database.',
              style: const TextStyle(fontSize: 13, color: AppColors.slate700),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(widget.turkceMi ? 'Tamam' : 'OK', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.turkceMi ? 'Resmi Sürücü Belgesi' : 'Official Driver Certificate',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22.0),
          child: Container(
            padding: const EdgeInsets.all(26.0),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.slate200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 40),
                ),
                const SizedBox(height: 14),
                const Text(
                  'KUZEY KIBRIS TÜRK CUMHURİYETİ',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.slate500, letterSpacing: 1),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.turkceMi ? 'Polis Genel Müdürlüğü Trafik Belgesi' : 'Police Traffic Certification',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.slate900),
                  textAlign: TextAlign.center,
                ),
                const Divider(height: 32, color: AppColors.slate200),

                _bilgiSatiri(widget.turkceMi ? 'Ad Soyad' : 'Full Name', widget.kullanici),
                _bilgiSatiri(widget.turkceMi ? 'Sürücü Puanı' : 'Driver Score', '${widget.puan} / 100'),
                _bilgiSatiri(widget.turkceMi ? 'Belge Durumu' : 'Status', widget.turkceMi ? 'Aktif / Geçerli' : 'Active / Valid'),
                const SizedBox(height: 24),

                // ÇALIŞIR QR KOD
                GestureDetector(
                  onTap: _qriDogrula,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Column(
                      children: [
                        _qrTaraniyor
                            ? const SizedBox(
                                height: 110,
                                width: 110,
                                child: Center(
                                  child: CircularProgressIndicator(color: AppColors.primary),
                                ),
                              )
                            : const Icon(Icons.qr_code_2_rounded, size: 110, color: AppColors.slate900),
                        const SizedBox(height: 8),
                        Text(
                          widget.turkceMi ? '🔍 Doğrulamak için QR Koda Dokunun' : '🔍 Tap QR to Verify Online',
                          style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Barkod No: KKTC-TR-2026-99182',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: AppColors.slate500,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bilgiSatiri(String baslik, String deger) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: const TextStyle(fontSize: 13, color: AppColors.slate500)),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                deger,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.slate900),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 🧾 5. RESMİ ÖDEME DEKONTU SAYFALARI
// ==========================================
class DekontlarSayfasi extends StatelessWidget {
  final List<Map<String, String>> dekontlar;
  final bool turkceMi;

  const DekontlarSayfasi({super.key, required this.dekontlar, required this.turkceMi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          turkceMi ? 'Ödeme Dekontları' : 'Payment Receipts',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: dekontlar.length,
        itemBuilder: (context, index) {
          var dekont = dekontlar[index];
          String islemAdi = turkceMi ? dekont['islem']! : (dekont['islemEn'] ?? dekont['islem']!);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.slate200),
              ),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.receipt_long_rounded, color: AppColors.success, size: 24),
              ),
              title: Text(islemAdi, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.slate900)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Row(
                  children: [
                    Text(
                      '${turkceMi ? 'Tarih' : 'Date'}: ${dekont['tarih']}',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.slate500),
                    ),
                    const SizedBox(width: 5),
                    const Text('•', style: TextStyle(fontSize: 10, color: AppColors.slate400)),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.slate200),
                        ),
                        child: Text(
                          dekont['kod']!,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              trailing: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  dekont['tutar']!,
                  style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.success, fontSize: 15),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DekontDetaySayfasi(dekont: dekont, turkceMi: turkceMi),
                  ),
                );
              },
            ),
          ),
        );
        },
      ),
    );
  }
}

class DekontDetaySayfasi extends StatelessWidget {
  final Map<String, String> dekont;
  final bool turkceMi;

  const DekontDetaySayfasi({super.key, required this.dekont, required this.turkceMi});

  @override
  Widget build(BuildContext context) {
    String islemAdi = turkceMi ? dekont['islem']! : (dekont['islemEn'] ?? dekont['islem']!);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          turkceMi ? 'Resmi Ödeme Makbuzu' : 'Official Payment Receipt',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.all(26.0),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.slate200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.account_balance_rounded, color: AppColors.primary, size: 36),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        turkceMi ? 'ONAYLANDI / TAHSİL EDİLDİ' : 'APPROVED & COLLECTED',
                        style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w800, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'KUZEY KIBRIS TÜRK CUMHURİYETİ',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.slate500, letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                Text(
                  turkceMi ? 'Maliye Bakanlığı Elektronik Tahsilat Makbuzu' : 'Ministry of Finance Electronic Receipt',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.slate900),
                ),
                const Divider(height: 32, color: AppColors.slate200),
                _dekontSatiri(turkceMi ? 'İşlem Türü' : 'Type', islemAdi),
                _dekontSatiri(turkceMi ? 'İşlem Kodu' : 'Ref Code', dekont['kod']!),
                _dekontSatiri(turkceMi ? 'İşlem Tarihi' : 'Date', dekont['tarih']!),
                _dekontSatiri(turkceMi ? 'İlgili Kurum' : 'Authority', dekont['kurum'] ?? 'KKTC Maliye Bakanlığı'),
                _dekontSatiri(turkceMi ? 'Durum' : 'Status', dekont['durum'] ?? 'Başarılı'),
                const Divider(height: 32, color: AppColors.slate200),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      turkceMi ? 'Tahsil Edilen Tutar' : 'Collected Amount',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.slate700),
                    ),
                    Text(
                      dekont['tutar']!,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.qr_code_rounded, size: 70, color: AppColors.slate900),
                      const SizedBox(height: 6),
                      Text(
                        turkceMi ? 'Resmi e-Devlet Doğrulama Kodu' : 'Official e-Government Verification Code',
                        style: const TextStyle(fontSize: 10, color: AppColors.slate400, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dekontSatiri(String baslik, String deger) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: const TextStyle(fontSize: 13, color: AppColors.slate500)),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                deger,
                style: TextStyle(
                  fontFamily: deger.contains('-') || deger.contains('#') ? 'monospace' : null,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate900,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// ⚖️ 6. İTİRAZ VE BİLDİRİM SAYFALARI
// ==========================================
class ItirazSayfasi extends StatelessWidget {
  final bool turkceMi;
  const ItirazSayfasi({super.key, required this.turkceMi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          turkceMi ? 'Cezaya İtiraz Dilekçesi' : 'Fine Appeal Form',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              turkceMi ? 'Resmi İtiraz Başvuru Formu' : 'Official Appeal Form',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.slate900),
            ),
            const SizedBox(height: 6),
            Text(
              turkceMi
                  ? 'Plaka veya ceza tutanağında hata olduğunu düşünüyorsanız, gerekçenizi belirterek KKTC Trafik Dairesi Hakem Kurulu\'na başvurabilirsiniz.'
                  : 'If you think there is an error in the issued fine, explain your reasoning to submit to the Arbitration Board.',
              style: const TextStyle(fontSize: 13, color: AppColors.slate500),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Column(
                children: [
                  TextField(
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: turkceMi
                          ? 'İtiraz gerekçenizi ve olayın detaylarını detaylıca buraya yazın...'
                          : 'Describe your objection and the details of the incident...',
                      hintStyle: const TextStyle(color: AppColors.slate400, fontSize: 14),
                      filled: true,
                      fillColor: AppColors.surfaceMuted,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    turkceMi
                                        ? 'İtiraz başvurunuz alındı. Dosya No: KKTC-ITR-9921'
                                        : 'Your appeal has been submitted. Case No: KKTC-ITR-9921',
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      },
                      child: Text(
                        turkceMi ? 'Dilekçeyi Gönder' : 'Submit Petition',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BildirimAyarlariSayfasi extends StatefulWidget {
  final bool turkceMi;
  const BildirimAyarlariSayfasi({super.key, required this.turkceMi});

  @override
  State<BildirimAyarlariSayfasi> createState() => _BildirimAyarlariSayfasiState();
}

class _BildirimAyarlariSayfasiState extends State<BildirimAyarlariSayfasi> {
  bool sigorta = true;
  bool muayene = true;
  bool radar = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.turkceMi ? 'Bildirim Ayarları' : 'Notification Preferences',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  activeThumbColor: AppColors.primary,
                  title: Text(widget.turkceMi ? 'Sigorta Hatırlatıcısı' : 'Insurance Reminders', style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(widget.turkceMi ? 'Poliçe bitimine 15 gün kala uyar' : 'Alert 15 days before expiration', style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
                  value: sigorta,
                  onChanged: (v) => setState(() => sigorta = v),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.slate200),
                SwitchListTile(
                  activeThumbColor: AppColors.primary,
                  title: Text(widget.turkceMi ? 'Muayene Hatırlatıcısı' : 'Inspection Reminders', style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(widget.turkceMi ? 'Muayene süresi yaklaştığında uyar' : 'Alert when vehicle inspection is due', style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
                  value: muayene,
                  onChanged: (v) => setState(() => muayene = v),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.slate200),
                SwitchListTile(
                  activeThumbColor: AppColors.primary,
                  title: Text(widget.turkceMi ? 'Yeni Ceza Uyarıları' : 'New Violation Alerts', style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(widget.turkceMi ? 'Plakaya radar veya ceza yazıldığında anında SMS ve bildirim' : 'Instant notification on new tickets', style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
                  value: radar,
                  onChanged: (v) => setState(() => radar = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PolisQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    canvas.scale(scale, scale);

    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(const Rect.fromLTWH(0, 0, 100, 100), bgPaint);

    final darkPaint = Paint()..color = const Color(0xFF0A122A);
    final whitePaint = Paint()..color = Colors.white;
    final redPaint = Paint()..color = const Color(0xFFD90429);

    // Finder Eye 1 (Top-Left)
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(10, 10, 28, 28), const Radius.circular(4)), darkPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(15, 15, 18, 18), const Radius.circular(2)), whitePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(19, 19, 10, 10), const Radius.circular(1)), darkPaint);

    // Finder Eye 2 (Top-Right)
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(62, 10, 28, 28), const Radius.circular(4)), darkPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(67, 15, 18, 18), const Radius.circular(2)), whitePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(71, 19, 10, 10), const Radius.circular(1)), darkPaint);

    // Finder Eye 3 (Bottom-Left)
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(10, 62, 28, 28), const Radius.circular(4)), darkPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(15, 67, 18, 18), const Radius.circular(2)), whitePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(19, 71, 10, 10), const Radius.circular(1)), darkPaint);

    // Matrix dots & patterns
    canvas.drawRect(const Rect.fromLTWH(44, 12, 6, 6), darkPaint);
    canvas.drawRect(const Rect.fromLTWH(52, 18, 6, 6), darkPaint);
    canvas.drawRect(const Rect.fromLTWH(44, 24, 6, 6), darkPaint);

    canvas.drawRect(const Rect.fromLTWH(14, 44, 6, 6), darkPaint);
    canvas.drawRect(const Rect.fromLTWH(22, 48, 6, 6), darkPaint);
    canvas.drawRect(const Rect.fromLTWH(32, 44, 6, 6), darkPaint);

    // Center Red TRNC security chip
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(44, 44, 12, 12), const Radius.circular(2)), redPaint);
    canvas.drawRect(const Rect.fromLTWH(47, 47, 6, 6), whitePaint);

    canvas.drawRect(const Rect.fromLTWH(62, 44, 6, 6), darkPaint);
    canvas.drawRect(const Rect.fromLTWH(74, 48, 6, 6), darkPaint);
    canvas.drawRect(const Rect.fromLTWH(84, 44, 6, 6), darkPaint);

    canvas.drawRect(const Rect.fromLTWH(44, 62, 6, 6), darkPaint);
    canvas.drawRect(const Rect.fromLTWH(52, 70, 6, 6), darkPaint);
    canvas.drawRect(const Rect.fromLTWH(44, 80, 6, 6), darkPaint);

    canvas.drawRect(const Rect.fromLTWH(62, 62, 6, 6), darkPaint);
    canvas.drawRect(const Rect.fromLTWH(74, 66, 8, 8), darkPaint);
    canvas.drawRect(const Rect.fromLTWH(66, 78, 8, 8), darkPaint);
    canvas.drawRect(const Rect.fromLTWH(80, 80, 6, 6), darkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _KibrisWatermarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;

    final scaleX = size.width / 200.0;
    final scaleY = size.height / 120.0;
    canvas.scale(scaleX, scaleY);

    final path = Path()
      ..moveTo(20, 60)
      ..quadraticBezierTo(50, 30, 90, 45)
      ..quadraticBezierTo(130, 60, 160, 25)
      ..quadraticBezierTo(185, 50, 170, 75)
      ..quadraticBezierTo(140, 80, 110, 85)
      ..quadraticBezierTo(60, 95, 20, 60)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
