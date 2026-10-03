import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'canli_gps_servisi.dart';
import 'yol_tarifi_sayfasi.dart' show RotaNoktasi;

// ==========================================
// 🏠 KKTC FAVORİ NOKTALAR SERVİSİ (EV & İŞ)
// ==========================================

class KktcFavoriNoktalarServisi extends ChangeNotifier {
  static final KktcFavoriNoktalarServisi _instance = KktcFavoriNoktalarServisi._internal();
  factory KktcFavoriNoktalarServisi() => _instance;
  KktcFavoriNoktalarServisi._internal();

  // Varsayılan Evim & İşim Değerleri
  String _evimAdres = 'Gönyeli / Lefkoşa';
  double _evimLat = 35.2130;
  double _evimLon = 33.3120;
  bool _evimAyarlandiMi = false;

  String _isimAdres = 'Dereboyu / Lefkoşa';
  double _isimLat = 35.1915;
  double _isimLon = 33.3480;
  bool _isimAyarlandiMi = false;

  bool _yuklendi = false;

  // Getters
  String get evimAdres => _evimAdres;
  double get evimLat => _evimLat;
  double get evimLon => _evimLon;
  bool get evimAyarlandiMi => _evimAyarlandiMi;

  String get isimAdres => _isimAdres;
  double get isimLat => _isimLat;
  double get isimLon => _isimLon;
  bool get isimAyarlandiMi => _isimAyarlandiMi;

  RotaNoktasi get evimRotaNoktasi => RotaNoktasi(
        id: 'fav_evim',
        ad: 'Evim ($_evimAdres)',
        adEn: 'Home ($_evimAdres)',
        kisaAd: 'Evim',
        bolge: 'Lefkoşa',
        lat: _evimLat,
        lon: _evimLon,
        ikon: Icons.home_rounded,
        kategori: 'favori',
      );

  RotaNoktasi get isimRotaNoktasi => RotaNoktasi(
        id: 'fav_isim',
        ad: 'İşim ($_isimAdres)',
        adEn: 'Work ($_isimAdres)',
        kisaAd: 'İşim',
        bolge: 'Lefkoşa',
        lat: _isimLat,
        lon: _isimLon,
        ikon: Icons.work_rounded,
        kategori: 'favori',
      );

  Future<void> baslat() async {
    if (_yuklendi) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/kktc_favori_adresler.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final Map<String, dynamic> data = jsonDecode(content);
        if (data.containsKey('evimAdres')) {
          _evimAdres = data['evimAdres'] ?? _evimAdres;
          _evimLat = (data['evimLat'] as num?)?.toDouble() ?? _evimLat;
          _evimLon = (data['evimLon'] as num?)?.toDouble() ?? _evimLon;
          _evimAyarlandiMi = data['evimAyarlandiMi'] ?? true;
        }
        if (data.containsKey('isimAdres')) {
          _isimAdres = data['isimAdres'] ?? _isimAdres;
          _isimLat = (data['isimLat'] as num?)?.toDouble() ?? _isimLat;
          _isimLon = (data['isimLon'] as num?)?.toDouble() ?? _isimLon;
          _isimAyarlandiMi = data['isimAyarlandiMi'] ?? true;
        }
      }
    } catch (_) {}
    _yuklendi = true;
    notifyListeners();
  }

  Future<void> kaydetEvim({
    required String adres,
    required double lat,
    required double lon,
  }) async {
    _evimAdres = adres;
    _evimLat = lat;
    _evimLon = lon;
    _evimAyarlandiMi = true;
    notifyListeners();
    await _dosyayaKaydet();
  }

  Future<void> kaydetIsim({
    required String adres,
    required double lat,
    required double lon,
  }) async {
    _isimAdres = adres;
    _isimLat = lat;
    _isimLon = lon;
    _isimAyarlandiMi = true;
    notifyListeners();
    await _dosyayaKaydet();
  }

  Future<void> _dosyayaKaydet() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/kktc_favori_adresler.json');
      final data = {
        'evimAdres': _evimAdres,
        'evimLat': _evimLat,
        'evimLon': _evimLon,
        'evimAyarlandiMi': _evimAyarlandiMi,
        'isimAdres': _isimAdres,
        'isimLat': _isimLat,
        'isimLon': _isimLon,
        'isimAyarlandiMi': _isimAyarlandiMi,
      };
      await file.writeAsString(jsonEncode(data));
    } catch (_) {}
  }
}

// ==========================================
// ✏️ EV & İŞ ADRESİNİ BELİRLEME DİYALOĞU
// ==========================================
Future<void> showEvIsDuzenleModal({
  required BuildContext context,
  required bool isEv,
  required VoidCallback onKaydedildi,
}) async {
  final servis = KktcFavoriNoktalarServisi();
  final TextEditingController adresCtrl = TextEditingController(
    text: isEv ? servis.evimAdres : servis.isimAdres,
  );
  double seciliLat = isEv ? servis.evimLat : servis.isimLat;
  double seciliLon = isEv ? servis.evimLon : servis.isimLon;
  bool gpsYukleniyor = false;

  final List<Map<String, dynamic>> bolgeOnerileri = isEv
      ? [
          {'ad': 'Gönyeli / Lefkoşa', 'lat': 35.2130, 'lon': 33.3120},
          {'ad': 'Ortaköy / Lefkoşa', 'lat': 35.2010, 'lon': 33.3390},
          {'ad': 'Küçük Kaymaklı / Lefkoşa', 'lat': 35.1910, 'lon': 33.3750},
          {'ad': 'Taşkınköy / Lefkoşa', 'lat': 35.2090, 'lon': 33.3540},
          {'ad': 'Kumsal / Lefkoşa', 'lat': 35.1870, 'lon': 33.3510},
          {'ad': 'Alsancak / Girne', 'lat': 35.3420, 'lon': 33.2450},
          {'ad': 'Girne Merkez', 'lat': 35.3360, 'lon': 33.3220},
          {'ad': 'Çatalköy / Girne', 'lat': 35.3210, 'lon': 33.3850},
          {'ad': 'Karakol / Gazimağusa', 'lat': 35.1410, 'lon': 33.9180},
          {'ad': 'Güzelyurt Merkez', 'lat': 35.1980, 'lon': 32.9930},
        ]
      : [
          {'ad': 'Dereboyu Caddesi / Lefkoşa', 'lat': 35.1915, 'lon': 33.3480},
          {'ad': 'Organize Sanayi Bölgesi / Lefkoşa', 'lat': 35.2180, 'lon': 33.3620},
          {'ad': 'Bakanlıklar & Meclis / Lefkoşa', 'lat': 35.1840, 'lon': 33.3590},
          {'ad': 'Girne Turizm Limanı & Çarşı', 'lat': 35.3410, 'lon': 33.3220},
          {'ad': 'Salamis Yolu Ticari / Gazimağusa', 'lat': 35.1380, 'lon': 33.9180},
          {'ad': 'Yeni Ercan Havalimanı', 'lat': 35.1585, 'lon': 33.4980},
          {'ad': 'DAÜ Kampüsü / Gazimağusa', 'lat': 35.1440, 'lon': 33.9050},
          {'ad': 'YDÜ Kampüsü / Lefkoşa', 'lat': 35.2260, 'lon': 33.3280},
        ];

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalCtx) => StatefulBuilder(
      builder: (ctx, setSheetState) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        final Color anaRenk = isEv ? const Color(0xFF10B981) : const Color(0xFF2563EB);

        return Container(
          padding: EdgeInsets.only(
            bottom: bottomInset + 16,
            left: 18,
            right: 18,
            top: 12,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tutamaç
                Center(
                  child: Container(
                    width: 38,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Başlık
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: anaRenk.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isEv ? Icons.home_rounded : Icons.work_rounded,
                        color: anaRenk,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEv ? 'Ev Adresinizi Belirleyin' : 'İş Adresinizi Belirleyin',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Tek dokunuşla rota başlatmak için kayıtlı adresiniz:',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(modalCtx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 🛰️ CANLI GPS İLE ŞU ANKİ NOKTAYI AYARLA BUTONU
                InkWell(
                  onTap: () async {
                    HapticFeedback.heavyImpact();
                    setSheetState(() => gpsYukleniyor = true);
                    try {
                      Position? pos = CanliGpsServisi().sonKonum;
                      if (pos == null) {
                        pos = await Geolocator.getCurrentPosition(
                          desiredAccuracy: LocationAccuracy.high,
                          timeLimit: const Duration(seconds: 4),
                        );
                      }
                      if (pos != null) {
                        seciliLat = pos.latitude;
                        seciliLon = pos.longitude;
                        adresCtrl.text = isEv
                            ? 'Evim (Canlı GPS: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})'
                            : 'İşim (Canlı GPS: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})';
                      }
                    } catch (_) {}
                    setSheetState(() => gpsYukleniyor = false);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [anaRenk.withOpacity(0.12), anaRenk.withOpacity(0.06)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: anaRenk.withOpacity(0.4), width: 1.2),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.my_location_rounded, color: anaRenk, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEv ? '📡 Şu Anki Konumumu Evim Yap' : '📡 Şu Anki Konumumu İşim Yap',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: anaRenk,
                                ),
                              ),
                              Text(
                                'Bulunduğunuz noktanın GPS koordinatlarını kaydeder',
                                style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        if (gpsYukleniyor)
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: anaRenk),
                          )
                        else
                          Icon(Icons.arrow_forward_ios_rounded, size: 13, color: anaRenk),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Özel Adres Yaz
                const Text(
                  'Adres veya Bölge Adı',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: TextField(
                    controller: adresCtrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: isEv ? 'Örn: Gönyeli, Belediye Yanı' : 'Örn: Dereboyu Caddesi No:42',
                      hintStyle: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      prefixIcon: Icon(
                        isEv ? Icons.home_work_rounded : Icons.apartment_rounded,
                        color: Colors.blueGrey,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Hızlı Bölge Seçenekleri
                const Text(
                  'Hızlı Önerilerden Seçin:',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: bolgeOnerileri.map((b) {
                    final bool isCur = adresCtrl.text == b['ad'];
                    return InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setSheetState(() {
                          adresCtrl.text = b['ad'] as String;
                          seciliLat = b['lat'] as double;
                          seciliLon = b['lon'] as double;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isCur ? anaRenk : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCur ? anaRenk : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Text(
                          b['ad'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isCur ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 18),

                // Kaydet Butonu
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: anaRenk,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    onPressed: () async {
                      final val = adresCtrl.text.trim();
                      if (val.isEmpty) return;
                      HapticFeedback.heavyImpact();

                      if (isEv) {
                        await servis.kaydetEvim(
                          adres: val,
                          lat: seciliLat,
                          lon: seciliLon,
                        );
                      } else {
                        await servis.kaydetIsim(
                          adres: val,
                          lat: seciliLat,
                          lon: seciliLon,
                        );
                      }
                      Navigator.pop(modalCtx);
                      onKaydedildi();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEv ? '🏠 Ev adresiniz güncellendi: $val' : '🏢 İş adresiniz güncellendi: $val',
                          ),
                          backgroundColor: anaRenk,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Text(
                      isEv ? 'Ev Adresini Kaydet' : 'İş Adresini Kaydet',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
