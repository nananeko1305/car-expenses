import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/tutorial_entry.dart';
import 'tutorial_cards.dart';

/// A search box and the notes it finds. [carOf] says which make and model
/// a note is about, and [authorOf] who wrote it.
class NotesList extends StatefulWidget {
  const NotesList({
    super.key,
    required this.notes,
    required this.carOf,
    required this.authorOf,
    required this.onOpen,
  });

  final List<TutorialNote> notes;
  final String Function(TutorialNote) carOf;
  final String Function(TutorialNote) authorOf;
  final ValueChanged<TutorialNote> onOpen;

  @override
  State<NotesList> createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final found = TutorialNote.newestFirst(
      widget.notes.where((n) => n.matches(_query.text, widget.carOf(n))),
    );
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: _query,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: t.notesSearchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => setState(_query.clear),
                    ),
            ),
          ),
        ),
        Expanded(
          child: found.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 48,
                    horizontal: 24,
                  ),
                  child: Text(
                    widget.notes.isEmpty ? t.noNotes : t.noNotesFound,
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  itemCount: found.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final note = found[i];
                    return TutorialNoteCard(
                      note: note,
                      car: widget.carOf(note),
                      authorName: widget.authorOf(note),
                      onTap: () => widget.onOpen(note),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
