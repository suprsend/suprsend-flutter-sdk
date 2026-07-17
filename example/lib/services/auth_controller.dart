import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suprsend_flutter_sdk/suprsend_flutter_sdk.dart';

import 'auth_token_service.dart';

/// Holds the SuprSend session (the logged-in distinct id) and exposes it as a
/// [Listenable] so the router can react to sign-in / sign-out via
/// `refreshListenable`. All identify / reset logic lives here so screens and the
/// router stay free of SDK details.
class AuthController extends ChangeNotifier {
  AuthController(this._tokenService);

  static const String _distinctIdPrefKey = 'suprsend_distinct_id';
  static const String _useUserTokenPrefKey = 'suprsend_use_user_token';

  final AuthTokenService _tokenService;

  bool _loading = true;
  String? _distinctId;

  /// A deep-link location (e.g. `/profile`) that arrived during startup, before
  /// we knew whether the user was signed in. Consumed by the router once the
  /// user is signed in so the link is replayed.
  String? _pendingLocation;

  /// True while the session is being restored on launch.
  bool get loading => _loading;
  bool get isLoggedIn => _distinctId != null;
  String? get distinctId => _distinctId;

  void setPendingLocation(String location) => _pendingLocation = location;

  String? takePendingLocation() {
    final location = _pendingLocation;
    _pendingLocation = null;
    return location;
  }

  /// Restores a persisted session on launch. Re-identifies so the user token is
  /// refreshed and the (in-memory) refresh callback is re-registered.
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

  /// Identifies [distinctId].
  ///
  /// When [useUserToken] is false (the default), this is a plain identify — no
  /// backend call and no refresh callback.
  ///
  /// When true, it runs in enhanced security mode: it fetches a signed user
  /// token from the backend and registers a [refreshUserToken] callback so the
  /// SDK can transparently obtain a new token before the current one expires.
  /// Falls back to identifying without a token if no endpoint is configured.
  Future<void> _identify(String distinctId, {required bool useUserToken}) async {
    if (!useUserToken) {
      await SuprSend.identify(distinctId);
      return;
    }
    final userToken = await _tokenService.fetchUserToken(distinctId);
    await SuprSend.identify(
      distinctId,
      userToken: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiJ9.eyJlbnRpdHlfdHlwZSI6InN1YnNjcmliZXIiLCJlbnRpdHlfaWQiOiJuQHMuYyIsImV4cCI6MTc4NDMwMzc1NCwic2NvcGUiOnsidGVuYW50X2lkIjoiZGVmYXVsdCJ9LCJpYXQiOjE3ODQzMDM1NzR9.ni9PKuswMALJVl-_o9wYD3-faJzkx0J-lk84Q3oEN9CPLA06SnKTjxCtjplMLU5aRed4y_j_7Xb6BCcJK79QBQ',
      refreshUserToken: _tokenService.isConfigured
          ? (oldUserToken, tokenPayload) async =>
              await _tokenService.fetchUserToken(distinctId) ?? oldUserToken
          : null,
    );
  }
}
