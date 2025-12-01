import 'package:flutter/material.dart';

enum AppLanguage { es, en, pt }

extension AppLanguageX on AppLanguage {
  String get flag {
    switch (this) {
      case AppLanguage.es:
        return '🇪🇸';
      case AppLanguage.en:
        return '🇺🇸';
      case AppLanguage.pt:
        return '🇧🇷';
    }
  }

  String get label {
    switch (this) {
      case AppLanguage.es:
        return 'Español';
      case AppLanguage.en:
        return 'English';
      case AppLanguage.pt:
        return 'Português';
    }
  }

  Locale get locale {
    switch (this) {
      case AppLanguage.es:
        return const Locale('es');
      case AppLanguage.en:
        return const Locale('en');
      case AppLanguage.pt:
        return const Locale('pt');
    }
  }
}

class LanguageProvider extends ChangeNotifier {
  AppLanguage _language = AppLanguage.es;

  AppLanguage get language => _language;

  void setLanguage(AppLanguage lang) {
    if (_language == lang) return;
    _language = lang;
    notifyListeners();
  }
}
