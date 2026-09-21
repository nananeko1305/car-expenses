import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// First name + last name inputs, both required.
class NameFields extends StatelessWidget {
  const NameFields({
    super.key,
    required this.firstName,
    required this.lastName,
    this.autofocus = false,
  });

  final TextEditingController firstName;
  final TextEditingController lastName;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? t.required : null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: firstName,
          autofocus: autofocus,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: t.firstName),
          validator: required,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: lastName,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: t.lastName),
          validator: required,
        ),
      ],
    );
  }
}

/// Dialog to edit the signed-in user's own name.
Future<void> showEditNameDialog(
  BuildContext context, {
  required String firstName,
  required String lastName,
  required void Function(String first, String last) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final first = TextEditingController(text: firstName);
  final last = TextEditingController(text: lastName);
  final t = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(t.editName),
      content: Form(
        key: formKey,
        child: NameFields(firstName: first, lastName: last, autofocus: true),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
        TextButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) return;
            onSave(first.text.trim(), last.text.trim());
            Navigator.pop(ctx);
          },
          child: Text(t.save),
        ),
      ],
    ),
  );
}
