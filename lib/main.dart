import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'radar_haritasi.dart';
import 'yol_tarifi_sayfasi.dart';
import 'kktc_gov_sync_service.dart';
import 'yardim_rehberi_sayfasi.dart';

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
  bool _turkceMi = true;
  bool _girisYapildiMi = false;
  String _kullaniciAdi = "";
  String _kullaniciRolu = "";
  List<String> _araclar = [];

  void _dilDegistir(bool turkceMi) {
    setState(() {
      _turkceMi = turkceMi;
    });
  }

  void _girisYapBasarili(String adSoyad, List<String> araclar, [String rol = ""]) {
    setState(() {
      _girisYapildiMi = true;
      _kullaniciAdi = adSoyad;
      _araclar = araclar;
      _kullaniciRolu = rol;
    });
  }

  void _cikisYap() {
    setState(() {
      _girisYapildiMi = false;
      _kullaniciAdi = "";
      _kullaniciRolu = "";
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
              kullaniciRolu: _kullaniciRolu,
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
  static const Color onSurfaceVariant = Color(0xFFE7BCBA);
  static const Color outlineVariant = Color(0xFF5D3F3D);
  static const Color onSecondaryContainer = Color(0xFFABB4D7);
  static const Color tertiaryFixedDim = Color(0xFF4EDEA3);
}

enum KullaniciTuru {
  kktcVatandas,
  tcVatandas,
  ogrenci,
  uluslararasi,
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
  final TextEditingController _girisController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();
  KullaniciTuru _seciliRol = KullaniciTuru.kktcVatandas;
  String _secilenUniversite = "ODTU";

  final List<Map<String, String>> _universiteler = [
    {"kod": "ODTU", "ad": "ODTÜ Kuzey Kıbrıs Kampüsü", "kisa": "ODTÜ KKK"},
    {"kod": "DAU", "ad": "Doğu Akdeniz Üniversitesi (DAÜ)", "kisa": "DAÜ / EMU"},
    {"kod": "YDU", "ad": "Yakın Doğu Üniversitesi (YDÜ)", "kisa": "YDÜ / NEU"},
    {"kod": "UKU", "ad": "Uluslararası Kıbrıs Üniversitesi", "kisa": "UKÜ / CIU"},
    {"kod": "LAU", "ad": "Lefke Avrupa Üniversitesi", "kisa": "LAÜ / EUL"},
    {"kod": "GU", "ad": "Girne Üniversitesi", "kisa": "GÜ / UoK"},
    {"kod": "DIGER", "ad": "Diğer KKTC Yükseköğretim (YÖBİS)", "kisa": "Diğer / YÖBİS"},
  ];

  bool _sifreGizli = true;
  bool _biyometrikYukleniyor = false;
  bool _biyometrikBasarili = false;
  bool _girisYukleniyor = false;
  bool _girisBasariliAnimasyon = false;
  int _authMethod = 0; // 0 = Kimlik&Şifre, 1 = SMS

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
            ? 'Lütfen kimlik/öğrenci no ve şifrenizi girin.'
            : 'Please enter your ID/credentials and password.',
        isError: true,
      );
      return;
    }

    setState(() => _girisYukleniyor = true);

    Future.delayed(const Duration(milliseconds: 950), () {
      if (!mounted) return;

      List<String> tanimliAraclar = [];
      String adSoyad = "";
      String rolAciklama = "";

      switch (_seciliRol) {
        case KullaniciTuru.kktcVatandas:
          adSoyad = widget.turkceMi ? "Ahmet Demir" : "Ahmet Demir (Citizen)";
          rolAciklama = widget.turkceMi ? "KKTC Vatandaşı (Merkezi Kayıt)" : "TRNC Citizen";
          tanimliAraclar = ["RZ 123", "LZ 555"];
          break;

        case KullaniciTuru.tcVatandas:
          adSoyad = widget.turkceMi ? "Mehmet Yılmaz" : "Mehmet Yilmaz";
          rolAciklama = widget.turkceMi ? "T.C. Vatandaşı (İkamet & Görevli)" : "TR Citizen (Resident & Duty)";
          tanimliAraclar = ["KY 440", "RZ 123"];
          break;

        case KullaniciTuru.ogrenci:
          final uni = _universiteler.firstWhere(
            (u) => u["kod"] == _secilenUniversite,
            orElse: () => _universiteler[0],
          );
          final uniKisa = uni["kisa"]!;
          adSoyad = widget.turkceMi ? "Tubi ($uniKisa)" : "Tubi ($uniKisa Student)";
          rolAciklama = widget.turkceMi ? "$uniKisa Öğrenci (YÖBİS Aktif)" : "$uniKisa Student (YOBIS Active)";
          if (_secilenUniversite == "ODTU") {
            tanimliAraclar = ["ODTU 107", "ST 999"];
          } else if (_secilenUniversite == "DAU") {
            tanimliAraclar = ["ST 999", "GM 202"];
          } else {
            tanimliAraclar = ["GM 202", "ST 999"];
          }
          break;

        case KullaniciTuru.uluslararasi:
          adSoyad = "Alex Smith";
          rolAciklama = widget.turkceMi ? "Uluslararası Misafir (İkamet İzni)" : "International Guest (Residence Permit)";
          tanimliAraclar = ["GM 202", "ST 999"];
          break;
      }

      setState(() {
        _girisYukleniyor = false;
        _girisBasariliAnimasyon = true;
      });

      Future.delayed(const Duration(milliseconds: 550), () {
        widget.onGirisBasarili(adSoyad, tanimliAraclar, rolAciklama);
      });
    });
  }

  void _hizliDemoGiris(KullaniciTuru rol, {String? uniKod}) {
    setState(() {
      _seciliRol = rol;
      if (uniKod != null) _secilenUniversite = uniKod;

      switch (rol) {
        case KullaniciTuru.kktcVatandas:
          _girisController.text = "123456";
          _sifreController.text = "123456";
          break;
        case KullaniciTuru.tcVatandas:
          _girisController.text = "19283746501";
          _sifreController.text = "tc1234";
          break;
        case KullaniciTuru.ogrenci:
          _girisController.text = uniKod == "ODTU" ? "21703517" : "tubi";
          _sifreController.text = "tugkan3517";
          break;
        case KullaniciTuru.uluslararasi:
          _girisController.text = "U8819201";
          _sifreController.text = "alex123";
          break;
      }
    });
    _girisYap();
  }

  void _biyometrikGiris() async {
    setState(() {
      _biyometrikYukleniyor = true;
      _biyometrikBasarili = false;
    });
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _biyometrikYukleniyor = false;
      _biyometrikBasarili = true;
      _girisController.text = '21894019284';
      _sifreController.text = '••••••••••••';
    });
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _biyometrikBasarili = false);
    _girisYap();
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
    // Dynamic Labels & Hints based on selected user type
    String idEtiketi = widget.turkceMi ? 'KKTC KİMLİK KARTI NO' : 'TRNC IDENTITY NO';
    String idHint = widget.turkceMi ? 'Örn: 123456 (KKTC Kimlik No)' : 'E.g.: 123456';
    IconData idIkon = Icons.badge_outlined;
    String idAciklama = widget.turkceMi
        ? 'KKTC Polis Genel Müdürlüğü Merkezi Kaydı'
        : 'TRNC Police Headquarters Registry';

    switch (_seciliRol) {
      case KullaniciTuru.kktcVatandas:
        idEtiketi = widget.turkceMi ? 'KKTC KİMLİK KARTI NO' : 'TRNC ID NUMBER';
        idHint = widget.turkceMi ? 'Örn: 123456 (KKTC Kimlik No)' : 'E.g.: 123456';
        idIkon = Icons.badge_outlined;
        idAciklama = widget.turkceMi
            ? 'KKTC Nüfus Kayıt Dairesi ve Polis Genel Müdürlüğü Entegre'
            : 'TRNC Civil Registry & Police HQ Integrated';
        break;
      case KullaniciTuru.tcVatandas:
        idEtiketi = widget.turkceMi ? 'T.C. KİMLİK NO (11 HANE) VEYA YKN' : 'TR ID NO (11-DIGIT) OR TRNC YKN';
        idHint = widget.turkceMi ? 'Örn: 19283746501 (T.C. Kimlik / Askeri & Görevli)' : 'E.g.: 19283746501';
        idIkon = Icons.credit_card_rounded;
        idAciklama = widget.turkceMi
            ? 'İkamet, Çalışma İzni & Görevli / Askeri Personel T.C. Kimlik Entegrasyonu'
            : 'TR Citizen, Resident, Duty & Military Personnel ID Integrated';
        break;
      case KullaniciTuru.ogrenci:
        idEtiketi = widget.turkceMi ? 'ÖĞRENCİ NO VEYA T.C. / PASAPORT NO' : 'STUDENT ID OR PASSPORT / TR ID';
        idHint = widget.turkceMi ? 'Örn: 21703517 veya tubi' : 'E.g.: 21703517 or tubi';
        idIkon = Icons.school_rounded;
        idAciklama = widget.turkceMi
            ? 'KKTC MEB & YÖBİS Öğrenci İkamet İzni ve Kampüs Araç Pulu Portalı'
            : 'TRNC Ministry of Education & YOBIS Student Permit Portal';
        break;
      case KullaniciTuru.uluslararasi:
        idEtiketi = widget.turkceMi ? 'PASAPORT NUMARASI' : 'PASSPORT NUMBER';
        idHint = widget.turkceMi ? 'Örn: U12345678 (Uluslararası Pasaport)' : 'E.g.: U12345678';
        idIkon = Icons.public_rounded;
        idAciklama = widget.turkceMi
            ? 'Yabancı Uyruklular İkamet ve Geçici İthal / Z Plaka Kaydı'
            : 'Foreign Residents Permit & Temporary Import / Z Plate Registry';
        break;
    }

    return Scaffold(
      backgroundColor: _HtmlColors.background,
      body: Stack(
        children: [
          // ── Ambient glow orbs ──
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

          // ── Main content ──
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top Bar ──
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
                                widget.turkceMi ? 'KKTC Kamu & Trafik Ağı Aktif' : 'TRNC Traffic Network Active',
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

                  // ── Institutional Crest & Branding ──
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 76,
                              height: 76,
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
                                      size: 38,
                                      color: _HtmlColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                        const SizedBox(height: 10),
                        Text(
                          widget.turkceMi ? 'KKTC RESMİ GEÇİT' : 'TRNC OFFICIAL PORTAL',
                          style: const TextStyle(
                            color: _HtmlColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.turkceMi ? 'KKTC e-Trafik' : 'TRNC e-Traffic',
                          style: const TextStyle(
                            color: _HtmlColors.onSurface,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.turkceMi
                              ? 'Polis Genel Müdürlüğü • Maliye Bakanlığı • MEB\nTrafik, Ceza, Seyrüsefer & Ruhsat Portalı'
                              : 'Police HQ • Ministry of Finance • MEB\nTraffic, Fines, Road Tax & License Portal',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: _HtmlColors.secondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Segmented Role Selector ──
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _HtmlColors.surfaceContainerLow.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          _roleChip(
                            icon: Icons.badge_outlined,
                            label: widget.turkceMi ? 'KKTC Vatandaşı' : 'TRNC Citizen',
                            selected: _seciliRol == KullaniciTuru.kktcVatandas,
                            onTap: () => setState(() => _seciliRol = KullaniciTuru.kktcVatandas),
                          ),
                          _roleChip(
                            icon: Icons.credit_card_rounded,
                            label: widget.turkceMi ? 'T.C. İkamet' : 'TR Resident',
                            selected: _seciliRol == KullaniciTuru.tcVatandas,
                            onTap: () => setState(() => _seciliRol = KullaniciTuru.tcVatandas),
                          ),
                          _roleChip(
                            icon: Icons.school_rounded,
                            label: widget.turkceMi ? 'Üniversite (Öğrenci)' : 'University (Student)',
                            selected: _seciliRol == KullaniciTuru.ogrenci,
                            onTap: () => setState(() => _seciliRol = KullaniciTuru.ogrenci),
                          ),
                          _roleChip(
                            icon: Icons.public_rounded,
                            label: widget.turkceMi ? 'Uluslararası / Pasaport' : 'International / Passport',
                            selected: _seciliRol == KullaniciTuru.uluslararasi,
                            onTap: () => setState(() => _seciliRol = KullaniciTuru.uluslararasi),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Extra Contextual Selector: Üniversite Seçimi ──
                  if (_seciliRol == KullaniciTuru.ogrenci)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _HtmlColors.surfaceContainerHigh.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _HtmlColors.tertiary.withValues(alpha: 0.35)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.school, size: 16, color: _HtmlColors.tertiary),
                              const SizedBox(width: 6),
                              Text(
                                widget.turkceMi ? 'ÜNİVERSİTE SEÇİMİ (KKTC YÖBİS ENTEGRASYONU)' : 'SELECT UNIVERSITY (TRNC YOBIS)',
                                style: const TextStyle(
                                  color: _HtmlColors.tertiaryFixed,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: _universiteler.map((uni) {
                                final secili = _secilenUniversite == uni["kod"];
                                return GestureDetector(
                                  onTap: () => setState(() => _secilenUniversite = uni["kod"]!),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.only(right: 6),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: secili ? _HtmlColors.tertiaryContainer : _HtmlColors.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: secili ? _HtmlColors.tertiaryFixed : Colors.white10,
                                      ),
                                    ),
                                    child: Text(
                                      uni["kisa"]!,
                                      style: TextStyle(
                                        color: secili ? Colors.white : _HtmlColors.secondary,
                                        fontSize: 11,
                                        fontWeight: secili ? FontWeight.w800 : FontWeight.w500,
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

                  const SizedBox(height: 12),

                  // ── Authentication Form Card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _HtmlColors.surfaceContainer.withValues(alpha: 0.75),
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
                                label: widget.turkceMi ? 'Kimlik & Şifre' : 'ID & Password',
                                selected: _authMethod == 0,
                                onTap: () => setState(() => _authMethod = 0),
                              ),
                              _authMethodTab(
                                icon: Icons.sms,
                                label: widget.turkceMi ? 'SMS / Mobil Onay' : 'SMS / Mobile Code',
                                selected: _authMethod == 1,
                                onTap: () => setState(() => _authMethod = 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // System Info Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _HtmlColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, size: 14, color: _HtmlColors.secondary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  idAciklama,
                                  style: const TextStyle(color: _HtmlColors.secondary, fontSize: 10),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ID Field Label
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              idEtiketi,
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
                          hint: idHint,
                          prefixIcon: idIkon,
                          obscure: false,
                        ),
                        const SizedBox(height: 14),

                        // Password Label
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.turkceMi ? 'PORTAL ŞİFRESİ / PIN' : 'PORTAL PASSWORD / PIN',
                              style: const TextStyle(
                                color: _HtmlColors.secondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                            Text(
                              widget.turkceMi ? 'SMS ile Şifre Al' : 'Get SMS Code',
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
                          hint: '••••••••••••',
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

                        // ── Primary Login Button ──
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
                                              ? (widget.turkceMi ? 'Giriş Başarılı' : 'Login Successful')
                                              : (widget.turkceMi ? 'Güvenli Giriş Yap' : 'Secure Login'),
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

                        // ── Biometric / Face ID Button ──
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
                                      ? (widget.turkceMi ? 'Kimlik Doğrulanıyor...' : 'Verifying...')
                                      : _biyometrikBasarili
                                          ? (widget.turkceMi ? 'Biyometri Doğrulandı' : 'Biometrics Verified')
                                          : (widget.turkceMi ? 'Yüz Tanıma (Face ID) ile Giriş' : 'Login with Face ID'),
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
                  const SizedBox(height: 18),

                  // ── Demo Presets Section Header ──
                  Row(
                    children: [
                      const Icon(Icons.touch_app, color: _HtmlColors.tertiary, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        widget.turkceMi ? 'HIZLI TEST & DEMO PROFİLLERİ' : 'QUICK DEMO SIMULATOR',
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

                  // Demo 1: KKTC Vatandaşı
                  _demoCard(
                    icon: Icons.directions_car,
                    name: 'Ahmet Demir',
                    badge: widget.turkceMi ? 'KKTC Vatandaşı' : 'TRNC Citizen',
                    subtitle: 'BMW 3.20i & Mercedes E220d (Aktif Koçan)',
                    iconBg: _HtmlColors.primaryContainer.withValues(alpha: 0.20),
                    iconColor: _HtmlColors.primary,
                    badgeBg: _HtmlColors.surfaceBright,
                    badgeColor: _HtmlColors.secondary,
                    onTap: () => _hizliDemoGiris(KullaniciTuru.kktcVatandas),
                  ),
                  const SizedBox(height: 8),

                  // Demo 2: T.C. Vatandaşı / KKTC İkamet
                  _demoCard(
                    icon: Icons.credit_card_rounded,
                    name: widget.turkceMi ? 'Mehmet Yılmaz' : 'Mehmet Yilmaz',
                    badge: widget.turkceMi ? 'T.C. İkamet / Çalışma' : 'TR Resident',
                    subtitle: 'Renault Megane Sedan (T.C. İkamet / YKN)',
                    iconBg: const Color(0xFF0284C7).withValues(alpha: 0.20),
                    iconColor: const Color(0xFF38BDF8),
                    badgeBg: const Color(0xFF0284C7).withValues(alpha: 0.30),
                    badgeColor: const Color(0xFF7DD3FC),
                    onTap: () => _hizliDemoGiris(KullaniciTuru.tcVatandas),
                  ),
                  const SizedBox(height: 8),

                  // Demo 3: Öğrenci (ODTÜ / DAÜ / YDÜ)
                  _demoCard(
                    icon: Icons.school_rounded,
                    name: widget.turkceMi ? 'Tubi (ODTÜ / DAÜ Öğrencisi)' : 'Tubi (Student Profile)',
                    badge: widget.turkceMi ? 'Kampüs Araç Pulu' : 'Campus Permit',
                    subtitle: 'Honda Civic & VW Polo (ODTÜ / DAÜ Pulu)',
                    iconBg: const Color(0xFF007C55).withValues(alpha: 0.20),
                    iconColor: _HtmlColors.tertiary,
                    badgeBg: const Color(0xFF007C55).withValues(alpha: 0.30),
                    badgeColor: _HtmlColors.tertiary,
                    onTap: () => _hizliDemoGiris(KullaniciTuru.ogrenci, uniKod: "ODTU"),
                  ),
                  const SizedBox(height: 8),

                  // Demo 4: Uluslararası / Pasaport
                  _demoCard(
                    icon: Icons.public_rounded,
                    name: 'Alex Smith',
                    badge: widget.turkceMi ? 'Uluslararası / UK' : 'International / UK',
                    subtitle: 'Toyota Corolla (Geçici İkamet İzni / Pasaport)',
                    iconBg: const Color(0xFF6D28D9).withValues(alpha: 0.20),
                    iconColor: const Color(0xFFA78BFA),
                    badgeBg: const Color(0xFF6D28D9).withValues(alpha: 0.30),
                    badgeColor: const Color(0xFFDDD6FE),
                    onTap: () => _hizliDemoGiris(KullaniciTuru.uluslararasi),
                  ),
                  const SizedBox(height: 24),

                  // ── Security Footer ──
                  Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_outline, color: _HtmlColors.tertiary, size: 14),
                            const SizedBox(width: 6),
                            const Text(
                              '256-Bit SSL Uçtan Uca Şifreleme',
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
                          'KKTC Polis Genel Müdürlüğü & Bayındırlık\nve Ulaştırma Bakanlığı Trafik Portalı',
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
                              widget.turkceMi ? 'Yardım Masası' : 'Help Desk',
                              style: const TextStyle(
                                color: _HtmlColors.secondary,
                                fontSize: 11,
                                decoration: TextDecoration.underline,
                                decorationColor: _HtmlColors.secondary,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('•', style: TextStyle(color: _HtmlColors.outlineVariant)),
                            ),
                            Text(
                              widget.turkceMi ? 'Trafik Çağrı: 155' : 'Traffic Hotline: 155',
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

  // ── Helper widgets ──

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

  Widget _roleChip({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? _HtmlColors.surfaceContainerHigh : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? _HtmlColors.primaryContainer.withValues(alpha: 0.6) : Colors.transparent,
            width: 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected ? _HtmlColors.primary : _HtmlColors.secondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? _HtmlColors.onSurface : _HtmlColors.secondary,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _HtmlColors.onSurface,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
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
      ),
      _cezaVeSigortaEkrani(
        markaModel: markaModel,
        cezalar: cezalar,
        sigortaGun: sigortaGun,
        muayeneGun: muayeneGun,
        ehliyetPuani: ehliyetPuani,
      ),
      _menuHizmetlerEkrani(
        ehliyetPuani: ehliyetPuani,
        markaModel: markaModel,
      ),
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
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
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
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _HtmlColors.tertiary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _HtmlColors.tertiary.withValues(alpha: 0.35)),
                          ),
                          child: const Icon(Icons.help_outline_rounded, color: _HtmlColors.tertiary, size: 21),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Avatar circle
                      GestureDetector(
                        onTap: () => setState(() => _seciliIndex = 3),
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
    ),
  ),
  body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              KamuSunucuDurumSeridi(turkceMi: widget.turkceMi),
              Expanded(
                child: sayfalar[_seciliIndex],
              ),
            ],
          ),
        ),
      ),
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
                        widget.turkceMi ? 'Cezalar' : 'Fines',
                        rozet: odenmemisCezaSayisi,
                      ),
                      _navItem(
                        3,
                        Icons.grid_view_rounded,
                        widget.turkceMi ? 'Menü' : 'Menu',
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
                            const SizedBox(height: 2),
                            Text(
                              '${g['tarih']} • ${g['kod']}',
                              style: const TextStyle(
                                color: _HtmlColors.secondary,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                      Container(
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
                    // Başlık ve Durum Rozeti
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0EA5E9).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF0EA5E9).withValues(alpha: 0.3)),
                              ),
                              child: const Icon(
                                Icons.account_balance_rounded,
                                color: Color(0xFF38BDF8),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.turkceMi ? 'KKTC MALİYE BAKANLIĞI' : 'TRNC MINISTRY OF FINANCE',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFE0F2FE),
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.turkceMi ? 'Gelir ve Vergi Dairesi • Araç Kayıt' : 'Revenue & Tax Dept. • Vehicle Reg.',
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
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
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
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
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
                              Row(
                                children: [
                                  Icon(
                                    Icons.hourglass_top_rounded,
                                    size: 20,
                                    color: acil ? Colors.amber : const Color(0xFF38BDF8),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
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
                                      Text(
                                        gecerli
                                            ? (widget.turkceMi ? '$kalanGun Gün Kaldı' : '$kalanGun Days Left')
                                            : (widget.turkceMi ? 'Süresi Doldu!' : 'Expired!'),
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: gecerli ? (acil ? Colors.amber : Colors.white) : Colors.redAccent,
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
                                    widget.turkceMi ? 'Bitiş Tarihi' : 'Expiry Date',
                                    style: const TextStyle(fontSize: 10, color: _HtmlColors.secondary),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    bitisTarihi,
                                    style: const TextStyle(
                                      fontSize: 13,
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
              Row(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.turkceMi ? 'Son Dönem Seyrüsefer Makbuzu' : 'Previous Period Receipt',
                        style: const TextStyle(color: _HtmlColors.onSurface, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.turkceMi ? '2025/2. Yıllık Dönem • Makbuz: #SYR-89210' : '2025/2 Period • Receipt: #SYR-89210',
                        style: const TextStyle(color: _HtmlColors.secondary, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
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
        Text(
          deger,
          style: TextStyle(
            color: isAlert ? Colors.redAccent : _HtmlColors.onSurface,
            fontSize: 11,
            fontWeight: FontWeight.bold,
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
          child: RichText(
            overflow: TextOverflow.ellipsis,
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
      ],
    );
  }

  // --- TAB 0: RADAR & CANLI SÜRÜŞ EKRANI (Ana Sayfa Açılışı) ---
  Widget _radarSurusEkrani({
    required int odenmemisCezaSayisi,
    required int toplamBorc,
    required int sigortaGun,
  }) {
    return Column(
      children: [
        // Sürücü Durum & Ceza İkaz Şeridi
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: odenmemisCezaSayisi > 0
              ? Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      setState(() {
                        _seciliIndex = 2;
                        _cezaSigortaAltSekme = 'ceza';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_HtmlColors.errorContainer, Color(0xFF6B0006)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _HtmlColors.primaryContainer, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: _HtmlColors.errorContainer.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.turkceMi
                                      ? '$odenmemisCezaSayisi Adet Ödenmemiş Ceza (₺$toplamBorc)'
                                      : '$odenmemisCezaSayisi Unpaid Ticket(s) (₺$toplamBorc)',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.turkceMi
                                      ? 'İndirimli ödemek veya itiraz etmek için dokunun'
                                      : 'Tap to pay with discount or file dispute',
                                  style: const TextStyle(
                                    color: Color(0xFFFFDAD6),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                        ],
                      ),
                    ),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _HtmlColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _HtmlColors.tertiary.withValues(alpha: 0.25), width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: _HtmlColors.tertiary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        widget.turkceMi ? 'Tüm Cezalar Ödenmiş' : 'All Fines Settled',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _HtmlColors.tertiaryContainer.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.turkceMi ? 'Sigorta Aktif ($sigortaGun G)' : 'Insurance OK ($sigortaGun D)',
                          style: const TextStyle(
                            color: _HtmlColors.tertiary,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        // Ana Radar ve Canlı Hız Uyarı Haritası
        Expanded(
          child: RadarHaritasiSayfasi(turkceMi: widget.turkceMi),
        ),
      ],
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

  // --- TAB 2: MENÜ & RESMİ HİZMETLER (Kıdemli ve Sade Tasarım) ---
  Widget _menuHizmetlerEkrani({
    required int ehliyetPuani,
    required String markaModel,
  }) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      physics: const BouncingScrollPhysics(),
      children: [
        // Sürücü Profil Kartı
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _HtmlColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: _HtmlColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded, color: _HtmlColors.onPrimary, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.kullaniciAdi.isNotEmpty ? widget.kullaniciAdi : 'Ahmet Demir',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _HtmlColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.kullaniciRolu.isNotEmpty
                          ? widget.kullaniciRolu
                          : (widget.turkceMi ? 'KKTC Kayıtlı Sürücü Belgesi' : 'TRNC Registered Driver License'),
                      style: const TextStyle(fontSize: 12, color: _HtmlColors.secondary),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _HtmlColors.tertiaryContainer.withValues(alpha: 0.30),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.turkceMi ? 'Ehliyet Puanı: $ehliyetPuani / 100' : 'License Points: $ehliyetPuani / 100',
                        style: const TextStyle(
                          color: _HtmlColors.tertiaryFixed,
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
        const SizedBox(height: 14),

        // Hızlı Acil Yardım & Yol Yardım Kutusu
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _HtmlColors.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _acilButon(
                ikon: Icons.local_police_rounded,
                baslik: widget.turkceMi ? 'Polis 155' : 'Police 155',
                renk: _HtmlColors.primaryContainer,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(widget.turkceMi ? '155 Polis İmdat aranıyor...' : 'Calling 155 Police...'),
                    ),
                  );
                },
              ),
              Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.08)),
              _acilButon(
                ikon: Icons.medical_services_rounded,
                baslik: widget.turkceMi ? 'Acil 112' : 'Ambulance 112',
                renk: const Color(0xFFF59E0B),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(widget.turkceMi ? '112 Acil Servis aranıyor...' : 'Calling 112 Ambulance...'),
                    ),
                  );
                },
              ),
              Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.08)),
              _acilButon(
                ikon: Icons.car_repair_rounded,
                baslik: widget.turkceMi ? 'Çekici 7/24' : 'Towing 24/7',
                renk: _HtmlColors.tertiary,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(widget.turkceMi ? '7/24 KKTC Yol Yardım: 0392 228 88 88' : 'Calling 24/7 Towing...'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Büyük Hizmet Menü Kartları
        _buyukMenuKarti(
          ikon: Icons.help_center_rounded,
          ikonRenk: const Color(0xFF38BDF8),
          baslik: widget.turkceMi ? 'Yardım & Akıllı Rota Rehberi' : 'Help & Smart Route Guide',
          aciklama: widget.turkceMi
              ? 'Nasıl gidilir, KKTC sürüş kuralları, acil numaralar ve S.S.S.'
              : 'How to navigate, TRNC driving rules, emergencies & FAQs',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => YardimRehberiSayfasi(turkceMi: widget.turkceMi),
            ),
          ),
        ),
        const SizedBox(height: 10),

        _buyukMenuKarti(
          ikon: Icons.qr_code_2_rounded,
          ikonRenk: _HtmlColors.primary,
          baslik: widget.turkceMi ? 'Barkodlu Resmi Sürücü Belgesi' : 'Official Barcoded Driver License',
          aciklama: widget.turkceMi ? 'Polis denetimlerinde gösterilebilir dijital ehliyet' : 'Digital license with QR verification',
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
        const SizedBox(height: 10),

        _buyukMenuKarti(
          ikon: Icons.receipt_long_rounded,
          ikonRenk: _HtmlColors.tertiary,
          baslik: widget.turkceMi ? 'Ödeme Dekontlarım & Geçmiş' : 'Payment Slips & History',
          aciklama: widget.turkceMi ? 'Ödenen cezalar ve sigorta yenileme makbuzları' : 'Official paid receipts and invoices',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DekontlarSayfasi(dekontlar: _dekontlar, turkceMi: widget.turkceMi),
            ),
          ),
        ),
        const SizedBox(height: 10),

        _buyukMenuKarti(
          ikon: Icons.gavel_rounded,
          ikonRenk: const Color(0xFFF59E0B),
          baslik: widget.turkceMi ? 'Trafik Hakem Heyeti İtirazı' : 'Traffic Dispute & Petition',
          aciklama: widget.turkceMi ? 'Hatalı yazılan cezalara online resmi itiraz dilekçesi' : 'Submit petition for incorrect traffic fines',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItirazSayfasi(turkceMi: widget.turkceMi),
            ),
          ),
        ),
        const SizedBox(height: 10),

        _buyukMenuKarti(
          ikon: Icons.notifications_active_outlined,
          ikonRenk: const Color(0xFFA78BFA),
          baslik: widget.turkceMi ? 'Sesli Uyarı & Hatırlatıcı Ayarları' : 'Audio Alerts & Reminders',
          aciklama: widget.turkceMi ? 'Radar yaklaşım sesi, sigorta ve muayene ikazları' : 'Speed proximity sound & renewal alerts',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BildirimAyarlariSayfasi(turkceMi: widget.turkceMi),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Güvenli Çıkış Butonu
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _HtmlColors.surfaceContainerLow,
              foregroundColor: const Color(0xFFFFB4AB),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: _HtmlColors.errorContainer.withValues(alpha: 0.5)),
              ),
            ),
            onPressed: widget.onCikisYap,
            icon: const Icon(Icons.logout_rounded, size: 20),
            label: Text(
              widget.turkceMi ? 'Güvenli Çıkış Yap' : 'Secure Logout',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Kurumsal Alt Bilgi
        Center(
          child: Text(
            widget.turkceMi ? 'KKTC Polis Genel Müdürlüğü Trafik Portalı v2.0' : 'TRNC Police Headquarters Portal v2.0',
            style: const TextStyle(fontSize: 11, color: _HtmlColors.secondary),
          ),
        ),
      ],
    );
  }

  Widget _acilButon({
    required IconData ikon,
    required String baslik,
    required Color renk,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ikon, color: renk, size: 18),
            const SizedBox(width: 6),
            Text(
              baslik,
              style: const TextStyle(
                color: _HtmlColors.onSurface,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buyukMenuKarti({
    required IconData ikon,
    required Color ikonRenk,
    required String baslik,
    required String aciklama,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _HtmlColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: ikonRenk.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(ikon, color: ikonRenk, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      baslik,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _HtmlColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      aciklama,
                      style: const TextStyle(
                        fontSize: 11,
                        color: _HtmlColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, color: _HtmlColors.secondary, size: 14),
            ],
          ),
        ),
      ),
    );
  }

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
