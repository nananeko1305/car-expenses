import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/repair.dart';
import '../money/money.dart';
import '../theme/app_colors.dart';
import 'skewed.dart';

/// Sum of the shown repairs as the leaning dark block, one line per currency (RSD and EUR are
/// never mixed, since there is no reliable exchange rate to apply).
class TotalsCard extends StatelessWidget {
  const TotalsCard({super.key, required this.repairs});

  final List<Repair> repairs;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final sums = <Currency, int>{};
    for (final r in repairs) {
      sums[r.currency] = (sums[r.currency] ?? 0) + r.amountMinor;
    }

    final c = context.colors;
    return Skewed(
      angle: Skewed.eightDegrees,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
        decoration: BoxDecoration(
          color: c.ink,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.total,
                    style: TextStyle(
                      color: c.background,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  for (final line in formatSums(sums, locale))
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        line,
                        maxLines: 1,
                        style: TextStyle(
                          color: c.background,
                          fontSize: 22,
                          height: 1.15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              t.repairsCount(repairs.length),
              style: TextStyle(
                color: c.background,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
