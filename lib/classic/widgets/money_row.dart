import 'package:flutter/material.dart';

import '../../models/repair.dart';
import '../../models/report.dart';
import '../../money/money.dart';
import '../theme/app_colors.dart';

/// A label with its amounts on the right, one line per currency.
/// [sign] goes before every amount but a zero. [minor] is a detail of
/// the row above; [strong] is the bottom line, shown in red where it
/// went negative.
class MoneyRow extends StatelessWidget {
  const MoneyRow({
    super.key,
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
                    '${shown[c] == 0 ? '' : sign}'
                    '${formatMoney(shown[c]!, c, locale)}',
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
