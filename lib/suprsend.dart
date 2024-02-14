import 'dart:async';
import 'utils/platform_checker.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'user.dart';

class suprsend {
  static const MethodChannel _channel = MethodChannel('suprsend_flutter_sdk');
  static User user = User(_channel);

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static void setLogLevel(int logLevelInt) {
    if (isMobile) {
      _channel.invokeMethod("setLogLevel", {"logLevel": logLevelInt});
    }
  }

  static void identify(String uniqueId) {
    if (isMobile) {
      _channel.invokeMethod("identify", {"uniqueId": uniqueId});
    }
  }

  static void track(String eventName, [Map<String, Object?>? properties]) {
    if (isMobile) {
      _channel.invokeMethod(
          "track", {"eventName": eventName, "properties": properties});
    }
  }

  static void setAndroidFcmPush(String token) {
    if (isAndroid) {
      _channel.invokeMethod("setAndroidFcmPush", {"token": token});
    }
  }

  static void unSetAndroidFcmPush(String token) {
    if (isAndroid) {
      _channel.invokeMethod("unSetAndroidFcmPush", {"token": token});
    }
  }

  static void setAndroidXiaomiPush(String token) {
    if (isAndroid) {
      _channel.invokeMethod("setAndroidXiaomiPush", {"token": token});
    }
  }

  static void unSetAndroidXiaomiPush(String token) {
    if (isAndroid) {
      _channel.invokeMethod("unSetAndroidXiaomiPush", {"token": token});
    }
  }

  static void setSuperProperties(Map<String, Object?>? properties) {
    if (isMobile) {
      _channel.invokeMethod("setSuperProperties", properties);
    }
  }

  static void unSetSuperProperty(String key) {
    if (isMobile) {
      _channel.invokeMethod("unSetSuperProperty", {"key": key});
    }
  }

  static void purchaseMade(Map<String, Object?>? properties) {
    if (isMobile) {
      _channel.invokeMethod("purchaseMade", properties);
    }
  }

  static void showNotification(String payload) {
    if (isAndroid) {
      _channel.invokeMethod(
          "showNotification", {"notificationPayloadJson": payload});
    }
  }

  static Future<PermissionStatus>? askNotificationPermission() {
    if (isAndroid) {
      return Permission.notification.request();
    }
    return null;
  }

  static void flush() {
    if (isMobile) {
      _channel.invokeMethod("flush");
    }
  }

  static void reset({bool? unSubscribePush = true}) {
    if (isMobile) {
      _channel
          .invokeMethod("reset", {"unsubscribeNotification": unSubscribePush});
    }
  }
}
