# 🚗 KKTC e-Trafik, Ceza, Seyrüsefer & Akıllı Navigasyon Sistemi

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Version](https://img.shields.io/badge/Sürüm-v1.0.3-10B981?style=for-the-badge)
![Security](https://img.shields.io/badge/Siber%20Güvenlik-WAF%20%7C%20Anti--DDoS%20%7C%20RBAC-D90429?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-4E73DF?style=for-the-badge)
![CI/CD](https://img.shields.io/badge/GitHub%20Actions-Otomatik%20APK%20%26%20IPA%20Build-success?style=for-the-badge&logo=githubactions&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)

<br/>

**Kuzey Kıbrıs Türk Cumhuriyeti (KKTC)** sürücüleri ve ziyaretçileri için geliştirilmiş yeni nesil dijital trafik, ceza sorgulama, seyrüsefer (yol vergisi) takibi, zorunlu sigorta, sabit radarlar, canlı trafik analitiği, akıllı rota rehberi, Google Maps tarzı canlı navigasyon ve mobil siber güvenlik kalkanı uygulaması.

[📲 En Son APK'yı İndir](https://github.com/Tubi-kara/kktc_ceza/releases/download/latest/kktc_ceza_app.apk) • [Özellikler](#-öne-çıkan-özellikler) • [Siber Güvenlik (WAF)](#-mobil-siber-güvenlik-duvarı-waf--soc-kalkanı) • [OTA Güncelleme](#-kablosuz-otomatik-güncelleme-ota--github-actions-cicd) • [Cihaz Uyumluluğu](#-cihaz-ve-ekran-uyumluluğu-redmi-note-13-pro-optimizasyonu) • [Kurulum](#-kurulum-ve-çalıştırma)

---

</div>

## 🚀 Son Sürümle Eklenenler (v1.0.3)

- **🎬 Sinematik Açılış Animasyonu (Splash Screen):** Uygulama ikonuna dokunulduğunda doğrudan kuru bir ekrana geçmek yerine; 3D resmi KKTC logosunun parlayarak elastik büyümesi, arkasında yayılan radar dalgaları, telemetri durum yükleme göstergesi ve akıcı cross-fade geçişiyle giriş ekranına bağlanan sinematik açılış eklendi (istendiğinde tek tıkla "Atla" seçeneğiyle).
- **🎨 Özel Resmi KKTC e-Trafik Uygulama Logosu & Başlatıcı İkonu:** Varsayılan Flutter logosu tamamen kaldırılarak; KKTC ay-yıldızı, altın işlemeli resmi polis arması, dijital yol haritası ve radar tarayıcısından oluşan yüksek çözünürlüklü 3D özel uygulama ikonu Android (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi) ve Web platformlarına uyarlandı.
- **📥 Uygulama İçi Direkt İndirme (In-App Downloader):** Güncelle butonuna basıldığında artık tarayıcıya veya GitHub'a yönlendirilmez. Uygulama içinde gerçek zamanlı MB/boyut ve % ilerleme çubuğuyla APK doğrudan indirilir.
- **⚡ Otomatik Paket Yükleyici (Direct Installer):** İndirme %100 tamamlandığı anda Android sistem paket yükleyicisi otomatik olarak ekrana gelir ve tek tıkla güncelleme kurulur.
- **🛡️ Google Play Protect Uyarısı Desteği & İzinler:** Android 8-15 ve HyperOS uyumluluğu için `REQUEST_INSTALL_PACKAGES` izni ve `KKTC e-Trafik` resmi etiket tanımlandı. Kurulum ekranında kullanıcılar için Play Protect aşma rehberi eklendi (*"Daha Fazla Ayrıntı" ➔ "Yine de Yükle"*).
- **🔑 Özel Yönetici Girişi (`tubi` / `1907`) & Gizli SOC Erişimi:** Admin demo kartı kaldırıldı; Siber Operasyon Merkezi ve güvenlik duvarı yalnızca yetkili kullanıcı adı `tubi` ve şifre `1907` ile özel olarak açılır.
- **🎯 Haritaya Dokunarak Dinamik Rota Oluşturma (Touch-to-Route):** Haritada herhangi bir noktaya dokunulduğunda anlık ekran koordinatlarından gerçek GPS `(lat, lon)` ters projeksiyonu yapılır. Açılan amber renkli hedef rozeti ve alt panel üzerinden tek tıkla *"Buraya Git (Hedef)"* veya *"Buradan Başla (Kalkış)"* seçilebilir; canlı OSRM rotası anında çizilir.
- **🧭 Google Maps Tarzı Gerçek Navigasyon HUD & Dönüş Manevraları:** Canlı yeşil dönüş banner'ı, *"200 m sonra Lefkoşa yönüne sola dönün"*, *"ŞİMDİ DÖNÜN"* sesli/görsel yönlendirmeleri, tahmini varış saati (ETA), kalan dakika/km telemetrisi ve canlı GPS takip pini.
- **🛡️ Mobil Siber Güvenlik Duvarı (WAF & SOC Kalkanı):** SQL Injection, XSS, komut enjeksiyonu filtreleri, 3 saniyede 12 sorgu Anti-DDoS flood koruması, Strict HTTPS ve izinli domain whitelist denetleyicisi.
- **🔒 Rol Bazlı Güvenlik (RBAC) & PIN Koruması:** Siber güvenlik HUD'ı normal vatandaşlardan tamamen gizlendi. Yalnızca `tubi` / `1907` yöneticisine veya Polis logosuna 5 kez tıklanarak girilen `1907` / `1974` PIN koduyla açılır.
- **📲 Kablosuz Otomatik Güncelleme (In-App OTA Auto-Update):** USB kablosuna ihtiyaç duymadan GitHub Releases üzerinden yeni sürüm denetimi ve uygulama içinden tek tıkla güncelleme motoru.

---

## 🌟 Öne Çıkan Özellikler

- **🔍 Akıllı Arama & Doğrudan Yönlendirme (Spotlight Search):** Ekranın üstündeki arama çubuğundan *"seyrüsefer"*, *"ceza"*, *"radar"*, *"itiraz"* veya *"rota"* yazıldığında; Türkçe karakter toleranslı arama motoru ile anında tespit edip kullanıcının tek tıkla doğrudan ilgili sekmeye gitmesini sağlar.
- **🚦 Canlı Trafik Yoğunluğu & Kalabalık Bölgeler Analitiği:** Ada içi kritik koridorlarda (Gönyeli Çemberi, Lefkoşa Dereboyu, Girne Sahil Şeridi, Değirmenlik Dağ Yolu) canlı trafik yoğunluğu seviyeleri (Akıcı / Yoğun / Kilitli), dakika bazlı gecikme tahmini ve alternatif baypas yolları.
- **🗺️ Canlı OpenStreetMap Navigasyonu & Rota Motoru:** Canlı GPS ve OSRM altyapısıyla harita üzerinde adım adım güzergah çizimi, güzergahtaki sabit hız kameralarının sayısı, mesafe ve varış süresi hesaplama.
- **🚨 Ceza Sorgulama & Erken Ödeme İndirimi:** Plaka veya kimlik numarasıyla anlık trafik cezası sorgulama, ceza puanı görüntüleme ve yasal 15 gün içinde **%15 erken ödeme indirimi** hesaplama.
- **🏛️ Seyrüsefer (Yol Vergisi) & Muayene Takibi:** KKTC Maliye Bakanlığı ve Gelir & Vergi Dairesi uyumlu seyrüsefer geçerlilik süresi, kalan gün sayacı, ceza risk analizi, muayene takvimi ve online harç yenileme.
- **🛡️ Apple Wallet Stili Dijital Sigorta:** Zorunlu Trafik Sigortası ve Kasko bitiş sayaçları, teminat dökümleri, PDF poliçe indirme ve resmi dijital sigorta kartı.
- **👮 Canlı Polis Çevirmesi QR Kodu:** Polis ve denetim ekipleri için tek ekranda güncel sigorta, seyrüsefer, muayene ve sürücü puanı durumunu doğrulayan dinamik ve OTP korumalı resmi QR kod sistemi.
- **⚖️ Trafik Hakem Heyeti İtiraz Dilekçesi:** Hatalı veya haksız kesilen radar cezalarına karşı online resmi itiraz dilekçesi hazırlama modülü.
- **📄 Barkodlu Resmi Sürücü Belgesi & Dekontlar:** Resmi kurumlarda geçerli dijital ehliyet ve geçmişe dönük tüm maliye tahsilat makbuzları.
- **🌐 Çift Dil Desteği:** Türkçe 🇹🇷 ve İngilizce 🇬🇧 tam arayüz yerelleştirmesi.

---

## 🛡️ Mobil Siber Güvenlik Duvarı (WAF) & SOC Kalkanı

Uygulama, siber saldırılara ve kötü niyetli veri manipülasyonuna karşı çok katmanlı kurumsal güvenlik kalkanı ile korunmaktadır:

1. **SQL Injection & XSS Saldırı Filtresi:** Arama kutularına, plaka girişlerine ve form alanlarına girilen `OR 1=1`, `UNION SELECT`, `DROP TABLE`, `<script>` gibi saldırı kodları anında yakalanır ve nötralize edilir.
2. **Anti-DDoS & Flood İstek Sınırlayıcı (Rate Limiter):** Bot saldırılarını engellemek amacıyla 3 saniyede 12'den fazla istek gönderen kaynaklar otomatik olarak geçici engellenir.
3. **Strict HTTPS & Güvenli Domain Whitelist (MitM Koruması):** Şifresiz (`http://`) tüm bağlantılar reddedilir. Yalnızca izinli sunucularla (`gov.ct.tr`, `openstreetmap.org`, `project-osrm.org`, `github.com`) haberleşilir; harici sunuculara veri sızdırılması engellenir.
4. **Cihaz Bütünlüğü & Root/Jailbreak Taraması:** Yetkisiz sistem müdahalelerini tespit eden tarama motoru içerir.
5. **Halktan Gizlenmiş Yönetici Paneli (RBAC):** Normal vatandaşlar güvenlik loglarını görmez; saldırı durumunda sade bir uyarı alır. Yönetici / SOC paneline erişim:
   - Giriş ekranında kullanıcı adı **`tubi`** ve şifre **`1907`** girilerek doğrudan, veya
   - Sol üstteki polis logosuna **5 kez dokunarak açılan gizli PIN ekranına (`1907` veya `1974`)** şifre girilerek açılabilir. Demo listesinde yönetici profili yer almaz.

---

## 📲 Kablosuz Otomatik Güncelleme (OTA) & GitHub Actions CI/CD

Artık telefonunuza kablo takmanıza gerek yoktur:

1. **Otomatik Bulut Derlemesi:** Her `git push` yapıldığında `.github/workflows/build_apk.yml` devreye girer, GitHub sunucularında release APK'sını derler ve GitHub Releases sekmesine yükler.
2. **Uygulama İçi Bildirim (OTA):** Uygulama açıldığında GitHub Releases API'sini sorgular. Yeni bir sürüm varsa ekrana modern glassmorphism güncelleme kartı gelir.
3. **Uygulama İçi Canlı İndirme:** *"Direkt İndir & Kur"* butonuna basıldığında tarayıcıya gitmeden, uygulama içinde anlık MB ve % ilerleme çubuğuyla APK indirilir.
4. **Otomatik Paket Yükleyici:** İndirme tamamlanır tamamlanmaz Android sistem yükleyicisi otomatik olarak açılır ve veriler kaybolmadan güncelleme yüklenir.
5. **🛡️ Google Play Protect Notu:** Üçüncü taraf mağaza dışı doğrudan güncellemelerde Google Play Protect uyarı verebilir. Ekranda gösterilen rehber uyarınca *"Daha Fazla Ayrıntı"* ➔ *"Yine de Yükle"* seçilerek kurulum saniyeler içinde tamamlanır.
6. **Manuel Kontrol:** Üst çubuktaki mavi Bulut Güncelleme (`cloud_sync`) ikonu ile istenildiği an yeni sürüm kontrol edilebilir.

---

## 📱 Cihaz ve Ekran Uyumluluğu (Redmi Note 13 Pro+ Optimizasyonu)

Uygulama, farklı ekran en-boy oranlarına ve özellikle Xiaomi/MIUI/HyperOS cihazlarda karşılaşılan yüksek DPI ve büyük font ölçeklendirmelerine karşı titizlikle optimize edilmiştir:

* **Sıfır Taşma (No RenderFlex Overflow):** Redmi Note 13 Pro+, iPhone SE, iPhone 15/16 Pro Max gibi farklı boyutlardaki cihazlarda `FittedBox`, `Flexible` ve `Expanded` widget mimarisi ile taşma hataları engellenmiştir.
* **Kod ve Referans Numaraları Düzenlemesi:** 
  - Ceza Referans Kodları (`#KKTC-2024-884912`),
  - Geçmiş Ödeme Makbuz Kodları (`#KKTC-2024-110294`, `#SYR-89210`),
  - Elektronik Tahsilat & Dekont Kodları (`DEKONT-...`, `SIGORTA-...`, `SYR-...`),
  - MOBESE Kanıt Zaptı ve Kamera Kodları (`CAM-04-GONYELI`, `DELİL NO: #884912`),
  - Dinamik Polis QR Güvenlik Kodu (`_sigortaOtpKodu`),
  - Resmi Barkod No (`Barkod No: KKTC-TR-2026-99182`),
  özelleştirilmiş monospace kapsayıcı hap rozetler (pills) ve otomatik ölçeklendirme ile korunarak kaymalar, satır kırılmaları veya metin kesilmeleri tamamen ortadan kaldırılmıştır.
* **Telemetri ve Radar Hız Ölçer Koruması:** Radar hızı ve hız limiti panelleri `FittedBox` içine alınarak dar alanlarda çakışmasız ve hizalı görüntülenmesi garanti altına alınmıştır.
* **Acil Yardım Butonları:** 14 karakterli acil çağrı numaraları (örn. `0392 228 88 88`) metin kayması yaşanmadan dinamik olarak buton içine sığdırılmıştır.
* **iOS Liquid Glass & Slate Tasarım:** Derin lacivert (`#0A122A`), KKTC Crimson Kırmızı ve Neon Emerald tonlarında modern ve estetik görsel dil.

---

## 🛠️ Teknoloji Yığını

| Bileşen | Teknoloji | Açıklama |
| :--- | :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev/) (3.x) | Çapraz platform yüksek performanslı mobil UI |
| **Dil** | [Dart](https://dart.dev/) | Tip güvenli ve modern mobil programlama dili |
| **Harita & Navigasyon** | OpenStreetMap & OSRM Engine | Canlı sokak polylineları, GPS HUD, dönüş manevraları |
| **Siber Güvenlik** | Özel WAF & Rate Limiter | SQLi/XSS koruması, Anti-DDoS, Strict HTTPS |
| **Güncelleme & Dağıtım** | GitHub Releases & OTA Engine | USB gerektirmeyen kablosuz uygulama içi güncelleme |
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

## 📂 Proje Dizin Yapısı

```plaintext
kktc_ceza_app/
├── .github/
│   └── workflows/
│       ├── build_apk.yml          # GitHub Actions Android Release APK derleme ve yayınlama
│       └── ios_build.yml          # GitHub Actions iOS IPA otomatik derleme hattı
├── android/                       # Android platform yapılandırması & izinleri
├── ios/                           # iOS Runner, Info.plist ATS ve donanım izinleri
├── lib/
│   ├── main.dart                  # Ana giriş, rol yönetimi, cezalar & sigorta, UI
│   ├── guvenlik_duvari.dart       # WAF, Anti-DDoS, SQLi/XSS filtresi, SOC HUD paneli
│   ├── guncelleme_servisi.dart    # GitHub Releases OTA kablosuz güncelleme motoru
│   ├── canli_gps_servisi.dart     # Canlı GPS konumu, gerçek hız ve yön takibi
│   ├── yol_tarifi_sayfasi.dart    # Touch-to-Route, Google Maps dönüş HUD'ı, OSRM rotası
│   ├── hizli_arama_modali.dart    # Spotlight arama ve doğrudan sekme yönlendirici
│   ├── yardim_rehberi_sayfasi.dart # Nasıl giderim, KKTC sürüş kuralları, acil rehber ve SSS
│   ├── radar_haritasi.dart        # KKTC geneli sabit radar koordinatları ve hız limitleri
│   └── kktc_gov_sync_service.dart # Canlı kamu sunucuları senkronizasyon şeridi
├── pubspec.yaml                   # Proje bağımlılıkları ve sürüm yapılandırması
└── README.md                      # Kapsamlı güncel dokümantasyon
```

---

## 📄 Katkı ve Lisans

Bu proje açık kaynaklı bir topluluk girişimidir. Bu yazılım **MIT** lisansı altında lisanslanmıştır.
