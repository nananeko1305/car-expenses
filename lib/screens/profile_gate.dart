import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_text.dart';
import '../models/app_user.dart';
import '../services/user_repository.dart';
import 'claim_admin_screen.dart';
import 'home_screen.dart';
import 'status_screen.dart';

/// Decides what a signed-in account sees, based on its `users/{uid}`
/// profile: the app, a "disabled" notice, or the one-time admin claim.
class ProfileGate extends StatefulWidget {
  const ProfileGate({super.key, required this.user});

  final User user;

  @override
  State<ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<ProfileGate> {
  final _users = UserRepository.instance;
  late final Stream<AppUser?> _profile = _users.watchProfile(widget.user.uid);
  late final Future<bool> _canClaim = _users.canClaimAdmin();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return StreamBuilder<AppUser?>(
      stream: _profile,
      builder: (context, snap) {
        if (snap.hasError) {
          return StatusScreen(
            icon: Icons.cloud_off_rounded,
            title: t.errGeneric,
            body: errorText(t, snap.error!),
          );
        }
        if (!snap.hasData && snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final profile = snap.data;
        if (profile == null) return _noProfile(t);
        if (profile.disabled) {
          return StatusScreen(
            icon: Icons.block_rounded,
            title: t.disabledTitle,
            body: t.disabledBody,
          );
        }
        return HomeScreen(profile: profile);
      },
    );
  }

  Widget _noProfile(AppLocalizations t) {
    return FutureBuilder<bool>(
      future: _canClaim,
      builder: (context, snap) {
        if (!snap.hasData && !snap.hasError) {
          return StatusScreen(
            icon: Icons.hourglass_top_rounded,
            title: t.setupTitle,
            body: '',
            loading: true,
          );
        }
        if (snap.data == true) return ClaimAdminScreen(user: widget.user);
        return StatusScreen(
          icon: Icons.lock_outline_rounded,
          title: t.noAccessTitle,
          body: t.noAccessBody,
        );
      },
    );
  }
}
