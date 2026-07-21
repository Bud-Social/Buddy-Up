import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/auth_repository.dart';
import '../../shared/widgets/otp_input.dart';
import '../../shared/widgets/toast.dart';

class TotpChallengeScreen extends StatefulWidget {
  final String tempToken;
  const TotpChallengeScreen({super.key, required this.tempToken});

  @override
  State<TotpChallengeScreen> createState() => _TotpChallengeScreenState();
}

class _TotpChallengeScreenState extends State<TotpChallengeScreen> {
  bool _isLoading = false;
  late AuthRepository _authRepo;

  @override
  void initState() {
    super.initState();
    _authRepo = AuthRepository(ApiClient().dio);
  }

  Future<void> _verify(String code) async {
    setState(() => _isLoading = true);
    try {
      final response = await _authRepo.totpChallenge({
        'temp_token': widget.tempToken,
        'code': code,
      });
      if (mounted) {
        Navigator.of(context).pop({
          'access': response.access,
          'refresh': response.refresh,
          'user': response.user,
          'profile': response.profile,
        });
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
      appBar: AppBar(title: const Text('Two-Factor Authentication')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              const Icon(Icons.security, size: 64, color: BuddyColors.green),
              const SizedBox(height: 24),
              const Text(
                'Enter the code from your authenticator app.',
                textAlign: TextAlign.center,
                style: TextStyle(color: BuddyColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 32),
              OtpInput(length: 6, enabled: !_isLoading, onCompleted: _verify),
            ],
          ),
        ),
      ),
    );
  }
}
