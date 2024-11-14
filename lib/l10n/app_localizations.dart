import 'package:flutter/material.dart';

import 'translations/app_en.dart';
import 'translations/app_th.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(context, AppLocalizations);
    return localizations ?? AppLocalizations(const Locale('th'));
  }
  
  String translate(String key) {
    final translation = _localizedValues[locale.languageCode]?[key];
    return translation ?? key;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'th': thTranslations,
    'en': enTranslations,
  };
}