import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../models/tutorial.dart';
import '../services/background_save.dart';
import '../services/live_data.dart';
import '../services/tutorial_repository.dart';
import '../widgets/confirm_delete.dart';
import '../widgets/name_dialog.dart';
import '../widgets/tutorial_cards.dart';
import 'tutorial_model_form_screen.dart';
import 'tutorial_model_screen.dart';

/// One make and its models. Stays live while open, and says so when
/// someone else deletes the make meanwhile.
class TutorialBrandScreen extends StatelessWidget {
  const TutorialBrandScreen({
    super.key,
    required this.data,
    required this.profile,
    required this.brandId,
  });

  final LiveData data;
  final AppUser profile;
  final String brandId;

  Future<void> _rename(BuildContext context, TutorialBrand brand) async {
    final t = AppLocalizations.of(context);
    final name = await showNameDialog(
      context,
      title: t.renameBrand,
      label: t.brandName,
      hint: t.brandHint,
      initial: brand.name,
      taken: [
        for (final b in data.tutorialBrands ?? const <TutorialBrand>[])
          if (b.id != brand.id) b.name,
      ],
      takenMessage: t.brandExists,
    );
    if (name == null || name == brand.name || !context.mounted) return;
    final renamed = TutorialBrand(
      id: brand.id,
      ownerId: brand.ownerId,
      name: name,
    );
    saveInBackground(
      context,
      () => TutorialRepository.instance.saveBrand(renamed),
    );
  }

  Future<void> _delete(BuildContext context, TutorialBrand brand) async {
    final t = AppLocalizations.of(context);
    // The rules cannot see a make's models, so the app guards this.
    if (data.modelsOf(brand.id).isNotEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.brandHasModels)));
      return;
    }
    if (!await confirmDelete(context, t.deleteBrandQ(brand.name)) ||
        !context.mounted) {
      return;
    }
    saveInBackground(
      context,
      () => TutorialRepository.instance.deleteBrand(brand.id),
    );
    Navigator.of(context).pop();
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: data,
      builder: (context, _) {
        final brand = data.brandById(brandId);
        if (brand == null) {
          return Scaffold(
            appBar: AppBar(),
            body: data.tutorialsReady
                ? Center(child: Text(t.deleted))
                : TutorialsLoading(error: data.error),
          );
        }
        final models = data.modelsOf(brand.id);
        return Scaffold(
          appBar: AppBar(
            title: Text(brand.name),
            actions: [
              IconButton(
                tooltip: t.edit,
                icon: const Icon(Icons.edit_rounded),
                onPressed: () => _rename(context, brand),
              ),
              IconButton(
                tooltip: t.delete,
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () => _delete(context, brand),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'tutorial-brand-fab',
            onPressed: () => _push(
              context,
              TutorialModelFormScreen(
                profile: profile,
                brand: brand,
                taken: [for (final m in models) m.name],
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: Text(t.addModel),
          ),
          body: models.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 48,
                    horizontal: 24,
                  ),
                  child: Text(t.noModels, textAlign: TextAlign.center),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: models.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final model = models[i];
                    return TutorialTile(
                      icon: Icons.menu_book_rounded,
                      title: model.name,
                      subtitle:
                          '${t.linksCount(data.linksOf(model.id).length)}'
                          ' · ${t.notesCount(data.notesOf(model.id).length)}',
                      onTap: () => _push(
                        context,
                        TutorialModelScreen(
                          data: data,
                          profile: profile,
                          modelId: model.id,
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
