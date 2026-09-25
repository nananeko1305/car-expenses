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
    _watch(VehicleRepository.instance.watchAll, (v) => vehicles = v);
    _watch(RepairRepository.instance.watchAll, (v) => repairs = v);
    _watch(UserRepository.instance.watchAll, (v) {
      users = v;
      _usersById = {for (final u in v) u.uid: u};
    });
    _watch(WalletRepository.instance.watchAll, (v) => entries = v);
    _watch(ToolRepository.instance.watchAll, (v) => tools = v);
  }

  static const _firstRetry = Duration(seconds: 5);
  static const _longestRetry = Duration(minutes: 1);

  final List<StreamSubscription<Object?>> _subs = [];
  final List<Timer> _retries = [];
  bool _disposed = false;

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

  /// Subscribes to a collection, and subscribes again after a failure.
  ///
  /// A Firestore listener that errors is finished — it never recovers on
  /// its own. Rules that have just been deployed, or a profile that was
  /// enabled a moment ago, would otherwise leave the app waiting on data
  /// that will never arrive until it is force-closed.
  void _watch<T>(
    Stream<T> Function() open,
    void Function(T) set, {
    Duration wait = _firstRetry,
  }) {
    late final StreamSubscription<T> sub;
    sub = open().listen(
      (value) {
        set(value);
        error = null;
        notifyListeners();
      },
      onError: (Object e) {
        error = e;
        notifyListeners();
        sub.cancel();
        _subs.remove(sub);
        _retryLater(open, set, wait);
      },
    );
    _subs.add(sub);
  }

  void _retryLater<T>(
    Stream<T> Function() open,
    void Function(T) set,
    Duration wait,
  ) {
    late final Timer timer;
    timer = Timer(wait, () {
      _retries.remove(timer);
      if (_disposed) return;
      // Backs off, so a collection nobody may read is not retried in a
      // tight loop for as long as the app is open.
      final next = wait * 2;
      _watch(open, set, wait: next > _longestRetry ? _longestRetry : next);
    });
    _retries.add(timer);
  }

  @override
  void dispose() {
    _disposed = true;
    for (final s in _subs) {
      s.cancel();
    }
    for (final t in _retries) {
      t.cancel();
    }
    super.dispose();
  }
}
