import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/repair.dart';
import '../models/report.dart';
import '../money/money.dart';
import '../theme/app_colors.dart';
import 'skewed.dart';

/// What the shown services earned this month. All time is left to the
/// report, which tapping it opens.
///
/// Drawn for the accent block at the top of the services tab: its text
/// takes that block's text color.
class EarningsCard extends StatelessWidget {
  const EarningsCard({
    super.key,
    required this.repairs,
    required this.onOpenReport,
  });

  final List<Repair> repairs;
  final VoidCallback onOpenReport;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final month = Report.of(month: DateTime.now(), repairs: repairs);
    final small = TextStyle(
      color: c.onPrimary,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    );

    return InkWell(
      onTap: onOpenReport,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.earnedThisMonth, style: small),
                const SizedBox(height: 4),
                for (final line in formatSums(month.earned, locale))
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      line,
                      maxLines: 1,
                      style: TextStyle(
                        color: c.onPrimary,
                        fontSize: 30,
                        height: 1.05,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(t.repairsCount(month.services), style: small),
              const SizedBox(height: 6),
              Skewed(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
                  decoration: BoxDecoration(
                    color: c.onPrimary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t.openReport.toUpperCase(),
                        style: TextStyle(
                          color: c.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: c.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
