import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() { _loadTheme(); }
  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_themeKey) ?? 0;
    _themeMode = ThemeMode.values[index.clamp(0, 2)];
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  void toggleDarkMode() {
    if (_themeMode == ThemeMode.dark) setThemeMode(ThemeMode.light);
    else if (_themeMode == ThemeMode.light) setThemeMode(ThemeMode.dark);
    else setThemeMode(ThemeMode.dark);
  }
}
