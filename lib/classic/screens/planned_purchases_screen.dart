import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/app_user.dart';
import '../../models/planned_purchase.dart';
import '../../services/live_data.dart';
import '../widgets/planned_purchase_card.dart';
import '../widgets/planned_purchase_dialog.dart';
import '../widgets/sync_banner.dart';
import '../widgets/tutorial_cards.dart';

/// What the workshop still has to buy, the most urgent first. A shared
/// list, so anyone may add to it, correct it, or take off what was bought.
class PlannedPurchasesScreen extends StatelessWidget {
  const PlannedPurchasesScreen({
    super.key,
    required this.data,
    required this.profile,
  });

  final LiveData data;
  final AppUser profile;

  void _open(BuildContext context, [PlannedPurchase? purchase]) {
    showPlannedPurchaseDialog(
      context,
      uid: profile.uid,
      purchase: purchase,
      authorName: purchase == null ? '' : data.nameOf(purchase.ownerId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.plannedPurchases)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(t.addPlannedPurchase),
      ),
      body: Column(
        children: [
          const SyncBanner(),
          Expanded(
            child: ListenableBuilder(
              listenable: data,
              builder: (context, _) {
                // Outside LiveData.ready, so this screen owns its loading
                // state: null is "not here yet", empty is "nothing to buy".
                final purchases = data.plannedPurchases;
                if (purchases == null) {
                  return TutorialsLoading(error: data.error);
                }
                return PlannedPurchaseList(
                  purchases: purchases,
                  nameOf: data.nameOf,
                  onTap: (purchase) => _open(context, purchase),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
