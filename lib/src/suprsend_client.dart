import 'dart:convert';

import 'package:flutter/services.dart';

import 'ss_response.dart';
import 'suprsend_user.dart';
import 'version.dart';

/// Called by the SDK to obtain a fresh user token shortly before the current
/// one expires (enhanced security mode). Return the new signed JWT.
///
/// - [oldUserToken] is the token that is about to expire (empty string if none
///   is available yet).
/// - [tokenPayload] is the decoded JWT claims of [oldUserToken] (empty map if
///   the token can't be decoded).
///
/// Mirrors the `refreshUserToken(oldUserToken, tokenPayload)` callback used by
/// SuprSend's web, React and iOS SDKs.
typedef SSRefreshUserTokenCallback = Future<String> Function(
  String oldUserToken,
  Map<String, dynamic> tokenPayload,
);

class SuprSend {
  SuprSend._();

  static const MethodChannel _channel = MethodChannel('suprsend_flutter_sdk');

  static final SuprSendUser user = SuprSendUser(_channel);

  static SSRefreshUserTokenCallback? _refreshUserToken;
  static bool _handlerRegistered = false;

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

  /// Identifies the current user with [distinctId].
  ///
  /// In enhanced security mode pass the signed [userToken] (JWT). Provide
  /// [refreshUserToken] to let the SDK request a fresh token from you shortly
  /// before the current one expires — it is invoked with the expiring token and
  /// its decoded payload, and must return the new signed JWT.
  static Future<SSResponse> identify(
    String distinctId, {
    String? userToken,
    SSRefreshUserTokenCallback? refreshUserToken,
  }) async {
    _refreshUserToken = refreshUserToken;
    if (refreshUserToken != null) _ensureHandlerRegistered();
    final result = await _channel.invokeMethod<dynamic>('identify', {
      'distinctId': distinctId,
      'userToken': userToken,
      'hasRefreshUserToken': refreshUserToken != null,
    });
    return SSResponse.fromMap(result as Map<dynamic, dynamic>?);
  }

  /// Registers the reverse method-call handler used by the native SDKs to call
  /// back into Dart (currently only for [refreshUserToken]). Idempotent.
  static void _ensureHandlerRegistered() {
    if (_handlerRegistered) return;
    _channel.setMethodCallHandler(_handleNativeCall);
    _handlerRegistered = true;
  }

  static Future<dynamic> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'refreshUserToken':
        final callback = _refreshUserToken;
        if (callback == null) return null;
        final args = (call.arguments as Map?) ?? const {};
        final oldUserToken = (args['oldUserToken'] as String?) ?? '';
        try {
          return await callback(oldUserToken, _decodeJwtPayload(oldUserToken));
        } catch (_) {
          // Swallow errors so the native side falls back to retry/expire
          // rather than crashing the platform call.
          return null;
        }
      default:
        return null;
    }
  }

  /// Decodes the claims segment of a JWT. Returns an empty map if [token] is
  /// not a well-formed JWT.
  static Map<String, dynamic> _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return const {};
      final normalized = base64.normalize(parts[1]);
      final decoded = utf8.decode(base64.decode(normalized));
      final payload = json.decode(decoded);
      return payload is Map<String, dynamic> ? payload : const {};
    } catch (_) {
      return const {};
    }
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
