import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/auth_models.dart';
import '../../data/repositories/auth_repository.dart';
import '../../shared/widgets/button.dart';
import '../../shared/widgets/input.dart';
import '../../shared/widgets/toast.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;
  const ResetPasswordScreen({super.key, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _done = false;
  late AuthRepository _authRepo;

  @override
  void initState() {
    super.initState();
    _authRepo = AuthRepository(ApiClient().dio);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      await _authRepo.resetPassword(
        PasswordResetConfirm(
          token: widget.token,
          newPassword: _passwordController.text,
        ),
      );
      setState(() => _done = true);
    } catch (e) {
      if (mounted) showToast(context, 'Reset failed. The link may have expired.', type: ToastType.error);
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
          child: _done ? _buildDone() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 32),
          const Icon(Icons.lock_reset, size: 64, color: BuddyColors.green),
          const SizedBox(height: 24),
          BuddyInput(
            controller: _passwordController,
            label: 'New Password',
            obscureText: true,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (v.length < 8) return 'At least 8 characters';
              return null;
            },
          ),
          const SizedBox(height: 16),
          BuddyInput(
            controller: _confirmController,
            label: 'Confirm New Password',
            obscureText: true,
            validator: (v) {
              if (v != _passwordController.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 24),
          BuddyButton(
            label: 'Reset Password',
            onPressed: _handleReset,
            isLoading: _isLoading,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDone() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, size: 64, color: BuddyColors.green),
        const SizedBox(height: 24),
        const Text(
          'Password reset successful!',
          style: TextStyle(color: BuddyColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        BuddyButton(
          label: 'Sign In',
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
          ),
          fullWidth: true,
        ),
      ],
    );
  }
}
