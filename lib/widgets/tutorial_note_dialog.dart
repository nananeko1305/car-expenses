import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../models/tutorial_entry.dart';
import '../services/background_save.dart';
import '../services/tutorial_repository.dart';
import 'confirm_delete.dart';

/// Adds a note to the model [modelId], or edits or deletes [note]. Any
/// user may do either; [authorName] says who wrote an existing one.
Future<void> showTutorialNoteDialog(
  BuildContext context, {
  required String modelId,
  required String uid,
  TutorialNote? note,
  String authorName = '',
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _NoteDialog(
      modelId: modelId,
      uid: uid,
      note: note,
      authorName: authorName,
    ),
  );
}

class _NoteDialog extends StatefulWidget {
  const _NoteDialog({
    required this.modelId,
    required this.uid,
    required this.authorName,
    this.note,
  });

  final String modelId;
  final String uid;
  final String authorName;
  final TutorialNote? note;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  /// The rules allow 2000 characters.
  static const _maxLength = 2000;

  final _formKey = GlobalKey<FormState>();
  late final _text = TextEditingController(text: widget.note?.text ?? '');

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final old = widget.note;
    final note = TutorialNote(
      id: old?.id ?? '',
      // Whoever edits, the one who wrote it stays on record.
      ownerId: old?.ownerId ?? widget.uid,
      modelId: widget.modelId,
      text: _text.text.trim(),
    );
    saveInBackground(context, () => TutorialRepository.instance.saveNote(note));
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final t = AppLocalizations.of(context);
    if (!await confirmDelete(context, t.deleteNoteQ) || !mounted) return;
    final id = widget.note!.id;
    saveInBackground(context, () => TutorialRepository.instance.deleteNote(id));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final editing = widget.note != null;
    return AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text(editing ? t.note : t.newNote)),
          if (editing)
            IconButton(
              tooltip: t.delete,
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _delete,
            ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _text,
                autofocus: !editing,
                minLines: 3,
                maxLines: 8,
                textCapitalization: TextCapitalization.sentences,
                inputFormatters: [LengthLimitingTextInputFormatter(_maxLength)],
                decoration: InputDecoration(
                  labelText: t.note,
                  hintText: t.noteHint,
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? t.required : null,
              ),
              if (editing) ...[
                const SizedBox(height: 12),
                Text(t.enteredBy(widget.authorName)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.cancel),
        ),
        TextButton(onPressed: _save, child: Text(t.save)),
      ],
    );
  }
}
