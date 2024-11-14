import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _key = 'language_code';
  late SharedPreferences _prefs;
  Locale _locale = const Locale('th');

  LocaleProvider() {
    _loadLocale();
  }

  Locale get locale => _locale;

  Future<void> _loadLocale() async {
    _prefs = await SharedPreferences.getInstance();
    final String? languageCode = _prefs.getString(_key);
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
    print('Loaded locale: ${_locale.languageCode}'); // Debug print
  }

  Future<void> setLocale(Locale locale) async {
    print('Setting locale to: ${locale.languageCode}'); // Debug print
    if (_locale == locale) {
      print('Same locale, skipping'); // Debug print
      return;
    }
    
    _locale = locale;
    _prefs = await SharedPreferences.getInstance();
    await _prefs.setString(_key, locale.languageCode);
    print('Locale saved: ${locale.languageCode}'); // Debug print
    notifyListeners();
  }
}