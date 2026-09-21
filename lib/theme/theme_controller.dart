import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_palette.dart';

/// Holds the selected palette AND light/dark mode; persists both.
class ThemeController extends ChangeNotifier {
  static const _key = 'theme_id';
  static const _darkKey = 'dark_mode';

  AppPalette _current = kPalettes.first;
  bool _dark = false;

  AppPalette get current => _current;
  bool get isDark => _dark;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_key);
    _current = kPalettes.firstWhere(
      (p) => p.id == id,
      orElse: () => kPalettes.first,
    );
    _dark = prefs.getBool(_darkKey) ?? false;
    notifyListeners();
  }

  Future<void> select(AppPalette palette) async {
    _current = palette;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, palette.id);
  }

  Future<void> setDark(bool dark) async {
    _dark = dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkKey, dark);
  }
}

final ThemeController themeController = ThemeController();
