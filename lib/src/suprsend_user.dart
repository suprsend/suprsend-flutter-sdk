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

  // Accepts either a `Map<String, V>` of properties, or a `String` key with
  // its value passed separately.
  static Map<String, V> _toProperties<V>(
      String method, Object keyOrProperties, V? value) {
    if (keyOrProperties is Map) {
      if (value != null) {
        throw ArgumentError(
            'value must not be passed when $method is called with a map');
      }
      // Check entries rather than the map's static type, so e.g. a
      // Map<String, dynamic> holding only numbers is accepted by increment.
      return keyOrProperties.map((k, v) {
        if (k is! String || v is! V) {
          throw ArgumentError.value(keyOrProperties, 'keyOrProperties',
              'must be a Map<String, $V>');
        }
        return MapEntry(k, v);
      });
    }
    if (keyOrProperties is String) {
      if (value == null) {
        throw ArgumentError.notNull('value');
      }
      return {keyOrProperties: value};
    }
    throw ArgumentError.value(keyOrProperties, 'keyOrProperties',
        'must be a String key or a Map<String, $V>');
  }

  /// `set('name', 'Jane')` or `set({'name': 'Jane', 'age': 30})`.
  Future<SSResponse> set(Object keyOrProperties, [dynamic value]) =>
      _invoke('set', {
        'properties': _toProperties<dynamic>('set', keyOrProperties, value)
      });

  /// `setOnce('signup_date', '2026-10-27')` or `setOnce({...})`.
  Future<SSResponse> setOnce(Object keyOrProperties, [dynamic value]) =>
      _invoke('setOnce', {
        'properties': _toProperties<dynamic>('setOnce', keyOrProperties, value)
      });

  /// `increment('login_count', 1)` or `increment({'login_count': 1})`.
  Future<SSResponse> increment(Object keyOrProperties, [num? value]) =>
      _invoke('increment', {
        'properties': _toProperties<num>('increment', keyOrProperties, value)
      });

  /// `append('tags', 'flutter')` or `append({'tags': 'flutter'})`.
  Future<SSResponse> append(Object keyOrProperties, [dynamic value]) =>
      _invoke('append', {
        'properties': _toProperties<dynamic>('append', keyOrProperties, value)
      });

  /// `remove('tags', 'flutter')` or `remove({'tags': 'flutter'})`.
  Future<SSResponse> remove(Object keyOrProperties, [dynamic value]) =>
      _invoke('remove', {
        'properties': _toProperties<dynamic>('remove', keyOrProperties, value)
      });

  /// `unset('plan')` or `unset(['plan', 'age'])`.
  Future<SSResponse> unset(Object keyOrKeys) {
    if (keyOrKeys is String) {
      return _invoke('unset', {'keys': [keyOrKeys]});
    }
    if (keyOrKeys is List && keyOrKeys.every((k) => k is String)) {
      return _invoke('unset', {'keys': keyOrKeys.cast<String>()});
    }
    throw ArgumentError.value(
        keyOrKeys, 'keyOrKeys', 'must be a String key or a List<String>');
  }

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
