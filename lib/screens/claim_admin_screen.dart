import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_text.dart';
import '../services/auth_service.dart';
import '../services/user_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/name_fields.dart';

/// One-time screen shown to the first account while no admin exists:
/// enter a name and become the admin.
class ClaimAdminScreen extends StatefulWidget {
  const ClaimAdminScreen({super.key, required this.user});

  final User user;

  @override
  State<ClaimAdminScreen> createState() => _ClaimAdminScreenState();
}

class _ClaimAdminScreenState extends State<ClaimAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  Future<void> _claim() async {
    if (!_formKey.currentState!.validate()) return;
    final t = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      // On success the profile stream in ProfileGate swaps this screen out.
      await UserRepository.instance.claimAdmin(
        widget.user,
        firstName: _firstName.text,
        lastName: _lastName.text,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorText(t, e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        decoration: context.colors.softGradient,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.admin_panel_settings_rounded,
                      size: 72,
                      color: context.colors.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      t.claimAdminTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(t.claimAdminBody, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    NameFields(firstName: _firstName, lastName: _lastName),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _busy ? null : _claim,
                      child: Text(_busy ? t.wait : t.claimAdmin),
                    ),
                    TextButton(
                      onPressed: AuthService.instance.signOut,
                      child: Text(t.signOut),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
