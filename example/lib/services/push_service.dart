import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:suprsend_flutter_sdk/suprsend_flutter_sdk.dart';

/// Headless FCM integration: the app owns the push pipeline and hands the device
/// token to SuprSend via addPush (APNs token on iOS, FCM token on Android).
class PushService {
  PushService._();

  static final PushService instance = PushService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  bool _listenersReady = false;
  String? _lastRegisteredToken;

  /// Wires up the FCM listeners. Safe to call multiple times; call once at startup.
  Future<void> init() async {
    if (_listenersReady) return;
    _listenersReady = true;

    await _initLocalNotifications();

    // iOS shows nothing in the foreground unless we opt in (no-op on Android).
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // FCM rotates its token periodically; re-register so SuprSend stays current.
    _messaging.onTokenRefresh.listen((_) => _registerCurrentToken());

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTapped);

    // App launched from a terminated state by tapping a notification.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) _onNotificationTapped(initialMessage);
  }

  /// Requests permission and registers the token. Call after the user is identified.
  Future<void> syncToken() async {
    final settings = await _messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('[Push] notification permission denied');
      return;
    }
    await _registerCurrentToken();
  }

  // Placeholder APNs token firebase_messaging returns on the simulator;
  // registering it would make SuprSend store an undeliverable token.
  static const String _fakeSimulatorApnsToken =
      '66616b652d61706e732d746f6b656e2d666f722d73696d756c61746f72';

  // APNs token on iOS, FCM token on Android. On iOS it arrives asynchronously,
  // so poll briefly until a real token is available.
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
    final content = _resolveContent(message);
    debugPrint(
      '[Push] foreground message: ${message.messageId} '
      '"${content.title}" / "${content.body}"',
    );
    debugPrint('[Push] foreground payload: ${message.data}');
    // Android never auto-presents foreground messages; iOS is handled above.
    if (Platform.isAndroid) showLocalNotification(message);
  }

  void _onNotificationTapped(RemoteMessage message) {
    debugPrint('[Push] notification tapped, data: ${message.data}');
  }
}

/// Handles messages while the app is backgrounded or terminated. Must be a
/// top-level/static function; it runs in a separate background isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[Push] background message: ${message.messageId}');
  // The isolate is fresh, so re-init the local-notifications plugin here.
  await _initLocalNotifications();
  await showLocalNotification(message);
}

// Top-level so the background isolate can reuse the same setup.
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
  // FCM already asked for permission, so don't prompt again here.
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

// SuprSend packs the whole Android notification into this data key as JSON.
const String _suprSendPayloadKey = 'supr_send_n_pl';

Map<String, dynamic>? _parseSuprSendPayload(RemoteMessage message) {
  final raw = message.data[_suprSendPayloadKey];
  if (raw is! String || raw.isEmpty) return null;
  try {
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? decoded : null;
  } catch (e) {
    debugPrint('[Push] failed to parse $_suprSendPayloadKey: $e');
    return null;
  }
}

// iOS gets a standard APNs alert on message.notification; Android is data-only,
// so the content lives in SuprSend's payload JSON.
({String title, String body}) _resolveContent(RemoteMessage message) {
  final notification = message.notification;

  if (Platform.isIOS) {
    return (
      title: notification?.title ?? 'SuprSend',
      body: notification?.body ?? 'You have a new notification',
    );
  }

  final payload = _parseSuprSendPayload(message);
  return (
    title: payload?['notificationTitle'] as String? ??
        notification?.title ??
        'SuprSend',
    body: payload?['shortDescription'] as String? ??
        payload?['longDescription'] as String? ??
        notification?.body ??
        'You have a new notification',
  );
}

Future<void> showLocalNotification(RemoteMessage message) async {
  final content = _resolveContent(message);

  await _localNotifications.show(
    message.hashCode,
    content.title,
    content.body,
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
