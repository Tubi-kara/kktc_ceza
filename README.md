# 🚗 KKTC e-Trafik, Ceza, Seyrüsefer & Akıllı Navigasyon Sistemi

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Version](https://img.shields.io/badge/Sürüm-v1.0.3-10B981?style=for-the-badge)
![Security](https://img.shields.io/badge/Güvenlik-256--Bit%20SSL%20%7C%20WAF-D90429?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-4E73DF?style=for-the-badge)
![CI/CD](https://img.shields.io/badge/GitHub%20Actions-Otomatik%20Build-success?style=for-the-badge&logo=githubactions&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)

<br/>

**Kuzey Kıbrıs Türk Cumhuriyeti (KKTC)** sürücüleri ve ziyaretçileri için geliştirilmiş yeni nesil dijital trafik, ceza sorgulama, seyrüsefer (yol vergisi) takibi, zorunlu sigorta, sabit radarlar, canlı trafik analitiği, akıllı rota rehberi ve Google Maps tarzı canlı navigasyon uygulaması.

[📲 En Son APK'yı İndir](https://github.com/Tubi-kara/kktc_ceza/releases/download/latest/kktc_ceza_app.apk) • [Özellikler](#-öne-çıkan-özellikler) • [Güvenlik](#-güvenlik-ve-gizlilik-standartları) • [OTA Güncelleme](#-kablosuz-otomatik-güncelleme-ota--github-actions-cicd) • [Cihaz Uyumluluğu](#-cihaz-ve-ekran-uyumluluğu) • [Kurulum](#-kurulum-ve-çalıştırma)

---

</div>

## 🚀 Son Sürümle Eklenenler (v1.0.3)

- **🍏 Tam Kapsamlı iOS (iPhone & iPad) Desteği:** iOS için özel AppIcon seti, kurumsal sistem yapılandırması, Safari Web PWA desteği (*"Paylaş ➔ Ana Ekrana Ekle"* ile kurulumsuz tam ekran çalışma) ve GitHub Releases üzerinden `.ipa` dağıtımı sağlandı.
- **🎬 Sinematik Açılış Animasyonu (Splash Screen):** 3D resmi KKTC arması, radar dalgaları, telemetri durumu yükleme göstergesi ve akıcı cross-fade geçişiyle giriş ekranına bağlanan sinematik açılış eklendi.
- **🎨 Özel Resmi KKTC e-Trafik Uygulama Logosu:** Standart simgeler kaldırılarak; resmi kalkan, ay-yıldız, dijital otoyol ve radar ışınından oluşan 3D özel uygulama logosu tüm platformlara entegre edildi.
- **📥 Uygulama İçi Direkt İndirme (In-App Downloader):** Güncelleme sırasında tarayıcıya gitmeden, uygulama içinde gerçek zamanlı MB/boyut ve % ilerleme çubuğuyla APK doğrudan indirilir.
- **⚡ Otomatik Paket Yükleyici:** İndirme tamamlandığı anda sistem paket yükleyicisi otomatik olarak açılarak güncelleme tek tıkla kurulur.
- **🎯 Haritaya Dokunarak Dinamik Rota Oluşturma (Touch-to-Route):** Haritada herhangi bir noktaya dokunulduğunda gerçek GPS koordinatları projeksiyonu yapılır; *"Buraya Git"* veya *"Buradan Başla"* seçenekleriyle canlı OSRM rotası çizilir.
- **🧭 Canlı Navigasyon HUD & Dönüş Manevraları:** Canlı dönüş yönlendirmeleri, tahmini varış saati (ETA), kalan dakika/km telemetrisi ve canlı GPS takip göstergesi.

---

## 🌟 Öne Çıkan Özellikler

- **🔍 Akıllı Arama & Doğrudan Yönlendirme (Spotlight Search):** Ekranın üstündeki arama çubuğundan *"seyrüsefer"*, *"ceza"*, *"radar"*, *"itiraz"* veya *"rota"* yazıldığında; Türkçe karakter toleranslı arama motoru ile kullanıcıyı doğrudan ilgili sekmeye yönlendirir.
- **🚦 Canlı Trafik Yoğunluğu & Kalabalık Bölgeler Analitiği:** Ada içi kritik koridorlarda (Gönyeli Çemberi, Lefkoşa Dereboyu, Girne Sahil Şeridi, Değirmenlik Dağ Yolu) canlı trafik yoğunluğu seviyeleri, gecikme tahmini ve alternatif baypas yolları.
- **🗺️ Canlı OpenStreetMap Navigasyonu & Rota Motoru:** Canlı GPS ve OSRM altyapısıyla harita üzerinde adım adım güzergah çizimi, güzergahtaki sabit hız kameralarının sayısı, mesafe ve varış süresi hesaplama.
- **🚨 Ceza Sorgulama & Erken Ödeme İndirimi:** Plaka veya kimlik numarasıyla anlık trafik cezası sorgulama, ceza puanı görüntüleme ve yasal 15 gün içinde **%15 erken ödeme indirimi** hesaplama.
- **🏛️ Seyrüsefer (Yol Vergisi) & Muayene Takibi:** KKTC Maliye Bakanlığı ve Gelir & Vergi Dairesi uyumlu seyrüsefer geçerlilik süresi, kalan gün sayacı, ceza risk analizi, muayene takvimi ve online harç yenileme rehberi.
- **🛡️ Apple Wallet Stili Dijital Sigorta:** Zorunlu Trafik Sigortası ve Kasko bitiş sayaçları, teminat dökümleri, PDF poliçe indirme ve resmi dijital sigorta kartı.
- **👮 Canlı Polis Çevirmesi QR Kodu:** Resmi denetimler için tek ekranda güncel sigorta, seyrüsefer, muayene ve ceza puanı durumunu doğrulayan dinamik ve OTP korumalı resmi QR kod sistemi.
- **⚖️ Trafik Hakem Heyeti İtiraz Dilekçesi:** Hatalı kesilen radar cezalarına karşı online resmi itiraz dilekçesi hazırlama modülü.
- **📄 Barkodlu Resmi Sürücü Belgesi & Dekontlar:** Resmi kurumlarda geçerli dijital ehliyet ve geçmişe dönük maliye tahsilat makbuzları.
- **🌐 Çift Dil Desteği:** Türkçe 🇹🇷 ve İngilizce 🇬🇧 tam arayüz yerelleştirmesi.

---

## 🛡️ Güvenlik ve Gizlilik Standartları

Uygulama, kamu veri tabanları ve kullanıcı sorguları arasında en üst düzey veri güvenliği standartlarını uygular:

1. **Uçtan Uca 256-Bit SSL/TLS Şifreleme:** Tüm sorgular şifrelenmiş tüneller üzerinden resmi kurum sunucularıyla haberleşir; aradaki bağlantılar dinlenemez veya değiştirilemez.
2. **Web Uygulama Güvenlik Filtreleri:** Arama çubuğu, plaka sorguları ve form girişleri zararlı kod enjeksiyonlarına karşı otomatik olarak doğrulanır ve filtrelenir.
3. **Akıllı İstek Sınırlayıcı (Rate Limiter):** Sistem kaynaklarının kötüye kullanımını ve bot kaynaklı aşırı yüklenmeleri engelleyen akıllı trafik regülatörü devrededir.
4. **Resmi Alan Adı İzin Listesi (Domain Whitelist):** Uygulama yalnızca doğrulanmış resmi kamu ve harita sunucularıyla (`gov.ct.tr`, `openstreetmap.org`, `project-osrm.org`, `github.com`) haberleşir.
5. **Cihaz Bütünlüğü Güvenliği:** Cihaz üzerindeki yetkisiz modifikasyonlara karşı verileri koruyan dahili güvenlik mekanizmaları içerir.

---

## 📲 Kablosuz Otomatik Güncelleme (OTA) & GitHub Actions CI/CD

- **Otomatik Bulut Derlemesi:** Her güncellemede GitHub Actions devreye girer, Android release APK ve iOS IPA paketlerini otomatik derler.
- **Uygulama İçi Bildirim:** Yeni bir sürüm yayınlandığında uygulama içinde kullanıcıya güncelleme penceresi gösterilir.
- **Uygulama İçi İndirme (Android):** Tarayıcıya gitmeden, uygulama içinde gerçek zamanlı indirme ve doğrudan sistem paket yükleyicisiyle kurulum gerçekleştirilir.
- **iOS & Web Kolaylığı:** iOS kullanıcıları için doğrudan IPA indirme veya Safari üzerinden tek tıkla ana ekrana ekleyerek anında kullanım imkanı sağlanır.

---

## 📱 Cihaz ve Ekran Uyumluluğu

Uygulama, farklı ekran oranlarına ve MIUI / HyperOS / iOS font ölçeklendirmelerine karşı titizlikle optimize edilmiştir:

- **Sıfır Taşma Garantisi:** `FittedBox` ve esnek grid mimarisiyle küçük ekranlardan büyük cihazlara kadar hiçbir ekranda taşma veya kayma yaşanmaz.
- **Korunaklı Referans Numaraları:** Ceza referans kodları, makbuz numaraları, dekontlar ve polis QR kodları özel monospace hap rozetlerle satır kırılmasına uğramadan net bir şekilde sunulur.
- **Modern Görsel Dil:** Derin lacivert (`#0A122A`), KKTC Crimson Kırmızı ve Neon Emerald tonlarında modern, göz yormayan arayüz tasarımı.

---

## 🛠️ Teknoloji Yığını

| Bileşen | Teknoloji | Açıklama |
| :--- | :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev/) (3.x) | Çapraz platform yüksek performanslı mobil UI |
| **Dil** | [Dart](https://dart.dev/) | Tip güvenli ve modern mobil programlama dili |
| **Harita & Navigasyon** | OpenStreetMap & OSRM Engine | Canlı sokak polylineları, GPS HUD, dönüş manevraları |
| **Ağ Güvenliği** | SSL/TLS & Strict HTTPS | Şifreli kamu bağlantıları ve güvenli domain whitelist |
| **Güncelleme & Dağıtım** | GitHub Releases & OTA Engine | Uygulama içi kablosuz güncelleme motoru |
| **Tasarım Dili** | Material 3 & Custom Tokens | KKTC resmi renkleri ve modern Slate/Crimson paleti |
| **CI / CD** | GitHub Actions | Otomatik Android Release APK ve iOS IPA derleme hattı |
| **Platformlar** | Android, iOS, Web | Tek kod tabanından çoklu platform desteği |

---

## 🚀 Kurulum ve Çalıştırma

### Ön Koşullar
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.13.0)
* [Dart SDK](https://dart.dev/get-dart)
* Android Studio / VS Code ve Flutter eklentileri

### Adımlar

1. **Repoyu Klonlayın:**
   ```bash
   git clone https://github.com/Tubi-kara/kktc_ceza.git
   cd kktc_ceza/kktc_ceza_app
   ```

2. **Bağımlılıkları Yükleyin:**
   ```bash
   flutter pub get
   ```

3. **Uygulamayı Başlatın:**
   ```bash
   flutter run
   ```

---

## 📄 Katkı ve Lisans

Bu proje açık kaynaklı bir topluluk girişimidir. Bu yazılım **MIT** lisansı altında lisanslanmıştır.
