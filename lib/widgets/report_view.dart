import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/report.dart';
import '../money/money.dart';
import '../theme/app_colors.dart';
import 'money_row.dart';
import 'skewed.dart';

/// One report laid out: what the services earned, how many cars and
/// services there were, then the money in and out down to the net.
class ReportView extends StatelessWidget {
  const ReportView({super.key, required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          // The blocks lean, so they need room at both ends.
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Skewed(
                angle: Skewed.eightDegrees,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 9, 14, 11),
                  decoration: BoxDecoration(
                    color: c.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.earnedFromServices,
                        style: TextStyle(
                          color: c.onPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      for (final line in formatSums(report.earned, locale))
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            line,
                            maxLines: 1,
                            style: TextStyle(
                              color: c.onPrimary,
                              fontSize: 28,
                              height: 1.1,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.directions_car_rounded,
                      value: report.cars,
                      label: t.vehicles,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.build_rounded,
                      value: report.services,
                      label: t.repairs,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
            child: Column(
              children: [
                MoneyRow(label: t.earnedFromServices, sums: report.earned),
                MoneyRow(label: t.otherIncome, sums: report.otherIncome),
                MoneyRow(label: t.costs, sums: report.costs, sign: '− '),
                MoneyRow(
                  label: t.ofWhichTools,
                  sums: report.tools,
                  minor: true,
                ),
                const Divider(height: 24),
                MoneyRow(label: t.net, sums: report.net, strong: true),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A count with its icon and what it counts, e.g. "8 Cars", as a
/// leaning tile.
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Skewed(
      angle: Skewed.eightDegrees,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: c.panel,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: c.ink),
            const SizedBox(width: 8),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 22,
                height: 1,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: c.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
