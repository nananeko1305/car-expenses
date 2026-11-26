import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/planned_purchase.dart';
import '../theme/app_colors.dart';
import 'purchase_priority.dart';

/// The to-buy list, the most urgent on top. Every item carries its own
/// priority, so there are no headings. Tapping one hands it to [onTap].
class PlannedPurchaseList extends StatelessWidget {
  const PlannedPurchaseList({
    super.key,
    required this.purchases,
    required this.nameOf,
    required this.onTap,
  });

  final List<PlannedPurchase> purchases;

  /// The name of the user with this uid, for "who added it".
  final String Function(String uid) nameOf;
  final ValueChanged<PlannedPurchase> onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final sorted = PlannedPurchase.inOrder(purchases);
    if (sorted.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Text(t.noPlannedPurchases, textAlign: TextAlign.center),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: sorted.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final purchase = sorted[i];
        return PlannedPurchaseCard(
          purchase: purchase,
          authorName: nameOf(purchase.ownerId),
          onTap: () => onTap(purchase),
        );
      },
    );
  }
}

/// One thing to buy: what it is, with its priority as a colored label
/// beside it, the note if it has one, then who added it and when.
/// Tapping edits it.
class PlannedPurchaseCard extends StatelessWidget {
  const PlannedPurchaseCard({
    super.key,
    required this.purchase,
    required this.authorName,
    required this.onTap,
  });

  final PlannedPurchase purchase;
  final String authorName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat.yMMMd(locale)
        .format(purchase.createdAt ?? DateTime.now());
    final faded = context.colors.ink.withValues(alpha: 0.65);
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      purchase.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  PriorityPill(purchase.priority),
                ],
              ),
              if (purchase.note.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  purchase.note,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                '$authorName · $date',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: faded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
