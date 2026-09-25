import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Asks "Delete …?" and resolves to true only on an explicit yes.
///
/// [confirmLabel] renames the confirming button for a question that is
/// not a deletion, such as archiving a tool.
Future<bool> confirmDelete(
  BuildContext context,
  String question, {
  String? body,
  String? confirmLabel,
}) async {
  final t = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(question),
      content: body == null ? null : Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(t.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel ?? t.delete),
        ),
      ],
    ),
  );
  return ok == true;
}
