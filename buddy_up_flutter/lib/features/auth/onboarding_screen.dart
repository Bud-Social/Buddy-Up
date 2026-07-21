import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/onboarding.dart';
import '../../data/repositories/profile_repository.dart';

import '../../shared/widgets/button.dart';
import '../../shared/widgets/toast.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  bool _isLoading = false;

  final List<String> _selectedGoals = [];
  String _activityLevel = '';
  final List<String> _selectedWorkouts = [];
  String _dietaryPreference = '';
  String _preferredTime = '';
  final String _discoverySource = '';

  late ProfileRepository _profileRepo;

  final _goals = ['Lose Weight', 'Build Muscle', 'Improve Endurance', 'General Fitness', 'Flexibility', 'Sports Performance'];
  final _levels = ['Sedentary', 'Lightly Active', 'Moderately Active', 'Very Active', 'Extremely Active'];
  final _workouts = ['Running', 'Weightlifting', 'Yoga', 'Swimming', 'Cycling', 'HIIT', 'Boxing', 'Pilates', 'Dance', 'Calisthenics'];
  final _diets = ['None', 'Vegetarian', 'Vegan', 'Keto', 'Paleo', 'Mediterranean', 'Halal'];
  final _times = ['Early Morning', 'Morning', 'Afternoon', 'Evening', 'Late Night'];

  @override
  void initState() {
    super.initState();
    _profileRepo = ProfileRepository(ApiClient().dio);
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      await _profileRepo.saveOnboarding(
        OnboardingPayload(
          primaryGoal: _selectedGoals,
          activityLevel: _activityLevel,
          preferredWorkouts: _selectedWorkouts,
          dietaryPreference: _dietaryPreference,
          preferredTime: _preferredTime,
          discoverySource: _discoverySource.isNotEmpty ? _discoverySource : null,
        ),
      );
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/feed', (_) => false);
      }
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
        title: Text('Step ${_step + 1} of 5'),
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
                value: (_step + 1) / 5,
                backgroundColor: BuddyColors.surfaceRaised,
                color: BuddyColors.green,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: 24),
              Expanded(child: _buildStep()),
              const SizedBox(height: 24),
              BuddyButton(
                label: _step == 4 ? 'Get Started' : 'Next',
                onPressed: _step == 4 ? _submit : () => setState(() => _step++),
                isLoading: _isLoading,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildMultiSelect('What are your fitness goals?', _goals, _selectedGoals);
      case 1:
        return _buildSingleSelect('What\'s your activity level?', _levels, _activityLevel, (v) => _activityLevel = v);
      case 2:
        return _buildMultiSelect('Preferred workouts', _workouts, _selectedWorkouts);
      case 3:
        return _buildSingleSelect('Dietary preference', _diets, _dietaryPreference, (v) => _dietaryPreference = v);
      case 4:
        return _buildSingleSelect('Preferred workout time', _times, _preferredTime, (v) => _preferredTime = v);
      default:
        return const SizedBox();
    }
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
