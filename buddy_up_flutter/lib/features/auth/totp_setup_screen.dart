import 'package:flutter/material.dart';
import 'dart:convert';
import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/auth_repository.dart';
import '../../shared/widgets/button.dart';
import '../../shared/widgets/otp_input.dart';
import '../../shared/widgets/toast.dart';

class TotpSetupScreen extends StatefulWidget {
  const TotpSetupScreen({super.key});

  @override
  State<TotpSetupScreen> createState() => _TotpSetupScreenState();
}

class _TotpSetupScreenState extends State<TotpSetupScreen> {
  bool _isLoading = false;
  bool _setupDone = false;
  String _secret = '';
  String _qrCode = '';
  late AuthRepository _authRepo;

  @override
  void initState() {
    super.initState();
    _authRepo = AuthRepository(ApiClient().dio);
    _loadSetup();
  }

  Future<void> _loadSetup() async {
    setState(() => _isLoading = true);
    try {
      final response = await _authRepo.totpSetup();
      setState(() {
        _secret = response.secret;
        _qrCode = response.qrCode;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) showToast(context, 'Failed to set up 2FA.', type: ToastType.error);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyTotp(String code) async {
    setState(() => _isLoading = true);
    try {
      await _authRepo.totpVerify({'code': code, 'secret': _secret});
      setState(() => _setupDone = true);
      if (mounted) showToast(context, 'Two-factor authentication enabled!', type: ToastType.success);
    } catch (e) {
      if (mounted) showToast(context, 'Invalid code. Try again.', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Up 2FA')),
      body: SafeArea(
        child: _isLoading && _secret.isEmpty
            ? const Center(child: CircularProgressIndicator(color: BuddyColors.green))
            : _setupDone
                ? _buildDone()
                : _buildSetup(),
      ),
    );
  }

  Widget _buildSetup() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Icon(Icons.security, size: 64, color: BuddyColors.green),
          const SizedBox(height: 16),
          const Text(
            'Scan this QR code with your authenticator app\n(Google Authenticator, Authy, etc.)',
            textAlign: TextAlign.center,
            style: TextStyle(color: BuddyColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          if (_qrCode.isNotEmpty)
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Image.memory(
                base64Decode(_qrCode.split(',').last),
                fit: BoxFit.contain,
              ),
            ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BuddyColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'Or enter this code manually:',
                  style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  _secret,
                  style: const TextStyle(
                    color: BuddyColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Enter the 6-digit code from your app to verify:',
            style: TextStyle(color: BuddyColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          OtpInput(length: 6, enabled: !_isLoading, onCompleted: _verifyTotp),
        ],
      ),
    );
  }

  Widget _buildDone() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 64, color: BuddyColors.green),
            const SizedBox(height: 24),
            const Text(
              'Two-factor authentication is now enabled.',
              textAlign: TextAlign.center,
              style: TextStyle(color: BuddyColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'You\'ll need a code from your authenticator app each time you sign in.',
              textAlign: TextAlign.center,
              style: TextStyle(color: BuddyColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 32),
            BuddyButton(
              label: 'Done',
              onPressed: () => Navigator.of(context).pop(),
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
