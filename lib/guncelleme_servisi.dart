import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// 🚀 Otomatik Güncelleme Bilgi Modeli
class GuncellemeBilgisi {
  final bool guncellemeVar;
  final String mevcutSurum;
  final String yeniSurum;
  final String baslik;
  final String aciklama;
  final String apkUrl;

  const GuncellemeBilgisi({
    required this.guncellemeVar,
    required this.mevcutSurum,
    required this.yeniSurum,
    required this.baslik,
    required this.aciklama,
    required this.apkUrl,
  });
}

/// 📲 KKTC Trafik & Ceza - Kablosuz OTA Güncelleme Servisi
class GuncellemeServisi {
  // Mevcut uygulama sürümü (Cihazdaki taban sürüm)
  static const String mevcutSurum = "1.0.0";
  static const String _repoApiUrl =
      "https://api.github.com/repos/Tubi-kara/kktc_ceza/releases/latest";
  static const String _varsayilanApkUrl =
      "https://github.com/Tubi-kara/kktc_ceza/releases/latest/download/kktc_ceza_app.apk";

  /// 🔍 GitHub Releases Üzerinden Yeni Sürüm Var mı Kontrol Eder
  static Future<GuncellemeBilgisi?> guncellemeKontrolEt() async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 6);
      final request = await client.getUrl(Uri.parse(_repoApiUrl));
      request.headers.set('User-Agent', 'KKTC-Ceza-App');
      request.headers.set('Accept', 'application/vnd.github.v3+json');

      final response = await request.close();
      if (response.statusCode != 200) {
        return null;
      }

      final body = await response.transform(utf8.decoder).join();
      final data = json.decode(body) as Map<String, dynamic>;

      final tagName = (data['tag_name'] ?? '').toString();
      final releaseName = (data['name'] ?? 'Yeni Güncelleme').toString();
      final releaseBody = (data['body'] ?? '').toString();

      // Sürüm numarasını temizle (örn: 'v1.0.2' -> '1.0.2')
      String temizYeniSurum = tagName.replaceAll(RegExp(r'[^0-9.]'), '');
      if (temizYeniSurum.isEmpty) {
        // Tag "latest" ise, başlık veya açıklamadaki sürümü ara
        final match = RegExp(r'v?(\d+\.\d+(\.\d+)?)').firstMatch('$releaseName $releaseBody');
        if (match != null) {
          temizYeniSurum = match.group(1) ?? '';
        }
      }
      if (temizYeniSurum.isEmpty) {
        temizYeniSurum = "1.0.2";
      }

      final temizMevcutSurum = mevcutSurum.replaceAll(RegExp(r'[^0-9.]'), '');

      // APK İndirme URL'sini bul
      String indirmeUrl = _varsayilanApkUrl;
      if (data['assets'] is List) {
        final assets = data['assets'] as List;
        for (final asset in assets) {
          final assetName = (asset['name'] ?? '').toString().toLowerCase();
          if (assetName.endsWith('.apk')) {
            indirmeUrl = asset['browser_download_url'] ?? indirmeUrl;
            break;
          }
        }
      }

      final bool yeniVar = _surumBuyukMu(temizYeniSurum, temizMevcutSurum) ||
          (tagName.toLowerCase() == 'latest' && temizYeniSurum != temizMevcutSurum);

      return GuncellemeBilgisi(
        guncellemeVar: yeniVar,
        mevcutSurum: mevcutSurum,
        yeniSurum: temizYeniSurum.isNotEmpty ? temizYeniSurum : tagName,
        baslik: releaseName,
        aciklama: releaseBody,
        apkUrl: indirmeUrl,
      );
    } catch (_) {
      // İnternet yoksa veya GitHub ulaşılamazsa sessizce geç
      return null;
    }
  }

  /// Semver karşılaştırma: yeni > mevcut ise true döner
  static bool _surumBuyukMu(String yeni, String mevcut) {
    if (yeni.isEmpty) return false;
    final yeniParcalar = yeni.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final mevcutParcalar = mevcut.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    while (yeniParcalar.length < 3) {
      yeniParcalar.add(0);
    }
    while (mevcutParcalar.length < 3) {
      mevcutParcalar.add(0);
    }

    for (int i = 0; i < 3; i++) {
      if (yeniParcalar[i] > mevcutParcalar[i]) return true;
      if (yeniParcalar[i] < mevcutParcalar[i]) return false;
    }
    return false;
  }

  /// 🔔 Uygulama Açılışında Otomatik Kontrol (Sadece yeni sürüm varsa pencere açar)
  static Future<void> otomatikKontrolEt(BuildContext context, bool turkceMi) async {
    final bilgi = await guncellemeKontrolEt();
    if (bilgi != null && bilgi.guncellemeVar && context.mounted) {
      guncellemeDiyaloguGoster(context, bilgi, turkceMi);
    }
  }

  /// ⚙️ Ayarlar / Profil Menüsünden Manuel Kontrol (Kullanıcı basarsa)
  static Future<void> manuelKontrolEt(BuildContext context, bool turkceMi) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              turkceMi
                  ? 'Güncellemeler denetleniyor...'
                  : 'Checking for updates...',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    final bilgi = await guncellemeKontrolEt();
    if (!context.mounted) return;

    if (bilgi != null && bilgi.guncellemeVar) {
      guncellemeDiyaloguGoster(context, bilgi, turkceMi);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  turkceMi
                      ? 'Harika! Uygulamanız en güncel sürümde (v$mevcutSurum).'
                      : 'You are on the latest version (v$mevcutSurum).',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0F172A),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 🚀 Yeni Sürüm Bulunduğunda Açılan Modern Glassmorphism İletişim Kutusu
  static void guncellemeDiyaloguGoster(
    BuildContext context,
    GuncellemeBilgisi bilgi,
    bool turkceMi,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.35), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Başlık & İkon Alanı
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.10),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              turkceMi ? 'Yeni Güncelleme Yayında!' : 'New Update Available!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              turkceMi ? 'Kablosuz tek tıkla yükleyin' : 'Install over-the-air wirelessly',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // İçerik & Sürüm Karşılaştırması
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sürüm Karşılaştırma Rozetleri
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  turkceMi ? 'Mevcut Sürüm' : 'Current',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'v${bilgi.mevcutSurum}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.arrow_forward_rounded, color: Color(0xFF10B981), size: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  turkceMi ? 'Yeni Sürüm' : 'New Version',
                                  style: const TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'v${bilgi.yeniSurum}',
                                  style: const TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Yenilikler Başlığı & Açıklaması
                      Text(
                        turkceMi ? 'Yenilikler & İyileştirmeler:' : "What's New:",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 120),
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            bilgi.aciklama.isNotEmpty
                                ? bilgi.aciklama
                                : (turkceMi
                                    ? '• Haritaya dokunarak rota belirleme (Touch-to-Route)\n• Canlı Google Maps dönüş manevraları & HUD\n• Canlı KKTC radar hız uyarısı ve performans geliştirmeleri'
                                    : '• Interactive touch-to-route point selection\n• Live turn-by-turn navigation HUD\n• Live speed camera warnings and fixes'),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 11.5,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Aksiyon Butonları
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white70,
                                side: const BorderSide(color: Colors.white24),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                turkceMi ? 'Daha Sonra' : 'Later',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                Navigator.of(ctx).pop();
                                final uri = Uri.parse(bilgi.apkUrl);
                                try {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                } catch (_) {
                                  // Alternatif olarak web sayfasını aç
                                  await launchUrl(
                                    Uri.parse("https://github.com/Tubi-kara/kktc_ceza/releases"),
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 6,
                                shadowColor: const Color(0xFF10B981).withValues(alpha: 0.5),
                              ),
                              icon: const Icon(Icons.download_rounded, size: 18),
                              label: Text(
                                turkceMi ? 'Hemen Güncelle' : 'Update Now',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
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
        );
      },
    );
  }
}
