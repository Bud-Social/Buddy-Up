import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/api_client.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/env/env.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/onboarding.dart';
import '../../data/models/profile.dart';
import '../../data/repositories/profile_repository.dart';

import '../../shared/widgets/button.dart';
import '../../shared/widgets/input.dart';
import '../../shared/widgets/toast.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  bool _isLoading = false;
  OnboardingPlan? _plan;

  // Web onboarding's profile step (step 2) — social sign-ins need all of these.
  final _displayName = TextEditingController();
  final _username = TextEditingController();
  final _city = TextEditingController();
  final _bio = TextEditingController();
  String _usernameStatus = 'idle';
  int _usernameCheckId = 0;
  Timer? _usernameTimer;

  static const _totalSteps =
      9; // consent, profile, goals, level, workouts, diet, time, preview, plan

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
  static const _goalLabels = [
    'Lose Weight',
    'Build Muscle',
    'Improve Endurance',
    'General Fitness',
    'Flexibility',
    'Sports Performance',
  ];
  static const _goalValues = [
    'lose_weight',
    'muscle_gain',
    'improve_endurance',
    'general_fitness',
    'flexibility',
    'sports_performance',
  ];
  static const _levelLabels = [
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Very Active',
    'Extremely Active',
  ];
  static const _levelValues = [
    'sedentary',
    'lightly_active',
    'moderately_active',
    'very_active',
    'extremely_active',
  ];
  final _workoutLabels = const [
    'Running',
    'Weightlifting',
    'Yoga',
    'Swimming',
    'Cycling',
    'HIIT',
    'Boxing',
    'Pilates',
    'Dance',
    'Calisthenics',
  ];
  final _workoutValues = const [
    'running',
    'weights',
    'yoga',
    'swimming',
    'cycling',
    'hiit',
    'martial_arts',
    'pilates',
    'other',
    'other',
  ];
  final _dietLabels = const [
    'None',
    'Vegetarian',
    'Vegan',
    'Keto',
    'Paleo',
    'Mediterranean',
    'Halal',
  ];
  final _dietValues = const [
    'none',
    'vegetarian',
    'vegan',
    'keto',
    'paleo',
    'other',
    'halal',
  ];
  static const _timeLabels = [
    'Early Morning',
    'Morning',
    'Afternoon',
    'Evening',
    'Late Night',
  ];
  static const _timeValues = [
    'early_morning',
    'morning',
    'afternoon',
    'evening',
    'late_night',
  ];

  @override
  void initState() {
    super.initState();
    _profileRepo = ProfileRepository(ApiClient().dio);
    final profile = ref.read(authProvider).profile;
    if (profile != null) {
      _displayName.text = profile.displayName;
      _username.text = profile.username;
      _city.text = profile.locationCity;
      _bio.text = profile.bio;
    }
    _username.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _usernameTimer?.cancel();
    _username.removeListener(_onUsernameChanged);
    _displayName.dispose();
    _username.dispose();
    _city.dispose();
    _bio.dispose();
    super.dispose();
  }

  /// Mirrors the web onboarding's live username availability check.
  void _onUsernameChanged() {
    final candidate = _username.text.trim().toLowerCase();
    _usernameTimer?.cancel();
    if (candidate.length < 3) {
      if (mounted) setState(() => _usernameStatus = 'idle');
      return;
    }
    if (!RegExp(r'^[a-z0-9_]{3,30}$').hasMatch(candidate)) {
      if (mounted) setState(() => _usernameStatus = 'invalid');
      return;
    }
    if (mounted) setState(() => _usernameStatus = 'checking');
    final id = ++_usernameCheckId;
    _usernameTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final response = await Dio().get<Map<String, dynamic>>(
          '${Env.apiBaseUrl}/auth/check-username/',
          queryParameters: {'username': candidate},
          options: Options(headers: const {'User-Agent': 'BuddyUp-Fit-App'}),
        );
        if (!mounted || id != _usernameCheckId) return;
        final payload = response.data?['data'] is Map
            ? response.data!['data'] as Map
            : response.data;
        final available = payload?['available'] == true;
        setState(
          () => _usernameStatus = available
              ? 'available'
              : (payload?['reason'] == 'invalid' ? 'invalid' : 'taken'),
        );
      } catch (_) {
        if (mounted && id == _usernameCheckId) {
          // Endpoint may be unreachable; the submit serializer still validates.
          setState(() => _usernameStatus = 'unknown');
        }
      }
    });
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
          dietaryPreference: _toValue(
            _dietaryPreference,
            _dietLabels,
            _dietValues,
          ),
          preferredTime: _toValue(_preferredTime, _timeLabels, _timeValues),
          discoverySource: _discoverySource.isNotEmpty
              ? _discoverySource
              : null,
          displayName: _displayName.text.trim().isEmpty
              ? null
              : _displayName.text.trim(),
          username: _username.text.trim().isEmpty
              ? null
              : _username.text.trim().toLowerCase(),
          locationCity: _city.text.trim().isEmpty ? null : _city.text.trim(),
          bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
          termsVersion: _termsVersion,
          marketingConsent: _marketingConsent,
        ),
      );
      // Sync the completed onboarding flag locally — otherwise the router's
      // onboarding gate would bounce the user straight back here.
      final profileJson = data['profile'];
      if (profileJson is Map<String, dynamic>) {
        await ref
            .read(authProvider.notifier)
            .updateProfile(Profile.fromJson(profileJson));
      }
      final planJson = data['onboarding_plan'];
      if (planJson is Map<String, dynamic>) {
        if (mounted) {
          setState(() {
            _plan = OnboardingPlan.fromJson(planJson);
            _step = 8;
          });
        }
        return;
      }
      if (mounted) context.go('/feed?walkthrough=1');
    } catch (e) {
      if (mounted) {
        // Web returns to the profile step with the server's field error.
        if (_step == 7) setState(() => _step = 1);
        showToast(
          context,
          'Something went wrong. Please try again.',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step ${_step + 1} of $_totalSteps'),
        leading: _step > 0 && _step < 8
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
                value: (_step + 1) / _totalSteps,
                backgroundColor: BuddyColors.surfaceRaised,
                color: BuddyColors.green,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: 24),
              Expanded(child: _buildStep()),
              const SizedBox(height: 24),
              BuddyButton(
                label: _step == 8
                    ? 'Go to BuddyUp'
                    : _step == 7
                    ? 'Confirm & Finish'
                    : 'Next',
                onPressed: _step == 8
                    ? () => context.go('/feed?walkthrough=1')
                    : _step == 7
                    ? (_isLoading ? null : _submit)
                    : (!_canAdvance ? null : () => setState(() => _step++)),
                isLoading: _isLoading,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _consentStepValid =>
      _acceptTerms && _acceptPrivacy && _acceptGuidelines;

  /// Web parity: each step requires an answer before advancing, including the
  /// profile step's display name, username format and live availability.
  bool get _canAdvance {
    switch (_step) {
      case 0:
        return _consentStepValid;
      case 1:
        final username = _username.text.trim().toLowerCase();
        return _displayName.text.trim().length >= 2 &&
            RegExp(r'^[a-z0-9_]{3,30}$').hasMatch(username) &&
            _usernameStatus != 'taken' &&
            _usernameStatus != 'invalid' &&
            _usernameStatus != 'checking';
      case 2:
        return _selectedGoals.isNotEmpty;
      case 3:
        return _activityLevel.isNotEmpty;
      case 4:
        return _selectedWorkouts.isNotEmpty;
      case 5:
        return _dietaryPreference.isNotEmpty;
      case 6:
        return _preferredTime.isNotEmpty;
      default:
        return true;
    }
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildConsentStep();
      case 1:
        return _buildProfileStep();
      case 2:
        return _buildMultiSelect(
          'What are your fitness goals?',
          _goalLabels,
          _selectedGoals,
        );
      case 3:
        return _buildSingleSelect(
          'What\'s your activity level?',
          _levelLabels,
          _activityLevel,
          (v) => _activityLevel = v,
        );
      case 4:
        return _buildMultiSelect(
          'Preferred workouts',
          _workoutLabels,
          _selectedWorkouts,
        );
      case 5:
        return _buildSingleSelect(
          'Dietary preference',
          _dietLabels,
          _dietaryPreference,
          (v) => _dietaryPreference = v,
        );
      case 6:
        return _buildSingleSelect(
          'Preferred workout time',
          _timeLabels,
          _preferredTime,
          (v) => _preferredTime = v,
        );
      case 7:
        return _buildPreviewStep();
      case 8:
        return _buildPlanStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildProfileStep() {
    return ListView(
      children: [
        const Text(
          'Set up your profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: BuddyColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        BuddyInput(
          label: 'Display name',
          hint: 'e.g. Jane K.',
          controller: _displayName,
        ),
        const SizedBox(height: 12),
        BuddyInput(
          label: 'Username',
          hint: 'fitness_fan',
          controller: _username,
        ),
        const SizedBox(height: 4),
        Text(
          switch (_usernameStatus) {
            'available' => '✓ Username available',
            'taken' => '✗ That username is already taken',
            'invalid' => '3–30 characters — letters, numbers, underscores.',
            'checking' => 'Checking availability…',
            _ => '3–30 characters — letters, numbers, underscores.',
          },
          style: TextStyle(
            fontSize: 11,
            color: _usernameStatus == 'taken' || _usernameStatus == 'invalid'
                ? BuddyColors.red
                : _usernameStatus == 'available'
                ? BuddyColors.green
                : BuddyColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        BuddyInput(
          label: 'City (optional)',
          hint: 'Nairobi',
          controller: _city,
        ),
        const SizedBox(height: 12),
        BuddyInput(
          label: 'Short bio (optional)',
          hint: '5k beginner, gym 3×/week…',
          controller: _bio,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildPreviewStep() {
    final goalLabels = _selectedGoals
        .map((l) => _toValue(l, _goalLabels, _goalValues))
        .toList();
    final workoutLabels = _selectedWorkouts
        .map((l) => _toValue(l, _workoutLabels, _workoutValues))
        .toList();
    return ListView(
      children: [
        const Text(
          'Preview your profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: BuddyColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'This is how other Buddies will see you. You can change any of it later in Settings.',
          style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: BuddyColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: BuddyColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: BuddyColors.green.withValues(alpha: 0.15),
                    child: Text(
                      _displayName.text.trim().isEmpty
                          ? 'B'
                          : _displayName.text.trim()[0].toUpperCase(),
                      style: const TextStyle(
                        color: BuddyColors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayName.text.trim().isEmpty
                              ? 'Your Name'
                              : _displayName.text.trim(),
                          style: const TextStyle(
                            color: BuddyColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '@${_username.text.trim()}',
                          style: const TextStyle(
                            color: BuddyColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_bio.text.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  _bio.text.trim(),
                  style: const TextStyle(
                    color: BuddyColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (_city.text.trim().isNotEmpty)
                    _previewChip('📍 ${_city.text.trim()}'),
                  if (_activityLevel.isNotEmpty) _previewChip(_activityLevel),
                  for (final goal in goalLabels) _previewChip(goal),
                  for (final workout in workoutLabels) _previewChip(workout),
                  if (_dietaryPreference.isNotEmpty)
                    _previewChip(_dietaryPreference),
                  if (_preferredTime.isNotEmpty) _previewChip(_preferredTime),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _previewChip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: BuddyColors.surfaceRaised,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      label,
      style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 11),
    ),
  );

  Widget _buildPlanStep() {
    final plan = _plan;
    if (plan == null) return const SizedBox();
    return ListView(
      children: [
        const Text(
          'Your Personalised Plan',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: BuddyColors.green,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        if (plan.suggestedWorkoutPlan != null) ...[
          const Text(
            'RECOMMENDED WORKOUT PLAN',
            style: TextStyle(
              color: BuddyColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${plan.suggestedWorkoutPlan!.frequency} — ${plan.suggestedWorkoutPlan!.focus}',
            style: const TextStyle(
              color: BuddyColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: [
              for (final split in plan.suggestedWorkoutPlan!.sampleSplit)
                _previewChip(split),
            ],
          ),
          const SizedBox(height: 16),
        ],
        for (final item in [
          ('BUDDY MATCHING', plan.buddyMatchingHint),
          ('ACTIVITY', plan.activityLevelAdvice),
          ('TIMING', plan.timePreferenceAdvice),
          ('NUTRITION', plan.mealPlanRecommendation),
        ]) ...[
          if (item.$2 != null && item.$2!.isNotEmpty) ...[
            Text(
              item.$1,
              style: const TextStyle(
                color: BuddyColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.$2!,
              style: const TextStyle(
                color: BuddyColors.textPrimary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 14),
          ],
        ],
        if (plan.recommendedTrainerSpecialties.isNotEmpty) ...[
          const Text(
            'TRAINERS TO LOOK FOR',
            style: TextStyle(
              color: BuddyColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: [
              for (final s in plan.recommendedTrainerSpecialties)
                _previewChip(s),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildConsentStep() {
    return ListView(
      children: [
        const Text(
          'Stay safe out there',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: BuddyColors.textPrimary,
          ),
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
                    onTap: () => context.push(route),
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
                    style: const TextStyle(
                      color: BuddyColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelect(
    String title,
    List<String> options,
    List<String> selected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: BuddyColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select all that apply',
          style: TextStyle(color: BuddyColors.textSecondary, fontSize: 14),
        ),
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
                side: BorderSide(
                  color: isSelected
                      ? BuddyColors.green
                      : BuddyColors.surfaceRaised,
                ),
                labelStyle: TextStyle(
                  color: isSelected
                      ? BuddyColors.green
                      : BuddyColors.textSecondary,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleSelect(
    String title,
    List<String> options,
    String selected,
    void Function(String) onSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: BuddyColors.textPrimary,
          ),
        ),
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
                  side: BorderSide(
                    color: isSelected
                        ? BuddyColors.green
                        : BuddyColors.surfaceRaised,
                  ),
                ),
                tileColor: isSelected
                    ? BuddyColors.green.withValues(alpha: 0.1)
                    : BuddyColors.surface,
                title: Text(
                  opt,
                  style: TextStyle(
                    color: isSelected
                        ? BuddyColors.green
                        : BuddyColors.textPrimary,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: BuddyColors.green)
                    : null,
                onTap: () => onSelected(opt),
              );
            },
          ),
        ),
      ],
    );
  }
}
