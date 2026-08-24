import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/constants.dart';
import '../../../data/models/post.dart';
import '../../community/providers/community_provider.dart';
import '../../marketplace/providers/marketplace_provider.dart';
import '../providers/feed_provider.dart';
import 'location_picker_screen.dart';

const List<({String key, String label})> _mealTypes = [
  (key: 'breakfast', label: 'Breakfast'),
  (key: 'lunch', label: 'Lunch'),
  (key: 'dinner', label: 'Dinner'),
  (key: 'snack', label: 'Snack'),
  (key: 'drink', label: 'Drink'),
  (key: 'other', label: 'Other'),
];

const List<String> _docExtensions = [
  'pdf', 'doc', 'docx', 'xls', 'xlsx',
  'ppt', 'pptx', 'txt', 'csv', 'md', 'zip',
];

/// A locally-picked attachment ready to be uploaded with a post.
class ComposerMedia {
  final String path;
  final String name;
  final String type; // image | video | file | document
  final Uint8List? bytes;

  const ComposerMedia({
    this.path = '',
    required this.name,
    required this.type,
    this.bytes,
  });
}

class PostComposerScreen extends ConsumerStatefulWidget {
  final String? communityId;
  final String? communityName;
  final VoidCallback? onPostCreated;

  const PostComposerScreen({
    super.key,
    this.communityId,
    this.communityName,
    this.onPostCreated,
  });

  @override
  ConsumerState<PostComposerScreen> createState() => _PostComposerScreenState();
}

class _PostComposerScreenState extends ConsumerState<PostComposerScreen> {
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _mealDescController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _pollQuestionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<TextEditingController> _pollOptionControllers = [];

  static const int _maxMedia = 12;

  String _postType = 'text';
  String _visibility = 'public';
  String? _gymTag;

  // Location (label + coordinates are all submitted together).
  String _locationLabel = '';
  String? _locationLat;
  String? _locationLng;

  // Media attachments (text / photo / video kinds)
  String _mediaKind = 'image';
  final List<ComposerMedia> _media = [];

  // Meal
  String _mealType = 'breakfast';
  final List<ComposerMedia> _mealPhotos = [];
  bool _analyzingMeal = false;

  // Progress
  String _weightUnit = 'kg';
  String _progressMode = 'transformation';
  final List<ComposerMedia> _beforePhotos = [];
  final List<ComposerMedia> _afterPhotos = [];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _pollOptionControllers.addAll([TextEditingController(), TextEditingController()]);
  }

  @override
  void dispose() {
    _bodyController.dispose();
    _foodController.dispose();
    _mealDescController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _weightController.dispose();
    _pollQuestionController.dispose();
    for (final c in _pollOptionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _canPost {
    switch (_postType) {
      case 'poll':
        return _pollQuestionController.text.trim().isNotEmpty &&
            _pollOptionControllers.where((c) => c.text.trim().isNotEmpty).length >= 2;
      case 'meal':
        return _foodController.text.trim().isNotEmpty ||
            _caloriesController.text.trim().isNotEmpty ||
            _mealPhotos.isNotEmpty;
      case 'progress':
        return _weightController.text.trim().isNotEmpty ||
            _beforePhotos.isNotEmpty ||
            _afterPhotos.isNotEmpty;
      default:
        return _bodyController.text.trim().isNotEmpty ||
            _media.isNotEmpty ||
            _locationLabel.isNotEmpty;
    }
  }

  // ── Media picking ────────────────────────────────────────────────────────

  Future<void> _addMedia() async {
    final remaining = _maxMedia - _media.length;
    if (remaining <= 0) {
      _snack('You can attach up to $_maxMedia files.');
      return;
    }
    switch (_mediaKind) {
      case 'video':
        final file = await _picker.pickVideo(source: ImageSource.gallery);
        if (file != null) {
          setState(() => _media.add(ComposerMedia(path: file.path, name: file.name, type: 'video')));
        }
        break;
      case 'file':
      case 'document':
        final result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.custom,
          allowedExtensions: _docExtensions,
        );
        if (result != null) {
          for (final f in result.files.take(remaining)) {
            setState(() {
              _media.add(ComposerMedia(
                path: f.path ?? '',
                name: f.name,
                type: f.path == null ? 'document' : _mediaKind,
                bytes: f.bytes,
              ));
            });
          }
        }
        break;
      default: // image
        final files = await _picker.pickMultiImage(imageQuality: 85);
        for (final f in files.take(remaining)) {
          setState(() => _media.add(ComposerMedia(path: f.path, name: f.name, type: 'image')));
        }
    }
  }

  Future<void> _addMealPhotos() async {
    final files = await _picker.pickMultiImage(imageQuality: 85);
    if (files.isEmpty) return;
    for (final f in files) {
      setState(() => _mealPhotos.add(ComposerMedia(path: f.path, name: f.name, type: 'image')));
    }
    if (_foodController.text.trim().isEmpty || _caloriesController.text.trim().isEmpty) {
      await _analyzeMealPhoto(files.first);
    }
  }

  Future<void> _analyzeMealPhoto(XFile file) async {
    setState(() => _analyzingMeal = true);
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      final form = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(file.path, filename: file.name),
      });
      final raw = await repo.recognizeFood(form);
      final data = raw['data'];
      if (data is Map<String, dynamic>) {
        _applyMealAnalysis(data);
      }
    } catch (_) {
      // food analyser unavailable – leave fields manual
    } finally {
      if (mounted) setState(() => _analyzingMeal = false);
    }
  }

  void _applyMealAnalysis(Map<String, dynamic> data) {
    final items = data['items'];
    Map<String, dynamic>? first = items is List && items.isNotEmpty && items.first is Map
        ? (items.first as Map).cast<String, dynamic>()
        : null;
    final nutrition = first?['nutrition'];
    final n = nutrition is Map ? nutrition.cast<String, dynamic>() : null;

    final itemName = first?['item'] as String?;
    final totalCal = data['total_calories'] ?? n?['calories'];
    final totalProtein = data['total_protein'] ?? n?['protein'];
    final totalCarbs = data['total_carbs'] ?? n?['carbs'];
    final totalFat = data['total_fat'] ?? n?['fat'];

    if (itemName != null && itemName.isNotEmpty && _foodController.text.trim().isEmpty) {
      _foodController.text = itemName;
    }
    void fill(TextEditingController c, dynamic v) {
      if (c.text.trim().isEmpty && v is num) {
        c.text = v.toStringAsFixed(1);
      }
    }

    final any = totalCal ?? totalProtein ?? totalCarbs ?? totalFat ?? itemName;
    if (!mounted) return;
    if (any != null) {
      fill(_caloriesController, totalCal);
      fill(_proteinController, totalProtein);
      fill(_carbsController, totalCarbs);
      fill(_fatController, totalFat);
      _snack('Nutrition detected — review before sharing.', error: false);
    } else {
      _snack('Could not analyze the meal photo. Enter details manually.');
    }
  }

  Future<void> _addProgressPhoto({required bool before}) async {
    final files = await _picker.pickMultiImage(imageQuality: 85);
    for (final f in files) {
      setState(() {
        final item = ComposerMedia(path: f.path, name: f.name, type: 'image');
        if (before) {
          _beforePhotos.add(item);
        } else {
          _afterPhotos.add(item);
        }
      });
    }
  }

  // ── Location ─────────────────────────────────────────────────────────────

  Future<void> _pickLocation() async {
    final result = await Navigator.of(context).push<LocationResult>(
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (result == null) return;
    setState(() {
      _locationLabel = result.label;
      _locationLat = result.lat?.toString();
      _locationLng = result.lng?.toString();
    });
  }

  // ── Visibility ───────────────────────────────────────────────────────────

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

  // ── Submit ───────────────────────────────────────────────────────────────

  dio.MultipartFile _fileToMultipart(ComposerMedia m) {
    if (m.path.isNotEmpty) {
      return dio.MultipartFile.fromFileSync(m.path, filename: m.name);
    }
    return dio.MultipartFile.fromBytes(m.bytes ?? const [], filename: m.name);
  }

  Future<void> _submitPost() async {
    if (!_canPost || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    final body = _bodyController.text.trim();
    final data = <String, dynamic>{
      'post_type': _postType,
      'body': body,
      'visibility': _visibility,
      'content_rating': 'general',
    };
    if (_gymTag != null) data['gym_tag'] = _gymTag;
    if (_locationLabel.isNotEmpty) {
      data['location_label'] = _locationLabel;
      if (_locationLat != null) data['location_lat'] = _locationLat;
      if (_locationLng != null) data['location_lng'] = _locationLng;
    }

    if (_postType == 'poll') {
      data['poll_question'] = _pollQuestionController.text.trim();
      data['poll_options'] =
          _pollOptionControllers.where((c) => c.text.trim().isNotEmpty).map((c) => c.text.trim()).toList();
      data['poll_allow_multiple'] = 'false';
    } else if (_postType == 'meal') {
      data['meal_data'] = jsonEncode({
        'meal_type': _mealType,
        'food_name': _foodController.text.trim(),
        'description': _mealDescController.text.trim(),
        'calories': _numOrNull(_caloriesController.text),
        'protein_g': _numOrNull(_proteinController.text),
        'carbs_g': _numOrNull(_carbsController.text),
        'fat_g': _numOrNull(_fatController.text),
      });
      data['media'] = _mealPhotos.map(_fileToMultipart).toList();
    } else if (_postType == 'progress') {
      data['progress_data'] = jsonEncode({
        'weight': _numOrNull(_weightController.text),
        'weight_unit': _weightUnit,
        'mode': _progressMode,
        'before_count': _beforePhotos.length,
      });
      data['media'] = [..._beforePhotos, ..._afterPhotos].map(_fileToMultipart).toList();
    } else {
      // text / photo / video
      data['media'] = _media.map(_fileToMultipart).toList();
    }

    try {
      if (widget.communityId != null && widget.communityId!.isNotEmpty) {
        String mediaUrl = '';
        if (_media.isNotEmpty) {
          mediaUrl = _media.first.path;
        }
        await ref.read(communityFeedProvider(widget.communityId!).notifier).createPost(body, mediaUrl: mediaUrl);
        widget.onPostCreated?.call();
        if (mounted) Navigator.of(context).pop();
        return;
      }

      final repo = ref.read(feedRepositoryProvider);
      final raw = await repo.createPost(data);
      final post = Post.fromJson(raw['data'] as Map<String, dynamic>);
      ref.read(feedProvider.notifier).addPostToTop(post);
      widget.onPostCreated?.call();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create post: $e')),
      );
    }
  }

  num? _numOrNull(String s) => num.tryParse(s.trim());

  void _snack(String message, {bool error = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? null : BuddyColors.green,
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.communityName != null ? 'Post to ${widget.communityName}' : 'Create Post'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: _canPost && !_isSubmitting ? _submitPost : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: Text(_isSubmitting ? 'Posting…' : 'Post'),
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
            if (_postType == 'poll') _buildPollBuilder(),
            if (_postType == 'meal') _buildMealForm(),
            if (_postType == 'progress') _buildProgressForm(),
            if (_postType != 'poll' && _postType != 'meal' && _postType != 'progress')
              _buildTextPost(),
            const SizedBox(height: 16),
            const Divider(),
            _buildOptionTile(
              Icons.push_pin,
              _locationLabel.isNotEmpty ? 'Location: $_locationLabel' : 'Add location',
              Icons.check_circle,
              () => _pickLocation(),
            ),
            _buildOptionTile(
              Icons.visibility,
              'Visibility: $_visibility',
              null,
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
      ('meal', Icons.restaurant, 'Meal'),
      ('progress', Icons.trending_up, 'Progress'),
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
              onSelected: (_) => setState(() {
                _postType = t.$1;
                if (t.$1 == 'photo') _mediaKind = 'image';
                if (t.$1 == 'video') _mediaKind = 'video';
              }),
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

  // Text / photo / video post with a media file-type selector and multi-file
  // gallery.
  Widget _buildTextPost() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        if (_media.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildMediaGallery(_media, (i) => setState(() => _media.removeAt(i))),
        ],
        const SizedBox(height: 12),
        _buildMediaKindPills(),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _addMedia,
          icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
          label: const Text('Add media'),
        ),
      ],
    );
  }

  Widget _buildMediaKindPills() {
    final kinds = [
      ('image', Icons.image_outlined, 'Photo'),
      ('video', Icons.videocam_outlined, 'Video'),
      ('file', Icons.insert_drive_file_outlined, 'File'),
      ('document', Icons.description_outlined, 'Doc'),
    ];
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: kinds.map((k) {
        final isActive = _mediaKind == k.$1;
        return ChoiceChip(
          avatar: Icon(k.$2, size: 16, color: isActive ? BuddyColors.green : BuddyColors.textSecondary),
          label: Text(k.$3),
          selected: isActive,
          onSelected: (_) => setState(() => _mediaKind = k.$1),
          selectedColor: BuddyColors.green.withValues(alpha: 0.2),
          labelStyle: TextStyle(
            color: isActive ? BuddyColors.green : BuddyColors.textPrimary,
            fontSize: 12,
          ),
          backgroundColor: BuddyColors.surfaceRaised,
          side: const BorderSide(color: BuddyColors.surfaceRaised),
        );
      }).toList(),
    );
  }

  Widget _buildPollBuilder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _pollQuestionController,
          style: const TextStyle(color: BuddyColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Ask a question...'),
        ),
        const SizedBox(height: 12),
        ...List.generate(_pollOptionControllers.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pollOptionControllers[i],
                    style: const TextStyle(color: BuddyColors.textPrimary),
                    decoration: InputDecoration(hintText: 'Option ${i + 1}'),
                  ),
                ),
                if (_pollOptionControllers.length > 2)
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: BuddyColors.red, size: 20),
                    onPressed: () {
                      final c = _pollOptionControllers.removeAt(i);
                      c.dispose();
                      setState(() {});
                    },
                  ),
              ],
            ),
          );
        }),
        if (_pollOptionControllers.length < maxPollOptions)
          TextButton.icon(
            onPressed: () {
              final c = TextEditingController();
              setState(() => _pollOptionControllers.add(c));
            },
            icon: const Icon(Icons.add),
            label: const Text('Add option'),
          ),
      ],
    );
  }

  Widget _buildMealForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _mealTypes
              .map((t) => ChoiceChip(
                    label: Text(t.label),
                    selected: _mealType == t.key,
                    onSelected: (_) => setState(() => _mealType = t.key),
                    selectedColor: BuddyColors.green.withValues(alpha: 0.25),
                    labelStyle: TextStyle(
                      color: _mealType == t.key
                          ? BuddyColors.green
                          : BuddyColors.textPrimary,
                      fontSize: 12,
                    ),
                    backgroundColor: BuddyColors.surfaceRaised,
                    side: const BorderSide(color: BuddyColors.surfaceRaised),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _foodController,
          style: const TextStyle(color: BuddyColors.textPrimary),
          decoration: const InputDecoration(labelText: 'Food name'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _mealDescController,
          maxLines: 2,
          style: const TextStyle(color: BuddyColors.textPrimary),
          decoration: const InputDecoration(labelText: 'Description (optional)'),
        ),
        const SizedBox(height: 12),
        if (_mealPhotos.isNotEmpty) ...[
          _buildMediaGallery(_mealPhotos, (i) => setState(() => _mealPhotos.removeAt(i))),
          const SizedBox(height: 8),
        ],
        GestureDetector(
          onTap: _analyzingMeal ? null : _addMealPhotos,
          child: Container(
            height: 96,
            decoration: BoxDecoration(
              color: BuddyColors.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: BuddyColors.border),
            ),
            child: _analyzingMeal
                ? const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: BuddyColors.green),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Analyzing meal…',
                          style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_camera_outlined, color: BuddyColors.textSecondary, size: 22),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Snap one or more photos to auto-fill nutrition',
                          style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _caloriesController,
                style: const TextStyle(color: BuddyColors.textPrimary),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Calories'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _proteinController,
                style: const TextStyle(color: BuddyColors.textPrimary),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Protein (g)'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _carbsController,
                style: const TextStyle(color: BuddyColors.textPrimary),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Carbs (g)'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _fatController,
                style: const TextStyle(color: BuddyColors.textPrimary),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Fat (g)'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'transformation', label: Text('Transformation')),
            ButtonSegment(value: 'milestone', label: Text('Milestone')),
          ],
          selected: {_progressMode},
          onSelectionChanged: (s) => setState(() => _progressMode = s.first),
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(BuddyColors.surface),
            foregroundColor: WidgetStatePropertyAll(BuddyColors.textPrimary),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _weightController,
                style: const TextStyle(color: BuddyColors.textPrimary),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Weight (optional)'),
              ),
            ),
            const SizedBox(width: 10),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'kg', label: Text('kg')),
                ButtonSegment(value: 'lbs', label: Text('lbs')),
              ],
              selected: {_weightUnit},
              onSelectionChanged: (s) => setState(() => _weightUnit = s.first),
              style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(BuddyColors.surfaceRaised),
                foregroundColor: WidgetStatePropertyAll(BuddyColors.textPrimary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildProgressBucket(
                title: 'BEFORE',
                color: BuddyColors.textSecondary,
                photos: _beforePhotos,
                onAdd: () => _addProgressPhoto(before: true),
                onRemove: (i) => setState(() => _beforePhotos.removeAt(i)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildProgressBucket(
                title: _progressMode == 'transformation' ? 'AFTER' : 'SNAP',
                color: BuddyColors.green,
                photos: _afterPhotos,
                onAdd: () => _addProgressPhoto(before: false),
                onRemove: (i) => setState(() => _afterPhotos.removeAt(i)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBucket({
    required String title,
    required Color color,
    required List<ComposerMedia> photos,
    required VoidCallback onAdd,
    required void Function(int) onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),
        if (photos.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(photos.length, (i) => _buildSmallThumb(photos[i], () => onRemove(i))),
          ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: BuddyColors.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: BuddyColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_a_photo, color: BuddyColors.textSecondary, size: 24),
                const SizedBox(height: 4),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaGallery(List<ComposerMedia> items, void Function(int) onRemove) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => _buildSmallThumb(items[i], () => onRemove(i)),
      ),
    );
  }

  Widget _buildSmallThumb(ComposerMedia m, VoidCallback onRemove) {
    Widget preview;
    if (m.type == 'image') {
      preview = m.path.isNotEmpty
          ? Image.file(File(m.path), width: 100, height: 100, fit: BoxFit.cover)
          : (m.bytes != null
                ? Image.memory(m.bytes!, width: 100, height: 100, fit: BoxFit.cover)
                : _fileThumb(m));
    } else if (m.type == 'video') {
      preview = Container(
        width: 100,
        height: 100,
        color: BuddyColors.surfaceRaised,
        child: const Center(child: Icon(Icons.play_circle_outline, color: BuddyColors.textSecondary, size: 36)),
      );
    } else {
      preview = _fileThumb(m);
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(width: 100, height: 100, child: preview),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black87),
              padding: const EdgeInsets.all(3),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fileThumb(ComposerMedia m) {
    return Container(
      width: 100,
      height: 100,
      padding: const EdgeInsets.all(8),
      color: BuddyColors.surfaceRaised,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            m.type == 'document'
                ? Icons.description_outlined
                : Icons.insert_drive_file_outlined,
            color: BuddyColors.textSecondary,
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(
            m.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String label, IconData? trailingIcon, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: BuddyColors.textSecondary, size: 22),
      title: Text(label, style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 14)),
      trailing: Icon(trailingIcon ?? Icons.chevron_right, color: BuddyColors.textSecondary, size: 20),
      onTap: onTap,
    );
  }
}