import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/repair.dart';
import '../models/vehicle.dart';
import '../money/money.dart';
import '../theme/app_colors.dart';

/// One service in the list: date, car, author, description and amount.
class RepairCard extends StatelessWidget {
  const RepairCard({
    super.key,
    required this.repair,
    required this.vehicle,
    required this.authorName,
    required this.onTap,
  });

  final Repair repair;
  final Vehicle? vehicle;
  final String authorName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat.yMMMd(locale).format(repair.date);
    final km = repair.mileage == null
        ? null
        : '${NumberFormat.decimalPattern(locale).format(repair.mileage)} km';
    final meta = [date, ?vehicle?.label, ?km].join(' · ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: context.colors.soft,
                foregroundColor: context.colors.primary,
                child: const Icon(Icons.build_rounded, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      repair.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meta,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.colors.ink.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.person_rounded,
                          size: 14,
                          color: context.colors.ink.withValues(alpha: 0.55),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            authorName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: context.colors.ink.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                formatMoney(repair.amountMinor, repair.currency, locale),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
