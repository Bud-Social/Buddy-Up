import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/auth_models.dart';
import '../../data/repositories/auth_repository.dart';
import '../../shared/widgets/button.dart';
import '../../shared/widgets/input.dart';
import '../../shared/widgets/toast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;
  late AuthRepository _authRepo;

  @override
  void initState() {
    super.initState();
    _authRepo = AuthRepository(ApiClient().dio);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await _authRepo.forgotPassword(PasswordResetRequest(email: email));
      setState(() => _sent = true);
    } catch (e) {
      if (mounted) showToast(context, 'Failed to send reset email.', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Icon(
                _sent ? Icons.check_circle : Icons.lock_reset,
                size: 64,
                color: _sent ? BuddyColors.green : BuddyColors.textSecondary,
              ),
              const SizedBox(height: 24),
              if (!_sent) ...[
                const Text(
                  'Enter your email address and we\'ll send you a reset link.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: BuddyColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 24),
                BuddyInput(
                  controller: _emailController,
                  hint: 'Email address',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 24),
                BuddyButton(
                  label: 'Send Reset Link',
                  onPressed: _handleSubmit,
                  isLoading: _isLoading,
                  fullWidth: true,
                ),
              ] else ...[
                const Text(
                  'Check your email for the reset link. If you don\'t see it, check your spam folder.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: BuddyColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 24),
                BuddyButton(
                  label: 'Back to Sign In',
                  onPressed: () => Navigator.of(context).pop(),
                  variant: BuddyButtonVariant.outline,
                  fullWidth: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
