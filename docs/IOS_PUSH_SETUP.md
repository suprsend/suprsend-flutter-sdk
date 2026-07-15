# iOS Push Setup (APNS Push)

### Prerequisites

- [Integration of SuprSend Flutter SDK](../README.md#integration-steps)
- Configuring iOS vendor form in SuprSend Dashboard

> **Tip:**
> Example can be found in the
> [`example/`](https://github.com/suprsend/suprsend-flutter-sdk/tree/main/example)
> app.

## Step 1: Add capabilities in iOS application

Open `ios/Runner.xcworkspace`, select the **Runner** target → **Signing &
Capabilities**, click **+ Capability**, and add **Push Notifications**.

![Add the Push Notifications capability in Xcode](https://mintcdn.com/suprsend/3ix_OjxB_ZGM-pa-/images/docs/29bafbe-Screenshot_2022-05-19_at_5.48.52_PM.png?fit=max&auto=format&n=3ix_OjxB_ZGM-pa-&q=85&s=6dc8960bc305b9ff439cfd265cd4f1dc)

Add **Background Modes** the same way, then tick **Remote notifications**. This
lets APNs wake the app so delivery of background notifications can be tracked.

![Enable Background Modes → Remote notifications](https://mintcdn.com/suprsend/09Y8zJBSaqwwb23r/images/docs/75c5310-Screenshot_2022-09-27_at_1.48.11_PM.png?fit=max&auto=format&n=09Y8zJBSaqwwb23r&q=85&s=3455b9ac0218ac1621399be197c1b46a)

## Step 2: Ask permission and register for push notification

In `ios/Runner/AppDelegate.swift`, set the notification center delegate, request
permission, and register with APNs inside `didFinishLaunchingWithOptions`:

```swift
import UIKit
import Flutter
import UserNotifications
import SuprSendSwift

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Request notification permission and register for the APNs token.
    UNUserNotificationCenter.current().delegate = self
    UNUserNotificationCenter.current().requestAuthorization(
      options: [.alert, .sound, .badge]
    ) { granted, _ in
      if granted {
        DispatchQueue.main.async {
          application.registerForRemoteNotifications()
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### Step 2.1: Asking User to send push notifications

The `options` you pass to `requestAuthorization` decide how the user is prompted
for permission.

#### Explicit Authorization

This shows the system permission dialog and, once the user allows it, enables
alert, sound and badge.

```swift
UNUserNotificationCenter.current().requestAuthorization(
  options: [.alert, .sound, .badge]
) { granted, _ in
  // ...
}
```

> **Note**
> Explicit authorization is the default method, as it automatically sets alert,
> sound and badge as soon as the user allows the request.

![Explicit authorization permission prompt](https://mintcdn.com/suprsend/JOwfEC79k-vs3tUR/images/docs/8538f91-app_permission.png?fit=max&auto=format&n=JOwfEC79k-vs3tUR&q=85&s=3e3be8e0b3762dd835a490e6c4c1af7f)

#### Provisional Authorization

Supported on iOS 12+. Add `.provisional` to deliver notifications quietly (to
Notification Center only, without an upfront prompt) until the user chooses to
**Keep** or **Turn off** notifications.

```swift
UNUserNotificationCenter.current().requestAuthorization(
  options: [.alert, .sound, .badge, .provisional]
) { granted, _ in
  // ...
}
```

![Provisional authorization notification example](https://mintcdn.com/suprsend/ftswjUsq0JlUh-RL/images/docs/0367021-provisional.png?fit=max&auto=format&n=ftswjUsq0JlUh-RL&q=85&s=c44246faebb35ddb646e77c3ea29a522)

## Step 3: Enable sending and tracking of push notifications

Add the following overrides to `AppDelegate` to hand the APNs token to SuprSend
and forward notification lifecycle events, so delivery and clicks are tracked:

```swift
// APNs returned the device token — forward it to SuprSend.
override func application(
  _ application: UIApplication,
  didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
) {
  let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
  Task { _ = await SuprSendClient.shared.user.addiOSPush(token) }  // Send APNs token to SuprSend
  super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
}

// Background / silent notification delivery.
override func application(
  _ application: UIApplication,
  didReceiveRemoteNotification userInfo: [AnyHashable: Any],
  fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
) {
  SuprSendClient.shared.push.application(
    application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
  completionHandler(.newData)
}

// Notification shown while the app is in the foreground.
override func userNotificationCenter(
  _ center: UNUserNotificationCenter,
  willPresent notification: UNNotification,
  withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
) {
  SuprSendClient.shared.push.userNotificationCenter(
    center, willPresent: notification, withCompletionHandler: completionHandler)
  if #available(iOS 14.0, *) {
    completionHandler([.banner, .badge, .sound])
  } else {
    completionHandler([.alert, .badge, .sound])
  }
}

// User tapped or dismissed a notification.
override func userNotificationCenter(
  _ center: UNUserNotificationCenter,
  didReceive response: UNNotificationResponse,
  withCompletionHandler completionHandler: @escaping () -> Void
) {
  SuprSendClient.shared.push.userNotificationCenter(
    center, didReceive: response, withCompletionHandler: completionHandler)
  completionHandler()
}
```

> **Note**
> The token is associated with the current user automatically and cleared on
> [`SuprSend.reset()`](../README.md#step-3-reset-user), so notifications stop
> after logout.

## Step 4: Adding support for Notification service

A Notification Service Extension lets APNs payloads be modified before display —
for example to download and attach an image — and improves delivery tracking.
Add it if you send rich (image/media) notifications.

#### Step 1: In Xcode go to File > New > Target

#### Step 2: Select Notification Service Extension from the template list

#### Step 3: Name your Notification Service

Give the target a name, e.g. `NotificationService`.

![Naming the Notification Service target](https://mintcdn.com/suprsend/3ix_OjxB_ZGM-pa-/images/docs/2545534-Screenshot_2022-09-27_at_8.23.30_PM.png?fit=max&auto=format&n=3ix_OjxB_ZGM-pa-&q=85&s=7d5b605ac23ad4753e43f6bbfc846424)

#### Step 4: A folder will be created with your given product name

Xcode creates a folder containing `NotificationService.swift` and `Info.plist`.

![NotificationService.swift inside the new folder](https://mintcdn.com/suprsend/09Y8zJBSaqwwb23r/images/docs/507d91a-Screenshot_2022-09-27_at_8.30.25_PM.png?fit=max&auto=format&n=09Y8zJBSaqwwb23r&q=85&s=844b510f372bafdcb4ff19dc6120c314)

#### Step 5: Add the SuprSend pod and run pod install

In `ios/Podfile`, add a target block for the extension then run `pod install` from the `ios/` directory:

```ruby
# Notification Service Extension: links SuprSendSwift for rich (image/media) notifications.
target 'NotificationService' do
  use_frameworks!
  pod 'SuprSendSwift', '~> 1.2'
end
```

![Podfile with the NotificationService target](https://mintcdn.com/suprsend/JOwfEC79k-vs3tUR/images/docs/8397e64-Screenshot_2024-08-14_at_4.34.21_PM.png?fit=max&auto=format&n=JOwfEC79k-vs3tUR&q=85&s=3e0c42ccbf163298ffb941ca71a249f2)

#### Step 6: Replace values with your public key

Replace the generated `NotificationService.swift` code with below ones and add valid public api key in place of "YOUR_PUBLIC_KEY".

```swift
import UserNotifications
import SuprSendSwift

final class NotificationService: SuprSendNotificationService {
  // Must match the public key passed to SuprSend(...) in your Dart main().
  override func publicKey() -> String {
    "YOUR_PUBLIC_KEY"
  }
}
```

Thats it, you are all set to test your apns push
