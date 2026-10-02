import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// KKTC e-Trafik Modern Güvenli Giriş ve Kayıt Sayfası
/// Bayındırlık ve Ulaştırma Bakanlığı & Trafik Portalı kurumsal kimliği ile
/// Üniversite öğrencileri (ODTÜ, DAÜ, YDÜ, GDU vb.), T.C. vatandaşları,
/// uluslararası sürücüler ve KKTC vatandaşları için tam kayıt ve giriş modülüdür.
class KktcETrafikGirisSayfasi extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const KktcETrafikGirisSayfasi({
    super.key,
    this.onLoginSuccess,
  });

  @override
  State<KktcETrafikGirisSayfasi> createState() => _KktcETrafikGirisSayfasiState();
}

class _KktcETrafikGirisSayfasiState extends State<KktcETrafikGirisSayfasi>
    with SingleTickerProviderStateMixin {
  // Renk Paleti (HTML tasarımındaki tokenlar ile birebir)
  static const Color cBg = Color(0xFF010E3C);
  static const Color cAccent = Color(0xFFD1C929);
  static const Color cText = Color(0xFFE3E3E3);
  static const Color cMuted = Color(0xFF747675);

  // Giriş Form Kontrolleri (Sürüş Ehliyet No & Şifre)
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _idFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  // Kayıt Form Kontrolleri (Ehliyet No, Son Kullanma Tarihi, Telefon SMS)
  final TextEditingController _regNameController = TextEditingController();
  final TextEditingController _regLicenseNoController = TextEditingController(); // Sürüş Ehliyet No
  final TextEditingController _regLicenseExpiryController = TextEditingController(); // Ehliyet Son Kullanma Tarihi
  final TextEditingController _regIdController = TextEditingController(); // Kimlik / Pasaport No
  final TextEditingController _regPhoneController = TextEditingController(); // SMS Doğrulama Telefonu
  final TextEditingController _regPlateController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();

  // Durum Değişkenleri
  bool _isLoginTab = true;
  bool _obscurePassword = true;
  bool _regObscurePassword = true;
  bool _rememberMe = true;
  bool _isEnglish = false;
  bool _isIdHighlighted = false;


  // Giriş Buton Durumu: 0: Normal, 1: Yükleniyor, 2: Başarılı
  int _submitState = 0;
  // Biyometrik Durumu: 0: Normal, 1: Doğrulanıyor, 2: Doğrulandı
  int _biometricState = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _idController.dispose();
    _passwordController.dispose();
    _idFocusNode.dispose();
    _passwordFocusNode.dispose();

    _regNameController.dispose();
    _regLicenseNoController.dispose();
    _regLicenseExpiryController.dispose();
    _regIdController.dispose();
    _regPhoneController.dispose();
    _regPlateController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }

  // Hızlı Demo Doldurma (Ehliyet No & Şifre)
  void _fillDemoCredentials({
    String id = 'D-849201',
    String pass = 'LefkosaTraffic2025*',
  }) {
    HapticFeedback.lightImpact();
    setState(() {
      _idController.text = id;
      _passwordController.text = pass;
      _isIdHighlighted = true;
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _isIdHighlighted = false;
        });
      }
    });
  }

  // Demo Seçim Modalı (KKTC Sürücü, ODTÜ Öğrenci, TC İkamet)
  void _showDemoProfilesSheet() {
    HapticFeedback.lightImpact();
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
                      _isEnglish ? 'Select Quick Demo Driver Profile' : 'Hızlı Demo Sürücü Profili Seçin',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white54),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDemoOptionTile(
                  icon: Icons.badge_rounded,
                  title: 'Ahmet Demir (KKTC)',
                  subtitle: 'Ehliyet No: D-849201 • BMW 3.20i (RZ 123)',
                  onTap: () {
                    Navigator.pop(ctx);
                    _fillDemoCredentials(id: 'D-849201', pass: 'LefkosaTraffic2025*');
                  },
                ),
                _buildDemoOptionTile(
                  icon: Icons.school_rounded,
                  title: 'Can Yılmaz (ODTÜ Öğrenci)',
                  subtitle: 'Ehliyet No: D-554210 • Mercedes C200 (LZ 555)',
                  onTap: () {
                    Navigator.pop(ctx);
                    _fillDemoCredentials(id: 'D-554210', pass: 'OdtuCampus2026*');
                  },
                ),
                _buildDemoOptionTile(
                  icon: Icons.credit_card_rounded,
                  title: 'Mehmet Kaya (T.C. Denklik)',
                  subtitle: 'Ehliyet No: TR-109283 • Ford Ranger (ST 999)',
                  onTap: () {
                    Navigator.pop(ctx);
                    _fillDemoCredentials(id: 'TR-109283', pass: 'TcGuvenli2026*');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDemoOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        tileColor: Colors.white.withOpacity(0.06),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: cAccent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: cAccent, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white60, fontSize: 11.5),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white38),
        onTap: onTap,
      ),
    );
  }

  // Biyometrik Simülasyon
  void _simulateBiometric() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _biometricState = 1; // Doğrulanıyor
    });

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    setState(() {
      _biometricState = 2; // Doğrulandı
    });
    HapticFeedback.heavyImpact();

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    setState(() {
      _idController.text = 'D-849201';
      _passwordController.text = '••••••••••••';
      _biometricState = 0;
    });

    // Otomatik giriş
    _handleLogin();
  }

  // 📅 Ehliyet Son Kullanma Tarihi Seçici (Takvim)
  Future<void> _selectLicenseExpiryDate() async {
    HapticFeedback.lightImpact();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 365 * 5)),
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 25)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: cAccent,
              onPrimary: cBg,
              surface: Color(0xFF0F172A),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF0F172A),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          "${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}";
      setState(() {
        _regLicenseExpiryController.text = formatted;
      });
    }
  }

  // 📱 SMS Telefon Doğrulama Modalı (OTP Akışı)
  void _showSmsVerificationSheet({
    required String phone,
    required VoidCallback onVerified,
  }) {
    HapticFeedback.mediumImpact();
    final String generatedCode = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
    final TextEditingController smsController = TextEditingController();
    int secondsRemaining = 60;
    Timer? countdownTimer;
    bool isVerifying = false;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            countdownTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
              if (secondsRemaining > 0) {
                setModalState(() {
                  secondsRemaining--;
                });
              } else {
                timer.cancel();
              }
            });

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalContext).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border.all(color: Colors.white12),
                ),
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tutamaç
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Simüle Edilmiş SMS Bildirim Banner'ı (Gelen SMS)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withOpacity(0.20),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0284C7).withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF38BDF8).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.mark_chat_unread_rounded, color: Color(0xFF38BDF8), size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '💬 Gelen SMS • KKTC e-Trafik',
                                  style: TextStyle(
                                    color: Color(0xFF38BDF8),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  'Güvenlik Kodunuz: $generatedCode',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setModalState(() {
                                smsController.text = generatedCode;
                                errorMessage = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: cAccent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Doldur',
                                style: TextStyle(
                                  color: cBg,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Başlık ve Açıklama
                    const Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 36),
                    const SizedBox(height: 10),
                    Text(
                      _isEnglish ? 'Phone SMS Verification' : 'SMS Telefon Doğrulaması',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isEnglish
                          ? 'Enter the 4-digit code sent to $phone'
                          : '$phone numaralı telefonunuza gönderilen 4 haneli SMS kodunu girin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: cText.withOpacity(0.70),
                        fontSize: 12.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 4 Haneli Kod Girişi
                    Container(
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: errorMessage != null ? const Color(0xFFEF4444) : cAccent,
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        controller: smsController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 18,
                          fontFamily: 'monospace',
                        ),
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          hintText: '••••',
                          hintStyle: TextStyle(
                            color: Colors.white30,
                            letterSpacing: 18,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),

                    if (errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Geri Sayım & Yeniden Gönder
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          secondsRemaining > 0
                              ? (_isEnglish ? 'Resend code in ${secondsRemaining}s' : 'Kodu tekrar gönder (${secondsRemaining}s)')
                              : (_isEnglish ? 'Did not receive code?' : 'Kod gelmedi mi?'),
                          style: TextStyle(
                            color: cText.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        if (secondsRemaining == 0) ...[
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setModalState(() {
                                secondsRemaining = 60;
                              });
                            },
                            child: const Text(
                              'Yeniden Gönder',
                              style: TextStyle(
                                color: cAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Doğrula Butonu
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 3,
                        ),
                        onPressed: isVerifying
                            ? null
                            : () async {
                                final entered = smsController.text.trim();
                                if (entered.isEmpty || entered.length < 4) {
                                  setModalState(() {
                                    errorMessage = _isEnglish ? 'Please enter 4 digits' : 'Lütfen 4 haneli kodu girin';
                                  });
                                  return;
                                }

                                if (entered != generatedCode && entered != "1234") {
                                  setModalState(() {
                                    errorMessage = _isEnglish ? 'Invalid verification code' : 'Hatalı kod girdiniz';
                                  });
                                  HapticFeedback.heavyImpact();
                                  return;
                                }

                                setModalState(() {
                                  isVerifying = true;
                                  errorMessage = null;
                                });
                                HapticFeedback.mediumImpact();

                                await Future.delayed(const Duration(milliseconds: 700));
                                countdownTimer?.cancel();
                                if (modalContext.mounted) {
                                  Navigator.pop(modalContext);
                                }
                                onVerified();
                              },
                        child: isVerifying
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_rounded, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isEnglish ? 'Verify & Sign In' : 'Doğrula ve Giriş Yap',
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
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
    ).whenComplete(() {
      countdownTimer?.cancel();
    });
  }

  // Giriş Yap Butonu (Ehliyet No & Şifre ile)
  void _handleLogin() async {
    if (_submitState != 0) return;

    if (_idController.text.trim().isEmpty) {
      _showSnackBar(
        _isEnglish
            ? 'Please enter your Driving License Number'
            : 'Lütfen Sürüş Ehliyet Numaranızı girin (Örn: D-849201)',
      );
      _idFocusNode.requestFocus();
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      _showSnackBar(
        _isEnglish ? 'Please enter your password' : 'Lütfen şifrenizi girin',
      );
      _passwordFocusNode.requestFocus();
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _submitState = 1); // Loading

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() => _submitState = 2); // Success
    HapticFeedback.vibrate();

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    if (widget.onLoginSuccess != null) {
      widget.onLoginSuccess!();
    } else {
      _showSnackBar(
        _isEnglish ? 'Login successful!' : 'Ehliyet doğrulandı! Giriş başarılı!',
        isSuccess: true,
      );
    }
  }

  // Kayıt Ol Butonu (Ehliyet No, Son Kullanma Tarihi, Telefon SMS ile)
  void _handleRegister() async {
    if (_submitState != 0) return;

    final name = _regNameController.text.trim();
    final licenseNo = _regLicenseNoController.text.trim();
    final licenseExpiry = _regLicenseExpiryController.text.trim();
    final phone = _regPhoneController.text.trim();
    final pass = _regPasswordController.text.trim();

    if (name.isEmpty) {
      _showSnackBar(
        _isEnglish ? 'Please enter your Full Name' : 'Lütfen Ad Soyad alanını doldurun',
      );
      return;
    }

    if (licenseNo.isEmpty) {
      _showSnackBar(
        _isEnglish
            ? 'Please enter your Driving License Number'
            : 'Lütfen Sürüş Ehliyet Numaranızı girin (Örn: D-849201)',
      );
      return;
    }

    if (licenseExpiry.isEmpty) {
      _showSnackBar(
        _isEnglish
            ? 'Please select your License Expiry Date'
            : 'Lütfen Ehliyetinizin Son Kullanma Tarihini seçin',
      );
      return;
    }

    if (phone.isEmpty) {
      _showSnackBar(
        _isEnglish
            ? 'Please enter your Mobile Phone Number for SMS verification'
            : 'Lütfen SMS doğrulaması için Cep Telefonu numaranızı girin',
      );
      return;
    }

    if (pass.isEmpty) {
      _showSnackBar(
        _isEnglish ? 'Please create a password' : 'Lütfen şifrenizi belirleyin',
      );
      return;
    }

    FocusScope.of(context).unfocus();

    // 📱 SMS DOĞRULAMA MODALINI AÇ
    _showSmsVerificationSheet(
      phone: phone,
      onVerified: () async {
        setState(() => _submitState = 1); // Loading
        await Future.delayed(const Duration(milliseconds: 700));
        if (!mounted) return;

        setState(() => _submitState = 2); // Success
        HapticFeedback.vibrate();

        _showSnackBar(
          _isEnglish
              ? 'SMS verified & Account created! Entering e-Trafik...'
              : 'SMS kodu doğrulandı! Ehliyet kaydınız başarıyla oluşturuldu, portala giriliyor...',
          isSuccess: true,
        );

        await Future.delayed(const Duration(milliseconds: 600));
        if (!mounted) return;

        if (widget.onLoginSuccess != null) {
          widget.onLoginSuccess!();
        }
      },
    );
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Çağrı 155 Başlatma
  Future<void> _callTrafficHelp() async {
    final Uri telUri = Uri.parse('tel:155');
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      _showSnackBar(
        _isEnglish ? 'Call failed: 155' : 'Arama başlatılamadı: 155',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cBg,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: cBg,
        ),
        child: Stack(
          children: [
            // 1. Arka Plan Atmosferik Parlamalar (Glows)
            Positioned(
              top: -80,
              left: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cAccent.withOpacity(0.06),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                  child: const SizedBox(),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.45,
              right: -90,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cMuted.withOpacity(0.12),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                  child: const SizedBox(),
                ),
              ),
            ),

            // 2. Ana İçerik
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Üst Bilgi Barı: Resmi Kamu Ağı & Dil Seçici
                        _buildTopUtilitiesBar(),
                        const SizedBox(height: 24),

                        // Logo ve Başlık (KKTC e-TRAFİK & Bayındırlık ve Ulaştırma Bakanlığı)
                        _buildBrandingHeader(),
                        const SizedBox(height: 22),

                        // Sekmeler: Giriş Yap / Kayıt Ol
                        _buildSegmentedTabs(),
                        const SizedBox(height: 18),

                        // Modern Cam Efektli Form Kartı (Giriş veya Kayıt)
                        _isLoginTab ? _buildLoginFormCard() : _buildRegisterFormCard(),
                        const SizedBox(height: 24),

                        // Alt Güvenlik & İletişim Bilgisi
                        _buildSecurityFooter(),
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

  // Üst Bar: "Resmi Kamu Ağı" & Dil Seçici
  Widget _buildTopUtilitiesBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Resmi Kamu Ağı Hapı
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cAccent.withOpacity(_pulseAnimation.value),
                          boxShadow: [
                            BoxShadow(
                              color: cAccent.withOpacity(_pulseAnimation.value * 0.6),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isEnglish ? 'OFFICIAL PUBLIC NETWORK' : 'RESMİ KAMU AĞI',
                    style: const TextStyle(
                      color: cText,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Dil Seçici (TR / EN)
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLanguageButton(label: 'TR', active: !_isEnglish, onTap: () {
                    if (_isEnglish) setState(() => _isEnglish = false);
                  }),
                  _buildLanguageButton(label: 'EN', active: _isEnglish, onTap: () {
                    if (!_isEnglish) setState(() => _isEnglish = true);
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageButton({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? cAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? cBg : cText.withOpacity(0.7),
            fontSize: 11,
            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Logo & Başlık (KKTC e-TRAFİK & Bakanlık)
  Widget _buildBrandingHeader() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.16)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    color: cAccent,
                    size: 28,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: cAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: cBg, width: 2.5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'KKTC e-Trafik',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _isEnglish
              ? 'Ministry of Public Works & Transport • Traffic Portal'
              : 'Bayındırlık ve Ulaştırma Bakanlığı • Trafik Portalı',
          style: TextStyle(
            color: cText.withOpacity(0.65),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Giriş Yap / Kayıt Ol Sekmeleri
  Widget _buildSegmentedTabs() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  title: _isEnglish ? 'Sign In' : 'Giriş Yap',
                  icon: Icons.lock_rounded,
                  isActive: _isLoginTab,
                  onTap: () {
                    if (!_isLoginTab) setState(() => _isLoginTab = true);
                  },
                ),
              ),
              Expanded(
                child: _buildTabButton(
                  title: _isEnglish ? 'Sign Up' : 'Kayıt Ol',
                  icon: Icons.person_add_rounded,
                  isActive: !_isLoginTab,
                  onTap: () {
                    if (_isLoginTab) setState(() => _isLoginTab = false);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: isActive ? cAccent : cText.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : cText.withOpacity(0.6),
                fontSize: 13.5,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. GİRİŞ FORMU KARTI
  // ===========================================================================
  Widget _buildLoginFormCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sürüş Ehliyet No Alanı (Giriş)
              _buildFieldLabel(
                label: _isEnglish
                    ? 'DRIVING LICENSE NUMBER'
                    : 'SÜRÜŞ EHLİYET NUMARASI',
                tag: _isEnglish ? 'REQUIRED' : 'ZORUNLU',
              ),
              const SizedBox(height: 6),
              _buildInputField(
                controller: _idController,
                focusNode: _idFocusNode,
                hintText: _isEnglish ? 'E.g. D-849201 or License No' : 'Örn: D-849201 veya Ehliyet No',
                icon: Icons.badge_outlined,
                isHighlighted: _isIdHighlighted,
              ),
              const SizedBox(height: 16),

              // Şifre / PIN Kodu Alanı
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEnglish ? 'Password / PIN Code' : 'Şifre / PIN Kodu',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cText.withOpacity(0.85),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _showSnackBar(
                        _isEnglish
                            ? 'Password reset link sent to your verified phone'
                            : 'Şifre sıfırlama bağlantısı kayıtlı numaranıza gönderildi',
                        isSuccess: true,
                      );
                    },
                    child: Text(
                      _isEnglish ? 'Forgot Password?' : 'Şifremi Unuttum',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cAccent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _buildInputField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                hintText: '••••••••••••',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                obscureText: _obscurePassword,
                onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 14),

              // Beni Hatırla Seçeneği
              Row(
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(
                      value: _rememberMe,
                      activeColor: cAccent,
                      checkColor: cBg,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      side: BorderSide(color: Colors.white.withOpacity(0.25), width: 1.5),
                      onChanged: (val) => setState(() => _rememberMe = val ?? true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _rememberMe = !_rememberMe),
                    child: Text(
                      _isEnglish ? 'Remember Me' : 'Beni Hatırla',
                      style: TextStyle(fontSize: 12.5, color: cText.withOpacity(0.75)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Ana Aksiyon Butonu: Güvenli Giriş Yap
              _buildSubmitButton(
                label: _isEnglish ? 'Secure Sign In' : 'Ehliyet No ile Giriş Yap',
                onTap: _handleLogin,
              ),
              const SizedBox(height: 16),

              Divider(color: Colors.white.withOpacity(0.10), thickness: 1, height: 1),
              const SizedBox(height: 14),

              // Biyometrik & Hızlı Demo Şeridi
              _buildQuickActionsRow(),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 2. KAYIT FORMU KARTI (EHLİYET NO, SON KULLANMA TARİHİ, SMS ONAYI)
  // ===========================================================================
  Widget _buildRegisterFormCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Ad Soyad
              _buildFieldLabel(
                label: _isEnglish ? 'Full Name' : 'Ad Soyad',
                tag: _isEnglish ? 'REQUIRED' : 'ZORUNLU',
              ),
              const SizedBox(height: 6),
              _buildInputField(
                controller: _regNameController,
                hintText: _isEnglish ? 'E.g. Ahmet Demir' : 'Örn: Ahmet Demir',
                icon: Icons.person_rounded,
              ),
              const SizedBox(height: 14),

              // 2. Sürüş Ehliyet Numarası (Zorunlu)
              _buildFieldLabel(
                label: _isEnglish ? 'DRIVING LICENSE NUMBER' : 'SÜRÜŞ EHLİYET NUMARASI',
                tag: _isEnglish ? 'REQUIRED' : 'ZORUNLU',
              ),
              const SizedBox(height: 6),
              _buildInputField(
                controller: _regLicenseNoController,
                hintText: _isEnglish ? 'E.g. D-849201' : 'Örn: D-849201',
                icon: Icons.badge_rounded,
              ),
              const SizedBox(height: 14),

              // 3. Ehliyet Son Kullanma Tarihi (Takvim Seçimli)
              _buildFieldLabel(
                label: _isEnglish ? 'LICENSE EXPIRY DATE' : 'EHLİYET SON KULLANMA TARİHİ',
                tag: _isEnglish ? 'SELECT DATE' : 'TAKVİMDEN SEÇİN',
              ),
              const SizedBox(height: 6),
              _buildInputField(
                controller: _regLicenseExpiryController,
                hintText: _isEnglish ? 'Select Date (E.g. 15.06.2030)' : 'Tarih Seçin (Örn: 15.06.2030)',
                icon: Icons.calendar_month_rounded,
                readOnly: true,
                onTap: _selectLicenseExpiryDate,
                customSuffix: IconButton(
                  icon: const Icon(Icons.event_note_rounded, color: cAccent, size: 20),
                  onPressed: _selectLicenseExpiryDate,
                ),
              ),
              const SizedBox(height: 14),

              // 4. Cep Telefonu Numarası (SMS Doğrulaması)
              _buildFieldLabel(
                label: _isEnglish ? 'Mobile Phone Number' : 'Cep Telefonu Numarası',
                tag: _isEnglish ? 'SMS OTP' : 'SMS ONAYLI',
              ),
              const SizedBox(height: 6),
              _buildInputField(
                controller: _regPhoneController,
                hintText: '0533 800 00 00 / 0548 000 00 00',
                icon: Icons.phone_iphone_rounded,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),

              // 5. Şifre Belirleyin
              _buildFieldLabel(
                label: _isEnglish ? 'Create Password' : 'Şifre Belirleyin',
                tag: _isEnglish ? 'MIN 6 CHARS' : 'EN AZ 6 KARAKTER',
              ),
              const SizedBox(height: 6),
              _buildInputField(
                controller: _regPasswordController,
                hintText: '••••••••••••',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                obscureText: _regObscurePassword,
                onTogglePassword: () => setState(() => _regObscurePassword = !_regObscurePassword),
              ),
              const SizedBox(height: 20),

              // SMS Gönder & Kayıt Ol Butonu
              _buildSubmitButton(
                label: _isEnglish ? 'Send SMS Code & Register' : 'SMS Kodu Gönder & Kayıt Ol',
                onTap: _handleRegister,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel({required String label, required String tag}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: cText.withOpacity(0.85),
          ),
        ),
        Text(
          tag,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: cAccent.withOpacity(0.9),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
    bool isHighlighted = false,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? customSuffix,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: isHighlighted ? cAccent.withOpacity(0.12) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted ? cAccent : Colors.white.withOpacity(0.10),
          width: 1.2,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        readOnly: readOnly,
        onTap: onTap,
        obscureText: isPassword && obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          fontFamily: 'monospace',
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: cText.withOpacity(0.35),
            fontSize: 13,
            fontWeight: FontWeight.normal,
            fontFamily: 'sans-serif',
          ),
          prefixIcon: Icon(icon, color: cText.withOpacity(0.5), size: 19),
          suffixIcon: customSuffix ??
              (isPassword
                  ? IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: cText.withOpacity(0.5),
                        size: 19,
                      ),
                      onPressed: onTogglePassword,
                    )
                  : null),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
      ),
    );
  }

  // Ana Aksiyon Butonu
  Widget _buildSubmitButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _submitState == 2 ? Colors.white : cAccent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: cAccent.withOpacity(_submitState == 2 ? 0.1 : 0.25),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: _submitState == 1
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: cBg),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _submitState == 2 ? Icons.check_circle_rounded : Icons.login_rounded,
                        size: 20,
                        color: cBg,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _submitState == 2 ? (_isEnglish ? 'Success!' : 'Giriş Başarılı!') : label,
                        style: const TextStyle(
                          color: cBg,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // Biyometrik & Hızlı Demo Şeridi
  Widget _buildQuickActionsRow() {
    return Row(
      children: [
        // Biyometrik Giriş Butonu
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _simulateBiometric,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _biometricState == 2 ? Icons.check_circle_rounded : Icons.fingerprint_rounded,
                      color: _biometricState == 2 ? const Color(0xFF10B981) : cAccent,
                      size: 19,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _biometricState == 1
                          ? (_isEnglish ? 'Verifying...' : 'Doğrulanıyor...')
                          : (_biometricState == 2
                              ? (_isEnglish ? 'Verified' : 'Doğrulandı')
                              : (_isEnglish ? 'Biometric' : 'Biyometrik Giriş')),
                      style: TextStyle(
                        color: _biometricState == 2 ? const Color(0xFF10B981) : cText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Hızlı Demo Butonu
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showDemoProfilesSheet,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bolt_rounded, color: cAccent, size: 19),
                    const SizedBox(width: 6),
                    Text(
                      _isEnglish ? 'Quick Demo' : 'Hızlı Demo',
                      style: const TextStyle(
                        color: cText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Alt Güvenlik & İletişim Bilgisi
  Widget _buildSecurityFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_rounded, color: cAccent, size: 13),
            const SizedBox(width: 6),
            Text(
              _isEnglish
                  ? '256-Bit SSL • KKTC Public Network Secure Login'
                  : '256-Bit SSL • KKTC Kamu Ağı Güvenli Giriş',
              style: TextStyle(
                color: cText.withOpacity(0.60),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _showSnackBar('KKTC e-Trafik Yardım Masası: destek@trafik.gov.ct.tr'),
              child: Text(
                _isEnglish ? 'Help Desk' : 'Yardım Masası',
                style: TextStyle(
                  color: cText.withOpacity(0.5),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('•', style: TextStyle(color: cText.withOpacity(0.3))),
            ),
            GestureDetector(
              onTap: _callTrafficHelp,
              child: const Text(
                'Trafik Çağrı: 155',
                style: TextStyle(
                  color: cAccent,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
