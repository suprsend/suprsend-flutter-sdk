import 'dart:io';

import 'package:flutter/services.dart';

import 'ss_response.dart';

class SuprSendUser {
  final MethodChannel _channel;

  SuprSendUser(this._channel);

  Future<SSResponse> _invoke(String method, [dynamic args]) async {
    final result = await _channel.invokeMethod<dynamic>(method, args);
    return SSResponse.fromMap(result as Map<dynamic, dynamic>?);
  }

  Future<SSResponse> set(Map<String, dynamic> properties) =>
      _invoke('set', {'properties': properties});

  Future<SSResponse> setOnce(Map<String, dynamic> properties) =>
      _invoke('setOnce', {'properties': properties});

  Future<SSResponse> increment(Map<String, num> properties) =>
      _invoke('increment', {'properties': properties});

  Future<SSResponse> append(Map<String, dynamic> properties) =>
      _invoke('append', {'properties': properties});

  Future<SSResponse> remove(Map<String, dynamic> properties) =>
      _invoke('remove', {'properties': properties});

  Future<SSResponse> unset(List<String> keys) =>
      _invoke('unset', {'keys': keys});

  Future<SSResponse> addEmail(String email) =>
      _invoke('addEmail', {'value': email});

  Future<SSResponse> removeEmail(String email) =>
      _invoke('removeEmail', {'value': email});

  Future<SSResponse> addSMS(String mobile) =>
      _invoke('addSms', {'value': mobile});

  Future<SSResponse> removeSMS(String mobile) =>
      _invoke('removeSms', {'value': mobile});

  Future<SSResponse> addWhatsapp(String mobile) =>
      _invoke('addWhatsapp', {'value': mobile});

  Future<SSResponse> removeWhatsapp(String mobile) =>
      _invoke('removeWhatsapp', {'value': mobile});

  Future<SSResponse> setPreferredLanguage(String language) =>
      _invoke('setPreferredLanguage', {'value': language});

  Future<SSResponse> setTimezone(String timezone) =>
      _invoke('setTimezone', {'value': timezone});

  Future<SSResponse> addPush(String token) {
    if (Platform.isIOS) {
      return _invoke('addiOSPush', {'token': token});
    }
    return _invoke('setAndroidFcmPush', {'token': token});
  }

  Future<SSResponse> removePush(String token) {
    if (Platform.isIOS) {
      return _invoke('removeiOSPush', {'token': token});
    }
    return _invoke('removeAndroidFcmPush', {'token': token});
  }
}
