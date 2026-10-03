import 'package:flutter/material.dart';

// ============================================================================
// 🚦 KKTC YOL FORUMU VERİ VE BİLDİRİM MODELLERİ
// Topluluk destekli anlık trafik olayları: Çevirme, Kaza, Yol Çalışması
// ============================================================================

enum YolForumTipi {
  cevirme, // 🚓 Polis Çevirmesi / Mobil Radar
  kaza,    // 💥 Trafik Kazası / Yol Tıkanıklığı
  calisma, // 🚧 Yol Yapım & Onarım Çalışması
}

extension YolForumTipiExtension on YolForumTipi {
  String get baslik {
    switch (this) {
      case YolForumTipi.cevirme:
        return 'Çevirme Var';
      case YolForumTipi.kaza:
        return 'Kaza Var';
      case YolForumTipi.calisma:
        return 'Çalışma Var';
    }
  }

  String get altBaslik {
    switch (this) {
      case YolForumTipi.cevirme:
        return 'Polis & Radar Kontrolü';
      case YolForumTipi.kaza:
        return 'Trafik Kazası & Yoğunluk';
      case YolForumTipi.calisma:
        return 'Yol Yapım & Bakım Onarım';
    }
  }

  IconData get ikon {
    switch (this) {
      case YolForumTipi.cevirme:
        return Icons.local_police_rounded;
      case YolForumTipi.kaza:
        return Icons.car_crash_rounded;
      case YolForumTipi.calisma:
        return Icons.construction_rounded;
    }
  }

  Color get anaRenk {
    switch (this) {
      case YolForumTipi.cevirme:
        return const Color(0xFF2563EB); // Polis Mavisi
      case YolForumTipi.kaza:
        return const Color(0xFFEF4444); // Kaza Kırmızısı
      case YolForumTipi.calisma:
        return const Color(0xFFF59E0B); // Turuncu Çalışma
    }
  }

  Color get acikRenk {
    switch (this) {
      case YolForumTipi.cevirme:
        return const Color(0xFFEFF6FF);
      case YolForumTipi.kaza:
        return const Color(0xFFFEF2F2);
      case YolForumTipi.calisma:
        return const Color(0xFFFFFBEB);
    }
  }

  Color get kenarRenk {
    switch (this) {
      case YolForumTipi.cevirme:
        return const Color(0xFF93C5FD);
      case YolForumTipi.kaza:
        return const Color(0xFFFCA5A5);
      case YolForumTipi.calisma:
        return const Color(0xFFFCD34D);
    }
  }
}

class YolForumYorum {
  final String id;
  final String yazar;
  final String zaman;
  final String yorum;
  int begeniSayisi;

  YolForumYorum({
    required this.id,
    required this.yazar,
    required this.zaman,
    required this.yorum,
    this.begeniSayisi = 0,
  });
}

class YolForumBildirimi {
  final String id;
  final YolForumTipi tip;
  final String baslik;
  final String bolge;
  final String konumAdi;
  final String aciklama;
  final double lat;
  final double lon;
  final String zaman;
  final DateTime olusturmaTarihi;
  int dogrulamaSayisi;
  int yanlisSayisi;
  final List<YolForumYorum> yorumlar;
  final String bildiren;

  YolForumBildirimi({
    required this.id,
    required this.tip,
    required this.baslik,
    required this.bolge,
    required this.konumAdi,
    required this.aciklama,
    required this.lat,
    required this.lon,
    required this.zaman,
    required this.olusturmaTarihi,
    this.dogrulamaSayisi = 1,
    this.yanlisSayisi = 0,
    required this.yorumlar,
    this.bildiren = 'Anonim Sürücü',
  });
}

// 📌 KKTC İÇİN GERÇEKÇİ BAŞLANGIÇ YOL BİLDİRİMLERİ
List<YolForumBildirimi> getKktcBaslangicYolBildirimleri() {
  return [
    YolForumBildirimi(
      id: 'yf_1',
      tip: YolForumTipi.cevirme,
      baslik: 'Gönyeli Çemberi Polis Çevirmesi',
      bolge: 'Lefkoşa',
      konumAdi: 'Lefkoşa - Gönyeli Çemberi Girne Çıkışı',
      aciklama: 'Trafik ekipleri araç durduruyor. Emniyet kemeri ve hız kontrolü yapılıyor.',
      lat: 35.2150,
      lon: 33.3280,
      zaman: '5 dk önce',
      olusturmaTarihi: DateTime.now().subtract(const Duration(minutes: 5)),
      dogrulamaSayisi: 21,
      yanlisSayisi: 0,
      bildiren: 'Ahmet Y. (Sürücü)',
      yorumlar: [
        YolForumYorum(
          id: 'y_1_1',
          yazar: 'Kemal T.',
          zaman: '3 dk önce',
          yorum: 'Girne yönüne giden şeritte bekliyorlar, hızınıza dikkat edin.',
          begeniSayisi: 8,
        ),
        YolForumYorum(
          id: 'y_1_2',
          yazar: 'Mustafa K.',
          zaman: '1 dk önce',
          yorum: 'Hala ordalar mı? Evet az önce geçtim, 2 ekip otosu var.',
          begeniSayisi: 4,
        ),
      ],
    ),
    YolForumBildirimi(
      id: 'yf_2',
      tip: YolForumTipi.kaza,
      baslik: 'Girne Dağ Yolu Maddi Hasarlı Kaza',
      bolge: 'Girne',
      konumAdi: 'Girne - Değirmenlik Dağ Yolu Keskin Viraj',
      aciklama: 'Çift taraflı kaza meydana geldi. Yol tek şeritten kontrollü olarak sağlanıyor.',
      lat: 35.2780,
      lon: 33.3950,
      zaman: '18 dk önce',
      olusturmaTarihi: DateTime.now().subtract(const Duration(minutes: 18)),
      dogrulamaSayisi: 34,
      yanlisSayisi: 1,
      bildiren: 'Tolga B.',
      yorumlar: [
        YolForumYorum(
          id: 'y_2_1',
          yazar: 'Caner D.',
          zaman: '12 dk önce',
          yorum: 'Çekici geldi yolu açmaya çalışıyorlar, yaklaşık 15 dk kuyruk var.',
          begeniSayisi: 11,
        ),
        YolForumYorum(
          id: 'y_2_2',
          yazar: 'Murat S.',
          zaman: '5 dk önce',
          yorum: 'Alternatif olarak Lefkoşa Boğaz yolunu kullanabilirsiniz.',
          begeniSayisi: 9,
        ),
      ],
    ),
    YolForumBildirimi(
      id: 'yf_3',
      tip: YolForumTipi.calisma,
      baslik: 'Balıkesir - Ercan Kavşağı Yol Çalışması',
      bolge: 'Lefkoşa / Balıkesir',
      konumAdi: 'Balıkesir Yonca Kavşağı - Ercan Bağlantısı',
      aciklama: 'Asfalt yenileme ve yol çizgisi çekimi yapılıyor. Hız limiti 50 km/s olarak uygulanıyor.',
      lat: 35.1894,
      lon: 33.4478,
      zaman: '32 dk önce',
      olusturmaTarihi: DateTime.now().subtract(const Duration(minutes: 32)),
      dogrulamaSayisi: 15,
      yanlisSayisi: 0,
      bildiren: 'Serhat G.',
      yorumlar: [
        YolForumYorum(
          id: 'y_3_1',
          yazar: 'Ayşe M.',
          zaman: '20 dk önce',
          yorum: 'Havalimanı uçağı olanlar 20 dakika erken çıksın, tek şerit açık.',
          begeniSayisi: 14,
        ),
      ],
    ),
    YolForumBildirimi(
      id: 'yf_4',
      tip: YolForumTipi.cevirme,
      baslik: 'Alsancak Çevre Yolu Mobil Radar',
      bolge: 'Girne',
      konumAdi: 'Escape Kavşağı Civarı (Batı Çıkışı)',
      aciklama: 'Sivil araçlı mobil radar tespit edildi. Hız limiti 65 km/s kontrol ediliyor.',
      lat: 35.3420,
      lon: 33.2510,
      zaman: '12 dk önce',
      olusturmaTarihi: DateTime.now().subtract(const Duration(minutes: 12)),
      dogrulamaSayisi: 19,
      yanlisSayisi: 0,
      bildiren: 'Bülent K.',
      yorumlar: [
        YolForumYorum(
          id: 'y_4_1',
          yazar: 'Mehmet E.',
          zaman: '7 dk önce',
          yorum: 'Beyaz renkli sivil araç refüj kenarında bekliyor.',
          begeniSayisi: 6,
        ),
      ],
    ),
    YolForumBildirimi(
      id: 'yf_5',
      tip: YolForumTipi.kaza,
      baslik: 'Lefkoşa Hastane Kavşağı Çarpışma',
      bolge: 'Lefkoşa',
      konumAdi: 'Dr. Burhan Nalbantoğlu Devlet Hastanesi Kavşağı',
      aciklama: 'Kavşakta maddi hasarlı kaza. Trafik polisi olay yerinde yönlendirme yapıyor.',
      lat: 35.2010,
      lon: 33.3360,
      zaman: '24 dk önce',
      olusturmaTarihi: DateTime.now().subtract(const Duration(minutes: 24)),
      dogrulamaSayisi: 16,
      yanlisSayisi: 1,
      bildiren: 'Hasan C.',
      yorumlar: [
        YolForumYorum(
          id: 'y_5_1',
          yazar: 'Ali V.',
          zaman: '10 dk önce',
          yorum: 'Ortabahçe yönüne dönüşler açıldı, kontrollü geçiş var.',
          begeniSayisi: 3,
        ),
      ],
    ),
    YolForumBildirimi(
      id: 'yf_6',
      tip: YolForumTipi.calisma,
      baslik: 'Dörtyol Çemberi Refüj & Aydınlatma Çalışması',
      bolge: 'Gazimağusa',
      konumAdi: 'Lefkoşa - Mağusa Anayolu Dörtyol Mevkii',
      aciklama: 'Karayolları ekipleri orta refüj aydınlatma direği montajı yapıyor. Sol şerit kapalı.',
      lat: 35.1950,
      lon: 33.7450,
      zaman: '45 dk önce',
      olusturmaTarihi: DateTime.now().subtract(const Duration(minutes: 45)),
      dogrulamaSayisi: 11,
      yanlisSayisi: 0,
      bildiren: 'Cevdet A.',
      yorumlar: [
        YolForumYorum(
          id: 'y_6_1',
          yazar: 'Sinan K.',
          zaman: '15 dk önce',
          yorum: 'Dubalar koyulmuş, yavaşlayarak geçiniz.',
          begeniSayisi: 5,
        ),
      ],
    ),
  ];
}
