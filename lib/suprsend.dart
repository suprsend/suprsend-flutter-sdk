import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'user.dart';

class suprsend {
  static const MethodChannel _channel = MethodChannel('suprsend_flutter_sdk');
  static User user = User(_channel);
  static bool isAndroid = Platform.isAndroid;

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static void setLogLevel(int logLevelInt) {
    _channel.invokeMethod("setLogLevel", {"logLevel": logLevelInt});
  }

  static void identify(String uniqueId) {
    _channel.invokeMethod("identify", {"uniqueId": uniqueId});
  }

  static void track(String eventName, [Map<String, Object?>? properties]) {
    _channel.invokeMethod(
        "track", {"eventName": eventName, "properties": properties});
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
    _channel.invokeMethod("setSuperProperties", properties);
  }

  static void unSetSuperProperty(String key) {
    _channel.invokeMethod("unSetSuperProperty", {"key": key});
  }

  static void purchaseMade(Map<String, Object?>? properties) {
    _channel.invokeMethod("purchaseMade", properties);
  }

  static void showNotification(String payload) {
    if (isAndroid) {
      _channel.invokeMethod(
          "showNotification", {"notificationPayloadJson": payload});
    }
  }

  static Future<PermissionStatus>? showNotificationPermission() {
    if (isAndroid) {
      return Permission.notification.request();
    }
    return null;
  }

  static void flush() {
    _channel.invokeMethod("flush");
  }

  static void reset() {
    _channel.invokeMethod("reset");
  }
}
