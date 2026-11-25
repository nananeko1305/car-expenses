import 'package:flutter/material.dart';

import 'app_palette.dart';

/// App-specific colors, carried by the [ThemeData] so that every widget
/// reading them through `context.colors` rebuilds when the palette or
/// light/dark mode changes.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.accentText,
    required this.soft,
    required this.background,
    required this.ink,
    required this.muted,
    required this.surface,
    required this.panel,
    required this.line,
    required this.moneyIn,
    required this.moneyOut,
  });

  factory AppColors.from(AppPalette p, {required bool dark}) => AppColors(
    primary: dark ? p.primaryOnDark : p.primary,
    onPrimary: p.onPrimary,
    accentText: dark ? p.bright : p.deep,
    soft: dark ? p.darkSoft : p.soft,
    background: dark ? p.darkBg : p.bg,
    ink: dark ? p.darkInk : p.ink,
    muted: dark ? const Color(0xFFA7AEB8) : const Color(0xFF555C66),
    surface: dark ? p.darkSurface : Colors.white,
    panel: dark ? const Color(0xFF20242B) : const Color(0xFFF1F2F4),
    line: dark ? const Color(0xFF2C313A) : const Color(0xFFDADDE2),
    moneyIn: dark ? const Color(0xFF5FD08F) : const Color(0xFF0A6B3A),
    moneyOut: dark ? const Color(0xFFFF8A80) : const Color(0xFFB00320),
  );

  /// Accent: header blocks, main buttons, the selected state.
  final Color primary;

  /// Text and icons drawn on [primary].
  final Color onPrimary;

  /// The accent as text on [background]; [primary] itself is often too
  /// light or too dark to read there.
  final Color accentText;

  /// Tinted background for avatars and highlights.
  final Color soft;
  final Color background;

  /// Main text color. Also the fill of the dark "blocks" (date squares,
  /// the earned tile), whose text is then [background].
  final Color ink;

  /// Secondary text.
  final Color muted;
  final Color surface;

  /// Quiet fill for fields and tiles.
  final Color panel;

  /// Hairlines between rows and around boxes.
  final Color line;

  /// Money that came in, and money that went out.
  final Color moneyIn;
  final Color moneyOut;

  @override
  AppColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? accentText,
    Color? soft,
    Color? background,
    Color? ink,
    Color? muted,
    Color? surface,
    Color? panel,
    Color? line,
    Color? moneyIn,
    Color? moneyOut,
  }) => AppColors(
    primary: primary ?? this.primary,
    onPrimary: onPrimary ?? this.onPrimary,
    accentText: accentText ?? this.accentText,
    soft: soft ?? this.soft,
    background: background ?? this.background,
    ink: ink ?? this.ink,
    muted: muted ?? this.muted,
    surface: surface ?? this.surface,
    panel: panel ?? this.panel,
    line: line ?? this.line,
    moneyIn: moneyIn ?? this.moneyIn,
    moneyOut: moneyOut ?? this.moneyOut,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      primary: mix(primary, other.primary),
      onPrimary: mix(onPrimary, other.onPrimary),
      accentText: mix(accentText, other.accentText),
      soft: mix(soft, other.soft),
      background: mix(background, other.background),
      ink: mix(ink, other.ink),
      muted: mix(muted, other.muted),
      surface: mix(surface, other.surface),
      panel: mix(panel, other.panel),
      line: mix(line, other.line),
      moneyIn: mix(moneyIn, other.moneyIn),
      moneyOut: mix(moneyOut, other.moneyOut),
    );
  }
}

extension AppColorsContext on BuildContext {
  /// The current [AppColors]; registers a dependency on the theme.
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
