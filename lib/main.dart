import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'radar_haritasi.dart';

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
// ğŸ¨ MODERN DESIGN TOKENS & THEME
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
  bool _turkceMi = true;
  bool _girisYapildiMi = false;
  String _kullaniciAdi = "";
  List<String> _araclar = [];

  void _dilDegistir(bool turkceMi) {
    setState(() {
      _turkceMi = turkceMi;
    });
  }

  void _girisYapBasarili(String adSoyad, List<String> araclar) {
    setState(() {
      _girisYapildiMi = true;
      _kullaniciAdi = adSoyad;
      _araclar = araclar;
    });
  }

  void _cikisYap() {
    setState(() {
      _girisYapildiMi = false;
      _kullaniciAdi = "";
      _araclar = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KKTC e-Trafik',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
          surfaceTint: Colors.transparent,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.slate900,
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.slate200, width: 1),
          ),
        ),
      ),
      home: _girisYapildiMi
          ? AnaSayfaTabs(
              kullaniciAdi: _kullaniciAdi,
              araclar: _araclar,
              turkceMi: _turkceMi,
              onDilDegistir: _dilDegistir,
              onCikisYap: _cikisYap,
            )
          : GirisSayfasi(
              turkceMi: _turkceMi,
              onDilDegistir: _dilDegistir,
              onGirisBasarili: _girisYapBasarili,
            ),
    );
  }
}

// ==========================================
// ğŸš€ 1. MODERN GÄ°RÄ°Å SAYFASI (HTML TasarÄ±m Uyumu)
// ==========================================

// Design tokens â€” HTML renk paletine birebir eÅŸleÅŸtirildi
class _HtmlColors {
  static const Color background = Color(0xFF0A122A);
  static const Color surfaceContainer = Color(0xFF171E37);
  static const Color surfaceContainerLow = Color(0xFF131A33);
  static const Color surfaceContainerHigh = Color(0xFF212942);
  static const Color surfaceBright = Color(0xFF313852);
  static const Color primaryContainer = Color(0xFFD90429); // kÄ±rmÄ±zÄ± buton
  static const Color primary = Color(0xFFFFB3AF);
  static const Color secondary = Color(0xFFBDC5E9);
  static const Color tertiary = Color(0xFF4EDEA3);
  static const Color onSurface = Color(0xFFDBE1FF);
  static const Color surfaceContainerLowest = Color(0xFF050D25);
  static const Color surfaceContainerHighest = Color(0xFF2C344D);
  static const Color tertiaryContainer = Color(0xFF007C55);
  static const Color tertiaryFixed = Color(0xFF6FFBBE);
  static const Color onTertiary = Color(0xFF003824);
  static const Color onTertiaryContainer = Color(0xFFB4FFD7);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color primaryFixed = Color(0xFFFFDAD7);
  static const Color primaryFixedDim = Color(0xFFFFB3AF);
  static const Color onPrimary = Color(0xFF68000E);
  static const Color onPrimaryContainer = Color(0xFFFFEAE8);
  static const Color onSurfaceVariant = Color(0xFFE7BCBA);
  static const Color outlineVariant = Color(0xFF5D3F3D);
}

class GirisSayfasi extends StatefulWidget {
  final bool turkceMi;
  final Function(bool) onDilDegistir;
  final Function(String, List<String>) onGirisBasarili;

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
  final TextEditingController _girisController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();
  bool _kktcVatandasiMi = true;
  bool _sifreGizli = true;
  bool _biyometrikYukleniyor = false;
  bool _biyometrikBasarili = false;
  bool _girisYukleniyor = false;
  bool _girisBasariliAnimasyon = false;
  // Auth method: 0 = Kimlik&Åifre, 1 = SMS
  int _authMethod = 0;

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
    _pingController.dispose();
    super.dispose();
  }

  void _girisYap() {
    String numara = _girisController.text.trim();
    String sifre = _sifreController.text.trim();

    if (numara.isEmpty || sifre.isEmpty) {
      _snack(
        widget.turkceMi
            ? 'LÃ¼tfen kimlik no ve ÅŸifre girin.'
            : 'Please enter credentials to proceed.',
        isError: true,
      );
      return;
    }

    setState(() => _girisYukleniyor = true);

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;

      List<String> tanimliAraclar = [];
      String adSoyad = "";

      if (!_kktcVatandasiMi) {
        if (numara.toLowerCase() == "tubi" && sifre == "tugkan3517") {
          adSoyad = widget.turkceMi ? "Tubi (Ã–ÄŸrenci)" : "Tubi (Student)";
          tanimliAraclar = ["ST 999", "GM 202"];
        } else {
          setState(() {
            _girisYukleniyor = false;
          });
          _snack(
            widget.turkceMi
                ? 'HatalÄ± Ã¶ÄŸrenci adÄ± veya ÅŸifre! (tubi / tugkan3517)'
                : 'Invalid student username or password!',
            isError: true,
          );
          return;
        }
      } else {
        adSoyad = widget.turkceMi ? "Ahmet Demir" : "Ahmet Demir (Citizen)";
        tanimliAraclar = ["RZ 123", "LZ 555"];
      }

      setState(() {
        _girisYukleniyor = false;
        _girisBasariliAnimasyon = true;
      });

      Future.delayed(const Duration(milliseconds: 600), () {
        widget.onGirisBasarili(adSoyad, tanimliAraclar);
      });
    });
  }

  void _hizliDemoGiris(bool ogrenci) {
    setState(() {
      _kktcVatandasiMi = !ogrenci;
      if (ogrenci) {
        _girisController.text = "tubi";
        _sifreController.text = "tugkan3517";
      } else {
        _girisController.text = "123456789";
        _sifreController.text = "123456";
      }
    });
    _girisYap();
  }

  void _biyometrikGiris() async {
    setState(() {
      _biyometrikYukleniyor = true;
      _biyometrikBasarili = false;
    });
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _biyometrikYukleniyor = false;
      _biyometrikBasarili = true;
      _girisController.text = '21894019284';
      _sifreController.text = 'â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢';
    });
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _biyometrikBasarili = false);
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
        backgroundColor: isError ? const Color(0xFF93000A) : const Color(0xFF007C55),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _HtmlColors.background,
      body: Stack(
        children: [
          // â”€â”€ Ambient glow orbs (HTML'e birebir) â”€â”€
          Positioned(
            top: -96,
            left: -80,
            child: Container(
              width: 288,
              height: 288,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _HtmlColors.primaryContainer.withValues(alpha: 0.20),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.33,
            right: -96,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _HtmlColors.surfaceBright.withValues(alpha: 0.25),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: MediaQuery.of(context).size.width * 0.25,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF007C55).withValues(alpha: 0.15),
              ),
            ),
          ),

          // â”€â”€ Main content â”€â”€
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // â”€â”€ Top Bar â”€â”€
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Active network pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _HtmlColors.surfaceContainerHigh.withValues(alpha: 0.80),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Animated ping dot
                              AnimatedBuilder(
                                animation: _pingController,
                                builder: (ctx, child) {
                                  final s = 0.7 + 0.3 * (1 - _pingController.value);
                                  return Transform.scale(
                                    scale: s,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _HtmlColors.tertiary.withValues(
                                          alpha: 0.5 + 0.5 * (1 - _pingController.value),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.turkceMi ? 'KKTC Kamu AÄŸÄ± Aktif' : 'TRNC Network Active',
                                style: const TextStyle(
                                  color: _HtmlColors.tertiary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // TR / EN Toggle
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _HtmlColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(100),
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
                  ),

                  // â”€â”€ Institutional Crest & Branding â”€â”€
                  Center(
                    child: Column(
                      children: [
                        // Shield avatar
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: _HtmlColors.surfaceContainerHigh.withValues(alpha: 0.90),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.35),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Gradient overlay
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: LinearGradient(
                                        colors: [
                                          _HtmlColors.primaryContainer.withValues(alpha: 0.20),
                                          Colors.transparent,
                                          _HtmlColors.surfaceBright.withValues(alpha: 0.30),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                  ),
                                  const Center(
                                    child: Icon(
                                      Icons.shield_outlined,
                                      size: 40,
                                      color: _HtmlColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Verified badge
                            Positioned(
                              right: -4,
                              bottom: -4,
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF007C55),
                                  border: Border.all(color: _HtmlColors.background, width: 2),
                                ),
                                child: const Icon(
                                  Icons.verified,
                                  size: 12,
                                  color: Color(0xFFB4FFD7),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Sub-label
                        Text(
                          widget.turkceMi ? 'KKTC RESMÄ° GEÃ‡Ä°T' : 'TRNC OFFICIAL PORTAL',
                          style: const TextStyle(
                            color: _HtmlColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.turkceMi ? 'KKTC e-Trafik' : 'TRNC e-Traffic',
                          style: const TextStyle(
                            color: _HtmlColors.onSurface,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.turkceMi
                              ? 'KKTC Polis Genel MÃ¼dÃ¼rlÃ¼ÄŸÃ¼ & BayÄ±ndÄ±rlÄ±k ve\nUlaÅŸtÄ±rma BakanlÄ±ÄŸÄ± Trafik PortalÄ±'
                              : 'TRNC Police HQ & Ministry of Public Works\nand Transportation Traffic Portal',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: _HtmlColors.secondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // â”€â”€ Role Selector Tabs â”€â”€
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _HtmlColors.surfaceContainerLow.withValues(alpha: 0.80),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        _roleTab(
                          icon: Icons.badge,
                          label: widget.turkceMi ? 'KKTC VatandaÅŸ' : 'TRNC Citizen',
                          selected: _kktcVatandasiMi,
                          onTap: () => setState(() => _kktcVatandasiMi = true),
                        ),
                        _roleTab(
                          icon: Icons.school,
                          label: widget.turkceMi ? 'Ã–ÄŸrenci / Misafir' : 'Student / Guest',
                          selected: !_kktcVatandasiMi,
                          onTap: () => setState(() => _kktcVatandasiMi = false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // â”€â”€ Authentication Form Card (glassmorphism) â”€â”€
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _HtmlColors.surfaceContainer.withValues(alpha: 0.70),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _HtmlColors.outlineVariant.withValues(alpha: 0.5),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.30),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Auth method sub-tabs
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _HtmlColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              _authMethodTab(
                                icon: Icons.pin,
                                label: widget.turkceMi ? 'Kimlik & Åifre' : 'ID & Password',
                                selected: _authMethod == 0,
                                onTap: () => setState(() => _authMethod = 0),
                              ),
                              _authMethodTab(
                                icon: Icons.sms,
                                label: widget.turkceMi ? 'SMS / Mobil Ä°mza' : 'SMS / Mobile Sign',
                                selected: _authMethod == 1,
                                onTap: () => setState(() => _authMethod = 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ID Field Label
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.turkceMi
                                  ? (_kktcVatandasiMi ? 'KKTC KÄ°MLÄ°K NO' : 'PASAPORT / Ã–ÄRENCÄ° NO')
                                  : (_kktcVatandasiMi ? 'TRNC IDENTITY NO' : 'PASSPORT / STUDENT NO'),
                              style: const TextStyle(
                                color: _HtmlColors.secondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                            Text(
                              widget.turkceMi ? 'ZORUNLU' : 'REQUIRED',
                              style: const TextStyle(
                                color: _HtmlColors.onSurfaceVariant,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // ID Input
                        _darkInputField(
                          controller: _girisController,
                          hint: _kktcVatandasiMi
                              ? (widget.turkceMi ? 'Ã–rn: 123456 (KKTC Kimlik No)' : 'E.g.: 123456')
                              : (widget.turkceMi ? 'U12345678 (Pasaport / Ã–ÄŸrenci No)' : 'U12345678'),
                          prefixIcon: Icons.person,
                          obscure: false,
                        ),
                        const SizedBox(height: 14),

                        // Password Label
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.turkceMi ? 'PORTAL ÅÄ°FRESÄ° / PIN' : 'PORTAL PASSWORD / PIN',
                              style: const TextStyle(
                                color: _HtmlColors.secondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                            Text(
                              widget.turkceMi ? 'SMS ile Åifre Al' : 'Get SMS Code',
                              style: const TextStyle(
                                color: _HtmlColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Password Input
                        _darkInputField(
                          controller: _sifreController,
                          hint: 'â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢',
                          prefixIcon: Icons.lock,
                          obscure: _sifreGizli,
                          suffixIcon: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              _sifreGizli ? Icons.visibility : Icons.visibility_off,
                              color: _HtmlColors.secondary,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _sifreGizli = !_sifreGizli),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // â”€â”€ Primary Login Button (Gradient Red) â”€â”€
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: _girisBasariliAnimasyon
                                  ? null
                                  : const LinearGradient(
                                      colors: [
                                        Color(0xFFD90429),
                                        Color(0xFFDC2626),
                                        Color(0xFF930018),
                                      ],
                                    ),
                              color: _girisBasariliAnimasyon ? const Color(0xFF007C55) : null,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD90429).withValues(alpha: 0.50),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                  spreadRadius: -4,
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: _girisYukleniyor ? null : _girisYap,
                              child: _girisYukleniyor
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _girisBasariliAnimasyon ? Icons.lock_open : Icons.login,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _girisBasariliAnimasyon
                                              ? (widget.turkceMi ? 'GiriÅŸ BaÅŸarÄ±lÄ±' : 'Login Successful')
                                              : (widget.turkceMi ? 'GÃ¼venli GiriÅŸ Yap' : 'Secure Login'),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // â”€â”€ Biometric / Face ID Button â”€â”€
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: _HtmlColors.surfaceContainerHigh.withValues(alpha: 0.60),
                              side: BorderSide(
                                color: _HtmlColors.outlineVariant.withValues(alpha: 0.5),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _biyometrikYukleniyor ? null : _biyometrikGiris,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_biyometrikYukleniyor)
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: _HtmlColors.primary,
                                    ),
                                  )
                                else
                                  Icon(
                                    _biyometrikBasarili ? Icons.check_circle : Icons.face,
                                    color: _biyometrikBasarili ? _HtmlColors.tertiary : _HtmlColors.primary,
                                    size: 22,
                                  ),
                                const SizedBox(width: 8),
                                Text(
                                  _biyometrikYukleniyor
                                      ? (widget.turkceMi ? 'Kimlik DoÄŸrulanÄ±yor...' : 'Verifying...')
                                      : _biyometrikBasarili
                                          ? (widget.turkceMi ? 'Biyometri DoÄŸrulandÄ±' : 'Biometrics Verified')
                                          : (widget.turkceMi ? 'YÃ¼z TanÄ±ma (Face ID) ile GiriÅŸ' : 'Login with Face ID'),
                                  style: TextStyle(
                                    color: _biyometrikBasarili ? _HtmlColors.tertiary : _HtmlColors.onSurface,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // â”€â”€ Demo Preset Cards â”€â”€
                  Row(
                    children: [
                      const Icon(Icons.touch_app, color: _HtmlColors.tertiary, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        widget.turkceMi ? 'HIZLI TEST & DEMO SÄ°MÃœLATÃ–RÃœ' : 'QUICK DEMO SIMULATOR',
                        style: const TextStyle(
                          color: _HtmlColors.secondary,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Demo Card â€” Ahmet Demir
                  _demoCard(
                    icon: Icons.directions_car,
                    name: 'Ahmet Demir',
                    badge: widget.turkceMi ? 'VatandaÅŸ' : 'Citizen',
                    subtitle: 'BMW 3.20i & Mercedes E220d (Aktif KoÃ§an)',
                    iconBg: _HtmlColors.primaryContainer.withValues(alpha: 0.20),
                    iconColor: _HtmlColors.primary,
                    badgeBg: _HtmlColors.surfaceBright,
                    badgeColor: _HtmlColors.secondary,
                    onTap: () => _hizliDemoGiris(false),
                  ),
                  const SizedBox(height: 8),

                  // Demo Card â€” Tubi
                  _demoCard(
                    icon: Icons.school,
                    name: widget.turkceMi ? 'Tubi Ã–ÄŸrenci Profili' : 'Tubi Student Profile',
                    badge: widget.turkceMi ? 'Misafir Ä°zin' : 'Guest Access',
                    subtitle: 'VW Polo & Toyota Corolla (GeÃ§ici KayÄ±t)',
                    iconBg: const Color(0xFF007C55).withValues(alpha: 0.20),
                    iconColor: _HtmlColors.tertiary,
                    badgeBg: const Color(0xFF007C55).withValues(alpha: 0.30),
                    badgeColor: _HtmlColors.tertiary,
                    onTap: () => _hizliDemoGiris(true),
                  ),
                  const SizedBox(height: 24),

                  // â”€â”€ Security Footer â”€â”€
                  Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_outline, color: _HtmlColors.tertiary, size: 14),
                            SizedBox(width: 6),
                            Text(
                              '256-Bit SSL UÃ§tan Uca Åifreleme',
                              style: TextStyle(
                                color: _HtmlColors.secondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'KKTC Polis Genel MÃ¼dÃ¼rlÃ¼ÄŸÃ¼ & BayÄ±ndÄ±rlÄ±k\nve UlaÅŸtÄ±rma BakanlÄ±ÄŸÄ± Trafik PortalÄ±',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _HtmlColors.secondary,
                            fontSize: 10,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.turkceMi ? 'YardÄ±m MasasÄ±' : 'Help Desk',
                              style: const TextStyle(
                                color: _HtmlColors.secondary,
                                fontSize: 11,
                                decoration: TextDecoration.underline,
                                decorationColor: _HtmlColors.secondary,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('â€¢', style: TextStyle(color: _HtmlColors.outlineVariant)),
                            ),
                            Text(
                              widget.turkceMi ? 'Trafik Ã‡aÄŸrÄ±: 155' : 'Traffic Hotline: 155',
                              style: const TextStyle(
                                color: _HtmlColors.secondary,
                                fontSize: 11,
                                decoration: TextDecoration.underline,
                                decorationColor: _HtmlColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
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

  // â”€â”€ Helper widgets â”€â”€

  Widget _langButton(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? _HtmlColors.surfaceBright : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? _HtmlColors.onSurface : _HtmlColors.secondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _roleTab({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? _HtmlColors.surfaceContainerHigh : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.20),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? _HtmlColors.primary : _HtmlColors.secondary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? _HtmlColors.onSurface : _HtmlColors.secondary,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _authMethodTab({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? _HtmlColors.surfaceContainerHigh : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: selected ? _HtmlColors.primary : _HtmlColors.secondary,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? _HtmlColors.onSurface : _HtmlColors.secondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _darkInputField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    required bool obscure,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _HtmlColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 8,
            spreadRadius: -2,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(
          color: _HtmlColors.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'monospace',
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: _HtmlColors.secondary.withValues(alpha: 0.60),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(prefixIcon, color: _HtmlColors.secondary, size: 20),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _HtmlColors.primaryContainer.withValues(alpha: 0.70),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _demoCard({
    required IconData icon,
    required String name,
    required String badge,
    required String subtitle,
    required Color iconBg,
    required Color iconColor,
    required Color badgeBg,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _HtmlColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _HtmlColors.outlineVariant.withValues(alpha: 0.30),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: _HtmlColors.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            color: badgeColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _HtmlColors.secondary,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.bolt, color: _HtmlColors.secondary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// ğŸ  2. MODERN ANA SAYFA & TABS
// ==========================================
class AnaSayfaTabs extends StatefulWidget {
  final String kullaniciAdi;
  final List<String> araclar;
  final bool turkceMi;
  final Function(bool) onDilDegistir;
  final VoidCallback onCikisYap;

  const AnaSayfaTabs({
    super.key,
    required this.kullaniciAdi,
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
  }

  @override
  void dispose() {
    _pingController.dispose();
    super.dispose();
  }
  final Map<String, Map<String, dynamic>> _aracBilgileriVeritabani = {
    "RZ 123": {
      "markaModel": "BMW 3.20i (2022)",
      "sigortaKalanGun": 45,
      "muayeneKalanGun": 120,
      "ehliyetPuani": 85,
      "sigortaAktif": true,
      "cezalar": [
        {
          "id": "1",
          "tarih": "15.05.2026",
          "tur": "HÄ±z SÄ±nÄ±rÄ± AÅŸÄ±mÄ± (Radar)",
          "turEn": "Speed Limit Violation (Radar)",
          "kategori": "HÄ±z",
          "tutar": "2450 TL",
          "odendi": false,
          "konum": "LefkoÅŸa - GÃ¼zelyurt Anayolu",
          "puan": "10 Ceza PuanÄ±",
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
      "cezalar": []
    },
    "ST 999": {
      "markaModel": "Volkswagen Polo (2021)",
      "sigortaKalanGun": 4,
      "muayeneKalanGun": 5,
      "ehliyetPuani": 70,
      "sigortaAktif": false,
      "cezalar": [
        {
          "id": "2",
          "tarih": "20.04.2026",
          "tur": "Muayenesiz AraÃ§ KullanÄ±mÄ±",
          "turEn": "Driving Uninspected Vehicle",
          "kategori": "Evrak",
          "tutar": "1850 TL",
          "odendi": false,
          "konum": "GÃ¼zelyurt KalkanlÄ± Yolu",
          "puan": "5 Ceza PuanÄ±",
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
      "cezalar": []
    },
  };

  final List<Map<String, String>> _dekontlar = [
    {
      "islem": "YanlÄ±ÅŸ Park CezasÄ± Ã–demesi",
      "islemEn": "Illegal Parking Fine Payment",
      "tarih": "10.02.2026",
      "tutar": "1200 TL",
      "kod": "DEKONT-99821",
      "kurum": "KKTC Maliye BakanlÄ±ÄŸÄ± Veznesi",
      "durum": "OnaylandÄ± / BaÅŸarÄ±lÄ±"
    },
  ];

  void _sigortaYenile(String plaka) {
    setState(() {
      if (_aracBilgileriVeritabani.containsKey(plaka)) {
        _aracBilgileriVeritabani[plaka]!['sigortaKalanGun'] = 365;
        _aracBilgileriVeritabani[plaka]!['sigortaAktif'] = true;
      }
      _dekontlar.insert(0, {
        "islem": "$plaka Nolu AraÃ§ Zorunlu Sigorta Yenileme",
        "islemEn": "$plaka Vehicle Mandatory Insurance Renewal",
        "tarih": "BugÃ¼n / Today",
        "tutar": "4500 TL",
        "kod": "SIGORTA-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
        "kurum": "KKTC Sigortalar BirliÄŸi Havuzu",
        "durum": "OnaylandÄ± / PoliÃ§e Aktif"
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
                    ? 'PoliÃ§e 365 gÃ¼n olarak baÅŸarÄ±yla yenilendi!'
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
        "tarih": "BugÃ¼n / Today",
        "tutar": tutar,
        "kod": "DEKONT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
        "kurum": "KKTC Polis Genel MÃ¼dÃ¼rlÃ¼ÄŸÃ¼ Maliyesi",
        "durum": "Ã–dendi / ArÅŸivlendi"
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
      _anaSayfaGorunumu(
        markaModel: markaModel,
        cezalar: cezalar,
        sigortaGun: sigortaGun,
        muayeneGun: muayeneGun,
        ehliyetPuani: ehliyetPuani,
        odenmemisCezaSayisi: odenmemisCezaSayisi,
        toplamBorc: toplamBorc,
      ),
      RadarHaritasiSayfasi(turkceMi: widget.turkceMi),
      _cezalarimGorunumu(cezalar: cezalar),
      _sigortaGorunumu(markaModel: markaModel, sigortaGun: sigortaGun, muayeneGun: muayeneGun),
      _profilGorunumu(ehliyetPuani: ehliyetPuani),
    ];

    return Scaffold(
      backgroundColor: _HtmlColors.background,
      appBar: PreferredSize(
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // KKTC e-Trafik brand logo & pulse
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _HtmlColors.primaryContainer.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_police_rounded,
                          color: _HtmlColors.primaryContainer,
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
                                  color: _HtmlColors.primaryFixedDim,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(width: 5),
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
                            ],
                          ),
                          Text(
                            _seciliIndex == 0 ? 'e-Trafik' : _baslikDondur(_seciliIndex),
                            style: const TextStyle(
                              color: _HtmlColors.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Actions: Language + Notifications + Profile Avatar
                  Row(
                    children: [
                      // Language button
                      PopupMenuButton<bool>(
                        tooltip: widget.turkceMi ? 'Dil Değiştir' : 'Change Language',
                        onSelected: (bool yeniTurkceMi) => widget.onDilDegistir(yeniTurkceMi),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        color: _HtmlColors.surfaceContainerHigh,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: _HtmlColors.surfaceContainerHigh.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.turkceMi ? 'TR' : 'EN',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: _HtmlColors.secondary,
                              fontSize: 13,
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
                      const SizedBox(width: 8),

                      // Notification bell with unread dot
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: _HtmlColors.surfaceContainerHigh,
                              content: Text(
                                widget.turkceMi
                                    ? 'Okunmamış 1 bildiriminiz bulunmaktadır.'
                                    : 'You have 1 unread notification.',
                                style: const TextStyle(color: _HtmlColors.onSurface),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _HtmlColors.surfaceContainerHigh.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(Icons.notifications_none_rounded, color: _HtmlColors.onSurface, size: 22),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _HtmlColors.primaryContainer,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: _HtmlColors.background, width: 1.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Avatar circle
                      GestureDetector(
                        onTap: () => setState(() => _seciliIndex = 4),
                        child: Container(
                          width: 34,
                          height: 34,
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
      body: sayfalar[_seciliIndex],
      bottomNavigationBar: Container(
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.dashboard_rounded, widget.turkceMi ? 'Panel' : 'Dashboard'),
                _navItem(1, Icons.radar_rounded, widget.turkceMi ? 'Radarlar' : 'Radars'),
                _navItem(2, Icons.receipt_long_rounded, widget.turkceMi ? 'Cezalar' : 'Fines', rozet: odenmemisCezaSayisi),
                _navItem(3, Icons.shield_rounded, widget.turkceMi ? 'Sigorta' : 'Insurance'),
                _navItem(4, Icons.badge_rounded, widget.turkceMi ? 'Profil & QR' : 'Profile & QR'),
              ],
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  ikon,
                  size: 24,
                  color: secili ? _HtmlColors.primaryContainer : _HtmlColors.secondary,
                ),
                if (rozet > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: _HtmlColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$rozet',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
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
          ],
        ),
      ),
    );
  }

  void _aracEkleDialog() {
    final plakaCtrl = TextEditingController();
    final modelCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _HtmlColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          widget.turkceMi ? 'Yeni Araç Ekle' : 'Add New Vehicle',
          style: const TextStyle(color: _HtmlColors.onSurface, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: plakaCtrl,
              style: const TextStyle(color: _HtmlColors.onSurface),
              decoration: InputDecoration(
                labelText: widget.turkceMi ? 'Plaka (Örn: KK 999)' : 'Plate (e.g. KK 999)',
                labelStyle: const TextStyle(color: _HtmlColors.secondary),
                filled: true,
                fillColor: _HtmlColors.surfaceContainerLowest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: modelCtrl,
              style: const TextStyle(color: _HtmlColors.onSurface),
              decoration: InputDecoration(
                labelText: widget.turkceMi ? 'Marka / Model' : 'Make / Model',
                labelStyle: const TextStyle(color: _HtmlColors.secondary),
                filled: true,
                fillColor: _HtmlColors.surfaceContainerLowest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(widget.turkceMi ? 'İptal' : 'Cancel', style: const TextStyle(color: _HtmlColors.secondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _HtmlColors.primaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final plaka = plakaCtrl.text.trim().toUpperCase();
              final model = modelCtrl.text.trim();
              if (plaka.isNotEmpty) {
                setState(() {
                  if (!widget.araclar.contains(plaka)) {
                    widget.araclar.add(plaka);
                  }
                  _aracBilgileriVeritabani[plaka] = {
                    "markaModel": model.isNotEmpty ? model : "Araç ($plaka)",
                    "sigortaKalanGun": 365,
                    "muayeneKalanGun": 365,
                    "ehliyetPuani": 100,
                    "sigortaAktif": true,
                    "cezalar": [],
                  };
                  _secilenPlaka = plaka;
                });
                Navigator.pop(ctx);
              }
            },
            child: Text(
              widget.turkceMi ? 'Kaydet' : 'Save',
              style: const TextStyle(color: _HtmlColors.onPrimaryContainer, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 1: ANA SAYFA ÖZETİ (HTML MOCKUP UYUMLU) ---
  Widget _anaSayfaGorunumu({
    required String markaModel,
    required List cezalar,
    required int sigortaGun,
    required int muayeneGun,
    required int ehliyetPuani,
    required int odenmemisCezaSayisi,
    required int toplamBorc,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Driver Security & Identity Passport Hero
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _HtmlColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Identity Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: _HtmlColors.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.account_circle_outlined,
                                  size: 32,
                                  color: _HtmlColors.secondary,
                                ),
                              ),
                              Positioned(
                                bottom: -2,
                                right: -2,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    color: _HtmlColors.tertiary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.verified,
                                    size: 13,
                                    color: _HtmlColors.onTertiary,
                                  ),
                                ),
                              ),
                            ],
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
                                        widget.kullaniciAdi.isNotEmpty ? widget.kullaniciAdi : 'Ahmet Demir',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: _HtmlColors.onSurface,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _HtmlColors.tertiaryContainer.withValues(alpha: 0.35),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'KKTC PASAPORT',
                                        style: TextStyle(
                                          color: _HtmlColors.tertiaryFixed,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.turkceMi
                                      ? 'Doğrulanmış Sürücü • Sınıf A2, B, D'
                                      : 'Verified Driver • Class A2, B, D',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: _HtmlColors.secondary,
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
                    // QR code button
                    GestureDetector(
                      onTap: () => setState(() => _seciliIndex = 4),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _HtmlColors.surfaceContainerLowest.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.qr_code_2_rounded,
                          color: _HtmlColors.tertiary,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Health Score & Violation Points Gauge Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _HtmlColors.surfaceContainerLowest.withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                FadeTransition(
                                  opacity: _pingController,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: _HtmlColors.tertiary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.turkceMi ? 'EHLİYET SAĞLIK SKORU' : 'DRIVER HEALTH SCORE',
                                  style: const TextStyle(
                                    color: _HtmlColors.tertiary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.turkceMi ? 'Güvenli Sürücü Seviyesi' : 'Safe Driver Standing',
                              style: const TextStyle(
                                color: _HtmlColors.onSurface,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _HtmlColors.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${100 - ehliyetPuani} ${widget.turkceMi ? 'Ceza Puanı' : 'Penalty Points'}',
                                    style: const TextStyle(
                                      color: _HtmlColors.primaryFixed,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.turkceMi ? 'Limit: 100 Puan' : 'Limit: 100 Pts',
                                  style: const TextStyle(
                                    color: _HtmlColors.secondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Radial Score Metric
                      SizedBox(
                        width: 76,
                        height: 76,
                        child: CustomPaint(
                          painter: _RadialGaugePainter(
                            value: (ehliyetPuani / 100.0).clamp(0.0, 1.0),
                            bgColor: _HtmlColors.surfaceContainerHigh,
                            fillColor: _HtmlColors.tertiary,
                            strokeWidth: 5,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$ehliyetPuani',
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: _HtmlColors.onSurface,
                                    height: 1.0,
                                  ),
                                ),
                                const Text(
                                  '/100',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _HtmlColors.secondary,
                                    height: 1.0,
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
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Registered Vehicles Horizontal Selector
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.turkceMi ? 'KAYITLI ARAÇLARIM' : 'REGISTERED VEHICLES'} (${widget.araclar.length})',
                      style: const TextStyle(
                        color: _HtmlColors.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: _HtmlColors.surfaceContainerHigh,
                            content: Text(
                              widget.turkceMi
                                  ? 'Tüm kayıtlı araçlar KKTC Trafik Dairesi ile senkronizedir.'
                                  : 'All registered vehicles are synced with TRNC Traffic Dept.',
                              style: const TextStyle(color: _HtmlColors.onSurface),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        widget.turkceMi ? 'Tümünü Yönet' : 'Manage All',
                        style: const TextStyle(
                          color: _HtmlColors.tertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...widget.araclar.map((plaka) {
                      bool aktif = plaka == _secilenPlaka;
                      String model = _aracBilgileriVeritabani[plaka]?['markaModel'] ?? plaka;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _secilenPlaka = plaka),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 48),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: aktif ? _HtmlColors.primaryContainer : _HtmlColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: aktif
                                  ? [
                                      BoxShadow(
                                        color: _HtmlColors.primaryContainer.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          plaka,
                                          style: TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.8,
                                            color: aktif ? _HtmlColors.onPrimaryContainer : _HtmlColors.onSurface,
                                          ),
                                        ),
                                        if (aktif) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.22),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              widget.turkceMi ? 'Aktif' : 'Active',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      model,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: aktif
                                            ? _HtmlColors.onPrimaryContainer.withValues(alpha: 0.85)
                                            : _HtmlColors.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.directions_car_rounded,
                                  size: 20,
                                  color: aktif ? _HtmlColors.onPrimaryContainer : _HtmlColors.secondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    // + Add Vehicle Button
                    GestureDetector(
                      onTap: () => _aracEkleDialog(),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 48),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _HtmlColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.add_circle_outline_rounded, color: _HtmlColors.tertiary, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              widget.turkceMi ? '+ Araç Ekle' : '+ Add Vehicle',
                              style: const TextStyle(
                                color: _HtmlColors.tertiary,
                                fontSize: 12,
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

          const SizedBox(height: 16),

          // 3. Active Vehicle Dossier Card (RZ 123 Status)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _HtmlColors.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Plate + Model + Status
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
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: _HtmlColors.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _secilenPlaka,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    color: _HtmlColors.primaryFixed,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  markaModel,
                                  style: const TextStyle(
                                    color: _HtmlColors.onSurface,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.turkceMi
                                ? 'Şasi: WBA3...9841 • Koçan No: KC-90412'
                                : 'Chassis: WBA3...9841 • Logbook: KC-90412',
                            style: const TextStyle(
                              fontSize: 11,
                              color: _HtmlColors.secondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _HtmlColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
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
                          Text(
                            widget.turkceMi ? 'Kayıtlı' : 'Registered',
                            style: const TextStyle(
                              color: _HtmlColors.secondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Status Triplets Matrix
                // 1. Ceza Durumu Uyarısı
                GestureDetector(
                  onTap: () => setState(() => _seciliIndex = 2),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _HtmlColors.errorContainer.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(12),
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
                                color: _HtmlColors.errorContainer.withValues(alpha: 0.40),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.warning_amber_rounded,
                                color: _HtmlColors.primaryFixedDim,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.turkceMi ? 'CEZA DURUMU' : 'VIOLATION STATUS',
                                  style: const TextStyle(
                                    color: _HtmlColors.primaryFixed,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  odenmemisCezaSayisi > 0
                                      ? '$odenmemisCezaSayisi ${widget.turkceMi ? 'Ödenmemiş Ceza Mevcut' : 'Unpaid Fines'}'
                                      : (widget.turkceMi ? 'Ödenmemiş Ceza Yok' : 'No Unpaid Fines'),
                                  style: const TextStyle(
                                    color: _HtmlColors.onSurface,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
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
                              '₺$toplamBorc',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                color: _HtmlColors.primaryFixed,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.turkceMi ? 'Vade: 15 Gün' : 'Due: 15 Days',
                              style: const TextStyle(
                                color: _HtmlColors.secondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // 2. Zorunlu Sigorta (Kritik Sayaç)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _HtmlColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: _HtmlColors.primaryContainer.withValues(alpha: 0.20),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.shield_outlined,
                                  color: _HtmlColors.primaryContainer,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.turkceMi ? 'ZORUNLU TRAFİK SİGORTASI' : 'MANDATORY TRAFFIC INSURANCE',
                                    style: const TextStyle(
                                      color: _HtmlColors.secondary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    sigortaGun < 30
                                        ? '${widget.turkceMi ? 'Kritik: Kalan' : 'Critical:'} $sigortaGun ${widget.turkceMi ? 'Gün!' : 'Days!'}'
                                        : '$sigortaGun ${widget.turkceMi ? 'Gün Kaldı' : 'Days Left'}',
                                    style: TextStyle(
                                      color: sigortaGun < 30 ? _HtmlColors.primaryFixed : _HtmlColors.tertiary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => _sigortaYenile(_secilenPlaka),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: _HtmlColors.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: _HtmlColors.primaryContainer.withValues(alpha: 0.35),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.turkceMi ? 'Hemen Yenile' : 'Renew Now',
                                    style: const TextStyle(
                                      color: _HtmlColors.onPrimaryContainer,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward, size: 14, color: _HtmlColors.onPrimaryContainer),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (sigortaGun / 365.0).clamp(0.04, 1.0),
                          backgroundColor: _HtmlColors.surfaceContainerLowest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            sigortaGun < 30 ? _HtmlColors.primaryContainer : _HtmlColors.tertiary,
                          ),
                          minHeight: 5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 3. Araç Muayenesi
                Container(
                  padding: const EdgeInsets.all(12),
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
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: _HtmlColors.tertiaryContainer.withValues(alpha: 0.30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.fact_check_outlined,
                              color: _HtmlColors.tertiary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.turkceMi ? 'ARAÇ MUAYENESİ' : 'VEHICLE INSPECTION',
                                style: const TextStyle(
                                  color: _HtmlColors.secondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.turkceMi ? 'Geçerli Durumda' : 'Valid Status',
                                style: const TextStyle(
                                  color: _HtmlColors.onSurface,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _HtmlColors.tertiaryContainer.withValues(alpha: 0.40),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${widget.turkceMi ? 'Kalan:' : 'Left:'} $muayeneGun ${widget.turkceMi ? 'Gün' : 'Days'}',
                          style: const TextStyle(
                            color: _HtmlColors.onTertiaryContainer,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4. Live KKTC Speed Camera Radar Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _HtmlColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
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
                        FadeTransition(
                          opacity: _pingController,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: _HtmlColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.turkceMi ? 'CANLI RADAR HARİTASI' : 'LIVE SPEED RADAR MAP',
                          style: const TextStyle(
                            color: _HtmlColors.primaryFixed,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _HtmlColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.turkceMi ? 'Çevrenizde 4 Sabit Radar' : '4 Fixed Radars Nearby',
                        style: const TextStyle(
                          color: _HtmlColors.tertiary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.turkceMi ? 'Hamitköy & Gönyeli kameraları aktif!' : 'Hamitköy & Gönyeli cameras active!',
                            style: const TextStyle(
                              color: _HtmlColors.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.turkceMi
                                ? 'Lefkoşa-Gazimağusa anayolunda güncel hız denetimi.'
                                : 'Active speed radar checks on Nicosia-Famagusta highway.',
                            style: const TextStyle(
                              color: _HtmlColors.secondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => setState(() => _seciliIndex = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        decoration: BoxDecoration(
                          color: _HtmlColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              widget.turkceMi ? 'Haritayı Aç' : 'Open Map',
                              style: const TextStyle(
                                color: _HtmlColors.tertiary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.near_me_rounded, color: _HtmlColors.tertiary, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 5. Quick Sovereign Utility Grid (Hızlı İşlemler)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  widget.turkceMi ? 'HIZLI İŞLEMLER' : 'QUICK ACTIONS',
                  style: const TextStyle(
                    color: _HtmlColors.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _hizliIslemButon(
                    ikon: Icons.radar_rounded,
                    baslik: widget.turkceMi ? 'Radarlar' : 'Radars',
                    iconColor: _HtmlColors.primaryContainer,
                    onTap: () => setState(() => _seciliIndex = 1),
                  ),
                  const SizedBox(width: 8),
                  _hizliIslemButon(
                    ikon: Icons.qr_code_scanner_rounded,
                    baslik: widget.turkceMi ? 'Resmi Belge' : 'Official Doc',
                    iconColor: _HtmlColors.tertiary,
                    onTap: () => setState(() => _seciliIndex = 4),
                  ),
                  const SizedBox(width: 8),
                  _hizliIslemButon(
                    ikon: Icons.receipt_long_rounded,
                    baslik: widget.turkceMi ? 'Dekontlar' : 'Receipts',
                    iconColor: _HtmlColors.secondary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DekontlarSayfasi(dekontlar: _dekontlar, turkceMi: widget.turkceMi),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _hizliIslemButon(
                    ikon: Icons.gavel_rounded,
                    baslik: widget.turkceMi ? 'İtiraz Et' : 'Appeal',
                    iconColor: _HtmlColors.primaryFixedDim,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItirazSayfasi(turkceMi: widget.turkceMi),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 6. Recent Infraction / Penalty Summary Card (Son İhlal Kaydı)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.turkceMi ? 'SON İHLAL KAYDI' : 'RECENT INFRACTION',
                      style: const TextStyle(
                        color: _HtmlColors.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _seciliIndex = 2),
                      child: Text(
                        widget.turkceMi ? 'Tüm Geçmiş →' : 'Full History →',
                        style: const TextStyle(
                          color: _HtmlColors.primaryFixedDim,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _HtmlColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: _HtmlColors.errorContainer.withValues(alpha: 0.30),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.speed_rounded,
                                color: _HtmlColors.primaryContainer,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cezalar.isNotEmpty
                                      ? (cezalar.first['tur'] ?? 'Gönyeli Çemberi Sabit Radar')
                                      : 'Gönyeli Çemberi Sabit Radar',
                                  style: const TextStyle(
                                    color: _HtmlColors.onSurface,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  cezalar.isNotEmpty
                                      ? (cezalar.first['tarih'] ?? '18 Mayıs 2024 • Saat: 14:32')
                                      : '18 Mayıs 2024 • Saat: 14:32',
                                  style: const TextStyle(
                                    color: _HtmlColors.secondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: _HtmlColors.errorContainer.withValues(alpha: 0.40),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.turkceMi ? 'Bekliyor' : 'Pending',
                            style: const TextStyle(
                              color: _HtmlColors.primaryFixed,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Violation Detail Telemetry Strip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: _HtmlColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.turkceMi ? 'İHLAL TÜRÜ' : 'VIOLATION TYPE',
                                style: const TextStyle(
                                  color: _HtmlColors.secondary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.turkceMi ? 'Hız Aşımı' : 'Speed Limit Violation',
                                style: const TextStyle(
                                  color: _HtmlColors.onSurface,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                widget.turkceMi ? 'ÖLÇÜLEN / LİMİT' : 'RECORDED / LIMIT',
                                style: const TextStyle(
                                  color: _HtmlColors.secondary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '78 km/s ',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        color: _HtmlColors.primaryFixed,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '/ 65 km/s',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        color: _HtmlColors.secondary,
                                        fontSize: 12,
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
                    const SizedBox(height: 12),
                    // Settlement Action Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.turkceMi ? 'CEZA TUTARI' : 'FINE AMOUNT',
                              style: const TextStyle(
                                color: _HtmlColors.secondary,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              cezalar.isNotEmpty && cezalar.first['tutar'] != null
                                  ? '${cezalar.first['tutar']}'
                                  : '₺1.850,00',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                color: _HtmlColors.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            if (cezalar.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CezaDetaySayfasi(
                                    ceza: cezalar.first,
                                    turkceMi: widget.turkceMi,
                                    onOdemeYap: () => _cezaOdemeGuncelle(
                                      _secilenPlaka,
                                      cezalar.first['id'],
                                      cezalar.first['tur'] ?? '',
                                      cezalar.first['turEn'] ?? '',
                                      cezalar.first['tutar'] ?? '',
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              setState(() => _seciliIndex = 2);
                            }
                          },
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 44),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                            decoration: BoxDecoration(
                              color: _HtmlColors.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: _HtmlColors.primaryContainer.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  widget.turkceMi ? 'Öde & Detay' : 'Pay & Details',
                                  style: const TextStyle(
                                    color: _HtmlColors.onPrimaryContainer,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.credit_card_rounded, color: _HtmlColors.onPrimaryContainer, size: 18),
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

          const SizedBox(height: 24),

          // Alt İsim İmzası
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _HtmlColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.turkceMi ? 'Geliştiren: Tuğberk Kara' : 'Developed by: Tuğberk Kara',
                style: const TextStyle(fontSize: 11, color: _HtmlColors.secondary, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }


  Widget _hizliIslemButon({required IconData ikon, required String baslik, required Color iconColor, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: _HtmlColors.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _HtmlColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(ikon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 6),
              Text(
                baslik,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _HtmlColors.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
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
                decoration: BoxDecoration(
                  color: aktif ? _HtmlColors.primaryContainer : _HtmlColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
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
                      const Flexible(
                        child: Text(
                          'e3b0c44298fc1c149afbf4c8996fb92427ae41e4',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: _HtmlColors.tertiaryFixed,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                Row(
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
                    Column(
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
                            Row(
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
                                Text(
                                  widget.turkceMi ? 'Aktif Kayıt' : 'Active Record',
                                  style: const TextStyle(
                                    color: _HtmlColors.tertiaryFixed,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
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
                        ),
                      ],
                    ),
                  ],
                ),
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
                  padding: const EdgeInsets.all(14),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _HtmlColors.tertiaryContainer.withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.check, color: _HtmlColors.tertiary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    g['baslik'],
                                    style: const TextStyle(
                                      color: _HtmlColors.onSurface,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
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
                              const SizedBox(height: 2),
                              Text(
                                '${g['tarih']} • ${g['kod']}',
                                style: const TextStyle(
                                  color: _HtmlColors.secondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                g['tutar'],
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  color: _HtmlColors.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Dekont No: ${g['dekontNo']}',
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
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _HtmlColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.receipt_long_rounded, color: _HtmlColors.secondary, size: 18),
                            ),
                          ),
                        ],
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
                            const SizedBox(height: 2),
                            const Text(
                              '#KKTC-2024-884912',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                color: _HtmlColors.primaryFixedDim,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
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
                            Row(
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
                            Container(
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
                        Row(
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _HtmlColors.surfaceContainerLowest.withValues(alpha: 0.85),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Row(
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _HtmlColors.primaryContainer.withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'DELİL NO: #884912',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _HtmlColors.surfaceContainerLowest.withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.zoom_in_rounded, color: _HtmlColors.onSurface, size: 14),
                                          const SizedBox(width: 4),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _HtmlColors.surfaceContainerLowest.withValues(alpha: 0.8),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        '2024-05-18 14:32:08',
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          color: _HtmlColors.secondary,
                                          fontSize: 9,
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
                                const Text(
                                  '₺1.572,50',
                                  style: TextStyle(
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
                                    '1572.50 TL',
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
                                    widget.turkceMi ? 'Güvenli Ödeme Yap (₺1.572,50)' : 'Pay Securely (₺1,572.50)',
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

  // --- TAB 3: SÄ°GORTA VE POLÄ°Ã‡E YÃ–NETÄ°MÄ° ---
  Widget _sigortaGorunumu({required String markaModel, required int sigortaGun, required int muayeneGun}) {
    bool aktif = sigortaGun > 0;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Apple Wallet tarzÄ± Modern Dijital PoliÃ§e KartÄ±
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E1B4B).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
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
                        const Icon(Icons.shield_rounded, color: Colors.white, size: 28),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.turkceMi ? 'KKTC TRAFÄ°K SÄ°GORTASI' : 'TRNC TRAFFIC INSURANCE',
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                            ),
                            Text(
                              widget.turkceMi ? 'Zorunlu Karayolu Mali Mesuliyet' : 'Mandatory Motor Third Party',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: aktif ? AppColors.success.withValues(alpha: 0.25) : AppColors.danger.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: aktif ? AppColors.success : AppColors.danger, width: 1),
                      ),
                      child: Text(
                        aktif ? (widget.turkceMi ? 'POLÄ°Ã‡E AKTÄ°F' : 'ACTIVE') : (widget.turkceMi ? 'SÃœRESÄ° DOLMUÅ' : 'EXPIRED'),
                        style: TextStyle(
                          color: aktif ? AppColors.success : AppColors.danger,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  _secilenPlaka,
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                ),
                Text(
                  markaModel,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.turkceMi ? 'Kalan GÃ¼n' : 'Days Remaining', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
                        const SizedBox(height: 2),
                        Text('$sigortaGun ${widget.turkceMi ? 'GÃ¼n' : 'Days'}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(widget.turkceMi ? 'PoliÃ§e No' : 'Policy No', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
                        const SizedBox(height: 2),
                        const Text('TRNC-SIG-2026', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Teminat Bilgileri
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.turkceMi ? 'Teminat KapsamÄ±' : 'Coverage Scope',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.slate900),
                ),
                const SizedBox(height: 12),
                _teminatSatiri(widget.turkceMi ? '3. ÅahÄ±s Maddi Zararlar' : '3rd Party Material Damage', '500.000 TL'),
                _teminatSatiri(widget.turkceMi ? 'Bedeni Zararlar ve Tedavi' : 'Bodily Harm & Medical', '1.000.000 TL'),
                _teminatSatiri(widget.turkceMi ? 'Hukuksal Koruma & Ã‡ekici' : 'Legal & Towing Support', widget.turkceMi ? 'Dahil' : 'Included'),
                const Divider(height: 24, color: AppColors.slate200),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.turkceMi ? 'YÄ±llÄ±k PoliÃ§e Ãœcreti' : 'Annual Fee',
                      style: const TextStyle(fontSize: 14, color: AppColors.slate500, fontWeight: FontWeight.w600),
                    ),
                    const Text('4.500 TL', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Yenileme Butonu
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => _sigortaYenile(_secilenPlaka),
              icon: const Icon(Icons.flash_on_rounded),
              label: Text(
                widget.turkceMi ? 'Hemen SigortayÄ± Yenile (4500 TL)' : 'Instantly Renew Policy (4500 TL)',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _teminatSatiri(String baslik, String deger) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: const TextStyle(fontSize: 13, color: AppColors.slate700)),
          Text(deger, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.slate900)),
        ],
      ),
    );
  }

  // --- TAB 4: PROFÄ°L & BELGELER ---
  Widget _profilGorunumu({required int ehliyetPuani}) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        // SÃ¼rÃ¼cÃ¼ KartÄ±
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryLight,
                child: const Icon(Icons.person, color: AppColors.primary, size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.kullaniciAdi,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.slate900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.turkceMi ? 'KKTC KayÄ±tlÄ± SÃ¼rÃ¼cÃ¼ Belgesi Sahibi' : 'TRNC Registered Driver License Holder',
                      style: const TextStyle(fontSize: 12, color: AppColors.slate500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // MenÃ¼ Ã–ÄŸeleri
        _profilMenuKutusu(
          children: [
            _profilMenuItem(
              ikon: Icons.qr_code_2_rounded,
              ikonRenk: AppColors.info,
              baslik: widget.turkceMi ? 'Barkodlu SÃ¼rÃ¼cÃ¼ Belgesi' : 'Barcoded Driver Certificate',
              altBaslik: widget.turkceMi ? 'Taranabilir ve Ã§alÄ±ÅŸÄ±r QR doÄŸrulamasÄ±' : 'Interactive QR verification code',
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
            const Divider(height: 1, indent: 56, color: AppColors.slate200),
            _profilMenuItem(
              ikon: Icons.receipt_long_rounded,
              ikonRenk: AppColors.success,
              baslik: widget.turkceMi ? 'Ã–deme DekontlarÄ±' : 'Payment Receipts',
              altBaslik: widget.turkceMi ? 'Resmi tahsilat makbuzlarÄ± ve PDF arÅŸivi' : 'Official payment slips & archive',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DekontlarSayfasi(dekontlar: _dekontlar, turkceMi: widget.turkceMi),
                ),
              ),
            ),
            const Divider(height: 1, indent: 56, color: AppColors.slate200),
            _profilMenuItem(
              ikon: Icons.gavel_rounded,
              ikonRenk: AppColors.warning,
              baslik: widget.turkceMi ? 'Cezaya Ä°tiraz BaÅŸvurusu' : 'Fine Objection Application',
              altBaslik: widget.turkceMi ? 'HatalÄ± veya radar itiraz dilekÃ§esi gÃ¶nder' : 'Submit petition for incorrect fines',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ItirazSayfasi(turkceMi: widget.turkceMi),
                ),
              ),
            ),
            const Divider(height: 1, indent: 56, color: AppColors.slate200),
            _profilMenuItem(
              ikon: Icons.notifications_active_outlined,
              ikonRenk: Colors.purple,
              baslik: widget.turkceMi ? 'Bildirim ve HatÄ±rlatÄ±cÄ±lar' : 'Notifications & Reminders',
              altBaslik: widget.turkceMi ? 'Sigorta ve muayene son gÃ¼n uyarÄ±larÄ±' : 'Insurance & inspection alerts',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BildirimAyarlariSayfasi(turkceMi: widget.turkceMi),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Ã‡Ä±kÄ±ÅŸ Yap
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.slate200),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.dangerLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
            ),
            title: Text(
              widget.turkceMi ? 'GÃ¼venli Ã‡Ä±kÄ±ÅŸ Yap' : 'Secure Logout',
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.danger, fontSize: 14),
            ),
            onTap: widget.onCikisYap,
          ),
        ),
        const SizedBox(height: 28),

        // Footer
        Center(
          child: Column(
            children: [
              Text(
                widget.turkceMi ? 'KKTC Polis Genel MÃ¼dÃ¼rlÃ¼ÄŸÃ¼ Bilgi Ä°ÅŸlem PortalÄ±' : 'TRNC Police Headquarters IT Portal',
                style: const TextStyle(fontSize: 11, color: AppColors.slate400, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                widget.turkceMi ? 'GeliÅŸtiren: TuÄŸberk Kara' : 'Developed by: TuÄŸberk Kara',
                style: const TextStyle(fontSize: 12, color: AppColors.slate700, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _profilMenuKutusu({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(children: children),
    );
  }

  Widget _profilMenuItem({
    required IconData ikon,
    required Color ikonRenk,
    required String baslik,
    required String altBaslik,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ikonRenk.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(ikon, color: ikonRenk, size: 22),
      ),
      title: Text(baslik, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.slate900)),
      subtitle: Text(altBaslik, style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.slate400, size: 20),
      onTap: onTap,
    );
  }

  String _baslikDondur(int index) {
    if (widget.turkceMi) {
      switch (index) {
        case 0: return 'e-Trafik Ã–zet';
        case 1: return 'KKTC Radar & Kameralar';
        case 2: return 'Trafik CezalarÄ±m';
        case 3: return 'Sigorta PoliÃ§eleri';
        case 4: return 'SÃ¼rÃ¼cÃ¼ Profilim';
        default: return 'e-Trafik';
      }
    } else {
      switch (index) {
        case 0: return 'e-Traffic Overview';
        case 1: return 'TRNC Radars & Cameras';
        case 2: return 'My Traffic Fines';
        case 3: return 'Insurance Policies';
        case 4: return 'Driver Profile';
        default: return 'e-Traffic';
      }
    }
  }
}

class _RadialGaugePainter extends CustomPainter {
  final double value;
  final Color bgColor;
  final Color fillColor;
  final double strokeWidth;

  const _RadialGaugePainter({
    required this.value,
    required this.bgColor,
    required this.fillColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5707963,
      6.2831853 * value,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(_RadialGaugePainter old) =>
      old.value != value || old.bgColor != bgColor || old.fillColor != fillColor;
}

// ==========================================
// ğŸ” 3. MODERN CEZA DETAY SAYFASI
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
          turkceMi ? 'Ceza ve KanÄ±t DetayÄ±' : 'Violation & Evidence',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kamera / KanÄ±t GÃ¶rseli KartÄ±
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
                                turkceMi ? 'Radar KanÄ±t GÃ¶rseli' : 'Radar Evidence Image',
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

            // Bilgi KartÄ±
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
                          odendiMi ? (turkceMi ? 'Ã–DENDÄ°' : 'PAID') : (turkceMi ? 'Ã–DENMEDÄ°' : 'UNPAID'),
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
                  _detaySatiri(turkceMi ? 'Ä°hlal Tarihi' : 'Date', ceza['tarih']),
                  _detaySatiri(turkceMi ? 'Konum' : 'Location', ceza['konum']),
                  _detaySatiri(turkceMi ? 'Ceza PuanÄ± Etkisi' : 'Penalty Points', ceza['puan']),
                  _detaySatiri(turkceMi ? 'Yetkili Birim' : 'Enforcing Unit', ceza['polis']),
                  _detaySatiri(turkceMi ? 'Kategori' : 'Category', ceza['kategori']),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Ã–deme Butonu
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
                                        ? 'Ã–deme simÃ¼lasyonu baÅŸarÄ±lÄ±! Dekontlar sayfasÄ±na makbuz eklendi.'
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
                          ? (turkceMi ? 'Bu Ceza Ã–denmiÅŸ' : 'This Fine is Paid')
                          : (turkceMi ? 'Åimdi Ã–de (Kart ile SimÃ¼lasyon)' : 'Pay Now (Card Simulation)'),
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
// ğŸ†” 4. MODERN BARKODLU SÃœRÃœCÃœ BELGESÄ° & Ã‡ALIÅIR QR
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
                    widget.turkceMi ? 'Resmi DoÄŸrulama BaÅŸarÄ±lÄ±' : 'Verification Successful',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            content: Text(
              widget.turkceMi
                  ? 'Bu belge KKTC Polis Genel MÃ¼dÃ¼rlÃ¼ÄŸÃ¼ merkezi veri tabanÄ±nda resmi olarak doÄŸrulanmÄ±ÅŸtÄ±r. Ehliyet puanÄ± ve kayÄ±t durumu onaylÄ±dÄ±r.'
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
          widget.turkceMi ? 'Resmi SÃ¼rÃ¼cÃ¼ Belgesi' : 'Official Driver Certificate',
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
                  'KUZEY KIBRIS TÃœRK CUMHURÄ°YETÄ°',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.slate500, letterSpacing: 1),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.turkceMi ? 'Polis Genel MÃ¼dÃ¼rlÃ¼ÄŸÃ¼ Trafik Belgesi' : 'Police Traffic Certification',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.slate900),
                  textAlign: TextAlign.center,
                ),
                const Divider(height: 32, color: AppColors.slate200),

                _bilgiSatiri(widget.turkceMi ? 'Ad Soyad' : 'Full Name', widget.kullanici),
                _bilgiSatiri(widget.turkceMi ? 'SÃ¼rÃ¼cÃ¼ PuanÄ±' : 'Driver Score', '${widget.puan} / 100'),
                _bilgiSatiri(widget.turkceMi ? 'Belge Durumu' : 'Status', widget.turkceMi ? 'Aktif / GeÃ§erli' : 'Active / Valid'),
                const SizedBox(height: 24),

                // Ã‡ALIÅIR QR KOD
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
                          widget.turkceMi ? 'ğŸ” DoÄŸrulamak iÃ§in QR Koda Dokunun' : 'ğŸ” Tap QR to Verify Online',
                          style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Barkod No: KKTC-TR-2026-99182',
                  style: TextStyle(fontSize: 11, color: AppColors.slate400, fontWeight: FontWeight.w600),
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
          Text(deger, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.slate900)),
        ],
      ),
    );
  }
}

// ==========================================
// ğŸ§¾ 5. RESMÄ° Ã–DEME DEKONTU SAYFALARI
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
          turkceMi ? 'Ã–deme DekontlarÄ±' : 'Payment Receipts',
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
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.slate200),
            ),
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
              subtitle: Text('${turkceMi ? 'Tarih' : 'Date'}: ${dekont['tarih']} | ${dekont['kod']}', style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
              trailing: Text(
                dekont['tutar']!,
                style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.success, fontSize: 16),
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
          turkceMi ? 'Resmi Ã–deme Makbuzu' : 'Official Payment Receipt',
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
                        turkceMi ? 'ONAYLANDI / TAHSÄ°L EDÄ°LDÄ°' : 'APPROVED & COLLECTED',
                        style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w800, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'KUZEY KIBRIS TÃœRK CUMHURÄ°YETÄ°',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.slate500, letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                Text(
                  turkceMi ? 'Maliye BakanlÄ±ÄŸÄ± Elektronik Tahsilat Makbuzu' : 'Ministry of Finance Electronic Receipt',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.slate900),
                ),
                const Divider(height: 32, color: AppColors.slate200),
                _dekontSatiri(turkceMi ? 'Ä°ÅŸlem TÃ¼rÃ¼' : 'Type', islemAdi),
                _dekontSatiri(turkceMi ? 'Ä°ÅŸlem Kodu' : 'Ref Code', dekont['kod']!),
                _dekontSatiri(turkceMi ? 'Ä°ÅŸlem Tarihi' : 'Date', dekont['tarih']!),
                _dekontSatiri(turkceMi ? 'Ä°lgili Kurum' : 'Authority', dekont['kurum'] ?? 'KKTC Maliye BakanlÄ±ÄŸÄ±'),
                _dekontSatiri(turkceMi ? 'Durum' : 'Status', dekont['durum'] ?? 'BaÅŸarÄ±lÄ±'),
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
                        turkceMi ? 'Resmi e-Devlet DoÄŸrulama Kodu' : 'Official e-Government Verification Code',
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
          Expanded(
            child: Text(
              deger,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.slate900),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// âš–ï¸ 6. Ä°TÄ°RAZ VE BÄ°LDÄ°RÄ°M SAYFALARI
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
          turkceMi ? 'Cezaya Ä°tiraz DilekÃ§esi' : 'Fine Appeal Form',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              turkceMi ? 'Resmi Ä°tiraz BaÅŸvuru Formu' : 'Official Appeal Form',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.slate900),
            ),
            const SizedBox(height: 6),
            Text(
              turkceMi
                  ? 'Plaka veya ceza tutanaÄŸÄ±nda hata olduÄŸunu dÃ¼ÅŸÃ¼nÃ¼yorsanÄ±z, gerekÃ§enizi belirterek KKTC Trafik Dairesi Hakem Kurulu\'na baÅŸvurabilirsiniz.'
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
                          ? 'Ä°tiraz gerekÃ§enizi ve olayÄ±n detaylarÄ±nÄ± detaylÄ±ca buraya yazÄ±n...'
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
                                        ? 'Ä°tiraz baÅŸvurunuz alÄ±ndÄ±. Dosya No: KKTC-ITR-9921'
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
                        turkceMi ? 'DilekÃ§eyi GÃ¶nder' : 'Submit Petition',
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
          widget.turkceMi ? 'Bildirim AyarlarÄ±' : 'Notification Preferences',
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
                  title: Text(widget.turkceMi ? 'Sigorta HatÄ±rlatÄ±cÄ±sÄ±' : 'Insurance Reminders', style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(widget.turkceMi ? 'PoliÃ§e bitimine 15 gÃ¼n kala uyar' : 'Alert 15 days before expiration', style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
                  value: sigorta,
                  onChanged: (v) => setState(() => sigorta = v),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.slate200),
                SwitchListTile(
                  activeThumbColor: AppColors.primary,
                  title: Text(widget.turkceMi ? 'Muayene HatÄ±rlatÄ±cÄ±sÄ±' : 'Inspection Reminders', style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(widget.turkceMi ? 'Muayene sÃ¼resi yaklaÅŸtÄ±ÄŸÄ±nda uyar' : 'Alert when vehicle inspection is due', style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
                  value: muayene,
                  onChanged: (v) => setState(() => muayene = v),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.slate200),
                SwitchListTile(
                  activeThumbColor: AppColors.primary,
                  title: Text(widget.turkceMi ? 'Yeni Ceza UyarÄ±larÄ±' : 'New Violation Alerts', style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(widget.turkceMi ? 'Plakaya radar veya ceza yazÄ±ldÄ±ÄŸÄ±nda anÄ±nda SMS ve bildirim' : 'Instant notification on new tickets', style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
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
