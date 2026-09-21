import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/repair.dart';
import '../models/vehicle.dart';
import '../models/wallet_entry.dart';
import 'repair_repository.dart';
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
    ];
  }

  late final List<StreamSubscription<Object?>> _subs;

  List<Vehicle>? vehicles;
  List<Repair>? repairs;
  List<AppUser>? users;
  List<WalletEntry>? entries;
  Object? error;
  Map<String, AppUser> _usersById = const {};

  bool get ready =>
      vehicles != null && repairs != null && users != null && entries != null;

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
