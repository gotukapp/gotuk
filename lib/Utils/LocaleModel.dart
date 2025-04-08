import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleModel extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  static const String _localeKey = 'selected_locale';

  LocaleModel() {
    _loadSavedLocale();
  }

  void set(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code != null) {
      _locale = Locale(code);
    } else {
      final deviceLocale = PlatformDispatcher.instance.locale;
      _locale = isSupported(deviceLocale.languageCode)
          ? deviceLocale
          : const Locale('en'); // fallback
    }

    notifyListeners();
  }

  bool isSupported(String code) {
    const supportedLocales = ['en', 'pt'];
    return supportedLocales.contains(code);
  }
}
