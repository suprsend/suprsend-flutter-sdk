# Suprsend

---

SuprSend is a notification stack as a service platform for easily creating, managing and delivering notifications to your end users. SuprSend has all the features set which enables you to send notifications in a reliable and scalable manner, as well as take care of end user experience, thereby eliminating the need to build any notification service in-house.

Benefits of using SuprSend as your notification stack are that:

- You do not have to do any vendor integrations for channels in your code. You can easily add / remove / prioritize vendors and channels from your SuprSend account,
- You can design powerful templates for all channels together and manage them from a single place,
- You can leverage powerful features to experiment fast with notifications as well as take care of end user experience without writing a single line of code.

### SDK Usage

This client side Flutter SDK can be used to send and track android push notifications, track user properties and events from the frontend clients. With the help of this sdk, you will be able to trigger workflows directly from your app, and render push notifications on the android devices. [Refer doc](https://docs.suprsend.com/docs/getting-started) for further details about Suprsend and how to trigger workflows with the help of this notification stack

### Version Supported

Ensure your minSDK is at least API 19 or above

### Installation

**Step 1. Open your Flutter project’s pubspec.yaml file**
Add following line of code inside dependencies in `pubspec.yaml` file

```
dependencies:
  flutter:
  	sdk: flutter
  suprsend_flutter_sdk: "^0.0.5"
```

**Step 2. Run `flutter pub get` in the terminal, or click _Pub get_ button in IntelliJ or Android Studio.**

```
$ flutter pub get
```

### Initialization

**Step 1:** To integrate SuprSend in your Android app, you will need to initialize the suprsend flutter sdk in your MainApplication class. Please note that if the main application is not created, you'll have to create the class.
Go to your android folder in the flutter project and perform the below steps:

```
import app.suprsend.SSApi; // import sdk

class MainApplication : Application(){

  override fun onCreate() {

  	// Important! without this, SDK will not work
 	SSApi.init(this, workspace_key, workspace_secret)

  	// Optional. Add this if you want to support Xiaomi notifications framework
  	SSApi.initXiaomi(this, xiaomi_app_id, xiaomi_api_key)

  	// Both initializations have to be called before the call to super()
 	super.onCreate()
  }
}
```

For initializing SDK, you need **workspace_key** and **workspace_secret**. You will get both the tokens from [client dashboard](https://app.suprsend.com/). For more details, check the [documentation on 'Workspaces'](https://docs.suprsend.com/docs/workspace).

**Step 2: To call suprsend events, you'll need to import suprsend SDK in your dart file**
Go back to the flutter folder and follow below steps:

```
import 'package:suprsend_flutter_sdk/suprsend.dart';
```

> **_Troubleshooting notes_**  
> In case you face compilation errors or warnings, please perform the following troubleshooting steps:

    - Ensure mavenCentral() is present under repositories in your project's build.gradle file
    - Ensure your minimum SDK version is 19 or above
    - Perform gradle sync after adding the suprsend sdk

You are all set to use the flutter SDK now for sending push notifications. For details on setting user properties and triggering workflows, please refer to [Suprsend Documentation](https://docs.suprsend.com/docs/getting-started)
