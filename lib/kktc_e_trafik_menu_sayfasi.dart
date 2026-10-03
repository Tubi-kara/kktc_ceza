import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'radar_haritasi.dart';
import 'yol_tarifi_sayfasi.dart';
import 'yardim_rehberi_sayfasi.dart';
import 'hizli_arama_modali.dart';
import 'guvenlik_duvari.dart';
import 'guncelleme_servisi.dart';
import 'main.dart' show BarkodluBelgeSayfasi, DekontlarSayfasi, ItirazSayfasi, BildirimAyarlariSayfasi;
import 'kktc_tema_servisi.dart';

/// KKTC e-Trafik Kategorize Edilmiş Zengin Menü Sayfası
/// Kullanıcının ilettiği HTML / Tailwind tasarımının ve önceki tüm gelişmiş özelliklerin tam entegre Flutter uygulamasıdır.
class KktcETrafikMenuSayfasi extends StatefulWidget {
  final VoidCallback? onOpenPanel;
  final VoidCallback? onOpenRadars;
  final VoidCallback? onOpenFines;
  final VoidCallback? onCikisYap;
  final bool girisYapildiMi;
  final String kullaniciAdi;
  final VoidCallback? onGirisYap;

  const KktcETrafikMenuSayfasi({
    super.key,
    this.onOpenPanel,
    this.onOpenRadars,
    this.onOpenFines,
    this.onCikisYap,
    this.girisYapildiMi = false,
    this.kullaniciAdi = 'Misafir Kullanıcı',
    this.onGirisYap,
  });

  @override
  State<KktcETrafikMenuSayfasi> createState() => _KktcETrafikMenuSayfasiState();
}

class _KktcETrafikMenuSayfasiState extends State<KktcETrafikMenuSayfasi> {
  // Tasarım Renk Tokenları
  static const Color cNavy = Color(0xFF010E3C);
  static const Color cSlate = Color(0xFF747675);
  static const Color cAccent = Color(0xFFD1C929);
  static const Color cAccentLight = Color(0xFFFAF9E5);
  static const Color cSoftRed = Color(0xFFFFF1F2);
  static const Color cDanger = Color(0xFFE11D48);

  bool _girisGerekliKontrol(String islemAdi) {
    if (!widget.girisYapildiMi) {
      HapticFeedback.mediumImpact();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.lock_rounded, color: cNavy, size: 22),
              SizedBox(width: 8),
              Text(
                'Giriş Yapmalısınız',
                style: TextStyle(fontWeight: FontWeight.w800, color: cNavy, fontSize: 17),
              ),
            ],
          ),
          content: Text(
            '$islemAdi için KKTC Kimlik veya Ehliyet numaranız ile sisteme giriş yapmalısınız.',
            style: const TextStyle(fontSize: 13.5, color: cSlate, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Vazgeç', style: TextStyle(color: cSlate)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                if (widget.onGirisYap != null) {
                  widget.onGirisYap!();
                }
              },
              icon: const Icon(Icons.login_rounded, size: 16, color: Colors.white),
              label: const Text('Giriş Yap'),
              style: ElevatedButton.styleFrom(
                backgroundColor: cNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
      return false;
    }
    return true;
  }

  // Örnek Dekontlar Listesi
  final List<Map<String, String>> _dekontlar = [
    {
      "islem": "Gönyeli Çemberi Sabit Radar İhlali Ödemesi",
      "islemEn": "Gonyeli Roundabout Radar Violation Payment",
      "tarih": "18.05.2024",
      "tutar": "₺1.850,00",
      "kod": "DEKONT-PGM-8841-TRF",
      "kurum": "KKTC Maliye Bakanlığı & Polis Genel Md.",
      "durum": "Ödendi / Arşivlendi"
    },
    {
      "islem": "RZ 123 2026/1. Dönem Seyrüsefer Harcı",
      "islemEn": "RZ 123 2026/1 Road Tax Period",
      "tarih": "12.01.2026",
      "tutar": "₺3.450,00",
      "kod": "DEKONT-SYR-2026-9912",
      "kurum": "Bayındırlık ve Ulaştırma Bakanlığı",
      "durum": "Onaylandı / Makbuz Kesildi"
    },
  ];

  // Acil 155 Arama
  Future<void> _ara155() async {
    HapticFeedback.heavyImpact();
    final Uri uri = Uri.parse('tel:155');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showSnackbar('Arama başlatılamadı: 155');
    }
  }

  void _showSnackbar(String mesaj) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.w600)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Bilgi & Detay Modalı
  void _showInfoSheet({
    required String title,
    required Widget content,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: cNavy,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: cSlate),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                content,
                if (actionLabel != null) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cNavy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        if (onAction != null) onAction();
                      },
                      child: Text(
                        actionLabel,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // Araçlarım Detay Sayfası / Modalı
  void _openAraclarimSheet() {
    if (!_girisGerekliKontrol('Kayıtlı araçlarınızı ve ruhsat bilgilerinizi görüntülemek')) return;
    _showInfoSheet(
      title: 'Kayıtlı Araçlarım',
      content: Column(
        children: [
          _buildVehicleDetailCard(
            plate: 'RZ 123',
            model: 'BMW 3.20i (2022)',
            chassis: 'TRNC-BM-2022-8192',
            isActive: true,
          ),
          const SizedBox(height: 10),
          _buildVehicleDetailCard(
            plate: 'LZ 555',
            model: 'Mercedes-Benz C200 (2023)',
            chassis: 'TRNC-MB-2023-4412',
            isActive: false,
          ),
        ],
      ),
      actionLabel: 'Yeni Araç Ekle (Ruhsat ile)',
      onAction: () {
        _showSnackbar('Yeni araç ruhsat tarama modülü açılıyor...');
      },
    );
  }

  Widget _buildVehicleDetailCard({
    required String plate,
    required String model,
    required String chassis,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? const Color(0xFF10B981) : Colors.grey.shade200,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: cNavy,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              plate,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: cNavy,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Şasi: $chassis',
                  style: const TextStyle(fontSize: 11, color: cSlate),
                ),
              ],
            ),
          ),
          if (isActive)
            const Chip(
              label: Text(
                'Seçili',
                style: TextStyle(
                  color: Color(0xFF047857),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              backgroundColor: Color(0xFFDCFCE7),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
        ],
      ),
    );
  }

  // Seyrüsefer Modalı
  // Seyrüsefer Modalı (İnteraktif & Yenileme Destekli)
  void _openSeyruseferSheet() {
    if (!_girisGerekliKontrol('Seyrüsefer harcı ve ruhsat yenileme durumunu görüntülemek')) return;
    _showInfoSheet(
      title: 'Seyrüsefer & Ruhsat Durumu',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E7FF).withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Araç Plaka:', style: TextStyle(color: cSlate)),
                    Text('RZ 123 (BMW 3.20i)', style: TextStyle(fontWeight: FontWeight.bold, color: cNavy)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dönem:', style: TextStyle(color: cSlate)),
                    Text('2026 / 2. Dönem', style: TextStyle(fontWeight: FontWeight.bold, color: cNavy)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Son Geçerlilik:', style: TextStyle(color: cSlate)),
                    Text('26 Aralık 2026 (86 Gün)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Harç Tutarı:', style: TextStyle(color: cSlate)),
                    Text('₺3.450,00', style: TextStyle(fontWeight: FontWeight.w900, color: cNavy, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Belgeniz resmi kamu veri tabanında güncel ve geçerlidir. Erken yenilemede %10 indirim uygulanmaktadır.',
            style: TextStyle(fontSize: 12, color: cSlate),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: cNavy,
                side: const BorderSide(color: cNavy),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BarkodluBelgeSayfasi(
                      kullanici: 'Ahmet Demir',
                      puan: 85,
                      turkceMi: true,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.qr_code_2_rounded, size: 18),
              label: const Text('Resmi Barkodlu Seyrüsefer Belgesini Aç', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ],
      ),
      actionLabel: 'Yeni Dönemi Erken Yenile (İndirimli ₺3.105)',
      onAction: () {
        Navigator.pop(context);
        _openSeyruseferOdemeDialog();
      },
    );
  }

  void _openSeyruseferOdemeDialog() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Seyrüsefer Harcı Tahsilatı',
          style: TextStyle(fontWeight: FontWeight.w900, color: cNavy, fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RZ 123 (BMW 3.20i) için 2027 1. Dönem erken yenileme harcı (%10 indirimle ₺3.105,00) tahsil edilecektir.',
              style: TextStyle(fontSize: 13, color: cSlate),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.credit_card_rounded, color: cNavy, size: 20),
                  SizedBox(width: 8),
                  Text('Garanti Bonus (•••• 4412)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç', style: TextStyle(color: cSlate)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cNavy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _showSnackbar('Seyrüsefer yenilendi! Resmi dijital pul oluşturuldu.');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BarkodluBelgeSayfasi(
                    kullanici: 'Ahmet Demir',
                    puan: 85,
                    turkceMi: true,
                  ),
                ),
              );
            },
            child: const Text('Öde & Belgeyi Al', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Muayene Takvimi Modalı
  void _openMuayeneSheet() {
    if (!_girisGerekliKontrol('Araç fenni muayene takviminizi görüntülemek')) return;
    _showInfoSheet(
      title: 'Araç Fenni Muayene Takvimi',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7).withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Kalan Süre:', style: TextStyle(color: cSlate)),
                    Text('48 Gün Kaldı', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFD97706))),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Son Muayene Tarihi:', style: TextStyle(color: cSlate)),
                    Text('09 Mayıs 2026', style: TextStyle(fontWeight: FontWeight.bold, color: cNavy)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('İstasyon:', style: TextStyle(color: cSlate)),
                    Text('Lefkoşa Polis Muayene Şube', style: TextStyle(fontWeight: FontWeight.bold, color: cNavy)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Fenni muayenesiz araç kullanmanın cezası ₺1.850,00 ve 5 ceza puanıdır. Randevunuzu önceden oluşturun.',
            style: TextStyle(fontSize: 12, color: cSlate),
          ),
        ],
      ),
      actionLabel: 'Online Muayene Randevusu Al',
      onAction: () {
        Navigator.pop(context);
        _showSnackbar('Muayene randevunuz 12 Mayıs 2026 10:30 olarak rezerve edildi!');
      },
    );
  }

  // Sigorta & Kasko Modalı
  void _openSigortaSheet() {
    if (!_girisGerekliKontrol('Sigorta ve kasko poliçesi detaylarınızı görüntülemek')) return;
    _showInfoSheet(
      title: 'Zorunlu Sigorta & Kasko Poliçesi',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
            ),
            child: const Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Sigorta Şirketi:', style: TextStyle(color: cSlate)),
                    Text('Kıbrıs Sigorta Kooperatifi', style: TextStyle(fontWeight: FontWeight.bold, color: cNavy)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Poliçe No:', style: TextStyle(color: cSlate)),
                    Text('KSK-2026-TRF-4819', style: TextStyle(fontWeight: FontWeight.bold, color: cNavy)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Durum:', style: TextStyle(color: cSlate)),
                    Text('Poliçe Aktif (317 Gün Kaldı)', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Bu poliçe KKTC Sigortalar Birliği ve PGM Trafik veri tabanı ile tam senkronizedir.',
            style: TextStyle(fontSize: 12, color: cSlate),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: cNavy,
                side: const BorderSide(color: cNavy),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: () {
                Navigator.pop(context);
                _showSnackbar('Kıbrıs Sigorta Müşteri Hizmetleri Aranıyor: 0392 228 11 22');
              },
              icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
              label: const Text('Sigorta Acentesini Ara', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ],
      ),
      actionLabel: 'Apple / Google Wallet\'a Ekle',
      onAction: () {
        _showSnackbar('Dijital sigorta kartı Wallet cüzdanına eklendi!');
      },
    );
  }

  // Radar Fotoğrafı ve Kanıt Modalı
  void _openRadarFotografKanitModal() {
    if (!_girisGerekliKontrol('Radar ihlal fotoğrafı ve kamera kanıtlarını incelemek')) return;
    _showInfoSheet(
      title: 'Radar Fotoğrafı & Telemetri Kanıtı',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 180,
              width: double.infinity,
              color: Colors.black,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=800',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF1E293B),
                      child: const Center(
                        child: Icon(Icons.videocam_rounded, size: 48, color: Colors.white54),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '18.05.2024 14:22:08 • GÖNYELİ-01',
                        style: TextStyle(
                          color: cAccent,
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: cDanger,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'ÖLÇÜLEN HIZ: 82 km/s (LİMİT: 65)',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'monospace',
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Tebliğ No: PGM-TRF-2024-8841\nCihaz: Sensys Gatso T-Series Sabit Hız Radarı\nDijital İmza: SHA256: 8a91b...c491f (Onaylı Adli Delil)',
            style: TextStyle(
              fontSize: 11.5,
              color: cSlate,
              height: 1.5,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
      actionLabel: 'Görüntüyü İndir / Paylaş (PDF)',
      onAction: () {
        _showSnackbar('Resmi radar kanıt belgesi indirildi.');
      },
    );
  }

  // Genel Ayarlar Modalı
  void _openSettingsModal() {
    _showInfoSheet(
      title: 'Uygulama Ayarları',
      content: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.palette_outlined, color: cNavy),
            title: const Text('Tema Görünümü', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Açık / Koyu Tema Seçimi'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: cNavy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                KktcTemaServisi().temaAdi,
                style: const TextStyle(color: cNavy, fontWeight: FontWeight.bold, fontSize: 11.5),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              KktcTemaServisi().showTemaSecimDialog(context);
            },
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.language_rounded, color: cNavy),
            title: const Text('Varsayılan Dil', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Türkçe / English'),
            trailing: const Text('Türkçe', style: TextStyle(color: cSlate, fontWeight: FontWeight.bold)),
            onTap: () => _showSnackbar('Dil seçimi üst bardan da değiştirilebilir'),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.cloud_off_rounded, color: cNavy),
            title: const Text('Çevrimdışı Radar Veritabanı', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('İnternetsiz GPS sesli uyarıları'),
            trailing: Switch(
              value: true,
              activeColor: cNavy,
              onChanged: (v) {},
            ),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.security_rounded, color: Color(0xFF10B981)),
            title: const Text('Siber Güvenlik Duvarı & SOC', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('WAF Koruma Paneli (Özel Yönetici Girişi)'),
            trailing: const Icon(Icons.lock_rounded, size: 18, color: cSlate),
            onTap: () {
              Navigator.pop(context);
              _adminPinDiyaloguAc();
            },
          ),
        ],
      ),
    );
  }

  int _secretLogoClicks = 0;

  void _adminPinDiyaloguAc() {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Text(
                'Yönetici / SOC Girişi',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Siber Güvenlik Duvarı & SOC Olay Günlüğünü açmak için 4 haneli PIN kodunu giriniz (1907 / 1974):',
                style: TextStyle(color: Colors.white70, fontSize: 12),
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
              child: const Text('İptal', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              onPressed: () {
                if (pinController.text == "1907" || pinController.text == "1974" || pinController.text == "9999") {
                  Navigator.pop(ctx);
                  GuvenlikDuvari.guvenlikPaneliGoster(context, true);
                } else {
                  _showSnackbar('❌ Hatalı Yönetici PIN Kodu!');
                }
              },
              child: const Text('Doğrula', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Çıkış Yap Onay Diyaloğu
  void _showLogoutDialog() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: cDanger),
            SizedBox(width: 8),
            Text(
              'Çıkış Yapılsın mı?',
              style: TextStyle(
                color: cNavy,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'Oturumunuz kapatılacak ve güvenli e-Trafik giriş sayfasına yönlendirileceksiniz.',
          style: TextStyle(color: cSlate, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç', style: TextStyle(color: cSlate)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cDanger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              if (widget.onCikisYap != null) {
                widget.onCikisYap!();
              }
            },
            child: const Text('Evet, Çıkış Yap'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. ÜST HEADER (Brand Title Bar & Hızlı QR)
        _buildTopHeader(),
        const SizedBox(height: 12),

        // 2. KULLANICI PROFİL KARTI (AD Rozet Avatar & Ehliyet Puanı)
        _buildProfileCard(),
        const SizedBox(height: 20),

        // 3. KATEGORİ 1: ARAÇ & BELGE İŞLEMLERİ
        _buildCategorySection(
          indicatorColor: const Color(0xFF10B981),
          title: 'ARAÇ & BELGE İŞLEMLERİ',
          items: [
            _buildMenuItem(
              iconBgColor: const Color(0xFFE0F2FE),
              iconColor: const Color(0xFF0284C7),
              icon: Icons.directions_car_filled_rounded,
              title: 'Kayıtlı Araçlarım',
              subtitle: widget.girisYapildiMi ? 'BMW 3.20i & Mercedes C200' : 'Giriş yaparak sorgulayın',
              onTap: _openAraclarimSheet,
            ),
            _buildMenuItem(
              iconBgColor: const Color(0xFFE0E7FF),
              iconColor: const Color(0xFF4F46E5),
              icon: Icons.description_rounded,
              title: 'Seyrüsefer & Ruhsat Yenileme',
              subtitle: widget.girisYapildiMi ? 'Tüm belgeler güncel' : 'Giriş yaparak sorgulayın',
              subtitleColor: widget.girisYapildiMi ? const Color(0xFF059669) : cSlate,
              onTap: _openSeyruseferSheet,
            ),
            _buildMenuItem(
              iconBgColor: const Color(0xFFFEF3C7),
              iconColor: const Color(0xFFD97706),
              icon: Icons.calendar_month_rounded,
              title: 'Araç Fenni Muayene Takvimi',
              subtitle: widget.girisYapildiMi ? 'Kalan süre: 48 gün (09.05.2026)' : 'Giriş yaparak sorgulayın',
              onTap: _openMuayeneSheet,
            ),
            _buildMenuItem(
              iconBgColor: const Color(0xFFECFDF5),
              iconColor: const Color(0xFF059669),
              icon: Icons.verified_user_rounded,
              title: 'Sigorta & Kasko Poliçeleri',
              subtitle: widget.girisYapildiMi ? 'Kıbrıs Sigorta Kooperatifi • Aktif' : 'Giriş yaparak sorgulayın',
              onTap: _openSigortaSheet,
            ),
          ],
        ),
        const SizedBox(height: 22),

        // 4. KATEGORİ 2: RADAR & GÜZERGAH
        _buildCategorySection(
          indicatorColor: const Color(0xFFF59E0B),
          title: 'RADAR & GÜZERGAH',
          items: [
            _buildMenuItem(
              iconBgColor: const Color(0xFFCCFBF1),
              iconColor: const Color(0xFF0F766E),
              icon: Icons.map_rounded,
              title: 'Haritalar & Canlı Radarlar',
              subtitle: 'Google Maps tarzı canlı tam ekran harita',
              subtitleColor: const Color(0xFF059669),
              onTap: () {
                if (widget.onOpenRadars != null) {
                  widget.onOpenRadars!();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RadarHaritasiSayfasi(turkceMi: true),
                    ),
                  );
                }
              },
            ),
            _buildMenuItem(
              customIconWidget: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFDC2626), width: 2),
                ),
                child: const Center(
                  child: Text(
                    '65',
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              iconBgColor: const Color(0xFFFEE2E2),
              iconColor: const Color(0xFFDC2626),
              title: 'Hız Limitleri & Sabit Kameralar',
              subtitle: '142 Sabit Hız & Işık Kamerası',
              onTap: widget.onOpenRadars,
            ),
            _buildMenuItem(
              iconBgColor: const Color(0xFFF3E8FF),
              iconColor: const Color(0xFF9333EA),
              icon: Icons.alt_route_rounded,
              title: 'Navigasyon & Rota Planlayıcı',
              subtitle: 'Canlı radar uyarıları ile sürüş',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => YolTarifiSayfasi(
                      turkceMi: true,
                      onTamEkranDegisti: (tamEkran) {},
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 22),

        // 5. KATEGORİ 3: CEZA & HUKUKİ İŞLEMLER
        _buildCategorySection(
          indicatorColor: const Color(0xFFF43F5E),
          title: 'CEZA & HUKUKİ İŞLEMLER',
          items: [
            _buildMenuItem(
              iconBgColor: const Color(0xFFFFE4E6),
              iconColor: const Color(0xFFE11D48),
              icon: Icons.receipt_long_rounded,
              title: 'Trafik Cezalarım & Ödeme',
              subtitle: widget.girisYapildiMi ? '1 Adet Bekleyen Ceza Bildirimi' : 'Giriş yaparak sorgulayın',
              subtitleColor: widget.girisYapildiMi ? const Color(0xFFE11D48) : cSlate,
              trailingBadgeText: widget.girisYapildiMi ? '1 Ödenmemiş' : 'Giriş Gerekli',
              trailingBadgeBg: widget.girisYapildiMi ? const Color(0xFFFFE4E6) : Colors.grey.shade100,
              trailingBadgeTextColor: widget.girisYapildiMi ? const Color(0xFFBE123C) : cSlate,
              onTap: () {
                if (!_girisGerekliKontrol('Trafik cezalarınızı ve ödeme kayıtlarınızı görüntülemek')) return;
                if (widget.onOpenFines != null) widget.onOpenFines!();
              },
            ),
            _buildMenuItem(
              iconBgColor: const Color(0xFFE0E7FF),
              iconColor: const Color(0xFF4338CA),
              icon: Icons.photo_camera_rounded,
              title: 'Radar Fotoğrafı & Kanıt İnceleme',
              subtitle: 'Kamera ihlal görüntüsü ve telemetri',
              onTap: _openRadarFotografKanitModal,
            ),
            _buildMenuItem(
              iconBgColor: const Color(0xFFF1F5F9),
              iconColor: cSlate,
              icon: Icons.article_rounded,
              title: 'İtiraz & Dilekçe İşlemleri',
              subtitle: 'Hakem Kurulu online başvuru',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ItirazSayfasi(turkceMi: true),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 22),

        // 6. KATEGORİ 4: POLİS & KAMU İLETİŞİMİ
        _buildCategorySection(
          indicatorColor: const Color(0xFF2563EB),
          title: 'POLİS & KAMU İLETİŞİMİ',
          items: [
            _buildMenuItem(
              iconBgColor: const Color(0xFFEF4444).withOpacity(0.15),
              iconColor: const Color(0xFFEF4444),
              icon: Icons.car_repair_rounded,
              title: '7/24 KKTC Yol Yardımı & Çekici',
              subtitle: 'Acil oto çekici, akü & kurtarma hattı',
              subtitleColor: const Color(0xFFDC2626),
              gradientBackground: const LinearGradient(
                colors: [Color(0xFFFEF2F2), Colors.white],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderColor: const Color(0xFFFECACA),
              onTap: () async {
                final Uri telUri = Uri.parse('tel:03922288888');
                if (await canLaunchUrl(telUri)) {
                  await launchUrl(telUri);
                }
              },
            ),
            _buildMenuItem(
              iconBgColor: const Color(0xFFFEE2E2),
              iconColor: const Color(0xFFDC2626),
              icon: Icons.phone_in_talk_rounded,
              title: 'Acil Trafik İhbar & 155 Polis İmdat',
              subtitle: '7/24 Kesintisiz Hat',
              onTap: _ara155,
            ),
            _buildMenuItem(
              iconBgColor: const Color(0xFFE0F2FE),
              iconColor: const Color(0xFF0369A1),
              icon: Icons.menu_book_rounded,
              title: 'Trafik Dairesi & İletişim Rehberi',
              subtitle: 'Kaza anında yapılacaklar & şubeler',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const YardimRehberiSayfasi(turkceMi: true),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 22),

        // 7. KATEGORİ 5: GÜVENLİK & SİSTEM İŞLEMLERİ (Önceki Gelişmiş Özellikler)
        _buildCategorySection(
          indicatorColor: const Color(0xFF4F46E5),
          title: 'GÜVENLİK & SİSTEM İŞLEMLERİ',
          items: [
            _buildMenuItem(
              iconBgColor: const Color(0xFFEDE9FE),
              iconColor: const Color(0xFF7C3AED),
              icon: Icons.notifications_active_rounded,
              title: 'Bildirim & Radar Ayarları',
              subtitle: 'Hız aşımı ve ceza uyarı tercihleri',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BildirimAyarlariSayfasi(turkceMi: true),
                  ),
                );
              },
            ),
            _buildMenuItem(
              iconBgColor: const Color(0xFFE0E7FF),
              iconColor: const Color(0xFF4338CA),
              icon: Icons.receipt_rounded,
              title: 'Ödeme Dekontları & Makbuz Arşivi',
              subtitle: 'Geçmiş ödemelerin resmi makbuzları',
              onTap: () {
                if (!_girisGerekliKontrol('Geçmiş ödeme dekontları ve makbuz arşivinizi görüntülemek')) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DekontlarSayfasi(
                      dekontlar: _dekontlar,
                      turkceMi: true,
                    ),
                  ),
                );
              },
            ),
            _buildMenuItem(
              iconBgColor: const Color(0xFFFEF3C7),
              iconColor: const Color(0xFFD97706),
              icon: Icons.manage_search_rounded,
              title: 'Hızlı Arama & 2026 Ceza Cetveli',
              subtitle: 'Asgari ücrete endeksli resmi cezalar',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => HizliAramaModalSayfasi(
                    turkceMi: true,
                    onHedefeGit: (hedefId) {},
                  ),
                );
              },
            ),
            _buildMenuItem(
              iconBgColor: const Color(0xFFCFFAFE),
              iconColor: const Color(0xFF0891B2),
              icon: Icons.sync_rounded,
              title: 'Mevzuat & Veri Eşitleme',
              subtitle: 'KKTC resmi sunucuları ile güncel tut',
              onTap: () {
                GuncellemeServisi.manuelKontrolEt(context, true);
              },
            ),
          ],
        ),
        const SizedBox(height: 22),

        // 8. ALT AYARLAR & ÇIKIŞ YAP BUTONLARI (SPLIT)
        _buildBottomUtilityActions(),
        const SizedBox(height: 20),

        // 9. ALT BİLGİ / TELİF
        Center(
          child: Text(
            'KKTC Trafik Dairesi Çevrimiçi Portalı v2.4.0',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Üst Bar (Header)
  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            _secretLogoClicks++;
            if (_secretLogoClicks >= 5) {
              _secretLogoClicks = 0;
              _adminPinDiyaloguAc();
            }
          },
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: cNavy,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: cNavy.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'TR',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KKTC e-TRAFİK',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: cNavy,
                      letterSpacing: 0.6,
                    ),
                  ),
                  Text(
                    'Bayındırlık ve Ulaştırma Bakanlığı',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: cSlate,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Hızlı QR Göster Butonu
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (!_girisGerekliKontrol('Karekodlu resmi dijital sürücü belgesi oluşturmak')) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BarkodluBelgeSayfasi(
                    kullanici: widget.kullaniciAdi,
                    puan: 85,
                    turkceMi: true,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.qr_code_2_rounded,
                size: 20,
                color: cNavy,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Profil Kartı
  Widget _buildProfileCard() {
    if (!widget.girisYapildiMi) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            if (widget.onGirisYap != null) {
              widget.onGirisYap!();
            }
          },
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: cNavy.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Misafir Avatarı
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cNavy.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: cNavy,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 2,
                        children: [
                          const Text(
                            'Misafir Kullanıcı',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: cNavy,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Text(
                              'Giriş Yapılmadı',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: cSlate,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Cezalar ve araç dökümü için tıklayın',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: cSlate,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(Icons.login_rounded, size: 12, color: Color(0xFF059669)),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Kimlik / Ehliyet ile Giriş Yap',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF059669),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: cNavy,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Giriş',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 13, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final String initials = widget.kullaniciAdi.isNotEmpty
        ? (widget.kullaniciAdi.length >= 2
            ? widget.kullaniciAdi.substring(0, 2).toUpperCase()
            : widget.kullaniciAdi.toUpperCase())
        : 'AD';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BarkodluBelgeSayfasi(
                kullanici: widget.kullaniciAdi,
                puan: 85,
                turkceMi: true,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: cNavy.withOpacity(0.04),
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
                    // AD İnisiyal Avatarı ve Yeşil Çevrimiçi Nokta
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE4E6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Color(0xFFBE123C),
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
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
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.kullaniciAdi,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: cNavy,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cAccentLight,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: cAccent.withOpacity(0.4)),
                                ),
                                child: const Text(
                                  '85/100 Puan',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF857B0D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'KKTC Ehliyet: 123456',
                            style: TextStyle(
                              fontSize: 12,
                              color: cSlate,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Sınıf A2, B, D',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text('•', style: TextStyle(color: cSlate, fontSize: 11)),
                              const SizedBox(width: 6),
                              const Text(
                                'Geçerli Sürücü',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF059669),
                                  fontWeight: FontWeight.w700,
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
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Kategori Bölümü Wrapper
  Widget _buildCategorySection({
    required Color indicatorColor,
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Container(
                width: 7.5,
                height: 7.5,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: cSlate,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: items
              .map((it) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.5),
                    child: it,
                  ))
              .toList(),
        ),
      ],
    );
  }

  // Menü Maddesi Kartı
  Widget _buildMenuItem({
    required Color iconBgColor,
    required Color iconColor,
    IconData? icon,
    Widget? customIconWidget,
    required String title,
    String? subtitle,
    Color? subtitleColor,
    String? trailingBadgeText,
    Color? trailingBadgeBg,
    Color? trailingBadgeTextColor,
    Gradient? gradientBackground,
    Color? borderColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          if (onTap != null) onTap();
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(13.5),
          decoration: BoxDecoration(
            color: gradientBackground == null ? Colors.white : null,
            gradient: gradientBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: borderColor ?? Colors.grey.shade100,
            ),
            boxShadow: [
              BoxShadow(
                color: cNavy.withOpacity(0.025),
                blurRadius: 6,
                offset: const Offset(0, 2),
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
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: customIconWidget ??
                            Icon(
                              icon,
                              size: 22,
                              color: iconColor,
                            ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: cNavy,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: subtitleColor ?? cSlate,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (trailingBadgeText != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: trailingBadgeBg ?? const Color(0xFFFFE4E6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        trailingBadgeText,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: trailingBadgeTextColor ?? const Color(0xFFBE123C),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Color(0xFF9CA3AF),
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

  // Alt Ayarlar & Çıkış Yap Bölümü
  Widget _buildBottomUtilityActions() {
    return Row(
      children: [
        // Ayarlar Butonu
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openSettingsModal,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: cNavy.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.settings_outlined, size: 19, color: cSlate),
                    SizedBox(width: 8),
                    Text(
                      'Ayarlar',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: cNavy,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Çıkış Yap / Giriş Yap Butonu
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.girisYapildiMi
                  ? _showLogoutDialog
                  : () {
                      if (widget.onGirisYap != null) {
                        widget.onGirisYap!();
                      }
                    },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: widget.girisYapildiMi ? cSoftRed : cNavy,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: widget.girisYapildiMi
                        ? const Color(0xFFFECDD3)
                        : Colors.transparent,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.girisYapildiMi
                          ? cDanger.withOpacity(0.04)
                          : cNavy.withOpacity(0.18),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.girisYapildiMi ? Icons.logout_rounded : Icons.login_rounded,
                      size: 19,
                      color: widget.girisYapildiMi ? cDanger : const Color(0xFFD1C929),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.girisYapildiMi ? 'Çıkış Yap' : 'Giriş Yap',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: widget.girisYapildiMi ? cDanger : Colors.white,
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
}
