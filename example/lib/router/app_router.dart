import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/splash_screen.dart';
import '../services/auth_controller.dart';

// Single source of truth for navigation: in-app nav and OS deep links resolve against the same route table.
class AppRouter {
  AppRouter._();

  // Custom URL scheme registered with the OS (AndroidManifest.xml / Info.plist).
  static const String deepLinkScheme = 'com.suprsend';

  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';

  static GoRouter create(AuthController auth) {
    return GoRouter(
      initialLocation: splash,
      // Re-run redirect whenever the session changes (sign-in / sign-out).
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
            tenantId: auth.tenantId,
            onChangeTenant: auth.changeTenant,
            onLogout: auth.logout,
          ),
        ),
      ],
    );
  }

  // Auth gate: keep unauthenticated users on login, remembering their target for after sign-in.
  static String? _redirect(AuthController auth, GoRouterState state) {
    final String location = state.matchedLocation;

    // Still restoring: park on splash, remembering any deep link to replay after sign-in.
    if (auth.loading) {
      if (location != splash) auth.setPendingLocation(state.uri.toString());
      return location == splash ? null : splash;
    }

    // Not signed in: gate to login. Don't record a pending location, or logout would bounce back here.
    if (!auth.isLoggedIn) {
      return location == login ? null : login;
    }

    // Signed in: send splash/login through to the intended destination.
    if (location == splash || location == login) {
      return auth.takePendingLocation() ?? home;
    }
    return null;
  }

  // Maps an OS deep link URI to a router location (the host becomes the path); null if not our scheme.
  static String? locationForDeepLink(Uri uri) {
    if (uri.scheme != deepLinkScheme || uri.host.isEmpty) return null;
    final String path = (uri.path == '/' ? '' : uri.path);
    final String location = '/${uri.host}$path';
    return uri.hasQuery ? '$location?${uri.query}' : location;
  }
}
