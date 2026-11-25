import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/repair.dart';
import '../models/tool.dart';
import '../money/money.dart';
import '../theme/app_colors.dart';
import 'skewed.dart';
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

    final c = context.colors;
    Widget mark(IconData icon) => Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Icon(icon, size: 18, color: c.muted),
    );

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.line)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SkewIcon(Icons.handyman_rounded),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tool.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        meta,
                        style: TextStyle(fontSize: 13, color: c.muted),
                      ),
                    ],
                  ),
                ),
                if (tool.receiptUrl.isNotEmpty)
                  mark(Icons.receipt_long_rounded),
                if (tool.notify && !tool.archived)
                  mark(Icons.notifications_active_rounded),
              ],
            ),
            const SizedBox(height: 8),
            WarrantyBar(tool: tool, now: now),
          ],
        ),
      ),
    );
  }
}
