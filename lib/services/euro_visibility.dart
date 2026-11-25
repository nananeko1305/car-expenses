import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whether the wallet shows its euro amounts, kept on the device. Off
/// until someone turns it on, since payment in euros is rare.
class EuroVisibility extends ChangeNotifier {
  static const _key = 'show_euros';

  bool _shown = false;
  bool get shown => _shown;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _shown = prefs.getBool(_key) ?? false;
    notifyListeners();
  }

  Future<void> set(bool shown) async {
    _shown = shown;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, shown);
  }
}

final EuroVisibility euroVisibility = EuroVisibility();
