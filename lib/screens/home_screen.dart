import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_text.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/live_data.dart';
import '../widgets/app_drawer.dart';
import '../widgets/sync_banner.dart';
import 'services_tab.dart';
import 'settings_screen.dart';
import 'users_screen.dart';
import 'vehicle_search_screen.dart';
import 'vehicles_screen.dart';
import 'wallet_tab.dart';

/// Signed-in shell: two tabs (services, wallet) over one [LiveData].
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.profile});

  final AppUser profile;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LiveData _data = LiveData();
  int _tab = 0;

  @override
  void dispose() {
    _data.dispose();
    super.dispose();
  }

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _onDrawer(DrawerDestination d) {
    switch (d) {
      case DrawerDestination.services:
        setState(() => _tab = 0);
      case DrawerDestination.wallet:
        setState(() => _tab = 1);
      case DrawerDestination.search:
        _openSearch();
      case DrawerDestination.vehicles:
        _open(VehiclesScreen(data: _data, profile: widget.profile));
      case DrawerDestination.users:
        _open(UsersScreen(currentUid: widget.profile.uid));
      case DrawerDestination.settings:
        _open(SettingsScreen(profile: widget.profile));
      case DrawerDestination.signOut:
        AuthService.instance.signOut();
    }
  }

  void _openSearch() =>
      _open(VehicleSearchScreen(data: _data, profile: widget.profile));

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_tab == 0 ? t.repairs : t.wallet),
        actions: [
          IconButton(
            tooltip: t.searchPlate,
            icon: const Icon(Icons.search_rounded),
            onPressed: _openSearch,
          ),
        ],
      ),
      drawer: AppDrawer(
        profile: widget.profile,
        selectedTab: _tab,
        onSelect: _onDrawer,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.car_repair_outlined),
            selectedIcon: const Icon(Icons.car_repair_rounded),
            label: t.repairs,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const Icon(Icons.account_balance_wallet_rounded),
            label: t.wallet,
          ),
        ],
      ),
      body: Column(
        children: [
          const SyncBanner(),
          Expanded(
            child: ListenableBuilder(
              listenable: _data,
              builder: (context, _) {
                if (_data.error != null && !_data.ready) {
                  return Center(child: Text(errorText(t, _data.error!)));
                }
                if (!_data.ready) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _tab == 0
                    ? ServicesTab(data: _data, profile: widget.profile)
                    : WalletTab(data: _data, profile: widget.profile);
              },
            ),
          ),
        ],
      ),
    );
  }
}
