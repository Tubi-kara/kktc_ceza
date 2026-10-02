import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'radar_haritasi.dart';

// ==========================================
// 🛰️ GERÇEK CANLI GPS & SÜRÜŞ SERVİSİ
// ==========================================

class CanliGpsServisi extends ChangeNotifier {
  static final CanliGpsServisi _instance = CanliGpsServisi._internal();
  factory CanliGpsServisi() => _instance;
  CanliGpsServisi._internal();

  StreamSubscription<Position>? _positionSubscription;
  Position? _sonKonum;
  bool _gpsAktif = false;
  bool _izinVerildi = false;
  String _durumMesaji = 'GPS Bekleniyor';
  double _gercekHizKmh = 0.0;
  
  // En yakın radar bilgisi
  RadarKamerasi? _enYakinRadar;
  double _enYakinRadarMesafeMetre = 99999.0;
  bool _radarIkazVerildi = false;

  // Getters
  Position? get sonKonum => _sonKonum;
  bool get gpsAktif => _gpsAktif;
  bool get izinVerildi => _izinVerildi;
  String get durumMesaji => _durumMesaji;
  double get gercekHizKmh => _gercekHizKmh;
  RadarKamerasi? get enYakinRadar => _enYakinRadar;
  double get enYakinRadarMesafeMetre => _enYakinRadarMesafeMetre;

  String get enYakinRadarMesafeFormatli {
    if (_enYakinRadarMesafeMetre >= 90000) return '';
    if (_enYakinRadarMesafeMetre < 1000) {
      return '${_enYakinRadarMesafeMetre.round()}m';
    }
    return '${(_enYakinRadarMesafeMetre / 1000).toStringAsFixed(1)} km';
  }

  bool get kibrisSinirlariIcinde {
    if (_sonKonum == null) return false;
    return _sonKonum!.latitude >= 34.8 &&
        _sonKonum!.latitude <= 35.85 &&
        _sonKonum!.longitude >= 32.2 &&
        _sonKonum!.longitude <= 34.85;
  }

  /// GPS Servisini Başlat ve İzinleri Kontrol Et
  Future<bool> servisiBaslat() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _durumMesaji = 'Konum (GPS) servisi kapalı. Lütfen GPS\'i açın.';
        _gpsAktif = false;
        notifyListeners();
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _durumMesaji = 'Konum izni reddedildi.';
          _izinVerildi = false;
          _gpsAktif = false;
          notifyListeners();
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _durumMesaji = 'Konum izni kalıcı olarak engellendi. Ayarlardan izin veriniz.';
        _izinVerildi = false;
        _gpsAktif = false;
        notifyListeners();
        return false;
      }

      _izinVerildi = true;
      _gpsAktif = true;
      _durumMesaji = 'Canlı GPS Aktif (Uydular Bağlı)';
      notifyListeners();

      // İlk anlık konumu al
      try {
        Position ilkKonum = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
          ),
        );
        _konumGuncelle(ilkKonum);
      } catch (e) {
        debugPrint('İlk konum hatası: $e');
      }

      // Canlı konum akışını dinlemeye başla
      await _positionSubscription?.cancel();
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 2, // 2 metrede bir güncelle
      );

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          _konumGuncelle(position);
        },
        onError: (error) {
          _durumMesaji = 'GPS Hatası: $error';
          notifyListeners();
        },
      );

      return true;
    } catch (e) {
      _durumMesaji = 'GPS başlatılamadı: $e';
      _gpsAktif = false;
      notifyListeners();
      return false;
    }
  }

  /// Canlı gelen konumu işle ve en yakın radarı hesapla
  void _konumGuncelle(Position position) {
    _sonKonum = position;

    // Hız hesapla (m/s -> km/s). Dururken veya negatif hız gelirse 0 yap.
    if (position.speed > 0.5) {
      _gercekHizKmh = position.speed * 3.6;
    } else {
      _gercekHizKmh = 0.0;
    }

    _enYakinRadariHesapla(position.latitude, position.longitude);
    notifyListeners();
  }

  /// KKTC'deki tüm sabit radarlarla aradaki gerçek GPS mesafesini hesapla
  void _enYakinRadariHesapla(double userLat, double userLon) {
    if (kktcRadarListesi.isEmpty) return;

    RadarKamerasi? enYakin;
    double minMesafe = double.infinity;

    for (var radar in kktcRadarListesi) {
      double mesafeMetre = Geolocator.distanceBetween(
        userLat,
        userLon,
        radar.lat,
        radar.lon,
      );

      if (mesafeMetre < minMesafe) {
        minMesafe = mesafeMetre;
        enYakin = radar;
      }
    }

    _enYakinRadar = enYakin;
    _enYakinRadarMesafeMetre = minMesafe;

    // 500m İkaz Sistemi (Titreşim ve Ses)
    if (minMesafe <= 500 && !_radarIkazVerildi) {
      _radarIkazVerildi = true;
      // Fiziksel titreşim üret
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 300), () {
        HapticFeedback.heavyImpact();
      });
      SystemSound.play(SystemSoundType.alert);
    } else if (minMesafe > 600) {
      _radarIkazVerildi = false;
    }
  }

  /// Servisi Durdur
  void servisiDurdur() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _gpsAktif = false;
    _durumMesaji = 'GPS Durduruldu';
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}
