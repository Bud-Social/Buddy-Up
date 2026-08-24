import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../messaging/providers/messaging_provider.dart';
import '../providers/community_provider.dart';

class CommunitySettingsScreen extends ConsumerStatefulWidget {
  final String communityId;
  final String initialName;
  final String initialDescription;
  final bool initialIsPublic;
  final String? initialAvatarUrl;
  final String? initialCoverUrl;

  const CommunitySettingsScreen({
    super.key,
    required this.communityId,
    required this.initialName,
    this.initialDescription = '',
    this.initialIsPublic = true,
    this.initialAvatarUrl,
    this.initialCoverUrl,
  });

  @override
  ConsumerState<CommunitySettingsScreen> createState() => _CommunitySettingsScreenState();
}

class _CommunitySettingsScreenState extends ConsumerState<CommunitySettingsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late bool _isPublic;
  String? _avatarUrl;
  bool _uploadingAvatar = false;
  bool _groupChatEnabled = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descController = TextEditingController(text: widget.initialDescription);
    _isPublic = widget.initialIsPublic;
    _avatarUrl = widget.initialAvatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (picked == null || !mounted) return;
    setState(() => _uploadingAvatar = true);
    try {
      final dio = ref.read(apiClientProvider4).dio;
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(picked.path, filename: picked.name),
      });
      final res = await dio.post('/messaging/upload/', data: form);
      final url = (res.data['data'] as Map<String, dynamic>)['url'] as String;
      setState(() => _avatarUrl = url);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image upload failed')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(communityFeedProvider(widget.communityId).notifier).updateSettings(
        name,
        _descController.text.trim(),
        _isPublic,
        groupAvatarUrl: _avatarUrl,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully.')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save settings: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteCommunity() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Community'),
        content: const Text(
          'Are you sure you want to permanently delete this community? All posts, members, and chat history will be removed.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: BuddyColors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await ref.read(communityFeedProvider(widget.communityId).notifier).leave();
        if (mounted) {
          context.go('/feed');
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Settings'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save', style: TextStyle(color: BuddyColors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Community Banner / Cover Picker
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Select cover photo from gallery.')),
              );
            },
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 32, color: cs.onSurface.withValues(alpha: 0.6)),
                    const SizedBox(height: 6),
                    Text('Change Cover Photo', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7), fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Profile picture
          Center(
            child: GestureDetector(
              onTap: _uploadingAvatar ? null : _pickAndUploadAvatar,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: cs.surfaceContainerHighest,
                    backgroundImage: (_avatarUrl?.isNotEmpty ?? false) ? NetworkImage(_avatarUrl!) : null,
                    child: (_avatarUrl?.isEmpty ?? true)
                        ? Icon(Icons.groups, size: 40, color: cs.onSurface.withValues(alpha: 0.6))
                        : _uploadingAvatar
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: BuddyColors.green, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, size: 16, color: BuddyColors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Name
          TextFormField(
            controller: _nameController,
            style: TextStyle(color: cs.onSurface),
            decoration: const InputDecoration(
              labelText: 'Community Name',
              hintText: 'e.g. Nairobi Runners Club',
            ),
          ),
          const SizedBox(height: 16),

          // Description
          TextFormField(
            controller: _descController,
            style: TextStyle(color: cs.onSurface),
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'What is this community about?',
            ),
          ),
          const SizedBox(height: 20),

          // Switches
          SwitchListTile(
            title: const Text('Public Community'),
            subtitle: const Text('Anyone can discover and join without invite code'),
            value: _isPublic,
            activeThumbColor: BuddyColors.green,
            onChanged: (v) => setState(() => _isPublic = v),
          ),
          SwitchListTile(
            title: const Text('Community Group Chat'),
            subtitle: const Text('Enable instant group messaging for members'),
            value: _groupChatEnabled,
            activeThumbColor: BuddyColors.green,
            onChanged: (v) => setState(() => _groupChatEnabled = v),
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          // Danger zone
          const Text('Danger Zone', style: TextStyle(color: BuddyColors.red, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: BuddyColors.red,
              side: const BorderSide(color: BuddyColors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.delete_forever),
            label: const Text('Delete Community'),
            onPressed: _deleteCommunity,
          ),
        ],
      ),
    );
  }
}
