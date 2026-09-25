import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/repair.dart';
import '../models/tool.dart';
import '../money/money.dart';
import '../theme/app_colors.dart';
import 'warranty_bar.dart';

/// One tool in the list: what it is, when it was bought, what it cost,
/// and how much of its warranty is left.
class ToolCard extends StatelessWidget {
  const ToolCard({
    super.key,
    required this.tool,
    required this.now,
    required this.onTap,
    this.amountMinor,
    this.currency,
  });

  final Tool tool;
  final DateTime now;
  final VoidCallback onTap;

  /// The price as the wallet has it today, falling back to the copy kept
  /// on the tool. Null when the tool was entered without one.
  final int? amountMinor;
  final Currency? currency;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final price = amountMinor == null
        ? null
        : formatMoney(amountMinor!, currency ?? Currency.rsd, locale);
    final meta = [
      DateFormat.yMMMd(locale).format(tool.purchaseDate),
      ?price,
      if (tool.archived) t.archivedTools,
    ].join(' · ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: context.colors.soft,
                    foregroundColor: context.colors.primary,
                    child: const Icon(Icons.handyman_rounded, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tool.name,
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
                      ],
                    ),
                  ),
                  if (tool.receiptUrl.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        size: 18,
                        color: context.colors.ink.withValues(alpha: 0.45),
                      ),
                    ),
                  if (tool.notify && !tool.archived)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Icon(
                        Icons.notifications_active_rounded,
                        size: 18,
                        color: context.colors.ink.withValues(alpha: 0.45),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              WarrantyBar(tool: tool, now: now),
            ],
          ),
        ),
      ),
    );
  }
}
