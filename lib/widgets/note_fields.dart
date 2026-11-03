import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../models/tutorial_entry.dart';

/// The editable year, engine and text of one note, shared by the new-note
/// form and the note dialog.
class NoteDraft {
  NoteDraft([TutorialNote? note])
    : year = TextEditingController(text: note?.year ?? ''),
      engine = TextEditingController(text: note?.engine ?? ''),
      text = TextEditingController(text: note?.text ?? '');

  final TextEditingController year;
  final TextEditingController engine;
  final TextEditingController text;

  /// The note as typed, about the model [modelId].
  TutorialNote toNote({
    required String id,
    required String ownerId,
    required String modelId,
  }) => TutorialNote(
    id: id,
    ownerId: ownerId,
    modelId: modelId,
    text: text.text.trim(),
    year: year.text.trim(),
    engine: engine.text.trim(),
  );

  void dispose() {
    year.dispose();
    engine.dispose();
    text.dispose();
  }
}

/// Year, engine and text fields for a [NoteDraft]. Only the text is
/// required: a note may be about every year and engine of a model.
class NoteFields extends StatelessWidget {
  const NoteFields({super.key, required this.draft, this.autofocus = false});

  /// The rules allow 2000 characters of text.
  static const _maxText = 2000;

  final NoteDraft draft;

  /// Puts the cursor in the text, which is the one field a note must have.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: draft.year,
          maxLength: 20,
          decoration: InputDecoration(
            labelText: t.noteYear,
            hintText: t.noteYearHint,
            counterText: '',
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: draft.engine,
          maxLength: 50,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            labelText: t.noteEngine,
            hintText: t.noteEngineHint,
            counterText: '',
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: draft.text,
          autofocus: autofocus,
          minLines: 3,
          maxLines: 8,
          textCapitalization: TextCapitalization.sentences,
          inputFormatters: [LengthLimitingTextInputFormatter(_maxText)],
          decoration: InputDecoration(
            labelText: t.note,
            hintText: t.noteHint,
            alignLabelWithHint: true,
          ),
          validator: (v) => (v == null || v.trim().isEmpty) ? t.required : null,
        ),
      ],
    );
  }
}
