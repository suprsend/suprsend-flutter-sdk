import 'package:flutter/material.dart';

/// Shown while the session is being restored; the router then redirects to
/// `/home`, `/login`, or a pending deep link.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
