import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/feed_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/constants.dart';
import '../../../data/models/post.dart';

class PostComposerScreen extends ConsumerStatefulWidget {
  const PostComposerScreen({super.key});

  @override
  ConsumerState<PostComposerScreen> createState() => _PostComposerScreenState();
}

class _PostComposerScreenState extends ConsumerState<PostComposerScreen> {
  final TextEditingController _bodyController = TextEditingController();
  final List<String> _mediaUrls = [];
  String _postType = 'text';
  String _visibility = 'public';
  String? _gymTag;
  String? _locationLabel;
  final List<String> _pollOptions = ['', ''];
  String _pollQuestion = '';
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canPost = _postType == 'poll'
        ? _pollQuestion.isNotEmpty && _pollOptions.where((o) => o.isNotEmpty).length >= 2
        : _postType == 'text'
            ? _bodyController.text.trim().isNotEmpty
            : _bodyController.text.trim().isNotEmpty || _mediaUrls.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: canPost ? _submitPost : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text('Post'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeSelector(),
            const SizedBox(height: 16),
            if (_postType != 'poll') ...[
              TextField(
                controller: _bodyController,
                maxLines: 8,
                maxLength: maxPostBodyLength,
                style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: "What's on your mind?",
                  hintStyle: TextStyle(color: BuddyColors.textSecondary),
                  border: InputBorder.none,
                  counterStyle: TextStyle(color: BuddyColors.textSecondary),
                ),
              ),
            ],
            if (_mediaUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _mediaUrls.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _mediaUrls[i],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 100, height: 100,
                            color: BuddyColors.surface,
                            child: const Icon(Icons.broken_image, color: BuddyColors.textSecondary),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4, right: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => _mediaUrls.removeAt(i)),
                          child: Container(
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black54),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (_postType == 'poll') _buildPollBuilder(),
            const SizedBox(height: 16),
            const Divider(),
            _buildOptionTile(Icons.photo_library, 'Add media', _pickMedia),
            _buildOptionTile(Icons.push_pin, 'Add location', _pickLocation),
            _buildOptionTile(Icons.fitness_center, 'Tag gym', _pickGym),
            _buildOptionTile(
              Icons.visibility,
              'Visibility: $_visibility',
              _pickVisibility,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    final types = [
      ('text', Icons.text_fields, 'Text'),
      ('photo', Icons.photo, 'Photo'),
      ('video', Icons.videocam, 'Video'),
      ('poll', Icons.poll, 'Poll'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: types.map((t) {
          final isActive = _postType == t.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(t.$3),
              selected: isActive,
              onSelected: (_) => setState(() => _postType = t.$1),
              selectedColor: BuddyColors.green.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isActive ? BuddyColors.green : BuddyColors.textSecondary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPollBuilder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          style: const TextStyle(color: BuddyColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Ask a question...',
            hintStyle: TextStyle(color: BuddyColors.textSecondary),
          ),
          onChanged: (v) => _pollQuestion = v,
        ),
        const SizedBox(height: 12),
        ...List.generate(_pollOptions.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: BuddyColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Option ${i + 1}',
                      hintStyle: const TextStyle(color: BuddyColors.textSecondary),
                    ),
                    onChanged: (v) => setState(() => _pollOptions[i] = v),
                  ),
                ),
                if (_pollOptions.length > 2)
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: BuddyColors.red, size: 20),
                    onPressed: () => setState(() => _pollOptions.removeAt(i)),
                  ),
              ],
            ),
          );
        }),
        if (_pollOptions.length < maxPollOptions)
          TextButton.icon(
            onPressed: () => setState(() => _pollOptions.add('')),
            icon: const Icon(Icons.add),
            label: const Text('Add option'),
          ),
      ],
    );
  }

  Widget _buildOptionTile(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: BuddyColors.textSecondary, size: 22),
      title: Text(label, style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, color: BuddyColors.textSecondary, size: 20),
      onTap: onTap,
    );
  }

  void _pickMedia() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _mediaUrls.add(picked.path));
    }
  }

  void _pickLocation() {
    setState(() => _locationLabel = 'Somewhere');
  }

  void _pickGym() {
    setState(() => _gymTag = 'gym');
  }

  void _pickVisibility() {
    showModalBottomSheet(
      context: context,
      backgroundColor: BuddyColors.surface,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: visibilityOptions.map((opt) {
          return ListTile(
            title: Text(opt, style: const TextStyle(color: BuddyColors.textPrimary)),
            trailing: _visibility == opt
                ? const Icon(Icons.check, color: BuddyColors.green)
                : null,
            onTap: () {
              setState(() => _visibility = opt);
              Navigator.of(context).pop();
            },
          );
        }).toList(),
      ),
    );
  }

  void _submitPost() async {
    final repo = ref.read(feedRepositoryProvider);
    try {
      final data = <String, dynamic>{
        'post_type': _postType,
        'body': _bodyController.text.trim(),
        'visibility': _visibility,
      };
      if (_gymTag != null) data['gym_tag'] = _gymTag;
      if (_locationLabel != null) data['location_label'] = _locationLabel;
      if (_postType == 'poll') {
        data['poll_question'] = _pollQuestion;
        data['poll_options'] = _pollOptions.where((o) => o.isNotEmpty).toList();
      }

      final raw = await repo.createPost(data);
      final post = Post.fromJson(raw['data'] as Map<String, dynamic>);
      ref.read(feedProvider.notifier).addPostToTop(post);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create post: $e')),
        );
      }
    }
  }
}
