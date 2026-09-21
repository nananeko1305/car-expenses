import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

/// Full-screen notice (no access, disabled, admin claim) with an optional
/// primary action and a sign-out button.
class StatusScreen extends StatelessWidget {
  const StatusScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    this.loading = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        decoration: AppTheme.warmGradient,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 72, color: AppTheme.terracotta),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (loading)
                    const CircularProgressIndicator()
                  else
                    Text(body, textAlign: TextAlign.center),
                  const SizedBox(height: 28),
                  if (actionLabel != null) ...[
                    FilledButton(
                      onPressed: onAction,
                      child: Text(actionLabel!),
                    ),
                    const SizedBox(height: 8),
                  ],
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
    );
  }
}
