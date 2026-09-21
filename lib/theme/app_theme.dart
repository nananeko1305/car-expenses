import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'theme_controller.dart';

/// AppTheme combines the selected palette and light/dark mode into
/// component styling.
///
/// The names (terracotta/peach/cream/ink) are historical; they return the
/// colors of the CURRENT palette and mode.
class AppTheme {
  static bool get _dark => themeController.isDark;
  static AppPalette get _p => themeController.current;

  static Color get terracotta => _dark ? _p.primaryOnDark : _p.primary;
  static Color get peach => _dark ? _p.darkSoft : _p.soft;
  static Color get cream => _dark ? _p.darkBg : _p.bg;
  static Color get ink => _dark ? _p.darkInk : _p.ink;
  static Color get surface => _dark ? _p.darkSurface : Colors.white;
  static List<Color> get avatarColors => _p.avatars;

  static BoxDecoration get warmGradient => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [peach, cream],
    ),
  );

  /// Theme for the current palette + mode (used by MaterialApp).
  static ThemeData get current => build(_p, _dark);

  static ThemeData build(AppPalette p, bool dark) {
    final scheme = ColorScheme.fromSeed(
      seedColor: p.primary,
      brightness: dark ? Brightness.dark : Brightness.light,
    ).copyWith(surface: dark ? p.darkBg : p.bg);

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final surface = dark ? p.darkSurface : Colors.white;
    final ink = dark ? p.darkInk : p.ink;
    final primary = dark ? p.primaryOnDark : p.primary;

    return base.copyWith(
      scaffoldBackgroundColor: dark ? p.darkBg : p.bg,
      textTheme: base.textTheme.apply(bodyColor: ink, displayColor: ink),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: ink,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shadowColor: p.primary.withValues(alpha: dark ? 0.5 : 0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(backgroundColor: surface),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: surface),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? p.darkBg : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: _border(primary.withValues(alpha: 0.25)),
        enabledBorder: _border(primary.withValues(alpha: 0.25)),
        focusedBorder: _border(primary, width: 2),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? p.darkSurface : p.ink,
        contentTextStyle: TextStyle(color: dark ? p.darkInk : Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1.5}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
