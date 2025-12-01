import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal();

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // Timezone (para schedule)
    tz.initializeTimeZones();


    final location = tz.getLocation('America/Argentina/Buenos_Aires');
    tz.setLocalLocation(location);

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(initSettings);
    _initialized = true;
  }
Future<void> requestAndroidPermission() async {
  final androidImpl = _plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();

  await androidImpl?.requestNotificationsPermission();
}

  // Notificación inmediata para puntos
  Future<void> showPointsThresholdNotification(int points) async {
    const androidDetails = AndroidNotificationDetails(
      'points_channel',
      'Recordatorios de puntos',
      channelDescription: 'Avisos cuando tenés puntos para canjear',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      1001,
      '¡Tenés puntos para canjear!',
      'Ya acumulaste $points puntos en ReciclApp. ¿Querés ver los canjes disponibles?',
      details,
    );
  }

  // Notificación programada cerca de la fecha de vencimiento
  Future<void> schedulePointsExpiryNotification(DateTime expiryDate) async {
    // Por ejemplo, 3 días antes del vencimiento, a las 9:00
    final reminderDate = DateTime(
      expiryDate.year,
      expiryDate.month,
      expiryDate.day - 3,
      9,
      0,
    );

    // Si ya pasó, no agendamos nada
    if (reminderDate.isBefore(DateTime.now())) return;

final tzDateTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));

    const androidDetails = AndroidNotificationDetails(
      'points_expiry_channel',
      'Vencimiento de puntos',
      channelDescription: 'Recordatorios cuando tus puntos están por vencer',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      1002,
      'Tus puntos están por vencer',
      'Algunos de tus puntos de ReciclApp vencen pronto. ¡Aprovechá para canjearlos!',
      tzDateTime,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }
}
