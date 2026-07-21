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

  const VerifyRegistrationOtpScreen({
    super.key,
    required this.registrationToken,
    required this.email,
  });

  @override
  ConsumerState<VerifyRegistrationOtpScreen> createState() =>
      _VerifyRegistrationOtpScreenState();
}

class _VerifyRegistrationOtpScreenState
    extends ConsumerState<VerifyRegistrationOtpScreen> {
  bool _isLoading = false;
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
                onPressed: () {},
                child: const Text('Resend code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
