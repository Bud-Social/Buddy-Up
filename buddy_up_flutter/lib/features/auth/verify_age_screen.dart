import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_error.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/age_gating.dart';
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
  String _country = '';
  late AuthRepository _authRepo;

  @override
  void initState() {
    super.initState();
    _authRepo = AuthRepository(ApiClient().dio);
  }

  Future<void> _handleVerify() async {
    if (_selectedDate == null) return;
    setState(() => _isLoading = true);
    final age = AgeGating.calculateAge(_selectedDate!);
    final country = _country.trim().isEmpty ? null : _country.trim();
    try {
      await _authRepo.verifyAge({
        // The server reads `date_of_birth`. Sending `dob` meant the view always
        // 400'd, and the catch below then told the user "You must be 16 or
        // older" -- blaming their birthday for a payload key mismatch.
        'date_of_birth': _selectedDate!.toIso8601String().split('T')[0],
        'location_country': ?country,
      });
      if (!mounted) return;
      Navigator.of(context).pop({
        'age': age,
      });
      if (age < 16) {
        showToast(context, 'You must be 16 or older to use Buddy-Up.', type: ToastType.error);
      }
    } catch (e) {
      // Never tell someone their birthday is the problem when the request may
      // simply have failed. A network error and a rejected age are very
      // different messages and only one of them is the user's fault.
      if (mounted) {
        showToast(
          context,
          _isUnderageRejection(e)
              ? 'You must be 16 or older to use Buddy-Up.'
              : 'Could not verify your age just now. Please try again.',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// True only when the server actually rejected the date of birth.
  bool _isUnderageRejection(Object error) {
    final status = apiStatusCode(error);
    if (status != null && status != 400 && status != 403) return false;
    final message = apiErrorMessage(error).toLowerCase();
    return message.contains('16') || message.contains('older') || message.contains('age');
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
                'Please enter your date of birth to continue. If your age is '
                'challenged, you can confirm it with a photo of your ID or '
                'passport in Settings → Verifications after sign-up.',
                textAlign: TextAlign.center,
                style: TextStyle(color: BuddyColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Country (for age thresholds)',
                  hintText: 'e.g. KE',
                  prefixIcon: Icon(Icons.public, color: BuddyColors.green),
                ),
                textCapitalization: TextCapitalization.characters,
                onChanged: (v) => setState(() => _country = v),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              const Text(
                'ID and passport photos are used only to confirm your age. '
                'They are deleted automatically after an admin decision '
                '(usually within 30 days) and only non-identifying metadata '
                'is kept.',
                textAlign: TextAlign.center,
                style: TextStyle(color: BuddyColors.textSecondary, fontSize: 11),
              ),
              const SizedBox(height: 20),
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
