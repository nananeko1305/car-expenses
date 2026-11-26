import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app has two whole interfaces over the same data: the leaning one
/// in `lib/screens` and `lib/widgets`, which is what a phone starts
/// with, and the classic one from before 2.0 in `lib/classic`.
enum UiStyle { leaning, classic }

/// Which interface this phone shows; kept on the device.
class UiChoice extends ChangeNotifier {
  static const _key = 'ui_style';

  UiStyle _style = UiStyle.leaning;
  UiStyle get style => _style;
  bool get isClassic => _style == UiStyle.classic;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_key);
    _style =
        UiStyle.values.where((s) => s.name == name).firstOrNull ??
        UiStyle.leaning;
    notifyListeners();
  }

  Future<void> set(UiStyle style) async {
    _style = style;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, style.name);
  }
}

final UiChoice uiChoice = UiChoice();
