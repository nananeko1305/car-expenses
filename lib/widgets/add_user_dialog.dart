import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_text.dart';
import '../services/user_repository.dart';
import 'name_fields.dart';

/// Admin dialog that creates a new account with an initial password.
/// Unlike other writes this one needs the network (Firebase Auth), so
/// it waits for the result.
Future<void> showAddUserDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _AddUserDialog(),
  );
}

class _AddUserDialog extends StatefulWidget {
  const _AddUserDialog();

  @override
  State<_AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<_AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final email = _email.text.trim();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await UserRepository.instance.createUser(
        email: email,
        password: _password.text,
        firstName: _firstName.text,
        lastName: _lastName.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(SnackBar(content: Text(t.userCreated(email))));
    } catch (e) {
      if (mounted) setState(() => _error = errorText(t, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(t.addUser),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NameFields(
                firstName: _firstName,
                lastName: _lastName,
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: t.email),
                validator: (v) =>
                    (v == null || !v.contains('@')) ? t.invalidEmail : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                decoration: InputDecoration(labelText: t.newUserPassword),
                validator: (v) =>
                    (v == null || v.length < 6) ? t.minChars6 : null,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(t.cancel),
        ),
        TextButton(
          onPressed: _busy ? null : _create,
          child: Text(_busy ? t.wait : t.addUser),
        ),
      ],
    );
  }
}
