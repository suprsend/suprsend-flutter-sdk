# Android Push Setup (FCM Push)

### Prerequisites

- [Integration of SuprSend Flutter SDK](../README.md#integration-steps)
- Configuring Android vendor form in SuprSend Dashboard

> **Tip:**
> Example can be found in the
> [`example/`](https://github.com/suprsend/suprsend-flutter-sdk/tree/main/example)
> app.

## Step 1: Create a Firebase project in the firebase console

Create a Firebase project (or reuse an existing one) in the
[Firebase console](https://console.firebase.google.com/) and register your
Android app using its `applicationId` (the same value as `applicationId` in
`android/app/build.gradle`).

## Step 2: Adding google-services.json to your project

Download the **`google-services.json`** file for your registered Android app from
the Firebase console and place it in your app module:

```
android/app/google-services.json
```

## Step 3: Adding Firebase dependencies and plugins

Depending on your project, use either the **Groovy** (`*.gradle`) or **Kotlin
DSL** (`*.gradle.kts`) snippets below.

**1. Declare the Google Services Gradle plugin** in `settings.gradle` (top-level,
`apply false`). Add it to your existing `plugins { }` block:

```groovy
// Groovy — android/settings.gradle
plugins {
    // ...
    id "com.google.gms.google-services" version "4.3.13" apply false // or latest version
}

// Kotlin DSL — android/settings.gradle.kts
plugins {
    // ...
    id("com.google.gms.google-services") version "4.3.13" apply false // or latest version
}
```

**2. Apply the plugin** in your app module. Add it to the existing `plugins { }`
block:

```groovy
// Groovy — android/app/build.gradle
plugins {
    // ...
    id "com.google.gms.google-services"
}

// Kotlin DSL — android/app/build.gradle.kts
plugins {
    // ...
    id("com.google.gms.google-services")
}
```

**3. Add the Firebase Messaging dependency** in your app module.

```groovy
// Groovy — android/app/build.gradle
dependencies {
    implementation "com.google.firebase:firebase-messaging:22.0.0" // or latest version
}

// Kotlin DSL — android/app/build.gradle.kts
dependencies {
    implementation("com.google.firebase:firebase-messaging:22.0.0") // or latest version
}
```

## Step 4: Implementing push

### Use SuprSend Background service (Recommended)

This is simplest way to implement push and everything is handled by suprsend background service like Token generating, attaching it to user, showing notification and tracking analytics. Register the SDK's messaging service inside the `<application>` tag of
`android/app/src/main/AndroidManifest.xml`:

```xml
<service
    android:name="app.suprsend.fcm.SSFirebaseMessagingService"
    android:enabled="true"
    android:exported="false">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
</service>
```

## Targeting Android 13 (API-33)

### Step 1: Add POST_NOTIFICATIONS permission in AndroidManifest.xml if not present already.

```xml
<manifest ...>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <application ...>
        ...
    </application>
</manifest>
```

### Step 2: Ask notification permission to show push notifications

The example uses
[`permission_handler`](https://pub.dev/packages/permission_handler):

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> requestNotificationPermission() async {
  final status = await Permission.notification.status;
  // Android 13+ shows the POST_NOTIFICATIONS dialog; older versions grant by default.
  if (status.isDenied) {
    await Permission.notification.request();
  }
}
```
