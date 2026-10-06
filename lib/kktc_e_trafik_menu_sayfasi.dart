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
import 'kktc_dil_servisi.dart';

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
  // 🌙 Koyu tema uyumlu dinamik metin & yüzey renkleri
  bool get isKoyu => KktcTemaServisi().isKoyuAktif;
  Color get cInk => KktcTemaServisi().isKoyuAktif ? const Color(0xFFF1F5F9) : cNavy;
  Color get cSurface => KktcTemaServisi().isKoyuAktif ? const Color(0xFF151D30) : Colors.white;
  Color get cSoftSurface => KktcTemaServisi().isKoyuAktif ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
  Color get cMuted => KktcTemaServisi().isKoyuAktif ? const Color(0xFF94A3B8) : cSlate;
  Color get cLine => KktcTemaServisi().isKoyuAktif ? const Color(0xFF243048) : const Color(0xFFE2E8F0);
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
          title: Row(
            children: [
              Icon(Icons.lock_rounded, color: cInk, size: 22),
              SizedBox(width: 8),
              Text(
                'Giriş Yapmalısınız',
                style: TextStyle(fontWeight: FontWeight.w800, color: cInk, fontSize: 17),
              ),
            ],
          ),
          content: Text(
            '$islemAdi için KKTC Kimlik veya Ehliyet numaranız ile sisteme giriş yapmalısınız.',
            style: TextStyle(fontSize: 13.5, color: cMuted, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Vazgeç', style: TextStyle(color: cMuted)),
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
    final bool koyuMu = KktcTemaServisi().isKoyu(context);
    final Color sheetBg = koyuMu ? const Color(0xFF151D30) : Colors.white;
    final Color titleColor = koyuMu ? Colors.white : cNavy;

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
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
                      color: koyuMu ? Colors.white24 : Colors.grey.shade300,
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: koyuMu ? Colors.white70 : cMuted),
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
                        backgroundColor: koyuMu ? const Color(0xFF2563EB) : cNavy,
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
    final bool koyuMu = KktcTemaServisi().isKoyu(context);
    final Color cardBg = isActive
        ? (koyuMu ? const Color(0xFF064E3B).withOpacity(0.35) : const Color(0xFFF0FDF4))
        : (koyuMu ? const Color(0xFF1E293B) : Colors.white);
    final Color borderCol = isActive
        ? const Color(0xFF10B981)
        : (koyuMu ? const Color(0xFF334155) : Colors.grey.shade200);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderCol,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: koyuMu ? const Color(0xFF2563EB) : cNavy,
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
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: koyuMu ? Colors.white : cInk,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Şasi: $chassis',
                  style: TextStyle(
                    fontSize: 11,
                    color: koyuMu ? const Color(0xFF94A3B8) : cMuted,
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            Chip(
              label: const Text(
                'Seçili',
                style: TextStyle(
                  color: Color(0xFF047857),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              backgroundColor: koyuMu ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7),
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Araç Plaka:', style: TextStyle(color: cMuted)),
                    Text('RZ 123 (BMW 3.20i)', style: TextStyle(fontWeight: FontWeight.bold, color: cInk)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dönem:', style: TextStyle(color: cMuted)),
                    Text('2026 / 2. Dönem', style: TextStyle(fontWeight: FontWeight.bold, color: cInk)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Son Geçerlilik:', style: TextStyle(color: cMuted)),
                    Text('26 Aralık 2026 (86 Gün)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Harç Tutarı:', style: TextStyle(color: cMuted)),
                    Text('₺3.450,00', style: TextStyle(fontWeight: FontWeight.w900, color: cInk, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Belgeniz resmi kamu veri tabanında güncel ve geçerlidir. Erken yenilemede %10 indirim uygulanmaktadır.',
            style: TextStyle(fontSize: 12, color: cMuted),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: cInk,
                side: BorderSide(color: cInk),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BarkodluBelgeSayfasi(
                      kullanici: 'Ahmet Demir',
                      puan: 85,
                      turkceMi: KktcDilServisi().turkceMi,
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
        backgroundColor: cSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          dil('Seyrüsefer Harcı Tahsilatı', 'Road Tax Payment'),
          style: TextStyle(fontWeight: FontWeight.w900, color: cInk, fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dil(
                'RZ 123 (BMW 3.20i) için 2027 1. Dönem erken yenileme harcı (%10 indirimle ₺3.105,00) tahsil edilecektir.',
                'For RZ 123 (BMW 3.20i), 2027 Term 1 early renewal fee (₺3,105.00 with 10% discount) will be charged.',
              ),
              style: TextStyle(fontSize: 13, color: cMuted),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cSoftSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cLine),
              ),
              child: Row(
                children: [
                  Icon(Icons.credit_card_rounded, color: cInk, size: 20),
                  const SizedBox(width: 8),
                  Text('Garanti Bonus (•••• 4412)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(dil('Vazgeç', 'Cancel'), style: TextStyle(color: cMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cNavy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _showSnackbar(dil('Seyrüsefer yenilendi! Resmi dijital pul oluşturuldu.', 'Road tax renewed! Digital tax disc created.'));
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BarkodluBelgeSayfasi(
                    kullanici: 'Ahmet Demir',
                    puan: 85,
                    turkceMi: KktcDilServisi().turkceMi,
                  ),
                ),
              );
            },
            child: Text(dil('Öde & Belgeyi Al', 'Pay & Get Certificate'), style: const TextStyle(fontWeight: FontWeight.bold)),
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Kalan Süre:', style: TextStyle(color: cMuted)),
                    Text('48 Gün Kaldı', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFD97706))),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Son Muayene Tarihi:', style: TextStyle(color: cMuted)),
                    Text('09 Mayıs 2026', style: TextStyle(fontWeight: FontWeight.bold, color: cInk)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('İstasyon:', style: TextStyle(color: cMuted)),
                    Text('Lefkoşa Polis Muayene Şube', style: TextStyle(fontWeight: FontWeight.bold, color: cInk)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Fenni muayenesiz araç kullanmanın cezası ₺1.850,00 ve 5 ceza puanıdır. Randevunuzu önceden oluşturun.',
            style: TextStyle(fontSize: 12, color: cMuted),
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Sigorta Şirketi:', style: TextStyle(color: cMuted)),
                    Text('Kıbrıs Sigorta Kooperatifi', style: TextStyle(fontWeight: FontWeight.bold, color: cInk)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Poliçe No:', style: TextStyle(color: cMuted)),
                    Text('KSK-2026-TRF-4819', style: TextStyle(fontWeight: FontWeight.bold, color: cInk)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Durum:', style: TextStyle(color: cMuted)),
                    Text('Poliçe Aktif (317 Gün Kaldı)', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Bu poliçe KKTC Sigortalar Birliği ve PGM Trafik veri tabanı ile tam senkronizedir.',
            style: TextStyle(fontSize: 12, color: cMuted),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: cInk,
                side: BorderSide(color: cInk),
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
          Text(
            'Tebliğ No: PGM-TRF-2024-8841\nCihaz: Sensys Gatso T-Series Sabit Hız Radarı\nDijital İmza: SHA256: 8a91b...c491f (Onaylı Adli Delil)',
            style: TextStyle(
              fontSize: 11.5,
              color: cMuted,
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
    final bool koyuMu = KktcTemaServisi().isKoyu(context);
    final Color titleColor = koyuMu ? Colors.white : cNavy;
    final Color subColor = koyuMu ? const Color(0xFF94A3B8) : cSlate;
    final Color iconColor = koyuMu ? const Color(0xFF38BDF8) : cNavy;
    final Color divColor = koyuMu ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    _showInfoSheet(
      title: 'Uygulama Ayarları',
      content: ListenableBuilder(
        listenable: Listenable.merge([KktcTemaServisi(), KktcDilServisi()]),
        builder: (modalCtx, _) {
          return Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.palette_outlined, color: iconColor),
                title: Text('Tema Görünümü', style: TextStyle(fontWeight: FontWeight.w600, color: titleColor)),
                subtitle: Text('Açık / Koyu Tema Seçimi', style: TextStyle(color: subColor)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: koyuMu ? const Color(0xFF1E293B) : cNavy.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    KktcTemaServisi().temaAdi,
                    style: TextStyle(color: koyuMu ? const Color(0xFF38BDF8) : cInk, fontWeight: FontWeight.bold, fontSize: 11.5),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  KktcTemaServisi().showTemaSecimDialog(context);
                },
              ),
              Divider(color: divColor),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.language_rounded, color: iconColor),
                title: Text('Varsayılan Dil', style: TextStyle(fontWeight: FontWeight.w600, color: titleColor)),
                subtitle: Text('Türkçe / English', style: TextStyle(color: subColor)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: koyuMu ? const Color(0xFF1E293B) : cNavy.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    KktcDilServisi().dilAdi,
                    style: TextStyle(color: koyuMu ? const Color(0xFF38BDF8) : cInk, fontWeight: FontWeight.bold, fontSize: 11.5),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  KktcDilServisi().showDilSecimDialog(context);
                },
              ),
              Divider(color: divColor),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.cloud_off_rounded, color: iconColor),
            title: Text('Çevrimdışı Radar Veritabanı', style: TextStyle(fontWeight: FontWeight.w600, color: titleColor)),
            subtitle: Text('İnternetsiz GPS sesli uyarıları', style: TextStyle(color: subColor)),
            trailing: Switch(
              value: true,
              activeColor: koyuMu ? const Color(0xFF38BDF8) : cInk,
              onChanged: (v) {},
            ),
          ),
          Divider(color: divColor),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.security_rounded, color: Color(0xFF10B981)),
            title: Text('Siber Güvenlik Duvarı & SOC', style: TextStyle(fontWeight: FontWeight.w600, color: titleColor)),
            subtitle: Text('WAF Koruma Paneli (Özel Yönetici Girişi)', style: TextStyle(color: subColor)),
            trailing: Icon(Icons.lock_rounded, size: 18, color: subColor),
            onTap: () {
              Navigator.pop(context);
              _adminPinDiyaloguAc();
            },
          ),
        ],
      );
    },
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
        backgroundColor: cSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.logout_rounded, color: cDanger),
            SizedBox(width: 8),
            Text(
              'Çıkış Yapılsın mı?',
              style: TextStyle(
                color: cInk,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'Oturumunuz kapatılacak ve güvenli e-Trafik giriş sayfasına yönlendirileceksiniz.',
          style: TextStyle(color: cMuted, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Vazgeç', style: TextStyle(color: cMuted)),
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
    return ListenableBuilder(
      listenable: KktcDilServisi(),
      builder: (context, _) {
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
          title: dil('ARAÇ & BELGE İŞLEMLERİ', 'VEHICLES & DOCUMENTS'),
          items: [
            _buildMenuItem(
              iconBgColor: const Color(0xFFE0F2FE),
              iconColor: const Color(0xFF0284C7),
              icon: Icons.directions_car_filled_rounded,
              title: dil('Kayıtlı Araçlarım', 'My Registered Vehicles'),
              subtitle: widget.girisYapildiMi ? 'BMW 3.20i & Mercedes C200' : dil('Giriş yaparak sorgulayın', 'Sign in to inquire'),
              onTap: _openAraclarimSheet,
            ),
            _buildMenuItem(
              iconBgColor: const Color(0xFFE0E7FF),
              iconColor: const Color(0xFF4F46E5),
              icon: Icons.description_rounded,
              title: dil('Seyrüsefer & Ruhsat Yenileme', 'Road Tax & Registration Renewal'),
              subtitle: widget.girisYapildiMi ? dil('Tüm belgeler güncel', 'All documents are up to date') : dil('Giriş yaparak sorgulayın', 'Sign in to inquire'),
              subtitleColor: widget.girisYapildiMi ? const Color(0xFF059669) : cSlate,
              onTap: _openSeyruseferSheet,
            ),
            _buildMenuItem(
              iconBgColor: const Color(0xFFFEF3C7),
              iconColor: const Color(0xFFD97706),
              icon: Icons.calendar_month_rounded,
              title: dil('Araç Fenni Muayene Takvimi', 'Vehicle Inspection Schedule'),
              subtitle: widget.girisYapildiMi ? dil('Kalan süre: 48 gün (09.05.2026)', '48 days left (09.05.2026)') : dil('Giriş yaparak sorgulayın', 'Sign in to inquire'),
              onTap: _openMuayeneSheet,
            ),
            _buildMenuItem(
              iconBgColor: const Color(0xFFECFDF5),
              iconColor: const Color(0xFF059669),
              icon: Icons.verified_user_rounded,
              title: dil('Sigorta & Kasko Poliçeleri', 'Insurance & Motor Policies'),
              subtitle: widget.girisYapildiMi ? dil('Kıbrıs Sigorta Kooperatifi • Aktif', 'Cyprus Insurance Coop • Active') : dil('Giriş yaparak sorgulayın', 'Sign in to inquire'),
              onTap: _openSigortaSheet,
            ),
          ],
        ),
        const SizedBox(height: 22),

        // 4. KATEGORİ 2: RADAR & GÜZERGAH
        _buildCategorySection(
          indicatorColor: const Color(0xFFF59E0B),
          title: dil('RADAR & GÜZERGAH', 'RADAR & ROUTES'),
          items: [
            _buildMenuItem(
              iconBgColor: const Color(0xFFCCFBF1),
              iconColor: const Color(0xFF0F766E),
              icon: Icons.map_rounded,
              title: dil('Haritalar & Canlı Radarlar', 'Maps & Live Radars'),
              subtitle: dil('Google Maps tarzı canlı tam ekran harita', 'Full-screen live radar navigation map'),
              subtitleColor: const Color(0xFF059669),
              onTap: () {
                if (widget.onOpenRadars != null) {
                  widget.onOpenRadars!();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RadarHaritasiSayfasi(turkceMi: KktcDilServisi().turkceMi),
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
              title: dil('Hız Limitleri & Sabit Kameralar', 'Speed Limits & Fixed Cameras'),
              subtitle: dil('142 Sabit Hız & Işık Kamerası', '142 Fixed Speed & Red Light Cameras'),
              onTap: widget.onOpenRadars,
            ),
            _buildMenuItem(
              iconBgColor: const Color(0xFFF3E8FF),
              iconColor: const Color(0xFF9333EA),
              icon: Icons.alt_route_rounded,
              title: dil('Navigasyon & Rota Planlayıcı', 'Navigation & Route Planner'),
              subtitle: dil('Canlı radar uyarıları ile sürüş', 'Drive with live speed alerts'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => YolTarifiSayfasi(
                      turkceMi: KktcDilServisi().turkceMi,
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
          title: dil('CEZA & HUKUKİ İŞLEMLER', 'FINES & LEGAL INQUIRIES'),
          items: [
            _buildMenuItem(
              iconBgColor: const Color(0xFFFFE4E6),
              iconColor: const Color(0xFFE11D48),
              icon: Icons.receipt_long_rounded,
              title: dil('Trafik Cezalarım & Ödeme', 'My Traffic Fines & Payment'),
              subtitle: widget.girisYapildiMi ? dil('1 Adet Bekleyen Ceza Bildirimi', '1 Pending Fine Notice') : dil('Giriş yaparak sorgulayın', 'Sign in to inquire'),
              subtitleColor: widget.girisYapildiMi ? const Color(0xFFE11D48) : cSlate,
              trailingBadgeText: widget.girisYapildiMi ? dil('1 Ödenmemiş', '1 Unpaid') : dil('Giriş Gerekli', 'Login Required'),
              trailingBadgeBg: widget.girisYapildiMi ? const Color(0xFFFFE4E6) : Colors.grey.shade100,
              trailingBadgeTextColor: widget.girisYapildiMi ? const Color(0xFFBE123C) : cSlate,
              onTap: () {
                if (!_girisGerekliKontrol(dil('Trafik cezalarınızı ve ödeme kayıtlarınızı görüntülemek', 'Viewing your traffic fines and payments'))) return;
                if (widget.onOpenFines != null) widget.onOpenFines!();
              },
            ),
            _buildMenuItem(
              iconBgColor: const Color(0xFFE0E7FF),
              iconColor: const Color(0xFF4338CA),
              icon: Icons.photo_camera_rounded,
              title: dil('Radar Fotoğrafı & Kanıt İnceleme', 'Radar Photo & Evidence Review'),
              subtitle: dil('Kamera ihlal görüntüsü ve telemetri', 'Camera violation capture & telemetry'),
              onTap: _openRadarFotografKanitModal,
            ),
            _buildMenuItem(
              iconBgColor: const Color(0xFFF1F5F9),
              iconColor: cSlate,
              icon: Icons.article_rounded,
              title: dil('İtiraz & Dilekçe İşlemleri', 'Objections & Petitions'),
              subtitle: dil('Hakem Kurulu online başvuru', 'Traffic arbitration board online request'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItirazSayfasi(turkceMi: KktcDilServisi().turkceMi),
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
          title: dil('POLİS & KAMU İLETİŞİMİ', 'POLICE & PUBLIC SERVICES'),
          items: [
            _buildMenuItem(
              iconBgColor: const Color(0xFFEF4444).withOpacity(0.15),
              iconColor: const Color(0xFFEF4444),
              icon: Icons.car_repair_rounded,
              title: dil('7/24 KKTC Yol Yardımı & Çekici', '24/7 TRNC Roadside & Towing'),
              subtitle: dil('Acil oto çekici, akü & kurtarma hattı', 'Emergency vehicle recovery & towing'),
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
              title: dil('Acil Trafik İhbar & 155 Polis İmdat', 'Emergency Traffic & 155 Police'),
              subtitle: dil('7/24 Kesintisiz Hat', '24/7 Non-stop Hotline'),
              onTap: _ara155,
            ),
            _buildMenuItem(
              iconBgColor: const Color(0xFFE0F2FE),
              iconColor: const Color(0xFF0369A1),
              icon: Icons.menu_book_rounded,
              title: dil('Yardım & SSS (Trafik Rehberi)', 'Help & FAQ (Traffic Guide)'),
              subtitle: dil('Sık sorular, acil adımlar & yasalar', 'FAQs, emergency steps & laws'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => YardimRehberiSayfasi(turkceMi: KktcDilServisi().turkceMi),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 22),

        // 7. KATEGORİ 5: GÜVENLİK & SİSTEM İŞLEMLERİ
        _buildCategorySection(
          indicatorColor: const Color(0xFF4F46E5),
          title: dil('GÜVENLİK & SİSTEM İŞLEMLERİ', 'SECURITY & SYSTEM'),
          items: [
            _buildMenuItem(
              iconBgColor: const Color(0xFFEDE9FE),
              iconColor: const Color(0xFF7C3AED),
              icon: Icons.notifications_active_rounded,
              title: dil('Bildirim & Radar Ayarları', 'Notification & Radar Settings'),
              subtitle: dil('Hız aşımı ve ceza uyarı tercihleri', 'Speed excess & fine alert preferences'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BildirimAyarlariSayfasi(turkceMi: KktcDilServisi().turkceMi),
                  ),
                );
              },
            ),
            _buildMenuItem(
              iconBgColor: const Color(0xFFE0E7FF),
              iconColor: const Color(0xFF4338CA),
              icon: Icons.receipt_rounded,
              title: dil('Ödeme Dekontları & Makbuz Arşivi', 'Payment Receipts & Official Archive'),
              subtitle: dil('Geçmiş ödemelerin resmi makbuzları', 'Official tax receipts of past payments'),
              onTap: () {
                if (!_girisGerekliKontrol(dil('Geçmiş ödeme dekontları ve makbuz arşivinizi görüntülemek', 'Viewing your past payment receipts archive'))) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DekontlarSayfasi(
                      dekontlar: _dekontlar,
                      turkceMi: KktcDilServisi().turkceMi,
                    ),
                  ),
                );
              },
            ),
            _buildMenuItem(
              iconBgColor: const Color(0xFFFEF3C7),
              iconColor: const Color(0xFFD97706),
              icon: Icons.manage_search_rounded,
              title: dil('Hızlı Arama & 2026 Ceza Cetveli', 'Quick Search & 2026 Penalty Table'),
              subtitle: dil('Asgari ücrete endeksli resmi cezalar', 'Official fines indexed to minimum wage'),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => HizliAramaModalSayfasi(
                    turkceMi: KktcDilServisi().turkceMi,
                    onHedefeGit: (hedefId) {},
                  ),
                );
              },
            ),
            _buildMenuItem(
              iconBgColor: const Color(0xFFCFFAFE),
              iconColor: const Color(0xFF0891B2),
              icon: Icons.sync_rounded,
              title: dil('Mevzuat & Veri Eşitleme', 'Legislation & Data Sync'),
              subtitle: dil('KKTC resmi sunucuları ile güncel tut', 'Keep synced with TRNC official servers'),
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
            dil('KKTC Trafik Dairesi Çevrimiçi Portalı v2.4.0', 'TRNC Traffic Department Online Portal v2.4.0'),
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
      },
    );
  }

  // Üst Bar (Header)
  Widget _buildTopHeader() {
    final bool koyuMu = KktcTemaServisi().isKoyu(context);
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
                  color: koyuMu ? const Color(0xFF2563EB) : cNavy,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: (koyuMu ? const Color(0xFF2563EB) : cNavy).withOpacity(0.25),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KKTC e-TRAFİK',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: koyuMu ? Colors.white : cInk,
                      letterSpacing: 0.6,
                    ),
                  ),
                  Text(
                    dil('Bayındırlık ve Ulaştırma Bakanlığı', 'Ministry of Public Works and Transportation'),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: koyuMu ? const Color(0xFF94A3B8) : cMuted,
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
              if (!_girisGerekliKontrol(dil('Karekodlu resmi dijital sürücü belgesi oluşturmak', 'Creating QR digital driver license'))) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BarkodluBelgeSayfasi(
                    kullanici: widget.kullaniciAdi,
                    puan: 85,
                    turkceMi: KktcDilServisi().turkceMi,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: koyuMu ? const Color(0xFF151D30) : cSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: koyuMu ? const Color(0xFF243048) : Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(koyuMu ? 0.2 : 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.qr_code_2_rounded,
                size: 20,
                color: koyuMu ? Colors.white : cInk,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Profil Kartı
  Widget _buildProfileCard() {
    final bool koyuMu = KktcTemaServisi().isKoyu(context);
    final Color cardBg = koyuMu ? const Color(0xFF151D30) : Colors.white;
    final Color cardBorder = koyuMu ? const Color(0xFF243048) : Colors.grey.shade200;
    final Color titleColor = koyuMu ? Colors.white : cNavy;
    final Color subColor = koyuMu ? const Color(0xFF94A3B8) : cSlate;

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
              color: cardBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(koyuMu ? 0.25 : 0.04),
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
                    color: koyuMu ? const Color(0xFF1E293B) : cNavy.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: koyuMu ? const Color(0xFF60A5FA) : cInk,
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
                          Text(
                            dil('Misafir Kullanıcı', 'Guest User'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: titleColor,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: koyuMu ? const Color(0xFF1E293B) : cSoftSurface,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: koyuMu ? const Color(0xFF334155) : Colors.grey.shade300),
                            ),
                            child: Text(
                              dil('Giriş Yapılmadı', 'Not Signed In'),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: subColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        dil('Cezalar ve araç dökümü için tıklayın', 'Tap to view fines and vehicles'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: subColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.login_rounded, size: 12, color: Color(0xFF10B981)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              dil('Kimlik / Ehliyet ile Giriş Yap', 'Sign In with ID / Driving License'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF10B981),
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
                    color: koyuMu ? const Color(0xFF2563EB) : cNavy,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dil('Giriş', 'Sign In'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, size: 13, color: Colors.white),
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
                turkceMi: KktcDilServisi().turkceMi,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: koyuMu ? const Color(0xFF243048) : Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(koyuMu ? 0.25 : 0.04),
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
                            color: koyuMu ? const Color(0xFF881337).withOpacity(0.4) : const Color(0xFFFFE4E6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: TextStyle(
                                color: koyuMu ? const Color(0xFFFDA4AF) : const Color(0xFFBE123C),
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
                              border: Border.all(color: koyuMu ? const Color(0xFF151D30) : Colors.white, width: 2),
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
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: titleColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: koyuMu ? const Color(0xFF422006) : cAccentLight,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: koyuMu ? const Color(0xFFEAB308).withOpacity(0.5) : cAccent.withOpacity(0.4)),
                                ),
                                child: Text(
                                  dil('85/100 Puan', '85/100 Pts'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: koyuMu ? const Color(0xFFFDE047) : const Color(0xFF857B0D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            dil('KKTC Ehliyet: 123456', 'TRNC License: 123456'),
                            style: TextStyle(
                              fontSize: 12,
                              color: subColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: koyuMu ? const Color(0xFF1E293B) : cSoftSurface,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  dil('Sınıf A2, B, D', 'Class A2, B, D'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: koyuMu ? const Color(0xFFCBD5E1) : const Color(0xFF374151),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text('•', style: TextStyle(color: subColor, fontSize: 11)),
                              const SizedBox(width: 6),
                              Text(
                                dil('Geçerli Sürücü', 'Valid Driver'),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF10B981),
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
                  color: koyuMu ? const Color(0xFF1E293B) : cSoftSurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: koyuMu ? const Color(0xFF64748B) : const Color(0xFF9CA3AF),
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
    final bool koyuMu = KktcTemaServisi().isKoyu(context);
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
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: koyuMu ? const Color(0xFF94A3B8) : cMuted,
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
    final bool koyuMu = KktcTemaServisi().isKoyu(context);
    final Color itemCardBg = koyuMu ? const Color(0xFF151D30) : Colors.white;
    final Color itemCardBorder = koyuMu
        ? (gradientBackground != null ? iconColor.withOpacity(0.35) : const Color(0xFF243048))
        : (borderColor ?? Colors.grey.shade100);
    final Color itemTitleColor = koyuMu ? Colors.white : cNavy;
    // Koyu modda renkli alt yazıları biraz açarak kontrastı artır
    final Color itemSubtitleColor = subtitleColor != null
        ? (koyuMu ? Color.lerp(subtitleColor, Colors.white, 0.3)! : subtitleColor)
        : (koyuMu ? const Color(0xFF94A3B8) : cSlate);
    // Açık renkli gradyanlar koyu modda ikon renginden türeyen koyu gradyana dönüşür
    final Gradient? itemGradient = gradientBackground == null
        ? null
        : (koyuMu
            ? LinearGradient(
                colors: [iconColor.withOpacity(0.22), itemCardBg],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : gradientBackground);
    final Color itemChevronBg = koyuMu ? const Color(0xFF1E293B) : Colors.grey.shade50;
    final Color itemChevronIcon = koyuMu ? const Color(0xFF64748B) : const Color(0xFF9CA3AF);
    final Color itemIconBg = koyuMu ? iconColor.withOpacity(0.18) : iconBgColor;

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
            color: itemGradient == null ? itemCardBg : null,
            gradient: itemGradient,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: itemCardBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(koyuMu ? 0.2 : 0.025),
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
                        color: itemIconBg,
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
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: itemTitleColor,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: itemSubtitleColor,
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
                        color: trailingBadgeBg ?? (koyuMu ? const Color(0xFF881337).withOpacity(0.5) : const Color(0xFFFFE4E6)),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        trailingBadgeText,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: trailingBadgeTextColor ?? (koyuMu ? const Color(0xFFFDA4AF) : const Color(0xFFBE123C)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: itemChevronBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: itemChevronIcon,
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
    final bool koyuMu = KktcTemaServisi().isKoyu(context);
    final Color cardBg = koyuMu ? const Color(0xFF151D30) : Colors.white;
    final Color cardBorder = koyuMu ? const Color(0xFF243048) : Colors.grey.shade200;
    final Color titleColor = koyuMu ? Colors.white : cNavy;
    final Color iconColor = koyuMu ? const Color(0xFF94A3B8) : cSlate;

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
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(koyuMu ? 0.2 : 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.settings_outlined, size: 19, color: iconColor),
                    const SizedBox(width: 8),
                    Text(
                      dil('Ayarlar', 'Settings'),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: titleColor,
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
                  color: widget.girisYapildiMi
                      ? (koyuMu ? const Color(0xFF4C0519).withOpacity(0.5) : cSoftRed)
                      : (koyuMu ? const Color(0xFF2563EB) : cNavy),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: widget.girisYapildiMi
                        ? (koyuMu ? const Color(0xFF881337) : const Color(0xFFFECDD3))
                        : Colors.transparent,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.girisYapildiMi
                          ? cDanger.withOpacity(0.04)
                          : (koyuMu ? const Color(0xFF2563EB).withOpacity(0.2) : cNavy.withOpacity(0.18)),
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
                      color: widget.girisYapildiMi
                          ? (koyuMu ? const Color(0xFFFDA4AF) : cDanger)
                          : const Color(0xFFD1C929),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.girisYapildiMi ? dil('Çıkış Yap', 'Sign Out') : dil('Giriş Yap', 'Sign In'),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: widget.girisYapildiMi
                            ? (koyuMu ? const Color(0xFFFDA4AF) : cDanger)
                            : Colors.white,
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
