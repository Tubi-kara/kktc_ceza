import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Tema Seçenekleri
enum KktcTemaModu {
  sistem,
  acik,
  koyu,
}

/// KKTC e-Trafik Tema Yönetim Servisi (Singleton)
class KktcTemaServisi extends ChangeNotifier {
  static final KktcTemaServisi _instance = KktcTemaServisi._internal();
  factory KktcTemaServisi() => _instance;

  KktcTemaModu _temaModu = KktcTemaModu.sistem;
  bool _yuklendi = false;

  KktcTemaServisi._internal() {
    _ayariYukle();
  }

  KktcTemaModu get temaModu => _temaModu;
  bool get yuklendi => _yuklendi;

  String get temaAdi {
    switch (_temaModu) {
      case KktcTemaModu.acik:
        return '☀️ Açık Tema';
      case KktcTemaModu.koyu:
        return '🌙 Koyu Tema';
      case KktcTemaModu.sistem:
        return '⚙️ Sistem';
    }
  }

  ThemeMode get flutterThemeMode {
    switch (_temaModu) {
      case KktcTemaModu.acik:
        return ThemeMode.light;
      case KktcTemaModu.koyu:
        return ThemeMode.dark;
      case KktcTemaModu.sistem:
        return ThemeMode.system;
    }
  }

  /// Belirli bir context altında koyu temanın aktif olup olmadığını belirler
  bool isKoyu(BuildContext context) {
    if (_temaModu == KktcTemaModu.koyu) return true;
    if (_temaModu == KktcTemaModu.acik) return false;
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
  }

  /// Aktif modun koyu olup olmadığını anlık kontrol eder (context'siz; sistem modunda cihaz temasına bakar)
  bool get isKoyuAktif {
    if (_temaModu == KktcTemaModu.koyu) return true;
    if (_temaModu == KktcTemaModu.acik) return false;
    return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  }

  /// Tema değişince açık olan tüm sayfa/sheet'lerin sabit renklerini de yenilemek için tüm ağacı yeniden çizer
  void _tumAgaciYenile() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final root = WidgetsBinding.instance.rootElement;
      if (root == null) return;
      void yenile(Element el) {
        el.markNeedsBuild();
        el.visitChildren(yenile);
      }
      root.visitChildren(yenile);
    });
  }

  // 🎨 DİNAMİK RENK TOKENLARI
  Color get bg => isKoyuAktif ? const Color(0xFF0A0F1D) : const Color(0xFFF4F5F7);
  Color get card => isKoyuAktif ? const Color(0xFF151D30) : const Color(0xFFFFFFFF);
  Color get cardBorder => isKoyuAktif ? const Color(0xFF243048) : const Color(0xFFE2E8F0);
  Color get textPrimary => isKoyuAktif ? const Color(0xFFF8FAFC) : const Color(0xFF010E3C);
  Color get textSecondary => isKoyuAktif ? const Color(0xFF94A3B8) : const Color(0xFF747675);
  Color get textMuted => isKoyuAktif ? const Color(0xFF64748B) : const Color(0xFFA0AEC0);
  Color get softBg => isKoyuAktif ? const Color(0xFF1A243B) : const Color(0xFFF1F5F9);
  Color get navBarBg => isKoyuAktif ? const Color(0xFF0D1424) : const Color(0xFFFFFFFF);
  Color get navBarBorder => isKoyuAktif ? const Color(0xFF1F2B42) : const Color(0xFFE2E8F0);
  Color get divider => isKoyuAktif ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

  // 🌟 FLUTTER MATERİAL 3 TEMA TANIMLARI
  static ThemeData get acikTemaData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF4F5F7),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF010E3C),
        brightness: Brightness.light,
        primary: const Color(0xFF010E3C),
        surface: Colors.white,
        surfaceTint: Colors.transparent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF010E3C),
        elevation: 0,
      ),
    );
  }

  static ThemeData get koyuTemaData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0F1D),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF38BDF8),
        brightness: Brightness.dark,
        primary: const Color(0xFF38BDF8),
        surface: const Color(0xFF151D30),
        surfaceTint: Colors.transparent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF151D30),
        foregroundColor: Color(0xFFF8FAFC),
        elevation: 0,
      ),
    );
  }

  /// Temayı değiştir ve kalıcı olarak kaydet
  Future<void> temaDegistir(KktcTemaModu yeniMod) async {
    if (_temaModu == yeniMod) return;
    _temaModu = yeniMod;
    notifyListeners();
    _tumAgaciYenile();
    await _ayariKaydet();
  }

  // --- Kalıcılık İşlemleri (JSON Dosyası) ---
  Future<File> _getDosya() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/kktc_tema_ayari.json');
  }

  Future<void> _ayariYukle() async {
    try {
      final file = await _getDosya();
      if (await file.exists()) {
        final content = await file.readAsString();
        final Map<String, dynamic> data = jsonDecode(content);
        final modStr = data['temaModu'] as String?;
        if (modStr == 'acik') {
          _temaModu = KktcTemaModu.acik;
        } else if (modStr == 'koyu') {
          _temaModu = KktcTemaModu.koyu;
        } else {
          _temaModu = KktcTemaModu.sistem;
        }
      }
    } catch (_) {
      _temaModu = KktcTemaModu.sistem;
    } finally {
      _yuklendi = true;
      notifyListeners();
    }
  }

  Future<void> _ayariKaydet() async {
    try {
      final file = await _getDosya();
      String modStr = 'sistem';
      if (_temaModu == KktcTemaModu.acik) modStr = 'acik';
      if (_temaModu == KktcTemaModu.koyu) modStr = 'koyu';
      await file.writeAsString(jsonEncode({'temaModu': modStr}));
    } catch (_) {}
  }

  /// Tema Seçim Modalı (BottomSheet)
  void showTemaSecimDialog(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final koyuMu = isKoyu(context);
            final sheetBg = koyuMu ? const Color(0xFF111827) : Colors.white;
            final sheetTitle = koyuMu ? Colors.white : const Color(0xFF010E3C);
            final sheetSub = koyuMu ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 14,
                bottom: MediaQuery.of(modalCtx).padding.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sürükleme Çubuğu
                  Center(
                    child: Container(
                      width: 44,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: koyuMu ? Colors.white24 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Başlık Satırı
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF010E3C).withValues(alpha: koyuMu ? 0.4 : 0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.palette_rounded,
                          color: koyuMu ? const Color(0xFF38BDF8) : const Color(0xFF010E3C),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tema Görünümü',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: sheetTitle,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'Uygulamanın renk tonunu ve temasını seçin',
                              style: TextStyle(fontSize: 12, color: sheetSub),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(modalCtx),
                        icon: Icon(Icons.close_rounded, color: sheetSub),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Seçenek 1: Açık Tema
                  _buildTemaSecenekKarti(
                    ctx: modalCtx,
                    secili: _temaModu == KktcTemaModu.acik,
                    ikon: Icons.light_mode_rounded,
                    ikonRenk: const Color(0xFFF59E0B),
                    baslik: 'Açık Tema (Gündüz Modu)',
                    aciklama: 'Aydınlık, yüksek kontrastlı ve canlı görünüm',
                    koyuMu: koyuMu,
                    onTap: () async {
                      await temaDegistir(KktcTemaModu.acik);
                      setModalState(() {});
                      if (context.mounted) {
                        Navigator.pop(modalCtx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('☀️ Açık tema aktif edildi.'),
                            duration: Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),

                  // Seçenek 2: Koyu Tema
                  _buildTemaSecenekKarti(
                    ctx: modalCtx,
                    secili: _temaModu == KktcTemaModu.koyu,
                    ikon: Icons.dark_mode_rounded,
                    ikonRenk: const Color(0xFF38BDF8),
                    baslik: 'Koyu Tema (Gece Modu)',
                    aciklama: 'Göz dinlendiren, şık gece mavisi ve koyu tonlar',
                    koyuMu: koyuMu,
                    onTap: () async {
                      await temaDegistir(KktcTemaModu.koyu);
                      setModalState(() {});
                      if (context.mounted) {
                        Navigator.pop(modalCtx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🌙 Koyu tema aktif edildi.'),
                            duration: Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),

                  // Seçenek 3: Sistem Teması
                  _buildTemaSecenekKarti(
                    ctx: modalCtx,
                    secili: _temaModu == KktcTemaModu.sistem,
                    ikon: Icons.settings_brightness_rounded,
                    ikonRenk: const Color(0xFF10B981),
                    baslik: 'Sistem Teması (Otomatik)',
                    aciklama: 'Cihazınızın sistem temasını otomatik olarak takip eder',
                    koyuMu: koyuMu,
                    onTap: () async {
                      await temaDegistir(KktcTemaModu.sistem);
                      setModalState(() {});
                      if (context.mounted) {
                        Navigator.pop(modalCtx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('⚙️ Sistem teması aktif edildi.'),
                            duration: Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTemaSecenekKarti({
    required BuildContext ctx,
    required bool secili,
    required IconData ikon,
    required Color ikonRenk,
    required String baslik,
    required String aciklama,
    required bool koyuMu,
    required VoidCallback onTap,
  }) {
    final borderCol = secili
        ? const Color(0xFF2563EB)
        : (koyuMu ? const Color(0xFF263354) : const Color(0xFFE2E8F0));
    final bgCol = secili
        ? const Color(0xFF2563EB).withValues(alpha: koyuMu ? 0.18 : 0.08)
        : (koyuMu ? const Color(0xFF16203B) : Colors.white);

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgCol,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol, width: secili ? 1.8 : 1.0),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ikonRenk.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(ikon, color: ikonRenk, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    baslik,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: secili ? FontWeight.w800 : FontWeight.w600,
                      color: koyuMu ? Colors.white : const Color(0xFF010E3C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    aciklama,
                    style: TextStyle(
                      fontSize: 11,
                      color: koyuMu ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            if (secili)
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
              )
            else
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: koyuMu ? Colors.white24 : Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
