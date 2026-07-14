# suprsend_flutter_sdk_example

Demonstrates how to use the suprsend_flutter_sdk plugin.

## Configuration

Copy `.env.example` to `.env` and set your SuprSend workspace public key:

```
SUPRSEND_PUBLIC_KEY=your-public-key
```

## Push notifications (headless FCM)

Push is fully headless in this example: the app owns Firebase Cloud Messaging
(via the [`firebase_messaging`](https://pub.dev/packages/firebase_messaging)
plugin) for **both Android and iOS**, and only hands the token to SuprSend. The
SuprSend SDK does not draw notifications or manage the token for you.

`SuprSend.user.addPush(token)` expects the token SuprSend stores for each
channel: the **APNs** device token on iOS (`getAPNSToken`) and the **FCM**
registration token on Android (`getToken`). `PushService` picks the right one
per platform.

How it's wired up:

- **`lib/services/push_service.dart`** requests notification permission, reads
  the platform-appropriate token and registers it with
  `SuprSend.user.addPush(token)`, re-registers on `onTokenRefresh`, and exposes
  the foreground / tapped / background message handlers for you to build on.
- **`lib/main.dart`** calls `Firebase.initializeApp()`, registers the background
  message handler and `PushService.instance.init()` at startup.
- **`lib/services/auth_controller.dart`** calls `PushService.instance.syncToken()`
  right after the user is identified (a token must be attached to an identified
  user).

### Firebase setup

Both platforms need a Firebase project with Cloud Messaging enabled:

- **Android** — drop your **`google-services.json`** into `android/app/`. It is
  **not** checked in, so download it from your Firebase project (the app's
  package name is `com.suprsend.flutterexample` — register a matching Android app
  in Firebase, or change the `applicationId` to your own).
- **iOS** — drop your **`GoogleService-Info.plist`** into `ios/Runner/` and add
  it to the Runner target in Xcode. It is **not** checked in. The
  `aps-environment` entitlement and `remote-notification` background mode are
  already configured; you still need to enable the **Push Notifications**
  capability for your bundle id, use a matching provisioning profile, and upload
  your APNs auth key to Firebase.

After changing dependencies run `flutter pub get`, then `pod install` in `ios/`.

> **iOS notes:**
> - Real APNs push works on a physical device and on capable simulators
>   (iOS 16+ on an Apple-silicon Mac running macOS 13+). The real APNs token
>   arrives asynchronously after registration, so `PushService` polls
>   `getAPNSToken()` briefly and skips `firebase_messaging`'s
>   `fake-apns-token-for-simulator` placeholder — registering that would make
>   SuprSend store an undeliverable token (BadDeviceToken on send).
> - `firebase_messaging` 14.x (pinned by Flutter 3.19) ships a public header
>   that `#import`s the non-modular `<Firebase/Firebase.h>`, which Xcode 16+
>   rejects as a hard module error. The Podfile `post_install` rewrites it to
>   the modular framework umbrellas so it builds; this re-applies on every
>   `pod install`.

See the [SuprSend push docs](https://docs.suprsend.com) for backend / channel
configuration.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
