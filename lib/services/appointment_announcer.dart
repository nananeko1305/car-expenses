import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/appointment.dart';

/// The push worker (see push_worker/). Its address is no secret: without
/// the ID token of an active account, it does nothing.
const pushWorkerUrl =
    'https://car-expenses-push.car-expenses.workers.dev/announce';

/// Asks the push worker to tell everyone about one booking. Which answer
/// comes back makes no difference here: the booking stays unannounced
/// until the worker marks it, so it is asked again on the next start.
Future<void> announceToWorker(String id) async {
  final token = await FirebaseAuth.instance.currentUser?.getIdToken();
  if (token == null) return;
  await http
      .post(
        Uri.parse(pushWorkerUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'appointmentId': id}),
      )
      .timeout(const Duration(seconds: 20));
}

/// Watches the calendar for bookings this account wrote that the server
/// has but nobody was told about, and asks for each to be announced, once
/// per session.
///
/// Going by what the server has, and not by the save, covers a booking
/// written offline, the app closed before it reached the server, and the
/// worker being down: each is picked up on the next change or start.
class AppointmentAnnouncer {
  AppointmentAnnouncer({
    required this._source,
    required this._read,
    required this._uid,
    required this._announce,
  });

  final Listenable _source;
  final List<Appointment>? Function() _read;
  final String _uid;
  final Future<void> Function(String id) _announce;
  final Set<String> _asked = {};

  void start() {
    _source.addListener(_check);
    _check();
  }

  void dispose() => _source.removeListener(_check);

  void _check() {
    for (final a in _read() ?? const <Appointment>[]) {
      if (a.ownerId == _uid && a.awaitsPush && _asked.add(a.id)) {
        _announce(a.id).catchError((Object _) {
          // Offline, or the worker is down: tried again on the next start.
        });
      }
    }
  }
}
