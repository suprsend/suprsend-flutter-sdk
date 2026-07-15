import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/splash_screen.dart';
import '../services/auth_controller.dart';

/// The single source of truth for navigation. In-app navigation and OS deep
/// links resolve against the same route table, so adding a screen is one route.
class AppRouter {
  AppRouter._();

  /// Custom URL scheme registered with the OS: `com.suprsend://<host>/<path>`.
  static const String deepLinkScheme = 'com.suprsend';

  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';

  static GoRouter create(AuthController auth) {
    return GoRouter(
      initialLocation: splash,
      // Re-run redirect whenever the session changes.
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

  /// Auth gate: keeps unauthenticated users on [login] and remembers where they
  /// were headed so they land there after signing in.
  static String? _redirect(AuthController auth, GoRouterState state) {
    final String location = state.matchedLocation;

    // Session still restoring: park on splash, remembering any deep link.
    if (auth.loading) {
      if (location != splash) auth.setPendingLocation(state.uri.toString());
      return location == splash ? null : splash;
    }

    // Not signed in: gate everything behind login (no pending location recorded).
    if (!auth.isLoggedIn) {
      return location == login ? null : login;
    }

    // Signed in: send splash/login through to the intended destination.
    if (location == splash || location == login) {
      return auth.takePendingLocation() ?? home;
    }
    return null;
  }

  /// Maps an OS deep link URI to an internal router location, e.g.
  /// `com.suprsend://profile` -> `/profile`. Returns `null` for other schemes.
  static String? locationForDeepLink(Uri uri) {
    if (uri.scheme != deepLinkScheme || uri.host.isEmpty) return null;
    final String path = (uri.path == '/' ? '' : uri.path);
    final String location = '/${uri.host}$path';
    return uri.hasQuery ? '$location?${uri.query}' : location;
  }
}
