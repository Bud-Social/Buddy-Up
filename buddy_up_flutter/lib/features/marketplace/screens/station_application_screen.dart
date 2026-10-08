import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/marketplace.dart';
import '../../../shared/widgets/input.dart';
import '../../../shared/widgets/wizard_widgets.dart';
import '../providers/marketplace_provider.dart';
import '../../../data/models/gym.dart';
import '../../../features/gym/providers/gym_provider.dart';
import '../utils/stations.dart';

/// Apply for a shop or gym you own to become a pickup station.
///
/// One live draft per applicant: the backend keeps a single `draft` row and
/// `submit=true` moves it to `submitted`, after which only staff can move it
/// further. Submitting twice therefore updates the same application rather than
/// creating a queue of duplicates.
///
/// A station belongs to *exactly one* owner, so the first step picks a shop or a
/// gym and never both.
class StationApplicationScreen extends ConsumerStatefulWidget {
  const StationApplicationScreen({super.key});

  @override
  ConsumerState<StationApplicationScreen> createState() =>
      _StationApplicationScreenState();
}

class _StationApplicationScreenState
    extends ConsumerState<StationApplicationScreen> {
  static const _stepCount = 3;
  static const _stepLabels = ['Owner', 'Site', 'Policy'];

  final PageController _pageController = PageController();
  int _currentStep = 0;

  String? _shopId;
  final _gymHandleController = TextEditingController();
  String? _gymId;
  String? _gymName;

  final _registrationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  final _hours = <String, ({bool open, TimeOfDay from, TimeOfDay to})>{
    for (final day in stationDayKeys)
      day: (open: true, from: const TimeOfDay(hour: 8, minute: 0), to: const TimeOfDay(hour: 20, minute: 0)),
  };

  bool _agreed = false;
  bool _submitting = false;
  String? _serverError;
  StationApplication? _application;

  @override
  void dispose() {
    _pageController.dispose();
    _gymHandleController.dispose();
    _registrationController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  bool get _hasOwner => _shopId != null || _gymId != null;

  /// Exactly one owner is required, so deselecting a shop clears a gym and the
  /// client never sends the pair the serializer rejects.
  void _selectShop(String? id) {
    setState(() {
      _shopId = id;
      if (id != null) {
        _gymId = null;
        _gymHandleController.clear();
      }
      _serverError = null;
    });
  }

  Future<void> _resolveGym() async {
    final handle = _gymHandleController.text.trim();
    if (handle.isEmpty) return;
    try {
      final gym = await ref.read(gymRepositoryProvider).getGym(handle);
      if (!mounted) return;
      final parsed = Gym.fromJson(gym['data'] as Map<String, dynamic>);
      setState(() {
        _gymId = parsed.id;
        _gymName = parsed.name;
        _shopId = null;
        _serverError = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _serverError = apiErrorMessage(
              e,
              fallback: 'Could not find a gym with that handle.',
            ));
      }
    }
  }

  void _next() {
    if (_currentStep == 0 && !_hasOwner) {
      setState(() => _serverError =
          'Pick the shop or gym that will own this pickup station.');
      return;
    }
    setState(() => _serverError = null);
    if (_currentStep < _stepCount - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
          duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
    }
  }

  void _back() {
    if (_currentStep == 0) return;
    setState(() => _currentStep--);
    _pageController.previousPage(
        duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
  }

  /// The exact shape the serializer documents: `{monday: {open, close}}`, with a
  /// closed day simply omitted.
  Map<String, dynamic> _openingHoursPayload() {
    final hours = <String, dynamic>{};
    _hours.forEach((day, value) {
      if (!value.open) return;
      hours[day] = {
        'open': _hhmm(value.from),
        'close': _hhmm(value.to),
      };
    });
    return hours;
  }

  static String _hhmm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _submit() async {
    if (!_agreed) {
      setState(() => _serverError =
          'Agree to the station policy before submitting.');
      return;
    }
    setState(() {
      _submitting = true;
      _serverError = null;
    });
    try {
      final raw = await ref
          .read(marketplaceRepositoryProvider)
          .applyForStation({
        if (_shopId != null) 'shop': _shopId,
        if (_gymId != null) 'gym': _gymId,
        'business_registration_number': _registrationController.text.trim(),
        'contact_phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'country': _countryController.text.trim(),
        'opening_hours': _openingHoursPayload(),
        'agreed_to_policy': true,
        'submit': true,
      });
      if (!mounted) return;
      setState(() {
        _application = StationApplication.fromJson(
            raw['data'] as Map<String, dynamic>);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(raw['message'] as String? ?? 'Application submitted.')),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _serverError =
            apiErrorMessage(e, fallback: 'Could not submit your application.'));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shops = ref.watch(myShopsProvider).value ?? const <Shop>[];
    return Scaffold(
      appBar: AppBar(
        title: Text('Station application — ${_stepLabels[_currentStep]}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          WizardStepIndicator(current: _currentStep, total: _stepCount),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _ownerStep(shops),
                _siteStep(),
                _policyStep(),
              ],
            ),
          ),
          WizardNavButtons(
            currentStep: _currentStep,
            total: _stepCount,
            loading: _submitting,
            onNext: _next,
            onBack: _back,
            onSubmit: _submit,
            submitLabel: 'Submit application',
          ),
        ],
      ),
    );
  }

  Widget _ownerStep(List<Shop> shops) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Who owns this station?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text(
          'A pickup station belongs to exactly one shop or one gym.',
          style: TextStyle(fontSize: 13, color: BuddyColors.textSecondary),
        ),
        const SizedBox(height: 20),
        const Text('Your shops',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (shops.isEmpty)
          const Text(
            'You do not own a shop yet, so pick a gym below instead.',
            style: TextStyle(fontSize: 12, color: BuddyColors.textSecondary),
          )
        else
          for (final shop in shops)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => _selectShop(_shopId == shop.id ? null : shop.id),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: _shopId == shop.id
                        ? BuddyColors.green.withValues(alpha: 0.1)
                        : cs.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _shopId == shop.id
                          ? BuddyColors.green
                          : cs.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _shopId == shop.id
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 18,
                        color: _shopId == shop.id
                            ? BuddyColors.green
                            : cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(shop.name,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                      if (shop.isCertified)
                        const Icon(Icons.verified,
                            size: 16, color: BuddyColors.green),
                    ],
                  ),
                ),
              ),
            ),
        const SizedBox(height: 20),
        const Text('Or a gym you own',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        BuddyInput(
          label: 'Gym handle',
          hint: 'e.g. iron-foundry',
          controller: _gymHandleController,
          suffixIcon: Icons.search,
          onSuffixTap: _resolveGym,
          onChanged: (_) {
            if (_gymId != null) setState(() => _gymId = null);
          },
        ),
        const SizedBox(height: 8),
        if (_gymId != null)
          Text(
            'Gym owner: ${_gymName ?? _gymId}',
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: BuddyColors.green),
          )
        else
          const Text(
            'There is no "my gyms" endpoint, so a gym is picked by handle and '
            'resolved to its id here.',
            style: TextStyle(
                fontSize: 11, color: BuddyColors.textSecondary, height: 1.35),
          ),
      ],
    );
  }

  Widget _siteStep() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Where is it?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        WizardTextField(
          'Business registration number',
          _registrationController,
          hint: 'Optional',
        ),
        const SizedBox(height: 16),
        BuddyInput(
          label: 'Contact phone',
          hint: '+254 712 345 678',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        WizardTextField(
          'Street address',
          _addressController,
          hint: 'Level 2, Westlands Mall',
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        WizardTextField('City', _cityController, hint: 'Nairobi'),
        const SizedBox(height: 16),
        WizardTextField('Country', _countryController, hint: 'Kenya'),
      ],
    );
  }

  Widget _policyStep() {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Opening hours',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text(
          'Buyers see these on the station picker, so keep them accurate.',
          style: TextStyle(fontSize: 13, color: BuddyColors.textSecondary),
        ),
        const SizedBox(height: 16),
        for (final day in stationDayKeys)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _DayHoursRow(
              day: day,
              label: stationDayLabels[day] ?? day,
              value: _hours[day]!,
              onChanged: (value) => setState(() => _hours[day] = value),
            ),
          ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: CheckboxListTile(
            value: _agreed,
            onChanged: (v) => setState(() => _agreed = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            activeColor: BuddyColors.green,
            title: const Text(
              'I agree to the pickup station policy and will keep these hours '
              'accurate.',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ),
        if (_application != null) ...[
          const SizedBox(height: 16),
          Text(
            'Application status: ${_application!.status.replaceAll('_', ' ')}',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: BuddyColors.green),
          ),
          if (_application!.rejectionReason.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Rejected: ${_application!.rejectionReason}',
                style: const TextStyle(fontSize: 12, color: BuddyColors.red),
              ),
            ),
        ],
        if (_serverError != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BuddyColors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: BuddyColors.red.withValues(alpha: 0.3)),
            ),
            child: Text(
              _serverError!,
              style: const TextStyle(
                  fontSize: 12, color: BuddyColors.red, height: 1.35),
            ),
          ),
        ],
      ],
    );
  }
}

typedef DayHours = ({bool open, TimeOfDay from, TimeOfDay to});

class _DayHoursRow extends StatelessWidget {
  final String day;
  final String label;
  final DayHours value;
  final ValueChanged<DayHours> onChanged;

  const _DayHoursRow({
    required this.day,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  Future<void> _pickTime(BuildContext context, bool isFrom) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isFrom ? value.from : value.to,
    );
    if (picked == null) return;
    onChanged(isFrom
        ? (open: value.open, from: picked, to: value.to)
        : (open: value.open, from: value.from, to: picked));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Switch(
              value: value.open,
              activeThumbColor: BuddyColors.green,
              onChanged: (v) => onChanged((
                open: v,
                from: value.from,
                to: value.to,
              )),
            ),
          ),
          if (value.open)
            TextButton(
              onPressed: () => _pickTime(context, true),
              child: Text(value.from.format(context)),
            ),
          if (value.open) const Text('–'),
          if (value.open)
            TextButton(
              onPressed: () => _pickTime(context, false),
              child: Text(value.to.format(context)),
            ),
          if (!value.open)
            Text('Closed',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}