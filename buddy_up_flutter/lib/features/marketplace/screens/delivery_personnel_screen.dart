import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/marketplace.dart'
    show DeliveryPersonnel, DeliveryPersonnelApplication;
import '../../../shared/widgets/input.dart';
import '../../../shared/widgets/wizard_widgets.dart';
import '../../../shared/navigation/business_roles_provider.dart';
import '../../../shared/navigation/main_header.dart';
import '../../verification/providers/verification_provider.dart';
import '../providers/marketplace_provider.dart';
import '../utils/checkout.dart' show isValidPhone;
import '../utils/delivery_vehicles.dart';

/// Register / update yourself as delivery personnel, and apply to be approved as
/// one.
///
/// The backend separates the two on purpose. `POST
/// /marketplace/delivery-personnel/` writes *your own* courier record — the
/// vehicle, zones and availability a dispatcher reads. `POST
/// /marketplace/delivery-personnel-applications/` is the vetted claim that
/// actually gets a `DeliveryPersonnel` row approved in the first place. Both
/// are offered side by side at the review step rather than chained, so an
/// existing courier updating their zones never accidentally files a fresh
/// application.
///
/// The vehicle list is a wire contract (`DELIVERY_VEHICLE_TYPES`): exactly
/// bike / motorbike / tuktuk / car / pickup / lorry, and nothing else.
class DeliveryPersonnelScreen extends ConsumerStatefulWidget {
  const DeliveryPersonnelScreen({super.key});

  @override
  ConsumerState<DeliveryPersonnelScreen> createState() =>
      _DeliveryPersonnelScreenState();
}

class _DeliveryPersonnelScreenState
    extends ConsumerState<DeliveryPersonnelScreen> {
  static const _stepCount = 3;
  static const _stepLabels = ['Vehicle', 'Coverage', 'Review'];

  final PageController _pageController = PageController();
  int _currentStep = 0;

  String _vehicleType = kDeliveryVehicleTypes.first.value;
  final _zonesController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _idDocumentController = TextEditingController();
  final _licenceController = TextEditingController();
  PlatformFile? _idFile;
  PlatformFile? _licenceFile;

  bool _submitting = false;
  String? _serverError;
  String? _notice;
  DeliveryPersonnel? _savedProfile;
  DeliveryPersonnelApplication? _application;

  @override
  void dispose() {
    _pageController.dispose();
    _zonesController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _idDocumentController.dispose();
    _licenceController.dispose();
    super.dispose();
  }

  List<String> get _zones => parseServiceZones(_zonesController.text);

  bool _stepError() {
    switch (_currentStep) {
      case 1:
        if (_zones.isEmpty) return true;
        if (_phoneController.text.trim().isNotEmpty &&
            !isValidPhone(_phoneController.text.trim())) {
          return true;
        }
        return false;
      default:
        return false;
    }
  }

  void _next() {
    if (_stepError()) {
      setState(
        () => _serverError = _currentStep == 1
            ? (_zones.isEmpty
                  ? 'Add at least one service zone you can deliver in.'
                  : 'Enter a valid phone number (7–15 digits) or leave it blank.')
            : null,
      );
      return;
    }
    setState(() => _serverError = null);
    if (_currentStep < _stepCount - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  void _back() {
    if (_currentStep == 0) return;
    setState(() => _currentStep--);
    _pageController.previousPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  Map<String, dynamic> get _basePayload => {
    'vehicle_type': _vehicleType,
    'service_zones': _zones,
    if (_bioController.text.trim().isNotEmpty)
      'bio': _bioController.text.trim(),
  };

  /// Self-service courier record. Self only — the serializer's `profile` is
  /// read-only and the view rejects another user's id outright.
  Future<void> _saveProfile() async {
    await _run(() async {
      final raw = await ref
          .read(marketplaceRepositoryProvider)
          .saveDeliveryPersonnel(_basePayload);
      _savedProfile = DeliveryPersonnel.fromJson(
        raw['data'] as Map<String, dynamic>,
      );
      _notice = raw['message'] as String? ?? 'Courier profile saved.';
      await ref.read(businessRolesProvider.notifier).refresh();
    });
  }

  /// The application is what staff review; `submit: true` moves the draft
  /// straight to `submitted` so it lands in the queue.
  Future<void> _submitApplication() async {
    await _run(() async {
      String? idUrl;
      String? licenceUrl;
      if (_idFile != null) {
        final raw = await _uploadVerificationFile(_idFile!, 'id_card');
        idUrl = _documentUrl(raw);
      }
      if (_licenceFile != null) {
        final raw = await _uploadVerificationFile(
          _licenceFile!,
          'drivers_license',
        );
        licenceUrl = _documentUrl(raw);
      }
      final raw = await ref
          .read(marketplaceRepositoryProvider)
          .applyAsDeliveryPersonnel({
            ..._basePayload,
            'phone': _phoneController.text.trim(),
            'id_document_url': idUrl ?? _idDocumentController.text.trim(),
            'licence_document_url':
                licenceUrl ?? _licenceController.text.trim(),
            'submit': true,
          });
      _application = DeliveryPersonnelApplication.fromJson(
        raw['data'] as Map<String, dynamic>,
      );
      _notice = raw['message'] as String? ?? 'Application submitted.';
      // An approved/self-provisioned courier should appear in the drawer as
      // soon as the registration flow completes. The probe remains
      // server-authoritative and simply hides the entry while approval is
      // still pending.
      await ref.read(businessRolesProvider.notifier).refresh();
    });
  }

  Future<dynamic> _uploadVerificationFile(
    PlatformFile file,
    String type,
  ) async {
    final bytes = await file.readAsBytes();
    if (bytes.length > 50 * 1024 * 1024) {
      throw StateError('Verification files must be 50 MB or smaller.');
    }
    return ref.read(verificationRepositoryProvider).uploadCredentialFile({
      'file': MultipartFile.fromBytes(bytes, filename: file.name),
      'document_type': type,
    });
  }

  String? _documentUrl(dynamic raw) {
    final data = raw is Map ? raw['data'] : null;
    return data is Map ? data['file_url'] as String? : null;
  }

  Future<void> _pickDocument({required bool licence}) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
    );
    if (result.isEmpty) return;
    final file = result.first;
    if (!mounted) return;
    setState(() {
      if (licence) {
        _licenceFile = file;
      } else {
        _idFile = file;
      }
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _submitting = true;
      _serverError = null;
      _notice = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) {
        setState(
          () => _serverError = apiErrorMessage(
            e,
            fallback: 'Could not save your courier details.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: 'Courier — ${_stepLabels[_currentStep]}',
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
              children: [_vehicleStep(), _coverageStep(), _reviewStep()],
            ),
          ),
          WizardNavButtons(
            currentStep: _currentStep,
            total: _stepCount,
            loading: _submitting,
            onNext: _next,
            onBack: _back,
            onSubmit: _submitApplication,
            submitLabel: 'Submit application',
          ),
        ],
      ),
    );
  }

  Widget _vehicleStep() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'What do you ride or drive?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'This is the vehicle a seller sees when they assign you an order.',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        for (final entry in kDeliveryVehicleTypes)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => setState(() {
                _vehicleType = entry.value;
                _serverError = null;
              }),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: _vehicleType == entry.value
                      ? BuddyColors.green.withValues(alpha: 0.1)
                      : BuddyColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _vehicleType == entry.value
                        ? BuddyColors.green
                        : BuddyColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _vehicleType == entry.value
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 18,
                      color: _vehicleType == entry.value
                          ? BuddyColors.green
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      entry.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _coverageStep() {
    final phoneInvalid =
        _phoneController.text.trim().isNotEmpty &&
        !isValidPhone(_phoneController.text.trim());
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Where you deliver',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        WizardTextField(
          'Service zones',
          _zonesController,
          hint: 'Westlands, Kilimani, Parklands',
        ),
        const SizedBox(height: 6),
        Text(
          'Comma-separated area names. Sellers pick couriers partly on this.',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        BuddyInput(
          label: 'Phone (optional)',
          hint: '+254 712 345 678',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          error: phoneInvalid
              ? 'Use 7–15 digits, e.g. +254 712 345 678.'
              : null,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        WizardTextField(
          'About you (optional)',
          _bioController,
          hint: 'Two lines about how you deliver',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        _documentPicker(
          'National ID / passport',
          _idFile,
          () => _pickDocument(licence: false),
        ),
        const SizedBox(height: 16),
        _documentPicker(
          'Driving licence',
          _licenceFile,
          () => _pickDocument(licence: true),
        ),
      ],
    );
  }

  Widget _documentPicker(String label, PlatformFile? file, VoidCallback pick) {
    return OutlinedButton.icon(
      onPressed: pick,
      icon: const Icon(Icons.upload_file_outlined),
      label: Text(
        file == null ? '$label · choose file' : '$label: ${file.name}',
      ),
    );
  }

  Widget _reviewStep() {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Review & submit',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Two separate things: your courier record is what dispatch reads, the '
          'application is what staff approve.',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ReviewRow(
                label: 'Vehicle',
                value: deliveryVehicleLabel(_vehicleType),
              ),
              _ReviewRow(
                label: 'Service zones',
                value: serviceZonesLabel(_zones),
              ),
              _ReviewRow(
                label: 'Phone',
                value: _phoneController.text.trim().isEmpty
                    ? '—'
                    : _phoneController.text.trim(),
              ),
              _ReviewRow(
                label: 'ID document',
                value: _idDocumentController.text.trim().isEmpty
                    ? 'Not provided'
                    : 'Provided',
              ),
              _ReviewRow(
                label: 'Licence',
                value: _licenceController.text.trim().isEmpty
                    ? 'Not provided'
                    : 'Provided',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ActionTile(
          icon: Icons.badge_outlined,
          title: 'Save courier profile',
          subtitle:
              'Writes your own courier record. Use this to keep your zones and '
              'availability up to date.',
          loading: _submitting,
          onTap: _saveProfile,
        ),
        if (_savedProfile != null) ...[
          const SizedBox(height: 8),
          Text(
            'Saved: ${deliveryVehicleLabel(_savedProfile!.vehicleType)} · '
            '${serviceZonesLabel(_savedProfile!.serviceZones)}',
            style: const TextStyle(fontSize: 12, color: BuddyColors.green),
          ),
        ],
        const SizedBox(height: 8),
        _ActionTile(
          icon: Icons.how_to_reg,
          title: 'Submit application for approval',
          subtitle:
              'Files the vetted application staff review. One live draft per person.',
          loading: _submitting,
          onTap: _submitApplication,
        ),
        if (_application != null) ...[
          const SizedBox(height: 8),
          Text(
            'Application status: ${_application!.status.replaceAll('_', ' ')}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: BuddyColors.green,
            ),
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
        if (_notice != null) ...[
          const SizedBox(height: 16),
          Text(
            _notice!,
            style: const TextStyle(fontSize: 13, color: BuddyColors.green),
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
                fontSize: 12,
                color: BuddyColors.red,
                height: 1.35,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool loading;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: BuddyColors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            if (loading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
      ),
    );
  }
}
