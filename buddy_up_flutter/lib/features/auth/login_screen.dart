import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../core/api/api_client.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/auth/google_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/auth_models.dart';
import '../../data/repositories/auth_repository.dart';
import '../../shared/widgets/button.dart';
import '../../shared/widgets/input.dart';
import '../../shared/widgets/otp_input.dart';
import '../../shared/widgets/toast.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'verify_registration_otp_screen.dart';

enum LoginStep { credentials, otp, totp }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _loginToken = '';
  String _maskedEmail = '';

  LoginStep _step = LoginStep.credentials;
  late AuthRepository _authRepo;

  @override
  void initState() {
    super.initState();
    _authRepo = AuthRepository(ApiClient().dio);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      final response = await _authRepo.login(
        LoginPayload(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
      if (response.requireOtp) {
        setState(() {
          _loginToken = response.loginToken;
          _maskedEmail = response.maskedEmail;
          _step = LoginStep.otp;
          _isLoading = false;
        });
      } else {
        await ref.read(authProvider.notifier).setTokens(response.loginToken, '');
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/feed');
        }
      }
    } catch (e) {
      if (e is DioException && e.response?.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;
        final message = data['message'] as String? ?? '';
        if (message.toLowerCase().contains('verify your email') && data['data'] is Map) {
          final inner = data['data'] as Map<String, dynamic>;
          final token = inner['registration_token'] as String?;
          final email = inner['email'] as String? ?? _emailController.text.trim();
          if (token != null && mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => VerifyRegistrationOtpScreen(
                  registrationToken: token,
                  email: email,
                ),
              ),
            );
            return;
          }
        }
        if (mounted) showToast(context, message.isNotEmpty ? message : 'Login failed.', type: ToastType.error);
      } else {
        if (mounted) showToast(context, 'Login failed. Please try again.', type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleOtp(String otp) async {
    setState(() => _isLoading = true);
    try {
      final response = await _authRepo.verifyLoginOtp(
        LoginOTPSerializer(loginToken: _loginToken, otp: otp),
      );
      await ref.read(authProvider.notifier).setTokens(response.access, response.refresh);
      await ref.read(authProvider.notifier).setUserAndProfile(response.user, response.profile);
      if (response.user.totpEnabled) {
        setState(() {
          _step = LoginStep.totp;
          _isLoading = false;
        });
      } else {
        if (mounted) Navigator.of(context).pushReplacementNamed('/feed');
      }
    } catch (e) {
      if (mounted) showToast(context, 'Invalid OTP. Try again.', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleTotp(String code) async {
    setState(() => _isLoading = true);
    try {
      final response = await _authRepo.totpChallenge({
        'temp_token': _loginToken,
        'code': code,
      });
      await ref.read(authProvider.notifier).setTokens(response.access, response.refresh);
      await ref.read(authProvider.notifier).setUserAndProfile(response.user, response.profile);
      if (mounted) Navigator.of(context).pushReplacementNamed('/feed');
    } catch (e) {
      if (mounted) showToast(context, 'Invalid TOTP code.', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final String? credential = await GoogleAuth.getIdToken();
      if (credential == null) {
        return; // User cancelled the Google flow — no error UI.
      }

      final res = await _authRepo.googleLogin({'credential': credential});
      await ref.read(authProvider.notifier).handleLoginSuccess(res);
    } catch (e) {
      if (GoogleAuth.isCancelled(e)) {
        return; // User cancelled mid-flow.
      }
      if (e is DioException && e.response?.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;
        final message = data['message'] as String? ?? '';
        if (message.toLowerCase().contains('verify your email') && data['data'] is Map) {
          final inner = data['data'] as Map<String, dynamic>;
          final token = inner['registration_token'] as String?;
          final email = inner['email'] as String? ?? '';
          if (token != null && mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => VerifyRegistrationOtpScreen(registrationToken: token, email: email),
              ),
            );
            return;
          }
        }
        if (mounted) showToast(context, message.isNotEmpty ? message : 'Google Sign-In failed.', type: ToastType.error);
      } else {
        if (mounted) showToast(context, 'Google Sign-In failed: $e', type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final res = await _authRepo.appleLogin({
        'identity_token': credential.identityToken,
        'authorization_code': credential.authorizationCode,
        'first_name': credential.givenName,
        'last_name': credential.familyName,
      });
      await ref.read(authProvider.notifier).handleLoginSuccess(res);
    } catch (e) {
      if (e is DioException && e.response?.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;
        final message = data['message'] as String? ?? '';
        if (message.toLowerCase().contains('verify your email') && data['data'] is Map) {
          final inner = data['data'] as Map<String, dynamic>;
          final token = inner['registration_token'] as String?;
          final email = inner['email'] as String? ?? '';
          if (token != null && mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => VerifyRegistrationOtpScreen(registrationToken: token, email: email),
              ),
            );
            return;
          }
        }
        if (mounted) showToast(context, message.isNotEmpty ? message : 'Apple Sign-In failed.', type: ToastType.error);
      } else {
        if (mounted) showToast(context, 'Apple Sign-In failed: $e', type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Buddy-Up',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: BuddyColors.green,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _step == LoginStep.credentials
                      ? 'Sign in to your account'
                      : _step == LoginStep.otp
                          ? 'Enter the code sent to $_maskedEmail'
                          : 'Enter your authenticator code',
                  style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 32),
                if (_step == LoginStep.credentials) _buildCredentialsForm(),
                if (_step == LoginStep.otp) _buildOtpForm(),
                if (_step == LoginStep.totp) _buildTotpForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCredentialsForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          BuddyInput(
            controller: _emailController,
            hint: 'Email address',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                v == null || v.isEmpty ? 'Enter your email' : null,
          ),
          const SizedBox(height: 16),
          BuddyInput(
            controller: _passwordController,
            hint: 'Password',
            obscureText: true,
            prefixIcon: Icons.lock_outlined,
            validator: (v) =>
                v == null || v.isEmpty ? 'Enter your password' : null,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
              ),
              child: const Text('Forgot password?'),
            ),
          ),
          const SizedBox(height: 24),
          BuddyButton(
            label: 'Sign In',
            onPressed: _handleLogin,
            isLoading: _isLoading,
            fullWidth: true,
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: Divider(color: BuddyColors.surfaceRaised)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('OR', style: TextStyle(color: BuddyColors.textSecondary, fontSize: 12)),
              ),
              Expanded(child: Divider(color: BuddyColors.surfaceRaised)),
            ],
          ),
          const SizedBox(height: 16),
          BuddyButton(
            label: 'Continue with Google',
            onPressed: _handleGoogleSignIn,
            isLoading: _isLoading,
            fullWidth: true,
            icon: Icons.g_mobiledata,
          ),
          const SizedBox(height: 8),
          BuddyButton(
            label: 'Continue with Apple',
            onPressed: _handleAppleSignIn,
            isLoading: _isLoading,
            fullWidth: true,
            icon: Icons.apple,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account? ",
                style: TextStyle(color: BuddyColors.textSecondary, fontSize: 14),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOtpForm() {
    return Column(
      children: [
        OtpInput(
          length: 6,
          enabled: !_isLoading,
          onCompleted: _handleOtp,
        ),
        const SizedBox(height: 24),
        BuddyButton(
          label: 'Verify Code',
          onPressed: _isLoading ? null : () {},
          isLoading: _isLoading,
          fullWidth: true,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            _handleLogin();
          },
          child: const Text('Resend code'),
        ),
        TextButton(
          onPressed: () => setState(() => _step = LoginStep.credentials),
          child: const Text('Back to login'),
        ),
      ],
    );
  }

  Widget _buildTotpForm() {
    return Column(
      children: [
        OtpInput(
          length: 6,
          enabled: !_isLoading,
          onCompleted: _handleTotp,
        ),
        const SizedBox(height: 24),
        BuddyButton(
          label: 'Verify',
          onPressed: _isLoading ? null : () {},
          isLoading: _isLoading,
          fullWidth: true,
        ),
      ],
    );
  }
}
