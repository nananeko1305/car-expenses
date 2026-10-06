import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/repair.dart';
import '../models/report.dart';
import '../money/money.dart';
import '../theme/app_colors.dart';

/// One report laid out: what the services earned, how many cars and
/// services there were, then the money in and out down to the net.
class ReportView extends StatelessWidget {
  const ReportView({super.key, required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.colors.primary,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.earnedFromServices,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              for (final line in formatSums(report.earned, locale))
                Text(
                  line,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.directions_car_rounded,
                value: report.cars,
                label: t.vehicles,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                icon: Icons.build_rounded,
                value: report.services,
                label: t.repairs,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _MoneyRow(label: t.earnedFromServices, sums: report.earned),
                _MoneyRow(label: t.otherIncome, sums: report.otherIncome),
                _MoneyRow(label: t.costs, sums: report.costs, sign: '− '),
                _MoneyRow(
                  label: t.ofWhichTools,
                  sums: report.tools,
                  minor: true,
                ),
                const Divider(height: 24),
                _MoneyRow(label: t.net, sums: report.net, strong: true),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A count with its icon and what it counts, e.g. "8 · Cars".
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: context.colors.soft,
              foregroundColor: context.colors.primary,
              child: Icon(icon, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.colors.ink.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A label with its amounts on the right, one line per currency.
/// [minor] is a detail of the row above; [strong] is the bottom line,
/// shown in red where it went negative.
class _MoneyRow extends StatelessWidget {
  const _MoneyRow({
    required this.label,
    required this.sums,
    this.sign = '',
    this.minor = false,
    this.strong = false,
  });

  static const _red = Color(0xFFD94E4E);

  final String label;
  final Amounts sums;
  final String sign;
  final bool minor;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final ink = context.colors.ink;
    final size = minor ? 13.0 : (strong ? 17.0 : 15.0);
    final weight = strong ? FontWeight.w800 : FontWeight.w600;
    final muted = ink.withValues(alpha: 0.6);
    final shown = sums.isEmpty ? {Currency.rsd: 0} : sums;

    return Padding(
      padding: EdgeInsets.fromLTRB(minor ? 16 : 0, 4, 0, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: size,
                fontWeight: weight,
                color: minor ? muted : ink,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final c in Currency.values)
                if (shown.containsKey(c))
                  Text(
                    '$sign${formatMoney(shown[c]!, c, locale)}',
                    style: TextStyle(
                      fontSize: size,
                      fontWeight: weight,
                      color: switch (shown[c]!) {
                        _ when minor => muted,
                        < 0 when strong => _red,
                        _ when strong => context.colors.primary,
                        _ => ink,
                      },
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }
}
