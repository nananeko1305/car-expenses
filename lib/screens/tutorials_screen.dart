import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../models/tutorial.dart';
import '../services/background_save.dart';
import '../services/live_data.dart';
import '../services/tutorial_repository.dart';
import '../widgets/name_dialog.dart';
import '../widgets/sync_banner.dart';
import '../widgets/tutorial_cards.dart';
import 'tutorial_brand_screen.dart';

/// The tutorials, one make at a time: each make holds its models, and
/// each model the links and notes for working on it. Shared knowledge,
/// so anyone may add, correct or delete any of it.
class TutorialsScreen extends StatelessWidget {
  const TutorialsScreen({super.key, required this.data, required this.profile});

  final LiveData data;
  final AppUser profile;

  Future<void> _addBrand(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final name = await showNameDialog(
      context,
      title: t.newBrand,
      label: t.brandName,
      hint: t.brandHint,
      taken: (data.tutorialBrands ?? const []).map((b) => b.name),
      takenMessage: t.brandExists,
    );
    if (name == null || !context.mounted) return;
    final brand = TutorialBrand(id: '', ownerId: profile.uid, name: name);
    saveInBackground(
      context,
      () => TutorialRepository.instance.saveBrand(brand),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.tutorials)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'tutorials-fab',
        onPressed: () => _addBrand(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(t.addBrand),
      ),
      body: Column(
        children: [
          const SyncBanner(),
          Expanded(
            child: ListenableBuilder(
              listenable: data,
              builder: (context, _) => _list(context, t),
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(BuildContext context, AppLocalizations t) {
    if (!data.tutorialsReady) return TutorialsLoading(error: data.error);
    final brands = sortedByName(data.tutorialBrands!, (b) => b.name);
    if (brands.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Text(t.noBrands, textAlign: TextAlign.center),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: brands.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final brand = brands[i];
        return TutorialTile(
          icon: Icons.directions_car_rounded,
          title: brand.name,
          subtitle: t.modelsCount(data.modelsOf(brand.id).length),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TutorialBrandScreen(
                data: data,
                profile: profile,
                brandId: brand.id,
              ),
            ),
          ),
        );
      },
    );
  }
}
