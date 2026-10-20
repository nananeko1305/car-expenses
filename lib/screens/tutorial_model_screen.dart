import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../models/tutorial.dart';
import '../models/tutorial_entry.dart';
import '../services/background_save.dart';
import '../services/live_data.dart';
import '../services/tutorial_repository.dart';
import '../widgets/confirm_delete.dart';
import '../widgets/name_dialog.dart';
import '../widgets/tutorial_cards.dart';
import '../widgets/tutorial_link_dialog.dart';
import '../widgets/tutorial_note_dialog.dart';

/// One model: the links for working on it, and the notes people left.
/// Stays live while open.
class TutorialModelScreen extends StatelessWidget {
  const TutorialModelScreen({
    super.key,
    required this.data,
    required this.profile,
    required this.modelId,
  });

  final LiveData data;
  final AppUser profile;
  final String modelId;

  /// Outside the app: YouTube links open in YouTube.
  Future<void> _open(BuildContext context, TutorialLink link) async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = AppLocalizations.of(context).linkOpenFailed;
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(link.url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      // Falls through to the message: there is nothing else to do.
    }
    if (!opened) messenger.showSnackBar(SnackBar(content: Text(failed)));
  }

  Future<void> _rename(BuildContext context, TutorialModel model) async {
    final t = AppLocalizations.of(context);
    final name = await showNameDialog(
      context,
      title: t.renameModel,
      label: t.modelName,
      hint: t.modelHint,
      initial: model.name,
      taken: [
        for (final m in data.modelsOf(model.brandId))
          if (m.id != model.id) m.name,
      ],
      takenMessage: t.modelExists,
    );
    if (name == null || name == model.name || !context.mounted) return;
    final renamed = TutorialModel(
      id: model.id,
      ownerId: model.ownerId,
      brandId: model.brandId,
      name: name,
    );
    saveInBackground(
      context,
      () => TutorialRepository.instance.saveModel(renamed),
    );
  }

  Future<void> _delete(BuildContext context, TutorialModel model) async {
    final t = AppLocalizations.of(context);
    final ok = await confirmDelete(
      context,
      t.deleteModelQ(model.name),
      body: t.deleteModelBody,
    );
    if (!ok || !context.mounted) return;
    final linkIds = [for (final l in data.linksOf(model.id)) l.id];
    final noteIds = [for (final n in data.notesOf(model.id)) n.id];
    saveInBackground(
      context,
      () => TutorialRepository.instance.deleteModel(
        model.id,
        linkIds: linkIds,
        noteIds: noteIds,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: data,
      builder: (context, _) {
        final model = data.modelById(modelId);
        if (model == null) {
          return Scaffold(
            appBar: AppBar(),
            body: data.tutorialsReady
                ? Center(child: Text(t.deleted))
                : TutorialsLoading(error: data.error),
          );
        }
        final brand = data.brandById(model.brandId);
        return Scaffold(
          appBar: AppBar(
            title: Text('${brand?.name ?? ''} ${model.name}'.trim()),
            actions: [
              IconButton(
                tooltip: t.edit,
                icon: const Icon(Icons.edit_rounded),
                onPressed: () => _rename(context, model),
              ),
              IconButton(
                tooltip: t.delete,
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () => _delete(context, model),
              ),
            ],
          ),
          body: _body(context, t, model),
        );
      },
    );
  }

  Widget _body(BuildContext context, AppLocalizations t, TutorialModel model) {
    final links = data.linksOf(model.id);
    final notes = data.notesOf(model.id);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        SectionTitle(t.links),
        if (links.isEmpty) _empty(context, t.noLinks),
        for (final link in links) ...[
          TutorialLinkCard(
            link: link,
            onOpen: () => _open(context, link),
            onEdit: () => showTutorialLinkDialog(
              context,
              modelId: model.id,
              uid: profile.uid,
              link: link,
              authorName: data.nameOf(link.ownerId),
            ),
          ),
          const SizedBox(height: 8),
        ],
        _addButton(
          t.addLink,
          () => showTutorialLinkDialog(
            context,
            modelId: model.id,
            uid: profile.uid,
          ),
        ),
        SectionTitle(t.notes),
        if (notes.isEmpty) _empty(context, t.noNotes),
        for (final note in notes) ...[
          TutorialNoteCard(
            note: note,
            authorName: data.nameOf(note.ownerId),
            onTap: () => showTutorialNoteDialog(
              context,
              modelId: model.id,
              uid: profile.uid,
              note: note,
              authorName: data.nameOf(note.ownerId),
            ),
          ),
          const SizedBox(height: 8),
        ],
        _addButton(
          t.addNote,
          () => showTutorialNoteDialog(
            context,
            modelId: model.id,
            uid: profile.uid,
          ),
        ),
      ],
    );
  }

  Widget _empty(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
    child: Text(text),
  );

  Widget _addButton(String label, VoidCallback onPressed) => Align(
    alignment: Alignment.centerLeft,
    child: TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add_rounded),
      label: Text(label),
    ),
  );
}
