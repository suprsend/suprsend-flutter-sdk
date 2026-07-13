import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/splash_screen.dart';
import '../services/auth_controller.dart';

/// The single source of truth for navigation. Every screen is declared here
/// once; both in-app navigation (`context.go` / `context.push`) and OS deep
/// links resolve against the same table, so adding a screen is a one-route
/// change with no deep-link plumbing to touch.
///
/// To add a screen:
///  1. add a `GoRoute` below (e.g. `path: '/orders/:id'`);
///  2. that's it — `com.suprsend://orders/123` reaches it automatically via
///     [locationForDeepLink].
class AppRouter {
  AppRouter._();

  /// The custom URL scheme registered with the OS (see AndroidManifest.xml /
  /// Info.plist). Deep links look like `com.suprsend://<host>/<path>`.
  static const String deepLinkScheme = 'com.suprsend';

  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';

  static GoRouter create(AuthController auth) {
    return GoRouter(
      initialLocation: splash,
      // Re-run [redirect] whenever the session changes (sign-in / sign-out).
      refreshListenable: auth,
      redirect: (context, state) => _redirect(auth, state),
      routes: <RouteBase>[
        GoRoute(
          path: splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: login,
          builder: (context, state) => LoginScreen(onSubmit: auth.login),
        ),
        GoRoute(
          path: home,
          builder: (context, state) =>
              HomeScreen(distinctId: auth.distinctId ?? ''),
        ),
        GoRoute(
          path: profile,
          builder: (context, state) => ProfileScreen(
            distinctId: auth.distinctId ?? '',
            onLogout: auth.logout,
          ),
        ),
      ],
    );
  }

  /// Auth gate. Keeps unauthenticated users on [login] and remembers where they
  /// were trying to go so they land there after signing in.
  static String? _redirect(AuthController auth, GoRouterState state) {
    final String location = state.matchedLocation;

    // Session still restoring: park on the splash and remember any deep link
    // that arrived before we knew whether the user was signed in (e.g. a
    // notification tap that launched the app). It's replayed after sign-in.
    if (auth.loading) {
      if (location != splash) auth.setPendingLocation(state.uri.toString());
      return location == splash ? null : splash;
    }

    // Not signed in: gate everything behind the login screen. We deliberately
    // do NOT record a pending location here — otherwise logging out from a
    // screen would send the user back to it after signing in again.
    if (!auth.isLoggedIn) {
      return location == login ? null : login;
    }

    // Signed in: send splash/login through to the intended destination.
    if (location == splash || location == login) {
      return auth.takePendingLocation() ?? home;
    }
    return null;
  }

  /// Maps an OS deep link URI to an internal router location.
  ///
  /// The screen lives in the URI's **host** for a custom scheme, so
  /// `com.suprsend://profile` becomes `/profile` and
  /// `com.suprsend://orders/42?tab=x` becomes `/orders/42?tab=x`. Returns
  /// `null` for a URI that isn't our scheme.
  static String? locationForDeepLink(Uri uri) {
    if (uri.scheme != deepLinkScheme || uri.host.isEmpty) return null;
    final String path = (uri.path == '/' ? '' : uri.path);
    final String location = '/${uri.host}$path';
    return uri.hasQuery ? '$location?${uri.query}' : location;
  }
}
