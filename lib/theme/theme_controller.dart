import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_palette.dart';

/// Holds the selected palette and whether the app is light, dark, or
/// follows the phone ([ThemeMode.system], the default); persists both.
class ThemeController extends ChangeNotifier {
  static const _key = 'theme_id';
  static const _modeKey = 'theme_mode';

  /// The on/off switch from before there were three choices.
  static const _oldDarkKey = 'dark_mode';

  AppPalette _current = kPalettes.first;
  ThemeMode _mode = ThemeMode.system;

  AppPalette get current => _current;
  ThemeMode get mode => _mode;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_key);
    _current = kPalettes.firstWhere(
      (p) => p.id == id,
      orElse: () => kPalettes.first,
    );
    _mode = _stored(prefs.getString(_modeKey), prefs.getBool(_oldDarkKey));
    notifyListeners();
  }

  /// Whoever turned the old dark switch on keeps dark. Everyone else now
  /// follows the phone: the switch being off was also just the default,
  /// so it does not say that light was chosen.
  static ThemeMode _stored(String? name, bool? oldDark) =>
      ThemeMode.values.where((m) => m.name == name).firstOrNull ??
      (oldDark == true ? ThemeMode.dark : ThemeMode.system);

  Future<void> select(AppPalette palette) async {
    _current = palette;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, palette.id);
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, mode.name);
  }
}

final ThemeController themeController = ThemeController();
