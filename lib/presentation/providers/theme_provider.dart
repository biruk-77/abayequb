import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isSimpleMode = false;
  static const String _prefKey = 'selected_theme';
  static const String _simpleModeKey = 'simple_mode';

  ThemeMode get themeMode => _themeMode;
  bool get isSimpleMode => _isSimpleMode;

  ThemeProvider() {
    _loadFromPrefs();
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, mode.name);
  }

  void toggleSimpleMode(bool value) async {
    _isSimpleMode = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_simpleModeKey, value);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_prefKey);
    if (themeName != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.name == themeName,
        orElse: () => ThemeMode.system,
      );
      notifyListeners();
    }
    
    _isSimpleMode = prefs.getBool(_simpleModeKey) ?? false;
    notifyListeners();
  }
}
