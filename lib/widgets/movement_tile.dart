import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/repair.dart';
import '../models/wallet_entry.dart';
import '../money/money.dart';
import '../theme/app_colors.dart';
import 'repair_card.dart';
import 'skewed.dart';

/// One wallet history line as a row: a block for its kind, what it was
/// for and the amount with its sign, and under them kind, date, person.
class MovementTile extends StatelessWidget {
  const MovementTile({
    super.key,
    required this.movement,
    required this.personName,
    required this.onTap,
  });

  final WalletMovement movement;
  final String personName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final m = movement;
    final incoming = m.signedMinor >= 0;
    final isService = m.repair != null;
    final (IconData icon, String kind) = switch (m) {
      _ when isService => (Icons.build_rounded, t.serviceIncome),
      _ when incoming => (Icons.south_west_rounded, t.deposit),
      _ => (Icons.north_east_rounded, t.withdrawal),
    };
    final color = incoming ? c.moneyIn : c.moneyOut;
    final amount = formatMoney(m.signedMinor.abs(), m.currency, locale);
    final date = DateFormat.MMMd(locale).format(m.date);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.line)),
        ),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Skewed(
                angle: Skewed.eightDegrees,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    // A service is the workshop's own work, so it gets the
                    // dark block; money moved by hand gets its color.
                    color: isService ? c.ink : color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isService ? c.background : color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          m.description.isEmpty ? kind : oneLine(m.description),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      MoneyText('${incoming ? '+' : '−'}$amount', color: color),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$kind · $date · $personName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: c.muted),
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
