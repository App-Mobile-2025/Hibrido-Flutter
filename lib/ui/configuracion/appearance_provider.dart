import 'package:flutter/material.dart';

enum AppThemeMode {
  system,
  light,
  dark,
}

class AppearanceProvider extends ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.system;
  double _textScale = 1.0; // 1.0 = normal

  AppThemeMode get themeMode => _themeMode;
  double get textScale => _textScale;

  void setThemeMode(AppThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setTextScale(double scale) {
    _textScale = scale.clamp(0.8, 1.4); // min 80%, max 140%
    notifyListeners();
  }

  // Helper para usar en MaterialApp
  ThemeMode get flutterThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
      default:
        return ThemeMode.system;
    }
  }
}
