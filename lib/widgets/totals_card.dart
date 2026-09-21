import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/repair.dart';
import '../money/money.dart';
import '../theme/app_theme.dart';

/// Sum of the shown repairs, one line per currency (RSD and EUR are
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
    final lines = Currency.values
        .where(sums.containsKey)
        .map((c) => formatMoney(sums[c]!, c, locale))
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.terracotta,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.total,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          for (final line
              in lines.isEmpty ? [formatMoney(0, Currency.rsd, locale)] : lines)
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
            t.repairsCount(repairs.length),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
          ),
        ],
      ),
    );
  }
}
