import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_text.dart';
import '../models/app_user.dart';
import '../models/appointment_push.dart';
import '../services/appointment_announcer.dart';
import '../services/auth_service.dart';
import '../services/live_data.dart';
import '../services/push_service.dart';
import '../services/update_checker.dart';
import '../widgets/appointment_push_snack_bar.dart';
import '../widgets/race_nav_bar.dart';
import '../widgets/sync_banner.dart';
import '../widgets/update_dialog.dart';
import 'calendar_screen.dart';
import 'more_tab.dart';
import 'planned_purchases_screen.dart';
import 'report_screen.dart';
import 'services_tab.dart';
import 'settings_screen.dart';
import 'tools_screen.dart';
import 'tutorials_screen.dart';
import 'users_screen.dart';
import 'vehicle_search_screen.dart';
import 'vehicles_screen.dart';
import 'wallet_tab.dart';

/// Signed-in shell over one [LiveData]: four tabs (services, wallet,
/// calendar, and "more" with everything else) and the bar that
/// switches between them.
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
  void initState() {
    super.initState();
    _checkForUpdate();
    // A release push (received in the foreground or tapped) re-runs the
    // same check, which then shows the download dialog.
    _releaseSub = PushService.instance.onRelease.listen(
      (_) => _checkForUpdate(),
    );
    _appointmentSub = PushService.instance.onAppointment.listen(
      _showAppointmentPush,
    );
    PushService.instance.start();
    PushService.instance.registerToken();
    _announcer.start();
  }

  late final StreamSubscription<void> _releaseSub;
  late final StreamSubscription<AppointmentPush> _appointmentSub;
  late final AppointmentAnnouncer _announcer = AppointmentAnnouncer(
    source: _data,
    read: () => _data.appointments,
    uid: widget.profile.uid,
    announce: announceToWorker,
  );
  bool _updateDialogOpen = false;

  void _showAppointmentPush(AppointmentPush push) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(appointmentPushSnackBar(AppLocalizations.of(context), push));
  }

  /// On app start and on release pushes; silent when offline or already
  /// up to date, and never stacks a second dialog on an open one.
  Future<void> _checkForUpdate() async {
    if (_updateDialogOpen) return;
    final result = await UpdateChecker.instance.check();
    if (!mounted || result is! UpdateAvailable || _updateDialogOpen) return;
    _updateDialogOpen = true;
    await showUpdateDialog(context, result);
    _updateDialogOpen = false;
  }

  @override
  void dispose() {
    _releaseSub.cancel();
    _appointmentSub.cancel();
    _announcer.dispose();
    _data.dispose();
    super.dispose();
  }

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _go(MenuDestination d) {
    switch (d) {
      case MenuDestination.services:
        setState(() => _tab = 0);
      case MenuDestination.wallet:
        setState(() => _tab = 1);
      case MenuDestination.calendar:
        setState(() => _tab = 2);
      case MenuDestination.report:
        _open(ReportScreen(data: _data, profile: widget.profile));
      case MenuDestination.search:
        _openSearch();
      case MenuDestination.vehicles:
        _open(VehiclesScreen(data: _data, profile: widget.profile));
      case MenuDestination.tools:
        _open(ToolsScreen(data: _data, profile: widget.profile));
      case MenuDestination.plannedPurchases:
        _open(PlannedPurchasesScreen(data: _data, profile: widget.profile));
      case MenuDestination.tutorials:
        _open(TutorialsScreen(data: _data, profile: widget.profile));
      case MenuDestination.users:
        _open(UsersScreen(currentUid: widget.profile.uid));
      case MenuDestination.settings:
        _open(SettingsScreen(profile: widget.profile));
      case MenuDestination.signOut:
        AuthService.instance.signOut();
    }
  }

  void _openSearch() =>
      _open(VehicleSearchScreen(data: _data, profile: widget.profile));

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      bottomNavigationBar: RaceNavBar(
        index: _tab,
        onChanged: (i) => setState(() => _tab = i),
        items: [
          (icon: Icons.build_rounded, label: t.repairs),
          (icon: Icons.account_balance_wallet_rounded, label: t.wallet),
          (icon: Icons.calendar_month_rounded, label: t.calendar),
          (icon: Icons.menu_rounded, label: t.more),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListenableBuilder(
              listenable: _data,
              builder: (context, _) => _tabBody(t),
            ),
          ),
          // Above the bar rather than under a header: every tab draws its
          // own header, right up to the top of the screen.
          const SyncBanner(),
        ],
      ),
    );
  }

  Widget _tabBody(AppLocalizations t) {
    // The calendar and the menu do not wait for the main collections.
    if (_tab == 2) {
      return CalendarScreen(data: _data, profile: widget.profile);
    }
    if (_tab == 3) return MoreTab(profile: widget.profile, onSelect: _go);
    if (_data.error != null && !_data.ready) {
      return SafeArea(child: Center(child: Text(errorText(t, _data.error!))));
    }
    if (!_data.ready) return const Center(child: CircularProgressIndicator());
    return _tab == 0
        ? ServicesTab(
            data: _data,
            profile: widget.profile,
            onSearch: _openSearch,
          )
        : WalletTab(
            data: _data,
            profile: widget.profile,
            onSearch: _openSearch,
          );
  }
}
