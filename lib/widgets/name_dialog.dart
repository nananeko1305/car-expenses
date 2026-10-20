import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/tutorial.dart';

/// Asks for one name, such as a make or a model, and resolves to it
/// trimmed, or to null when cancelled. A name already in [taken] is
/// refused with [takenMessage], whatever its case.
Future<String?> showNameDialog(
  BuildContext context, {
  required String title,
  required String label,
  required String hint,
  required Iterable<String> taken,
  required String takenMessage,
  String initial = '',
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _NameDialog(
      title: title,
      label: label,
      hint: hint,
      taken: taken,
      takenMessage: takenMessage,
      initial: initial,
    ),
  );
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({
    required this.title,
    required this.label,
    required this.hint,
    required this.taken,
    required this.takenMessage,
    required this.initial,
  });

  final String title;
  final String label;
  final String hint;
  final Iterable<String> taken;
  final String takenMessage;
  final String initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_name.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _name,
          autofocus: true,
          maxLength: 100,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            counterText: '',
          ),
          onFieldSubmitted: (_) => _save(),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return t.required;
            if (nameTaken(v, widget.taken)) return widget.takenMessage;
            return null;
          },
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
