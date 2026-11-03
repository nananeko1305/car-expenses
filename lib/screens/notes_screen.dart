import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../services/live_data.dart';
import '../widgets/notes_list.dart';
import '../widgets/sync_banner.dart';
import '../widgets/tutorial_cards.dart';
import '../widgets/tutorial_note_dialog.dart';
import 'note_form_screen.dart';

/// Every note from the tutorials in one list, whichever car it is about,
/// with a search. Stays live while open.
class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key, required this.data, required this.profile});

  final LiveData data;
  final AppUser profile;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: data,
      builder: (context, _) {
        final ready = data.tutorialsReady;
        return Scaffold(
          appBar: AppBar(title: Text(t.notes)),
          // Not before the makes are here: the form would not know them,
          // and would add them a second time.
          floatingActionButton: !ready
              ? null
              : FloatingActionButton.extended(
                  heroTag: 'notes-fab',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NoteFormScreen(
                        profile: profile,
                        brands: data.tutorialBrands!,
                        models: data.tutorialModels!,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(t.newNote),
                ),
          body: Column(
            children: [
              const SyncBanner(),
              Expanded(
                child: !ready
                    ? TutorialsLoading(error: data.error)
                    : NotesList(
                        notes: data.tutorialNotes!,
                        carOf: data.carOfNote,
                        authorOf: (note) => data.nameOf(note.ownerId),
                        onOpen: (note) => showTutorialNoteDialog(
                          context,
                          modelId: note.modelId,
                          uid: profile.uid,
                          note: note,
                          authorName: data.nameOf(note.ownerId),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
