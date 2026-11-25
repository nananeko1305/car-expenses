import 'package:flutter/material.dart';

/// One palette = one accent color. Everything around it is neutral: a
/// white or near-black ground and graphite ink, the same for every
/// accent, so the accent is the only thing a choice of color changes.
class AppPalette {
  const AppPalette({
    required this.id,
    required this.label,
    required this.primary,
    required this.deep,
    this.onPrimary = Colors.white,
  });

  final String id;
  final String label;

  /// The accent: header blocks, main buttons, the selected state.
  final Color primary;

  /// The accent dark enough to be read as text on the light ground.
  final Color deep;

  /// Text and icons on [primary]: white, or ink where the accent is light.
  final Color onPrimary;

  // --- light ground ---
  Color get bg => const Color(0xFFFFFFFF);
  Color get ink => const Color(0xFF101216);
  Color get soft => Color.alphaBlend(primary.withValues(alpha: 0.12), bg);

  // --- dark ground ---
  Color get primaryOnDark => primary;
  Color get darkBg => const Color(0xFF0E1014);
  Color get darkSurface => const Color(0xFF181B21);
  Color get darkInk => const Color(0xFFF2F3F5);
  Color get darkSoft =>
      Color.alphaBlend(primary.withValues(alpha: 0.24), darkBg);

  /// The accent light enough to be read as text on the dark ground.
  Color get bright {
    final hsl = HSLColor.fromColor(primary);
    return hsl.withLightness(hsl.lightness.clamp(0.68, 1.0)).toColor();
  }
}

/// All available palettes. The first is what a new install starts with.
const List<AppPalette> kPalettes = [
  AppPalette(
    id: 'crvena',
    label: 'Red',
    primary: Color(0xFFD90429),
    deep: Color(0xFFB00320),
  ),
  AppPalette(
    id: 'plava',
    label: 'Blue',
    primary: Color(0xFF1D4ED8),
    deep: Color(0xFF1A3FAE),
  ),
  AppPalette(
    id: 'topla',
    label: 'Warm',
    primary: Color(0xFFC2410C),
    deep: Color(0xFF9A3409),
  ),
  AppPalette(
    id: 'zelena',
    label: 'Green',
    primary: Color(0xFF0B7A43),
    deep: Color(0xFF075C32),
  ),
  AppPalette(
    id: 'zuta',
    label: 'Yellow',
    primary: Color(0xFFFFC400),
    deep: Color(0xFF7A5C00),
    onPrimary: Color(0xFF101216),
  ),
  AppPalette(
    id: 'ljubicasta',
    label: 'Purple',
    primary: Color(0xFF6D28D9),
    deep: Color(0xFF5521B5),
  ),
];
