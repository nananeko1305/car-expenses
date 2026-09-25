import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/tool.dart';
import '../models/warranty.dart';
import '../theme/app_colors.dart';

/// How far a tool's warranty has run: empty on the day it was bought,
/// full once it is over.
///
/// [now] is passed in rather than read from the clock, so the bar can be
/// tested and so a whole list shares one instant.
class WarrantyBar extends StatelessWidget {
  const WarrantyBar({super.key, required this.tool, required this.now});

  final Tool tool;
  final DateTime now;

  static const _amber = Color(0xFFE0A63E);
  static const _red = Color(0xFFD94E4E);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final status = tool.status(now);
    final days = tool.daysLeft(now);
    final color = switch (status) {
      WarrantyStatus.active => context.colors.primary,
      WarrantyStatus.expiringSoon => _amber,
      WarrantyStatus.expired => _red,
    };
    // A full bar reads the same whether the warranty ended today or years
    // ago, so the label carries the meaning.
    final label = switch (status) {
      WarrantyStatus.expired => t.warrantyExpired,
      WarrantyStatus.expiringSoon when days == 0 => t.warrantyEndsToday,
      WarrantyStatus.expiringSoon => t.warrantyDaysLeft(days),
      WarrantyStatus.active => t.warrantyUntil(
        DateFormat.yMMMd(locale).format(tool.warrantyEnd),
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: tool.progress(now),
            minHeight: 6,
            backgroundColor: context.colors.soft,
            color: color,
            semanticsLabel: t.warranty,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: status == WarrantyStatus.active
                ? context.colors.ink.withValues(alpha: 0.65)
                : color,
          ),
        ),
      ],
    );
  }
}
