import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;
  static const String _prefKey = 'selected_language';

  Locale? get locale => _locale;

  LocaleProvider() {
    _loadFromPrefs();
  }

  void setLocale(Locale locale) async {
    if (!['en', 'am'].contains(locale.languageCode)) return;
    _locale = locale;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
  }

  void clearLocale() async {
    _locale = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(_prefKey);
    if (langCode != null) {
      _locale = Locale(langCode);
      notifyListeners();
    }
  }
}
