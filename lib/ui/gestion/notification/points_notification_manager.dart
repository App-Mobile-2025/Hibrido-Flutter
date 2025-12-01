import 'package:reciclapp/data/services/notification_service.dart';
import 'package:reciclapp/ui/configuracion/provider/notification_provider.dart';

class PointsNotificationManager {
  final NotificationService _notificationService;

  PointsNotificationManager(this._notificationService);

  Future<void> procesarNotificaciones({
    required int puntos,
    required DateTime? puntosVencimiento,
    required NotificationSettingsProvider settings,
  }) async {
    // Si las notificaciones están desactivadas → nada
    if (!settings.notificationsEnabled || !settings.pointsReminderEnabled) {
      return;
    }

    // Notificación por umbral de puntos
    const int threshold = 1000;
    if (puntos >= threshold) {
      await _notificationService.showPointsThresholdNotification(puntos);
    }

    //Notificación por vencimiento de puntos
    if (puntosVencimiento != null) {
      await _programarVencimiento(puntosVencimiento);
    }
  }

  Future<void> _programarVencimiento(DateTime expiry) async {
    print("CHECK VENCIMIENTO -> $expiry");

    final now = DateTime.now();
    final diff = expiry.difference(now).inDays;

    print("DIAS RESTANTES: $diff");

    if (diff > 30) {
      print("FALTAN MÁS DE 30 DIAS → no notifico");
      return;
    }

    if (diff <= 0) {
      print("YA VENCIO → no notifico");
      return;
    }

    print("PROGRAMANDO NOTI para $expiry");
    await _notificationService.schedulePointsExpiryNotification(expiry);
  }
}
