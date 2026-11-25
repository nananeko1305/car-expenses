import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/repair.dart';
import '../models/vehicle.dart';
import '../money/money.dart';
import '../theme/app_colors.dart';
import 'date_block.dart';
import 'plate_chip.dart';
import 'skewed.dart';

/// One service as a row of a list: its day as a block, what was done and
/// the amount (or "no charge" where nobody paid), and under them the
/// car's plate and name, the mileage and who entered it.
class RepairCard extends StatelessWidget {
  const RepairCard({
    super.key,
    required this.repair,
    required this.vehicle,
    required this.authorName,
    required this.onTap,
  });

  final Repair repair;

  /// Null where the list is already about one car.
  final Vehicle? vehicle;
  final String authorName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final km = repair.mileage == null
        ? null
        : '${NumberFormat.decimalPattern(locale).format(repair.mileage)} km';
    final plate = vehicle?.plate ?? '';

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.line)),
        ),
        child: Row(
          children: [
            DateBlock(repair.date),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          oneLine(repair.description),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (repair.free)
                        SkewTag(AppLocalizations.of(context).noCharge)
                      else
                        MoneyText(
                          formatMoney(
                            repair.amountMinor,
                            repair.currency,
                            locale,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      if (plate.isNotEmpty) ...[
                        PlateChip(plate),
                        const SizedBox(width: 8),
                      ],
                      // The car's name gives way first: the plate next to
                      // it already says which car it is.
                      Expanded(
                        child: Text(
                          // Without a car to name, the mileage leads.
                          vehicle?.name ?? km ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, color: c.muted),
                        ),
                      ),
                      if (vehicle != null && km != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          km,
                          style: TextStyle(fontSize: 13, color: c.muted),
                        ),
                      ],
                      const SizedBox(width: 8),
                      Icon(
                        Icons.person_rounded,
                        size: 14,
                        color: c.ink.withValues(alpha: 0.55),
                      ),
                      const SizedBox(width: 3),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 72),
                        child: Text(
                          // The first name is enough in a row, and leaves
                          // the car's name room; the form has it in full.
                          authorName.split(' ').first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: c.ink.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
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

/// An amount in the app's leaning figures, with its currency smaller
/// after it. [money] is what `formatMoney` returns, such as
/// "12.000,00 RSD"; the text reads the same to a screen reader and to a
/// test.
class MoneyText extends StatelessWidget {
  const MoneyText(this.money, {super.key, this.size = 17, this.color});

  final String money;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cut = money.lastIndexOf(' ');
    final number = cut < 0 ? money : money.substring(0, cut);
    final unit = cut < 0 ? '' : money.substring(cut);
    return Text.rich(
      TextSpan(
        text: number,
        children: [
          TextSpan(
            text: unit,
            style: TextStyle(
              fontSize: size * 0.65,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w600,
              color: color ?? c.muted,
            ),
          ),
        ],
      ),
      maxLines: 1,
      style: TextStyle(
        fontSize: size,
        height: 1,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w800,
        color: color ?? c.ink,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
