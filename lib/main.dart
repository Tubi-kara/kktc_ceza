import 'package:flutter/material.dart';

void main() {
  runApp(const KktcCezaApp());
}

class KktcCezaApp extends StatefulWidget {
  const KktcCezaApp({super.key});

  @override
  State<KktcCezaApp> createState() => _KktcCezaAppState();
}

class _KktcCezaAppState extends State<KktcCezaApp> {
  // true = Türkçe, false = İngilizce
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC8102E)),
        useMaterial3: true,
        fontFamily: 'Roboto',
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

// --- 1. GİRİŞ EKRANI ---
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

  void _girisYap() {
    String numara = _girisController.text.trim();
    String sifre = _sifreController.text.trim();

    if (numara.isEmpty || sifre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.turkceMi ? 'Lütfen alanları boş bırakmayın!' : 'Please fill in all fields!')),
      );
      return;
    }

    List<String> tanimliAraclar = [];
    String adSoyad = "";

    if (!_kktcVatandasiMi) {
      if (numara == "tubi" && sifre == "tugkan3517") {
        adSoyad = widget.turkceMi ? "Tubi (Öğrenci)" : "Tubi (Student)";
        tanimliAraclar = ["ST 999", "GM 202"];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.turkceMi ? 'Hatalı öğrenci adı veya şifre! (tubi / tugkan3517)' : 'Invalid student username or password!')),
        );
        return;
      }
    } else {
      adSoyad = widget.turkceMi ? "Ahmet Demir" : "Ahmet Demir (Citizen)";
      tanimliAraclar = ["RZ 123", "LZ 555"];
    }

    widget.onGirisBasarili(adSoyad, tanimliAraclar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFC8102E), Color(0xFF800A1A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => widget.onDilDegistir(true),
                      child: Text('🇹🇷 Türkçe', style: TextStyle(color: widget.turkceMi ? Colors.white : Colors.white70, fontWeight: widget.turkceMi ? FontWeight.bold : FontWeight.normal)),
                    ),
                    TextButton(
                      onPressed: () => widget.onDilDegistir(false),
                      child: Text('🇬🇧 English', style: TextStyle(color: !widget.turkceMi ? Colors.white : Colors.white70, fontWeight: !widget.turkceMi ? FontWeight.bold : FontWeight.normal)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
                              child: const Icon(Icons.shield_rounded, size: 48, color: Color(0xFFC8102E)),
                            ),
                            const SizedBox(height: 16),
                            Text(widget.turkceMi ? 'KKTC e-Trafik' : 'TRNC e-Traffic', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(widget.turkceMi ? 'Kamu Dijital Hizmet Portalı' : 'Public Digital Services Portal', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                            const SizedBox(height: 24),
                            Container(
                              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _kktcVatandasiMi = true),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: _kktcVatandasiMi ? const Color(0xFFC8102E) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(widget.turkceMi ? 'KKTC Kimlik' : 'TRNC ID', style: TextStyle(fontWeight: FontWeight.bold, color: _kktcVatandasiMi ? Colors.white : Colors.black54)),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _kktcVatandasiMi = false),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: !_kktcVatandasiMi ? const Color(0xFFC8102E) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(widget.turkceMi ? 'Öğrenci (Tubi)' : 'Student (Tubi)', style: TextStyle(fontWeight: FontWeight.bold, color: !_kktcVatandasiMi ? Colors.white : Colors.black54)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _girisController,
                              decoration: InputDecoration(
                                labelText: _kktcVatandasiMi ? (widget.turkceMi ? 'KKTC Kimlik Numarası' : 'TRNC ID Number') : (widget.turkceMi ? 'Öğrenci Kullanıcı Adı (tubi)' : 'Student Username (tubi)'),
                                prefixIcon: Icon(_kktcVatandasiMi ? Icons.person : Icons.school, color: const Color(0xFFC8102E)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _sifreController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: _kktcVatandasiMi ? (widget.turkceMi ? 'Şifre' : 'Password') : (widget.turkceMi ? 'Öğrenci Şifresi (tugkan3517)' : 'Student Password (tugkan3517)'),
                                prefixIcon: const Icon(Icons.lock, color: Color(0xFFC8102E)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFC8102E),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: _girisYap,
                                child: Text(widget.turkceMi ? 'Güvenli Giriş Yap' : 'Secure Login', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Geliştiren: Tuğberk Kara',
                              style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500),
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
        ),
      ),
    );
  }
}

// --- 2. ANA SAYFA TABS ---
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
          "kanit": "https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=500"
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
          "polis": "Trafik Ekipleri",
          "kanit": "https://images.unsplash.com/photo-1486006920555-c77dce18193b?w=500"
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

  String _secilenPlaka = "";

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
      _dekontlar.add({
        "islem": "$plaka Nolu Araç Zorunlu Sigorta Yenileme",
        "islemEn": "$plaka Vehicle Mandatory Insurance Renewal",
        "tarih": "Bugün / Today",
        "tutar": "4500 TL",
        "kod": "SIGORTA-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
        "kurum": "KKTC Sigortalar Birliği",
        "durum": "Onaylandı / Poliçe Aktif"
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.turkceMi ? 'Sigorta poliçesi başarıyla yenilendi!' : 'Insurance policy successfully renewed!')),
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
      _dekontlar.add({
        "islem": cezaAdi,
        "islemEn": cezaAdiEn,
        "tarih": "Bugün / Today",
        "tutar": tutar,
        "kod": "DEKONT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
        "kurum": "KKTC Polis Genel Müdürlüğü Trafik Müdürlüğü",
        "durum": "Ödendi / Kapandı"
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

    final List<Widget> sayfalar = [
      // 1. ANA SAYFA
      SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFC8102E), Color(0xFF900A1D)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  const CircleAvatar(radius: 28, backgroundColor: Colors.white, child: Icon(Icons.person, color: Color(0xFFC8102E), size: 32)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.kullaniciAdi, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(widget.turkceMi ? 'Ehliyet Sağlık Puanı: $ehliyetPuani / 100' : 'Driver Health Score: $ehliyetPuani / 100', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(widget.turkceMi ? 'Araçlarım' : 'My Vehicles', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 10),
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.araclar.length,
                itemBuilder: (context, index) {
                  String plaka = widget.araclar[index];
                  bool seciliMi = (_secilenPlaka == plaka);
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(plaka),
                      selected: seciliMi,
                      selectedColor: const Color(0xFFC8102E),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(fontWeight: FontWeight.bold, color: seciliMi ? Colors.white : Colors.black87),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      onSelected: (selected) {
                        setState(() {
                          _secilenPlaka = plaka;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 6)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.directions_car_filled, color: Color(0xFFC8102E), size: 28),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(markaModel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('${widget.turkceMi ? 'Plaka' : 'Plate'}: $_secilenPlaka', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _durumGosterge(widget.turkceMi ? 'Sigorta' : 'Insurance', '$sigortaGun ${widget.turkceMi ? 'Gün' : 'Days'}', sigortaGun < 20 ? Colors.orange : Colors.green, Icons.security),
                      Container(height: 30, width: 1, color: Colors.grey.shade200),
                      _durumGosterge(widget.turkceMi ? 'Muayene' : 'Inspection', '$muayeneGun ${widget.turkceMi ? 'Gün' : 'Days'}', muayeneGun < 20 ? Colors.red : Colors.green, Icons.car_repair),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.turkceMi ? 'Son Cezalar ve İhlaller' : 'Recent Fines & Violations', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                TextButton(
                  onPressed: () => setState(() => _seciliIndex = 1),
                  child: Text(widget.turkceMi ? 'Tümünü Gör' : 'View All', style: const TextStyle(color: Color(0xFFC8102E))),
                ),
              ],
            ),
            const SizedBox(height: 8),
            cezalar.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12)),
                    child: Text(widget.turkceMi ? 'Seçili araçta aktif ceza bulunmuyor. 🎉' : 'No active fines for selected vehicle. 🎉', style: const TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cezalar.length > 2 ? 2 : cezalar.length,
                    itemBuilder: (context, index) {
                      final ceza = cezalar[index];
                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          dense: true,
                          leading: Icon(ceza['odendi'] ? Icons.check_circle : Icons.warning_rounded, color: ceza['odendi'] ? Colors.green : Colors.red, size: 24),
                          title: Text(widget.turkceMi ? ceza['tur'] : ceza['turEn'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text('${widget.turkceMi ? 'Tarih' : 'Date'}: ${ceza['tarih']} | ${ceza['tutar']}', style: const TextStyle(fontSize: 11)),
                          trailing: Text(ceza['odendi'] ? (widget.turkceMi ? 'Ödendi' : 'Paid') : (widget.turkceMi ? 'Ödenmedi' : 'Unpaid'), style: TextStyle(color: ceza['odendi'] ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
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
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 4.0, bottom: 8.0),
                child: Text(
                  'Geliştiren: Tuğberk Kara',
                  style: TextStyle(fontSize: 11, color: Colors.black54, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),

      // 2. CEZALARIM
      ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cezalar.isEmpty ? 1 : cezalar.length,
        itemBuilder: (context, index) {
          if (cezalar.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(40),
              alignment: Alignment.center,
              child: Text(widget.turkceMi ? 'Seçili araçta aktif ceza bulunmuyor. 🎉' : 'No active fines for selected vehicle. 🎉', style: const TextStyle(fontSize: 15, color: Colors.green, fontWeight: FontWeight.bold)),
            );
          }
          final ceza = cezalar[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(ceza['odendi'] ? Icons.check_circle : Icons.warning_rounded, color: ceza['odendi'] ? Colors.green : Colors.red, size: 32),
              title: Text(widget.turkceMi ? ceza['tur'] : ceza['turEn'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${widget.turkceMi ? 'Tarih' : 'Date'}: ${ceza['tarih']} | ${ceza['tutar']}'),
              trailing: Text(ceza['odendi'] ? (widget.turkceMi ? 'Ödendi' : 'Paid') : (widget.turkceMi ? 'Ödenmedi' : 'Unpaid'), style: TextStyle(color: ceza['odendi'] ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
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
            ),
          );
        },
      ),

      // 3. SİGORTA YÖNETİMİ
      SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.turkceMi ? 'Zorunlu Trafik Sigortası Yönetimi' : 'Mandatory Traffic Insurance Management', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(widget.turkceMi ? 'Aracınızın sigorta poliçesini buradan takip edebilir veya anında yenileyebilirsiniz.' : 'Track or instantly renew your vehicle insurance policy here.', style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 20),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$_secilenPlaka - $markaModel', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: sigortaGun < 20 ? Colors.orange[100] : Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            sigortaGun < 20 ? (widget.turkceMi ? 'Süresi Azaldı' : 'Expiring Soon') : (widget.turkceMi ? 'Aktif Poliçe' : 'Active Policy'),
                            style: TextStyle(color: sigortaGun < 20 ? Colors.orange[800] : Colors.green[800], fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text('${widget.turkceMi ? 'Kalan Süre' : 'Remaining Time'}: $sigortaGun ${widget.turkceMi ? 'Gün' : 'Days'}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: sigortaGun < 20 ? Colors.orange : Colors.black87)),
                    const SizedBox(height: 8),
                    Text(widget.turkceMi ? 'Teminat: 3. Şahıs Maddi / Bedeni Hasarlar' : 'Coverage: 3rd Party Material / Bodily Damages', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC8102E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _sigortaYenile(_secilenPlaka),
                        child: Text(widget.turkceMi ? 'Hemen Sigortayı Yenile / Satın Al (4500 TL)' : 'Renew Insurance / Buy Now (4500 TL)', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 4. PROFİL & BELGELER
      ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFFC8102E)),
            title: Text(widget.kullaniciAdi, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(widget.turkceMi ? 'KKTC Vatandaşı / Kayıtlı Sürücü' : 'TRNC Citizen / Registered Driver'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.qr_code, color: Colors.blue),
            title: Text(widget.turkceMi ? 'Barkodlu Sürücü Belgesi' : 'Barcoded Driver Certificate'),
            subtitle: Text(widget.turkceMi ? 'Resmi barkodlu ceza ve puan özeti (Çalışır QR)' : 'Official barcoded summary (Interactive QR)'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BarkodluBelgeSayfasi(kullanici: widget.kullaniciAdi, puan: ehliyetPuani, turkceMi: widget.turkceMi))),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long, color: Colors.green),
            title: Text(widget.turkceMi ? 'Ödeme Dekontları' : 'Payment Receipts'),
            subtitle: Text(widget.turkceMi ? 'Tıklanabilir resmi dekont makbuzları' : 'Clickable official payment receipts'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DekontlarSayfasi(dekontlar: _dekontlar, turkceMi: widget.turkceMi))),
          ),
          ListTile(
            leading: const Icon(Icons.gavel, color: Colors.orange),
            title: Text(widget.turkceMi ? 'Cezaya İtiraz Başvurusu' : 'Fine Objection Application'),
            subtitle: Text(widget.turkceMi ? 'Yanlış kesilen cezalar için dilekçe' : 'Petition for incorrectly issued fines'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ItirazSayfasi(turkceMi: widget.turkceMi))),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active, color: Colors.purple),
            title: Text(widget.turkceMi ? 'Bildirim Ayarları' : 'Notification Settings'),
            subtitle: Text(widget.turkceMi ? 'Sigorta ve muayene hatırlatıcıları' : 'Insurance and inspection reminders'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BildirimAyarlariSayfasi(turkceMi: widget.turkceMi))),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(widget.turkceMi ? 'Oturumu Kapat / Çıkış Yap' : 'Log Out / Sign Out', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: widget.onCikisYap,
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Geliştiren: Tuğberk Kara',
              style: TextStyle(fontSize: 11, color: Colors.black54, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(_baslikDondur(_seciliIndex), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFC8102E),
        elevation: 0,
        actions: [
          PopupMenuButton<bool>(
            icon: const Icon(Icons.language, color: Colors.white),
            onSelected: (bool yeniTurkceMi) {
              widget.onDilDegistir(yeniTurkceMi);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<bool>>[
              const PopupMenuItem<bool>(value: true, child: Text('🇹🇷 Türkçe')),
              const PopupMenuItem<bool>(value: false, child: Text('🇬🇧 English')),
            ],
          ),
        ],
      ),
      body: sayfalar[_seciliIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _seciliIndex,
        selectedItemColor: const Color(0xFFC8102E),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _seciliIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: widget.turkceMi ? 'Ana Sayfa' : 'Home'),
          BottomNavigationBarItem(icon: const Icon(Icons.warning), label: widget.turkceMi ? 'Cezalarım' : 'Fines'),
          BottomNavigationBarItem(icon: const Icon(Icons.security), label: widget.turkceMi ? 'Sigorta' : 'Insurance'),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: widget.turkceMi ? 'Profil' : 'Profile'),
        ],
      ),
    );
  }

  String _baslikDondur(int index) {
    if (widget.turkceMi) {
      switch (index) {
        case 0: return 'e-Trafik Ana Sayfa';
        case 1: return 'Trafik Cezalarım';
        case 2: return 'Sigorta ve Poliçeler';
        case 3: return 'Sürücü Profilim & Belgeler';
        default: return 'e-Trafik';
      }
    } else {
      switch (index) {
        case 0: return 'e-Traffic Home';
        case 1: return 'My Traffic Fines';
        case 2: return 'Insurance & Policies';
        case 3: return 'Driver Profile & Docs';
        default: return 'e-Traffic';
      }
    }
  }

  Widget _durumGosterge(String baslik, String deger, Color renk, IconData ikon) {
    return Row(
      children: [
        Icon(ikon, color: renk, size: 24),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(deger, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: renk)),
          ],
        ),
      ],
    );
  }
}

// --- 3. CEZA DETAY SAYFASI ---
class CezaDetaySayfasi extends StatelessWidget {
  final Map<String, dynamic> ceza;
  final bool turkceMi;
  final VoidCallback onOdemeYap;

  const CezaDetaySayfasi({super.key, required this.ceza, required this.turkceMi, required this.onOdemeYap});

  @override
  Widget build(BuildContext context) {
    bool odendiMi = ceza['odendi'];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(turkceMi ? 'Ceza ve Kanıt Detayı' : 'Fine & Evidence Detail', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFC8102E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                ceza['kanit'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Center(child: Text(turkceMi ? 'Görsel Yüklenemedi' : 'Image Not Loaded')),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(turkceMi ? ceza['tur'] : ceza['turEn'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFC8102E))),
                    const Divider(height: 24),
                    _detaySatiri(turkceMi ? 'Tarih' : 'Date', ceza['tarih']),
                    _detaySatiri(turkceMi ? 'Konum' : 'Location', ceza['konum']),
                    _detaySatiri(turkceMi ? 'Ceza Puanı' : 'Penalty Points', ceza['puan']),
                    _detaySatiri(turkceMi ? 'İlgili Birim' : 'Authorized Unit', ceza['polis']),
                    _detaySatiri(turkceMi ? 'Kategori' : 'Category', ceza['kategori']),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(turkceMi ? 'Toplam Tutar' : 'Total Amount', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(ceza['tutar'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFC8102E))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: odendiMi ? Colors.green : const Color(0xFFC8102E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: odendiMi
                    ? null
                    : () {
                        onOdemeYap();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(turkceMi ? 'Ödeme başarıyla simüle edildi ve dekontlara eklendi!' : 'Payment simulated successfully and added to receipts!')),
                        );
                        Navigator.pop(context);
                      },
                child: Text(
                  odendiMi ? (turkceMi ? 'Bu Ceza Ödenmiş' : 'This Fine is Paid') : (turkceMi ? 'Hemen Ödeme Yap (Simülasyon)' : 'Pay Now (Simulation)'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(deger, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }
}

// --- 4. BARKODLU SÜRÜCÜ BELGESİ VE ÇALIŞIR QR SAYFASI ---
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
            title: Text(widget.turkceMi ? 'QR Doğrulama Başarılı ✅' : 'QR Verification Successful ✅'),
            content: Text(widget.turkceMi 
                ? 'Bu belge KKTC Polis Genel Müdürlüğü bilgi sistemlerinde resmi olarak onaylanmıştır. Puan ve ceza kaydı temizdir.'
                : 'This document has been officially approved in the TRNC Police Headquarters information systems.',
                style: const TextStyle(fontSize: 13)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(widget.turkceMi ? 'Tamam' : 'OK'),
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
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(widget.turkceMi ? 'Resmi Barkodlu Belge' : 'Official Barcoded Certificate', style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFC8102E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.verified, color: Colors.blue, size: 52),
                  const SizedBox(height: 10),
                  const Text('KUZEY KIBRIS TÜRK CUMHURİYETİ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey), textAlign: TextAlign.center),
                  Text(widget.turkceMi ? 'Polis Genel Müdürlüğü - Sürücü Belge Özeti' : 'Police Headquarters - Driver License Summary', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), textAlign: TextAlign.center),
                  const Divider(height: 30),
                  Align(alignment: Alignment.centerLeft, child: Text('${widget.turkceMi ? 'Ad Soyad' : 'Full Name'}: ${widget.kullanici}', style: const TextStyle(fontSize: 15))),
                  const SizedBox(height: 8),
                  Align(alignment: Alignment.centerLeft, child: Text('${widget.turkceMi ? 'Ehliyet Sağlık Puanı' : 'Driver Health Score'}: ${widget.puan} / 100', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 24),
                  
                  // ÇALIŞIR / DOKUNULABİLİR QR KOD ALANI
                  GestureDetector(
                    onTap: _qriDogrula,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Column(
                        children: [
                          _qrTaraniyor 
                              ? const SizedBox(height: 100, width: 100, child: Center(child: CircularProgressIndicator(color: Color(0xFFC8102E))))
                              : const Icon(Icons.qr_code_2, size: 100, color: Colors.black87),
                          const SizedBox(height: 8),
                          Text(
                            widget.turkceMi ? '(Doğrulamak için QR Koda Dokun)' : '(Tap QR Code to Verify)',
                            style: TextStyle(fontSize: 11, color: Colors.blue[700], fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Barkod No: KKTC-TR-2026-99182', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- 5. GERÇEKÇİ ÖDEME DEKONTU SAYFASI ---
class DekontlarSayfasi extends StatelessWidget {
  final List<Map<String, String>> dekontlar;
  final bool turkceMi;

  const DekontlarSayfasi({super.key, required this.dekontlar, required this.turkceMi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(turkceMi ? 'Ödeme Dekontları' : 'Payment Receipts', style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFC8102E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dekontlar.length,
        itemBuilder: (context, index) {
          var dekont = dekontlar[index];
          String islemAdi = turkceMi ? dekont['islem']! : (dekont['islemEn'] ?? dekont['islem']!);
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.receipt_long, color: Color(0xFFC8102E), size: 32),
              title: Text(islemAdi, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${turkceMi ? 'Tarih' : 'Date'}: ${dekont['tarih']} | ${dekont['kod']}'),
              trailing: Text(dekont['tutar']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 15)),
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
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(turkceMi ? 'Resmi Ödeme Dekontu' : 'Official Payment Receipt', style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFC8102E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.account_balance, color: Color(0xFFC8102E), size: 36),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(8)),
                        child: Text(turkceMi ? 'ONAYLANDI' : 'APPROVED', style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('KUZEY KIBRIS TÜRK CUMHURİYETİ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                  Text(turkceMi ? 'Kamu Maliye Elektronik Tahsilat Makbuzu' : 'Public Finance Electronic Collection Receipt', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const Divider(height: 30),
                  _dekontSatiri(turkceMi ? 'İşlem Türü' : 'Transaction Type', islemAdi),
                  _dekontSatiri(turkceMi ? 'İşlem Kodu' : 'Transaction Code', dekont['kod']!),
                  _dekontSatiri(turkceMi ? 'İşlem Tarihi' : 'Transaction Date', dekont['tarih']!),
                  _dekontSatiri(turkceMi ? 'İlgili Kurum' : 'Authorized Institution', dekont['kurum'] ?? 'KKTC Maliye Bakanlığı'),
                  _dekontSatiri(turkceMi ? 'İşlem Durumu' : 'Status', dekont['durum'] ?? 'Başarılı'),
                  const Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(turkceMi ? 'Ödenen Tutar' : 'Paid Amount', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(dekont['tutar']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFC8102E))),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.qr_code, size: 70, color: Colors.black87),
                        const SizedBox(height: 4),
                        Text(turkceMi ? 'Elektronik Doğrulama Barkodu' : 'Electronic Verification Barcode', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
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
          Text(baslik, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(deger, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.right),
        ],
      ),
    );
  }
}

class ItirazSayfasi extends StatelessWidget {
  final bool turkceMi;
  const ItirazSayfasi({super.key, required this.turkceMi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(turkceMi ? 'Cezaya İtiraz Et' : 'Object to Fine', style: const TextStyle(color: Colors.white)), backgroundColor: const Color(0xFFC8102E), iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              maxLines: 5,
              decoration: InputDecoration(labelText: turkceMi ? 'İtiraz Gerekçeniz' : 'Your Objection Reason', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC8102E), foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(turkceMi ? 'İtirazınız iletildi!' : 'Objection submitted!')));
              },
              child: Text(turkceMi ? 'Gönder' : 'Submit'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.turkceMi ? 'Bildirim Tercihleri' : 'Notification Preferences', style: const TextStyle(color: Colors.white)), backgroundColor: const Color(0xFFC8102E), iconTheme: const IconThemeData(color: Colors.white)),
      body: ListView(
        children: [
          SwitchListTile(title: Text(widget.turkceMi ? 'Sigorta Hatırlatıcısı' : 'Insurance Reminder'), value: sigorta, onChanged: (v) => setState(() => sigorta = v)),
          SwitchListTile(title: Text(widget.turkceMi ? 'Muayene Hatırlatıcısı' : 'Inspection Reminder'), value: muayene, onChanged: (v) => setState(() => muayene = v)),
        ],
      ),
    );
  }
}