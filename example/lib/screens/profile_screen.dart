import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';

// Reached via in-app nav or the com.suprsend://profile deep link — the router builds it the same way.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.distinctId,
    required this.tenantId,
    required this.onChangeTenant,
    required this.onLogout,
  });

  final String distinctId;
  final String? tenantId;
  final Future<void> Function(String tenantId) onChangeTenant;
  final Future<void> Function() onLogout;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Prefill with the current tenant; empty when the user hasn't set one.
  late final TextEditingController _tenantController =
      TextEditingController(text: widget.tenantId ?? '');
  bool _changingTenant = false;
  bool _loggingOut = false;

  @override
  void dispose() {
    _tenantController.dispose();
    super.dispose();
  }

  Future<void> _changeTenant() async {
    final tenant = _tenantController.text.trim();
    if (tenant.isEmpty || _changingTenant) return;
    setState(() => _changingTenant = true);
    try {
      await widget.onChangeTenant(tenant);
      _toast('Changed tenant to $tenant');
    } catch (e) {
      _toast('Change tenant failed: $e');
    } finally {
      if (mounted) setState(() => _changingTenant = false);
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
                  child:
                      const Icon(Icons.person, size: 48, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'DISTINCT ID',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 0.5),
              ),
              const SizedBox(height: 6),
              Text(
                widget.distinctId,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Text(
                'TENANT ID',
                style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 0.5),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tenantController,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.go,
                      onSubmitted: (_) => _changeTenant(),
                      decoration: const InputDecoration(
                        hintText: 'e.g. acme',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _changingTenant ? null : _changeTenant,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: _changingTenant
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Change'),
                  ),
                ],
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
