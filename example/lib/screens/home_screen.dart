import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:suprsend_flutter_sdk/suprsend_flutter_sdk.dart';

import '../router/app_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.distinctId,
  });

  final String distinctId;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _sampleEmail = 'user@example.com';

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ));
  }

  Future<void> _run(String label, Future<SSResponse> Function() action) async {
    try {
      final r = await action();
      _toast(r.isSuccess ? '$label ok' : '$label failed');
    } catch (e) {
      _toast('$label failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome', style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 4),
                        Text(
                          widget.distinctId,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Opens the profile screen (same route as com.suprsend://profile).
                  Tooltip(
                    message: 'Profile',
                    child: InkWell(
                      onTap: () => context.push(AppRouter.profile),
                      customBorder: const CircleBorder(),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: theme.colorScheme.primary,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _action('Add email', () => SuprSend.user.addEmail(_sampleEmail)),
              _action('Remove email',
                  () => SuprSend.user.removeEmail(_sampleEmail)),
              _action(
                'Track event',
                () => SuprSend.track(
                  'home_button_clicked',
                  {'source': 'home_screen'},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _action(String label, Future<SSResponse> Function() action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FilledButton(
        onPressed: () => _run(label, action),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.black,
          minimumSize: const Size.fromHeight(52),
        ),
        child: Text(label),
      ),
    );
  }
}
