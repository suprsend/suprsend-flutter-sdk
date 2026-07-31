# Migrating to v3 from v2

Migrating from v2 to v3 has breaking changes, as we have made some architectural level changes. Refer the v2 SDK [documentation](https://github.com/suprsend/suprsend-flutter-sdk-old/blob/main/docs) . Following are changes in detail:

### Installation

v3 requires iOS 15.0+ (v2 supported iOS 13.0+) and Android `minSdk` 19. Bump the version in `pubspec.yaml` and the deployment target in `ios/Podfile`, then run `flutter pub get` and `pod install` inside the `ios` folder.

```yaml v3
# pubspec.yaml (v3)
dependencies:
  suprsend_flutter_sdk: ^3.0.0

# ios/Podfile (v3)
platform :ios, '15.0'
```

```yaml v2
# pubspec.yaml (v2)
dependencies:
  suprsend_flutter_sdk: "^2.5.1"

# ios/Podfile (v2)
platform :ios, '13.0'
```

<br />

### Initializing SDK

v2 needed platform-specific initialization: `SSApi.init` in your Android `Application` class and `SuprSendSDKConfiguration` in `AppDelegate.swift`.

In v3 the SDK is initialized once from Dart in `main`, and all SDK methods can be accessed only after creating the instance. Remove the v2 native initialization code from both platforms.

```dart v3
// main.dart (v3)
import 'package:suprsend_flutter_sdk/suprsend_flutter_sdk.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SuprSend('YOUR_PUBLIC_KEY');

  runApp(const MyApp());
}
```

```dart v2
// main.dart (v2) — only imported the SDK, native code did the init
import 'package:suprsend_flutter_sdk/suprsend.dart';
```

<br />

### Authentication changes

In v2, workspace key and workspace secret are used to authenticate requests made to SuprSend which is not so secure. They were also passed in native code, which means the secret was shipped inside your app binary.

In v3 we have changed authentication to use public API Key (**ApiKeys → Public Keys** in dashboard) and Signed User Token. `userToken` is mandatory when enhanced security mode is on — refer [docs](https://docs.suprsend.com/docs/client-authentication#enhanced-security-mode-with-signed-user-token) to create it.

```dart v3
// main.dart (v3)
SuprSend('YOUR_PUBLIC_KEY');

await SuprSend.identify('user-distinct-id', userToken: jwt);
```

```text v2
// MainApplication.kt (v2) — Android initialization
SSApi.init(this, WORKSPACE_KEY, WORKSPACE_SECRET)

// AppDelegate.swift (v2) — iOS initialization
let suprSendConfiguration = SuprSendSDKConfiguration(withKey: "your workspace key", secret: "your workspace secret", baseUrl: nil)
SuprSend.shared.configureWith(configuration: suprSendConfiguration, launchOptions: launchOptions)

// main.dart (v2) — user identified without any token
suprsend.identify("user-distinct-id");
```

<br />

### Asynchronous methods

In v2 all methods used to be fire-and-forget and have returned `void`. In background SDK used to batch requests and make API calls.

In v3 every method returns a `Future<SSResponse>` so you could access response of API immediately depending on status of API call. Refer [API Response](../README.md#api-response) for the response structure.

```dart v3
// any Dart file (v3)
final response = await SuprSend.track('test');

print(response.status); // success or error
```

```dart v2
// any Dart file (v2) — fire-and-forget, no response to inspect
suprsend.track("test");
```

<br />

### Renamed class and methods

The lowercase `suprsend` class is now `SuprSend`, channel methods changed from `set`/`unSet` to `add`/`remove`, and push methods are no longer platform-specific.

| v2                                        | v3                                              |
| :---------------------------------------- | :---------------------------------------------- |
| `suprsend.identify(uniqueId)`             | `SuprSend.identify(distinctId, userToken: jwt)` |
| `suprsend.reset(unSubscribePush: true)`   | `SuprSend.reset(unsubscribePush: true)`         |
| `suprsend.setLogLevel(LogLevels.VERBOSE)` | `SuprSend.enableLogging()`                      |
| `suprsend.user.setEmail(email)`           | `SuprSend.user.addEmail(email)`                 |
| `suprsend.user.unSetEmail(email)`         | `SuprSend.user.removeEmail(email)`              |
| `suprsend.user.setSms(mobile)`            | `SuprSend.user.addSMS(mobile)`                  |
| `suprsend.user.unSetSms(mobile)`          | `SuprSend.user.removeSMS(mobile)`               |
| `suprsend.user.setWhatsApp(mobile)`       | `SuprSend.user.addWhatsapp(mobile)`             |
| `suprsend.user.unSetWhatsApp(mobile)`     | `SuprSend.user.removeWhatsapp(mobile)`          |
| `suprsend.user.unSet(keys)`               | `SuprSend.user.unset(keys)`                     |
| `suprsend.setAndroidFcmPush(token)`       | `SuprSend.user.addPush(token)`                  |
| `suprsend.unSetAndroidFcmPush(token)`     | `SuprSend.user.removePush(token)`               |

`track` and the user property methods (`set`, `setOnce`, `increment`, `append`, `remove`) keep their names, but now they are awaitable and their property argument is non-nullable.

<br />

### Removed methods

| Removed in v3                                | What to use instead                                                                        |
| :------------------------------------------- | :----------------------------------------------------------------------------------------- |
| `purchaseMade(properties)`                   | `track('\$purchase_made', properties)`                                                     |
| `setSuperProperties` / `unSetSuperProperty`  | Pass these properties as individual event properties in `track`.                            |
| `flush()`                                    | Nothing to flush — each call reaches SuprSend when you await it.                            |
| `setLogLevel(level)` and `LogLevels`         | `enableLogging()`, which turns on verbose logs.                                             |
| `showNotification(payload)`                  | Register the SuprSend messaging service — it displays notifications and tracks them for you. |

<br />

### Push notification setup changes

Push is still configured natively on each platform, but the integration steps changed. Refer [Android Push Setup](ANDROID_PUSH_SETUP.md) and [iOS Push Setup](IOS_PUSH_SETUP.md) for the complete v3 steps.

**Android** — Firebase setup and the `app.suprsend.fcm.SSFirebaseMessagingService` registration in `AndroidManifest.xml` stay the same. Only the removed `SSApi.init` call and the manual token/notification flow need to be cleaned up.

**iOS** — permission is requested with the standard `UNUserNotificationCenter` APIs instead of `SuprSend.shared.registerForPushNotifications(options:)`, the APNs token is passed with `SuprSendClient.shared.user.addiOSPush(token)` instead of `SuprSend.shared.setPushNotificationToken(token:)`, and notification callbacks are forwarded through `SuprSendClient.shared.push`. If you had added a Notification Service Extension, it now extends `SuprSendNotificationService` and only overrides `publicKey()`.

<br />

### Newly added in v3

| Method                                         | Description                                                       |
| :--------------------------------------------- | :---------------------------------------------------------------- |
| `SuprSend.identify(..., tenantId: id)`         | Scopes the user's activity to a tenant in multi-tenant workspaces. |
| `SuprSend.changeTenant(tenantId)`              | Switches the active tenant of an identified user.                  |
| `SuprSend.identify(..., refreshUserToken: cb)` | Returns a new `userToken` when the existing one expires.           |
| `SuprSend.isIdentified()`                      | Whether a user is currently identified.                            |
| `SuprSend.getDistinctId()`                     | Returns the `distinctId` of the identified user.                   |
| `SuprSend.user.setPreferredLanguage(lang)`     | Sets the user's preferred language for notifications.              |
| `SuprSend.user.setTimezone(tz)`                | Sets the user's timezone.                                          |

<br />

After migrating please test all library methods to see if everything is working properly. If you face any issue in migration process please reach out to us on our [slack community](https://join.slack.com/t/suprsendcommunity/shared_invite/zt-3932rw936-XNWY1RC8bsffh4if4ZyoXQ) or drop an email to us on [support@suprsend.com](mailto:support@suprsend.com)
