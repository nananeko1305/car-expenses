import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/repair.dart';
import '../models/report.dart';
import '../money/money.dart';
import '../theme/app_colors.dart';

/// What the shown services earned this month. All time is left to the
/// report, which tapping it opens.
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
    final locale = Localizations.localeOf(context).toLanguageTag();
    final month = Report.of(month: DateTime.now(), repairs: repairs);
    final soft = Colors.white.withValues(alpha: 0.85);

    return Material(
      color: context.colors.primary,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpenReport,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.earnedThisMonth,
                      style: TextStyle(
                        color: soft,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    t.openReport,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.white),
                ],
              ),
              const SizedBox(height: 6),
              for (final line in formatSums(month.earned, locale))
                Text(
                  line,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                t.repairsCount(month.services),
                style: TextStyle(color: soft),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
