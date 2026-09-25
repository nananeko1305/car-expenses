import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../theme/app_colors.dart';

/// Where a drawer tap should go. Tabs switch in place; the rest push
/// a screen (handled by the home screen).
enum DrawerDestination {
  services,
  wallet,
  search,
  vehicles,
  tools,
  users,
  settings,
  signOut,
}

/// Side menu: profile header plus navigation. The admin also sees Users.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.profile,
    required this.selectedTab,
    required this.onSelect,
  });

  final AppUser profile;

  /// 0 = services, 1 = wallet.
  final int selectedTab;
  final ValueChanged<DrawerDestination> onSelect;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    Widget item(
      DrawerDestination d,
      IconData icon,
      String label, {
      bool selected = false,
    }) {
      return ListTile(
        leading: Icon(icon),
        title: Text(label),
        selected: selected,
        selectedColor: context.colors.primary,
        selectedTileColor: context.colors.soft.withValues(alpha: 0.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onTap: () {
          Navigator.of(context).pop();
          onSelect(d);
        },
      );
    }

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _header(context, t),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  item(
                    DrawerDestination.services,
                    Icons.car_repair_rounded,
                    t.repairs,
                    selected: selectedTab == 0,
                  ),
                  item(
                    DrawerDestination.wallet,
                    Icons.account_balance_wallet_rounded,
                    t.wallet,
                    selected: selectedTab == 1,
                  ),
                  item(
                    DrawerDestination.search,
                    Icons.search_rounded,
                    t.searchPlate,
                  ),
                  item(
                    DrawerDestination.vehicles,
                    Icons.directions_car_rounded,
                    t.vehicles,
                  ),
                  item(
                    DrawerDestination.tools,
                    Icons.handyman_rounded,
                    t.tools,
                  ),
                  if (profile.isAdmin)
                    item(DrawerDestination.users, Icons.group_rounded, t.users),
                  const Divider(height: 24),
                  item(
                    DrawerDestination.settings,
                    Icons.settings_rounded,
                    t.settings,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: item(
                DrawerDestination.signOut,
                Icons.logout_rounded,
                t.signOut,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, AppLocalizations t) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset('assets/icon/logo.png', width: 56, height: 56),
          ),
          const SizedBox(height: 14),
          Text(
            profile.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            profile.email,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              profile.isAdmin ? t.roleAdmin : t.roleUser,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
