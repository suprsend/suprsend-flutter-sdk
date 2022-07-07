import 'dart:async';

import 'package:flutter/services.dart';

import 'user.dart';

class suprsend {

  static const MethodChannel _channel = MethodChannel('suprsend_flutter_sdk');
  static User user = User(_channel);

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
    _channel.invokeMethod("track", {"eventName": eventName, "properties": properties});
  }

  static void setAndroidFcmPush(String token) {
    _channel.invokeMethod("setAndroidFcmPush", {"token": token});
  }

  static void unSetAndroidFcmPush(String token) {
    _channel.invokeMethod("unSetAndroidFcmPush", {"token": token});
  }

  static void init(String apiKey, String apiSecret, [String? apiBaseUrl]) {
    _channel.invokeMethod("init", {"apiKey": apiKey, "apiSecret": apiSecret, "apiBaseUrl": apiBaseUrl});
  }

  static void initXiaomi(String appId, String apiKey) {
    _channel.invokeMethod("initXiaomi", {"appId": appId, "apiKey": apiKey});
  }

  static void setAndroidXiaomiPush(String token) {
    _channel.invokeMethod("setAndroidXiaomiPush", {"token": token});
  }

  static void unSetAndroidXiaomiPush(String token) {
    _channel.invokeMethod("unSetAndroidXiaomiPush", {"token": token});
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
    _channel.invokeMethod("showNotification", {"notificationPayloadJson": payload});
  }

  static void flush() {
    _channel.invokeMethod("flush");
  }

  static void reset() {
    _channel.invokeMethod("reset");
  }
}
