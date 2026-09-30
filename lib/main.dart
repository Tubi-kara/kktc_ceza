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
// 🚀 1. MODERN GİRİŞ SAYFASI
// ==========================================
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

class _GirisSayfasiState extends State<GirisSayfasi> {
  final TextEditingController _girisController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();
  bool _kktcVatandasiMi = true;
  bool _sifreGizli = true;

  @override
  void dispose() {
    _girisController.dispose();
    _sifreController.dispose();
    super.dispose();
  }

  void _girisYap() {
    String numara = _girisController.text.trim();
    String sifre = _sifreController.text.trim();

    if (numara.isEmpty || sifre.isEmpty) {
      _snack(
        widget.turkceMi
            ? 'Lütfen kullanıcı adı / kimlik no ve şifre girin.'
            : 'Please enter credentials to proceed.',
        isError: true,
      );
      return;
    }

    List<String> tanimliAraclar = [];
    String adSoyad = "";

    if (!_kktcVatandasiMi) {
      if (numara.toLowerCase() == "tubi" && sifre == "tugkan3517") {
        adSoyad = widget.turkceMi ? "Tubi (Öğrenci)" : "Tubi (Student)";
        tanimliAraclar = ["ST 999", "GM 202"];
      } else {
        _snack(
          widget.turkceMi
              ? 'Hatalı öğrenci adı veya şifre! (tubi / tugkan3517)'
              : 'Invalid student username or password! (tubi / tugkan3517)',
          isError: true,
        );
        return;
      }
    } else {
      adSoyad = widget.turkceMi ? "Ahmet Demir" : "Ahmet Demir (Citizen)";
      tanimliAraclar = ["RZ 123", "LZ 555"];
    }

    widget.onGirisBasarili(adSoyad, tanimliAraclar);
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
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Arka plan modern gradient & ambient ışık halkaları
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.35),
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.2),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Üst Dil Seçici
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.shield_outlined, color: Colors.white, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              widget.turkceMi ? 'Resmi Kamu Portalı' : 'Official Portal',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                        ),
                        child: Row(
                          children: [
                            _dilButon(label: '🇹🇷 TR', secili: widget.turkceMi, onTap: () => widget.onDilDegistir(true)),
                            _dilButon(label: '🇬🇧 EN', secili: !widget.turkceMi, onTap: () => widget.onDilDegistir(false)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo & Başlık
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, Color(0xFFFB7185)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.45),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.traffic_rounded, size: 38, color: Colors.white),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            widget.turkceMi ? 'KKTC e-Trafik' : 'TRNC e-Traffic',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.turkceMi
                                ? 'Kuzey Kıbrıs Türk Cumhuriyeti Ceza & Trafik Portalı'
                                : 'Turkish Republic of Northern Cyprus Traffic Portal',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Form Kartı
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Sekme Geçişi: KKTC Kimlik vs Öğrenci
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceMuted,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _rolSekme(
                                          baslik: widget.turkceMi ? 'KKTC Vatandaş' : 'TRNC Citizen',
                                          ikon: Icons.badge_outlined,
                                          secili: _kktcVatandasiMi,
                                          onTap: () => setState(() => _kktcVatandasiMi = true),
                                        ),
                                      ),
                                      Expanded(
                                        child: _rolSekme(
                                          baslik: widget.turkceMi ? 'Öğrenci (Tubi)' : 'Student (Tubi)',
                                          ikon: Icons.school_outlined,
                                          secili: !_kktcVatandasiMi,
                                          onTap: () => setState(() => _kktcVatandasiMi = false),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 22),

                                // Giriş Alanı
                                Text(
                                  _kktcVatandasiMi
                                      ? (widget.turkceMi ? 'Kimlik Numarası' : 'Identity Number')
                                      : (widget.turkceMi ? 'Öğrenci Kullanıcı Adı' : 'Student Username'),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.slate700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _girisController,
                                  decoration: InputDecoration(
                                    hintText: _kktcVatandasiMi ? 'Örn: 123456789' : 'tubi',
                                    hintStyle: const TextStyle(color: AppColors.slate400, fontSize: 14),
                                    prefixIcon: Icon(
                                      _kktcVatandasiMi ? Icons.fingerprint_rounded : Icons.account_circle_outlined,
                                      color: AppColors.slate500,
                                    ),
                                    filled: true,
                                    fillColor: AppColors.surfaceMuted,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // Şifre Alanı
                                Text(
                                  widget.turkceMi ? 'Şifre' : 'Password',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.slate700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _sifreController,
                                  obscureText: _sifreGizli,
                                  decoration: InputDecoration(
                                    hintText: _kktcVatandasiMi ? '••••••' : 'tugkan3517',
                                    hintStyle: const TextStyle(color: AppColors.slate400, fontSize: 14),
                                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.slate500),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _sifreGizli ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        color: AppColors.slate400,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(() => _sifreGizli = !_sifreGizli),
                                    ),
                                    filled: true,
                                    fillColor: AppColors.surfaceMuted,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Giriş Butonu
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: _girisYap,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          widget.turkceMi ? 'Güvenli Giriş Yap' : 'Secure Login',
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward_rounded, size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Hızlı Demo Butonları
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          side: const BorderSide(color: AppColors.slate200),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        onPressed: () => _hizliDemoGiris(false),
                                        icon: const Icon(Icons.person, size: 16, color: AppColors.slate700),
                                        label: Text(
                                          widget.turkceMi ? 'Vatandaş Demo' : 'Citizen Demo',
                                          style: const TextStyle(fontSize: 12, color: AppColors.slate700, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                                          backgroundColor: AppColors.primaryLight.withValues(alpha: 0.4),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        onPressed: () => _hizliDemoGiris(true),
                                        icon: const Icon(Icons.flash_on_rounded, size: 16, color: AppColors.primary),
                                        label: Text(
                                          widget.turkceMi ? 'Tubi Demo' : 'Tubi Demo',
                                          style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Geliştirici İmzası
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified_user_rounded, color: Colors.white70, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  widget.turkceMi ? 'Geliştiren: Tuğberk Kara' : 'Developed by: Tuğberk Kara',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w500,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dilButon({required String label, required bool secili, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: secili ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: secili ? AppColors.slate900 : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _rolSekme({required String baslik, required IconData ikon, required bool secili, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: secili ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: secili
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ikon, size: 16, color: secili ? AppColors.primary : AppColors.slate500),
            const SizedBox(width: 6),
            Text(
              baslik,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: secili ? AppColors.primary : AppColors.slate500,
              ),
            ),
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

class _AnaSayfaTabsState extends State<AnaSayfaTabs> {
  int _seciliIndex = 0;
  String _secilenPlaka = "";
  String _cezaFiltre = "hepsi"; // hepsi, odenmedi, odendi

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

  @override
  void initState() {
    super.initState();
    if (widget.araclar.isNotEmpty) {
      _secilenPlaka = widget.araclar.first;
    }
  }

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _baslikDondur(_seciliIndex),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.slate900),
            ),
            Text(
              widget.turkceMi ? 'Kuzey Kıbrıs Türk Cumhuriyeti' : 'Turkish Republic of Northern Cyprus',
              style: const TextStyle(fontSize: 11, color: AppColors.slate500, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(20),
            ),
            child: PopupMenuButton<bool>(
              tooltip: widget.turkceMi ? 'Dil Değiştir' : 'Change Language',
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.turkceMi ? '🇹🇷 TR' : '🇬🇧 EN', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.slate700),
                ],
              ),
              onSelected: (bool yeniTurkceMi) => widget.onDilDegistir(yeniTurkceMi),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<bool>>[
                const PopupMenuItem<bool>(value: true, child: Text('🇹🇷 Türkçe')),
                const PopupMenuItem<bool>(value: false, child: Text('🇬🇧 English')),
              ],
            ),
          ),
        ],
      ),
      body: sayfalar[_seciliIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.slate200, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.dashboard_rounded, Icons.dashboard_outlined, widget.turkceMi ? 'Özet' : 'Overview'),
                _navItem(1, Icons.radar_rounded, Icons.radar_outlined, widget.turkceMi ? 'Radarlar' : 'Radars'),
                _navItem(2, Icons.receipt_long_rounded, Icons.receipt_long_outlined, widget.turkceMi ? 'Cezalar' : 'Fines', rozet: odenmemisCezaSayisi),
                _navItem(3, Icons.verified_user_rounded, Icons.verified_user_outlined, widget.turkceMi ? 'Sigorta' : 'Insurance'),
                _navItem(4, Icons.person_rounded, Icons.person_outline_rounded, widget.turkceMi ? 'Profil' : 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData aktifIkon, IconData pasifIkon, String etiket, {int rozet = 0}) {
    bool secili = _seciliIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _seciliIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: secili ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  secili ? aktifIkon : pasifIkon,
                  size: 22,
                  color: secili ? AppColors.primary : AppColors.slate500,
                ),
                if (rozet > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
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
            if (secili) ...[
              const SizedBox(width: 8),
              Text(
                etiket,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- TAB 1: ANA SAYFA ÖZETİ ---
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
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sürücü Profil Kartı
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          widget.kullaniciAdi.isNotEmpty ? widget.kullaniciAdi[0] : 'U',
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.kullaniciAdi,
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.verified_rounded, color: AppColors.info, size: 18),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.turkceMi ? 'Doğrulanmış KKTC Sürücü Kimliği' : 'Verified TRNC Driver License',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.health_and_safety_outlined, color: AppColors.success, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            widget.turkceMi ? 'Ehliyet Sağlık Skoru' : 'Driver Safety Score',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: ehliyetPuani >= 80 ? AppColors.success.withValues(alpha: 0.2) : AppColors.warning.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$ehliyetPuani / 100',
                          style: TextStyle(
                            color: ehliyetPuani >= 80 ? AppColors.success : AppColors.warning,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Araç Seçici
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.turkceMi ? 'Kayıtlı Araçlarım' : 'My Registered Vehicles',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.slate900),
              ),
              Text(
                '${widget.araclar.length} ${widget.turkceMi ? 'Araç' : 'Vehicles'}',
                style: const TextStyle(fontSize: 12, color: AppColors.slate500, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.araclar.length,
              itemBuilder: (context, index) {
                String plaka = widget.araclar[index];
                bool secili = (_secilenPlaka == plaka);
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _secilenPlaka = plaka),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: secili ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: secili ? AppColors.primary : AppColors.slate200,
                          width: 1.2,
                        ),
                        boxShadow: secili
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.directions_car_filled_rounded,
                            size: 16,
                            color: secili ? Colors.white : AppColors.slate500,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            plaka,
                            style: TextStyle(
                              color: secili ? Colors.white : AppColors.slate700,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
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
          const SizedBox(height: 18),

          // Seçili Araç Genel Durumu
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.slate200, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            markaModel,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.slate900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.turkceMi ? 'Plaka' : 'Plate'}: $_secilenPlaka',
                            style: const TextStyle(fontSize: 12, color: AppColors.slate500, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: odenmemisCezaSayisi == 0 ? AppColors.successLight : AppColors.dangerLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        odenmemisCezaSayisi == 0
                            ? (widget.turkceMi ? 'Temiz' : 'Clear')
                            : '$odenmemisCezaSayisi ${widget.turkceMi ? 'Ceza' : 'Fines'}',
                        style: TextStyle(
                          color: odenmemisCezaSayisi == 0 ? AppColors.success : AppColors.danger,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28, color: AppColors.slate200),

                // Sigorta & Muayene Sayaçları
                Row(
                  children: [
                    Expanded(
                      child: _durumKarti(
                        baslik: widget.turkceMi ? 'Zorunlu Sigorta' : 'Insurance',
                        kalanGun: sigortaGun,
                        ikon: Icons.security_rounded,
                        onYenile: () => _sigortaYenile(_secilenPlaka),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _durumKarti(
                        baslik: widget.turkceMi ? 'Araç Muayene' : 'Inspection',
                        kalanGun: muayeneGun,
                        ikon: Icons.build_circle_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 📍 KKTC CANLI RADAR & KAMERA HARİTASI BANNERI
          GestureDetector(
            onTap: () => setState(() => _seciliIndex = 1),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.5)),
                    ),
                    child: const Icon(Icons.radar_rounded, color: Color(0xFFDC2626), size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.turkceMi ? 'KKTC Canlı Radar Haritası' : 'TRNC Live Radar Map',
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('CANLI', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.turkceMi
                              ? '18 Sabit Hız & Kırmızı Işık Kamerası Aktif'
                              : '18 Speed & Traffic Cameras Active',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),

          // Hızlı İşlemler
          Text(
            widget.turkceMi ? 'Hızlı İşlemler' : 'Quick Actions',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.slate900),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _hizliIslemButon(
                  ikon: Icons.radar_rounded,
                  baslik: widget.turkceMi ? 'Radarlar' : 'Radars',
                  renk: AppColors.primary,
                  onTap: () => setState(() => _seciliIndex = 1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _hizliIslemButon(
                  ikon: Icons.qr_code_2_rounded,
                  baslik: widget.turkceMi ? 'Barkodlu' : 'QR Doc',
                  renk: AppColors.info,
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
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _hizliIslemButon(
                  ikon: Icons.receipt_long_rounded,
                  baslik: widget.turkceMi ? 'Dekont' : 'Receipts',
                  renk: AppColors.success,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DekontlarSayfasi(dekontlar: _dekontlar, turkceMi: widget.turkceMi),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _hizliIslemButon(
                  ikon: Icons.gavel_rounded,
                  baslik: widget.turkceMi ? 'İtiraz' : 'Appeal',
                  renk: AppColors.warning,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItirazSayfasi(turkceMi: widget.turkceMi),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Son Cezalar Başlığı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.turkceMi ? 'Son Cezalar & İhlaller' : 'Recent Violations',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.slate900),
              ),
              TextButton(
                onPressed: () => setState(() => _seciliIndex = 2),
                child: Text(
                  widget.turkceMi ? 'Tümünü Gör' : 'View All',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (cezalar.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.successLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 36),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.turkceMi ? 'Seçili araçta kayıtlı aktif ceza bulunmuyor.' : 'No active violations found for this vehicle.',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.slate900),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.turkceMi ? 'Güvenli sürüşler dileriz! 🎉' : 'Drive safely! 🎉',
                    style: const TextStyle(fontSize: 12, color: AppColors.slate500),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cezalar.length > 2 ? 2 : cezalar.length,
              itemBuilder: (context, index) {
                final ceza = cezalar[index];
                return _cezaKarti(ceza);
              },
            ),
          const SizedBox(height: 24),

          // Alt İsim İmzası
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.turkceMi ? 'Geliştiren: Tuğberk Kara' : 'Developed by: Tuğberk Kara',
                style: const TextStyle(fontSize: 11, color: AppColors.slate500, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _durumKarti({required String baslik, required int kalanGun, required IconData ikon, VoidCallback? onYenile}) {
    bool kritik = kalanGun < 15;
    Color renk = kritik ? AppColors.danger : (kalanGun < 45 ? AppColors.warning : AppColors.success);
    Color zemin = kritik ? AppColors.dangerLight : (kalanGun < 45 ? AppColors.warningLight : AppColors.successLight);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kritik ? AppColors.danger.withValues(alpha: 0.3) : AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(ikon, color: renk, size: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: zemin, borderRadius: BorderRadius.circular(10)),
                child: Text(
                  '$kalanGun ${widget.turkceMi ? 'Gün' : 'Days'}',
                  style: TextStyle(color: renk, fontWeight: FontWeight.w800, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(baslik, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slate700)),
          const SizedBox(height: 2),
          Text(
            kritik
                ? (widget.turkceMi ? 'Süresi Dolmak Üzere!' : 'Expiring Soon!')
                : (widget.turkceMi ? 'Geçerli' : 'Valid'),
            style: TextStyle(fontSize: 11, color: renk, fontWeight: FontWeight.w600),
          ),
          if (kritik && onYenile != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onYenile,
              child: Text(
                widget.turkceMi ? 'Yenile →' : 'Renew →',
                style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _hizliIslemButon({required IconData ikon, required String baslik, required Color renk, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.slate200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: renk.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(ikon, color: renk, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              baslik,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slate900),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 2: CEZALARIM GÖRÜNÜMÜ ---
  Widget _cezalarimGorunumu({required List cezalar}) {
    List filtrelenmis = cezalar.where((c) {
      if (_cezaFiltre == "odenmedi") return c['odendi'] == false;
      if (_cezaFiltre == "odendi") return c['odendi'] == true;
      return true;
    }).toList();

    return Column(
      children: [
        // Filtre Sekmeleri
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              _cezaFiltreChip(etiket: widget.turkceMi ? 'Tümü' : 'All', deger: "hepsi"),
              const SizedBox(width: 8),
              _cezaFiltreChip(etiket: widget.turkceMi ? 'Ödenmemiş' : 'Unpaid', deger: "odenmedi"),
              const SizedBox(width: 8),
              _cezaFiltreChip(etiket: widget.turkceMi ? 'Ödenmiş' : 'Paid', deger: "odendi"),
            ],
          ),
        ),

        Expanded(
          child: filtrelenmis.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: AppColors.successLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle_outline, color: AppColors.success, size: 48),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.turkceMi ? 'Bu filtrede ceza kaydı bulunmuyor.' : 'No records found in this category.',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.slate700),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtrelenmis.length,
                  itemBuilder: (context, index) {
                    final ceza = filtrelenmis[index];
                    return _cezaKarti(ceza);
                  },
                ),
        ),
      ],
    );
  }

  Widget _cezaFiltreChip({required String etiket, required String deger}) {
    bool secili = _cezaFiltre == deger;
    return GestureDetector(
      onTap: () => setState(() => _cezaFiltre = deger),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: secili ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: secili ? AppColors.primary : AppColors.slate200),
        ),
        child: Text(
          etiket,
          style: TextStyle(
            color: secili ? Colors.white : AppColors.slate700,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _cezaKarti(Map<String, dynamic> ceza) {
    bool odendi = ceza['odendi'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CezaDetaySayfasi(
                ceza: ceza,
                turkceMi: widget.turkceMi,
                onOdemeYap: () {
                  _cezaOdemeGuncelle(_secilenPlaka, ceza['id'], ceza['tur'], ceza['turEn'], ceza['tutar']);
                },
              ),
            ),
          );
          setState(() {});
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: odendi ? AppColors.successLight : AppColors.dangerLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      odendi ? (widget.turkceMi ? 'ÖDENDİ' : 'PAID') : (widget.turkceMi ? 'ÖDENMEDİ' : 'UNPAID'),
                      style: TextStyle(
                        color: odendi ? AppColors.success : AppColors.danger,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    ceza['tutar'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.slate900),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.turkceMi ? ceza['tur'] : ceza['turEn'],
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.slate900),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.slate500),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      ceza['konum'] ?? '',
                      style: const TextStyle(fontSize: 12, color: AppColors.slate500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.slate400),
                      const SizedBox(width: 5),
                      Text(ceza['tarih'], style: const TextStyle(fontSize: 12, color: AppColors.slate500, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        widget.turkceMi ? 'Detay & Kanıt' : 'Details & Evidence',
                        style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 18),
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

  // --- TAB 3: SİGORTA VE POLİÇE YÖNETİMİ ---
  Widget _sigortaGorunumu({required String markaModel, required int sigortaGun, required int muayeneGun}) {
    bool aktif = sigortaGun > 0;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Apple Wallet tarzı Modern Dijital Poliçe Kartı
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
                              widget.turkceMi ? 'KKTC TRAFİK SİGORTASI' : 'TRNC TRAFFIC INSURANCE',
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
                        aktif ? (widget.turkceMi ? 'POLİÇE AKTİF' : 'ACTIVE') : (widget.turkceMi ? 'SÜRESİ DOLMUŞ' : 'EXPIRED'),
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
                        Text(widget.turkceMi ? 'Kalan Gün' : 'Days Remaining', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
                        const SizedBox(height: 2),
                        Text('$sigortaGun ${widget.turkceMi ? 'Gün' : 'Days'}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(widget.turkceMi ? 'Poliçe No' : 'Policy No', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
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
                  widget.turkceMi ? 'Teminat Kapsamı' : 'Coverage Scope',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.slate900),
                ),
                const SizedBox(height: 12),
                _teminatSatiri(widget.turkceMi ? '3. Şahıs Maddi Zararlar' : '3rd Party Material Damage', '500.000 TL'),
                _teminatSatiri(widget.turkceMi ? 'Bedeni Zararlar ve Tedavi' : 'Bodily Harm & Medical', '1.000.000 TL'),
                _teminatSatiri(widget.turkceMi ? 'Hukuksal Koruma & Çekici' : 'Legal & Towing Support', widget.turkceMi ? 'Dahil' : 'Included'),
                const Divider(height: 24, color: AppColors.slate200),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.turkceMi ? 'Yıllık Poliçe Ücreti' : 'Annual Fee',
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
                widget.turkceMi ? 'Hemen Sigortayı Yenile (4500 TL)' : 'Instantly Renew Policy (4500 TL)',
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

  // --- TAB 4: PROFİL & BELGELER ---
  Widget _profilGorunumu({required int ehliyetPuani}) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        // Sürücü Kartı
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
                      widget.turkceMi ? 'KKTC Kayıtlı Sürücü Belgesi Sahibi' : 'TRNC Registered Driver License Holder',
                      style: const TextStyle(fontSize: 12, color: AppColors.slate500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Menü Öğeleri
        _profilMenuKutusu(
          children: [
            _profilMenuItem(
              ikon: Icons.qr_code_2_rounded,
              ikonRenk: AppColors.info,
              baslik: widget.turkceMi ? 'Barkodlu Sürücü Belgesi' : 'Barcoded Driver Certificate',
              altBaslik: widget.turkceMi ? 'Taranabilir ve çalışır QR doğrulaması' : 'Interactive QR verification code',
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
              baslik: widget.turkceMi ? 'Ödeme Dekontları' : 'Payment Receipts',
              altBaslik: widget.turkceMi ? 'Resmi tahsilat makbuzları ve PDF arşivi' : 'Official payment slips & archive',
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
              baslik: widget.turkceMi ? 'Cezaya İtiraz Başvurusu' : 'Fine Objection Application',
              altBaslik: widget.turkceMi ? 'Hatalı veya radar itiraz dilekçesi gönder' : 'Submit petition for incorrect fines',
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
              baslik: widget.turkceMi ? 'Bildirim ve Hatırlatıcılar' : 'Notifications & Reminders',
              altBaslik: widget.turkceMi ? 'Sigorta ve muayene son gün uyarıları' : 'Insurance & inspection alerts',
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

        // Çıkış Yap
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
              widget.turkceMi ? 'Güvenli Çıkış Yap' : 'Secure Logout',
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
                widget.turkceMi ? 'KKTC Polis Genel Müdürlüğü Bilgi İşlem Portalı' : 'TRNC Police Headquarters IT Portal',
                style: const TextStyle(fontSize: 11, color: AppColors.slate400, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                widget.turkceMi ? 'Geliştiren: Tuğberk Kara' : 'Developed by: Tuğberk Kara',
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
        case 0: return 'e-Trafik Özet';
        case 1: return 'KKTC Radar & Kameralar';
        case 2: return 'Trafik Cezalarım';
        case 3: return 'Sigorta Poliçeleri';
        case 4: return 'Sürücü Profilim';
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