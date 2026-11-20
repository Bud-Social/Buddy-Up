import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/toast.dart';
import '../../feed/providers/feed_provider.dart';
import '../providers/inbox_providers.dart';
import '../providers/messaging_provider.dart';

/// Post a story (an Instagram-style fullscreen moment) from the device.
class StoryCreateScreen extends ConsumerStatefulWidget {
  const StoryCreateScreen({super.key});

  @override
  ConsumerState<StoryCreateScreen> createState() => _StoryCreateScreenState();
}

class _StoryCreateScreenState extends ConsumerState<StoryCreateScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _caption = TextEditingController();
  XFile? _media;
  bool _isUploading = false;
  String? _error;
  String _visibility = 'public';

  static const _visibilityOptions = <String, String>{
    'public': 'Everyone',
    'buddies': 'Buddies only',
    'gym_members': 'Gym members',
    'private': 'Only me',
  };

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    setState(() => _error = null);
    try {
      final picked = source == ImageSource.camera
          ? await _picker.pickImage(source: ImageSource.camera, maxWidth: 1440, maxHeight: 1440, imageQuality: 82)
          : await _picker.pickMedia();
      if (picked == null) return;
      setState(() {
        _media = picked;
        _error = null;
      });
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not capture that media.');
    }
  }

  Future<void> _postStory() async {
    final media = _media;
    if (media == null || _isUploading) return;
    setState(() {
      _isUploading = true;
      _error = null;
    });
    try {
      // 1. Upload the media payload first.
      final dio = ref.read(apiClientProvider4).dio;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(media.path, filename: media.name),
      });
      final upload = await dio.post('/messaging/upload/', data: formData);
      final uploadData = upload.data is Map<String, dynamic> ? upload.data['data'] : null;
      final url = (uploadData is Map<String, dynamic> ? uploadData['url'] : null)?.toString();
      if (url == null || url.isEmpty) throw StateError('Upload returned no url');

      // 2. Compose the moment (story) post.
      final feedRepo = ref.read(feedRepositoryProvider);
      await feedRepo.createPost({
        'post_type': 'moment',
        'body': _caption.text.trim(),
        'media_urls': jsonEncode([url]),
        'visibility': _visibility,
      });

      // 3. Refresh the story strip / rails.
      ref.read(storiesProvider.notifier).load();
      if (mounted) {
        showToast(context, 'Story posted!', type: ToastType.success);
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/messages');
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Could not post your story. Try again.');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showVisibilityPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: BuddyColors.surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Who can see this story?',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            for (final entry in _visibilityOptions.entries)
              ListTile(
                leading: Icon(
                  entry.key == 'private' ? Icons.lock_outline : Icons.visibility_outlined,
                  color: BuddyColors.green,
                ),
                title: Text(entry.value, style: const TextStyle(color: Colors.white)),
                trailing: _visibility == entry.key
                    ? const Icon(Icons.check, color: BuddyColors.green)
                    : null,
                onTap: () {
                  setState(() => _visibility = entry.key);
                  Navigator.of(ctx).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(authProvider).profile;
    final media = _media;
    return Scaffold(
      backgroundColor: BuddyColors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Media preview or empty state
          if (media != null)
            Center(
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: media.mimeType?.startsWith('video/') == true
                    ? _VideoPreview(path: media.path)
                    : Image.file(File(media.path), fit: BoxFit.contain, width: double.infinity, height: double.infinity),
              ),
            )
          else
            _EmptyState(onPickCamera: () => _pick(ImageSource.camera), onPickGallery: () => _pick(ImageSource.gallery)),
          // Top bar
          SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                if (media != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    onPressed: () => setState(() => _media = null),
                  ),
              ],
            ),
          ),
          // Bottom composer
          if (media != null)
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.visibility_outlined, color: Colors.white70, size: 16),
                          const SizedBox(width: 6),
                          const Text('Who can see this story',
                              style: TextStyle(color: Colors.white70, fontSize: 12)),
                          const Spacer(),
                          TextButton(
                            onPressed: _showVisibilityPicker,
                            child: Text(
                              _visibilityOptions[_visibility] ?? 'Everyone',
                              style: const TextStyle(color: BuddyColors.green, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                    children: [
                      Avatar(src: profile?.avatarUrl, alt: profile?.displayName ?? 'You', size: AvatarSize.sm),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _caption,
                          maxLength: 200,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Add a caption…',
                            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                            counterText: '',
                            filled: true,
                            fillColor: Colors.white10,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: const BorderSide(color: BuddyColors.green, width: 1),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _PublishButton(busy: _isUploading, onTap: _postStory),
                    ],
                  ),
                    ],
                  ),
                ),
              ),
            ),
          if (_error != null)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 60, left: 24, right: 24),
                  child: Material(
                    color: Colors.red.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Text(_error!, style: const TextStyle(color: Colors.white, fontSize: 13)),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;
  const _EmptyState({required this.onPickCamera, required this.onPickGallery});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt_outlined, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          const Text('Share a moment',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Your story disappears after 24 hours.',
              style: TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: onPickCamera,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take photo / video'),
            style: ElevatedButton.styleFrom(
              backgroundColor: BuddyColors.green,
              foregroundColor: BuddyColors.black,
              minimumSize: const Size(0, 48),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onPickGallery,
            icon: const Icon(Icons.photo_library),
            label: const Text('Pick from gallery'),
            style: OutlinedButton.styleFrom(
              foregroundColor: BuddyColors.textPrimary,
              minimumSize: const Size(0, 48),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoPreview extends StatelessWidget {
  final String path;
  const _VideoPreview({required this.path});

  @override
  Widget build(BuildContext context) {
    // MVP: surface the file path for the user to understand this is a video.
    // The actual playback for stories in the strip is handled by StoryViewer.
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_circle_outline, size: 64, color: Colors.white54),
              const SizedBox(height: 12),
              Text(path.split('/').last, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

class _PublishButton extends StatelessWidget {
  final bool busy;
  final VoidCallback onTap;
  const _PublishButton({required this.busy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: FloatingActionButton(
        heroTag: 'publish-story',
        backgroundColor: BuddyColors.green,
        onPressed: busy ? null : onTap,
        child: busy
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: BuddyColors.black))
            : const Icon(Icons.check, color: BuddyColors.black),
      ),
    );
  }
}


