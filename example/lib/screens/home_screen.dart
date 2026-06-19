import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:suprsend_flutter_sdk/suprsend_flutter_sdk.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.distinctId,
    required this.onLogout,
  });

  final String distinctId;
  final Future<void> Function() onLogout;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _sampleEmail = 'user@example.com';
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;
    // On Android 13+ this shows the POST_NOTIFICATIONS system dialog.
    // On older versions notifications are granted by default, so this is a no-op.
    if (status.isDenied) {
      await Permission.notification.request();
    }
  }

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

  Future<void> _logout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);
    try {
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
