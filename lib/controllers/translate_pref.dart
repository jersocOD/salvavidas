import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as Ui;

enum _LocalizationType { Country, Language }

class TranslatePreferences implements ITranslatePreferences {
  static const String _selectedLocaleKey = 'selected_locale';

  @override
  Future<Locale> getPreferredLocale() async {
    final preferences = await SharedPreferences.getInstance();

    var locale = preferences.getString(_selectedLocaleKey);
    if (locale == null) {
      String systemLanguage = _getSystemLanguage();
      locale = systemLanguage == "es" ? systemLanguage : "en";
      savePreferredLocale(localeFromString(locale));
    }
    return localeFromString(locale);
  }

  @override
  Future savePreferredLocale(Locale locale) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_selectedLocaleKey, localeToString(locale));
  }

  String _getSystemLanguage() {
    String languageCode;
    try {
      languageCode = Ui.window.locale.languageCode;
      if (languageCode != null) {
        return languageCode;
      } else
        throw Exception("Did not found a language in Ui");
    } catch (e) {
      try {
        return _getLocaleCountryOrLanguage(_LocalizationType.Language);
      } catch (e) {
        return "en";
      }
    }
  }

  String _getLocaleCountryOrLanguage(_LocalizationType localizationType) {
    String _localeStringAlternative = Platform.localeName;

    switch (localizationType) {
      case _LocalizationType.Country:
        return _localeStringAlternative.split("_")[1];
      case _LocalizationType.Language:
        return _localeStringAlternative.split("_")[0];
    }
  }
}
