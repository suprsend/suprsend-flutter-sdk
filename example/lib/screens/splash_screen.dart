import 'package:flutter/material.dart';

// Shown while AuthController.restore checks for a persisted session; the router redirects away once known.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
