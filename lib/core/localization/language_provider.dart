import 'package:flutter/material.dart';
import 'app_translations.dart';

class LanguageProvider extends ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.english;

  AppLanguage get currentLanguage => _currentLanguage;
  String get currentCode => _currentLanguage.code;

  void setLanguage(AppLanguage language) {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      notifyListeners();
    }
  }

  void setLanguageByCode(String code) {
    final lang = AppLanguage.fromCode(code);
    setLanguage(lang);
  }

  String translate(String key) {
    return AppTranslations.getText(key, _currentLanguage.code);
  }
}
