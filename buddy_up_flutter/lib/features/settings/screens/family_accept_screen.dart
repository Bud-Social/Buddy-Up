import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/input.dart';
import '../../../shared/widgets/toast.dart';
import '../providers/settings_providers.dart';

/// Web `FamilyAccept.tsx` — `/settings/family/accept?token=…`.
///
/// A guardian invites a 16–17 year old, who lands here from the email link to
/// set a password and activate the account. The token is the only credential;
/// the backend validates it and the password strength.
class FamilyAcceptScreen extends ConsumerStatefulWidget {
  const FamilyAcceptScreen({super.key});

  @override
  ConsumerState<FamilyAcceptScreen> createState() => _FamilyAcceptScreenState();
}

class _FamilyAcceptScreenState extends ConsumerState<FamilyAcceptScreen> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _token;
  bool _loading = false;
  String? _error;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _token = GoRouterState.of(context).uri.queryParameters['token'];
  }

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final token = _token;
    if (token == null || token.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(settingsGuardianRepoProvider).acceptGuardianInvite({
        'invite_token': token,
        'new_password': _password.text,
      });
      if (mounted) {
        setState(() => _done = true);
        showToast(
          context,
          'Invite accepted — your account is ready.',
          type: ToastType.success,
        );
        context.go('/settings/family');
      }
    } catch (e) {
      final message = e.toString().replaceFirst(RegExp(r'^.*?:'), '').trim();
      if (mounted) {
        setState(
          () => _error = message.isEmpty
              ? 'Invalid or expired invite link.'
              : message,
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authenticated = ref.watch(authProvider).isAuthenticated;

    if (!authenticated) {
      // Web preserves the link through login via ?next=. Do the same so the
      // token survives the round-trip instead of stranding the new teen.
      final next = Uri(
        path: '/settings/family/accept',
        queryParameters: {'token': _token ?? ''},
      ).toString();
      return Scaffold(
        appBar: AppBar(title: const Text('Accept Family Invite')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.usersRound,
                    size: 44,
                    color: BuddyColors.green,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sign in to accept this invite',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You will be brought straight back here after signing in.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  BuddyButton(
                    label: 'Go to login',
                    fullWidth: true,
                    onPressed: () =>
                        context.go('/login?next=${Uri.encodeComponent(next)}'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Accept Family Invite')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: BuddyColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: BuddyColors.border),
                ),
                child: _done
                    ? const Text(
                        'Invite accepted! Taking you to Family settings…',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: BuddyColors.green,
                          fontSize: 14,
                        ),
                      )
                    : Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_token == null || _token!.isEmpty)
                              const Text(
                                'This invite link is missing its token.',
                                style: TextStyle(
                                  color: BuddyColors.red,
                                  fontSize: 13,
                                ),
                              )
                            else ...[
                              Text(
                                'Welcome to BuddyUp Fit! Set a password to activate the account linked to your guardian.',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 18),
                              BuddyInput(
                                label: 'New password',
                                hint: 'At least 8 characters',
                                obscureText: true,
                                controller: _password,
                                validator: (v) => (v ?? '').length < 8
                                    ? 'Password must be at least 8 characters.'
                                    : null,
                              ),
                              BuddyInput(
                                label: 'Confirm password',
                                hint: 'Repeat your password',
                                obscureText: true,
                                controller: _confirm,
                                validator: (v) => v != _password.text
                                    ? 'Passwords do not match.'
                                    : null,
                              ),
                              if (_error != null) ...[
                                Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: BuddyColors.red,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                              const SizedBox(height: 8),
                              BuddyButton(
                                label: _loading
                                    ? 'Accepting…'
                                    : 'Accept Invite',
                                fullWidth: true,
                                isLoading: _loading,
                                onPressed: _loading ? null : _submit,
                              ),
                            ],
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () => context.go('/settings/family'),
                              child: const Text('Back to Family'),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
