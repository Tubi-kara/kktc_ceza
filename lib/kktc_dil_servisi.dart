import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'kktc_tema_servisi.dart';

enum KktcDilModu {
  tr,
  en,
}

/// KKTC e-Trafik Dil Yönetim Servisi (Singleton)
class KktcDilServisi extends ChangeNotifier {
  static final KktcDilServisi _instance = KktcDilServisi._internal();
  factory KktcDilServisi() => _instance;

  KktcDilModu _dilModu = KktcDilModu.tr;
  bool _yuklendi = false;

  KktcDilServisi._internal() {
    _ayariYukle();
  }

  KktcDilModu get dilModu => _dilModu;
  bool get yuklendi => _yuklendi;
  bool get turkceMi => _dilModu == KktcDilModu.tr;
  bool get isTurkce => _dilModu == KktcDilModu.tr;
  bool get isEnglish => _dilModu == KktcDilModu.en;

  String get dilAdi => _dilModu == KktcDilModu.tr ? '🇹🇷 Türkçe' : '🇬🇧 English';
  String get dilKodu => _dilModu == KktcDilModu.tr ? 'TR' : 'EN';
  String get dilKisa => _dilModu == KktcDilModu.tr ? 'Türkçe' : 'English';

  /// Dil değişince açık olan tüm sayfa/widget'ların yeniden çizilmesini sağlar
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

  /// Dili değiştir ve kalıcı olarak kaydet
  Future<void> dilDegistir(bool turkce) async {
    final yeniMod = turkce ? KktcDilModu.tr : KktcDilModu.en;
    if (_dilModu == yeniMod) return;
    _dilModu = yeniMod;
    notifyListeners();
    _tumAgaciYenile();
    await _ayariKaydet();
  }

  // --- Kalıcılık İşlemleri (JSON Dosyası) ---
  Future<File> _getDosya() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/kktc_dil_ayari.json');
  }

  Future<void> _ayariYukle() async {
    try {
      final file = await _getDosya();
      if (await file.exists()) {
        final content = await file.readAsString();
        final map = jsonDecode(content);
        if (map['dil'] == 'en') {
          _dilModu = KktcDilModu.en;
        } else {
          _dilModu = KktcDilModu.tr;
        }
      }
    } catch (_) {
      _dilModu = KktcDilModu.tr;
    } finally {
      _yuklendi = true;
      notifyListeners();
    }
  }

  Future<void> _ayariKaydet() async {
    try {
      final file = await _getDosya();
      await file.writeAsString(jsonEncode({'dil': _dilModu == KktcDilModu.en ? 'en' : 'tr'}));
    } catch (_) {}
  }

  /// Dil Seçim Modalı (BottomSheet)
  void showDilSecimDialog(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final koyuMu = KktcTemaServisi().isKoyu(context);
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
                          Icons.language_rounded,
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
                              turkceMi ? 'Uygulama Dili' : 'App Language',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: sheetTitle,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              turkceMi ? 'Kullanmak istediğiniz dili seçin' : 'Select your preferred language',
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

                  // Seçenek 1: Türkçe
                  _buildDilSecenekKarti(
                    ctx: modalCtx,
                    secili: _dilModu == KktcDilModu.tr,
                    bayrak: '🇹🇷',
                    baslik: 'Türkçe',
                    aciklama: 'Kuzey Kıbrıs Türk Cumhuriyeti (Varsayılan)',
                    koyuMu: koyuMu,
                    onTap: () async {
                      await dilDegistir(true);
                      setModalState(() {});
                      if (context.mounted) {
                        Navigator.pop(modalCtx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🇹🇷 Dil Türkçe olarak güncellendi.'),
                            duration: Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),

                  // Seçenek 2: English
                  _buildDilSecenekKarti(
                    ctx: modalCtx,
                    secili: _dilModu == KktcDilModu.en,
                    bayrak: '🇬🇧',
                    baslik: 'English',
                    aciklama: 'Turkish Republic of Northern Cyprus e-Traffic',
                    koyuMu: koyuMu,
                    onTap: () async {
                      await dilDegistir(false);
                      setModalState(() {});
                      if (context.mounted) {
                        Navigator.pop(modalCtx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🇬🇧 Language switched to English.'),
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

  Widget _buildDilSecenekKarti({
    required BuildContext ctx,
    required bool secili,
    required String bayrak,
    required String baslik,
    required String aciklama,
    required bool koyuMu,
    required VoidCallback onTap,
  }) {
    final cardBg = secili
        ? (koyuMu ? const Color(0xFF0C4A6E).withValues(alpha: 0.35) : const Color(0xFFE0F2FE))
        : (koyuMu ? const Color(0xFF1E293B).withValues(alpha: 0.6) : const Color(0xFFF8FAFC));

    final cardBorder = secili
        ? const Color(0xFF0284C7)
        : (koyuMu ? const Color(0xFF334155) : const Color(0xFFE2E8F0));

    final textColor = koyuMu ? Colors.white : const Color(0xFF010E3C);
    final subColor = koyuMu ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cardBorder,
              width: secili ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: koyuMu ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  bayrak,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      baslik,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      aciklama,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: subColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: secili ? const Color(0xFF0284C7) : Colors.transparent,
                  border: Border.all(
                    color: secili
                        ? const Color(0xFF0284C7)
                        : (koyuMu ? const Color(0xFF64748B) : const Color(0xFFCBD5E1)),
                    width: 2,
                  ),
                ),
                child: secili
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
