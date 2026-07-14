import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';

/// Captures OS deep links (the `com.suprsend://` custom URL scheme) and feeds
/// them to the router. This is deliberately thin: it only turns a URI into an
/// internal location via [AppRouter.locationForDeepLink] and calls
/// `router.go(...)`. All routing decisions (auth gating, which widget to build)
/// live in [AppRouter], so new screens need no changes here.
///
/// Both delivery paths are handled:
///  * cold start — the app was launched by the link ([AppLinks.getInitialLink]);
///  * warm start — a link arrives while the app is already running
///    ([AppLinks.uriLinkStream]).
class DeepLinkService {
  DeepLinkService(this._router);

  final GoRouter _router;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  Future<void> init() async {
    // Links arriving while the app is running (foreground or resumed).
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
    // go() is frame-independent and idempotent, so repeated links to the same
    // location just re-resolve through the router (no stacked duplicates).
    _router.go(location);
  }
}
