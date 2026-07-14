import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:suprsend_flutter_sdk/suprsend_flutter_sdk.dart';

/// Headless Firebase Cloud Messaging integration.
///
/// The app owns the entire push pipeline — permission prompt, token and message
/// handling — and only hands the token to SuprSend via [SuprSendUser.addPush]
/// so SuprSend can deliver notifications to this device. SuprSend does not
/// display notifications or manage the token for you.
///
/// Which token is registered depends on the platform, matching what SuprSend
/// stores for each channel:
///   * **iOS**   — the raw **APNs** device token (`getAPNSToken`).
///   * **Android** — the **FCM** registration token (`getToken`).
///
/// Usage:
///   1. In `main()`, before `runApp`:
///        await Firebase.initializeApp();
///        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
///        await PushService.instance.init();
///   2. After the user is identified (login / session restore):
///        await PushService.instance.syncToken();
class PushService {
  PushService._();

  static final PushService instance = PushService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  bool _listenersReady = false;
  String? _lastRegisteredToken;

  /// Wires up the FCM listeners. Safe to call multiple times; only the first
  /// call takes effect. Call once at startup.
  Future<void> init() async {
    if (_listenersReady) return;
    _listenersReady = true;

    await _initLocalNotifications();

    // iOS shows nothing in the foreground unless we opt in. This makes the OS
    // present incoming notification messages while the app is foregrounded
    // (no-op on Android, which never auto-presents foreground messages).
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // FCM rotates its token periodically; on iOS this also signals that the
    // APNs token may have changed. Re-register the platform-appropriate token
    // so SuprSend always has a deliverable one.
    _messaging.onTokenRefresh.listen((_) => _registerCurrentToken());

    // App in the foreground: SuprSend won't draw anything, so this is where you
    // present your own in-app UI (e.g. flutter_local_notifications).
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // A notification was tapped while the app was backgrounded (not terminated).
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTapped);

    // The app was launched from a terminated state by tapping a notification.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) _onNotificationTapped(initialMessage);
  }

  /// Requests notification permission, reads the current token and registers it
  /// with SuprSend. Call after the user has been identified.
  Future<void> syncToken() async {
    final settings = await _messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('[Push] notification permission denied');
      return;
    }
    await _registerCurrentToken();
  }

  /// Removes the currently registered token from SuprSend (e.g. on logout when
  /// you don't rely on `SuprSend.reset(unsubscribePush: true)`).
  Future<void> unregister() async {
    final token = _lastRegisteredToken ?? await _currentToken();
    if (token != null) await SuprSend.user.removePush(token);
    _lastRegisteredToken = null;
  }

  /// firebase_messaging hands out this placeholder on a simulator until a real
  /// APNs token arrives (hex of "fake-apns-token-for-simulator"). Registering it
  /// would make SuprSend store an undeliverable token → BadDeviceToken on send.
  static const String _fakeSimulatorApnsToken =
      '66616b652d61706e732d746f6b656e2d666f722d73696d756c61746f72';

  /// The push token SuprSend expects for this platform: the APNs token on iOS,
  /// the FCM token on Android.
  ///
  /// On iOS the real APNs token is delivered asynchronously after registration,
  /// so an immediate read can return null or the simulator placeholder. Poll
  /// briefly until a real token appears; returns null if none does (e.g. an
  /// environment without push).
  Future<String?> _currentToken() async {
    if (!Platform.isIOS) return _messaging.getToken();

    for (var attempt = 0; attempt < 8; attempt++) {
      final apns = await _messaging.getAPNSToken();
      if (apns != null && apns.toLowerCase() != _fakeSimulatorApnsToken) {
        return apns;
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    debugPrint('[Push] no real APNs token available (simulator placeholder/null)');
    return null;
  }

  Future<void> _registerCurrentToken() async {
    try {
      final token = await _currentToken();
      if (token != null) await _register(token);
    } catch (e) {
      debugPrint('[Push] failed to fetch push token: $e');
    }
  }

  Future<void> _register(String token) async {
    if (token == _lastRegisteredToken) return;
    final res = await SuprSend.user.addPush(token);
    if (res.isSuccess) {
      _lastRegisteredToken = token;
      debugPrint('[Push] push token registered with SuprSend');
    } else {
      debugPrint('[Push] token registration failed: ${res.errorMessage}');
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    debugPrint(
      '[Push] foreground message: ${message.messageId} '
      '"${message.notification?.title}"',
    );
    // Android never auto-presents foreground messages, so draw one ourselves.
    // iOS is handled by setForegroundNotificationPresentationOptions above, so
    // showing a local notification too would duplicate it.
    if (Platform.isAndroid) {
      showLocalNotification(message);
    }
  }

  void _onNotificationTapped(RemoteMessage message) {
    debugPrint('[Push] notification tapped, data: ${message.data}');
    // TODO: route based on message.data (e.g. a deep link).
  }
}

/// Handles messages delivered while the app is in the background or terminated.
///
/// Must be a top-level (or static) function annotated with `@pragma`, because
/// it runs in a separate background isolate that does not share state with the
/// app. Register it once in `main()` via `FirebaseMessaging.onBackgroundMessage`.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[Push] background message: ${message.messageId}');
  // The isolate is fresh, so re-init the local-notifications plugin here.
  await _initLocalNotifications();
  // Note: if the payload also carries a `notification` block, Android/iOS
  // already show that one in the tray, so this dummy will appear as a second
  // notification. Send data-only messages to avoid the duplicate.
  await showLocalNotification(message);
}

// --- Local notifications ---------------------------------------------------
//
// Kept as top-level members so the background isolate (which does not share
// state with the app) can reuse the exact same setup.

const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
  'suprsend_default',
  'SuprSend Notifications',
  description: 'Push notifications delivered through SuprSend.',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

Future<void> _initLocalNotifications() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  // FCM already asked for notification permission, so don't prompt again here.
  const iosInit = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  await _localNotifications.initialize(
    const InitializationSettings(android: androidInit, iOS: iosInit),
  );
  await _localNotifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_androidChannel);
}

/// Shows a local notification for [message]. Falls back to dummy text when the
/// payload carries no notification block (e.g. a data-only message).
Future<void> showLocalNotification(RemoteMessage message) async {
  final notification = message.notification;
  final title = notification?.title ?? 'SuprSend';
  final body = notification?.body ?? 'You have a new notification';

  await _localNotifications.show(
    message.hashCode,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannel.id,
        _androidChannel.name,
        channelDescription: _androidChannel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(),
    ),
    payload: message.data.isEmpty ? null : message.data.toString(),
  );
}
