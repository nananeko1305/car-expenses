import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/repair.dart';
import '../models/tool.dart';
import '../models/vehicle.dart';
import '../models/wallet_entry.dart';
import 'repair_repository.dart';
import 'tool_repository.dart';
import 'user_repository.dart';
import 'vehicle_repository.dart';
import 'wallet_repository.dart';

/// Live snapshot of the shared collections (cars, services, users and
/// wallet entries). One instance per signed-in session, owned by the
/// home screen; every tab reads from it instead of opening its own
/// Firestore listeners.
class LiveData extends ChangeNotifier {
  LiveData() {
    _subs = [
      _listen<List<Vehicle>>(
        VehicleRepository.instance.watchAll(),
        (v) => vehicles = v,
      ),
      _listen<List<Repair>>(
        RepairRepository.instance.watchAll(),
        (v) => repairs = v,
      ),
      _listen<List<AppUser>>(UserRepository.instance.watchAll(), (v) {
        users = v;
        _usersById = {for (final u in v) u.uid: u};
      }),
      _listen<List<WalletEntry>>(
        WalletRepository.instance.watchAll(),
        (v) => entries = v,
      ),
      _listen<List<Tool>>(ToolRepository.instance.watchAll(), (v) => tools = v),
    ];
  }

  late final List<StreamSubscription<Object?>> _subs;

  List<Vehicle>? vehicles;
  List<Repair>? repairs;
  List<AppUser>? users;
  List<WalletEntry>? entries;

  /// Left out of [ready] on purpose: the tools screen handles its own
  /// loading, so a hiccup there cannot hold up services and the wallet.
  List<Tool>? tools;

  Object? error;
  Map<String, AppUser> _usersById = const {};

  bool get ready =>
      vehicles != null && repairs != null && users != null && entries != null;

  WalletEntry? entryById(String id) {
    for (final e in entries ?? const <WalletEntry>[]) {
      if (e.id == id) return e;
    }
    return null;
  }

  /// The tool a wallet entry bought, if it bought one.
  Tool? toolForEntry(String entryId) {
    if (entryId.isEmpty) return null;
    for (final t in tools ?? const <Tool>[]) {
      if (t.entryId == entryId) return t;
    }
    return null;
  }

  Vehicle? vehicleById(String id) {
    for (final v in vehicles ?? const <Vehicle>[]) {
      if (v.id == id) return v;
    }
    return null;
  }

  /// "First Last" of a user, or "—" when unknown.
  String nameOf(String uid) => _usersById[uid]?.displayName ?? '—';

  StreamSubscription<T> _listen<T>(Stream<T> stream, void Function(T) set) {
    return stream.listen(
      (value) {
        set(value);
        error = null;
        notifyListeners();
      },
      onError: (Object e) {
        error = e;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }
}
