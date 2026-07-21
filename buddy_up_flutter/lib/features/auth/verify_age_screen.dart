import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/auth_repository.dart';
import '../../shared/widgets/button.dart';
import '../../shared/widgets/toast.dart';

class VerifyAgeScreen extends StatefulWidget {
  const VerifyAgeScreen({super.key});

  @override
  State<VerifyAgeScreen> createState() => _VerifyAgeScreenState();
}

class _VerifyAgeScreenState extends State<VerifyAgeScreen> {
  DateTime? _selectedDate;
  bool _isLoading = false;
  late AuthRepository _authRepo;

  @override
  void initState() {
    super.initState();
    _authRepo = AuthRepository(ApiClient().dio);
  }

  Future<void> _handleVerify() async {
    if (_selectedDate == null) return;
    setState(() => _isLoading = true);
    try {
      await _authRepo.verifyAge({'dob': _selectedDate!.toIso8601String().split('T')[0]});
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) showToast(context, 'You must be 16 or older to use Buddy-Up.', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Your Age')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              const Icon(Icons.calendar_today, size: 64, color: BuddyColors.green),
              const SizedBox(height: 24),
              const Text(
                'Please enter your date of birth to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(color: BuddyColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BuddyColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1940),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) setState(() => _selectedDate = date);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate != null
                            ? '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}'
                            : 'Tap to select date of birth',
                        style: TextStyle(
                          color: _selectedDate != null ? BuddyColors.textPrimary : BuddyColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: BuddyColors.green, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              BuddyButton(
                label: 'Verify Age',
                onPressed: _selectedDate != null ? _handleVerify : null,
                isLoading: _isLoading,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
