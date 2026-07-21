import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/auth_models.dart';
import '../../data/repositories/auth_repository.dart';
import '../../shared/widgets/button.dart';
import '../../shared/widgets/input.dart';
import '../../shared/widgets/toast.dart';
import 'verify_registration_otp_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _isLoading = false;
  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;
  bool _acceptedGuidelines = false;
  bool _is16Plus = false;
  String _role = 'user';
  late AuthRepository _authRepo;

  @override
  void initState() {
    super.initState();
    _authRepo = AuthRepository(ApiClient().dio);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_acceptedTerms || !_acceptedPrivacy) {
      showToast(context, 'You must accept the terms and privacy policy.', type: ToastType.error);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _authRepo.register(
        RegisterPayload(
          email: _emailController.text.trim(),
          phone: _phoneController.text.isNotEmpty ? _phoneController.text.trim() : null,
          password: _passwordController.text,
          dob: '2000-01-01',
          username: _usernameController.text.trim(),
          displayName: _displayNameController.text.trim(),
          role: _role,
          acceptedTerms: _acceptedTerms,
          acceptedPrivacy: _acceptedPrivacy,
          acceptedGuidelines: _acceptedGuidelines,
          is16Plus: _is16Plus,
        ),
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => VerifyRegistrationOtpScreen(
              registrationToken: response.registrationToken,
              email: response.email,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) showToast(context, 'Registration failed. Try again.', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BuddyInput(
                  controller: _displayNameController,
                  label: 'Display Name',
                  hint: 'Your public name',
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                BuddyInput(
                  controller: _usernameController,
                  label: 'Username',
                  hint: 'Choose a username',
                  prefixIcon: Icons.alternate_email,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length < 3) return 'At least 3 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                BuddyInput(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'your@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (!v.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                BuddyInput(
                  controller: _phoneController,
                  label: 'Phone (optional)',
                  hint: '+1234567890',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                ),
                const SizedBox(height: 16),
                BuddyInput(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: true,
                  prefixIcon: Icons.lock_outlined,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length < 8) return 'At least 8 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                BuddyInput(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  obscureText: true,
                  prefixIcon: Icons.lock_outlined,
                  validator: (v) {
                    if (v != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'I am a...',
                  style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _roleChip('user', 'User'),
                    const SizedBox(width: 8),
                    _roleChip('trainer', 'Trainer'),
                    const SizedBox(width: 8),
                    _roleChip('practitioner', 'Practitioner'),
                  ],
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: _acceptedTerms,
                  onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                  title: const Text('I accept the Terms of Service', style: TextStyle(fontSize: 14)),
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                ),
                CheckboxListTile(
                  value: _acceptedPrivacy,
                  onChanged: (v) => setState(() => _acceptedPrivacy = v ?? false),
                  title: const Text('I accept the Privacy Policy', style: TextStyle(fontSize: 14)),
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                ),
                CheckboxListTile(
                  value: _acceptedGuidelines,
                  onChanged: (v) => setState(() => _acceptedGuidelines = v ?? false),
                  title: const Text('I accept the Community Guidelines', style: TextStyle(fontSize: 14)),
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                ),
                CheckboxListTile(
                  value: _is16Plus,
                  onChanged: (v) => setState(() => _is16Plus = v ?? false),
                  title: const Text('I am 16 or older', style: TextStyle(fontSize: 14)),
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                ),
                const SizedBox(height: 24),
                BuddyButton(
                  label: 'Create Account',
                  onPressed: _handleRegister,
                  isLoading: _isLoading,
                  fullWidth: true,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: BuddyColors.textSecondary, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleChip(String value, String label) {
    final selected = _role == value;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 13, color: selected ? BuddyColors.green : BuddyColors.textSecondary)),
      selected: selected,
      onSelected: (v) => setState(() => _role = value),
      selectedColor: BuddyColors.green.withValues(alpha: 0.2),
      backgroundColor: BuddyColors.surface,
      side: BorderSide(color: selected ? BuddyColors.green : BuddyColors.surfaceRaised),
    );
  }
}
