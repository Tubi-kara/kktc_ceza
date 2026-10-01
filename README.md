# 🚗 KKTC e-Trafik, Ceza, Seyrüsefer & Akıllı Navigasyon Sistemi

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-4E73DF?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)
![CI/CD](https://img.shields.io/badge/GitHub%20Actions-iOS%20IPA%20Build-success?style=for-the-badge&logo=githubactions&logoColor=white)
![Status](https://img.shields.io/badge/Durum-Aktif%20Geliştirme-success?style=for-the-badge)

<br/>

**Kuzey Kıbrıs Türk Cumhuriyeti (KKTC)** sürücüleri ve ziyaretçileri için geliştirilmiş yeni nesil dijital trafik, ceza sorgulama, seyrüsefer (yol vergisi) takibi, zorunlu sigorta, sabit radarlar, akıllı rota rehberi ve canlı navigasyon mobil uygulaması.

[Özellikler](#-öne-çıkan-özellikler) • [Modüller](#-modüller-ve-fonksiyonlar) • [Ekran Uyumluluğu](#-cihaz-ve-ekran-uyumluluğu) • [Kurulum & iOS](#-kurulum-ve-çalıştırma) • [Teknolojiler](#-teknoloji-yığını) • [Lisans](#-katkı-ve-lisans)

---

</div>

## 🌟 Öne Çıkan Özellikler

- **🔍 Akıllı Arama & Doğrudan Yönlendirme (Spotlight Search):** Ekranın üstündeki arama çubuğundan *"seyrüsefer"*, *"ceza"*, *"radar"*, *"itiraz"* veya *"rota"* yazıldığında; Türkçe karakter toleranslı arama motoru ile anında tespit edip kullanıcının tek tıkla doğrudan ilgili sekmeye ve alt sekmeye gitmesini sağlar.
- **🧭 Nasıl Giderim? & KKTC Sürüş ve Yardım Rehberi:** Ada içi kritik rotalar (Kalkanlı/ODTÜ ➔ Erülkü Demirhan, Girne ➔ Lapta & Alsancak Sahili, Lefkoşa ➔ Ercan Havalimanı vb.) için radar ve ışık baypas önerileri, tek dokunuşla rota haritasına aktarma, sol trafik sürüş kuralları, çember geçiş üstünlükleri ve acil durum hatları (155, 112, 199, 159, 7/24 Çekici).
- **🗺️ Canlı OpenStreetMap Navigasyonu & Rota Motoru:** Canlı GPS ve OSRM altyapısıyla harita üzerinde adım adım güzergah çizimi, güzergahtaki sabit hız kameralarının sayısı, mesafe ve varış süresi hesaplama.
- **🚨 Ceza Sorgulama & Erken Ödeme İndirimi:** Plaka veya kimlik numarasıyla anlık trafik cezası sorgulama, ceza puanı görüntüleme ve yasal 15 gün içinde **%15 erken ödeme indirimi** hesaplama.
- **🏛️ Seyrüsefer (Yol Vergisi) & Muayene Takibi:** KKTC Maliye Bakanlığı ve Gelir & Vergi Dairesi uyumlu seyrüsefer geçerlilik süresi, kalan gün sayacı, ceza risk analizi, muayene takvimi ve online harç yenileme.
- **🛡️ Apple Wallet Stili Dijital Sigorta:** Zorunlu Trafik Sigortası ve Kasko bitiş sayaçları, teminat dökümleri, PDF poliçe indirme ve resmi dijital sigorta kartı.
- **👮 Canlı Polis Çevirmesi QR Kodu:** Polis ve denetim ekipleri için tek ekranda güncel sigorta, seyrüsefer, muayene ve sürücü puanı durumunu doğrulayan dinamik ve OTP korumalı resmi QR kod sistemi.
- **⚖️ Trafik Hakem Heyeti İtiraz Dilekçesi:** Hatalı veya haksız kesilen radar cezalarına karşı online resmi itiraz dilekçesi hazırlama modülü.
- **📄 Barkodlu Resmi Sürücü Belgesi & Dekontlar:** Resmi kurumlarda geçerli dijital ehliyet ve geçmişe dönük tüm maliye tahsilat makbuzları.
- **🌐 Çift Dil Desteği:** Türkçe 🇹🇷 ve İngilizce 🇬🇧 tam arayüz yerelleştirmesi.

---

## 📱 Modüller ve Fonksiyonlar

### 1. 🔍 Hızlı Arama & Navigasyon Yönlendirici (Spotlight)
* Ekranın üst kısmında kalıcı ve erişilebilir akıllı arama çubuğu.
* Hızlı öneri çipleri (`🚗 Seyrüsefer`, `⚖️ Cezalarım`, `📸 Sabit Radarlar`, `🗺️ Yol Tarifi`, `🛡️ Sigorta & QR`, `📝 İtiraz Dilekçesi`, `💡 Nasıl Giderim?`).
* Arama sonucuna basıldığında arama modali kapanır ve ilgili tab/alt sekme otomatik seçilip açılır.

### 2. 🧭 Yardım, Sürüş ve Rota Rehberi
* **Kalkanlı / ODTÜ ➔ Erülkü Demirhan:** Gönyeli şehir içi 50 km/s radarlarına takılmadan Kuzey Çevre Yolu viyadüğünden bağlanma ipuçları.
* **Girne ➔ Lapta & Alsancak Sahili:** Alsancak çevre yolu tüneli ve çift şerit avantajı, dar viraj ve yaya uyarısı.
* **Lefkoşa ➔ Ercan Havalimanı (Yeni Terminal):** Değirmenlik dağ yolu kavşağı, yeni terminal bağlantısı ve 90 km/s hız sınırları.
* **KKTC Trafik Kuralları:** Soldan akan trafik, dönel kavşaklarda (çember) geçiş hakkı ve 100 ceza puanı sistemi.
* **Acil Yardım Rehberi:** 155 Polis İmdat, 112 Ambulans, 199 İtfaiye, 159 Karayolları Yol Yardım ve 7/24 Kurtarıcı Çekici.

### 3. 💳 Trafik Cezaları ve Ödeme Yönetimi
* Plakaya kayıtlı aktif ve geçmiş cezalar.
* Kamera görüntüleri, ihlal yeri, radar hızı ve ceza puanı dökümü.
* 15 gün içinde ödemede geçerli indirimli tutar hesaplama.
* Kredi kartı ile hızlı ve güvenli ceza ödeme simülasyonu.

### 4. ⏳ Seyrüsefer (Yol Vergisi) & Araç Muayenesi
* Kalan gün sayacı (Görsel ilerleme çubuğu & durum rozetleri).
* Gecikme faizi ve trafik cezası risk analizi.
* Yıllık ve dönemsel harç yenileme seçeneği.
* Resmi Seyrüsefer Belgesi (.PDF) indirme imkânı.

### 5. 🗺️ Radar ve Canlı Sürüş Haritası
* Ada genelindeki tüm sabit hız kameraları (Lefkoşa, Girne, Gazimağusa, Güzelyurt, İskele, Lefke).
* Güzergaha göre hız limitleri (50 km/s, 65 km/s, 75 km/s, 90 km/s, 100 km/s).
* Sesli ve görsel radar yaklaşma ikazları.

### 6. 🪪 Dijital Denetim & QR Ruhsat
* Trafik kontrol noktalarında polise gösterilmek üzere optimize edilmiş hızlı denetim kartı.
* Seyrüsefer, sigorta ve muayene durumunu tek bir dinamik QR kodda birleştiren altyapı.

---

## 📱 Cihaz ve Ekran Uyumluluğu

* **Sıfır Taşma (No Overflow):** Redmi Note 13 Pro+, iPhone SE, iPhone 15/16 Pro Max gibi farklı en-boy oranlarına ve font ölçeklerine sahip cihazlarda `FittedBox` ve esnek grid yapılarıyla optimize edildi.
* **iOS Liquid Glass & Slate Tasarım:** Derin lacivert (`#0A122A`), KKTC Crimson Kırmızı ve Neon Emerald tonlarında modern ve estetik görsel dil.

---

## 🛠️ Teknoloji Yığını

| Bileşen | Teknoloji | Açıklama |
| :--- | :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev/) (3.x) | Çapraz platform yüksek performanslı mobil UI |
| **Dil** | [Dart](https://dart.dev/) | Tip güvenli ve modern mobil programlama dili |
| **Harita & Navigasyon** | OpenStreetMap & OSRM Engine | Canlı harita çizimi ve güzergah motoru |
| **Tasarım Dili** | Material 3 & Custom Tokens | KKTC resmi renkleri ve modern Slate/Crimson paleti |
| **İkonlar** | Cupertino & Material Rounded Icons | Kusursuz platform uyumluluğu |
| **CI / CD** | GitHub Actions | Otomatik macOS tabanlı iOS IPA derleme ve dağıtım |
| **Platformlar** | iOS, Android, Web | Tek kod tabanından çoklu platform desteği |

---

## 🚀 Kurulum ve Çalıştırma

Projeyi yerel ortamınızda çalıştırmak için aşağıdaki adımları takip edebilirsiniz:

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
   # Bağlı cihazları listele
   flutter devices

   # Uygulamayı çalıştır
   flutter run
   ```

---

## 🍏 iOS (.ipa) Derlemesi ve Kurulum

Projede otomatik **GitHub Actions CI/CD** hattı tanımlıdır:
1. GitHub deposunda her `main` dalına push yapıldığında veya manuel olarak **Actions** sekmesinden workflow tetiklenir.
2. Derleme tamamlandığında **`KKTC_Ceza_iOS.ipa`** paketi Artifacts olarak indirilebilir.
3. İndirilen `.ipa` dosyası **AltStore**, **Scarlet**, **Sideloadly** veya **TrollStore** aracılığıyla herhangi bir iPhone'a doğrudan yüklenebilir.

---

## 📂 Proje Dizin Yapısı

```plaintext
kktc_ceza_app/
├── .github/
│   └── workflows/
│       └── ios_build.yml          # GitHub Actions iOS IPA otomatik derleme hattı
├── android/                       # Android platform yapılandırması & izinleri
├── ios/                           # iOS Runner, Info.plist ATS ve donanım izinleri
├── web/                           # Web platform yapılandırması
├── lib/
│   ├── main.dart                  # Ana giriş, tab yönetimi, cezalar & sigorta, servisler
│   ├── hizli_arama_modali.dart    # Spotlight arama ve doğrudan sekme yönlendirici
│   ├── yardim_rehberi_sayfasi.dart # Nasıl giderim, KKTC sürüş kuralları, acil rehber ve SSS
│   ├── yol_tarifi_sayfasi.dart    # Canlı OpenStreetMap navigasyonu ve rota motoru
│   ├── radar_haritasi.dart        # KKTC geneli sabit radar koordinatları ve hız limitleri
│   └── kktc_gov_sync_service.dart # Canlı kamu sunucuları senkronizasyon şeridi
├── pubspec.yaml                   # Proje bağımlılıkları ve yapılandırma
└── README.md                      # Kapsamlı dokümantasyon
```

---

## 📄 Katkı ve Lisans

Bu proje açık kaynaklı bir topluluk girişimidir. Katkıda bulunmak için:
1. Projeyi Fork'layın (`Fork`)
2. Yeni bir özellik dalı açın (`git checkout -b feature/YeniOzellik`)
3. Değişikliklerinizi commit edin (`git commit -m 'feat: Yeni özellik eklendi'`)
4. Dalınıza push yapın (`git push origin feature/YeniOzellik`)
5. Bir **Pull Request** açın.

Bu yazılım **MIT** lisansı altında lisanslanmıştır. Detaylar için `LICENSE` dosyasına göz atabilirsiniz.
