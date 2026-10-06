import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'yol_tarifi_sayfasi.dart' show RotaNoktasi;
// ==========================================
// 🌍 SERBEST ADRES / MEKAN ARAMA (GEOCODING)
// Ücretsiz OpenStreetMap servisleri: Photon (yazarken tamamlama) + Nominatim (yedek)
// ==========================================
class KktcAdresAramaServisi {
  // Kıbrıs adası sınır kutusu (minLon, minLat, maxLon, maxLat)
  static const String _photonBbox = '32.20,34.55,34.65,35.72';
  static const String _nominatimViewbox = '32.20,35.72,34.65,34.55';
  static final Map<String, List<RotaNoktasi>> _onbellek = {};

  static Future<List<RotaNoktasi>> ara(String sorgu, {double? yakinLat, double? yakinLon, String dil = 'tr'}) async {
    final q = sorgu.trim();
    if (q.length < 2) return [];
    final key = '${q.toLowerCase()}|$dil';
    if (_onbellek.containsKey(key)) return _onbellek[key]!;

    List<RotaNoktasi> sonuc = [];
    try {
      sonuc = await _photonAra(q, yakinLat ?? 35.20, yakinLon ?? 33.36, dil);
    } catch (_) {}
    if (sonuc.isEmpty) {
      try {
        sonuc = await _nominatimAra(q, dil);
      } catch (_) {}
    }
    if (sonuc.isNotEmpty) _onbellek[key] = sonuc;
    return sonuc;
  }

  // Yalnızca Kuzey Kıbrıs (KKTC) sonuçlarını kabul et
  static bool _kkTcMi(String metin) {
    final t = metin.toLowerCase();
    return t.contains('kuzey') || t.contains('northern') || t.contains('kktc');
  }

  static Future<List<RotaNoktasi>> _photonAra(String q, double lat, double lon, String dil) async {
    final uri = Uri.parse('https://photon.komoot.io/api/').replace(queryParameters: {
      'q': q,
      'limit': '10',
      'lat': lat.toString(),
      'lon': lon.toString(),
      'bbox': _photonBbox,
      'lang': dil == 'en' ? 'en' : 'default',
    });
    final resp = await http.get(uri, headers: {
      if (!kIsWeb) 'User-Agent': 'KktcCezaApp/1.0',
    }).timeout(const Duration(seconds: 6));
    if (resp.statusCode != 200) return [];

    final data = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
    final features = (data['features'] as List<dynamic>?) ?? [];
    final List<RotaNoktasi> list = [];
    final Set<String> gorulen = {};

    for (final f in features) {
      final p = (f['properties'] as Map<String, dynamic>?) ?? {};
      final coords = (f['geometry']?['coordinates'] as List<dynamic>?) ?? [];
      if (coords.length < 2) continue;
      final fLon = (coords[0] as num).toDouble();
      final fLat = (coords[1] as num).toDouble();

      // KKTC filtresi: state/country alanında "Kuzey" veya "Northern" olmalı
      final stateAlan = (p['state'] ?? '').toString();
      final countryAlan = (p['country'] ?? '').toString();
      if (!_kkTcMi(stateAlan) && !_kkTcMi(countryAlan)) continue;

      final sokak = [p['street'], p['housenumber']].where((e) => e != null).join(' ');
      final ad = (p['name'] ?? (sokak.isNotEmpty ? sokak : null) ?? q).toString();
      final yer = (p['city'] ?? p['town'] ?? p['village'] ?? p['district'] ?? p['county'] ?? p['state'] ?? 'Kıbrıs').toString();
      final detay = [
        if (p['name'] != null && sokak.isNotEmpty) sokak,
        p['district'],
        p['city'] ?? p['county'],
      ].where((e) => e != null && e.toString().isNotEmpty).toSet().join(', ');

      final tekil = '$ad|${fLat.toStringAsFixed(4)}|${fLon.toStringAsFixed(4)}';
      if (!gorulen.add(tekil)) continue;

      list.add(RotaNoktasi(
        id: 'geo_${fLat.toStringAsFixed(5)}_${fLon.toStringAsFixed(5)}',
        ad: ad,
        adEn: ad,
        kisaAd: detay.isNotEmpty ? detay : yer,
        bolge: yer,
        lat: fLat,
        lon: fLon,
        ikon: _ikonSec(p['osm_key']?.toString(), p['osm_value']?.toString()),
        kategori: 'arama',
      ));
    }
    return list;
  }

  static Future<List<RotaNoktasi>> _nominatimAra(String q, String dil) async {
    final uri = Uri.parse('https://nominatim.openstreetmap.org/search').replace(queryParameters: {
      'q': q,
      'format': 'jsonv2',
      'limit': '10',
      'countrycodes': 'cy',
      'viewbox': _nominatimViewbox,
      'bounded': '0',
      'addressdetails': '1',
      'accept-language': dil,
    });
    final resp = await http.get(uri, headers: {
      if (!kIsWeb) 'User-Agent': 'KktcCezaApp/1.0 (karam3517@hotmail.com)',
    }).timeout(const Duration(seconds: 6));
    if (resp.statusCode != 200) return [];

    final items = jsonDecode(utf8.decode(resp.bodyBytes)) as List<dynamic>;
    return items.map((e) {
      final m = e as Map<String, dynamic>;
      final adr = (m['address'] as Map<String, dynamic>?) ?? {};
      // KKTC filtresi: address.country veya display_name "Kuzey Kıbrıs" içermeli
      final country = (adr['country'] ?? '').toString();
      final display = m['display_name']?.toString() ?? '';
      if (!_kkTcMi(country) && !_kkTcMi(display)) return null;
      final fLat = double.tryParse(m['lat'].toString()) ?? 0;
      final fLon = double.tryParse(m['lon'].toString()) ?? 0;
      final ad = (m['name']?.toString().isNotEmpty == true)
          ? m['name'].toString()
          : m['display_name'].toString().split(',').first;
      final yer = (adr['city'] ?? adr['town'] ?? adr['village'] ?? adr['county'] ?? 'Kıbrıs').toString();
      return RotaNoktasi(
        id: 'geo_${fLat.toStringAsFixed(5)}_${fLon.toStringAsFixed(5)}',
        ad: ad,
        adEn: ad,
        kisaAd: m['display_name'].toString().split(',').skip(1).take(3).join(',').trim(),
        bolge: yer,
        lat: fLat,
        lon: fLon,
        ikon: _ikonSec(m['category']?.toString(), m['type']?.toString()),
        kategori: 'arama',
      );
    }).where((e) => e != null).toList().whereType<RotaNoktasi>().toList();
  }

  static IconData _ikonSec(String? key, String? value) {
    switch (value) {
      case 'fuel':
        return Icons.local_gas_station_rounded;
      case 'hospital':
      case 'clinic':
      case 'pharmacy':
        return Icons.local_hospital_rounded;
      case 'restaurant':
      case 'fast_food':
      case 'cafe':
      case 'bar':
        return Icons.restaurant_rounded;
      case 'hotel':
      case 'guest_house':
        return Icons.hotel_rounded;
      case 'university':
      case 'school':
      case 'college':
        return Icons.school_rounded;
      case 'beach':
        return Icons.beach_access_rounded;
      case 'supermarket':
      case 'mall':
        return Icons.shopping_bag_rounded;
      case 'parking':
        return Icons.local_parking_rounded;
      case 'city':
      case 'town':
      case 'village':
      case 'suburb':
      case 'neighbourhood':
        return Icons.location_city_rounded;
    }
    if (key == 'highway') return Icons.add_road_rounded;
    if (key == 'building') return Icons.home_work_rounded;
    return Icons.place_rounded;
  }
}

