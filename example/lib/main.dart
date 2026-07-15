import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:suprsend_flutter_sdk/suprsend_flutter_sdk.dart';

import 'router/app_router.dart';
import 'services/auth_controller.dart';
import 'services/auth_token_service.dart';
import 'services/deep_link_service.dart';

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

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  late final AuthController _auth =
      AuthController(AuthTokenService(dotenv.env['SUPRSEND_AUTH_TOKEN_URL'] ?? ''));
  late final GoRouter _router = AppRouter.create(_auth);
  late final DeepLinkService _deepLinkService = DeepLinkService(_router);

  @override
  void initState() {
    super.initState();
    // Restore any persisted session; the router shows a splash until it resolves.
    _auth.restore();
    // Listen for com.suprsend:// deep links (cold start + while running).
    _deepLinkService.init();
  }

  @override
  void dispose() {
    _deepLinkService.dispose();
    _router.dispose();
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SuprSend Example',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2563EB),
      ),
      routerConfig: _router,
    );
  }
}
