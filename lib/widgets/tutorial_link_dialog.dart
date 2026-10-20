import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/tutorial_entry.dart';
import '../services/background_save.dart';
import '../services/tutorial_repository.dart';
import 'confirm_delete.dart';
import 'link_fields.dart';

/// Adds a link to the model [modelId], or edits or deletes [link]. Any
/// user may do either; [authorName] says who added an existing one.
Future<void> showTutorialLinkDialog(
  BuildContext context, {
  required String modelId,
  required String uid,
  TutorialLink? link,
  String authorName = '',
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _LinkDialog(
      modelId: modelId,
      uid: uid,
      link: link,
      authorName: authorName,
    ),
  );
}

class _LinkDialog extends StatefulWidget {
  const _LinkDialog({
    required this.modelId,
    required this.uid,
    required this.authorName,
    this.link,
  });

  final String modelId;
  final String uid;
  final String authorName;
  final TutorialLink? link;

  @override
  State<_LinkDialog> createState() => _LinkDialogState();
}

class _LinkDialogState extends State<_LinkDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _draft = LinkDraft(widget.link);

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final old = widget.link;
    final link = TutorialLink(
      id: old?.id ?? '',
      // Whoever edits, the one who added it stays on record.
      ownerId: old?.ownerId ?? widget.uid,
      modelId: widget.modelId,
      title: _draft.title.text.trim(),
      url: normalizeUrl(_draft.url.text)!,
    );
    saveInBackground(context, () => TutorialRepository.instance.saveLink(link));
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final t = AppLocalizations.of(context);
    if (!await confirmDelete(context, t.deleteLinkQ) || !mounted) return;
    final id = widget.link!.id;
    saveInBackground(context, () => TutorialRepository.instance.deleteLink(id));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final editing = widget.link != null;
    return AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text(editing ? t.link : t.newLink)),
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
              LinkFields(draft: _draft),
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
