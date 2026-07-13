# SuprSend Flutter SDK

[![pub package](https://img.shields.io/pub/v/suprsend_flutter_sdk.svg)](https://pub.dev/packages/suprsend_flutter_sdk)

Official Flutter SDK for [SuprSend](https://www.suprsend.com) — user
identification, event tracking, user properties & channels, and push
notifications.

This plugin is a thin, type-safe Dart wrapper over the native SuprSend SDKs:

| Platform | Native SDK | Min version |
| -------- | ---------- | ----------- |
| Android  | `com.suprsend:native` 2.0.1 | minSdk 19 |
| iOS      | `SuprSendSwift` 1.2.0 | iOS 15.0 |

## Installation

```yaml
dependencies:
  suprsend_flutter_sdk: ^3.0.0
```

```sh
flutter pub get
```

### iOS

The iOS deployment target must be at least **15.0**. In `ios/Podfile`:

```ruby
platform :ios, '15.0'
```

Then run `cd ios && pod install`.

### Android

No extra setup is required for the core SDK — the native dependency is pulled in
automatically. For push notifications, add Firebase Cloud Messaging to your app
(see [Push notifications](#push-notifications)).

## Quick start

Initialize the SDK once, as early as possible (e.g. in `main`), by constructing
it with your workspace **public key** (found in the SuprSend dashboard).
Everything else is then called statically on the `SuprSend` class.

```dart
import 'package:suprsend_flutter_sdk/suprsend_flutter_sdk.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SuprSend(
    'YOUR_PUBLIC_KEY',
    appName: 'My App',       // optional
    appVersion: '1.0.0',     // optional
    // host: 'https://hub.suprsend.com', // optional custom host
  );

  runApp(const MyApp());
}
```

All asynchronous calls resolve to an [`SSResponse`](#ssresponse).

## Identifying users

```dart
// Anonymous events are attributed to the current device until you identify.
await SuprSend.identify('user-distinct-id');

// Recommended: pass a JWT signed by your backend for authenticated mode.
await SuprSend.identify('user-distinct-id', userToken: jwt);

// Enhanced security: let the SDK fetch a fresh JWT before the current one
// expires. `refreshUserToken` receives the expiring token and its decoded
// payload, and must return the new signed token.
await SuprSend.identify(
  'user-distinct-id',
  userToken: jwt,
  refreshUserToken: (oldUserToken, tokenPayload) async {
    return await myBackend.fetchSuprSendToken('user-distinct-id');
  },
);

final identified = await SuprSend.isIdentified();
final distinctId = await SuprSend.getDistinctId();

// On logout — detaches the push token by default.
await SuprSend.reset();
```

## Tracking events

```dart
await SuprSend.track('product_viewed', {
  'product_id': 42,
  'name': 'Running shoes',
  'price': 129.99,
});
```

## User properties & channels

```dart
final user = SuprSend.user;

await user.set({'first_name': 'Ada', 'plan': 'pro'});
await user.setOnce({'signup_date': '2026-06-05'});
await user.increment({'logins': 1});
await user.append({'tags': 'beta'});
await user.remove({'tags': 'beta'});
await user.unset(['plan']);

// Communication channels
await user.addEmail('ada@example.com');
await user.addSMS('+15551234567');        // E.164 format
await user.addWhatsapp('+15551234567');

await user.setPreferredLanguage('en');
await user.setTimezone('America/New_York');
```

## Push notifications

Push is configured natively on each platform; there is no Dart API to call.
Token registration, permission prompts and subscription sync are handled by the
underlying native SDKs.

### iOS

Request notification permission and register the APNs token from your
`AppDelegate`, and forward notification delegate callbacks to
`SuprSendClient.shared.push`. To render rich notifications, add a Notification
Service Extension that subclasses `SuprSendNotificationService`. See the
[iOS push guide](https://docs.suprsend.com).

### Android

1. Add Firebase to your app (`google-services.json` + the Google Services
   Gradle plugin).
2. The plugin bundles `app.suprsend.fcm.SSFirebaseMessagingService` (merged into
   your manifest automatically), which obtains the FCM token and keeps it in
   sync with SuprSend.

If your app uses its own `FirebaseMessagingService`, forward new tokens to the
bundled service. See the [Android push guide](https://docs.suprsend.com).

## SSResponse

```dart
final res = await SuprSend.user.addEmail('ada@example.com');
if (res.isSuccess) {
  // ...
} else {
  print('${res.errorType}: ${res.errorMessage}');
}
```

| Field | Type | Description |
| ----- | ---- | ----------- |
| `status` | `String` | `"success"` or `"error"` |
| `isSuccess` | `bool` | Convenience getter |
| `statusCode` | `int?` | HTTP status code, when available |
| `errorType` | `String?` | e.g. `VALIDATION_ERROR`, `NETWORK_ERROR` |
| `errorMessage` | `String?` | Human readable error |

## Logging

```dart
await SuprSend.enableLogging();
```

> Logging is off by default. `enableLogging()` turns on verbose logging in the
> native SDK (mapped to `LogLevel.VERBOSE` on Android).

## Example

A runnable example is in [`example/`](example/lib/main.dart).

## License

[MIT](LICENSE)
