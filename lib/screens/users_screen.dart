import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_text.dart';
import '../models/app_user.dart';
import '../services/background_save.dart';
import '../services/user_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/add_user_dialog.dart';
import '../widgets/sync_banner.dart';

/// Admin only: list users, add new ones, disable or re-enable them.
class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key, required this.currentUid});

  final String currentUid;

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late final Stream<List<AppUser>> _users = UserRepository.instance.watchAll();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.users)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddUserDialog(context),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text(t.addUser),
      ),
      body: Column(
        children: [
          const SyncBanner(),
          Expanded(
            child: StreamBuilder<List<AppUser>>(
              stream: _users,
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(child: Text(errorText(t, snap.error!)));
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final users = snap.data!;
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: users.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _tile(t, users[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(AppLocalizations t, AppUser u) {
    final isMe = u.uid == widget.currentUid;
    final role = u.isAdmin ? t.roleAdmin : t.roleUser;
    final status = [
      role,
      if (isMe) t.you,
      if (u.disabled) t.disabled,
    ].join(' · ');
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: u.disabled ? Colors.grey.shade300 : AppTheme.peach,
          foregroundColor: u.disabled ? Colors.grey : AppTheme.terracotta,
          child: Icon(
            u.isAdmin
                ? Icons.admin_panel_settings_rounded
                : Icons.person_rounded,
          ),
        ),
        title: Text(
          u.displayName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('${u.email}\n$status'),
        isThreeLine: true,
        // The admin cannot disable themselves (rules forbid it too).
        trailing: isMe
            ? null
            : TextButton(
                onPressed: () => saveInBackground(
                  context,
                  () => UserRepository.instance.setDisabled(u.uid, !u.disabled),
                ),
                child: Text(u.disabled ? t.enableUser : t.disableUser),
              ),
      ),
    );
  }
}
