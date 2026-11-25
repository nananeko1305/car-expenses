import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';

/// "‹ OCTOBER 2026 ›": steps one month back or forth, never past
/// [first] or [last] (both the first day of their month).
class MonthSwitcher extends StatelessWidget {
  const MonthSwitcher({
    super.key,
    required this.month,
    required this.first,
    required this.last,
    required this.onChanged,
  });

  final DateTime month;
  final DateTime first;
  final DateTime last;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Row(
      children: [
        IconButton(
          tooltip: t.previousMonth,
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: month.isAfter(first)
              ? () => onChanged(DateTime(month.year, month.month - 1))
              : null,
        ),
        Expanded(
          child: Text(
            DateFormat.yMMMM(locale).format(month).toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          tooltip: t.nextMonth,
          icon: const Icon(Icons.chevron_right_rounded, size: 28),
          onPressed: month.isBefore(last)
              ? () => onChanged(DateTime(month.year, month.month + 1))
              : null,
        ),
      ],
    );
  }
}
