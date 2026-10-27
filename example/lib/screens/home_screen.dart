import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
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
  // Must pass libphonenumber validation natively (555 area codes are rejected).
  static const String _sampleMobile = '+918989898989';
  // Dummy value for testing the bridge; real tokens are registered natively.
  static const String _samplePushToken = 'dummy_push_token';

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;
    // Android 13+ shows the POST_NOTIFICATIONS dialog; older versions grant by default.
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
      _toast(r.isSuccess ? '$label ok' : '$label failed: ${r.errorMessage}');
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
                  // Opens profile — same route com.suprsend://profile resolves to.
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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _section('CHANNELS'),
                      _action('Add email',
                          () => SuprSend.user.addEmail(_sampleEmail)),
                      _action('Remove email',
                          () => SuprSend.user.removeEmail(_sampleEmail)),
                      _action(
                          'Add SMS', () => SuprSend.user.addSMS(_sampleMobile)),
                      _action('Remove SMS',
                          () => SuprSend.user.removeSMS(_sampleMobile)),
                      _action('Add WhatsApp',
                          () => SuprSend.user.addWhatsapp(_sampleMobile)),
                      _action('Remove WhatsApp',
                          () => SuprSend.user.removeWhatsapp(_sampleMobile)),
                      _action('Add push',
                          () => SuprSend.user.addPush(_samplePushToken)),
                      _action('Remove push',
                          () => SuprSend.user.removePush(_samplePushToken)),
                      _section('PROPERTIES (MAP)'),
                      _action(
                        'Set',
                        () => SuprSend.user
                            .set({'name': 'Test User', 'plan': 'pro'}),
                      ),
                      _action(
                        'Set once',
                        () => SuprSend.user.setOnce(
                            {'first_seen': DateTime.now().toIso8601String()}),
                      ),
                      _action('Increment',
                          () => SuprSend.user.increment({'login_count': 1})),
                      _action('Append',
                          () => SuprSend.user.append({'tags': 'flutter'})),
                      _action('Remove',
                          () => SuprSend.user.remove({'tags': 'flutter'})),
                      _action('Unset', () => SuprSend.user.unset(['plan'])),
                      _section('PROPERTIES (SINGLE KEY)'),
                      _action('Set (string)',
                          () => SuprSend.user.set('city', 'Bengaluru')),
                      _action('Set (bool)',
                          () => SuprSend.user.set('is_beta', true)),
                      _action(
                        'Set (map value)',
                        () => SuprSend.user
                            .set('address', {'zip': '560001', 'country': 'IN'}),
                      ),
                      _action(
                        'Set once (string)',
                        () => SuprSend.user
                            .setOnce('referrer', 'flutter_example'),
                      ),
                      _action('Increment (int)',
                          () => SuprSend.user.increment('app_opens', 1)),
                      _action('Increment (double)',
                          () => SuprSend.user.increment('wallet_balance', 2.5)),
                      _action('Decrement (int)',
                          () => SuprSend.user.increment('app_opens', -1)),
                      _action('Append (string)',
                          () => SuprSend.user.append('interests', 'music')),
                      _action('Append (number)',
                          () => SuprSend.user.append('lucky_numbers', 7)),
                      _action('Remove (string)',
                          () => SuprSend.user.remove('interests', 'music')),
                      _action('Remove (number)',
                          () => SuprSend.user.remove('lucky_numbers', 7)),
                      _action('Unset (single key)',
                          () => SuprSend.user.unset('city')),
                      _section('PREFERENCES'),
                      _action('Set preferred language',
                          () => SuprSend.user.setPreferredLanguage('en')),
                      _action('Set timezone',
                          () => SuprSend.user.setTimezone('Asia/Kolkata')),
                      _section('EVENTS'),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(letterSpacing: 0.5),
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
