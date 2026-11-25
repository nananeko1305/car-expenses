import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A registration plate, drawn as one: a white box with a firm border.
class PlateChip extends StatelessWidget {
  const PlateChip(this.plate, {super.key, this.fontSize = 12});

  final String plate;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.ink, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        plate,
        maxLines: 1,
        style: TextStyle(
          color: c.ink,
          fontSize: fontSize,
          height: 1.45,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
