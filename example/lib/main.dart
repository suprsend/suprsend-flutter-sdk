import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suprsend_flutter_sdk/suprsend_flutter_sdk.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_token_service.dart';

const String _distinctIdPrefKey = 'suprsend_distinct_id';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  SuprSend(
    dotenv.env['SUPRSEND_PUBLIC_KEY'] ?? '',
    appName: 'SuprSend Example',
    appVersion: '3.0.0',
  );
  await SuprSend.enableLogging();

  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SuprSend Example',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2563EB),
      ),
      home: const RootView(),
    );
  }
}

class RootView extends StatefulWidget {
  const RootView({super.key});

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  bool _loading = true;
  String? _distinctId;

  final AuthTokenService _tokenService =
      AuthTokenService(dotenv.env['SUPRSEND_AUTH_TOKEN_URL'] ?? '');

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  /// Identifies [distinctId], fetching a signed user token from the backend and
  /// registering a [refreshUserToken] callback so the SDK can transparently
  /// obtain a new token before the current one expires. If no token endpoint is
  /// configured we fall back to identifying without a token.
  Future<void> _identify(String distinctId) async {
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

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    String? distinctId = prefs.getString(_distinctIdPrefKey);
    if (distinctId != null) {
      // Re-identify on launch so the token is refreshed and the
      // refreshUserToken callback (in-memory only) is re-registered.
      await _identify(distinctId);
    } else if (await SuprSend.isIdentified()) {
      distinctId = await SuprSend.getDistinctId();
    }
    if (!mounted) return;
    setState(() {
      _distinctId = distinctId;
      _loading = false;
    });
  }

  Future<void> _handleLogin(String distinctId) async {
    await _identify(distinctId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_distinctIdPrefKey, distinctId);
    if (!mounted) return;
    setState(() => _distinctId = distinctId);
  }

  Future<void> _handleLogout() async {
    await SuprSend.reset();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_distinctIdPrefKey);
    if (!mounted) return;
    setState(() => _distinctId = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final distinctId = _distinctId;
    if (distinctId == null) {
      return LoginScreen(onSubmit: _handleLogin);
    }
    return HomeScreen(distinctId: distinctId, onLogout: _handleLogout);
  }
}
