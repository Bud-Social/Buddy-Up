import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/profile.dart';
import '../../data/repositories/profile_repository.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/input.dart';
import '../../shared/widgets/toast.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final Profile profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;
  late TextEditingController _pronounsController;
  late TextEditingController _locationCityController;
  late TextEditingController _locationCountryController;
  late TextEditingController _externalLinkController;
  String _avatarUrl = '';
  // ignore: unused_field
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  late ProfileRepository _profileRepo;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _profileRepo = ProfileRepository(ApiClient().dio);
    _avatarUrl = widget.profile.avatarUrl;
    _displayNameController = TextEditingController(text: widget.profile.displayName);
    _bioController = TextEditingController(text: widget.profile.bio);
    _pronounsController = TextEditingController(text: widget.profile.pronouns);
    _locationCityController = TextEditingController(text: widget.profile.locationCity);
    _locationCountryController = TextEditingController(text: widget.profile.locationCountry);
    _externalLinkController = TextEditingController(text: widget.profile.externalLink ?? '');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _pronounsController.dispose();
    _locationCityController.dispose();
    _locationCountryController.dispose();
    _externalLinkController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (file == null) return;
    setState(() => _isLoading = true);
    try {
      final res = await _profileRepo.uploadAvatar(
        FormData.fromMap({
          'avatar': await MultipartFile.fromFile(file.path, filename: 'avatar.jpg'),
        }),
      );
      final data = res['data'] as Map<String, dynamic>?;
      final newUrl = data?['avatar_url'] as String? ?? '';
      if (newUrl.isNotEmpty) {
        setState(() => _avatarUrl = newUrl);
        await ref.read(authProvider.notifier).updateProfile(
          widget.profile.copyWith(avatarUrl: newUrl),
        );
      }
      if (mounted) showToast(context, 'Avatar updated!', type: ToastType.success);
    } catch (e) {
      if (mounted) showToast(context, 'Failed to upload avatar.', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      await _profileRepo.updateProfile(
        ProfileUpdatePayload(
          displayName: _displayNameController.text.trim(),
          bio: _bioController.text.trim(),
          pronouns: _pronounsController.text.trim(),
          locationCity: _locationCityController.text.trim(),
          locationCountry: _locationCountryController.text.trim(),
          externalLink: _externalLinkController.text.trim().isNotEmpty ? _externalLinkController.text.trim() : null,
        ),
      );
      if (mounted) {
        showToast(context, 'Profile updated!', type: ToastType.success);
        await ref.read(authProvider.notifier).updateProfile(widget.profile.copyWith(
          displayName: _displayNameController.text.trim(),
          bio: _bioController.text.trim(),
          pronouns: _pronounsController.text.trim(),
          locationCity: _locationCityController.text.trim(),
          locationCountry: _locationCountryController.text.trim(),
          avatarUrl: _avatarUrl,
        ));
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) showToast(context, 'Failed to update profile.', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Save',
              style: TextStyle(
                color: BuddyColors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Avatar(
                        src: _avatarUrl.isNotEmpty ? _avatarUrl : null,
                        alt: widget.profile.displayName,
                        size: AvatarSize.xl,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: BuddyColors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, size: 16, color: BuddyColors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                BuddyInput(
                  controller: _displayNameController,
                  label: 'Display Name',
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                BuddyInput(
                  controller: _bioController,
                  label: 'Bio',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                BuddyInput(
                  controller: _pronounsController,
                  label: 'Pronouns',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: BuddyInput(
                        controller: _locationCityController,
                        label: 'City',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BuddyInput(
                        controller: _locationCountryController,
                        label: 'Country',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                BuddyInput(
                  controller: _externalLinkController,
                  label: 'External Link',
                  hint: 'https://',
                  keyboardType: TextInputType.url,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
