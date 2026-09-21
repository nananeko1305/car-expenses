import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

/// Release notifications over Firebase Cloud Messaging.
///
/// Every install subscribes to the [releasesTopic]; CI sends one message
/// to it after publishing a new APK. While the app is closed or in the
/// background, Android shows the notification itself. When a release
/// message arrives in the foreground, or the user taps the notification,
/// [onRelease] fires so the UI can show the update dialog.
class PushService {
  PushService._();
  static final PushService instance = PushService._();

  static const releasesTopic = 'releases';

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final StreamController<void> _releases = StreamController.broadcast();
  bool _started = false;

  /// Emits whenever a release notification was received or opened.
  Stream<void> get onRelease => _releases.stream;

  /// Idempotent; safe to call on every app start. Failures (no Play
  /// services, offline) are swallowed — the start-up check still works.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    FirebaseMessaging.onMessage.listen(_handle);
    FirebaseMessaging.onMessageOpenedApp.listen(_handle);
    try {
      // Android 13+ shows the system permission prompt once.
      await _fcm.requestPermission();
      await _fcm.subscribeToTopic(releasesTopic);
    } catch (_) {
      // Retried automatically on the next app start.
      _started = false;
    }
  }

  void _handle(RemoteMessage message) {
    if (message.data['type'] == 'release') _releases.add(null);
  }
}
