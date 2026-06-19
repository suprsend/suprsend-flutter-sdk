# suprsend_flutter_sdk_example

Demonstrates how to use the suprsend_flutter_sdk plugin.

## Configuration

Copy `.env.example` to `.env` and set your SuprSend workspace public key:

```
SUPRSEND_PUBLIC_KEY=your-public-key
```

## iOS push notifications (APNs)

Push is handled natively on iOS. This example already includes the setup:

- **`ios/Runner/AppDelegate.swift`** requests notification permission,
  registers for remote notifications, forwards the APNs token to SuprSend via
  `SuprSendClient.shared.user.addiOSPush(token)`, and routes
  delivery/tap/foreground callbacks through `SuprSendClient.shared.push`.
- **`ios/Runner/Runner.entitlements`** declares `aps-environment` and is wired
  into the Runner target (`CODE_SIGN_ENTITLEMENTS`).
- **`ios/Runner/Info.plist`** enables the `remote-notification` background mode.

To run on a device you still need to, in your Apple Developer account:

1. Enable the **Push Notifications** capability for the app's bundle id
   (`com.suprsend.suprsendFlutterSdkExample`) and use a matching provisioning
   profile.
2. Upload your APNs auth key / certificate to the SuprSend dashboard.

### Rich / media notifications

A **Notification Service Extension** is already included
(`ios/NotificationService/`) so SuprSend can render images / media and track
delivery reliably. It's wired into the Xcode project and the Podfile.

The extension can't read the app's `.env`, so set the **same** workspace public
key you use in `lib/main.dart` in
[`ios/NotificationService/NotificationService.swift`](ios/NotificationService/NotificationService.swift):

```swift
final class NotificationService: SuprSendNotificationService {
  override func publicKey() -> String { "your-public-key" }
}
```

See the [iOS APNs push guide](https://docs.suprsend.com/docs/ios-apns-push) for
full details.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
