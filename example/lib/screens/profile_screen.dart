import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';

/// Profile screen. Reached either by in-app navigation (the profile icon on the
/// home screen) or the `com.suprsend://profile` deep link — the router builds
/// it the same way for both. Shows the signed-in distinct id and a logout
/// action.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.distinctId,
    required this.onLogout,
  });

  final String distinctId;
  final Future<void> Function() onLogout;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loggingOut = false;

  Future<void> _logout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);
    try {
      // On success the session clears and the router redirects to /login.
      await widget.onLogout();
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFFF2F2F7),
        // Deep links can land here with nothing to pop, so fall back to Home.
        leading: IconButton(
          icon: Icon(
            context.canPop() ? Icons.arrow_back : Icons.home_outlined,
          ),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRouter.home),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: theme.colorScheme.primary,
                  child: const Icon(Icons.person,
                      size: 48, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'DISTINCT ID',
                textAlign: TextAlign.center,
                style:
                    theme.textTheme.labelSmall?.copyWith(letterSpacing: 0.5),
              ),
              const SizedBox(height: 6),
              Text(
                widget.distinctId,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: _loggingOut ? null : _logout,
                child: _loggingOut
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
