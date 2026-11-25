import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_palette.dart';
import 'theme_controller.dart';

/// AppTheme combines the selected palette and light/dark mode into
/// component styling. Widgets read colors via `context.colors`
/// ([AppColors]), never from static getters, so they repaint when the
/// mode or palette changes.
///
/// The look: one accent on a neutral ground, Exo 2 throughout, small
/// radii and hairlines instead of soft cards. The leaning shapes that go
/// with it are widgets (see `widgets/skewed.dart`), since a theme cannot
/// lean anything.
class AppTheme {
  static AppPalette get _p => themeController.current;

  /// The app's one typeface, bundled under `assets/fonts/`.
  static const fontFamily = 'Exo2';

  /// The corner of fields, buttons and tiles.
  static const radius = 8.0;

  /// The current palette as a light and as a dark theme. MaterialApp
  /// takes both and picks by [ThemeController.mode], which may leave the
  /// choice to the phone.
  static ThemeData get light => build(_p, false);
  static ThemeData get dark => build(_p, true);

  static ThemeData build(AppPalette p, bool dark) {
    final c = AppColors.from(p, dark: dark);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: p.primary,
          brightness: dark ? Brightness.dark : Brightness.light,
        ).copyWith(
          primary: c.primary,
          onPrimary: c.onPrimary,
          surface: c.background,
          onSurface: c.ink,
          onSurfaceVariant: c.muted,
          outline: c.line,
          outlineVariant: c.line,
        );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );

    return base.copyWith(
      extensions: [c],
      scaffoldBackgroundColor: c.background,
      dividerColor: c.line,
      dividerTheme: DividerThemeData(color: c.line, thickness: 1, space: 1),
      textTheme: base.textTheme.apply(bodyColor: c.ink, displayColor: c.ink),
      appBarTheme: AppBarTheme(
        backgroundColor: c.primary,
        surfaceTintColor: Colors.transparent,
        foregroundColor: c.onPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: overlayOn(c.onPrimary),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 24,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w800,
          color: c.onPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: c.line),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.panel,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        floatingLabelStyle: TextStyle(
          color: c.accentText,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w700,
        ),
        border: _border(Colors.transparent, width: 0),
        enabledBorder: _border(Colors.transparent, width: 0),
        disabledBorder: _border(Colors.transparent, width: 0),
        focusedBorder: _border(c.primary, width: 2),
        errorBorder: _border(c.moneyOut, width: 1.5),
        focusedErrorBorder: _border(c.moneyOut, width: 2),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: shape,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accentText,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          side: WidgetStatePropertyAll(BorderSide(color: c.ink, width: 1.5)),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? c.ink : c.background,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? c.background : c.ink,
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w800),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        elevation: 3,
        shape: shape,
        extendedTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w800,
        ),
      ),
      listTileTheme: ListTileThemeData(iconColor: c.ink),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? c.panel : c.ink,
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: dark ? c.ink : Colors.white,
        ),
        shape: shape,
      ),
    );
  }

  /// Status and navigation bar icons: dark on the light theme, light on
  /// the dark theme, over a transparent bar.
  static SystemUiOverlayStyle overlayStyle(bool dark) =>
      (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      );

  /// Status bar icons over an accent block, whose text is [foreground]:
  /// they take whichever of light and dark that text is.
  static SystemUiOverlayStyle overlayOn(Color foreground) => overlayStyle(
    ThemeData.estimateBrightnessForColor(foreground) == Brightness.light,
  );

  static OutlineInputBorder _border(Color color, {double width = 1.5}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: width == 0
          ? BorderSide.none
          : BorderSide(color: color, width: width),
    );
  }
}
