import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/auth_models.dart';
import '../../data/repositories/auth_repository.dart';
import '../../shared/widgets/otp_input.dart';
import '../../shared/widgets/toast.dart';

class VerifyRegistrationOtpScreen extends ConsumerStatefulWidget {
  final String registrationToken;
  final String email;

  /// Set when the user was redirected here from a login attempt — the screen
  /// then explains that the account was never verified.
  final bool unverifiedNotice;

  const VerifyRegistrationOtpScreen({
    super.key,
    required this.registrationToken,
    required this.email,
    this.unverifiedNotice = false,
  });

  @override
  ConsumerState<VerifyRegistrationOtpScreen> createState() =>
      _VerifyRegistrationOtpScreenState();
}

class _VerifyRegistrationOtpScreenState
    extends ConsumerState<VerifyRegistrationOtpScreen> {
  bool _isLoading = false;
  bool _resending = false;
  late AuthRepository _authRepo;

  @override
  void initState() {
    super.initState();
    _authRepo = AuthRepository(ApiClient().dio);
  }

  Future<void> _handleOtp(String otp) async {
    setState(() => _isLoading = true);
    try {
      final response = await _authRepo.verifyRegistrationOtp(
        RegistrationOTPSerializer(
          registrationToken: widget.registrationToken,
          otp: otp,
        ),
      );
      await ref.read(authProvider.notifier).setTokens(response.access, response.refresh);
      await ref.read(authProvider.notifier).setUserAndProfile(response.user, response.profile);
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/onboarding', (_) => false);
      }
    } catch (e) {
      if (mounted) showToast(context, 'Invalid code. Try again.', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResend() async {
    setState(() => _resending = true);
    try {
      await _authRepo.resendRegistrationOtp({
        'registration_token': widget.registrationToken,
        'channel': 'email',
      });
      if (mounted) showToast(context, 'New OTP sent to your email.', type: ToastType.success);
    } catch (e) {
      if (mounted) showToast(context, 'Failed to resend OTP. Please try again.', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
          children: [
            const SizedBox(height: 32),
            const Icon(Icons.mark_email_unread, size: 64, color: BuddyColors.green),
            const SizedBox(height: 24),
            if (widget.unverifiedNotice) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BuddyColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: BuddyColors.green.withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'Your account isn\'t verified yet — enter the OTP we emailed you, or tap Resend for a new one.',
                  style: TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Enter the verification code',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: BuddyColors.textPrimary,
                  ),
            ),
              const SizedBox(height: 8),
              Text(
                'We sent a 6-digit code to ${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 32),
              OtpInput(length: 6, enabled: !_isLoading, onCompleted: _handleOtp),
              const SizedBox(height: 24),
              TextButton(
                onPressed: _resending ? null : _handleResend,
                child: Text(_resending ? 'Sending...' : 'Resend code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
