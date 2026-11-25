import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../theme/app_colors.dart';
import '../widgets/skewed.dart';
import '../widgets/slant_header.dart';

/// Where a tap in the menu should go. Tabs switch in place; the rest
/// push a screen (handled by the home screen).
enum MenuDestination {
  services,
  wallet,
  calendar,
  report,
  search,
  vehicles,
  tools,
  plannedPurchases,
  tutorials,
  users,
  settings,
  signOut,
}

/// The last tab: who is signed in, and every destination that has no tab
/// of its own. The admin also sees Users.
class MoreTab extends StatelessWidget {
  const MoreTab({super.key, required this.profile, required this.onSelect});

  final AppUser profile;
  final ValueChanged<MenuDestination> onSelect;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    Widget row(
      MenuDestination d,
      IconData icon,
      String label, {
      bool leaving = false,
    }) {
      final color = leaving ? c.accentText : c.ink;
      return InkWell(
        onTap: () => onSelect(d),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: c.line)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (!leaving) Icon(Icons.chevron_right_rounded, color: c.muted),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        SlantHeader(title: t.more, child: _who(context, t)),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              row(
                MenuDestination.report,
                Icons.insights_rounded,
                t.monthlyReport,
              ),
              row(MenuDestination.search, Icons.search_rounded, t.searchPlate),
              row(
                MenuDestination.vehicles,
                Icons.directions_car_rounded,
                t.vehicles,
              ),
              row(MenuDestination.tools, Icons.handyman_rounded, t.tools),
              row(
                MenuDestination.plannedPurchases,
                Icons.shopping_cart_rounded,
                t.plannedPurchases,
              ),
              row(
                MenuDestination.tutorials,
                Icons.menu_book_rounded,
                t.tutorials,
              ),
              if (profile.isAdmin)
                row(MenuDestination.users, Icons.group_rounded, t.users),
              row(MenuDestination.settings, Icons.settings_rounded, t.settings),
              row(
                MenuDestination.signOut,
                Icons.logout_rounded,
                t.signOut,
                leaving: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _who(BuildContext context, AppLocalizations t) {
    final c = context.colors;
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/icon/logo.png', width: 44, height: 44),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                profile.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SkewTag(profile.isAdmin ? t.roleAdmin : t.roleUser, color: c.onPrimary),
      ],
    );
  }
}
