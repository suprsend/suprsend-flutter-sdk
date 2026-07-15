import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';

/// Captures OS deep links (the `com.suprsend://` scheme) and feeds them to the
/// router. All routing decisions live in [AppRouter].
class DeepLinkService {
  DeepLinkService(this._router);

  final GoRouter _router;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  Future<void> init() async {
    // Links arriving while the app is running.
    _subscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (Object err) =>
          debugPrint('[SuprSend example] deep link stream error: $err'),
    );

    // Link that launched the app from a terminated state.
    final Uri? initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) _handleUri(initialUri);
  }

  void dispose() {
    _subscription?.cancel();
  }

  void _handleUri(Uri uri) {
    final String? location = AppRouter.locationForDeepLink(uri);
    debugPrint('[SuprSend example] deep link $uri -> ${location ?? 'ignored'}');
    if (location == null) return;
    _router.go(location);
  }
}
