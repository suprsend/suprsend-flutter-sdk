import 'package:flutter/material.dart';

/// Shown while [AuthController.restore] determines whether there's a persisted
/// session. The router redirects away from here to `/home` or `/login` (or a
/// pending deep link) as soon as the session state is known.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
