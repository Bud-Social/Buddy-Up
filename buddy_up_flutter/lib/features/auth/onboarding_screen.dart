import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/api_client.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/onboarding.dart';
import '../../data/models/profile.dart';
import '../../data/repositories/profile_repository.dart';

import '../../shared/widgets/button.dart';
import '../../shared/widgets/toast.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  bool _isLoading = false;

  // Consent step. Must match the backend's CURRENT_TERMS_VERSION and the
  // web onboarding's TERMS_VERSION — the backend records whatever version
  // the client accepted on the profile for audit.
  static const _termsVersion = '2026-08-v1';
  bool _acceptTerms = false;
  bool _acceptPrivacy = false;
  bool _acceptGuidelines = false;
  bool _marketingConsent = false;

  final List<String> _selectedGoals = [];
  String _activityLevel = '';
  final List<String> _selectedWorkouts = [];
  String _dietaryPreference = '';
  String _preferredTime = '';
  final String _discoverySource = '';

  late ProfileRepository _profileRepo;

  // Display labels the user taps, with parallel snake_case values the
  // backend expects. Chips render labels; _submit() maps to values.
  static const _goalLabels = ['Lose Weight', 'Build Muscle', 'Improve Endurance', 'General Fitness', 'Flexibility', 'Sports Performance'];
  static const _goalValues = ['lose_weight', 'muscle_gain', 'improve_endurance', 'general_fitness', 'flexibility', 'sports_performance'];
  static const _levelLabels = ['Sedentary', 'Lightly Active', 'Moderately Active', 'Very Active', 'Extremely Active'];
  static const _levelValues = ['sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extremely_active'];
  final _workoutLabels = const ['Running', 'Weightlifting', 'Yoga', 'Swimming', 'Cycling', 'HIIT', 'Boxing', 'Pilates', 'Dance', 'Calisthenics'];
  final _workoutValues = const ['running', 'weights', 'yoga', 'swimming', 'cycling', 'hiit', 'martial_arts', 'pilates', 'other', 'other'];
  final _dietLabels = const ['None', 'Vegetarian', 'Vegan', 'Keto', 'Paleo', 'Mediterranean', 'Halal'];
  final _dietValues = const ['none', 'vegetarian', 'vegan', 'keto', 'paleo', 'other', 'halal'];
  static const _timeLabels = ['Early Morning', 'Morning', 'Afternoon', 'Evening', 'Late Night'];
  static const _timeValues = ['early_morning', 'morning', 'afternoon', 'evening', 'late_night'];

  @override
  void initState() {
    super.initState();
    _profileRepo = ProfileRepository(ApiClient().dio);
  }

  String _toValue(String label, List<String> labels, List<String> values) {
    final i = labels.indexOf(label);
    return i >= 0 ? values[i] : label;
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final data = await _profileRepo.saveOnboarding(
        OnboardingPayload(
          primaryGoal: _selectedGoals
              .map((l) => _toValue(l, _goalLabels, _goalValues))
              .toList(),
          activityLevel: _toValue(_activityLevel, _levelLabels, _levelValues),
          preferredWorkouts: _selectedWorkouts
              .map((l) => _toValue(l, _workoutLabels, _workoutValues))
              .toList(),
          dietaryPreference: _toValue(_dietaryPreference, _dietLabels, _dietValues),
          preferredTime: _toValue(_preferredTime, _timeLabels, _timeValues),
          discoverySource: _discoverySource.isNotEmpty ? _discoverySource : null,
          termsVersion: _termsVersion,
          marketingConsent: _marketingConsent,
        ),
      );
      // Sync the completed onboarding flag locally — otherwise the router's
      // onboarding gate would bounce the user straight back here.
      final profileJson = data['profile'];
      if (profileJson is Map<String, dynamic>) {
        await ref.read(authProvider.notifier).updateProfile(Profile.fromJson(profileJson));
      }
      if (mounted) context.go('/feed');
    } catch (e) {
      if (mounted) showToast(context, 'Something went wrong. Please try again.', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step ${_step + 1} of 6'),
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _step--),
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: (_step + 1) / 6,
                backgroundColor: BuddyColors.surfaceRaised,
                color: BuddyColors.green,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: 24),
              Expanded(child: _buildStep()),
              const SizedBox(height: 24),
              BuddyButton(
                label: _step == 5 ? 'Get Started' : 'Next',
                onPressed: _step == 5
                    ? _submit
                    : _step == 0 && !_consentStepValid
                        ? null
                        : () => setState(() => _step++),
                isLoading: _isLoading,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _consentStepValid => _acceptTerms && _acceptPrivacy && _acceptGuidelines;

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildConsentStep();
      case 1:
        return _buildMultiSelect('What are your fitness goals?', _goalLabels, _selectedGoals);
      case 2:
        return _buildSingleSelect('What\'s your activity level?', _levelLabels, _activityLevel, (v) => _activityLevel = v);
      case 3:
        return _buildMultiSelect('Preferred workouts', _workoutLabels, _selectedWorkouts);
      case 4:
        return _buildSingleSelect('Dietary preference', _dietLabels, _dietaryPreference, (v) => _dietaryPreference = v);
      case 5:
        return _buildSingleSelect('Preferred workout time', _timeLabels, _preferredTime, (v) => _preferredTime = v);
      default:
        return const SizedBox();
    }
  }

  Widget _buildConsentStep() {
    return ListView(
      children: [
        const Text(
          'Stay safe out there',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: BuddyColors.textPrimary),
        ),
        const SizedBox(height: 8),
        const Text(
          'Please review and accept our policies to set up your account.',
          style: TextStyle(color: BuddyColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 16),
        _consentRow(
          checked: _acceptTerms,
          onChanged: (v) => setState(() => _acceptTerms = v),
          label: 'I accept the Terms of Service',
          route: '/terms',
        ),
        _consentRow(
          checked: _acceptPrivacy,
          onChanged: (v) => setState(() => _acceptPrivacy = v),
          label: 'I accept the Privacy Policy',
          route: '/privacy',
        ),
        _consentRow(
          checked: _acceptGuidelines,
          onChanged: (v) => setState(() => _acceptGuidelines = v),
          label: 'I accept the Community Guidelines',
          route: '/community-guidelines',
        ),
        _consentRow(
          checked: _marketingConsent,
          onChanged: (v) => setState(() => _marketingConsent = v),
          label: 'Send me product updates and fitness tips (optional)',
        ),
      ],
    );
  }

  Widget _consentRow({
    required bool checked,
    required ValueChanged<bool> onChanged,
    required String label,
    String? route,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: checked,
          onChanged: (v) => onChanged(v ?? false),
          activeColor: BuddyColors.green,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: route != null
                ? GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed(route),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: BuddyColors.textSecondary,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 14),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelect(String title, List<String> options, List<String> selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: BuddyColors.textPrimary)),
        const SizedBox(height: 8),
        const Text('Select all that apply', style: TextStyle(color: BuddyColors.textSecondary, fontSize: 14)),
        const SizedBox(height: 16),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((opt) {
              final isSelected = selected.contains(opt);
              return ChoiceChip(
                label: Text(opt),
                selected: isSelected,
                onSelected: (v) {
                  setState(() {
                    if (v) {
                      selected.add(opt);
                    } else {
                      selected.remove(opt);
                    }
                  });
                },
                selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                backgroundColor: BuddyColors.surface,
                side: BorderSide(color: isSelected ? BuddyColors.green : BuddyColors.surfaceRaised),
                labelStyle: TextStyle(color: isSelected ? BuddyColors.green : BuddyColors.textSecondary),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleSelect(String title, List<String> options, String selected, void Function(String) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: BuddyColors.textPrimary)),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: options.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final opt = options[i];
              final isSelected = selected == opt;
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isSelected ? BuddyColors.green : BuddyColors.surfaceRaised),
                ),
                tileColor: isSelected ? BuddyColors.green.withValues(alpha: 0.1) : BuddyColors.surface,
                title: Text(opt, style: TextStyle(color: isSelected ? BuddyColors.green : BuddyColors.textPrimary)),
                trailing: isSelected ? const Icon(Icons.check_circle, color: BuddyColors.green) : null,
                onTap: () => onSelected(opt),
              );
            },
          ),
        ),
      ],
    );
  }
}
