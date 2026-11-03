import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/appointment_push.dart';
import 'push_token_repository.dart';

/// Notifications over Firebase Cloud Messaging: new releases and the
/// calendar.
///
/// Every install subscribes to the [releasesTopic]; CI sends one message
/// to it after publishing a new APK. Calendar pushes carry booking text, so
/// they go to the phones of active accounts one by one instead, from the
/// push worker (see push_worker/), which is why [registerToken] exists.
///
/// While the app is closed or in the background, Android shows a
/// notification itself. When a release message arrives in the foreground,
/// or the user taps the notification, [onRelease] fires so the UI can show
/// the update dialog. A calendar push in the foreground fires
/// [onAppointment]; tapping one only opens the app.
class PushService {
  PushService._();
  static final PushService instance = PushService._();

  static const releasesTopic = 'releases';

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final StreamController<void> _releases = StreamController.broadcast();
  final StreamController<AppointmentPush> _appointments =
      StreamController.broadcast();
  bool _listening = false;
  bool _started = false;

  /// The token last tied to an account, to untie it on sign-out.
  String? _token;

  /// Emits whenever a release notification was received or opened.
  Stream<void> get onRelease => _releases.stream;

  /// Emits a calendar push received while the app is open.
  Stream<AppointmentPush> get onAppointment => _appointments.stream;

  /// Idempotent; safe to call on every app start. Failures (no Play
  /// services, offline) are swallowed — the start-up check still works.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    _listen();
    try {
      // Android 13+ shows the system permission prompt once.
      await _fcm.requestPermission();
      await _fcm.subscribeToTopic(releasesTopic);
    } catch (_) {
      // Retried automatically on the next app start.
      _started = false;
    }
  }

  /// Once per process, however many times [start] is retried.
  void _listen() {
    if (_listening) return;
    _listening = true;
    FirebaseMessaging.onMessage.listen(_onForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(_checkRelease);
    _fcm.onTokenRefresh.listen(_saveToken);
  }

  /// Ties this phone to the signed-in account. Not part of [start], which
  /// runs once: another account can sign in without the process ending.
  Future<void> registerToken() async {
    try {
      final token = await _fcm.getToken();
      if (token != null) await _saveToken(token);
    } catch (_) {
      // Retried automatically on the next visit to the home screen.
    }
  }

  /// Unties this phone from the account. Needs the sign-in, so it comes
  /// before signing out.
  Future<void> forgetToken() async {
    final token = _token;
    if (token == null) return;
    _token = null;
    await PushTokenRepository.instance.delete(token);
  }

  Future<void> _saveToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    _token = token;
    try {
      await PushTokenRepository.instance.save(token, uid);
    } catch (_) {
      // Retried automatically on the next visit to the home screen.
    }
  }

  void _onForeground(RemoteMessage message) {
    _checkRelease(message);
    final push = AppointmentPush.fromMessage(
      message.data,
      message.notification?.body,
    );
    if (push != null) _appointments.add(push);
  }

  void _checkRelease(RemoteMessage message) {
    if (message.data['type'] == 'release') _releases.add(null);
  }
}
