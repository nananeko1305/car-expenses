import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/appointment.dart';
import 'appointment_repository.dart';

/// The push worker (see push_worker/). Its address is no secret: without
/// the ID token of an active account, it does nothing.
const pushWorkerUrl = 'https://car-expenses-push.car-expenses.workers.dev';

/// Sends one booking to [path] on the push worker, as the signed-in account,
/// and returns the status it answered with.
Future<int> _askWorker(String path, String id, Duration limit) async {
  final token = await FirebaseAuth.instance.currentUser?.getIdToken();
  if (token == null) return HttpStatus.unauthorized;
  final response = await http
      .post(
        Uri.parse('$pushWorkerUrl/$path'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'appointmentId': id}),
      )
      .timeout(limit);
  return response.statusCode;
}

/// Asks the push worker to tell everyone about one booking. Which answer
/// comes back makes no difference here: the booking stays unannounced
/// until the worker marks it, so it is asked again on the next start.
Future<void> announceToWorker(String id) =>
    _askWorker('announce', id, const Duration(seconds: 20));

Future<int> _askToCancel(String id) =>
    _askWorker('cancel', id, const Duration(seconds: 10));

Future<void> _deleteDirectly(String id) =>
    AppointmentRepository.instance.delete(id);

/// Deletes a booking through the push worker, which then tells everyone.
/// Anything but a yes from it means deleting directly and telling nobody: a
/// booking must stay deletable offline and with the worker down. A refusal
/// from that delete reaches the caller, as it always has.
Future<void> cancelAppointment(
  String id, {
  Future<int> Function(String id) ask = _askToCancel,
  Future<void> Function(String id) delete = _deleteDirectly,
}) async {
  try {
    final status = await ask(id);
    if (status >= 200 && status < 300) return;
  } catch (_) {
    // Offline, or the worker is down: deleted below.
  }
  await delete(id);
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
