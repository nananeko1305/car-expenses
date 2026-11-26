import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../models/planned_purchase.dart';
import '../../services/background_save.dart';
import '../../services/planned_purchase_repository.dart';
import 'confirm_delete.dart';
import 'purchase_priority.dart';

/// Adds something to the to-buy list, or edits or deletes [purchase].
/// Any user may do either; [authorName] says who added an existing one.
Future<void> showPlannedPurchaseDialog(
  BuildContext context, {
  required String uid,
  PlannedPurchase? purchase,
  String authorName = '',
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _PlannedPurchaseDialog(
      uid: uid,
      purchase: purchase,
      authorName: authorName,
    ),
  );
}

class _PlannedPurchaseDialog extends StatefulWidget {
  const _PlannedPurchaseDialog({
    required this.uid,
    required this.authorName,
    this.purchase,
  });

  final String uid;
  final String authorName;
  final PlannedPurchase? purchase;

  @override
  State<_PlannedPurchaseDialog> createState() => _PlannedPurchaseDialogState();
}

class _PlannedPurchaseDialogState extends State<_PlannedPurchaseDialog> {
  /// The rules allow 100 characters of name and 500 of note.
  static const _maxName = 100;
  static const _maxNote = 500;

  final _formKey = GlobalKey<FormState>();
  late final PlannedPurchase? _old = widget.purchase;
  late final _name = TextEditingController(text: _old?.name ?? '');
  late final _note = TextEditingController(text: _old?.note ?? '');
  late PurchasePriority _priority = _old?.priority ?? PurchasePriority.medium;

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final purchase = PlannedPurchase(
      id: _old?.id ?? '',
      // Whoever edits, the one who added it stays on record.
      ownerId: _old?.ownerId ?? widget.uid,
      name: _name.text.trim(),
      priority: _priority,
      note: _note.text.trim(),
    );
    saveInBackground(
      context,
      () => PlannedPurchaseRepository.instance.save(purchase),
    );
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final t = AppLocalizations.of(context);
    if (!await confirmDelete(context, t.deletePlannedPurchaseQ) || !mounted) {
      return;
    }
    final id = _old!.id;
    saveInBackground(
      context,
      () => PlannedPurchaseRepository.instance.delete(id),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final editing = _old != null;
    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Text(editing ? t.editPlannedPurchase : t.newPlannedPurchase),
          ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _name,
                autofocus: !editing,
                textCapitalization: TextCapitalization.sentences,
                inputFormatters: [LengthLimitingTextInputFormatter(_maxName)],
                decoration: InputDecoration(
                  labelText: t.plannedPurchaseName,
                  hintText: t.plannedPurchaseNameHint,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? t.required : null,
              ),
              const SizedBox(height: 16),
              PriorityPicker(
                value: _priority,
                onChanged: (p) => setState(() => _priority = p),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _note,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                inputFormatters: [LengthLimitingTextInputFormatter(_maxNote)],
                decoration: InputDecoration(
                  labelText: t.plannedPurchaseNote,
                  hintText: t.plannedPurchaseNoteHint,
                ),
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
