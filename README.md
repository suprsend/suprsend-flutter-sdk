# SuprSend Flutter SDK

This SDK is used to integrate SuprSend features like Mobile Push, Preferences and InApp feed in to your Flutter application.

> 📘 This is v3 of suprsend_flutter_sdk
>
> - Documentation for v2 of this sdk is available [here](https://github.com/suprsend/suprsend-flutter-sdk-old/blob/main/README.md)
> - Please refer migration guide [here](https://docs.suprsend.com/docs/flutter-migration-from-v3).

## Installation

Add the SDK to your `pubspec.yaml`:

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

## Integration Steps

### Step 1: Create Client Instance

Initialize the SuprSend client inside `main`. All the methods of SuprSend SDK can be accessed only after creating instance.

```dart
import 'package:suprsend_flutter_sdk/suprsend_flutter_sdk.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SuprSend('YOUR_PUBLIC_KEY');

  runApp(const MyApp());
}
```

| Parameter    | Description                                                                                      |
| ------------ | ------------------------------------------------------------------------------------------------ |
| `publicKey*` | **Required.** Your workspace public key from the SuprSend dashboard (**ApiKeys → Public Keys**). |
| `host`       | Optional. Custom SuprSend API host; only needed for self-hosted or region-specific setups.       |

### Step 2: Authenticate User

Authenticate user so that all the actions performed after authenticating will be w.r.t that user. This is mandatory step and need to be called before using any other method. This is usually performed after successful login and on reload of page to re-authenticate user (can be changed based on your requirement).

```dart
await SuprSend.identify(
  'user-distinct-id',
  userToken: jwt, // only needed in production environments for security
  refreshUserToken: (oldUserToken, tokenPayload) async {
    return await myBackend.fetchSuprSendToken();
  },
);
```

| Properties       | Description                                                                                                                                                                                                                               |
| :--------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| distinctId\*     | Unique identifier to identify a user across platform.                                                                                                                                                                                     |
| userToken        | Mandatory when enhanced security mode is on. This is ES256 JWT token generated in your server-side. Refer [docs](https://docs.suprsend.com/docs/client-authentication#enhanced-security-mode-with-signed-user-token) to create userToken. |
| refreshUserToken | This function is called by SDK internally to get new userToken when existing user token is expired. The returned string is used as the new userToken.                                                                                     |

### Step 3: Reset User

This will remove user data from SuprSend instance similar to logout action.

```dart
await SuprSend.reset();
```

## Push Notifications

Push is configured natively on each platform. Follow the platform-specific guide:

- [iOS Push Setup (APNs)](doc/IOS_PUSH_SETUP.md)
- [Android Push Setup (FCM)](doc/ANDROID_PUSH_SETUP.md)

## Logging

Add below code in `main` below the SuprSend instance creation to see logs for debugging.

```dart
await SuprSend.enableLogging();
```

## API Response

All SuprSend SDK methods returns `SSResponse`. Use it to check whether a call succeeded and to read error details when it didn't.

```dart
final response = await SuprSend.user.addEmail('user@example.com');
if (response.isSuccess) {
  // handle success
} else {
  print('${response.errorType}: ${response.errorMessage}');
}
```

| Property     | Description                                                      |
| :----------- | :--------------------------------------------------------------- |
| status       | `"success"` or `"error"`.                                        |
| isSuccess    | `true` when the call succeeded (convenience getter over status). |
| statusCode   | HTTP status code, when available.                                |
| errorType    | Error category, e.g. `VALIDATION_ERROR`, `NETWORK_ERROR`.        |
| errorMessage | Human-readable error message.                                    |
