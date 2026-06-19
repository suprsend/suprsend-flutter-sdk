import 'package:flutter/services.dart';

import 'ss_response.dart';
import 'suprsend_user.dart';
import 'version.dart';

class SuprSend {
  SuprSend._();

  static const MethodChannel _channel = MethodChannel('suprsend_flutter_sdk');

  static final SuprSendUser user = SuprSendUser(_channel);

  factory SuprSend(
    String publicKey, {
    String? host,
    String? appName,
    String? appVersion,
  }) {
    _channel.invokeMethod<void>('configure', {
      'publicKey': publicKey,
      'host': host,
      'appName': appName,
      'appVersion': appVersion,
      'sdkName': kSuprSendSdkName,
      'sdkVersion': kSuprSendSdkVersion,
    });
    return _instance;
  }

  static final SuprSend _instance = SuprSend._();

  static Future<SSResponse> identify(
    String distinctId, {
    String? userToken,
  }) async {
    final result = await _channel.invokeMethod<dynamic>('identify', {
      'distinctId': distinctId,
      'userToken': userToken,
    });
    return SSResponse.fromMap(result as Map<dynamic, dynamic>?);
  }

  static Future<bool> isIdentified({bool checkUserToken = false}) async {
    final result = await _channel.invokeMethod<bool>('isIdentified', {
      'checkUserToken': checkUserToken,
    });
    return result ?? false;
  }

  static Future<SSResponse> track(
    String event, [
    Map<String, dynamic>? properties,
  ]) async {
    final result = await _channel.invokeMethod<dynamic>('track', {
      'event': event,
      'properties': properties,
    });
    return SSResponse.fromMap(result as Map<dynamic, dynamic>?);
  }

  static Future<SSResponse> reset({bool unsubscribePush = true}) async {
    final result = await _channel.invokeMethod<dynamic>('reset', {
      'unsubscribePush': unsubscribePush,
    });
    return SSResponse.fromMap(result as Map<dynamic, dynamic>?);
  }

  static Future<void> enableLogging() {
    return _channel.invokeMethod<void>('enableLogging');
  }

  static Future<String?> getDistinctId() {
    return _channel.invokeMethod<String?>('getDistinctId');
  }
}
