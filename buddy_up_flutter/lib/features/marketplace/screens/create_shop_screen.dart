import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/marketplace_provider.dart';

class CreateShopScreen extends ConsumerStatefulWidget {
  const CreateShopScreen({super.key});

  @override
  ConsumerState<CreateShopScreen> createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends ConsumerState<CreateShopScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _loading = false;

  // Form data
  final _nameController = TextEditingController();
  final _handleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  String _shopType = 'fitness';
  XFile? _logoFile;
  XFile? _coverFile;

  final List<String> _shopTypes = ['fitness', 'nutrition', 'wellness', 'medical', 'merchandise'];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _handleController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isLogo) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) {
      setState(() {
        if (isLogo) {
          _logoFile = file;
        } else {
          _coverFile = file;
        }
      });
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _createShop() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      final data = {
        'name': _nameController.text.trim(),
        'handle': _handleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _shopType,
        'contact_email': _emailController.text.trim(),
        'contact_phone': _phoneController.text.trim(),
        'website_url': _websiteController.text.trim(),
      };

      // Upload logo if selected
      if (_logoFile != null) {
        final formData = FormData.fromMap({
          'image': await MultipartFile.fromFile(_logoFile!.path, filename: 'logo.jpg'),
        });
        final result = await repo.uploadImage(formData);
        data['logo_url'] = result['data']['url'] as String;
      }

      // Upload cover if selected
      if (_coverFile != null) {
        final formData = FormData.fromMap({
          'image': await MultipartFile.fromFile(_coverFile!.path, filename: 'cover.jpg'),
        });
        final result = await repo.uploadImage(formData);
        data['banner_url'] = result['data']['url'] as String;
      }

      await repo.createShop(data);
      ref.invalidate(myShopsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Shop created successfully!'),
            backgroundColor: BuddyColors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BuddyColors.black,
      appBar: AppBar(
        backgroundColor: BuddyColors.surface,
        title: const Text('Create Shop'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Step indicator
          Container(
            color: BuddyColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: List.generate(4, (i) {
                final isActive = i <= _currentStep;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                    height: 3,
                    decoration: BoxDecoration(
                      color: isActive ? BuddyColors.green : BuddyColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _Step1BasicInfo(),
                _Step2Branding(),
                _Step3ShopType(),
                _Step4Review(),
              ],
            ),
          ),
          // Navigation buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _prevStep,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: BuddyColors.green),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _loading
                          ? null
                          : _currentStep < 3
                              ? _nextStep
                              : _createShop,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BuddyColors.green,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : Text(_currentStep < 3 ? 'Next' : 'Create Shop',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _Step1BasicInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Basic Information',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Start with your shop name and handle.',
              style: TextStyle(color: BuddyColors.textSecondary)),
          const SizedBox(height: 28),
          _buildField('Shop Name', _nameController, hint: 'e.g. FitLife by Coach John'),
          const SizedBox(height: 16),
          _buildField('Handle', _handleController,
              hint: 'e.g. fitlife-john', prefix: '@'),
          const SizedBox(height: 16),
          _buildField('Description', _descriptionController,
              hint: 'Describe your shop and what you offer...', maxLines: 4),
          const SizedBox(height: 16),
          _buildField('Contact Email', _emailController, hint: 'your@email.com',
              inputType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          _buildField('Phone', _phoneController,
              hint: '+1 234 567 890', inputType: TextInputType.phone),
          const SizedBox(height: 16),
          _buildField('Website', _websiteController,
              hint: 'https://yoursite.com', inputType: TextInputType.url),
        ],
      ),
    );
  }

  Widget _Step2Branding() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Branding', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Upload your shop logo and cover image.',
              style: TextStyle(color: BuddyColors.textSecondary)),
          const SizedBox(height: 28),
          // Cover preview
          GestureDetector(
            onTap: () => _pickImage(false),
            child: Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: BuddyColors.surfaceRaised,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: _coverFile != null ? BuddyColors.green : BuddyColors.surfaceRaised,
                    width: 2),
              ),
              clipBehavior: Clip.antiAlias,
              child: _coverFile != null
                  ? Image.file(File(_coverFile!.path), fit: BoxFit.cover)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            size: 40, color: BuddyColors.textSecondary),
                        const SizedBox(height: 8),
                        const Text('Tap to upload cover image',
                            style: TextStyle(color: BuddyColors.textSecondary)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Logo', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _pickImage(true),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: BuddyColors.surfaceRaised,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _logoFile != null ? BuddyColors.green : BuddyColors.surfaceRaised,
                    width: 2),
              ),
              clipBehavior: Clip.antiAlias,
              child: _logoFile != null
                  ? Image.file(File(_logoFile!.path), fit: BoxFit.cover)
                  : const Icon(Icons.storefront_outlined,
                      size: 36, color: BuddyColors.textSecondary),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Tap to upload logo',
              style: TextStyle(fontSize: 12, color: BuddyColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _Step3ShopType() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Shop Type', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('What kind of services does your shop offer?',
              style: TextStyle(color: BuddyColors.textSecondary)),
          const SizedBox(height: 28),
          ..._shopTypes.map((type) => _ShopTypeOption(
                type: type,
                isSelected: _shopType == type,
                onTap: () => setState(() => _shopType = type),
              )),
        ],
      ),
    );
  }

  Widget _Step4Review() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Review & Create', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Check your shop details before creating.',
              style: TextStyle(color: BuddyColors.textSecondary)),
          const SizedBox(height: 24),
          Card(
            color: BuddyColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ReviewRow('Name', _nameController.text),
                  _ReviewRow('Handle', '@${_handleController.text}'),
                  _ReviewRow('Type', _shopType),
                  if (_emailController.text.isNotEmpty)
                    _ReviewRow('Email', _emailController.text),
                  if (_descriptionController.text.isNotEmpty)
                    _ReviewRow('Description', _descriptionController.text),
                  _ReviewRow('Logo', _logoFile != null ? '✅ Uploaded' : '⚠️ Not set'),
                  _ReviewRow('Cover', _coverFile != null ? '✅ Uploaded' : '⚠️ Not set'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BuddyColors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: BuddyColors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: BuddyColors.green, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'You can apply for certification after creating your shop to unlock more features.',
                    style: TextStyle(fontSize: 12, color: BuddyColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: BuddyColors.textSecondary)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {String? hint, String? prefix, int maxLines = 1, TextInputType? inputType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: inputType,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            filled: true,
            fillColor: BuddyColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _ShopTypeOption extends StatelessWidget {
  final String type;
  final bool isSelected;
  final VoidCallback onTap;

  const _ShopTypeOption(
      {required this.type, required this.isSelected, required this.onTap});

  IconData get icon {
    switch (type) {
      case 'fitness':
        return Icons.fitness_center;
      case 'nutrition':
        return Icons.restaurant;
      case 'wellness':
        return Icons.spa;
      case 'medical':
        return Icons.medical_services;
      case 'merchandise':
        return Icons.shopping_bag;
      default:
        return Icons.storefront;
    }
  }

  String get label => type[0].toUpperCase() + type.substring(1);

  String get description {
    switch (type) {
      case 'fitness':
        return 'Training programmes, gym services';
      case 'nutrition':
        return 'Meal plans, dietary advice';
      case 'wellness':
        return 'Mindfulness, holistic health';
      case 'medical':
        return 'Health services, consultations';
      case 'merchandise':
        return 'Physical or digital products';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? BuddyColors.green.withValues(alpha: 0.12)
              : BuddyColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? BuddyColors.green : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? BuddyColors.green.withValues(alpha: 0.2)
                    : BuddyColors.surfaceRaised,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color: isSelected ? BuddyColors.green : BuddyColors.textSecondary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? BuddyColors.green : null)),
                  Text(description,
                      style: const TextStyle(
                          fontSize: 12, color: BuddyColors.textSecondary)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: BuddyColors.green, size: 22),
          ],
        ),
      ),
    );
  }
}
