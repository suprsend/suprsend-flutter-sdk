import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suprsend_flutter_sdk/suprsend_flutter_sdk.dart';

import 'auth_token_service.dart';

// Holds the SuprSend session and exposes it as a Listenable so the router reacts to sign-in/out.
class AuthController extends ChangeNotifier {
  AuthController(this._tokenService);

  static const String _distinctIdPrefKey = 'suprsend_distinct_id';
  static const String _useUserTokenPrefKey = 'suprsend_use_user_token';

  final AuthTokenService _tokenService;

  bool _loading = true;
  String? _distinctId;

  // A deep-link location that arrived during startup, replayed by the router after sign-in.
  String? _pendingLocation;

  bool get loading => _loading;
  bool get isLoggedIn => _distinctId != null;
  String? get distinctId => _distinctId;

  void setPendingLocation(String location) => _pendingLocation = location;

  String? takePendingLocation() {
    final location = _pendingLocation;
    _pendingLocation = null;
    return location;
  }

  // Restores a persisted session, re-identifying so the token and refresh callback are refreshed.
  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    String? distinctId = prefs.getString(_distinctIdPrefKey);
    if (distinctId != null) {
      await _identify(
        distinctId,
        useUserToken: prefs.getBool(_useUserTokenPrefKey) ?? false,
      );
    } else if (await SuprSend.isIdentified()) {
      distinctId = await SuprSend.getDistinctId();
    }
    _distinctId = distinctId;
    _loading = false;
    notifyListeners();
  }

  Future<void> login(String distinctId, {bool useUserToken = false}) async {
    await _identify(distinctId, useUserToken: useUserToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_distinctIdPrefKey, distinctId);
    await prefs.setBool(_useUserTokenPrefKey, useUserToken);
    _distinctId = distinctId;
    notifyListeners();
  }

  Future<void> logout() async {
    await SuprSend.reset();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_distinctIdPrefKey);
    await prefs.remove(_useUserTokenPrefKey);
    _distinctId = null;
    _pendingLocation = null; // an explicit logout shouldn't resume anywhere
    notifyListeners();
  }

  // Plain identify when useUserToken is false; else fetch a signed token and register a refresh callback.
  Future<void> _identify(String distinctId, {required bool useUserToken}) async {
    if (!useUserToken) {
      await SuprSend.identify(distinctId);
      return;
    }
    final userToken = await _tokenService.fetchUserToken(distinctId);
    await SuprSend.identify(
      distinctId,
      userToken: userToken,
      refreshUserToken: _tokenService.isConfigured
          ? (oldUserToken, tokenPayload) async =>
              await _tokenService.fetchUserToken(distinctId) ?? oldUserToken
          : null,
    );
  }
}
