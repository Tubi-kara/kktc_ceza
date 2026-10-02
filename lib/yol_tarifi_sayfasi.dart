import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'radar_haritasi.dart';
import 'kktc_gov_sync_service.dart';
import 'yardim_rehberi_sayfasi.dart';
import 'canli_gps_servisi.dart';

// ==========================================
// 🎨 NAVİGASYON VE HARİTA TASARIM TOKENLARI (İNSAN DOSTU & SADE)
// ==========================================
class NavHtmlColors {
  // Apple Haritalar & Google Haritalar tarzı göz dinlendiren, şık ve doğal koyu tema
  static const Color background = Color(0xFF0F172A); // Doğal Slate 900
  static const Color surfaceContainer = Color(0xFF1E293B); // Slate 800
  static const Color surfaceContainerLow = Color(0xFF162032);
  static const Color surfaceContainerLowest = Color(0xFF0B1120);
  static const Color surfaceContainerHigh = Color(0xFF243248);
  static const Color surfaceContainerHighest = Color(0xFF334155);
  static const Color surfaceBright = Color(0xFF3B4A63);
  static const Color primaryContainer = Color(0xFFE11D48); // Zarif KKTC Kırmızısı
  static const Color primary = Color(0xFF38BDF8); // Canlı gök mavisi
  static const Color primaryFixedDim = Color(0xFF7DD3FC);
  static const Color secondary = Color(0xFF94A3B8); // Yumuşak gümüş gri
  static const Color tertiary = Color(0xFF10B981); // Doğal akıcı yeşil (neon değil)
  static const Color tertiaryContainer = Color(0xFF065F46);
  static const Color onSurface = Color(0xFFF8FAFC); // Yumuşak doğal beyaz
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFF59E0B); // Sıcak kehribar sarısı

  // 🚦 Gerçek Canlı Trafik Renkleri
  static const Color trafficClear = Color(0xFF22C55E); // Akıcı / Yeşil
  static const Color trafficModerate = Color(0xFFF59E0B); // Orta Yoğunluk / Kehribar
  static const Color trafficHeavy = Color(0xFFEF4444); // Sıkışık / Kırmızı
  static const Color trafficGridlock = Color(0xFF991B1B); // Dur-Kalk / Koyu Bordo
}

// ==========================================
// 🚦 CANLI TRAFİK VE KALABALIK NOKTA MODELİ
// ==========================================
class KktcTrafikNoktasi {
  final String id;
  final String ad;
  final String adEn;
  final String bolge;
  final double lat;
  final double lon;
  final int yogunlukYuzde; // 0 - 100
  final int gecikmeDakika; // Gecikme süresi (dakika)
  final String durum; // "Akıcı", "Orta Yoğunluk", "Ağır Trafik", "Kuyruk"
  final String durumEn;
  final String aciklama;
  final String aciklamaEn;
  final IconData ikon;

  const KktcTrafikNoktasi({
    required this.id,
    required this.ad,
    required this.adEn,
    required this.bolge,
    required this.lat,
    required this.lon,
    required this.yogunlukYuzde,
    required this.gecikmeDakika,
    required this.durum,
    required this.durumEn,
    required this.aciklama,
    required this.aciklamaEn,
    this.ikon = Icons.traffic_rounded,
  });

  Color get renk {
    if (yogunlukYuzde >= 75) return NavHtmlColors.trafficHeavy;
    if (yogunlukYuzde >= 45) return NavHtmlColors.trafficModerate;
    return NavHtmlColors.trafficClear;
  }

  String get seviyeEtiketi {
    if (yogunlukYuzde >= 75) return "Ağır";
    if (yogunlukYuzde >= 45) return "Orta";
    return "Akıcı";
  }
}

// KKTC Gerçek Kritik Trafik ve Kalabalık Noktaları
final List<KktcTrafikNoktasi> kktcTrafikVeritabani = [
  const KktcTrafikNoktasi(
    id: "gonyeli_cemberi",
    ad: "Gönyeli Çemberi & Hastane Kavşağı",
    adEn: "Gonyeli Roundabout & Hospital Jct",
    bolge: "Lefkoşa",
    lat: 35.2078,
    lon: 33.3085,
    yogunlukYuzde: 84,
    gecikmeDakika: 5,
    durum: "Ağır Trafik (Dur-Kalk)",
    durumEn: "Heavy Stop & Go",
    aciklama: "Çember girişlerinde yoğun kuyruk var. Kuzey Çevre Yolu alternatifi önerilir.",
    aciklamaEn: "Long vehicle queues at circle entry. North Bypass recommended.",
    ikon: Icons.traffic_rounded,
  ),
  const KktcTrafikNoktasi(
    id: "metehan_kermiya",
    ad: "Kermiya (Metehan) Sınır Kapısı",
    adEn: "Metehan / Kermiya Border Crossing",
    bolge: "Lefkoşa",
    lat: 35.1830,
    lon: 33.3320,
    yogunlukYuzde: 90,
    gecikmeDakika: 12,
    durum: "Sınır Araç Kuyruğu",
    durumEn: "Border Checkpoint Queue",
    aciklama: "Güney Kıbrıs geçiş şeridinde kimlik kontrolleri nedeniyle uzun kuyruk var.",
    aciklamaEn: "Extensive vehicle queue due to checkpoint identity processing.",
    ikon: Icons.hourglass_top_rounded,
  ),
  const KktcTrafikNoktasi(
    id: "lefkosa_dereboyu",
    ad: "Lefkoşa Dereboyu (Mehmet Akif Cd.)",
    adEn: "Dereboyu Avenue (Mehmet Akif St.)",
    bolge: "Lefkoşa",
    lat: 35.1910,
    lon: 33.3540,
    yogunlukYuzde: 70,
    gecikmeDakika: 4,
    durum: "Yavaş Akış & Park Yoğunluğu",
    durumEn: "Slow Flow & Parking Queue",
    aciklama: "Şehir içi mağaza ve kafe trafiği nedeniyle akış ağır ilerliyor.",
    aciklamaEn: "Slow crawl traffic due to active commercial and roadside parking.",
    ikon: Icons.directions_car_filled_rounded,
  ),
  const KktcTrafikNoktasi(
    id: "girne_bogaz",
    ad: "Girne Boğaz Tepe Geçişi",
    adEn: "Kyrenia Bogaz Mountain Pass",
    bolge: "Girne",
    lat: 35.2910,
    lon: 33.3080,
    yogunlukYuzde: 55,
    gecikmeDakika: 3,
    durum: "Orta Yoğunluk (Virajlı)",
    durumEn: "Moderate Traffic (Winding)",
    aciklama: "Dağ tırmanışında ağır vasıtalar sebebiyle hız zaman zaman 40 km/s'ye düşüyor.",
    aciklamaEn: "Uphill trucks on serpentine pass intermittently slow traffic down.",
    ikon: Icons.terrain_rounded,
  ),
  const KktcTrafikNoktasi(
    id: "girne_liman_giris",
    ad: "Girne Yeni Liman & Çarşı Çemberi",
    adEn: "Kyrenia Harbor & Downtown Circle",
    bolge: "Girne",
    lat: 35.3340,
    lon: 33.3280,
    yogunlukYuzde: 78,
    gecikmeDakika: 5,
    durum: "Kalabalık Şehir İçi",
    durumEn: "Congested Downtown",
    aciklama: "Antik Liman ve sahil kordonuna inen cadde üzerinde araç birikmesi var.",
    aciklamaEn: "High congestion along narrow corridors towards historic harbor.",
    ikon: Icons.sailing_rounded,
  ),
  const KktcTrafikNoktasi(
    id: "alsancak_sahil",
    ad: "Alsancak Sahil Yolu & Oteller",
    adEn: "Alsancak Coastal Road & Hotels",
    bolge: "Girne",
    lat: 35.3510,
    lon: 33.2250,
    yogunlukYuzde: 60,
    gecikmeDakika: 3,
    durum: "Orta Yoğunluk",
    durumEn: "Moderate Density",
    aciklama: "Plaj girişleri ve otel servisleri nedeniyle yerel yavaşlamalar görülüyor.",
    aciklamaEn: "Hotel shuttles and beach traffic causing localized slows.",
    ikon: Icons.beach_access_rounded,
  ),
  const KktcTrafikNoktasi(
    id: "kuzey_cevre_yolu",
    ad: "Lefkoşa Kuzey Çevre Yolu",
    adEn: "Lefkosa North Bypass Freeway",
    bolge: "Lefkoşa",
    lat: 35.2280,
    lon: 33.3350,
    yogunlukYuzde: 15,
    gecikmeDakika: 0,
    durum: "Tamamen Açık & Akıcı",
    durumEn: "Completely Clear & Fast",
    aciklama: "Işıksız, çift şerit, kesintisiz hızlı akış. En rahat çevre koridoru.",
    aciklamaEn: "Uninterrupted dual carriageway with zero signals. Highly fluent.",
    ikon: Icons.bolt_rounded,
  ),
  const KktcTrafikNoktasi(
    id: "haspolat_kavsagi",
    ad: "Haspolat - UKÜ Kavşağı",
    adEn: "Haspolat - CIU Junction",
    bolge: "Lefkoşa",
    lat: 35.2160,
    lon: 33.4320,
    yogunlukYuzde: 28,
    gecikmeDakika: 0,
    durum: "Akıcı Trafik",
    durumEn: "Flowing Traffic",
    aciklama: "Mağusa anayolu kesintisiz akıyor, hız limitlerine uyarak seyredin.",
    aciklamaEn: "Smooth transit along Famagusta highway corridor.",
    ikon: Icons.check_circle_outline_rounded,
  ),
  const KktcTrafikNoktasi(
    id: "erulku_girisi",
    ad: "Demirhan - Erülkü Süpermarket Girişi",
    adEn: "Demirhan - Erulku Supermarket Jct",
    bolge: "Lefkoşa",
    lat: 35.2185,
    lon: 33.4800,
    yogunlukYuzde: 42,
    gecikmeDakika: 2,
    durum: "Girişte Hafif Yavaşlama",
    durumEn: "Minor Turn Delays",
    aciklama: "Süpermarket otoparkı ve benzin istasyonu girişinde dönüş yapan araçlar.",
    aciklamaEn: "Short queue for vehicles entering shopping parking and fuel stalls.",
    ikon: Icons.shopping_bag_rounded,
  ),
  const KktcTrafikNoktasi(
    id: "guzelyurt_cember",
    ad: "Güzelyurt Giriş Çemberi",
    adEn: "Guzelyurt Entrance Roundabout",
    bolge: "Güzelyurt",
    lat: 35.1980,
    lon: 32.9950,
    yogunlukYuzde: 20,
    gecikmeDakika: 0,
    durum: "Akıcı & Rahat",
    durumEn: "Clear & Smooth",
    aciklama: "Kalkanlı ve Lefkoşa yönü açık, trafik sorunsuz seyrediyor.",
    aciklamaEn: "Clear arterial road towards METU Kalkanli and Lefkosa.",
    ikon: Icons.done_all_rounded,
  ),
  const KktcTrafikNoktasi(
    id: "magusa_anit_cemberi",
    ad: "Gazimağusa Anıt Çemberi & DAÜ",
    adEn: "Famagusta Monument Circle & EMU",
    bolge: "Gazimağusa",
    lat: 35.1260,
    lon: 33.9350,
    yogunlukYuzde: 65,
    gecikmeDakika: 4,
    durum: "Yoğun Kavşak",
    durumEn: "Busy Roundabout",
    aciklama: "Üniversite çıkışı ve Salamis yolu bağlantısında yoğun araç akışı.",
    aciklamaEn: "Student transit and Salamis strip connection causing delays.",
    ikon: Icons.school_rounded,
  ),
];


// ==========================================
// 📍 GERÇEK GPS VE ROTA NOKTASI MODELLERİ
// ==========================================
class OsrmRoutePoint {
  final double lat;
  final double lon;
  const OsrmRoutePoint(this.lat, this.lon);
}

class RotaNoktasi {
  final String id;
  final String ad;
  final String adEn;
  final String kisaAd;
  final String bolge;
  final double lat; // Gerçek GPS Enlem
  final double lon; // Gerçek GPS Boylam
  final IconData ikon;

  const RotaNoktasi({
    required this.id,
    required this.ad,
    required this.adEn,
    required this.kisaAd,
    required this.bolge,
    required this.lat,
    required this.lon,
    required this.ikon,
  });
}

// KKTC Sürüş & Trafik Odaklı Noktalar Veritabanı (Gerçek GPS Koordinatlarıyla)
// Yalnızca Benzinlik, Lastik & Tamir, Otopark, Hastane ve Ana Ulaşım Arterleri
final List<RotaNoktasi> kktcNoktalari = [
  // ==========================================
  // ⛽ 1. BENZİN İSTASYONLARI (K-PET, ALPET, ALTINBAŞ)
  // ==========================================
  const RotaNoktasi(
    id: "poi-kpet-gonyeli",
    ad: "K-Pet Gönyeli Çemberi İstasyonu",
    adEn: "K-Pet Gonyeli Roundabout Station",
    kisaAd: "K-Pet Gönyeli",
    bolge: "Lefkoşa",
    lat: 35.2105,
    lon: 33.3102,
    ikon: Icons.local_gas_station_rounded,
  ),
  const RotaNoktasi(
    id: "poi-alpet-dereboyu",
    ad: "Alpet Mehmet Akif Caddesi İstasyonu (Dereboyu)",
    adEn: "Alpet Dereboyu Station",
    kisaAd: "Alpet Dereboyu",
    bolge: "Lefkoşa",
    lat: 35.1950,
    lon: 33.3520,
    ikon: Icons.local_gas_station_rounded,
  ),
  const RotaNoktasi(
    id: "poi-kpet-ortakoy",
    ad: "K-Pet Ortaköy Devlet Hastanesi İstasyonu",
    adEn: "K-Pet Ortakoy State Hospital Station",
    kisaAd: "K-Pet Ortaköy",
    bolge: "Lefkoşa",
    lat: 35.2010,
    lon: 33.3320,
    ikon: Icons.local_gas_station_rounded,
  ),
  const RotaNoktasi(
    id: "poi-kpet-alsancak",
    ad: "K-Pet Girne Alsancak Çevre Yolu İstasyonu",
    adEn: "K-Pet Kyrenia Alsancak Station",
    kisaAd: "K-Pet Alsancak",
    bolge: "Girne",
    lat: 35.3480,
    lon: 33.2450,
    ikon: Icons.local_gas_station_rounded,
  ),
  const RotaNoktasi(
    id: "poi-alpet-bogaz",
    ad: "Alpet Boğaz Dağ Yolu Dinlenme Tesisi",
    adEn: "Alpet Bogaz Mountain Pass Station",
    kisaAd: "Alpet Boğaz",
    bolge: "Girne",
    lat: 35.2950,
    lon: 33.3120,
    ikon: Icons.local_gas_station_rounded,
  ),
  const RotaNoktasi(
    id: "poi-alpet-dogankoy",
    ad: "Alpet Girne Çevre Yolu Doğanköy İstasyonu",
    adEn: "Alpet Kyrenia Bypass Dogankoy Station",
    kisaAd: "Alpet Doğanköy",
    bolge: "Girne",
    lat: 35.3310,
    lon: 33.3280,
    ikon: Icons.local_gas_station_rounded,
  ),
  const RotaNoktasi(
    id: "poi-altinbas-magusa",
    ad: "Altınbaş Petrol Gazimağusa Girişi",
    adEn: "Altinbas Petrol Famagusta Entry",
    kisaAd: "Altınbaş Mağusa",
    bolge: "Gazimağusa",
    lat: 35.1380,
    lon: 33.9180,
    ikon: Icons.local_gas_station_rounded,
  ),
  const RotaNoktasi(
    id: "poi-kpet-magusa",
    ad: "K-Pet Gazimağusa Giriş (Anıt Çemberi) İstasyonu",
    adEn: "K-Pet Famagusta Monument Roundabout Station",
    kisaAd: "K-Pet Mağusa Anıt",
    bolge: "Gazimağusa",
    lat: 35.1290,
    lon: 33.9280,
    ikon: Icons.local_gas_station_rounded,
  ),
  const RotaNoktasi(
    id: "poi-kpet-guzelyurt",
    ad: "K-Pet Güzelyurt Çevre Yolu İstasyonu",
    adEn: "K-Pet Guzelyurt Bypass Station",
    kisaAd: "K-Pet Güzelyurt",
    bolge: "Güzelyurt",
    lat: 35.1960,
    lon: 32.9910,
    ikon: Icons.local_gas_station_rounded,
  ),
  const RotaNoktasi(
    id: "poi-kpet-ercan",
    ad: "K-Pet Ercan Havalimanı Kavşağı İstasyonu",
    adEn: "K-Pet Ercan Airport Junction",
    kisaAd: "K-Pet Ercan",
    bolge: "Lefkoşa",
    lat: 35.1620,
    lon: 33.5020,
    ikon: Icons.local_gas_station_rounded,
  ),
  const RotaNoktasi(
    id: "poi-altinbas-iskele",
    ad: "Altınbaş Petrol İskele İstasyonu",
    adEn: "Altinbas Petrol Iskele Station",
    kisaAd: "Altınbaş İskele",
    bolge: "İskele",
    lat: 35.2910,
    lon: 33.9050,
    ikon: Icons.local_gas_station_rounded,
  ),
  const RotaNoktasi(
    id: "poi-alpet-gemikonagi",
    ad: "Alpet Lefke Gemikonağı İstasyonu",
    adEn: "Alpet Lefke Gemikonagi Station",
    kisaAd: "Alpet Gemikonağı",
    bolge: "Lefke",
    lat: 35.1480,
    lon: 32.8520,
    ikon: Icons.local_gas_station_rounded,
  ),

  // ==========================================
  // 🔧 2. OTO LASTİK & TAMİR & YOL YARDIM (7/24)
  // ==========================================
  const RotaNoktasi(
    id: "poi-lastik-lefkosa",
    ad: "Lefkoşa Sanayi 7/24 Lastik & Akü Yol Yardım",
    adEn: "Lefkosa Industrial 7/24 Tire & Battery Service",
    kisaAd: "Lefkoşa Lastikçi",
    bolge: "Lefkoşa",
    lat: 35.2180,
    lon: 33.3620,
    ikon: Icons.build_circle_rounded,
  ),
  const RotaNoktasi(
    id: "poi-lastik-girne",
    ad: "Girne Alsancak Oto Servis & Mobil Lastikçi",
    adEn: "Kyrenia Alsancak Tire & Auto Repair Service",
    kisaAd: "Girne Lastikçi",
    bolge: "Girne",
    lat: 35.3420,
    lon: 33.2350,
    ikon: Icons.build_circle_rounded,
  ),
  const RotaNoktasi(
    id: "poi-lastik-magusa",
    ad: "Gazimağusa Sanayi Lastik & Yol Yardım Servisi",
    adEn: "Famagusta Industrial Tire & Recovery Service",
    kisaAd: "Mağusa Lastikçi",
    bolge: "Gazimağusa",
    lat: 35.1320,
    lon: 33.9210,
    ikon: Icons.build_circle_rounded,
  ),
  const RotaNoktasi(
    id: "poi-lastik-guzelyurt",
    ad: "Güzelyurt Sanayi Oto Lastik & Tamir Servisi",
    adEn: "Guzelyurt Industrial Tire & Auto Repair",
    kisaAd: "Güzelyurt Lastikçi",
    bolge: "Güzelyurt",
    lat: 35.2010,
    lon: 32.9960,
    ikon: Icons.build_circle_rounded,
  ),

  // ==========================================
  // 🅿️ 3. OTOPARKLAR
  // ==========================================
  const RotaNoktasi(
    id: "poi-otopark-lefkosa",
    ad: "Lefkoşa Ledra Palace Yanı Belediye Otoparkı",
    adEn: "Lefkosa Municipal Parking (Ledra Palace)",
    kisaAd: "Lefkoşa Otoparkı",
    bolge: "Lefkoşa",
    lat: 35.1785,
    lon: 33.3560,
    ikon: Icons.local_parking_rounded,
  ),
  const RotaNoktasi(
    id: "poi-otopark-girne",
    ad: "Girne Antik Liman Katlı Belediye Otoparkı",
    adEn: "Kyrenia Multi-storey Municipal Parking",
    kisaAd: "Girne Otoparkı",
    bolge: "Girne",
    lat: 35.3425,
    lon: 33.3205,
    ikon: Icons.local_parking_rounded,
  ),
  const RotaNoktasi(
    id: "poi-otopark-magusa",
    ad: "Gazimağusa Suriçi Belediye Otoparkı",
    adEn: "Famagusta Walled City Municipal Parking",
    kisaAd: "Mağusa Otoparkı",
    bolge: "Gazimağusa",
    lat: 35.1245,
    lon: 33.9410,
    ikon: Icons.local_parking_rounded,
  ),

  // ==========================================
  // 🏥 4. DEVLET HASTANELERİ & ACİL SERVİSLER (7/24)
  // ==========================================
  const RotaNoktasi(
    id: "poi-hastane-lefkosa",
    ad: "Dr. Burhan Nalbantoğlu Devlet Hastanesi Acil (112)",
    adEn: "Dr. Burhan Nalbantoglu State Hospital Emergency",
    kisaAd: "Lefkoşa Acil Hastanesi",
    bolge: "Lefkoşa",
    lat: 35.2036,
    lon: 33.3361,
    ikon: Icons.local_hospital_rounded,
  ),
  const RotaNoktasi(
    id: "poi-hastane-girne",
    ad: "Girne Dr. Akçiçek Devlet Hastanesi Acil Servis",
    adEn: "Kyrenia Dr. Akcicek State Hospital Emergency",
    kisaAd: "Girne Acil Hastanesi",
    bolge: "Girne",
    lat: 35.3360,
    lon: 33.3190,
    ikon: Icons.local_hospital_rounded,
  ),
  const RotaNoktasi(
    id: "poi-hastane-magusa",
    ad: "Gazimağusa Devlet Hastanesi Acil Servis",
    adEn: "Famagusta State Hospital Emergency Service",
    kisaAd: "Mağusa Acil Hastanesi",
    bolge: "Gazimağusa",
    lat: 35.1480,
    lon: 33.9080,
    ikon: Icons.local_hospital_rounded,
  ),
  const RotaNoktasi(
    id: "poi-hastane-cengiztopel",
    ad: "Cengiz Topel Devlet Hastanesi Acil (Lefke)",
    adEn: "Cengiz Topel State Hospital Emergency (Lefke)",
    kisaAd: "Cengiz Topel Hastanesi",
    bolge: "Lefke",
    lat: 35.1380,
    lon: 32.8360,
    ikon: Icons.local_hospital_rounded,
  ),

  // ==========================================
  // 🚗 5. ANA TRAFİK VE ULAŞIM ARTERLERİ
  // ==========================================
  const RotaNoktasi(
    id: "ercan_havalimani",
    ad: "Ercan Uluslararası Havalimanı (Yeni Terminal)",
    adEn: "Ercan International Airport (New Terminal)",
    kisaAd: "Ercan Havalimanı",
    bolge: "Lefkoşa",
    lat: 35.1585,
    lon: 33.5015,
    ikon: Icons.flight_takeoff_rounded,
  ),
  const RotaNoktasi(
    id: "gonyeli_cemberi",
    ad: "Gönyeli Çemberi & Kuzey Çevre Yolu Kavşağı",
    adEn: "Gonyeli Roundabout & North Bypass",
    kisaAd: "Gönyeli Çemberi",
    bolge: "Lefkoşa",
    lat: 35.2078,
    lon: 33.3085,
    ikon: Icons.traffic_rounded,
  ),
  const RotaNoktasi(
    id: "girne_liman",
    ad: "Girne Liman & Çevre Yolu Kavşağı",
    adEn: "Kyrenia Harbor & Bypass Junction",
    kisaAd: "Girne Liman Kavşağı",
    bolge: "Girne",
    lat: 35.3340,
    lon: 33.3280,
    ikon: Icons.directions_boat_rounded,
  ),
  const RotaNoktasi(
    id: "lefkosa_dereboyu",
    ad: "Lefkoşa Dereboyu Caddesi (Mehmet Akif Cad.)",
    adEn: "Lefkosa Dereboyu Avenue",
    kisaAd: "Lefkoşa Dereboyu",
    bolge: "Lefkoşa",
    lat: 35.1920,
    lon: 33.3510,
    ikon: Icons.location_city_rounded,
  ),
  const RotaNoktasi(
    id: "guzelyurt_merkez",
    ad: "Güzelyurt Terminal & Kent Meydanı",
    adEn: "Guzelyurt Terminal & Center",
    kisaAd: "Güzelyurt Merkez",
    bolge: "Güzelyurt",
    lat: 35.1980,
    lon: 32.9930,
    ikon: Icons.directions_bus_rounded,
  ),
  const RotaNoktasi(
    id: "metehan_sinir",
    ad: "Metehan (Kermiya) Sınır Kapısı",
    adEn: "Metehan Border Crossing",
    kisaAd: "Metehan Sınır",
    bolge: "Lefkoşa",
    lat: 35.1795,
    lon: 33.3210,
    ikon: Icons.security_rounded,
  ),
];

// ==========================================
// 🛣️ ADIM ADIM MANEVRA MODELİ
// ==========================================
class RotaManevraAdimi {
  final IconData ikon;
  final String baslik;
  final String baslikEn;
  final String aciklama;
  final String aciklamaEn;
  final String mesafe;
  final double? lat;
  final double? lon;
  final double? mesafeMetre;
  final RadarKamerasi? bagliRadar;
  final bool onemliMi;

  const RotaManevraAdimi({
    required this.ikon,
    required this.baslik,
    required this.baslikEn,
    required this.aciklama,
    required this.aciklamaEn,
    required this.mesafe,
    this.lat,
    this.lon,
    this.mesafeMetre,
    this.bagliRadar,
    this.onemliMi = false,
  });
}

// ==========================================
// 🗺️ HESAPLANMIŞ ROTA VERİSİ
// ==========================================
class HesaplanmisRota {
  final RotaNoktasi baslangic;
  final RotaNoktasi varis;
  final String secenekAdi;
  final String secenekAdiEn;
  final double mesafeKm;
  final int tahminiDakika;
  final String kolaylikOzeti;
  final String kolaylikOzetiEn;
  final List<RadarKamerasi> radarlar;
  final List<RotaManevraAdimi> manevralar;
  final List<OsrmRoutePoint> gpsNoktalari; // Gerçek Enlem/Boylam yol noktaları
  final List<KktcTrafikNoktasi> trafikNoktalari; // Güzergahtaki canlı trafik ve kalabalık noktalar
  final String genelTrafikDurumu;
  final String genelTrafikDurumuEn;
  final int toplamGecikmeDakika;

  const HesaplanmisRota({
    required this.baslangic,
    required this.varis,
    required this.secenekAdi,
    required this.secenekAdiEn,
    required this.mesafeKm,
    required this.tahminiDakika,
    required this.kolaylikOzeti,
    required this.kolaylikOzetiEn,
    required this.radarlar,
    required this.manevralar,
    required this.gpsNoktalari,
    this.trafikNoktalari = const [],
    this.genelTrafikDurumu = '',
    this.genelTrafikDurumuEn = '',
    this.toplamGecikmeDakika = 0,
  });
}

// ==========================================
// 🌐 CANLI OSRM & OPENSTREETMAP ROTA SERVİSİ
// ==========================================
class OsrmRotaSonucu {
  final List<OsrmRoutePoint> points;
  final List<RotaManevraAdimi> manevralar;
  final double? mesafeKm;
  final int? sureDakika;

  const OsrmRotaSonucu({
    required this.points,
    required this.manevralar,
    this.mesafeKm,
    this.sureDakika,
  });
}

class CanliOsrmServisi {
  static final Map<String, OsrmRotaSonucu> _onbellek = {};

  static Future<OsrmRotaSonucu?> rotaCek({
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
  }) async {
    final cacheKey = '$startLat,$startLon-$endLat,$endLon';
    if (_onbellek.containsKey(cacheKey)) {
      return _onbellek[cacheKey];
    }

    HttpClient? client;
    try {
      client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
      client.userAgent = 'KktcCezaApp/1.0';
      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/$startLon,$startLat;$endLon,$endLat?overview=full&geometries=geojson&steps=true',
      );
      final req = await client.getUrl(uri);
      final resp = await req.close().timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200) {
        final body = await resp.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        final routes = json['routes'] as List<dynamic>?;
        if (routes != null && routes.isNotEmpty) {
          final firstRoute = routes[0] as Map<String, dynamic>;
          final double rawDist = (firstRoute['distance'] as num?)?.toDouble() ?? 0.0;
          final double rawDur = (firstRoute['duration'] as num?)?.toDouble() ?? 0.0;
          final double km = (rawDist / 1000.0);
          final int dk = (rawDur / 60.0).round();

          final geom = firstRoute['geometry'] as Map<String, dynamic>?;
          final coords = geom?['coordinates'] as List<dynamic>?;
          List<OsrmRoutePoint> points = [];
          if (coords != null && coords.isNotEmpty) {
            points = coords.map((c) {
              final lon = (c[0] as num).toDouble();
              final lat = (c[1] as num).toDouble();
              return OsrmRoutePoint(lat, lon);
            }).toList();
          }

          // Adım Adım Manevraları Parse Et
          List<RotaManevraAdimi> manevralar = [];
          final legs = firstRoute['legs'] as List<dynamic>?;
          if (legs != null && legs.isNotEmpty) {
            final steps = legs[0]['steps'] as List<dynamic>?;
            if (steps != null && steps.isNotEmpty) {
              for (var s in steps) {
                final maneuver = s['maneuver'] as Map<String, dynamic>?;
                final String type = maneuver?['type']?.toString().toLowerCase() ?? '';
                final String modifier = maneuver?['modifier']?.toString().toLowerCase() ?? '';
                final loc = maneuver?['location'] as List<dynamic>?;
                final double? stepLon = loc != null && loc.isNotEmpty ? (loc[0] as num).toDouble() : null;
                final double? stepLat = loc != null && loc.length > 1 ? (loc[1] as num).toDouble() : null;
                final double dist = (s['distance'] as num?)?.toDouble() ?? 0.0;
                final String name = s['name']?.toString() ?? '';

                IconData ikon = Icons.straight_rounded;
                String baslik = 'Düz Devam Edin';
                String baslikEn = 'Continue Straight';

                if (type == 'depart') {
                  ikon = Icons.navigation_rounded;
                  baslik = 'Yola Çıkın';
                  baslikEn = 'Head Out';
                } else if (type == 'arrive') {
                  ikon = Icons.place_rounded;
                  baslik = 'Hedefe Ulaştınız';
                  baslikEn = 'Arrive at Destination';
                } else if (type.contains('roundabout') || type.contains('rotary')) {
                  ikon = Icons.roundabout_right_rounded;
                  baslik = 'Döner Kavşaktan Çıkın';
                  baslikEn = 'Take Roundabout Exit';
                } else if (modifier.contains('slight left')) {
                  ikon = Icons.turn_slight_left_rounded;
                  baslik = 'Hafif Sola Dönün';
                  baslikEn = 'Slight Left';
                } else if (modifier.contains('slight right')) {
                  ikon = Icons.turn_slight_right_rounded;
                  baslik = 'Hafif Sağa Dönün';
                  baslikEn = 'Slight Right';
                } else if (modifier.contains('left')) {
                  ikon = Icons.turn_left_rounded;
                  baslik = 'Sola Dönün';
                  baslikEn = 'Turn Left';
                } else if (modifier.contains('right')) {
                  ikon = Icons.turn_right_rounded;
                  baslik = 'Sağa Dönün';
                  baslikEn = 'Turn Right';
                } else if (modifier.contains('uturn')) {
                  ikon = Icons.u_turn_left_rounded;
                  baslik = 'U Dönüşü Yapın';
                  baslikEn = 'Make U-Turn';
                }

                String mesafeMetin = dist < 1000 ? '${dist.round()} m' : '${(dist / 1000).toStringAsFixed(1)} km';
                String aciklama = name.isNotEmpty ? '$name yoluna katılın' : 'Güzergahı takip edin';
                String aciklamaEn = name.isNotEmpty ? 'Follow $name' : 'Continue along the route';

                manevralar.add(
                  RotaManevraAdimi(
                    ikon: ikon,
                    baslik: baslik,
                    baslikEn: baslikEn,
                    aciklama: aciklama,
                    aciklamaEn: aciklamaEn,
                    mesafe: mesafeMetin,
                    lat: stepLat,
                    lon: stepLon,
                    mesafeMetre: dist,
                  ),
                );
              }
            }
          }

          if (points.isNotEmpty) {
            final sonuc = OsrmRotaSonucu(
              points: points,
              manevralar: manevralar,
              mesafeKm: km,
              sureDakika: dk,
            );
            _onbellek[cacheKey] = sonuc;
            return sonuc;
          }
        }
      }
    } catch (_) {
      // Çevrimdışı durumunda yedek koordinatlar ve yerleşik manevralar kullanılır
    } finally {
      client?.close();
    }
    return null;
  }
}

// ==========================================
// 🚀 ANA YOL TARİFİ VE NAVİGASYON SAYFASI
// ==========================================
class YolTarifiSayfasi extends StatefulWidget {
  final bool turkceMi;
  final Function(bool)? onTamEkranDegisti;
  final RotaNoktasi? baslangicNoktasi;
  final RotaNoktasi? varisNoktasi;
  final bool otomatikNavigasyonBaslat;

  const YolTarifiSayfasi({
    super.key,
    required this.turkceMi,
    this.onTamEkranDegisti,
    this.baslangicNoktasi,
    this.varisNoktasi,
    this.otomatikNavigasyonBaslat = false,
  });

  @override
  State<YolTarifiSayfasi> createState() => _YolTarifiSayfasiState();
}

class _YolTarifiSayfasiState extends State<YolTarifiSayfasi>
    with SingleTickerProviderStateMixin {
  late RotaNoktasi _baslangicNoktasi;
  late RotaNoktasi _varisNoktasi;
  int _secilenRotaModu = 0; // 0 = En Kolay & Hızlı (Çevre Yolu), 1 = Şehir İçi Alternatif

  // Gerçek Google Maps Tarzı Adım Adım Navigasyon Durumları
  bool _navigasyonAktif = false;
  int _aktifManevraIndeksi = 0;
  double _mevcutManevrayaKalanMetre = 250.0;
  int _canliSurusHizi = 0;
  bool _yakinCekimModu = true; // 🌟 Dönülecek kavşakları 17.4x yakın çekim göster

  // Canlı Simülasyon Durumları (İsteğe bağlı test amaçlı)
  bool _simulasyonAktif = false;
  double _simulasyonIlerleme = 0.0;
  Timer? _simulasyonTimer;
  RadarKamerasi? _yaklasanRadar;
  double _yaklasanRadarMesafeMetre = 0.0;

  late final AnimationController _pulseController;
  List<OsrmRoutePoint>? _canliGpsRotasi;
  OsrmRotaSonucu? _canliOsrmSonucu;
  bool _canliRotaYukleniyor = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    // 1. Hedef Noktayı Belirle (Tıklanan K-Pet, POI veya Radar)
    if (widget.varisNoktasi != null) {
      _varisNoktasi = widget.varisNoktasi!;
    } else {
      _varisNoktasi = kktcNoktalari.firstWhere(
        (n) => n.id == "poi-kpet-gonyeli",
        orElse: () => kktcNoktalari[0],
      );
    }

    // 2. Başlangıç Noktasını Belirle (Kullanıcının Gerçek Canlı GPS Konumu)
    if (widget.baslangicNoktasi != null) {
      _baslangicNoktasi = widget.baslangicNoktasi!;
    } else {
      final pos = CanliGpsServisi().sonKonum;
      if (pos != null) {
        _baslangicNoktasi = RotaNoktasi(
          id: 'mevcut_gps_konum',
          ad: widget.turkceMi ? 'Mevcut Konumum' : 'My Current Location',
          adEn: 'My Current Location',
          kisaAd: widget.turkceMi ? 'Mevcut Konum' : 'Current Location',
          bolge: widget.turkceMi ? 'Canlı GPS' : 'Live GPS',
          lat: pos.latitude,
          lon: pos.longitude,
          ikon: Icons.my_location_rounded,
        );
      } else {
        _baslangicNoktasi = kktcNoktalari.firstWhere(
          (n) => n.id != _varisNoktasi.id,
          orElse: () => kktcNoktalari[0],
        );
      }
    }

    // Canlı GPS servisi dinleyicisi ekle
    CanliGpsServisi().addListener(_onGpsNavigasyonGuncelle);

    if (widget.otomatikNavigasyonBaslat) {
      CanliGpsServisi().servisiBaslat();
      _navigasyonAktif = true;
      _aktifManevraIndeksi = 0;
      _yakinCekimModu = true;
      widget.onTamEkranDegisti?.call(true);
    }

    _canliRotayiTetikle();
  }

  @override
  void dispose() {
    CanliGpsServisi().removeListener(_onGpsNavigasyonGuncelle);
    _simulasyonTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _onGpsNavigasyonGuncelle() {
    if (!mounted) return;
    if (_navigasyonAktif) {
      final pos = CanliGpsServisi().sonKonum;
      final rota = _rotaHesapla();
      final manevralar = (_canliOsrmSonucu?.manevralar.isNotEmpty ?? false)
          ? _canliOsrmSonucu!.manevralar
          : rota.manevralar;

      if (pos != null && _aktifManevraIndeksi < manevralar.length) {
        final hedefManevra = manevralar[_aktifManevraIndeksi];
        if (hedefManevra.lat != null && hedefManevra.lon != null) {
          final mesafe = Geolocator.distanceBetween(
            pos.latitude,
            pos.longitude,
            hedefManevra.lat!,
            hedefManevra.lon!,
          );
          setState(() {
            _mevcutManevrayaKalanMetre = mesafe;
            _canliSurusHizi = CanliGpsServisi().gercekHizKmh.round();
          });

          // Manevra noktasına 45m kala otomatik olarak sonraki adıma geç
          if (mesafe <= 45) {
            HapticFeedback.heavyImpact();
            SystemSound.play(SystemSoundType.alert);
            _sonrakiManevra();
          }
        } else {
          setState(() {
            _canliSurusHizi = CanliGpsServisi().gercekHizKmh.round();
          });
        }
      }
    }
  }

  void _canliRotayiTetikle() async {
    setState(() => _canliRotaYukleniyor = true);
    final res = await CanliOsrmServisi.rotaCek(
      startLat: _baslangicNoktasi.lat,
      startLon: _baslangicNoktasi.lon,
      endLat: _varisNoktasi.lat,
      endLon: _varisNoktasi.lon,
    );
    if (mounted) {
      setState(() {
        _canliOsrmSonucu = res;
        _canliGpsRotasi = res?.points;
        _canliRotaYukleniyor = false;
        _aktifManevraIndeksi = 0;
      });
    }
  }

  void _noktalariDegistir() {
    setState(() {
      final gecici = _baslangicNoktasi;
      _baslangicNoktasi = _varisNoktasi;
      _varisNoktasi = gecici;
      _durdurNavigasyon();
      _durdurSimulasyon();
    });
    _canliRotayiTetikle();
  }

  void _hazirRotaSec(String baslangicId, String varisId) {
    setState(() {
      _baslangicNoktasi = kktcNoktalari.firstWhere(
        (n) => n.id == baslangicId,
        orElse: () => kktcNoktalari[0],
      );
      _varisNoktasi = kktcNoktalari.firstWhere(
        (n) => n.id == varisId,
        orElse: () => kktcNoktalari[1],
      );
      _secilenRotaModu = 0;
      _durdurNavigasyon();
      _durdurSimulasyon();
    });
    _canliRotayiTetikle();
  }

  // 🎯 HARİTADAN DOKUNARAK HEDEF VEYA KALKIŞ AYARLAMA (TOUCH-TO-ROUTE)
  void _hedefNoktasiAyarla(RotaNoktasi yeniHedef) {
    setState(() {
      _varisNoktasi = yeniHedef;
      _secilenRotaModu = 0;
      _durdurNavigasyon();
      _durdurSimulasyon();
    });
    _canliRotayiTetikle();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.pin_drop_rounded, color: Color(0xFF10B981)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.turkceMi
                    ? '🎯 Haritada seçilen noktaya canlı rota çiziliyor...'
                    : '🎯 Calculating live route to chosen map point...',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _baslangicNoktasiAyarla(RotaNoktasi yeniBaslangic) {
    setState(() {
      _baslangicNoktasi = yeniBaslangic;
      _secilenRotaModu = 0;
      _durdurNavigasyon();
      _durdurSimulasyon();
    });
    _canliRotayiTetikle();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.trip_origin_rounded, color: Color(0xFF38BDF8)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.turkceMi
                    ? '📍 Başlangıç noktası güncellendi, canlı rota hesaplanıyor...'
                    : '📍 Start point updated, calculating live route...',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // 🧭 GERÇEK GOOGLE MAPS TARZI NAVİGASYON BAŞLATMA
  void _baslatNavigasyon() {
    CanliGpsServisi().servisiBaslat();
    final rota = _rotaHesapla();
    final manevralar = (_canliOsrmSonucu?.manevralar.isNotEmpty ?? false)
        ? _canliOsrmSonucu!.manevralar
        : rota.manevralar;

    double baslangicMesafe = 250.0;
    if (manevralar.isNotEmpty) {
      final ilk = manevralar.first;
      if (ilk.mesafeMetre != null && ilk.mesafeMetre! > 0) {
        baslangicMesafe = ilk.mesafeMetre!;
      }
      final pos = CanliGpsServisi().sonKonum;
      if (pos != null && ilk.lat != null && ilk.lon != null) {
        baslangicMesafe = Geolocator.distanceBetween(
          pos.latitude,
          pos.longitude,
          ilk.lat!,
          ilk.lon!,
        );
      }
    }

    setState(() {
      _navigasyonAktif = true;
      _simulasyonAktif = false;
      _aktifManevraIndeksi = 0;
      _mevcutManevrayaKalanMetre = baslangicMesafe;
      _canliSurusHizi = CanliGpsServisi().gercekHizKmh.round();
    });

    widget.onTamEkranDegisti?.call(true);

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.navigation_rounded, color: Color(0xFF10B981)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.turkceMi
                    ? 'Canlı Google Maps Navigasyonu Başlatıldı! İyi yolculuklar.'
                    : 'Live Navigation Started! Have a safe trip.',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: NavHtmlColors.surfaceContainerHighest,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _durdurNavigasyon() {
    setState(() {
      _navigasyonAktif = false;
      _aktifManevraIndeksi = 0;
    });
    widget.onTamEkranDegisti?.call(false);
    HapticFeedback.lightImpact();
  }

  void _sonrakiManevra() {
    final rota = _rotaHesapla();
    final manevralar = (_canliOsrmSonucu?.manevralar.isNotEmpty ?? false)
        ? _canliOsrmSonucu!.manevralar
        : rota.manevralar;

    if (_aktifManevraIndeksi < manevralar.length - 1) {
      setState(() {
        _aktifManevraIndeksi++;
        final yeni = manevralar[_aktifManevraIndeksi];
        final pos = CanliGpsServisi().sonKonum;
        if (pos != null && yeni.lat != null && yeni.lon != null) {
          _mevcutManevrayaKalanMetre = Geolocator.distanceBetween(
            pos.latitude,
            pos.longitude,
            yeni.lat!,
            yeni.lon!,
          );
        } else {
          _mevcutManevrayaKalanMetre = yeni.mesafeMetre ?? 250.0;
        }
      });
      HapticFeedback.selectionClick();
    } else {
      _durdurNavigasyon();
      _gosterHedefeUlasildi();
    }
  }

  void _oncekiManevra() {
    if (_aktifManevraIndeksi > 0) {
      final rota = _rotaHesapla();
      final manevralar = (_canliOsrmSonucu?.manevralar.isNotEmpty ?? false)
          ? _canliOsrmSonucu!.manevralar
          : rota.manevralar;

      setState(() {
        _aktifManevraIndeksi--;
        final yeni = manevralar[_aktifManevraIndeksi];
        _mevcutManevrayaKalanMetre = yeni.mesafeMetre ?? 250.0;
      });
      HapticFeedback.selectionClick();
    }
  }

  void _baslatSimulasyon() {
    setState(() {
      _simulasyonAktif = true;
      _simulasyonIlerleme = 0.0;
      _aktifManevraIndeksi = 0;
      _mevcutManevrayaKalanMetre = 350.0;
    });

    _simulasyonTimer?.cancel();
    _simulasyonTimer = Timer.periodic(const Duration(milliseconds: 200), (t) {
      if (!mounted) return;
      setState(() {
        _simulasyonIlerleme += 0.007; // ~30 saniyede rotayı tamamlar
        if (_simulasyonIlerleme >= 1.0) {
          _simulasyonIlerleme = 1.0;
          _durdurSimulasyon();
          _gosterHedefeUlasildi();
          return;
        }

        // Hız dalgalanması
        final speeds = [64, 65, 66, 68, 63, 65, 62, 72, 70];
        _canliSurusHizi = speeds[(t.tick) % speeds.length];

        final rota = _rotaHesapla();
        // Yaklaşan radar tespiti
        if (rota.radarlar.isNotEmpty) {
          int radarIndex = ((_simulasyonIlerleme * rota.radarlar.length)).clamp(0, rota.radarlar.length - 1).toInt();
          _yaklasanRadar = rota.radarlar[radarIndex];
          double kalanKmMesafesi = (1.0 - _simulasyonIlerleme) * rota.mesafeKm;
          _yaklasanRadarMesafeMetre = (kalanKmMesafesi * 250).clamp(150, 4800);
        }

        // Manevra adımlarını ve dönüş mesafesini dinamik ilerlet
        final manevralar = (_canliOsrmSonucu?.manevralar.isNotEmpty ?? false)
            ? _canliOsrmSonucu!.manevralar
            : rota.manevralar;
        if (manevralar.isNotEmpty) {
          int mIndex = ((_simulasyonIlerleme * manevralar.length)).clamp(0, manevralar.length - 1).toInt();
          if (mIndex != _aktifManevraIndeksi) {
            _aktifManevraIndeksi = mIndex;
            HapticFeedback.selectionClick();
          }
          final currentM = manevralar[_aktifManevraIndeksi];
          double stepFraction = 1.0 / manevralar.length;
          double stepProgress = ((_simulasyonIlerleme - (mIndex * stepFraction)) / stepFraction).clamp(0.0, 1.0);
          double totalStepM = (currentM.mesafeMetre ?? 450.0);
          _mevcutManevrayaKalanMetre = (totalStepM * (1.0 - stepProgress)).clamp(15.0, 3500.0);
        }
      });
    });
  }

  void _durdurSimulasyon() {
    _simulasyonTimer?.cancel();
    setState(() {
      _simulasyonAktif = false;
      _simulasyonIlerleme = 0.0;
      _yaklasanRadar = null;
    });
  }

  void _gosterHedefeUlasildi() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: NavHtmlColors.trafficClear),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.turkceMi
                    ? 'Hedefe ulaştınız. Güvenli sürüşler ve iyi günler dileriz!'
                    : 'You have reached your destination. Safe travels!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: NavHtmlColors.surfaceContainerHighest,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // Akıllı Rota Hesaplayıcı (TRNC Yol Ağı ve Radarlarını Analiz Eder)
  HesaplanmisRota _rotaHesapla() {
    bool kalkanliErulkuMu = (_baslangicNoktasi.id == "kalkanli" && _varisNoktasi.id == "erulku") ||
        (_baslangicNoktasi.id == "erulku" && _varisNoktasi.id == "kalkanli");

    RadarKamerasi kalkanliRadar = kktcRadarListesi.firstWhere(
      (r) => r.id == "RAD-15",
      orElse: () => kktcRadarListesi.first,
    );
    RadarKamerasi yilmazkoyRadar = kktcRadarListesi.firstWhere(
      (r) => r.id == "RAD-14",
      orElse: () => kktcRadarListesi.first,
    );
    RadarKamerasi gonyeliRadar = kktcRadarListesi.firstWhere(
      (r) => r.id == "RAD-01",
      orElse: () => kktcRadarListesi.first,
    );
    RadarKamerasi hamitkoyRadar = kktcRadarListesi.firstWhere(
      (r) => r.id == "RAD-03",
      orElse: () => kktcRadarListesi.first,
    );
    RadarKamerasi haspolatRadar = kktcRadarListesi.firstWhere(
      (r) => r.id == "RAD-04",
      orElse: () => kktcRadarListesi.first,
    );
    RadarKamerasi erulkuRadar = kktcRadarListesi.firstWhere(
      (r) => r.id == "RAD-19",
      orElse: () => kktcRadarListesi.first,
    );

    final gCember = kktcTrafikVeritabani.firstWhere((t) => t.id == "guzelyurt_cember");
    final kCevre = kktcTrafikVeritabani.firstWhere((t) => t.id == "kuzey_cevre_yolu");
    final hKavsak = kktcTrafikVeritabani.firstWhere((t) => t.id == "haspolat_kavsagi");
    final eGiris = kktcTrafikVeritabani.firstWhere((t) => t.id == "erulku_girisi");
    final gonyeli = kktcTrafikVeritabani.firstWhere((t) => t.id == "gonyeli_cemberi");

    if (kalkanliErulkuMu) {
      final defaultPoints = [
        const OsrmRoutePoint(35.2470, 33.0280), // Kalkanlı ODTÜ
        const OsrmRoutePoint(35.2340, 33.0210), // Kalkanlı Köyü
        const OsrmRoutePoint(35.2180, 33.0230), // RAD-15 Kalkanlı Radarı
        const OsrmRoutePoint(35.2040, 33.0110), // Güzelyurt Bağlantısı
        const OsrmRoutePoint(35.2010, 33.0450), // Mevlevi
        const OsrmRoutePoint(35.2030, 33.1020), // Aydınköy
        const OsrmRoutePoint(35.2065, 33.1580), // RAD-14 Yılmazköy Radarı
        const OsrmRoutePoint(35.2100, 33.2200), // Alayköy
        const OsrmRoutePoint(35.2150, 33.2850), // Kuzey Çevre Yolu Sapağı
        const OsrmRoutePoint(35.2280, 33.3250), // Sanayi Viyadüğü
        const OsrmRoutePoint(35.2220, 33.3650), // Hamitköy Kuzey
        const OsrmRoutePoint(35.2155, 33.3880), // RAD-03 Hamitköy Radarı
        const OsrmRoutePoint(35.2168, 33.4350), // RAD-04 Haspolat Radarı
        const OsrmRoutePoint(35.2185, 33.4820), // RAD-19 Erülkü Demirhan
      ];

      final pts = _canliGpsRotasi ?? defaultPoints;

      if (_secilenRotaModu == 0) {
        // EN KOLAY & EN HIZLI: ODTÜ Kalkanlı -> Güzelyurt -> Lefkoşa Kuzey Çevre Yolu -> Haspolat -> Erülkü
        return HesaplanmisRota(
          baslangic: _baslangicNoktasi,
          varis: _varisNoktasi,
          secenekAdi: "Kuzey Çevre Yolu Üzerinden (En Rahat & Kolay)",
          secenekAdiEn: "Via North Bypass Road (Easiest & Fastest)",
          mesafeKm: 48.2,
          tahminiDakika: 41,
          kolaylikOzeti:
              "Gönyeli şehir trafiğine ve 50 km/s hız radarlarına girmeden Kuzey Çevre Yolu'ndan kesintisiz, ışıksız olarak Erülkü Demirhan'a varış.",
          kolaylikOzetiEn:
              "Bypasses congested Gonyeli center and 50 km/h cameras via uninterrupted North Bypass directly to Erulku Demirhan.",
          radarlar: [
            kalkanliRadar,
            yilmazkoyRadar,
            hamitkoyRadar,
            haspolatRadar,
            erulkuRadar,
          ],
          trafikNoktalari: [gCember, kCevre, hKavsak, eGiris],
          genelTrafikDurumu: "Kuzey Çevre Yolu açık ve akıcı. Gönyeli sıkışıklığına girmeden rahat varış.",
          genelTrafikDurumuEn: "North Bypass is clear and fluent. Smooth route avoiding Gonyeli bottlenecks.",
          toplamGecikmeDakika: 2,
          manevralar: (_canliOsrmSonucu?.manevralar.isNotEmpty ?? false)
              ? _canliOsrmSonucu!.manevralar
              : [
                  RotaManevraAdimi(
                    ikon: Icons.navigation_rounded,
                    baslik: "Kalkanlı ODTÜ Nizamiyesi'nden Çıkış",
                    baslikEn: "Exit METU Kalkanli Campus Gates",
                    aciklama: "Kampüs ana güvenlik kapısından çıkıp Güzelyurt anayoluna bağlanın.",
                    aciklamaEn: "Leave main security gates and join Guzelyurt highway.",
                    mesafe: "3.2 km",
                    lat: 35.2470,
                    lon: 33.0280,
                    mesafeMetre: 3200,
                    bagliRadar: kalkanliRadar,
                    onemliMi: true,
                  ),
                  RotaManevraAdimi(
                    ikon: Icons.roundabout_right_rounded,
                    baslik: "Güzelyurt Çemberi - Lefkoşa Anayolu",
                    baslikEn: "Guzelyurt Roundabout - Lefkosa Highway",
                    aciklama: "Çemberin 2. çıkışından çift şerit bölünmüş Lefkoşa anayoluna katılın.",
                    aciklamaEn: "Take 2nd exit into dual-lane divided Lefkosa highway.",
                    mesafe: "14.5 km",
                    lat: 35.2040,
                    lon: 33.0110,
                    mesafeMetre: 14500,
                  ),
                  RotaManevraAdimi(
                    ikon: Icons.speed_rounded,
                    baslik: "Yılmazköy Düzlüğü Hız Kontrolü",
                    baslikEn: "Yilmazkoy Straight Speed Control",
                    aciklama: "Uzun düzlükte 75 km/s sabit radar aktiftir. Hız sabitleyiciyi 75 km/s'e kurun.",
                    aciklamaEn: "75 km/h speed camera active on the long straight. Keep under limit.",
                    mesafe: "9.8 km",
                    lat: 35.2065,
                    lon: 33.1580,
                    mesafeMetre: 9800,
                    bagliRadar: yilmazkoyRadar,
                    onemliMi: true,
                  ),
                  RotaManevraAdimi(
                    ikon: Icons.alt_route_rounded,
                    baslik: "Kuzey Çevre Yolu Sapağı (En Kolay Yol Tavsiyesi)",
                    baslikEn: "North Bypass Exit (Easiest Route Advice)",
                    aciklama: "Gönyeli çemberine girmeden sağ sapaktan yeni Lefkoşa Kuzey Çevre Yolu'na girin.",
                    aciklamaEn: "Veer right before Gonyeli roundabout onto the new Lefkosa North Bypass.",
                    mesafe: "11.4 km",
                    lat: 35.2150,
                    lon: 33.2850,
                    mesafeMetre: 11400,
                    bagliRadar: hamitkoyRadar,
                    onemliMi: true,
                  ),
                  RotaManevraAdimi(
                    ikon: Icons.merge_type_rounded,
                    baslik: "Haspolat - UKÜ Bağlantısı",
                    baslikEn: "Haspolat - CIU Highway Connection",
                    aciklama: "Çevre yolundan Gazimağusa anayoluna sorunsuz bağlanın. UKÜ alt geçit radarını geçin.",
                    aciklamaEn: "Merge seamlessly onto Famagusta highway past CIU underpass radar.",
                    mesafe: "5.5 km",
                    lat: 35.2168,
                    lon: 33.4350,
                    mesafeMetre: 5500,
                    bagliRadar: haspolatRadar,
                    onemliMi: true,
                  ),
                  RotaManevraAdimi(
                    ikon: Icons.storefront_rounded,
                    baslik: "Demirhan - Erülkü Süpermarket Varış",
                    baslikEn: "Demirhan - Erulku Supermarket Arrival",
                    aciklama: "Sağ tarafta Erülkü Süpermarket ana otopark girişine yanaşın. Radara dikkat edin!",
                    aciklamaEn: "Pull into Erulku Supermarket parking lot on right. Watch 65 km/h camera!",
                    mesafe: "3.8 km",
                    lat: 35.2185,
                    lon: 33.4820,
                    mesafeMetre: 3800,
                    bagliRadar: erulkuRadar,
                    onemliMi: true,
                  ),
                ],
          gpsNoktalari: pts,
        );
      } else {
        // ALTERNATİF: Gönyeli Merkez & Lefkoşa Şehir İçi (Daha yoğun trafik ve 50 km/s radarlar)
        return HesaplanmisRota(
          baslangic: _baslangicNoktasi,
          varis: _varisNoktasi,
          secenekAdi: "Gönyeli & Lefkoşa Şehir İçi (Işıklı & Yoğun)",
          secenekAdiEn: "Via Gonyeli & Lefkosa City (High Traffic)",
          mesafeKm: 51.6,
          tahminiDakika: 58,
          kolaylikOzeti:
              "Gönyeli çemberi ve Lefkoşa içi ışıklardan geçer. Trafik saatlerinde yavaştır ve 50 km/s hız radarları yoğundur.",
          kolaylikOzetiEn:
              "Passes through Gonyeli roundabout and city signals. Slower during rush hour with 50 km/h speed cameras.",
          radarlar: [
            kalkanliRadar,
            yilmazkoyRadar,
            gonyeliRadar,
            hamitkoyRadar,
            haspolatRadar,
            erulkuRadar,
          ],
          trafikNoktalari: [gCember, gonyeli, hKavsak, eGiris],
          genelTrafikDurumu: "Gönyeli Çemberi girişinde ağır trafik ve dur-kalk bekleme var (+5 dk).",
          genelTrafikDurumuEn: "Heavy stop-and-go congestion at Gonyeli Circle (+5 min delay).",
          toplamGecikmeDakika: 7,
          manevralar: [
            RotaManevraAdimi(
              ikon: Icons.navigation_rounded,
              baslik: "Kalkanlı ODTÜ'den Çıkış",
              baslikEn: "Exit METU Kalkanli",
              aciklama: "Güzelyurt istikametine devam edin.",
              aciklamaEn: "Head towards Guzelyurt.",
              mesafe: "3.2 km",
              bagliRadar: kalkanliRadar,
            ),
            RotaManevraAdimi(
              ikon: Icons.straight_rounded,
              baslik: "Güzelyurt - Lefkoşa Anayolu",
              baslikEn: "Guzelyurt - Lefkosa Highway",
              aciklama: "Yılmazköy radarını 75 km/s ile geçin.",
              aciklamaEn: "Pass Yilmazkoy radar under 75 km/h.",
              mesafe: "24.0 km",
              bagliRadar: yilmazkoyRadar,
            ),
            RotaManevraAdimi(
              ikon: Icons.warning_amber_rounded,
              baslik: "Gönyeli Çemberi Şehir İçi Girişi",
              baslikEn: "Gonyeli Roundabout City Entry",
              aciklama: "⚠️ 50 km/s kırmızı ışık ve hız radarı mevcuttur! Yoğun kavşak.",
              aciklamaEn: "⚠️ 50 km/h red light and speed camera! Heavy congestion.",
              mesafe: "7.4 km",
              bagliRadar: gonyeliRadar,
              onemliMi: true,
            ),
            RotaManevraAdimi(
              ikon: Icons.storefront_rounded,
              baslik: "Hamitköy & Haspolat Üzerinden Erülkü'ye Varış",
              baslikEn: "Arrival at Erulku via Hamitkoy & Haspolat",
              aciklama: "Mağusa anayoluna çıkıp Erülkü Demirhan'a ulaşın.",
              aciklamaEn: "Take Famagusta highway to Erulku Demirhan.",
              mesafe: "17.0 km",
              bagliRadar: erulkuRadar,
            ),
          ],
          gpsNoktalari: pts,
        );
      }
    }

    // 🟢 KALKANLI <-> GÜZELYURT MERKEZ ÖZEL ROTASI
    bool kalkanliGuzelyurtMu = (_baslangicNoktasi.id == "kalkanli" && _varisNoktasi.id == "guzelyurt_merkez") ||
        (_baslangicNoktasi.id == "guzelyurt_merkez" && _varisNoktasi.id == "kalkanli");

    if (kalkanliGuzelyurtMu) {
      final defaultPoints = [
        const OsrmRoutePoint(35.2470, 33.0280), // Kalkanlı ODTÜ
        const OsrmRoutePoint(35.2340, 33.0210), // Kalkanlı Köy Yolu
        const OsrmRoutePoint(35.2180, 33.0230), // RAD-15 Kalkanlı Radarı
        const OsrmRoutePoint(35.2050, 33.0080), // Güzelyurt Girişi
        const OsrmRoutePoint(35.1980, 32.9930), // Güzelyurt Terminal & Merkez
      ];
      final pts = _canliGpsRotasi ?? defaultPoints;

      return HesaplanmisRota(
        baslangic: _baslangicNoktasi,
        varis: _varisNoktasi,
        secenekAdi: "Kalkanlı - Güzelyurt Anayolu",
        secenekAdiEn: "Kalkanli - Guzelyurt Highway",
        mesafeKm: 6.2,
        tahminiDakika: 8,
        kolaylikOzeti:
            "ODTÜ Kalkanlı nizamiyesinden Güzelyurt anayolunu takip ederek doğrudan şehir merkezine ve terminale varış. Hızlı ve rahattır.",
        kolaylikOzetiEn:
            "Direct route from METU Kalkanli gates along Guzelyurt highway straight to town center & terminal.",
        radarlar: [kalkanliRadar],
        trafikNoktalari: [gCember],
        genelTrafikDurumu: "Kalkanlı - Güzelyurt anayolu tamamen açık ve sakin.",
        genelTrafikDurumuEn: "Kalkanli - Guzelyurt highway is clear and calm.",
        toplamGecikmeDakika: 0,
        manevralar: [
          RotaManevraAdimi(
            ikon: Icons.navigation_rounded,
            baslik: "Kalkanlı ODTÜ Kampüs Çıkışı",
            baslikEn: "Exit METU Kalkanli Campus",
            aciklama: "Nizamiyeden ayrılarak Güzelyurt istikametine katılın.",
            aciklamaEn: "Depart security gates and join Guzelyurt highway.",
            mesafe: "1.2 km",
          ),
          RotaManevraAdimi(
            ikon: Icons.speed_rounded,
            baslik: "Kalkanlı Yolu Radar Denetimi",
            baslikEn: "Kalkanli Road Speed Camera",
            aciklama: "⚠️ Hız limiti: 65 km/s. ODTÜ güzergahındaki sabit hız radarına dikkat edin.",
            aciklamaEn: "⚠️ Speed limit: 65 km/h. Watch fixed speed camera on METU route.",
            mesafe: "3.2 km",
            bagliRadar: kalkanliRadar,
            onemliMi: true,
          ),
          RotaManevraAdimi(
            ikon: Icons.place_rounded,
            baslik: "Güzelyurt Terminal & Merkez Varış",
            baslikEn: "Guzelyurt Center & Terminal Arrival",
            aciklama: "Hedefinize ulaştınız. Çarşı ve terminal otoparkına yanaşın.",
            aciklamaEn: "Destination reached. Proceed to center/terminal parking.",
            mesafe: "1.8 km",
            onemliMi: true,
          ),
        ],
        gpsNoktalari: pts,
      );
    }

    // DİĞER ROTALAR İÇİN GENEL HESAPLAMA (Örn: Girne -> Lefkoşa, Gazimağusa -> Erülkü vb.)
    double dx = (_varisNoktasi.lon - _baslangicNoktasi.lon).abs();
    double dy = (_varisNoktasi.lat - _baslangicNoktasi.lat).abs();
    double rawDist = math.sqrt(dx * dx + dy * dy) * 111.0;
    double distKm = _canliOsrmSonucu?.mesafeKm ?? (rawDist * 1.25).clamp(4.0, 110.0);
    int durationMin = _canliOsrmSonucu?.sureDakika ?? (distKm * 1.15).round();

    // Rota çevresindeki radarları filtrele
    double minLat = math.min(_baslangicNoktasi.lat, _varisNoktasi.lat) - 0.06;
    double maxLat = math.max(_baslangicNoktasi.lat, _varisNoktasi.lat) + 0.06;
    double minLon = math.min(_baslangicNoktasi.lon, _varisNoktasi.lon) - 0.06;
    double maxLon = math.max(_baslangicNoktasi.lon, _varisNoktasi.lon) + 0.06;

    List<RadarKamerasi> yolRadarlari = kktcRadarListesi.where((r) {
      return r.lat >= minLat && r.lat <= maxLat && r.lon >= minLon && r.lon <= maxLon;
    }).toList();

    // Rota çevresindeki canlı trafik noktalarını filtrele
    List<KktcTrafikNoktasi> yolTrafikNoktalari = kktcTrafikVeritabani.where((t) {
      return t.lat >= minLat && t.lat <= maxLat && t.lon >= minLon && t.lon <= maxLon;
    }).toList();

    if (yolTrafikNoktalari.isEmpty) {
      yolTrafikNoktalari = [
        KktcTrafikNoktasi(
          id: "rota_akici",
          ad: "${_baslangicNoktasi.kisaAd} - ${_varisNoktasi.kisaAd} Koridoru",
          adEn: "${_baslangicNoktasi.kisaAd} - ${_varisNoktasi.kisaAd} Corridor",
          bolge: _baslangicNoktasi.bolge,
          lat: (_baslangicNoktasi.lat + _varisNoktasi.lat) / 2.0,
          lon: (_baslangicNoktasi.lon + _varisNoktasi.lon) / 2.0,
          yogunlukYuzde: 25,
          gecikmeDakika: 0,
          durum: "Akıcı & Sorunsuz",
          durumEn: "Smooth Flow",
          aciklama: "Ana arterlerde açık yol, belirgin bir kuyruk veya tıkanma bulunmuyor.",
          aciklamaEn: "Clear arterial highways with no significant congestion.",
        ),
      ];
    }

    int delayTotal = yolTrafikNoktalari.fold(0, (sum, t) => sum + t.gecikmeDakika);

    List<RotaManevraAdimi> dinamikManevralar = [
      RotaManevraAdimi(
        ikon: Icons.trip_origin_rounded,
        baslik: "${_baslangicNoktasi.kisaAd}'dan Çıkış Yapın",
        baslikEn: "Depart from ${_baslangicNoktasi.kisaAd}",
        aciklama: "Ana caddeye katılarak navigasyon güzergahını takip edin.",
        aciklamaEn: "Join main thoroughfare and follow route.",
        mesafe: "${(distKm * 0.2).clamp(1.0, 4.0).toStringAsFixed(1)} km",
      ),
    ];

    if (yolRadarlari.isNotEmpty) {
      dinamikManevralar.add(
        RotaManevraAdimi(
          ikon: Icons.speed_rounded,
          baslik: "${yolRadarlari.first.ad} (Hız Kontrolü)",
          baslikEn: "${yolRadarlari.first.adEn} (Speed Check)",
          aciklama:
              "⚠️ Hız limiti: ${yolRadarlari.first.hizLimiti} km/s. Güzergahtaki sabit denetim noktası.",
          aciklamaEn: "⚠️ Speed limit: ${yolRadarlari.first.hizLimiti} km/h. Fixed speed point.",
          mesafe: "${(distKm * 0.5).clamp(1.5, 35.0).toStringAsFixed(1)} km",
          bagliRadar: yolRadarlari.first,
          onemliMi: true,
        ),
      );
    }

    dinamikManevralar.add(
      RotaManevraAdimi(
        ikon: Icons.place_rounded,
        baslik: "${_varisNoktasi.kisaAd} Varış",
        baslikEn: "Arrive at ${_varisNoktasi.kisaAd}",
        aciklama: "Hedefinize ulaştınız. Güvenli park alanına yanaşın.",
        aciklamaEn: "Destination reached. Proceed to designated parking.",
        mesafe: "${(distKm * 0.3).clamp(1.0, 8.0).toStringAsFixed(1)} km",
        onemliMi: true,
      ),
    );

    // Otomatik ara nokta interpolasyonu
    List<OsrmRoutePoint> pts = _canliGpsRotasi ?? [
      OsrmRoutePoint(_baslangicNoktasi.lat, _baslangicNoktasi.lon),
      OsrmRoutePoint(
        _baslangicNoktasi.lat + (_varisNoktasi.lat - _baslangicNoktasi.lat) * 0.33,
        _baslangicNoktasi.lon + (_varisNoktasi.lon - _baslangicNoktasi.lon) * 0.33,
      ),
      OsrmRoutePoint(
        _baslangicNoktasi.lat + (_varisNoktasi.lat - _baslangicNoktasi.lat) * 0.66,
        _baslangicNoktasi.lon + (_varisNoktasi.lon - _baslangicNoktasi.lon) * 0.66,
      ),
      OsrmRoutePoint(_varisNoktasi.lat, _varisNoktasi.lon),
    ];

    return HesaplanmisRota(
      baslangic: _baslangicNoktasi,
      varis: _varisNoktasi,
      secenekAdi: "En Hızlı Anayol Güzergahı",
      secenekAdiEn: "Fastest Highway Route",
      mesafeKm: double.parse(distKm.toStringAsFixed(1)),
      tahminiDakika: durationMin,
      kolaylikOzeti:
          "${_baslangicNoktasi.kisaAd} noktasından ${_varisNoktasi.kisaAd} varışına ana arterler ve çevre yolları kullanılarak en rahat güzergah.",
      kolaylikOzetiEn:
          "Optimal route from ${_baslangicNoktasi.kisaAd} to ${_varisNoktasi.kisaAd} using primary bypass corridors.",
      radarlar: yolRadarlari,
      trafikNoktalari: yolTrafikNoktalari,
      genelTrafikDurumu: delayTotal > 0
          ? "Güzergah üzerinde yaklaşık $delayTotal dakika gecikmeye neden olan yerel yoğunluklar var."
          : "Güzergah boyunca trafik genel olarak açık ve akıcı.",
      genelTrafikDurumuEn: delayTotal > 0
          ? "Localized density along the corridor adding approximately $delayTotal min delay."
          : "Traffic along the route is broadly clear and fluent.",
      toplamGecikmeDakika: delayTotal,
      manevralar: (_canliOsrmSonucu?.manevralar.isNotEmpty ?? false)
          ? _canliOsrmSonucu!.manevralar
          : dinamikManevralar,
      gpsNoktalari: pts,
    );
  }

  @override
  Widget build(BuildContext context) {
    final rota = _rotaHesapla();

    // 🏎️ TAM EKRAN ARAÇ MODU (TESLA & APPLE CARPLAY KOKPİTİ)
    if (_navigasyonAktif) {
      return _buildTamEkranAracModu(rota);
    }

    final Widget mainBody = Container(
      color: NavHtmlColors.background,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 🎯 BAŞLIK VE HIZLI HAZIR ROTALAR
            // ==========================================
            _buildUstBilgiVePresetler(),

            const SizedBox(height: 14),

            // ==========================================
            // 🚗 KALKIŞ & VARIŞ SEÇİCİ KARTI
            // ==========================================
            _buildGuzergahSeciciKarti(),

            const SizedBox(height: 14),

            // ==========================================
            // 🗺️ GERÇEK OPENSTREETMAP HARİTASI & CANLI ROTA
            // ==========================================
            _buildGercekHaritaGorunumu(rota),

            const SizedBox(height: 14),

            // ==========================================
            // 📊 ROTA ÖZETİ VE METRİKLER (Mesafe, Süre, Radar)
            // ==========================================
            _buildMetrikOzetKartlari(rota),

            const SizedBox(height: 14),

            // ==========================================
            // 🚦 CANLI TRAFİK DURUMU & KALABALIK BÖLGELER
            // ==========================================
            _buildCanliTrafikPaneli(rota),

            const SizedBox(height: 14),

            // ==========================================
            // 💡 "NEREDEN KOLAY GİDEBİLİRİM?" TAVSİYE KARTI
            // ==========================================
            _buildKolaylikRehberiKarti(rota),

            const SizedBox(height: 14),

            // ==========================================
            // 📢 KARAYOLLARI DAİRESİ RESMİ BİLDİRİMLERİ
            // ==========================================
            _buildKarayollariDairesiBildirimleri(),

            const SizedBox(height: 14),

            // ==========================================
            // 📷 GÜZERGAHTAKİ SABİT RADARLAR LİSTESİ
            // ==========================================
            _buildGuzergahRadarlari(rota),

            const SizedBox(height: 14),

            // ==========================================
            // 🧭 ADIM ADIM MANEVRA VE YOL TARİFİ
            // ==========================================
            _buildAdimAdimManevralar(rota),

            const SizedBox(height: 24),
          ],
        ),
      ),
      ),
    );

    if (Navigator.canPop(context)) {
      return Scaffold(
        backgroundColor: NavHtmlColors.background,
        appBar: AppBar(
          backgroundColor: NavHtmlColors.surfaceContainer,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.turkceMi ? 'KKTC Yol Tarifi & Akıllı Rota' : 'TRNC Route & Live Traffic',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
        body: Material(
          color: NavHtmlColors.background,
          child: mainBody,
        ),
      );
    }

    return Material(
      color: NavHtmlColors.background,
      child: mainBody,
    );
  }

  // ==========================================
  // 🏎️ TAM EKRAN ARAÇ KOKPİTİ HUD (TESLA & APPLE MAPS TASARIMI)
  // ==========================================
  Widget _buildTamEkranAracModu(HesaplanmisRota rota) {
    final manevralar = (_canliOsrmSonucu?.manevralar.isNotEmpty ?? false)
        ? _canliOsrmSonucu!.manevralar
        : rota.manevralar;

    final aktifManevra = (_aktifManevraIndeksi < manevralar.length)
        ? manevralar[_aktifManevraIndeksi]
        : (manevralar.isNotEmpty ? manevralar.first : null);

    final kalanMetre = _mevcutManevrayaKalanMetre.round();
    final String mesafeGosterge = kalanMetre < 1000 ? '$kalanMetre m' : '${(kalanMetre / 1000).toStringAsFixed(1)} km';
    final int anlikHiz = _canliSurusHizi > 0 ? _canliSurusHizi : 68;
    const int hizLimiti = 65; // Sabit KKTC anayol hız limiti

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. TAM EKRAN CANLI HARİTA GÖRÜNÜMÜ
          Positioned.fill(
            child: KktcRealRouteMapView(
              rota: rota,
              turkceMi: widget.turkceMi,
              canliRotaYukleniyor: _canliRotaYukleniyor,
              simulasyonAktif: _simulasyonAktif,
              simulasyonIlerleme: _simulasyonIlerleme,
              canliSurusHizi: _canliSurusHizi,
              yaklasanRadar: _yaklasanRadar,
              yaklasanRadarMesafeMetre: _yaklasanRadarMesafeMetre,
              onToggleSimulasyon: _simulasyonAktif ? _durdurSimulasyon : _baslatSimulasyon,
              navigasyonAktif: _navigasyonAktif,
              aktifManevraIndeksi: _aktifManevraIndeksi,
              mevcutManevrayaKalanMetre: _mevcutManevrayaKalanMetre,
              onBaslatNavigasyon: _baslatNavigasyon,
              onDurdurNavigasyon: _durdurNavigasyon,
              onSonrakiManevra: _sonrakiManevra,
              onOncekiManevra: _oncekiManevra,
              aktifManevralar: manevralar,
              isFullScreen: true,
              yakinCekimModu: _yakinCekimModu,
            ),
          ),

          // 2. ÜST: APPLE MAPS & WAZE BÜYÜK DÖNÜŞ TABELASI (CANLI YEŞİL)
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00A84D), Color(0xFF007C36)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00A84D).withValues(alpha: 0.45),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Büyük Yön Oku / Manevra İkonu
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        aktifManevra?.ikon ?? Icons.navigation_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Kalan Mesafe, Adım Rozeti ve Yol Adı
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                mesafeGosterge,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Dönüş ${_aktifManevraIndeksi + 1}/${manevralar.length}',
                                  style: const TextStyle(
                                    color: Color(0xFFD1FAE5),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.turkceMi ? (aktifManevra?.baslik ?? "Düz Devam Edin") : (aktifManevra?.baslikEn ?? "Continue Straight"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.turkceMi ? (aktifManevra?.aciklama ?? "Güzergahı takip edin") : (aktifManevra?.aciklamaEn ?? "Follow route"),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Önceki ve Sonraki Manevra Butonları
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_aktifManevraIndeksi > 0)
                          IconButton(
                            onPressed: _oncekiManevra,
                            icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 26),
                            tooltip: widget.turkceMi ? 'Önceki Manevra' : 'Previous Step',
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          ),
                        IconButton(
                          onPressed: _sonrakiManevra,
                          icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 28),
                          tooltip: widget.turkceMi ? 'Sonraki Manevra' : 'Next Step',
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2.5 SOL ÜST: ARAÇ MODU HIZLI KAMERA & SİMÜLASYON KONTROLLERİ
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 104, left: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dönüşe Yakından Bak (Kavşak Odak) Butonu
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _yakinCekimModu = !_yakinCekimModu;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _yakinCekimModu
                                  ? (widget.turkceMi ? '🔍 Dönüş kavşağına yakından odaklanıldı (17.4x).' : '🔍 Zoomed into upcoming turn.')
                                  : (widget.turkceMi ? '🗺️ Tüm güzergah görünümüne geçildi.' : '🗺️ Switched to full route view.'),
                            ),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _yakinCekimModu ? const Color(0xFF10B981) : Colors.white24,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _yakinCekimModu ? const Color(0xFF10B981).withValues(alpha: 0.35) : Colors.black45,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _yakinCekimModu ? Icons.zoom_in_map_rounded : Icons.map_rounded,
                              color: _yakinCekimModu ? const Color(0xFF10B981) : Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _yakinCekimModu
                                  ? (widget.turkceMi ? 'Dönüş Yakın Çekim' : 'Close Turn View')
                                  : (widget.turkceMi ? 'Tüm Rota' : 'Full Route'),
                              style: TextStyle(
                                color: _yakinCekimModu ? const Color(0xFF10B981) : Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Simülasyon Sürüşü Butonu (Test Sürüşü)
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        if (_simulasyonAktif) {
                          _durdurSimulasyon();
                        } else {
                          _baslatSimulasyon();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _simulasyonAktif ? const Color(0xFFEF4444) : Colors.white24,
                            width: 1.2,
                          ),
                          boxShadow: const [
                            BoxShadow(color: Colors.black45, blurRadius: 8),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _simulasyonAktif ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                              color: _simulasyonAktif ? const Color(0xFFEF4444) : const Color(0xFF38BDF8),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _simulasyonAktif
                                  ? (widget.turkceMi ? 'Sürüşü Duraklat' : 'Pause Drive')
                                  : (widget.turkceMi ? 'Sürüş Simülasyonu' : 'Test Drive'),
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. SAĞ ÜST / ORTA: DİJİTAL HIZ GÖSTERGESİ & HIZ SINIRI HALKASI
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 104, right: 16),
                child: Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.90),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: anlikHiz > hizLimiti ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                      width: 3.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (anlikHiz > hizLimiti ? const Color(0xFFEF4444) : const Color(0xFF10B981)).withValues(alpha: 0.35),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$anlikHiz',
                        style: TextStyle(
                          color: anlikHiz > hizLimiti ? const Color(0xFFEF4444) : Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 1),
                      const Text(
                        'km/h',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0.5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFDC2626), width: 1.2),
                        ),
                        child: Text(
                          '$hizLimiti',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 4. ALT: TESLA & APPLE CARPLAY STİLİ ŞIK CAM KOKPİT DOCK'U
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.60),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Kalan Süre / ETA
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${rota.tahminiDakika} dk',
                                style: const TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.20),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'ETA',
                                  style: TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${rota.mesafeKm} km • ${DateTime.now().add(Duration(minutes: rota.tahminiDakika)).hour.toString().padLeft(2, '0')}:${DateTime.now().add(Duration(minutes: rota.tahminiDakika)).minute.toString().padLeft(2, '0')} Varış',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.70),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Kırmızı "Rotayı Bitir" Butonu
                    ElevatedButton.icon(
                      onPressed: _durdurNavigasyon,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 6,
                        shadowColor: const Color(0xFFEF4444).withValues(alpha: 0.5),
                      ),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      label: Text(
                        widget.turkceMi ? 'Rotayı Bitir' : 'End Route',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. Üst Bilgi ve Popüler Rota Kısayolları ---
  Widget _buildUstBilgiVePresetler() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: NavHtmlColors.primaryContainer.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: NavHtmlColors.primaryContainer.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.navigation_rounded, color: NavHtmlColors.primaryContainer, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.turkceMi ? 'KKTC Yol Tarifi & Canlı Trafik' : 'TRNC Route & Live Traffic',
                    style: const TextStyle(
                      color: NavHtmlColors.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    widget.turkceMi
                        ? 'Nerede trafik var, hangi yollar kalabalık anlık görün'
                        : 'Real-time traffic density, busy spots and speed cameras',
                    style: TextStyle(
                      color: NavHtmlColors.secondary.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => YardimRehberiSayfasi(
                      turkceMi: widget.turkceMi,
                      onRotayiAc: (bId, vId) => _hazirRotaSec(bId, vId),
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.help_outline_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      widget.turkceMi ? 'Rehber' : 'Guide',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Popüler Rota Çipleri (Kalkanlı -> Erülkü vurgulu!)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPresetChip(
                etiket: widget.turkceMi ? "💡 Nasıl Giderim? (Rehber)" : "💡 How to Go? (Guide)",
                seciliMi: false,
                rozet: widget.turkceMi ? "Yardım" : "Help",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => YardimRehberiSayfasi(
                        turkceMi: widget.turkceMi,
                        onRotayiAc: (bId, vId) => _hazirRotaSec(bId, vId),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                etiket: "⛽ Gönyeli Çemberi K-Pet",
                seciliMi: _varisNoktasi.id == "poi-kpet-gonyeli",
                onTap: () => _hazirRotaSec("lefkosa_dereboyu", "poi-kpet-gonyeli"),
                rozet: "En Popüler",
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                etiket: "⛽ Alpet Dereboyu İstasyonu",
                seciliMi: _varisNoktasi.id == "poi-alpet-dereboyu",
                onTap: () => _hazirRotaSec("gonyeli_cemberi", "poi-alpet-dereboyu"),
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                etiket: "🔧 Lefkoşa Sanayi 7/24 Lastikçi",
                seciliMi: _varisNoktasi.id == "poi-lastik-lefkosa",
                onTap: () => _hazirRotaSec("gonyeli_cemberi", "poi-lastik-lefkosa"),
                rozet: "Yol Yardım",
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                etiket: "🏥 Dr. Burhan Nalbantoğlu Acil",
                seciliMi: _varisNoktasi.id == "poi-hastane-lefkosa",
                onTap: () => _hazirRotaSec("gonyeli_cemberi", "poi-hastane-lefkosa"),
                rozet: "7/24 Acil",
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                etiket: "🅿️ Lefkoşa Belediye Otoparkı",
                seciliMi: _varisNoktasi.id == "poi-otopark-lefkosa",
                onTap: () => _hazirRotaSec("lefkosa_dereboyu", "poi-otopark-lefkosa"),
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                etiket: "⛽ K-Pet Girne Alsancak",
                seciliMi: _varisNoktasi.id == "poi-kpet-alsancak",
                onTap: () => _hazirRotaSec("girne_liman", "poi-kpet-alsancak"),
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                etiket: "🏥 Girne Dr. Akçiçek Acil",
                seciliMi: _varisNoktasi.id == "poi-hastane-girne",
                onTap: () => _hazirRotaSec("girne_liman", "poi-hastane-girne"),
                rozet: "7/24 Acil",
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                etiket: "✈️ Lefkoşa ➔ Ercan Havalimanı",
                seciliMi: _varisNoktasi.id == "ercan_havalimani",
                onTap: () => _hazirRotaSec("gonyeli_cemberi", "ercan_havalimani"),
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                etiket: "🚗 Girne ➔ Lefkoşa Dereboyu",
                seciliMi: _baslangicNoktasi.id == "girne_liman" && _varisNoktasi.id == "lefkosa_dereboyu",
                onTap: () => _hazirRotaSec("girne_liman", "lefkosa_dereboyu"),
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                etiket: "⛽ Altınbaş Gazimağusa Girişi",
                seciliMi: _varisNoktasi.id == "poi-altinbas-magusa",
                onTap: () => _hazirRotaSec("ercan_havalimani", "poi-altinbas-magusa"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPresetChip({
    required String etiket,
    required bool seciliMi,
    required VoidCallback onTap,
    String? rozet,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: seciliMi
              ? NavHtmlColors.primaryContainer.withValues(alpha: 0.25)
              : NavHtmlColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: seciliMi ? NavHtmlColors.primaryContainer : Colors.white.withValues(alpha: 0.08),
            width: seciliMi ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              etiket,
              style: TextStyle(
                color: seciliMi ? Colors.white : NavHtmlColors.secondary,
                fontSize: 12,
                fontWeight: seciliMi ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (rozet != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: NavHtmlColors.tertiary.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  rozet,
                  style: const TextStyle(
                    color: NavHtmlColors.tertiary,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- 2. Kalkış ve Varış Noktası Seçici Kartı ---
  Widget _buildGuzergahSeciciKarti() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NavHtmlColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Sol dikey rota çizgisi (Yeşil -> Kırmızı)
              Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: NavHtmlColors.tertiary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: NavHtmlColors.tertiary.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 38,
                    color: NavHtmlColors.secondary.withValues(alpha: 0.3),
                  ),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: NavHtmlColors.primaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: NavHtmlColors.primaryContainer.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Nokta Seçim Dropdownları
              Expanded(
                child: Column(
                  children: [
                    // Başlangıç Noktası
                    _buildNoktaSecici(
                      etiket: widget.turkceMi ? 'Kalkış Noktası' : 'Starting Point',
                      secilenNokta: _baslangicNoktasi,
                      onChanged: (yeniNokta) {
                        if (yeniNokta != null) {
                          setState(() {
                            _baslangicNoktasi = yeniNokta;
                            _durdurSimulasyon();
                          });
                          _canliRotayiTetikle();
                        }
                      },
                    ),
                    const Divider(color: Colors.white12, height: 16),
                    // Varış Noktası
                    _buildNoktaSecici(
                      etiket: widget.turkceMi ? 'Varış Noktası (Hedef)' : 'Destination',
                      secilenNokta: _varisNoktasi,
                      onChanged: (yeniNokta) {
                        if (yeniNokta != null) {
                          setState(() {
                            _varisNoktasi = yeniNokta;
                            _durdurSimulasyon();
                          });
                          _canliRotayiTetikle();
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Yön Değiştirme Butonu (⇄)
              GestureDetector(
                onTap: _noktalariDegistir,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: NavHtmlColors.surfaceContainerLowest,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: const Icon(
                    Icons.swap_vert_rounded,
                    color: NavHtmlColors.onSurface,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Rota Alternatifi Seçici Butonları (Kuzey Çevre Yolu vs Şehir İçi)
          if ((_baslangicNoktasi.id == "kalkanli" && _varisNoktasi.id == "erulku") ||
              (_baslangicNoktasi.id == "erulku" && _varisNoktasi.id == "kalkanli"))
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: NavHtmlColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _secilenRotaModu = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                        decoration: BoxDecoration(
                          color: _secilenRotaModu == 0
                              ? NavHtmlColors.tertiaryContainer.withValues(alpha: 0.45)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: _secilenRotaModu == 0
                                ? NavHtmlColors.tertiary
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 14,
                              color: _secilenRotaModu == 0
                                  ? NavHtmlColors.tertiary
                                  : NavHtmlColors.secondary,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                widget.turkceMi ? 'Kuzey Çevre Yolu' : 'North Bypass',
                                style: TextStyle(
                                  color: _secilenRotaModu == 0 ? Colors.white : NavHtmlColors.secondary,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _secilenRotaModu = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                        decoration: BoxDecoration(
                          color: _secilenRotaModu == 1
                              ? NavHtmlColors.surfaceContainerHighest
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: _secilenRotaModu == 1
                                ? Colors.white30
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.traffic_rounded,
                              size: 14,
                              color: _secilenRotaModu == 1
                                  ? NavHtmlColors.warning
                                  : NavHtmlColors.secondary,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                widget.turkceMi ? 'Gönyeli Şehir İçi' : 'City Center',
                                style: TextStyle(
                                  color: _secilenRotaModu == 1 ? Colors.white : NavHtmlColors.secondary,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoktaSecici({
    required String etiket,
    required RotaNoktasi secilenNokta,
    required ValueChanged<RotaNoktasi?> onChanged,
  }) {
    return InkWell(
      onTap: () => _noktaSecimSheetGoster(
        etiket: etiket,
        secilen: secilenNokta,
        onSecildi: onChanged,
      ),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  etiket.toUpperCase(),
                  style: const TextStyle(
                    color: NavHtmlColors.primaryFixedDim,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: NavHtmlColors.primaryContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.touch_app_rounded, size: 10, color: NavHtmlColors.secondary),
                      const SizedBox(width: 2),
                      Text(
                        widget.turkceMi ? 'Listeyi Aç' : 'Browse',
                        style: const TextStyle(
                          color: NavHtmlColors.secondary,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(secilenNokta.ikon, size: 16, color: NavHtmlColors.secondary),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: NavHtmlColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    secilenNokta.bolge,
                    style: const TextStyle(
                      color: NavHtmlColors.tertiary,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.turkceMi ? secilenNokta.ad : secilenNokta.adEn,
                    style: const TextStyle(
                      color: NavHtmlColors.onSurface,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: NavHtmlColors.secondary,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _noktaSecimSheetGoster({
    required String etiket,
    required RotaNoktasi secilen,
    required ValueChanged<RotaNoktasi?> onSecildi,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _NoktaSeciciBottomSheet(
          turkceMi: widget.turkceMi,
          baslik: etiket,
          secilenNokta: secilen,
          noktalar: kktcNoktalari,
          onSecildi: (nokta) {
            Navigator.of(ctx).pop();
            onSecildi(nokta);
          },
        );
      },
    );
  }

  // --- 3. Gerçek OpenStreetMap Harita Görünümü ---
  Widget _buildGercekHaritaGorunumu(HesaplanmisRota rota) {
    final manevralar = (_canliOsrmSonucu?.manevralar.isNotEmpty ?? false)
        ? _canliOsrmSonucu!.manevralar
        : rota.manevralar;

    return KktcRealRouteMapView(
      rota: rota,
      turkceMi: widget.turkceMi,
      canliRotaYukleniyor: _canliRotaYukleniyor,
      simulasyonAktif: _simulasyonAktif,
      simulasyonIlerleme: _simulasyonIlerleme,
      canliSurusHizi: _canliSurusHizi,
      yaklasanRadar: _yaklasanRadar,
      yaklasanRadarMesafeMetre: _yaklasanRadarMesafeMetre,
      onToggleSimulasyon: _simulasyonAktif ? _durdurSimulasyon : _baslatSimulasyon,
      navigasyonAktif: _navigasyonAktif,
      aktifManevraIndeksi: _aktifManevraIndeksi,
      mevcutManevrayaKalanMetre: _mevcutManevrayaKalanMetre,
      onBaslatNavigasyon: _baslatNavigasyon,
      onDurdurNavigasyon: _durdurNavigasyon,
      onSonrakiManevra: _sonrakiManevra,
      onOncekiManevra: _oncekiManevra,
      aktifManevralar: manevralar,
      onHedefNoktaSecildi: _hedefNoktasiAyarla,
      onBaslangicNoktaSecildi: _baslangicNoktasiAyarla,
    );
  }

  // --- 4. Metrik Özet Kartları (Mesafe, Süre, Radar Sayısı, Kolaylık) ---
  Widget _buildMetrikOzetKartlari(HesaplanmisRota rota) {
    return Row(
      children: [
        // Mesafe
        Expanded(
          child: _buildKucukMetrikKarti(
            ikon: Icons.straighten_rounded,
            baslik: widget.turkceMi ? 'Mesafe' : 'Distance',
            deger: '${rota.mesafeKm} km',
            renk: NavHtmlColors.secondary,
          ),
        ),
        const SizedBox(width: 8),
        // Tahmini Süre
        Expanded(
          child: _buildKucukMetrikKarti(
            ikon: Icons.schedule_rounded,
            baslik: widget.turkceMi ? 'Süre' : 'Est. Time',
            deger: '${rota.tahminiDakika} dk',
            renk: NavHtmlColors.tertiary,
          ),
        ),
        const SizedBox(width: 8),
        // Radar Sayısı
        Expanded(
          child: _buildKucukMetrikKarti(
            ikon: Icons.camera_alt_rounded,
            baslik: widget.turkceMi ? 'Sabit Radar' : 'Radars',
            deger: '${rota.radarlar.length} Adet',
            renk: NavHtmlColors.primaryContainer,
            vurguluMu: true,
          ),
        ),
      ],
    );
  }

  Widget _buildKucukMetrikKarti({
    required IconData ikon,
    required String baslik,
    required String deger,
    required Color renk,
    bool vurguluMu = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: NavHtmlColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: vurguluMu ? renk.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.06),
          width: vurguluMu ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ikon, size: 15, color: renk),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  baslik,
                  style: TextStyle(
                    color: NavHtmlColors.secondary.withValues(alpha: 0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              deger,
              style: TextStyle(
                color: vurguluMu ? Colors.white : NavHtmlColors.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  // --- 4.5 🚦 CANLI TRAFİK VE KALABALIK NOKTALAR PANELİ ---
  Widget _buildCanliTrafikPaneli(HesaplanmisRota rota) {
    final bool agirTrafikVarMi = rota.toplamGecikmeDakika >= 4;
    final bool ortaTrafikVarMi = rota.toplamGecikmeDakika > 0 && !agirTrafikVarMi;

    final Color durumRengi = agirTrafikVarMi
        ? NavHtmlColors.trafficHeavy
        : (ortaTrafikVarMi ? NavHtmlColors.trafficModerate : NavHtmlColors.trafficClear);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NavHtmlColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: durumRengi.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık Satırı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: durumRengi.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.traffic_rounded, color: durumRengi, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.turkceMi ? 'Canlı Trafik & Kalabalık Bölgeler' : 'Live Traffic & Crowded Spots',
                              style: const TextStyle(
                                color: NavHtmlColors.onSurface,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            widget.turkceMi
                                ? 'Güzergah üzerindeki anlık yoğunluk durumu'
                                : 'Real-time congestion along this route',
                            style: TextStyle(
                              color: NavHtmlColors.secondary.withValues(alpha: 0.8),
                              fontSize: 10.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: durumRengi.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: durumRengi.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: durumRengi,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      rota.toplamGecikmeDakika > 0
                          ? '+${rota.toplamGecikmeDakika} dk'
                          : (widget.turkceMi ? 'Akıcı' : 'Clear'),
                      style: TextStyle(
                        color: durumRengi,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Özet Durum Kutusu (İnsan dostu samimi dil)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: NavHtmlColors.surfaceContainerLowest.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  agirTrafikVarMi
                      ? Icons.warning_amber_rounded
                      : (ortaTrafikVarMi ? Icons.info_outline_rounded : Icons.check_circle_rounded),
                  color: durumRengi,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.turkceMi ? rota.genelTrafikDurumu : rota.genelTrafikDurumuEn,
                    style: const TextStyle(
                      color: NavHtmlColors.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (rota.trafikNoktalari.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              widget.turkceMi ? 'Güzergah Üzerindeki Noktalar:' : 'Points Along the Route:',
              style: TextStyle(
                color: NavHtmlColors.secondary.withValues(alpha: 0.9),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ...rota.trafikNoktalari.map((nokta) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: NavHtmlColors.surfaceContainerLowest.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: nokta.renk.withValues(alpha: 0.22)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(nokta.ikon, size: 16, color: nokta.renk),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.turkceMi ? nokta.ad : nokta.adEn,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: nokta.renk.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.turkceMi ? nokta.durum : nokta.durumEn,
                            style: TextStyle(
                              color: nokta.renk,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Yoğunluk Çubuğu
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (nokta.yogunlukYuzde / 100.0).clamp(0.0, 1.0),
                              backgroundColor: Colors.white.withValues(alpha: 0.08),
                              valueColor: AlwaysStoppedAnimation<Color>(nokta.renk),
                              minHeight: 5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '%${nokta.yogunlukYuzde} ${widget.turkceMi ? 'Yoğunluk' : 'Density'}',
                          style: TextStyle(
                            color: nokta.renk,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.turkceMi ? nokta.aciklama : nokta.aciklamaEn,
                      style: TextStyle(
                        color: NavHtmlColors.secondary.withValues(alpha: 0.85),
                        fontSize: 10.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  // --- 5. "Nereden Kolay Gidebilirim?" Tavsiye Kartı ---
  Widget _buildKolaylikRehberiKarti(HesaplanmisRota rota) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            NavHtmlColors.tertiaryContainer.withValues(alpha: 0.25),
            NavHtmlColors.surfaceContainerHigh,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: NavHtmlColors.tertiary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: NavHtmlColors.tertiary.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: NavHtmlColors.tertiary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.turkceMi ? '💡 Nereden Kolay Gidebilirim? (Tavsiye)' : '💡 Easiest Route Advice',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: NavHtmlColors.tertiaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.turkceMi ? 'Hızlı & Işıksız' : 'Fast & Smooth',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.turkceMi ? rota.kolaylikOzeti : rota.kolaylikOzetiEn,
            style: const TextStyle(
              color: NavHtmlColors.onSurface,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: NavHtmlColors.surfaceContainerLowest.withValues(alpha: 0.70),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: NavHtmlColors.tertiary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.turkceMi
                        ? 'Tavsiye Edilen Güzergah: ${rota.baslangic.kisaAd} ➔ ${rota.secenekAdi} ➔ ${rota.varis.kisaAd}'
                        : 'Recommended: ${rota.baslangic.kisaAd} ➔ ${rota.secenekAdiEn} ➔ ${rota.varis.kisaAd}',
                    style: const TextStyle(
                      color: NavHtmlColors.secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 5.1 Karayolları Dairesi Canlı Yol Bildirimleri ---
  Widget _buildKarayollariDairesiBildirimleri() {
    final gov = KktcGovSyncService();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.campaign_rounded, color: NavHtmlColors.warning, size: 18),
            const SizedBox(width: 8),
            Text(
              widget.turkceMi ? 'Karayolları Dairesi Güncel Bildirimleri' : 'Highway Dept. Live Bulletins',
              style: const TextStyle(
                color: NavHtmlColors.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...gov.yolBildirimleri.map((bildirim) {
          final isWarning = bildirim.seviye == 'dikkat';
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: NavHtmlColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isWarning
                    ? NavHtmlColors.warning.withValues(alpha: 0.3)
                    : NavHtmlColors.tertiary.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isWarning ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                  size: 16,
                  color: isWarning ? NavHtmlColors.warning : NavHtmlColors.tertiary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.turkceMi ? bildirim.baslik : bildirim.baslikEn,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            bildirim.tarih,
                            style: TextStyle(
                              color: NavHtmlColors.secondary.withValues(alpha: 0.7),
                              fontSize: 9.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.turkceMi ? bildirim.detay : bildirim.detayEn,
                        style: TextStyle(
                          color: NavHtmlColors.secondary.withValues(alpha: 0.85),
                          fontSize: 10.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // --- 6. Güzergahtaki Sabit Radarlar Listesi ---
  Widget _buildGuzergahRadarlari(HesaplanmisRota rota) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.shield_outlined, color: NavHtmlColors.primaryContainer, size: 18),
                const SizedBox(width: 8),
                Text(
                  widget.turkceMi ? 'Güzergahtaki Sabit Radarlar' : 'Speed Cameras on Route',
                  style: const TextStyle(
                    color: NavHtmlColors.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            Text(
              '${rota.radarlar.length} ${widget.turkceMi ? 'Kamera' : 'Cameras'}',
              style: TextStyle(
                color: NavHtmlColors.secondary.withValues(alpha: 0.8),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (rota.radarlar.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NavHtmlColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                widget.turkceMi ? 'Bu güzergahta sabit radar bulunmuyor.' : 'No speed cameras on this path.',
                style: const TextStyle(color: NavHtmlColors.secondary, fontSize: 12),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rota.radarlar.length,
            separatorBuilder: (c, i) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final radar = rota.radarlar[index];
              return _buildRadarKarti(radar, index + 1);
            },
          ),
      ],
    );
  }

  Widget _buildRadarKarti(RadarKamerasi radar, int sira) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: NavHtmlColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          // Sıra & Trafik Tabelası
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFDC2626), width: 3.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.25),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${radar.hizLimiti}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Radar Bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '#$sira',
                      style: const TextStyle(
                        color: NavHtmlColors.primaryFixedDim,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.turkceMi ? radar.ad : radar.adEn,
                        style: const TextStyle(
                          color: NavHtmlColors.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  widget.turkceMi ? radar.yon : radar.yonEn,
                  style: TextStyle(
                    color: NavHtmlColors.secondary.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.turkceMi ? radar.aciklama : radar.aciklamaEn,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.60),
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Hız Limiti Etiketi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: NavHtmlColors.primaryContainer.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: NavHtmlColors.primaryContainer.withValues(alpha: 0.3)),
            ),
            child: Text(
              '${radar.hizLimiti} km/s',
              style: const TextStyle(
                color: NavHtmlColors.primaryContainer,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 7. Adım Adım Manevralar ve Yol Tarifi ---
  Widget _buildAdimAdimManevralar(HesaplanmisRota rota) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.turn_right_rounded, color: NavHtmlColors.tertiary, size: 20),
            const SizedBox(width: 8),
            Text(
              widget.turkceMi ? 'Adım Adım Yol Tarifi & Manevralar' : 'Turn-by-Turn Directions',
              style: const TextStyle(
                color: NavHtmlColors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: NavHtmlColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rota.manevralar.length,
            separatorBuilder: (c, i) => const Divider(color: Colors.white10, height: 20),
            itemBuilder: (context, index) {
              final adim = rota.manevralar[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: adim.onemliMi
                          ? NavHtmlColors.primaryContainer.withValues(alpha: 0.20)
                          : NavHtmlColors.surfaceContainerLowest,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: adim.onemliMi ? NavHtmlColors.primaryContainer : Colors.white12,
                      ),
                    ),
                    child: Icon(
                      adim.ikon,
                      size: 16,
                      color: adim.onemliMi ? NavHtmlColors.primaryContainer : NavHtmlColors.tertiary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.turkceMi ? adim.baslik : adim.baslikEn,
                                style: const TextStyle(
                                  color: NavHtmlColors.onSurface,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              adim.mesafe,
                              style: const TextStyle(
                                color: NavHtmlColors.tertiary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.turkceMi ? adim.aciklama : adim.aciklamaEn,
                          style: TextStyle(
                            color: NavHtmlColors.secondary.withValues(alpha: 0.8),
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                        if (adim.bagliRadar != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: NavHtmlColors.primaryContainer.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: NavHtmlColors.primaryContainer.withValues(alpha: 0.25)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.camera_alt_rounded, size: 12, color: NavHtmlColors.primaryContainer),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${widget.turkceMi ? 'Radar Uyarısı' : 'Camera'}: ${adim.bagliRadar!.hizLimiti} km/s Limit (${adim.bagliRadar!.ad})',
                                    style: const TextStyle(
                                      color: NavHtmlColors.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 🗺️ GERÇEK OPENSTREETMAP ROTA VE TILE GÖRÜNÜMÜ
// ==========================================
class KktcRealRouteMapView extends StatefulWidget {
  final HesaplanmisRota rota;
  final bool turkceMi;
  final bool canliRotaYukleniyor;
  final bool simulasyonAktif;
  final double simulasyonIlerleme;
  final int canliSurusHizi;
  final RadarKamerasi? yaklasanRadar;
  final double yaklasanRadarMesafeMetre;
  final VoidCallback onToggleSimulasyon;
  // Gerçek Google Maps Navigasyon Parametreleri
  final bool navigasyonAktif;
  final int aktifManevraIndeksi;
  final double mevcutManevrayaKalanMetre;
  final VoidCallback onBaslatNavigasyon;
  final VoidCallback onDurdurNavigasyon;
  final VoidCallback onSonrakiManevra;
  final VoidCallback onOncekiManevra;
  final List<RotaManevraAdimi> aktifManevralar;
  final bool isFullScreen;
  final bool yakinCekimModu;
  // Dokunarak Rota Seçimi (Touch-to-Route)
  final ValueChanged<RotaNoktasi>? onHedefNoktaSecildi;
  final ValueChanged<RotaNoktasi>? onBaslangicNoktaSecildi;

  const KktcRealRouteMapView({
    super.key,
    required this.rota,
    required this.turkceMi,
    required this.canliRotaYukleniyor,
    required this.simulasyonAktif,
    required this.simulasyonIlerleme,
    required this.canliSurusHizi,
    required this.yaklasanRadar,
    required this.yaklasanRadarMesafeMetre,
    required this.onToggleSimulasyon,
    required this.navigasyonAktif,
    required this.aktifManevraIndeksi,
    required this.mevcutManevrayaKalanMetre,
    required this.onBaslatNavigasyon,
    required this.onDurdurNavigasyon,
    required this.onSonrakiManevra,
    required this.onOncekiManevra,
    required this.aktifManevralar,
    this.isFullScreen = false,
    this.yakinCekimModu = true,
    this.onHedefNoktaSecildi,
    this.onBaslangicNoktaSecildi,
  });

  @override
  State<KktcRealRouteMapView> createState() => _KktcRealRouteMapViewState();
}

class _KktcRealRouteMapViewState extends State<KktcRealRouteMapView>
    with SingleTickerProviderStateMixin {
  late double _centerLat;
  late double _centerLon;
  double _zoom = 10.2;
  int _mapStyleIndex = 0; // 0 = OSM Standart, 1 = CartoDB Voyager, 2 = Uydu
  bool _trafikKatmaniAcik = true; // Canlı Trafik ve Kalabalık Yoğunluk Katmanı

  // Dokunarak Seçilen Nokta (Touch-to-Route)
  RotaNoktasi? _dokunulanNokta;
  bool _isPanning = false;

  late final AnimationController _pulseController;

  final List<String> _tileProviders = [
    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    'https://a.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}.jpg',
  ];

  final List<String> _tileNames = [
    'OpenStreetMap',
    'Canlı Renkli',
    'Gerçek Uydu',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _rotayaOdaklanHesapla();
  }

  @override
  void didUpdateWidget(covariant KktcRealRouteMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rota.baslangic.id != widget.rota.baslangic.id ||
        oldWidget.rota.varis.id != widget.rota.varis.id) {
      _rotayaOdaklanHesapla();
    } else if (widget.navigasyonAktif && !oldWidget.navigasyonAktif) {
      _navigasyonaOdaklan();
    } else if (widget.navigasyonAktif &&
        oldWidget.aktifManevraIndeksi != widget.aktifManevraIndeksi) {
      _aktifManevrayaOdaklan();
    } else if (widget.yakinCekimModu != oldWidget.yakinCekimModu) {
      if (widget.yakinCekimModu) {
        _aktifManevrayaOdaklan();
      } else {
        setState(_rotayaOdaklanHesapla);
      }
    } else if (widget.navigasyonAktif &&
        (oldWidget.mevcutManevrayaKalanMetre - widget.mevcutManevrayaKalanMetre).abs() > 25 &&
        !_isPanning &&
        widget.yakinCekimModu) {
      // 🌟 Dönüşe yaklaştıkça ultra yakın kavşak çekimine geç (17.4x)
      if (widget.mevcutManevrayaKalanMetre <= 250 && _zoom < 17.2) {
        final m = (widget.aktifManevraIndeksi < widget.aktifManevralar.length)
            ? widget.aktifManevralar[widget.aktifManevraIndeksi]
            : null;
        if (m != null && m.lat != null && m.lon != null) {
          setState(() {
            _centerLat = m.lat!;
            _centerLon = m.lon!;
            _zoom = 17.4;
          });
        }
      }
    } else if (widget.simulasyonAktif &&
        (oldWidget.simulasyonIlerleme - widget.simulasyonIlerleme).abs() > 0.005 &&
        !_isPanning &&
        widget.rota.gpsNoktalari.length >= 2) {
      // Simülasyonda hareket eden aracı ve kavşakları takip et
      final pts = widget.rota.gpsNoktalari;
      double t = widget.simulasyonIlerleme.clamp(0.0, 1.0);
      int segIndex = (t * (pts.length - 1)).floor();
      double segT = (t * (pts.length - 1)) - segIndex;
      if (segIndex < pts.length - 1) {
        double curLat = pts[segIndex].lat + (pts[segIndex + 1].lat - pts[segIndex].lat) * segT;
        double curLon = pts[segIndex].lon + (pts[segIndex + 1].lon - pts[segIndex].lon) * segT;
        if (widget.yakinCekimModu && widget.mevcutManevrayaKalanMetre <= 250 && widget.aktifManevraIndeksi < widget.aktifManevralar.length) {
          final m = widget.aktifManevralar[widget.aktifManevraIndeksi];
          if (m.lat != null && m.lon != null) {
            setState(() {
              _centerLat = m.lat!;
              _centerLon = m.lon!;
              _zoom = 17.4;
            });
          }
        } else if (widget.navigasyonAktif && widget.yakinCekimModu) {
          setState(() {
            _centerLat = curLat;
            _centerLon = curLon;
            _zoom = 16.8;
          });
        }
      }
    }
  }

  void _navigasyonaOdaklan() {
    if (!widget.yakinCekimModu) {
      _rotayaOdaklanHesapla();
      return;
    }
    if (widget.aktifManevralar.isNotEmpty && widget.aktifManevraIndeksi < widget.aktifManevralar.length) {
      final m = widget.aktifManevralar[widget.aktifManevraIndeksi];
      if (m.lat != null && m.lon != null) {
        setState(() {
          _centerLat = m.lat!;
          _centerLon = m.lon!;
          _zoom = 17.0; // 🌟 DÖNECEĞİMİZ YERİ YAKINDAN GÖSTER
        });
        return;
      }
    }
    final pos = CanliGpsServisi().sonKonum;
    if (pos != null) {
      setState(() {
        _centerLat = pos.latitude;
        _centerLon = pos.longitude;
        _zoom = 17.0;
      });
    }
  }

  void _aktifManevrayaOdaklan() {
    if (!widget.yakinCekimModu) {
      return;
    }
    if (widget.aktifManevraIndeksi < widget.aktifManevralar.length) {
      final m = widget.aktifManevralar[widget.aktifManevraIndeksi];
      if (m.lat != null && m.lon != null) {
        setState(() {
          _centerLat = m.lat!;
          _centerLon = m.lon!;
          _zoom = widget.mevcutManevrayaKalanMetre <= 250 ? 17.4 : 17.0;
        });
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _rotayaOdaklanHesapla() {
    final b = widget.rota.baslangic;
    final v = widget.rota.varis;
    _centerLat = (b.lat + v.lat) / 2.0;
    _centerLon = (b.lon + v.lon) / 2.0;

    double dLat = (b.lat - v.lat).abs();
    double dLon = (b.lon - v.lon).abs();
    double maxSpan = math.max(dLat, dLon);

    if (maxSpan > 0.6) {
      _zoom = 9.2;
    } else if (maxSpan > 0.3) {
      _zoom = 10.0;
    } else if (maxSpan > 0.1) {
      _zoom = 10.8;
    } else {
      _zoom = 12.0;
    }
  }

  static double lonToTileX(double lon, double zoom) {
    return ((lon + 180.0) / 360.0 * math.pow(2.0, zoom));
  }

  static double latToTileY(double lat, double zoom) {
    final rad = lat * math.pi / 180.0;
    final sinVal = math.sin(rad).clamp(-0.9999, 0.9999);
    return ((1.0 - math.log((1.0 + sinVal) / (1.0 - sinVal)) / (2.0 * math.pi)) / 2.0 * math.pow(2.0, zoom));
  }

  static double tileXToLon(double x, double zoom) {
    return (x / math.pow(2.0, zoom) * 360.0 - 180.0);
  }

  static double tileYToLat(double y, double zoom) {
    final n = math.pi - 2.0 * math.pi * y / math.pow(2.0, zoom);
    final sinh = 0.5 * (math.exp(n) - math.exp(-n));
    return (180.0 / math.pi * math.atan(sinh));
  }

  void _zoomIn() {
    setState(() => _zoom = (_zoom + 0.8).clamp(8.5, 15.0));
  }

  void _zoomOut() {
    setState(() => _zoom = (_zoom - 0.8).clamp(8.5, 15.0));
  }

  void _toggleStyle() {
    setState(() => _mapStyleIndex = (_mapStyleIndex + 1) % _tileProviders.length);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: widget.isFullScreen
          ? null
          : BoxDecoration(
              color: NavHtmlColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 22,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.isFullScreen ? 0 : 20),
        child: SizedBox(
          height: widget.isFullScreen ? double.infinity : 280,
          width: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              final intZoom = _zoom.floor();
              final subScale = math.pow(2.0, _zoom - intZoom).toDouble();
              final tileSize = 256.0 * subScale;

              final centerTileX = lonToTileX(_centerLon, intZoom.toDouble());
              final centerTileY = latToTileY(_centerLat, intZoom.toDouble());

              final minTileX = (centerTileX - (width / 2.0) / tileSize).floor() - 1;
              final maxTileX = (centerTileX + (width / 2.0) / tileSize).ceil() + 1;
              final minTileY = (centerTileY - (height / 2.0) / tileSize).floor() - 1;
              final maxTileY = (centerTileY + (height / 2.0) / tileSize).ceil() + 1;
              final numTiles = 1 << intZoom;
              final template = _tileProviders[_mapStyleIndex];

              return GestureDetector(
                onPanStart: (_) => _isPanning = true,
                onPanUpdate: (details) {
                  _isPanning = true;
                  setState(() {
                    final dxTiles = -details.delta.dx / tileSize;
                    final dyTiles = -details.delta.dy / tileSize;
                    _centerLon = tileXToLon(centerTileX + dxTiles, intZoom.toDouble()).clamp(32.2, 34.6);
                    _centerLat = tileYToLat(centerTileY + dyTiles, intZoom.toDouble()).clamp(34.8, 35.8);
                  });
                },
                onPanEnd: (_) {
                  Future.delayed(const Duration(milliseconds: 140), () {
                    if (mounted) _isPanning = false;
                  });
                },
                onTapUp: (details) {
                  if (widget.navigasyonAktif) return;
                  if (_isPanning) return;
                  final dxPixels = details.localPosition.dx - width / 2.0;
                  final dyPixels = details.localPosition.dy - height / 2.0;
                  final tappedTileX = centerTileX + (dxPixels / tileSize);
                  final tappedTileY = centerTileY + (dyPixels / tileSize);
                  final tappedLon = tileXToLon(tappedTileX, intZoom.toDouble()).clamp(32.2, 34.6);
                  final tappedLat = tileYToLat(tappedTileY, intZoom.toDouble()).clamp(34.8, 35.8);

                  setState(() {
                    _dokunulanNokta = RotaNoktasi(
                      id: 'custom_pin_${DateTime.now().millisecondsSinceEpoch}',
                      ad: widget.turkceMi
                          ? 'Haritada Seçilen Nokta (${tappedLat.toStringAsFixed(3)}, ${tappedLon.toStringAsFixed(3)})'
                          : 'Selected Map Location (${tappedLat.toStringAsFixed(3)}, ${tappedLon.toStringAsFixed(3)})',
                      adEn: 'Selected Map Location (${tappedLat.toStringAsFixed(3)}, ${tappedLon.toStringAsFixed(3)})',
                      kisaAd: '${tappedLat.toStringAsFixed(2)}, ${tappedLon.toStringAsFixed(2)}',
                      bolge: widget.turkceMi ? 'Harita Seçimi' : 'Map Pin',
                      lat: tappedLat,
                      lon: tappedLon,
                      ikon: Icons.place_rounded,
                    );
                  });
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 1. GERÇEK OPENSTREETMAP TİLELARI
                    for (int tx = minTileX; tx <= maxTileX; tx++)
                      for (int ty = minTileY; ty <= maxTileY; ty++)
                        if (ty >= 0 && ty < numTiles)
                          Positioned(
                            left: width / 2.0 + (tx - centerTileX) * tileSize,
                            top: height / 2.0 + (ty - centerTileY) * tileSize,
                            width: tileSize + 0.6,
                            height: tileSize + 0.6,
                            child: Image.network(
                              template
                                  .replaceAll('{z}', '$intZoom')
                                  .replaceAll('{x}', '${((tx % numTiles) + numTiles) % numTiles}')
                                  .replaceAll('{y}', '$ty'),
                              headers: const {'User-Agent': 'KktcTrafikCezaRadar/1.0'},
                              fit: BoxFit.fill,
                              errorBuilder: (c, e, s) => Container(
                                color: NavHtmlColors.surfaceContainerHigh.withValues(alpha: 0.3),
                              ),
                            ),
                          ),

                    // 2. TİLELAR ÜZERİNE ÇİZİLEN GERÇEK GPS POLYLİNE KATMANI (CANLI TRAFİK RENKLERİYLE)
                    CustomPaint(
                      size: Size(width, height),
                      painter: _RealGpsRoutePainter(
                        points: widget.rota.gpsNoktalari,
                        centerLon: _centerLon,
                        centerLat: _centerLat,
                        zoom: _zoom,
                        tileSize: tileSize,
                        width: width,
                        height: height,
                        simulasyonIlerleme: widget.simulasyonIlerleme,
                        simulasyonAktif: widget.simulasyonAktif,
                        pulseValue: _pulseController.value,
                        trafikKatmaniAcik: _trafikKatmaniAcik,
                        trafikNoktalari: widget.rota.trafikNoktalari,
                      ),
                    ),

                    // 3. RADAR KAMERALARI PINLERI (GERÇEK GPS KOORDİNATLARINDA)
                    ...widget.rota.radarlar.map((radar) {
                      final rTileX = lonToTileX(radar.lon, intZoom.toDouble());
                      final rTileY = latToTileY(radar.lat, intZoom.toDouble());
                      final px = width / 2.0 + (rTileX - centerTileX) * tileSize;
                      final py = height / 2.0 + (rTileY - centerTileY) * tileSize;

                      if (px < -40 || px > width + 40 || py < -40 || py > height + 40) {
                        return const SizedBox.shrink();
                      }

                      return Positioned(
                        left: px - 15,
                        top: py - 15,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFDC2626), width: 2.8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${radar.hizLimiti}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    // 3.5 CANLI TRAFİK VE KALABALIK BÖLGE BALONCUKLARI
                    if (_trafikKatmaniAcik)
                      ...widget.rota.trafikNoktalari.map((trafik) {
                        final tTileX = lonToTileX(trafik.lon, intZoom.toDouble());
                        final tTileY = latToTileY(trafik.lat, intZoom.toDouble());
                        final px = width / 2.0 + (tTileX - centerTileX) * tileSize;
                        final py = height / 2.0 + (tTileY - centerTileY) * tileSize;

                        if (px < -60 || px > width + 60 || py < -60 || py > height + 60) {
                          return const SizedBox.shrink();
                        }

                        return Positioned(
                          left: px - 38,
                          top: py - 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: NavHtmlColors.surfaceContainerLowest.withValues(alpha: 0.94),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: trafik.renk, width: 1.4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.traffic_rounded, size: 11, color: trafik.renk),
                                const SizedBox(width: 4),
                                Text(
                                  trafik.gecikmeDakika > 0
                                      ? '+${trafik.gecikmeDakika} dk'
                                      : (widget.turkceMi ? 'Akıcı' : 'Clear'),
                                  style: TextStyle(
                                    color: trafik.renk,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                    // 4. BAŞLANGIÇ PİNİ (ODTÜ KALKANLI - YEŞİL)
                    _buildGpsPin(
                      lat: widget.rota.baslangic.lat,
                      lon: widget.rota.baslangic.lon,
                      label: widget.rota.baslangic.kisaAd,
                      color: NavHtmlColors.tertiary,
                      icon: widget.rota.baslangic.ikon,
                      width: width,
                      height: height,
                      tileSize: tileSize,
                      centerTileX: centerTileX,
                      centerTileY: centerTileY,
                      intZoom: intZoom,
                    ),

                    // 5. VARIŞ PİNİ (ERÜLKÜ DEMİRHAN - KIRMIZI)
                    _buildGpsPin(
                      lat: widget.rota.varis.lat,
                      lon: widget.rota.varis.lon,
                      label: widget.rota.varis.kisaAd,
                      color: NavHtmlColors.primaryContainer,
                      icon: widget.rota.varis.ikon,
                      width: width,
                      height: height,
                      tileSize: tileSize,
                      centerTileX: centerTileX,
                      centerTileY: centerTileY,
                      intZoom: intZoom,
                    ),

                    // 5.5 CANLI KULLANICI GPS PİNİ
                    if (CanliGpsServisi().sonKonum != null)
                      _buildGpsPin(
                        lat: CanliGpsServisi().sonKonum!.latitude,
                        lon: CanliGpsServisi().sonKonum!.longitude,
                        label: widget.turkceMi
                            ? 'Siz (${CanliGpsServisi().gercekHizKmh.round()} km/s)'
                            : 'You (${CanliGpsServisi().gercekHizKmh.round()} km/h)',
                        color: const Color(0xFF0284C7),
                        icon: Icons.navigation_rounded,
                        width: width,
                        height: height,
                        tileSize: tileSize,
                        centerTileX: centerTileX,
                        centerTileY: centerTileY,
                        intZoom: intZoom,
                      ),

                    // 5.7 HARİTADAN DOKUNULARAK SEÇİLEN HEDEF PİNİ (TOUCH-TO-ROUTE)
                    if (_dokunulanNokta != null)
                      _buildGpsPin(
                        lat: _dokunulanNokta!.lat,
                        lon: _dokunulanNokta!.lon,
                        label: widget.turkceMi ? 'Seçilen Hedef' : 'Selected Pin',
                        color: const Color(0xFFF59E0B),
                        icon: Icons.add_location_alt_rounded,
                        width: width,
                        height: height,
                        tileSize: tileSize,
                        centerTileX: centerTileX,
                        centerTileY: centerTileY,
                        intZoom: intZoom,
                      ),

                    // 5.8 DÖNECEĞİMİZ YERİ YAKINDAN GÖSTEREN AKTİF MANEVRA / KAVŞAK ROZETİ
                    if (widget.navigasyonAktif && widget.aktifManevralar.isNotEmpty && widget.aktifManevraIndeksi < widget.aktifManevralar.length) ...[
                      () {
                        final manevra = widget.aktifManevralar[widget.aktifManevraIndeksi];
                        if (manevra.lat == null || manevra.lon == null) return const SizedBox.shrink();
                        final mTileX = lonToTileX(manevra.lon!, intZoom.toDouble());
                        final mTileY = latToTileY(manevra.lat!, intZoom.toDouble());
                        final px = width / 2.0 + (mTileX - centerTileX) * tileSize;
                        final py = height / 2.0 + (mTileY - centerTileY) * tileSize;

                        if (px < -100 || px > width + 100 || py < -100 || py > height + 100) {
                          return const SizedBox.shrink();
                        }

                        final kalanM = widget.mevcutManevrayaKalanMetre.round();
                        final kalanMetreStr = kalanM <= 35
                            ? (widget.turkceMi ? 'ŞİMDİ DÖNÜN' : 'TURN NOW')
                            : (kalanM < 1000 ? '$kalanM m' : '${(kalanM / 1000).toStringAsFixed(1)} km');

                        return Positioned(
                          left: px - 65,
                          top: py - 60,
                          width: 130,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF047857), Color(0xFF065F46)],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFF34D399), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(manevra.ikon, size: 13, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        kalanMetreStr,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 42 + (_pulseController.value * 16),
                                    height: 42 + (_pulseController.value * 16),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF10B981).withValues(alpha: (1.0 - _pulseController.value) * 0.45),
                                    ),
                                  ),
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.4),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      manevra.ikon,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }(),
                    ],

                    // 6. ÜST NAVİGASYON BAŞLIĞI: GOOGLE MAPS DÖNÜŞ PANELİ VEYA HARİTA BİLGİ ROZETİ
                    if (widget.navigasyonAktif && !widget.isFullScreen)
                      _buildGoogleMapsTurnBanner(width)
                    else if (!widget.navigasyonAktif)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: math.max(100.0, width - 80)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: NavHtmlColors.surfaceContainerLowest.withValues(alpha: 0.90),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: widget.canliRotaYukleniyor ? NavHtmlColors.warning : NavHtmlColors.trafficClear,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    widget.canliRotaYukleniyor
                                        ? (widget.turkceMi ? 'Trafik & Rota Alınıyor...' : 'Updating Route...')
                                        : (widget.turkceMi ? 'Canlı Harita & Trafik' : 'Live Map & Traffic'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // 7. SAĞ ÜST: HARİTA KONTROLLERİ (Trafik / Katman / Odaklan / + / -)
                    Positioned(
                      top: widget.navigasyonAktif ? 100 : 10,
                      right: 10,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHaritaAksiyonButonu(
                            icon: _trafikKatmaniAcik ? Icons.traffic_rounded : Icons.traffic_outlined,
                            tooltip: widget.turkceMi ? 'Canlı Trafik Yoğunluğu' : 'Live Traffic Density',
                            aktifMi: _trafikKatmaniAcik,
                            aktifRenk: NavHtmlColors.warning,
                            onTap: () {
                              setState(() => _trafikKatmaniAcik = !_trafikKatmaniAcik);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _trafikKatmaniAcik
                                        ? (widget.turkceMi ? 'Trafik yoğunluğu katmanı açık' : 'Traffic layer enabled')
                                        : (widget.turkceMi ? 'Trafik yoğunluğu katmanı gizlendi' : 'Traffic layer hidden'),
                                  ),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 6),
                          _buildHaritaAksiyonButonu(
                            icon: Icons.layers_rounded,
                            tooltip: _tileNames[_mapStyleIndex],
                            onTap: _toggleStyle,
                          ),
                          const SizedBox(height: 6),
                          _buildHaritaAksiyonButonu(
                            icon: Icons.filter_center_focus_rounded,
                            tooltip: widget.turkceMi ? 'Rotaya Odaklan' : 'Fit Route',
                            onTap: () => setState(_rotayaOdaklanHesapla),
                          ),
                          const SizedBox(height: 6),
                          _buildHaritaAksiyonButonu(
                            icon: Icons.my_location_rounded,
                            tooltip: widget.turkceMi ? 'Canlı GPS Konumum' : 'My GPS Location',
                            aktifMi: CanliGpsServisi().sonKonum != null,
                            aktifRenk: const Color(0xFF38BDF8),
                            onTap: () {
                              final pos = CanliGpsServisi().sonKonum;
                              if (pos != null) {
                                setState(() {
                                  _centerLat = pos.latitude;
                                  _centerLon = pos.longitude;
                                  _zoom = 13.5;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      widget.turkceMi
                                          ? 'Canlı GPS konumunuza odaklanıldı (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})'
                                          : 'Centered on live GPS location',
                                    ),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } else {
                                CanliGpsServisi().servisiBaslat();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      widget.turkceMi
                                          ? 'GPS uyduları taranıyor, lütfen bekleyin...'
                                          : 'Searching for GPS signal...',
                                    ),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 6),
                          _buildHaritaAksiyonButonu(
                            icon: Icons.add_rounded,
                            tooltip: 'Zoom +',
                            onTap: _zoomIn,
                          ),
                          const SizedBox(height: 6),
                          _buildHaritaAksiyonButonu(
                            icon: Icons.remove_rounded,
                            tooltip: 'Zoom -',
                            onTap: _zoomOut,
                          ),
                        ],
                      ),
                    ),

                    // 8. ALT PANEL: NAVİGASYON AKTİF İSE GOOGLE MAPS ALT BARI, SEÇİLEN NOKTA VARSA TOUCH-TO-ROUTE KARTI, DEĞİLSE "YOLA ÇIK" VE SİMÜLASYON BUTONU
                    if (widget.navigasyonAktif)
                      _buildNavigasyonAktifAltBar(width)
                    else if (_dokunulanNokta != null)
                      _buildDokunulanNoktaKarti(width)
                    else ...[
                      // Boştayken haritaya dokunarak rota belirleme rehber rozeti
                      if (!widget.simulasyonAktif)
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5.5),
                            decoration: BoxDecoration(
                              color: NavHtmlColors.surfaceContainerLowest.withValues(alpha: 0.90),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.touch_app_rounded, size: 13, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 5),
                                Text(
                                  widget.turkceMi ? 'Haritaya dokunarak rota belirleyin' : 'Tap map to set route',
                                  style: const TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 🧭 Google Maps Tarzı Gerçek Navigasyon Başlat
                            ElevatedButton.icon(
                              onPressed: widget.onBaslatNavigasyon,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                                elevation: 6,
                                shadowColor: const Color(0xFF10B981).withValues(alpha: 0.5),
                              ),
                              icon: const Icon(Icons.navigation_rounded, size: 18),
                              label: Text(
                                widget.turkceMi ? '🧭 Yola Çık (Navigasyon)' : '🧭 Start Navigation',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Hızlı Simülasyon Butonu
                            IconButton.filledTonal(
                              onPressed: widget.onToggleSimulasyon,
                              icon: Icon(
                                widget.simulasyonAktif ? Icons.stop_rounded : Icons.play_arrow_rounded,
                                size: 18,
                              ),
                              tooltip: widget.turkceMi ? 'Simülasyon' : 'Simulate',
                              style: IconButton.styleFrom(
                                backgroundColor: widget.simulasyonAktif
                                    ? const Color(0xFFDC2626)
                                    : NavHtmlColors.surfaceContainerHigh,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // 9. SOL ALT: YAKLAŞAN RADAR BİLGİ HUD ŞERİDİ (Simülasyon Aktifken)
                    if (widget.simulasyonAktif && widget.yaklasanRadar != null && !widget.navigasyonAktif && _dokunulanNokta == null)
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: math.max(120.0, width - 155)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: NavHtmlColors.primaryContainer.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: NavHtmlColors.primaryContainer.withValues(alpha: 0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${widget.yaklasanRadar!.hizLimiti}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${widget.yaklasanRadar!.ad} • ${widget.yaklasanRadarMesafeMetre.toInt()}m',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      Text(
                                        'Hızınız: ${widget.canliSurusHizi} km/s',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // 🧭 GOOGLE MAPS YEŞİL DÖNÜŞ MANEVRA BANNER'I (ÜST HUD)
  Widget _buildGoogleMapsTurnBanner(double width) {
    if (widget.aktifManevralar.isEmpty) return const SizedBox.shrink();
    final manevra = widget.aktifManevralar[
        widget.aktifManevraIndeksi.clamp(0, widget.aktifManevralar.length - 1)];

    final String mesafeStr = widget.mevcutManevrayaKalanMetre <= 40
        ? (widget.turkceMi ? 'ŞİMDİ DÖNÜN' : 'TURN NOW')
        : (widget.mevcutManevrayaKalanMetre < 1000
            ? '${widget.mevcutManevrayaKalanMetre.round()} m'
            : '${(widget.mevcutManevrayaKalanMetre / 1000).toStringAsFixed(1)} km');

    final int hizLimiti = manevra.bagliRadar?.hizLimiti ??
        (widget.rota.radarlar.isNotEmpty ? widget.rota.radarlar.first.hizLimiti : 75);

    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF064E3B), Color(0xFF022C22)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.7), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.25),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            // Manevra İkon Rozeti
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.25),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Icon(
                  manevra.ikon,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Manevra Metinleri & Mesafe
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        mesafeStr,
                        style: TextStyle(
                          color: widget.mevcutManevrayaKalanMetre <= 40
                              ? const Color(0xFF6EE7B7)
                              : Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (manevra.bagliRadar != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.speed_rounded, size: 10, color: Colors.white),
                              const SizedBox(width: 3),
                              Text(
                                '${manevra.bagliRadar!.hizLimiti} km/s',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.turkceMi ? manevra.baslik : manevra.baslikEn,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.turkceMi ? manevra.aciklama : manevra.aciklamaEn,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Hız Limiti & Canlı Hız
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Hız Limiti Yuvarlağı
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFDC2626), width: 2.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$hizLimiti',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Uydu Hızı
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    '${widget.canliSurusHizi} km/s',
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🗺️ GOOGLE MAPS ALT BARI (ETA, KALAN SÜRE, ADIM BUTONLARI VE DURDUR)
  Widget _buildNavigasyonAktifAltBar(double width) {
    final int kalanDk = widget.rota.tahminiDakika;
    final now = DateTime.now();
    final varisZamani = now.add(Duration(minutes: kalanDk));
    final saatStr = '${varisZamani.hour.toString().padLeft(2, '0')}:${varisZamani.minute.toString().padLeft(2, '0')}';

    final int toplamAdim = widget.aktifManevralar.length;
    final int suankiAdim = widget.aktifManevraIndeksi + 1;

    return Positioned(
      bottom: 10,
      left: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: NavHtmlColors.surfaceContainerLowest.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Tahmini Varış ve Kalan Süre
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        saatStr,
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.turkceMi ? 'Varış' : 'Arrival',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$kalanDk dk • ${widget.rota.mesafeKm} km',
                    style: TextStyle(
                      color: NavHtmlColors.secondary.withValues(alpha: 0.9),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Adım Atlama / Test Kontrolleri (Masaüstü/Evde Önizleme Kolaylığı)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: NavHtmlColors.surfaceContainerHigh.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: widget.aktifManevraIndeksi > 0 ? widget.onOncekiManevra : null,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        size: 20,
                        color: widget.aktifManevraIndeksi > 0 ? Colors.white : Colors.white24,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '$suankiAdim/$toplamAdim',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: widget.onSonrakiManevra,
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Durdur / Çık Butonu
            ElevatedButton.icon(
              onPressed: widget.onDurdurNavigasyon,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                elevation: 4,
              ),
              icon: const Icon(Icons.close_rounded, size: 15),
              label: Text(
                widget.turkceMi ? 'Durdur' : 'Stop',
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎯 HARİTADAN DOKUNARAK SEÇİLEN NOKTA AKSİYON KARTI (TOUCH-TO-ROUTE)
  Widget _buildDokunulanNoktaKarti(double width) {
    if (_dokunulanNokta == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 10,
      left: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.7), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.pin_drop_rounded,
                    color: Color(0xFFF59E0B),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.turkceMi ? 'Haritada Seçilen Konum' : 'Selected Map Location',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${_dokunulanNokta!.lat.toStringAsFixed(4)}° K, ${_dokunulanNokta!.lon.toStringAsFixed(4)}° D',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  icon: const Icon(Icons.close_rounded, size: 18, color: Colors.white60),
                  onPressed: () => setState(() => _dokunulanNokta = null),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final n = _dokunulanNokta!;
                      setState(() => _dokunulanNokta = null);
                      widget.onHedefNoktaSecildi?.call(n);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 3,
                    ),
                    icon: const Icon(Icons.flag_rounded, size: 14),
                    label: Text(
                      widget.turkceMi ? 'Buraya Git (Hedef)' : 'Route Here (Destination)',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final n = _dokunulanNokta!;
                      setState(() => _dokunulanNokta = null);
                      widget.onBaslangicNoktaSecildi?.call(n);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF38BDF8),
                      side: const BorderSide(color: Color(0xFF38BDF8), width: 1.2),
                      backgroundColor: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.trip_origin_rounded, size: 14),
                    label: Text(
                      widget.turkceMi ? 'Buradan Başla' : 'Start Here',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGpsPin({
    required double lat,
    required double lon,
    required String label,
    required Color color,
    required IconData icon,
    required double width,
    required double height,
    required double tileSize,
    required double centerTileX,
    required double centerTileY,
    required int intZoom,
  }) {
    final pTileX = lonToTileX(lon, intZoom.toDouble());
    final pTileY = latToTileY(lat, intZoom.toDouble());
    final px = width / 2.0 + (pTileX - centerTileX) * tileSize;
    final py = height / 2.0 + (pTileY - centerTileY) * tileSize;

    if (px < -60 || px > width + 60 || py < -60 || py > height + 60) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: px - 45,
      top: py - 40,
      width: 90,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: NavHtmlColors.surfaceContainerLowest.withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color, width: 1.2),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Icon(icon, size: 13, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildHaritaAksiyonButonu({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool aktifMi = false,
    Color? aktifRenk,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: aktifMi
                ? (aktifRenk ?? NavHtmlColors.primaryContainer).withValues(alpha: 0.25)
                : NavHtmlColors.surfaceContainerLowest.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: aktifMi
                  ? (aktifRenk ?? NavHtmlColors.primaryContainer)
                  : Colors.white.withValues(alpha: 0.16),
              width: aktifMi ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: aktifMi ? (aktifRenk ?? Colors.white) : Colors.white,
            size: 17,
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 🎨 GERÇEK GPS POLYLİNE ÇİZİCİSİ (CANLI TRAFİK RENKLERİYLE)
// ==========================================
class _RealGpsRoutePainter extends CustomPainter {
  final List<OsrmRoutePoint> points;
  final double centerLon;
  final double centerLat;
  final double zoom;
  final double tileSize;
  final double width;
  final double height;
  final double simulasyonIlerleme;
  final bool simulasyonAktif;
  final double pulseValue;
  final bool trafikKatmaniAcik;
  final List<KktcTrafikNoktasi> trafikNoktalari;

  _RealGpsRoutePainter({
    required this.points,
    required this.centerLon,
    required this.centerLat,
    required this.zoom,
    required this.tileSize,
    required this.width,
    required this.height,
    required this.simulasyonIlerleme,
    required this.simulasyonAktif,
    required this.pulseValue,
    this.trafikKatmaniAcik = true,
    this.trafikNoktalari = const [],
  });

  static double lonToTileX(double lon, double zoom) {
    return ((lon + 180.0) / 360.0 * math.pow(2.0, zoom));
  }

  static double latToTileY(double lat, double zoom) {
    final rad = lat * math.pi / 180.0;
    final sinVal = math.sin(rad).clamp(-0.9999, 0.9999);
    return ((1.0 - math.log((1.0 + sinVal) / (1.0 - sinVal)) / (2.0 * math.pi)) / 2.0 * math.pow(2.0, zoom));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final intZoom = zoom.floor().toDouble();
    final centerTileX = lonToTileX(centerLon, intZoom);
    final centerTileY = latToTileY(centerLat, intZoom);

    final screenPoints = <Offset>[];
    for (var pt in points) {
      final pTileX = lonToTileX(pt.lon, intZoom);
      final pTileY = latToTileY(pt.lat, intZoom);
      final px = width / 2.0 + (pTileX - centerTileX) * tileSize;
      final py = height / 2.0 + (pTileY - centerTileY) * tileSize;
      screenPoints.add(Offset(px, py));
    }

    if (screenPoints.length < 2) return;

    // 1. Dış Kontur Çizgisi (Doğal gölge & net sınır - Apple / Google Haritalar stili)
    final routePath = Path();
    routePath.moveTo(screenPoints.first.dx, screenPoints.first.dy);
    for (int i = 1; i < screenPoints.length; i++) {
      routePath.lineTo(screenPoints[i].dx, screenPoints[i].dy);
    }

    final outlinePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(routePath, outlinePaint);

    // 2. Canlı Trafik Renkli Polyline Çizimi
    if (trafikKatmaniAcik && points.length == screenPoints.length) {
      for (int i = 0; i < screenPoints.length - 1; i++) {
        final pt = points[i];

        // Bu noktaya en yakın kritik trafik noktası var mı?
        Color segColor = NavHtmlColors.trafficClear; // Varsayılan akıcı yeşil
        double minDistance = double.infinity;
        KktcTrafikNoktasi? enYakinTrafik;

        for (final tn in trafikNoktalari) {
          final dLat = (tn.lat - pt.lat).abs();
          final dLon = (tn.lon - pt.lon).abs();
          final dist = math.sqrt(dLat * dLat + dLon * dLon);
          if (dist < minDistance) {
            minDistance = dist;
            enYakinTrafik = tn;
          }
        }

        // Eğer yoğun trafik noktasına yakınsa (3-4 km)
        if (enYakinTrafik != null && minDistance < 0.035) {
          if (enYakinTrafik.yogunlukYuzde >= 75) {
            segColor = NavHtmlColors.trafficHeavy; // Sıkışık kırmızı
          } else if (enYakinTrafik.yogunlukYuzde >= 45) {
            segColor = NavHtmlColors.trafficModerate; // Kehribar / sarı
          }
        }

        final segPaint = Paint()
          ..color = segColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.8
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        canvas.drawLine(screenPoints[i], screenPoints[i + 1], segPaint);
      }
    } else {
      // Trafik kapalıyken Apple Maps şık mavi rota çizgisi
      final linePaint = Paint()
        ..color = const Color(0xFF0A84FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(routePath, linePaint);
    }

    // 3. Simülasyon Aracı (Apple Haritalar tarzı modern navigasyon imleci)
    if (simulasyonAktif && simulasyonIlerleme > 0.0 && screenPoints.length >= 2) {
      double t = simulasyonIlerleme.clamp(0.0, 1.0);
      int segIndex = (t * (screenPoints.length - 1)).floor();
      double segT = (t * (screenPoints.length - 1)) - segIndex;

      Offset carPos = screenPoints.last;
      if (segIndex < screenPoints.length - 1) {
        Offset p1 = screenPoints[segIndex];
        Offset p2 = screenPoints[segIndex + 1];
        carPos = Offset(p1.dx + (p2.dx - p1.dx) * segT, p1.dy + (p2.dy - p1.dy) * segT);
      }

      final carHalo = Paint()
        ..color = const Color(0xFF0A84FF).withValues(alpha: 0.25)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(carPos, 16, carHalo);

      final carRim = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(carPos, 8.5, carRim);

      final carCenter = Paint()
        ..color = const Color(0xFF0A84FF)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(carPos, 6, carCenter);
    }
  }

  @override
  bool shouldRepaint(covariant _RealGpsRoutePainter oldDelegate) {
    return oldDelegate.centerLon != centerLon ||
        oldDelegate.centerLat != centerLat ||
        oldDelegate.zoom != zoom ||
        oldDelegate.simulasyonIlerleme != simulasyonIlerleme ||
        oldDelegate.simulasyonAktif != simulasyonAktif ||
        oldDelegate.trafikKatmaniAcik != trafikKatmaniAcik ||
        oldDelegate.points != points;
  }
}

// ==========================================
// 📍 GELİŞMİŞ NOKTA SEÇİM BOTTOM SHEETİ
// ==========================================
class _NoktaSeciciBottomSheet extends StatefulWidget {
  final bool turkceMi;
  final String baslik;
  final RotaNoktasi secilenNokta;
  final List<RotaNoktasi> noktalar;
  final ValueChanged<RotaNoktasi> onSecildi;

  const _NoktaSeciciBottomSheet({
    required this.turkceMi,
    required this.baslik,
    required this.secilenNokta,
    required this.noktalar,
    required this.onSecildi,
  });

  @override
  State<_NoktaSeciciBottomSheet> createState() => _NoktaSeciciBottomSheetState();
}

class _NoktaSeciciBottomSheetState extends State<_NoktaSeciciBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _seciliBolge = 'Tümü';
  String _aramaMetni = '';

  final List<String> _bolgeler = [
    'Tümü',
    'Girne',
    'Lefkoşa',
    'Güzelyurt',
    'Gazimağusa',
    'İskele',
    'Lefke',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _canliGpsSec() async {
    final gps = CanliGpsServisi();
    if (!gps.gpsAktif) {
      await gps.servisiBaslat();
    }
    if (!mounted) return;

    final pos = gps.sonKonum;
    if (pos != null) {
      final liveNokta = RotaNoktasi(
        id: "live_gps",
        ad: widget.turkceMi
            ? "📍 Canlı GPS Konumum (${pos.latitude.toStringAsFixed(3)}, ${pos.longitude.toStringAsFixed(3)})"
            : "📍 Live GPS Location (${pos.latitude.toStringAsFixed(3)}, ${pos.longitude.toStringAsFixed(3)})",
        adEn: "📍 Live GPS Location",
        kisaAd: widget.turkceMi ? "Canlı Konumum" : "My Location",
        bolge: "Anlık GPS",
        lat: pos.latitude,
        lon: pos.longitude,
        ikon: Icons.my_location_rounded,
      );
      widget.onSecildi(liveNokta);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.turkceMi
                ? 'GPS uyduları aranıyor, lütfen açık alanda birkaç saniye bekleyin...'
                : 'Acquiring GPS fix, please wait a few seconds...',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  int _noktaSayisi(String b) {
    if (b == 'Tümü') return widget.noktalar.length;
    return widget.noktalar.where((n) => n.bolge.toLowerCase().contains(b.toLowerCase())).length;
  }

  List<RotaNoktasi> get _filtrelenmisNoktalar {
    return widget.noktalar.where((n) {
      // Bölge Filtresi
      if (_seciliBolge != 'Tümü' && !n.bolge.toLowerCase().contains(_seciliBolge.toLowerCase())) {
        return false;
      }
      // Metin Arama
      if (_aramaMetni.trim().isNotEmpty) {
        final query = _aramaMetni.trim().toLowerCase();
        final matchAd = n.ad.toLowerCase().contains(query);
        final matchEn = n.adEn.toLowerCase().contains(query);
        final matchKisa = n.kisaAd.toLowerCase().contains(query);
        final matchBolge = n.bolge.toLowerCase().contains(query);
        return matchAd || matchEn || matchKisa || matchBolge;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final sonuclar = _filtrelenmisNoktalar;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: NavHtmlColors.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tutma çubuğu
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Başlık ve Kapat Butonu
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.baslik,
                        style: const TextStyle(
                          color: NavHtmlColors.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.turkceMi
                            ? "Lapta, Alsancak, Girne ve tüm KKTC noktaları (${widget.noktalar.length} nokta)"
                            : "All TRNC locations (${widget.noktalar.length} destinations)",
                        style: const TextStyle(
                          color: NavHtmlColors.secondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: NavHtmlColors.secondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Arama Girişi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              decoration: BoxDecoration(
                color: NavHtmlColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                onChanged: (val) {
                  setState(() {
                    _aramaMetni = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: widget.turkceMi
                      ? 'Nokta veya ilçe ara (örn: Lapta, Alsancak, Girne...)'
                      : 'Search location (e.g. Lapta, Alsancak...)',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 12.5),
                  prefixIcon: const Icon(Icons.search_rounded, color: NavHtmlColors.tertiary, size: 20),
                  suffixIcon: _aramaMetni.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: Colors.white54, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _aramaMetni = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
          ),

          // Bölge Filtre Butonları (Horizontal Chips)
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              scrollDirection: Axis.horizontal,
              itemCount: _bolgeler.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final b = _bolgeler[i];
                final secili = _seciliBolge == b;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _seciliBolge = b;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: secili
                          ? NavHtmlColors.primaryContainer.withValues(alpha: 0.3)
                          : NavHtmlColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: secili ? NavHtmlColors.primaryContainer : Colors.white12,
                        width: secili ? 1.4 : 1.0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        b == 'Tümü' ? 'Tümü (${widget.noktalar.length})' : '$b (${_noktaSayisi(b)})',
                        style: TextStyle(
                          color: secili ? Colors.white : NavHtmlColors.secondary,
                          fontSize: 11.5,
                          fontWeight: secili ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(color: Colors.white10, height: 16),

          // 📍 CANLI GPS KONUMUNU KULLAN BUTONU
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: InkWell(
              onTap: _canliGpsSec,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0369A1), Color(0xFF0284C7)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.turkceMi ? 'Canlı GPS Konumumu Seç' : 'Use Current Live GPS',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.turkceMi
                                ? 'Cihazınızın anlık uydu koordinatlarını başlangıç noktası yapar'
                                : 'Sets start point to live satellite coordinates',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Liste Görünümü
          Expanded(
            child: sonuclar.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_off_rounded, size: 36, color: Colors.white30),
                        const SizedBox(height: 8),
                        Text(
                          widget.turkceMi ? 'Sonuç bulunamadı' : 'No locations found',
                          style: const TextStyle(color: NavHtmlColors.secondary, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    itemCount: sonuclar.length,
                    itemBuilder: (context, idx) {
                      final nokta = sonuclar[idx];
                      final isSelected = nokta.id == widget.secilenNokta.id;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? NavHtmlColors.primaryContainer.withValues(alpha: 0.15)
                              : NavHtmlColors.surfaceContainerLowest.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? NavHtmlColors.primaryContainer.withValues(alpha: 0.8)
                                : Colors.white.withValues(alpha: 0.05),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: ListTile(
                          onTap: () => widget.onSecildi(nokta),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? NavHtmlColors.primaryContainer.withValues(alpha: 0.3)
                                  : NavHtmlColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              nokta.ikon,
                              color: isSelected ? NavHtmlColors.primaryContainer : NavHtmlColors.secondary,
                              size: 19,
                            ),
                          ),
                          title: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: NavHtmlColors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Text(
                                  nokta.bolge,
                                  style: const TextStyle(
                                    color: NavHtmlColors.tertiary,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.turkceMi ? nokta.ad : nokta.adEn,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : NavHtmlColors.onSurface,
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              nokta.kisaAd,
                              style: const TextStyle(
                                color: NavHtmlColors.secondary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          trailing: isSelected
                              ? const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: NavHtmlColors.primaryContainer,
                                  child: Icon(Icons.check_rounded, color: Colors.white, size: 16),
                                )
                              : const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.white24,
                                  size: 18,
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

