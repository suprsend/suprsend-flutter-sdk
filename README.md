# SuprSend Flutter SDK

[![pub package](https://img.shields.io/pub/v/suprsend_flutter_sdk.svg)](https://pub.dev/packages/suprsend_flutter_sdk)

Official Flutter SDK for [SuprSend](https://www.suprsend.com) — user
identification, event tracking, user properties & channels, and push
notifications.

## Installation

```yaml
dependencies:
  suprsend_flutter_sdk: ^3.0.0
```

```sh
flutter pub get
```

**Requirements:** iOS 15.0+, Android minSdk 19.

For iOS, set the deployment target in `ios/Podfile`, then run `pod install`:

```ruby
platform :ios, '15.0'
```

## Quick start

Initialize the SDK once, as early as possible (e.g. in `main`), with your
workspace **public key** from the SuprSend dashboard. Everything else is called
statically on the `SuprSend` class.

```dart
import 'package:suprsend_flutter_sdk/suprsend_flutter_sdk.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SuprSend(
    'YOUR_PUBLIC_KEY',
    appName: 'My App',       // optional
    appVersion: '1.0.0',     // optional
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

// Optional: let the SDK fetch a fresh JWT before the current one expires.
await SuprSend.identify(
  'user-distinct-id',
  userToken: jwt,
  refreshUserToken: (oldUserToken, tokenPayload) async {
    return await myBackend.fetchSuprSendToken('user-distinct-id');
  },
);

final identified = await SuprSend.isIdentified();
final distinctId = await SuprSend.getDistinctId();

// On logout.
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

// Communication channels (each has a matching remove*).
await user.addEmail('ada@example.com');
await user.addSMS('+15551234567');        // E.164 format
await user.addWhatsapp('+15551234567');

await user.setPreferredLanguage('en');
await user.setTimezone('America/New_York');
```

## Push notifications

Push is configured natively on each platform; there is no Dart API to call.
Token registration, permission prompts and subscription sync are handled for you.

- **iOS:** request notification permission and register the APNs token from your
  `AppDelegate`, then forward the notification delegate callbacks to SuprSend.
  For rich notifications, add a Notification Service Extension.
  See the [iOS push guide](https://docs.suprsend.com).
- **Android:** add Firebase to your app (`google-services.json` + the Google
  Services Gradle plugin). Token sync works automatically.
  See the [Android push guide](https://docs.suprsend.com).

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

Logging is off by default. Turn on verbose logging while debugging:

```dart
await SuprSend.enableLogging();
```

## Example

A runnable example is in [`example/`](example/lib/main.dart).

## License

[MIT](LICENSE)
