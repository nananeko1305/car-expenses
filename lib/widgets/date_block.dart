import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';
import 'skewed.dart';

/// A day as a leaning dark block: the day number over the short month,
/// like a start number. Leads a row of a list that runs by date.
class DateBlock extends StatelessWidget {
  const DateBlock(this.date, {super.key});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final month = DateFormat.MMM(locale).format(date).replaceAll('.', '');
    return Skewed(
      angle: Skewed.eightDegrees,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: c.ink,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                color: c.background,
                fontSize: 19,
                height: 1,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              month.toUpperCase(),
              style: TextStyle(
                color: c.background,
                fontSize: 11,
                height: 1.2,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
