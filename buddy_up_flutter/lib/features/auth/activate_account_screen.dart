import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../shared/widgets/button.dart';

/// Web parity for the `/activate` deep link: the registration/login activation
/// email carries `?token=<activation_token>`. This screen exchanges it for the
/// "log in again with password + OTP" session the backend mints.
class ActivateAccountScreen extends StatefulWidget {
  const ActivateAccountScreen({super.key});

  @override
  State<ActivateAccountScreen> createState() => _ActivateAccountScreenState();
}

class _ActivateAccountScreenState extends State<ActivateAccountScreen> {
  final AuthRepository _authRepo = AuthRepository(ApiClient().dio);
  final TextEditingController _tokenController = TextEditingController();

  bool _loading = false;
  bool _verified = false;
  String? _error;
  String _message = '';

  @override
  void initState() {
    super.initState();
    final token = GoRouterState.of(context).uri.queryParameters['token'];
    if (token != null && token.isNotEmpty) {
      _tokenController.text = token;
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _activate() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _authRepo.activateAccount({'activation_token': token});
      final data = (res['data'] as Map?)?.cast<String, dynamic>() ?? res;
      if (res['success'] == true) {
        setState(() {
          _verified = true;
          _message = (data['message'] as String?) ?? 'Email verified!';
        });
      } else {
        setState(() {
          _verified = false;
          _error =
              (res['message'] as String?) ??
              'Activation failed. Please try again.';
        });
      }
    } on DioException catch (e) {
      final body = e.response?.data;
      String message = 'Activation failed. Please try again.';
      if (body is Map) {
        final inner = body['data'];
        if (inner is Map && inner['message'] is String) {
          message = inner['message'] as String;
        } else if (body['message'] is String) {
          message = body['message'] as String;
        }
      }
      if (mounted) {
        setState(() {
          _error = message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Activation failed. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _goToLogin() {
    // After a successful activation the backend issues a login token (password +
    // OTP). The user simply logs in again from the normal login screen.
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Activate your account'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_loading)
                    Column(
                      children: [
                        CircularProgressIndicator(color: BuddyColors.green),
                        SizedBox(height: 18),
                        Text(
                          'Activating your account…',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  else if (_error != null)
                    _ActivationState(
                      icon: LucideIcons.alertCircle,
                      title: 'Activation failed',
                      body: _error!,
                      actionLabel: 'Back to login',
                      onAction: _goToLogin,
                    )
                  else if (_verified)
                    _ActivationState(
                      icon: LucideIcons.checkCircle2,
                      title: 'Email Verified!',
                      body: _message,
                      actionLabel: 'Continue to Login',
                      onAction: _goToLogin,
                    )
                  else
                    _ActivationState(
                      icon: LucideIcons.keyRound,
                      title: 'Activate your account',
                      body:
                          'Paste the activation token from your email link to verify your email and continue.',
                      actionLabel: _loading ? null : 'Verify & activate',
                      onAction: _loading ? null : () => _activate(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivationState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _ActivationState({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(icon, size: 64, color: BuddyColors.green),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          body,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
            height: 1.55,
          ),
        ),
        if (actionLabel != null) ...[
          const SizedBox(height: 26),
          BuddyButton(
            label: actionLabel!,
            fullWidth: true,
            onPressed: onAction,
          ),
        ],
      ],
    );
  }
}
