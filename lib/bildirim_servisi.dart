import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ==========================================
// 🔔 KKTC BİLDİRİM SERVİSİ
// Yaklaşan sabit radarlar için yerel bildirim gönderir.
// ==========================================
class KktcBildirimServisi {
  static final KktcBildirimServisi _instance = KktcBildirimServisi._();
  factory KktcBildirimServisi() => _instance;
  KktcBildirimServisi._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _hazir = false;
  final Set<String> _gonderilenRadarlar = {};

  Future<void> baslat() async {
    if (_hazir || kIsWeb) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(settings: const InitializationSettings(android: android, iOS: ios));

    // Android 13+ bildirim izni iste
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
    _hazir = true;
  }

  Future<void> radarUyarisi({
    required String radarId,
    required String baslik,
    required String mesaj,
  }) async {
    if (kIsWeb || _gonderilenRadarlar.contains(radarId)) return;
    _gonderilenRadarlar.add(radarId);
    await baslat();

    const detay = NotificationDetails(
      android: AndroidNotificationDetails(
        'radar_uygulama',
        'Radar Uyarıları',
        channelDescription: 'Yaklaşan sabit radar bildirimleri',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(id: radarId.hashCode.abs(), title: baslik, body: mesaj, notificationDetails: detay);
  }

  void listeSifirla() {
    _gonderilenRadarlar.clear();
  }
}
