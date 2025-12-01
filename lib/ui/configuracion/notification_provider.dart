import 'package:flutter/foundation.dart';

class NotificationSettingsProvider extends ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _pointsReminderEnabled = true;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get pointsReminderEnabled => _pointsReminderEnabled;

  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;

    if (!value) {
      _pointsReminderEnabled = false;
    }

    notifyListeners();
  }

  void setPointsReminderEnabled(bool value) {
    _pointsReminderEnabled = value;
    notifyListeners();
  }
}
