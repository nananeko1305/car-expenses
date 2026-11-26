import 'package:flutter/material.dart';

import 'app_palette.dart';

/// App-specific colors, carried by the [ThemeData] so that every widget
/// reading them through `context.colors` rebuilds when the palette or
/// light/dark mode changes.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.soft,
    required this.background,
    required this.ink,
    required this.surface,
  });

  factory AppColors.from(AppPalette p, {required bool dark}) => AppColors(
    primary: dark ? p.primaryOnDark : p.primary,
    soft: dark ? p.darkSoft : p.soft,
    background: dark ? p.darkBg : p.bg,
    ink: dark ? p.darkInk : p.ink,
    surface: dark ? p.darkSurface : Colors.white,
  );

  /// Accent: buttons, amounts, icons.
  final Color primary;

  /// Tinted background for avatars and highlights.
  final Color soft;
  final Color background;

  /// Main text color; use with alpha for secondary text.
  final Color ink;
  final Color surface;

  /// Soft top-to-bottom gradient for the full-screen pages.
  BoxDecoration get softGradient => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [soft, background],
    ),
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? soft,
    Color? background,
    Color? ink,
    Color? surface,
  }) => AppColors(
    primary: primary ?? this.primary,
    soft: soft ?? this.soft,
    background: background ?? this.background,
    ink: ink ?? this.ink,
    surface: surface ?? this.surface,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      soft: Color.lerp(soft, other.soft, t)!,
      background: Color.lerp(background, other.background, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  /// The current [AppColors]; registers a dependency on the theme.
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
