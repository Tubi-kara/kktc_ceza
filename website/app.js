/**
 * KKTC TRAFİK & SABİT RADAR SİSTEMİ - İNTERAKTİF WEB UYGULAMASI (app.js)
 * 2026 Güncel KKTC Trafik & Asgari Ücret Veritabanı
 */

// ==========================================
// 📍 GERÇEK KKTC SABİT RADAR LİSTESİ (18 ADET)
// ==========================================
const kktcRadarlar = [
  {
    id: "RAD-01",
    ad: "Gönyeli Çemberi Girişi",
    adEn: "Gonyeli Roundabout Entrance",
    sehir: "Lefkoşa",
    hizLimiti: 50,
    tur: "Sabit Hız & Kırmızı Işık",
    turEn: "Fixed Speed & Red Light",
    yon: "Lefkoşa Giriş Yönü (Çift Şerit)",
    yonEn: "Lefkosa Entrance (Dual Lane)",
    aciklama: "Gönyeli çemberine 250m kala, Lefkoşa ana arteri üzerinde.",
    aciklamaEn: "250m before Gonyeli roundabout on main Lefkosa artery.",
    lat: 35.2132,
    lon: 33.3085,
    mesafe: "1.4 km"
  },
  {
    id: "RAD-02",
    ad: "Dr. Burhan Nalbantoğlu Hastane Yolu",
    adEn: "State Hospital Road",
    sehir: "Lefkoşa",
    hizLimiti: 50,
    tur: "Sabit Hız Radarı",
    turEn: "Fixed Speed Camera",
    yon: "Ortaköy - Hastane İstikameti",
    yonEn: "Ortakoy - Hospital Direction",
    aciklama: "Devlet hastanesi kavşağı civarı, yoğun yaya bölgesi.",
    aciklamaEn: "Near State Hospital junction, high pedestrian zone.",
    lat: 35.2036,
    lon: 33.3361,
    mesafe: "2.1 km"
  },
  {
    id: "RAD-03",
    ad: "Hamitköy Çevre Yolu",
    adEn: "Hamitkoy Ring Road",
    sehir: "Lefkoşa",
    hizLimiti: 65,
    tur: "Sabit Hız Radarı",
    turEn: "Fixed Speed Camera",
    yon: "Lefkoşa - Gazimağusa Anayolu",
    yonEn: "Lefkosa - Famagusta Highway",
    aciklama: "Hamitköy ışıkları sonrası çevre yolu bağlantısı.",
    aciklamaEn: "Ring road link past Hamitkoy junction lights.",
    lat: 35.2155,
    lon: 33.3880,
    mesafe: "4.3 km"
  },
  {
    id: "RAD-04",
    ad: "Haspolat - UKÜ Kavşağı",
    adEn: "Haspolat - CIU Junction",
    sehir: "Lefkoşa",
    hizLimiti: 65,
    tur: "Sabit Hız Radarı",
    turEn: "Fixed Speed Camera",
    yon: "Çift Yönlü",
    yonEn: "Both Directions",
    aciklama: "Uluslararası Kıbrıs Üniversitesi alt geçidi yakını.",
    aciklamaEn: "Near Cyprus International University underpass.",
    lat: 35.2168,
    lon: 33.4350,
    mesafe: "6.7 km"
  },
  {
    id: "RAD-05",
    ad: "Metehan Sınır Kapısı Yolu",
    adEn: "Metehan Border Crossing Road",
    sehir: "Lefkoşa",
    hizLimiti: 50,
    tur: "Sabit Hız & Güvenlik",
    turEn: "Speed & Surveillance",
    yon: "Kermiya - Metehan Yolu",
    yonEn: "Kermiya - Metehan Road",
    aciklama: "Sınır kapısına gidiş güzergahında hız denetimi.",
    aciklamaEn: "Speed control route leading to the crossing.",
    lat: 35.1795,
    lon: 33.3210,
    mesafe: "3.2 km"
  },
  {
    id: "RAD-06",
    ad: "Boğaz Yolu (St. Hilarion Kavşağı)",
    adEn: "Bogaz Highway (St. Hilarion)",
    sehir: "Girne",
    hizLimiti: 65,
    tur: "Sabit Hız Radarı",
    turEn: "Fixed Speed Camera",
    yon: "Lefkoşa - Girne Çift Yön",
    yonEn: "Lefkosa - Kyrenia Both Ways",
    aciklama: "Boğaz dağ yolu viraj çıkışı, piknik alanı civarı.",
    aciklamaEn: "Bogaz mountain road curve exit, picnic area.",
    lat: 35.2785,
    lon: 33.2845,
    mesafe: "11.2 km"
  },
  {
    id: "RAD-07",
    ad: "Girne Çevre Yolu (Alsancak Girişi)",
    adEn: "Kyrenia Ring Road (Alsancak Entry)",
    sehir: "Girne",
    hizLimiti: 50,
    tur: "Sabit Hız Radarı",
    turEn: "Fixed Speed Camera",
    yon: "Alsancak - Girne İstikameti",
    yonEn: "Alsancak - Kyrenia Direction",
    aciklama: "Çevre yolu batı kavşağı bağlantısı.",
    aciklamaEn: "Ring road west intersection link.",
    lat: 35.3370,
    lon: 33.2510,
    mesafe: "16.4 km"
  },
  {
    id: "RAD-08",
    ad: "Karaoğlanoğlu Caddesi (GAÜ Girişi)",
    adEn: "Karaoglanoglu Ave (GAU Entry)",
    sehir: "Girne",
    hizLimiti: 50,
    tur: "Kırmızı Işık & Hız Kamerası",
    turEn: "Red Light & Speed Camera",
    yon: "Girne Merkez - Karaoğlanoğlu",
    yonEn: "Kyrenia Center - Karaoglanoglu",
    aciklama: "Girne Amerikan Üniversitesi kavşak ışıkları.",
    aciklamaEn: "Girne American University intersection signals.",
    lat: 35.3395,
    lon: 33.2980,
    mesafe: "14.8 km"
  },
  {
    id: "RAD-09",
    ad: "Doğanköy - Bellapais Yolu",
    adEn: "Dogankoy - Bellapais Road",
    sehir: "Girne",
    hizLimiti: 50,
    tur: "Sabit Hız Radarı",
    turEn: "Fixed Speed Camera",
    yon: "Doğanköy Çıkışı",
    yonEn: "Dogankoy Exit",
    aciklama: "Bellapais manastırı yönündeki tırmanış arteri.",
    aciklamaEn: "Climbing artery towards Bellapais Abbey.",
    lat: 35.3230,
    lon: 33.3540,
    mesafe: "15.9 km"
  },
  {
    id: "RAD-10",
    ad: "DAÜ Girişi - Salamis Yolu",
    adEn: "EMU Entry - Salamis Road",
    sehir: "Gazimağusa",
    hizLimiti: 50,
    tur: "Kırmızı Işık & Hız Kamerası",
    turEn: "Red Light & Speed Camera",
    yon: "Salamis Yolu - DAÜ Çemberi",
    yonEn: "Salamis Road - EMU Circle",
    aciklama: "Doğu Akdeniz Üniversitesi ana giriş ışıkları.",
    aciklamaEn: "Eastern Mediterranean University main entrance lights.",
    lat: 35.1450,
    lon: 33.9140,
    mesafe: "48.0 km"
  },
  {
    id: "RAD-11",
    ad: "Dörtyol Çemberi (Anayol)",
    adEn: "Dortyol Roundabout (Highway)",
    sehir: "Gazimağusa",
    hizLimiti: 65,
    tur: "Sabit Hız Radarı",
    turEn: "Fixed Speed Camera",
    yon: "Lefkoşa - Mağusa Çift Yön",
    yonEn: "Lefkosa - Famagusta Both Ways",
    aciklama: "Dörtyol kavşağı öncesi hız düşürme radarı.",
    aciklamaEn: "Speed reduction radar prior to Dortyol junction.",
    lat: 35.1865,
    lon: 33.7510,
    mesafe: "32.5 km"
  },
  {
    id: "RAD-12",
    ad: "Glapsides Çemberi Girişi",
    adEn: "Glapsides Beach Entrance",
    sehir: "Gazimağusa",
    hizLimiti: 50,
    tur: "Sabit Hız Radarı",
    turEn: "Fixed Speed Camera",
    yon: "Mağusa - İskele Sahil Yolu",
    yonEn: "Famagusta - Iskele Coast Road",
    aciklama: "Glapsides plaj kavşağı sahil ana arteri.",
    aciklamaEn: "Coast artery near Glapsides beach junction.",
    lat: 35.1880,
    lon: 33.9050,
    mesafe: "51.2 km"
  },
  {
    id: "RAD-13",
    ad: "Geçitkale - Tatlısu Yol Ayrımı",
    adEn: "Gecitkale - Tatlisu Junction",
    sehir: "Gazimağusa",
    hizLimiti: 75,
    tur: "Sabit Hız Radarı",
    turEn: "Fixed Speed Camera",
    yon: "Kuzey Sahil Yolu Bağlantısı",
    yonEn: "North Coast Link",
    aciklama: "Tatlısu sahil yoluna inen virajlı geçit.",
    aciklamaEn: "Pass connecting towards Tatlisu northern coast.",
    lat: 35.2750,
    lon: 33.7520,
    mesafe: "38.0 km"
  },
  {
    id: "RAD-14",
    ad: "Yılmazköy Düzlüğü",
    adEn: "Yilmazkoy Straight",
    sehir: "Güzelyurt",
    hizLimiti: 75,
    tur: "Sabit Hız Radarı",
    turEn: "Fixed Speed Camera",
    yon: "Lefkoşa - Güzelyurt Çift Yön",
    yonEn: "Lefkosa - Guzelyurt Both Ways",
    aciklama: "Uzun düzlük güzergahında çift yönlü hız denetimi.",
    aciklamaEn: "Dual-direction speed enforcement on the long straight.",
    lat: 35.2065,
    lon: 33.1580,
    mesafe: "18.3 km"
  },
  {
    id: "RAD-15",
    ad: "Kalkanlı Yolu (ODTÜ Güzergahı)",
    adEn: "Kalkanli Road (METU Route)",
    sehir: "Güzelyurt",
    hizLimiti: 65,
    tur: "Sabit Hız Radarı",
    turEn: "Fixed Speed Camera",
    yon: "Güzelyurt - Kalkanlı İstikameti",
    yonEn: "Guzelyurt - Kalkanli Route",
    aciklama: "ODTÜ Kuzey Kıbrıs Kampüsü anayolu üzeri.",
    aciklamaEn: "Along the METU Northern Cyprus campus route.",
    lat: 35.2180,
    lon: 33.0230,
    mesafe: "28.5 km"
  },
  {
    id: "RAD-16",
    ad: "Lefke Cengiz Topel Anıtı Yolu",
    adEn: "Lefke Cengiz Topel Memorial Road",
    sehir: "Lefke",
    hizLimiti: 50,
    tur: "Sabit Hız Radarı",
    turEn: "Fixed Speed Camera",
    yon: "Lefke Girişi",
    yonEn: "Lefke Entrance",
    aciklama: "Lefke Avrupa Üniversitesi ve sahil bağlantı yolu.",
    aciklamaEn: "European University of Lefke coastal connector.",
    lat: 35.1210,
    lon: 32.8450,
    mesafe: "62.0 km"
  },
  {
    id: "RAD-17",
    ad: "İskele Boğaz Sahil Yolu",
    adEn: "Iskele Bogaz Coast Road",
    sehir: "İskele",
    hizLimiti: 65,
    tur: "Sabit Hız Radarı",
    turEn: "Fixed Speed Camera",
    yon: "İskele - Karpaz Anayolu",
    yonEn: "Iskele - Karpaz Main Highway",
    aciklama: "Boğaz balıkçı barınağı civarı sahil şeridi denetimi.",
    aciklamaEn: "Coastal speed enforcement near Bogaz harbor.",
    lat: 35.3120,
    lon: 33.9510,
    mesafe: "68.5 km"
  },
  {
    id: "RAD-18",
    ad: "Ercan Havalimanı Yonca Kavşağı",
    adEn: "Ercan Airport Cloverleaf Junction",
    sehir: "Lefkoşa",
    hizLimiti: 65,
    tur: "Sabit Hız & Şerit Takip",
    turEn: "Fixed Speed & Lane Tracking",
    yon: "Havalimanı Çıkış & Giriş",
    yonEn: "Airport Inbound & Outbound",
    aciklama: "Yeni Ercan terminal bağlantı köprüsü virajı.",
    aciklamaEn: "New Ercan terminal access flyover curve.",
    lat: 35.1585,
    lon: 33.5020,
    mesafe: "14.2 km"
  }
];

// ==========================================
// 🌐 ÇOKLU DİL MOTORU (TR / EN)
// ==========================================
let currentLang = 'tr';

const translations = {
  tr: {
    nav: {
      subtitle: "E-Trafik & Navigasyon",
      map: "Canlı Radar Haritası",
      simulation: "Rota Simülatörü",
      calculator: "2026 Ceza Hesapla",
      features: "Özellikler",
      download: "İndir",
      getApk: "APK İndir"
    },
    hero: {
      badge: "KKTC E-Trafik & Radar Sistemi v2.4.0 Yayında",
      title1: "Kuzey Kıbrıs'ın",
      title2: "En Akıllı Sabit Radar &",
      title3: "Trafik Kokpiti",
      desc: "Lefkoşa, Girne, Gazimağusa, Güzelyurt ve tüm KKTC anayollarındaki 112+ sabit radar noktası, canlı hız ikazı, Google Maps kalitesinde azalan navigasyon ve 2026 güncel asgari ücret ceza tarifesi parmaklarınızın ucunda.",
      freeDownload: "Ücretsiz İndir",
      liveMapBtn: "Canlı Haritayı Aç",
      statRadars: "Sabit Radar & Kamera",
      statLatency: "GPS Gecikmesi",
      statFines: "Resmi Ceza Tarifesi",
      statSupport: "Acil Yol Yardımı"
    },
    map: {
      tag: "Canlı Veri Tabanı",
      title: "KKTC İnteraktif Sabit Radar Haritası",
      desc: "Lefkoşa, Girne, Mağusa, Güzelyurt ve Lefke'deki tüm sabit hız kameralarını harita üzerinde anlık görüntüleyin, hız limitlerini ve olası ceza oranlarını inceleyin.",
      searchPlaceholder: "Radar adı, bölge veya cadde ara (örn: Gönyeli, Boğaz, Hastane)...",
      filterAll: "Tüm Bölgeler",
      speedAll: "Tüm Limitler",
      radarList: "Radar Noktaları"
    },
    sim: {
      tag: "Canlı Önizleme & Test",
      title: "Gerçek Zamanlı Sürüş Navigasyon Simülatörü",
      desc: "Koltukta otururken KKTC rotalarında test sürüşü yapın; dinamik azalan süreyi, hız uyarısını ve yaklaşan radar ikazlarını tarayıcınızda deneyimleyin.",
      startBtn: "Simülasyonu Başlat",
      pauseBtn: "Simülasyonu Duraklat",
      resetBtn: "Sıfırla",
      remainingTime: "Kalan Süre (ETA)",
      remainingDist: "Kalan Mesafe",
      arrivalTime: "Tahmini Varış"
    },
    calc: {
      tag: "Yasal Ceza Tarifesi",
      title: "KKTC 2026 Trafik Cezası & Ceza Puanı Hesaplayıcı",
      desc: "KKTC Trafik Yasası uyarınca trafik cezaları resmi brüt asgari ücrete göre belirlenir. Hızınızı girerek ceza tutarını ve ceza puanını anında hesaplayın.",
      violationType: "Trafik İhlali Türü:",
      roadLimit: "Yol Hız Limiti (km/s):",
      driverSpeed: "Sürüş Hızınız (km/s):",
      speedSlider: "Hız Aşımını Kaydırıcıyla Ayarlayın:",
      fineAmount: "Ceza Tutarı:",
      penaltyPoints: "Ehliyet Ceza Puanı:",
      wageBasis: "Hesaplama, 2026 KKTC Resmi Brüt Asgari Ücreti (35.180 ₺) oranları baz alınarak otomatik yapılmaktadır."
    }
  },
  en: {
    nav: {
      subtitle: "E-Traffic & Navigation",
      map: "Live Radar Map",
      simulation: "Route Simulator",
      calculator: "2026 Fine Calculator",
      features: "Features",
      download: "Download",
      getApk: "Download APK"
    },
    hero: {
      badge: "TRNC E-Traffic & Radar System v2.4.0 Live",
      title1: "Northern Cyprus'",
      title2: "Smartest Speed Radar &",
      title3: "Traffic Cockpit",
      desc: "112+ fixed speed camera locations across Lefkosa, Kyrenia, Famagusta, Guzelyurt, live speed warnings, Google Maps style decrementing navigation, and official 2026 fine calculators.",
      freeDownload: "Free Download",
      liveMapBtn: "Open Live Map",
      statRadars: "Fixed Radars & Cameras",
      statLatency: "GPS Latency",
      statFines: "Official 2026 Fines",
      statSupport: "24/7 Road Assistance"
    },
    map: {
      tag: "Live Database",
      title: "TRNC Interactive Speed Radar Map",
      desc: "View all fixed speed cameras across Lefkosa, Kyrenia, Famagusta, Guzelyurt, and Lefke on an interactive map. Check speed limits and penalty tariffs.",
      searchPlaceholder: "Search radar, area or street (e.g. Gonyeli, Bogaz, Hospital)...",
      filterAll: "All Districts",
      speedAll: "All Limits",
      radarList: "Radar Cameras"
    },
    sim: {
      tag: "Live Preview & Test",
      title: "Real-Time Drive Navigation Simulator",
      desc: "Take a test drive along TRNC highways right in your browser; experience dynamically decrementing ETA, speed radar alerts, and turn instructions.",
      startBtn: "Start Simulation",
      pauseBtn: "Pause Simulation",
      resetBtn: "Reset",
      remainingTime: "Remaining Time (ETA)",
      remainingDist: "Remaining Distance",
      arrivalTime: "Est. Arrival"
    },
    calc: {
      tag: "Legal Penalties",
      title: "TRNC 2026 Traffic Fine & Penalty Point Calculator",
      desc: "Traffic fines in TRNC are indexed to the official gross minimum wage. Calculate your exact fine amount in TL and license penalty points.",
      violationType: "Traffic Violation Type:",
      roadLimit: "Speed Limit (km/h):",
      driverSpeed: "Your Driving Speed (km/h):",
      speedSlider: "Adjust Speed with Slider:",
      fineAmount: "Fine Amount:",
      penaltyPoints: "Penalty Points:",
      wageBasis: "Calculations are dynamically derived from the official 2026 TRNC Gross Minimum Wage (35,180 ₺)."
    }
  }
};

function setLanguage(lang) {
  currentLang = lang;
  const t = translations[lang];
  
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.getAttribute('data-i18n');
    const parts = key.split('.');
    let val = t;
    for (const p of parts) {
      if (val && val[p]) val = val[p];
      else { val = null; break; }
    }
    if (val) el.textContent = val;
  });

  document.querySelectorAll('[data-i18n-placeholder]').forEach(el => {
    const key = el.getAttribute('data-i18n-placeholder');
    const parts = key.split('.');
    let val = t;
    for (const p of parts) {
      if (val && val[p]) val = val[p];
      else { val = null; break; }
    }
    if (val) el.setAttribute('placeholder', val);
  });

  const langBtn = document.getElementById('langToggle');
  if (langBtn) {
    langBtn.innerHTML = lang === 'tr' 
      ? '<span class="lang-flag">🇹🇷</span> <span class="lang-text">TR</span>' 
      : '<span class="lang-flag">🇬🇧</span> <span class="lang-text">EN</span>';
  }

  // Haritadaki radar listesini mevcut dile göre yenile
  renderRadarList(kktcRadarlar);
  updateFineCalculator();
}

// ==========================================
// 🗺️ LEAFLET HARİTA KURULUMU
// ==========================================
let map;
let markersLayer;
let currentFilteredRadars = [...kktcRadarlar];

function initLeafletMap() {
  const mapElement = document.getElementById('kktcLeafletMap');
  if (!mapElement) return;

  // Haritayı Lefkoşa merkezli başlat
  map = L.map('kktcLeafletMap', {
    center: [35.22, 33.36],
    zoom: 10,
    zoomControl: true,
    scrollWheelZoom: false
  });

  // %100 Ücretsiz, API Key İstemeyen Resmi OpenStreetMap ve Esri Uydu Katmanları
  const osmHarita = L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
    maxZoom: 19
  });

  const esriUydu = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
    attribution: '&copy; Esri, Maxar, Earthstar Geographics',
    maxZoom: 18
  });

  // Varsayılan olarak OpenStreetMap başlat
  osmHarita.addTo(map);

  // Sağ üste katman değiştirici ekle (Sokak / Uydu)
  L.control.layers({
    "🗺️ Sokak Haritası": osmHarita,
    "🛰️ Canlı Uydu": esriUydu
  }, null, { position: 'topright' }).addTo(map);

  markersLayer = L.layerGroup().addTo(map);

  renderRadarMarkers(kktcRadarlar);
  renderRadarList(kktcRadarlar);
}

function createRadarIcon(speed) {
  let borderColor = '#38BDF8';
  if (speed === 65) borderColor = '#10B981';
  if (speed >= 75) borderColor = '#EF4444';

  const html = `
    <div style="
      width: 32px;
      height: 32px;
      background: #FFFFFF;
      border: 3px solid ${borderColor};
      border-radius: 50%;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      box-shadow: 0 4px 12px rgba(0,0,0,0.5);
      font-family: 'Outfit', sans-serif;
      font-weight: 900;
      color: #000;
      font-size: 11px;
      line-height: 1;
    ">
      ${speed}
    </div>
  `;

  return L.divIcon({
    html: html,
    className: 'custom-radar-pin',
    iconSize: [32, 32],
    iconAnchor: [16, 16]
  });
}

function renderRadarMarkers(radars) {
  if (!markersLayer) return;
  markersLayer.clearLayers();

  radars.forEach(radar => {
    const marker = L.marker([radar.lat, radar.lon], {
      icon: createRadarIcon(radar.hizLimiti),
      title: radar.ad
    });

    const isEn = currentLang === 'en';
    const title = isEn ? radar.adEn : radar.ad;
    const type = isEn ? radar.turEn : radar.tur;
    const desc = isEn ? radar.aciklamaEn : radar.aciklama;
    const direction = isEn ? radar.yonEn : radar.yon;

    const popupContent = `
      <div style="font-family: 'Inter', sans-serif; min-width: 200px; padding: 4px;">
        <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:6px;">
          <strong style="font-size:13px; color:#0F172A;">${title}</strong>
          <span style="background:#EF4444; color:#FFF; font-size:10px; font-weight:800; padding:2px 6px; border-radius:4px;">${radar.hizLimiti} km/s</span>
        </div>
        <p style="font-size:11px; color:#475569; margin-bottom:4px;"><strong>${isEn ? 'Type:' : 'Tür:'}</strong> ${type}</p>
        <p style="font-size:11px; color:#475569; margin-bottom:4px;"><strong>${isEn ? 'Direction:' : 'Yön:'}</strong> ${direction}</p>
        <p style="font-size:11px; color:#64748B; margin-bottom:8px;">${desc}</p>
        <button onclick="zoomToRadar(${radar.lat}, ${radar.lon})" style="
          width:100%;
          background:#10B981;
          color:#FFF;
          border:none;
          padding:6px;
          border-radius:6px;
          font-weight:700;
          font-size:11px;
          cursor:pointer;
        ">
          ${isEn ? 'Focus Location' : 'Konuma Odaklan'}
        </button>
      </div>
    `;

    marker.bindPopup(popupContent);
    markersLayer.addLayer(marker);
  });
}

function renderRadarList(radars) {
  const container = document.getElementById('radarListContainer');
  const counter = document.getElementById('radarCounter');
  if (!container) return;

  if (counter) {
    counter.textContent = `${radars.length} ${currentLang === 'en' ? 'Points' : 'Nokta'}`;
  }

  container.innerHTML = '';

  if (radars.length === 0) {
    container.innerHTML = `
      <div style="text-align:center; padding:30px 10px; color:#94A3B8; font-size:0.9rem;">
        <i class="fa-solid fa-filter-circle-xmark" style="font-size:1.8rem; margin-bottom:10px; display:block;"></i>
        ${currentLang === 'en' ? 'No radars found matching the criteria.' : 'Kriterlere uygun radar noktası bulunamadı.'}
      </div>
    `;
    return;
  }

  radars.forEach(radar => {
    const isEn = currentLang === 'en';
    const card = document.createElement('div');
    card.className = 'radar-card-item';
    card.onclick = () => {
      zoomToRadar(radar.lat, radar.lon);
      document.querySelectorAll('.radar-card-item').forEach(c => c.classList.remove('selected'));
      card.classList.add('selected');
    };

    card.innerHTML = `
      <div class="radar-speed-badge">
        ${radar.hizLimiti}
        <span>km/s</span>
      </div>
      <div class="radar-card-info">
        <h4 class="radar-card-title">${isEn ? radar.adEn : radar.ad}</h4>
        <div class="radar-card-meta">
          <span><i class="fa-solid fa-location-dot"></i> ${radar.sehir}</span>
          <span>•</span>
          <span><i class="fa-solid fa-arrows-split-up-and-left"></i> ${isEn ? radar.yonEn : radar.yon}</span>
        </div>
        <p class="radar-card-desc">${isEn ? radar.aciklamaEn : radar.aciklama}</p>
      </div>
    `;

    container.appendChild(card);
  });
}

window.zoomToRadar = function(lat, lon) {
  if (!map) return;
  map.setView([lat, lon], 14, { animate: true, duration: 1 });
  markersLayer.eachLayer(layer => {
    const pos = layer.getLatLng();
    if (Math.abs(pos.lat - lat) < 0.0001 && Math.abs(pos.lng - lon) < 0.0001) {
      layer.openPopup();
    }
  });
};

// ==========================================
// 🔍 ARAMA & FİLTRELEME MANTIĞI
// ==========================================
function filterRadars() {
  const searchVal = document.getElementById('radarSearchInput').value.toLowerCase().trim();
  const activeCity = document.querySelector('#cityFilter .pill.active')?.getAttribute('data-city') || 'all';
  const activeSpeed = document.querySelector('#speedFilter .speed-pill.active')?.getAttribute('data-speed') || 'all';

  currentFilteredRadars = kktcRadarlar.filter(r => {
    // Şehir filtresi
    const matchesCity = activeCity === 'all' || r.sehir.toLowerCase() === activeCity.toLowerCase();
    
    // Hız filtresi
    const matchesSpeed = activeSpeed === 'all' || r.hizLimiti.toString() === activeSpeed;

    // Metin araması
    const matchesSearch = !searchVal || 
      r.ad.toLowerCase().includes(searchVal) ||
      r.adEn.toLowerCase().includes(searchVal) ||
      r.sehir.toLowerCase().includes(searchVal) ||
      r.aciklama.toLowerCase().includes(searchVal);

    return matchesCity && matchesSpeed && matchesSearch;
  });

  renderRadarMarkers(currentFilteredRadars);
  renderRadarList(currentFilteredRadars);

  const clearBtn = document.getElementById('clearSearchBtn');
  if (clearBtn) {
    clearBtn.style.display = searchVal ? 'block' : 'none';
  }
}

// ==========================================
// 🚗 SÜRÜŞ SİMÜLATÖRÜ DEMO MOTORU
// ==========================================
const mockRoutes = {
  lefkosa_girne: {
    name: "Lefkoşa ➔ Girne Dağ Yolu",
    totalKm: 28.4,
    totalMinutes: 32,
    speedLimit: 65,
    maneuvers: [
      { text: "Dr. Fazıl Küçük Bulvarı yönünde ilerleyin", dist: 800, icon: "fa-arrow-up" },
      { text: "Boğaz virajlarına yaklaşılıyor - Hızınızı düşürün", dist: 1200, icon: "fa-arrow-turn-up fa-rotate-270" },
      { text: "St. Hilarion Kavşağı Sabit Radarını Geçin", dist: 450, icon: "fa-camera", isRadar: true, radarSpeed: 65 },
      { text: "Girne Çevre Yolu çemberinden 2. çıkışa girin", dist: 3500, icon: "fa-rotate-right" }
    ]
  },
  lefkosa_ercan: {
    name: "Lefkoşa ➔ Ercan Havalimanı",
    totalKm: 24.2,
    totalMinutes: 22,
    speedLimit: 65,
    maneuvers: [
      { text: "Hamitköy çevre yolundan Yonca Kavşağı yönüne ilerleyin", dist: 1400, icon: "fa-arrow-up" },
      { text: "Hamitköy Sabit Radarına Yaklaşıyorsunuz", dist: 500, icon: "fa-camera", isRadar: true, radarSpeed: 65 },
      { text: "Haspolat UKÜ üst geçidini takip edin", dist: 2800, icon: "fa-arrow-turn-up fa-rotate-90" },
      { text: "Ercan Yeni Terminal Bağlantı Yoluna Girin", dist: 4200, icon: "fa-plane" }
    ]
  },
  guzelyurt_lefkosa: {
    name: "Güzelyurt ➔ Lefkoşa",
    totalKm: 38.0,
    totalMinutes: 35,
    speedLimit: 75,
    maneuvers: [
      { text: "Güzelyurt çıkışı bölünmüş anayolunda ilerleyin", dist: 2000, icon: "fa-arrow-up" },
      { text: "Yılmazköy Düzlüğü Çift Yönlü Radar Denetimi", dist: 600, icon: "fa-camera", isRadar: true, radarSpeed: 75 },
      { text: "Alayköy kavşağına doğru devam edin", dist: 4500, icon: "fa-arrow-up" }
    ]
  },
  lefkosa_magusa: {
    name: "Lefkoşa ➔ Gazimağusa",
    totalKm: 58.5,
    totalMinutes: 52,
    speedLimit: 65,
    maneuvers: [
      { text: "Haspolat - Demirhan düzlüğünde ilerleyin", dist: 3000, icon: "fa-arrow-up" },
      { text: "Dörtyol Çemberi Radar Noktası • Limit 65 km/s", dist: 450, icon: "fa-camera", isRadar: true, radarSpeed: 65 },
      { text: "DAÜ / Salamis Yolu Kavşağına Sola Dönün", dist: 5200, icon: "fa-arrow-turn-up fa-rotate-270" }
    ]
  }
};

let simInterval = null;
let simProgress = 0.0;
let isSimRunning = false;

// Web Audio API ile Gerçek Zamanlı Radar Siren Sesi Sentezleyici
function playRadarBeepSound() {
  try {
    const AudioContext = window.AudioContext || window.webkitAudioContext;
    if (!AudioContext) return;
    const ctx = new AudioContext();
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();

    osc.type = 'sawtooth';
    osc.frequency.setValueAtTime(880, ctx.currentTime); // 880 Hz
    osc.frequency.exponentialRampToValueAtTime(440, ctx.currentTime + 0.25);

    gain.gain.setValueAtTime(0.2, ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.25);

    osc.connect(gain);
    gain.connect(ctx.destination);

    osc.start();
    osc.stop(ctx.currentTime + 0.28);
  } catch (e) {
    // Tarayıcı otomatik ses çalma kısıtlaması
  }
}

function startSimulation() {
  const routeKey = document.getElementById('routeSelect').value;
  const route = mockRoutes[routeKey] || mockRoutes.lefkosa_girne;

  const startBtn = document.getElementById('startSimBtn');
  const resetBtn = document.getElementById('resetSimBtn');

  if (isSimRunning) {
    // Duraklat
    clearInterval(simInterval);
    isSimRunning = false;
    startBtn.innerHTML = `<i class="fa-solid fa-play"></i> <span>${currentLang === 'en' ? 'Resume Simulation' : 'Simülasyonu Sürdür'}</span>`;
    return;
  }

  isSimRunning = true;
  startBtn.innerHTML = `<i class="fa-solid fa-pause"></i> <span>${currentLang === 'en' ? 'Pause Simulation' : 'Simülasyonu Duraklat'}</span>`;
  resetBtn.style.display = 'inline-flex';

  simInterval = setInterval(() => {
    simProgress += 0.015;

    if (simProgress >= 1.0) {
      simProgress = 1.0;
      clearInterval(simInterval);
      isSimRunning = false;
      startBtn.innerHTML = `<i class="fa-solid fa-flag-checkered"></i> <span>${currentLang === 'en' ? 'Arrived!' : 'Hedefe Ulaşıldı!'}</span>`;
      updateCockpitUI(route, 1.0);
      return;
    }

    updateCockpitUI(route, simProgress);
  }, 300);
}

function resetSimulation() {
  clearInterval(simInterval);
  isSimRunning = false;
  simProgress = 0.0;
  
  const startBtn = document.getElementById('startSimBtn');
  const resetBtn = document.getElementById('resetSimBtn');

  startBtn.innerHTML = `<i class="fa-solid fa-play"></i> <span>${currentLang === 'en' ? 'Start Simulation' : 'Simülasyonu Başlat'}</span>`;
  resetBtn.style.display = 'none';

  const routeKey = document.getElementById('routeSelect').value;
  const route = mockRoutes[routeKey] || mockRoutes.lefkosa_girne;
  updateCockpitUI(route, 0.0);
}

function updateCockpitUI(route, progress) {
  // Kullanıcının özellikle istediği Google Maps dinamik azalan sayaç:
  const remainingRatio = Math.max(0.0, 1.0 - progress);
  const remainingKm = (route.totalKm * remainingRatio).toFixed(1);
  const remainingMinutes = Math.round(route.totalMinutes * remainingRatio);

  // Varış Saati (Şimdiki zaman + kalan dakika)
  const now = new Date();
  now.setMinutes(now.getMinutes() + remainingMinutes);
  const arrivalStr = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`;

  // Göstergeleri Güncelle
  const remainingTimeEl = document.getElementById('simRemainingTime');
  const remainingDistEl = document.getElementById('simRemainingDist');
  const arrivalTimeEl = document.getElementById('simArrivalTime');

  if (remainingTimeEl) remainingTimeEl.textContent = remainingMinutes <= 0 ? (currentLang === 'en' ? 'Arrived' : 'Ulaşıldı') : `${remainingMinutes} dk`;
  if (remainingDistEl) remainingDistEl.textContent = `${remainingKm} km`;
  if (arrivalTimeEl) arrivalTimeEl.textContent = arrivalStr;

  // Hız Dalgalanması
  const speeds = [62, 64, 66, 68, 70, 65, 63, 67];
  const simSpeed = progress >= 1.0 ? 0 : speeds[Math.floor(Math.random() * speeds.length)];
  const speedValEl = document.getElementById('simSpeedVal');
  const gaugeEl = document.getElementById('simGauge');
  const speedStatusEl = document.getElementById('simSpeedStatus');

  if (speedValEl) speedValEl.textContent = simSpeed;
  if (gaugeEl) {
    if (simSpeed > route.speedLimit) {
      gaugeEl.classList.add('over-limit');
      if (speedStatusEl) {
        speedStatusEl.textContent = currentLang === 'en' ? '⚠️ OVER LIMIT' : '⚠️ HIZ AŞIMI';
        speedStatusEl.style.color = '#EF4444';
      }
    } else {
      gaugeEl.classList.remove('over-limit');
      if (speedStatusEl) {
        speedStatusEl.textContent = currentLang === 'en' ? 'Safe Speed' : 'Güvenli Sürüş';
        speedStatusEl.style.color = '#10B981';
      }
    }
  }

  // Manevra Adımı & Radar Algılayıcı
  const mIndex = Math.min(route.maneuvers.length - 1, Math.floor(progress * route.maneuvers.length));
  const currentM = route.maneuvers[mIndex];
  
  const turnIconEl = document.getElementById('simTurnIcon');
  const turnDistEl = document.getElementById('simTurnDist');
  const turnInstEl = document.getElementById('simTurnInst');
  const radarDetectorEl = document.getElementById('simRadarDetector');
  const radarStatusTextEl = document.getElementById('simRadarStatusText');

  if (turnIconEl) turnIconEl.innerHTML = `<i class="fa-solid ${currentM.icon}"></i>`;
  if (turnInstEl) turnInstEl.textContent = currentM.text;

  // Kalan manevra mesafesi
  const stepDist = Math.max(25, Math.round(currentM.dist * (1.0 - ((progress * route.maneuvers.length) % 1))));
  if (turnDistEl) turnDistEl.textContent = `${stepDist} m`;

  // Radar Dedektörü Uyarısı
  if (currentM.isRadar && stepDist <= 800) {
    if (radarDetectorEl) radarDetectorEl.classList.add('danger');
    if (radarStatusTextEl) {
      radarStatusTextEl.textContent = currentLang === 'en' 
        ? `🚨 RADAR DETECTED • ${stepDist}m Remaining (Limit: ${currentM.radarSpeed})` 
        : `🚨 RADAR TESPİT EDİLDİ • ${stepDist}m Kaldı (Limit: ${currentM.radarSpeed} km/s)`;
    }
    // Sesli uyarı
    playRadarBeepSound();
  } else {
    if (radarDetectorEl) radarDetectorEl.classList.remove('danger');
    if (radarStatusTextEl) {
      radarStatusTextEl.textContent = currentLang === 'en' ? 'Radar sensor active • No hazard ahead' : 'Radar sensörü aktif • İleride radar yok';
    }
  }

  // Mockup telefonundaki göstergeleri de eş zamanlı oynat
  const mockEtaDk = document.getElementById('mockEtaDk');
  const mockEtaKm = document.getElementById('mockEtaKm');
  const mockSpeedVal = document.getElementById('mockSpeedVal');
  const mockTurnDist = document.getElementById('mockTurnDist');

  if (mockEtaDk) mockEtaDk.textContent = `${remainingMinutes} dk`;
  if (mockEtaKm) mockEtaKm.textContent = `${remainingKm} km • ${arrivalStr} Varış`;
  if (mockSpeedVal) mockSpeedVal.textContent = simSpeed;
  if (mockTurnDist) mockTurnDist.textContent = `${stepDist} m`;
}

// ==========================================
// 💰 2026 KKTC CEZA HESAPLAYICI MOTORU
// ==========================================
const KKTC_BRUT_ASGARI_UCRET_2026 = 35180; // TL

function updateFineCalculator() {
  const violationType = document.getElementById('violationType').value;
  const speedParamsGroup = document.getElementById('speedParamsGroup');
  const roadLimit = parseInt(document.getElementById('roadLimitSelect').value, 10);
  const driverSpeed = parseInt(document.getElementById('driverSpeedInput').value, 10);

  const resultBadge = document.getElementById('resultStatusBadge');
  const fineAmountTL = document.getElementById('fineAmountTL');
  const finePointsVal = document.getElementById('finePointsVal');
  const fineDesc = document.getElementById('fineDescription');

  const isEn = currentLang === 'en';

  if (violationType === 'speed') {
    if (speedParamsGroup) speedParamsGroup.style.display = 'block';

    const excessSpeed = driverSpeed - roadLimit;
    const sliderBadge = document.getElementById('sliderBadge');
    if (sliderBadge) {
      sliderBadge.textContent = excessSpeed > 0 ? `Limit +${excessSpeed} km/s` : (isEn ? 'Within Limit' : 'Limit İçi');
      sliderBadge.style.background = excessSpeed > 0 ? 'rgba(239, 68, 68, 0.2)' : 'rgba(16, 185, 129, 0.2)';
      sliderBadge.style.color = excessSpeed > 0 ? '#F87171' : '#34D399';
    }

    if (excessSpeed <= 0) {
      // Ceza yok
      resultBadge.className = 'result-badge safe';
      resultBadge.textContent = isEn ? 'SAFE DRIVING' : 'CEZA YOK (GÜVENLİ)';
      fineAmountTL.textContent = '0 ₺';
      fineAmountTL.style.color = '#10B981';
      finePointsVal.textContent = isEn ? '0 Points' : '0 Puan';
      fineDesc.textContent = isEn 
        ? 'Your speed is compliant with the speed limit. Have a safe journey!' 
        : 'Hızınız yasal sınır dahilinde. Güvenli sürüşler!';
      return;
    }

    resultBadge.className = 'result-badge danger';
    resultBadge.textContent = isEn ? 'FINE APPLIES' : 'CEZA KAPSAMINDA';
    fineAmountTL.style.color = '#EF4444';

    if (excessSpeed <= 20) {
      // 1-20 km/s aşım: Asgari ücretin %10'u, 5 Ceza Puanı
      const fine = Math.round(KKTC_BRUT_ASGARI_UCRET_2026 * 0.10);
      fineAmountTL.textContent = `${fine.toLocaleString('tr-TR')} ₺`;
      finePointsVal.textContent = isEn ? '5 Points' : '5 Puan';
      fineDesc.textContent = isEn
        ? `Speed exceeded by up to 20 km/h (10% of gross minimum wage). Payable within 15 days.`
        : `Hız sınırını 20 km/s'ye kadar aştınız (Brüt Asgari Ücretin %10'u). 15 gün içinde ödenirse mahkemeye sevk edilmez.`;
    } else if (excessSpeed <= 40) {
      // 21-40 km/s aşım: Asgari ücretin %15'i, 25 Ceza Puanı
      const fine = Math.round(KKTC_BRUT_ASGARI_UCRET_2026 * 0.15);
      fineAmountTL.textContent = `${fine.toLocaleString('tr-TR')} ₺`;
      finePointsVal.textContent = isEn ? '25 Points' : '25 Puan';
      fineDesc.textContent = isEn
        ? `Speed exceeded between 20-40 km/h (15% of gross minimum wage). High risk of license suspension on repeat.`
        : `Hız sınırını 20-40 km/s arasında aştınız (Brüt Asgari Ücretin %15'i). 15 gün içinde ödenmelidir.`;
    } else {
      // 40+ km/s aşım: Asgari ücretin %25'i, 50 Ceza Puanı + Mahkeme
      const fine = Math.round(KKTC_BRUT_ASGARI_UCRET_2026 * 0.25);
      fineAmountTL.textContent = `${fine.toLocaleString('tr-TR')} ₺`;
      finePointsVal.textContent = isEn ? '50 Points + Court' : '50 Puan + Mahkeme';
      fineDesc.textContent = isEn
        ? `Extreme speeding (+40 km/h). 25% minimum wage fine and mandatory court appearance for reckless driving.`
        : `Hız sınırını 40 km/s'den fazla aştınız (Brüt Asgari Ücretin %25'i). Ağır kusur kapsamında mahkemeye sevk ve ehliyete el konulma riski!`;
    }
  } else {
    // Diğer İhlaller
    if (speedParamsGroup) speedParamsGroup.style.display = 'none';
    resultBadge.className = 'result-badge danger';
    resultBadge.textContent = isEn ? 'FINE APPLIES' : 'CEZA KAPSAMINDA';
    fineAmountTL.style.color = '#EF4444';

    if (violationType === 'phone') {
      const fine = Math.round(KKTC_BRUT_ASGARI_UCRET_2026 * 0.10);
      fineAmountTL.textContent = `${fine.toLocaleString('tr-TR')} ₺`;
      finePointsVal.textContent = isEn ? '15 Points' : '15 Puan';
      fineDesc.textContent = isEn ? 'Mobile phone usage while operating vehicle (10% of minimum wage).' : 'Seyir halinde elde cep telefonuyla konuşma veya mesajlaşma (Asgari ücretin %10\'u).';
    } else if (violationType === 'belt') {
      const fine = Math.round(KKTC_BRUT_ASGARI_UCRET_2026 * 0.10);
      fineAmountTL.textContent = `${fine.toLocaleString('tr-TR')} ₺`;
      finePointsVal.textContent = isEn ? '5 Points' : '5 Puan';
      fineDesc.textContent = isEn ? 'Driving without wearing a safety seatbelt.' : 'Sürücünün veya yolcuların emniyet kemeri takmaması (Asgari ücretin %10\'u).';
    } else if (violationType === 'red_light') {
      const fine = Math.round(KKTC_BRUT_ASGARI_UCRET_2026 * 0.20);
      fineAmountTL.textContent = `${fine.toLocaleString('tr-TR')} ₺`;
      finePointsVal.textContent = isEn ? '30 Points' : '30 Puan';
      fineDesc.textContent = isEn ? 'Running a red traffic light signal.' : 'Kırmızı ışıkta durmayarak geçiş yapma ihlali (Asgari ücretin %20\'si).';
    } else if (violationType === 'alcohol') {
      const fine = Math.round(KKTC_BRUT_ASGARI_UCRET_2026 * 0.50);
      fineAmountTL.textContent = `${fine.toLocaleString('tr-TR')} ₺`;
      finePointsVal.textContent = isEn ? '50 Points + 3 Months Ban' : '50 Puan + 3 Ay Men';
      fineDesc.textContent = isEn ? 'Driving under influence of alcohol (50-100 promil).' : '50-100 promil arası alkollü araç kullanımı. Araca el konur ve sürücü mahkemeye sevk edilir.';
    } else if (violationType === 'inspection') {
      const fine = Math.round(KKTC_BRUT_ASGARI_UCRET_2026 * 0.10);
      fineAmountTL.textContent = `${fine.toLocaleString('tr-TR')} ₺`;
      finePointsVal.textContent = isEn ? '0 Points' : '0 Puan';
      fineDesc.textContent = isEn ? 'Operating an uninspected vehicle or without road tax.' : 'Muayenesi veya seyrüsefer ruhsatı yenilenmemiş araçla trafiğe çıkış.';
    }
  }
}

// ==========================================
// 🚀 EVENT LISTENERS & SAYFA BAŞLATMA
// ==========================================
document.addEventListener('DOMContentLoaded', () => {
  // 1. Haritayı Başlat
  initLeafletMap();

  // 2. Dil Butonu
  const langToggleBtn = document.getElementById('langToggle');
  if (langToggleBtn) {
    langToggleBtn.addEventListener('click', () => {
      setLanguage(currentLang === 'tr' ? 'en' : 'tr');
    });
  }

  // 3. Mobil Menü Toggle
  const mobileToggle = document.getElementById('mobileToggle');
  const navMenu = document.getElementById('navMenu');
  if (mobileToggle && navMenu) {
    mobileToggle.addEventListener('click', () => {
      navMenu.classList.toggle('active');
    });

    document.querySelectorAll('.nav-link').forEach(link => {
      link.addEventListener('click', () => navMenu.classList.remove('active'));
    });
  }

  // 4. Arama Çubuğu
  const searchInput = document.getElementById('radarSearchInput');
  const clearBtn = document.getElementById('clearSearchBtn');
  if (searchInput) {
    searchInput.addEventListener('input', filterRadars);
  }
  if (clearBtn) {
    clearBtn.addEventListener('click', () => {
      searchInput.value = '';
      filterRadars();
    });
  }

  // 5. Şehir Filtre Butonları
  document.querySelectorAll('#cityFilter .pill').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('#cityFilter .pill').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      filterRadars();
    });
  });

  // 6. Hız Limiti Filtre Butonları
  document.querySelectorAll('#speedFilter .speed-pill').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('#speedFilter .speed-pill').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      filterRadars();
    });
  });

  // 7. Simülasyon Kontrolleri
  const startSimBtn = document.getElementById('startSimBtn');
  const resetSimBtn = document.getElementById('resetSimBtn');
  const routeSelect = document.getElementById('routeSelect');

  if (startSimBtn) startSimBtn.addEventListener('click', startSimulation);
  if (resetSimBtn) resetSimBtn.addEventListener('click', resetSimulation);
  if (routeSelect) routeSelect.addEventListener('change', resetSimulation);

  // 8. Ceza Hesaplayıcı Kontrolleri
  const violationType = document.getElementById('violationType');
  const roadLimitSelect = document.getElementById('roadLimitSelect');
  const driverSpeedInput = document.getElementById('driverSpeedInput');
  const speedSlider = document.getElementById('speedSlider');

  if (violationType) violationType.addEventListener('change', updateFineCalculator);
  if (roadLimitSelect) roadLimitSelect.addEventListener('change', updateFineCalculator);

  if (driverSpeedInput && speedSlider) {
    driverSpeedInput.addEventListener('input', () => {
      speedSlider.value = driverSpeedInput.value;
      updateFineCalculator();
    });

    speedSlider.addEventListener('input', () => {
      driverSpeedInput.value = speedSlider.value;
      updateFineCalculator();
    });
  }

  // 9. SSS Accordion
  document.querySelectorAll('.faq-question').forEach(btn => {
    btn.addEventListener('click', () => {
      const item = btn.closest('.faq-item');
      const isOpen = item.classList.contains('open');

      document.querySelectorAll('.faq-item').forEach(i => i.classList.remove('open'));
      if (!isOpen) item.classList.add('open');
    });
  });

  // İlk hesaplama kurulumu
  updateFineCalculator();
});
