import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/upload/cloudinary_uploader.dart';
import '../../../core/utils/constants.dart';
import '../../../data/models/post.dart';
import '../../community/providers/community_provider.dart';
import '../../marketplace/providers/marketplace_provider.dart';
import '../providers/feed_provider.dart';
import 'location_picker_screen.dart';
import 'video_studio_screen.dart';

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

  // Video studio results (trim + sound), persisted into the media JSON.
  final int trimStartMs;
  final int trimEndMs;
  final String? soundId;
  final double? soundVolume;

  const ComposerMedia({
    this.path = '',
    required this.name,
    required this.type,
    this.bytes,
    this.trimStartMs = 0,
    this.trimEndMs = 0,
    this.soundId,
    this.soundVolume,
  });

  ComposerMedia copyWith({
    String? path,
    String? name,
    String? type,
    Uint8List? bytes,
    int? trimStartMs,
    int? trimEndMs,
    String? soundId,
    double? soundVolume,
  }) {
    return ComposerMedia(
      path: path ?? this.path,
      name: name ?? this.name,
      type: type ?? this.type,
      bytes: bytes ?? this.bytes,
      trimStartMs: trimStartMs ?? this.trimStartMs,
      trimEndMs: trimEndMs ?? this.trimEndMs,
      soundId: soundId ?? this.soundId,
      soundVolume: soundVolume ?? this.soundVolume,
    );
  }
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
  bool _pollAllowMultiple = false;
  int _pollMinSelections = 1;
  int _pollMaxSelections = 2;

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

  // Direct-upload state (Cloudinary) — per-item progress for the UI.
  final Map<int, double> _uploadProgress = {};
  String _uploadStatus = '';

  // Studio audience result.
  bool _commentsEnabled = true;

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
  // TikTok-style publish stages: Finalizing → Uploading (overall %) → Creating.
  String _publishStage = '';
  double _overallProgress = 0;

  String? _serverDraftId;
  Timer? _draftDebounce;

  @override
  void initState() {
    super.initState();
    _pollOptionControllers.addAll([TextEditingController(), TextEditingController()]);
    _restoreServerDraftIfAny();
    // Per-account draft sync (mirrors the web composer).
    _bodyController.addListener(_scheduleDraftSave);
    _pollQuestionController.addListener(_scheduleDraftSave);
  }

  Future<void> _restoreServerDraftIfAny() async {
    try {
      final repo = ref.read(feedRepositoryProvider);
      final raw = await repo.getDrafts();
      final drafts = (raw['data'] as List? ?? []);
      if (drafts.isEmpty) return;
      final latest = Draft.fromJson(drafts.first as Map<String, dynamic>);
      if (!mounted) return;
      final hasContent = (latest.body.trim()).isNotEmpty ||
          latest.pollQuestion.trim().isNotEmpty ||
          latest.locationLabel.trim().isNotEmpty ||
          latest.mediaUrls.isNotEmpty;
      if (!hasContent) return;
      final restore = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: BuddyColors.surface,
          title: const Text('Restore draft?'),
          content: Text(
            'You have an unfinished ${latest.postType == 'poll' ? 'poll' : latest.postType} post'
            '${latest.body.isNotEmpty ? ': "${latest.body.characters.take(60)}"' : '.'}',
            style: const TextStyle(color: BuddyColors.textSecondary),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Discard')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: BuddyColors.green, foregroundColor: BuddyColors.black),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Restore'),
            ),
          ],
        ),
      );
      if (restore != true || !mounted) {
        if (latest.id != null) await repo.deleteDraft(latest.id!);
        return;
      }
      _serverDraftId = latest.id;
      // Restore studio media whose local files still exist.
      final restoredMedia = <ComposerMedia>[];
      for (final entry in latest.mediaUrls) {
        if (!entry.trim().startsWith('{')) continue;
        try {
          final decoded = jsonDecode(entry) as Map<String, dynamic>;
          final list = decoded['buddyup_media'] as List? ?? [];
          for (final raw in list) {
            final map = raw as Map<String, dynamic>;
            final path = (map['path'] ?? '') as String;
            if (path.isEmpty || !File(path).existsSync()) continue;
            restoredMedia.add(ComposerMedia(
              path: path,
              name: (map['name'] ?? '') as String,
              type: (map['type'] ?? 'image') as String,
              trimStartMs: (map['trim_start_ms'] ?? 0) as int,
              trimEndMs: (map['trim_end_ms'] ?? 0) as int,
              soundId: map['sound_id'] as String?,
              soundVolume: (map['sound_volume'] as num?)?.toDouble(),
            ));
          }
        } catch (_) {}
      }
      setState(() {
        if (restoredMedia.isNotEmpty) _media.addAll(restoredMedia);
        _postType = latest.postType;
        _bodyController.text = latest.body;
        _visibility = latest.visibility;
        _locationLabel = latest.locationLabel;
        _locationLat = latest.locationLat?.toString();
        _locationLng = latest.locationLng?.toString();
        _pollAllowMultiple = latest.pollAllowMultiple;
        _pollMinSelections = latest.pollMinSelections;
        _pollMaxSelections = latest.pollMaxSelections < 2 ? 2 : latest.pollMaxSelections;
        if (latest.pollQuestion.isNotEmpty) {
          _pollQuestionController.text = latest.pollQuestion;
        }
        // Rebuild option controllers to match the saved poll shape.
        for (final c in _pollOptionControllers) { c.dispose(); }
        _pollOptionControllers
          ..clear()
          ..addAll(latest.pollOptions.map((t) => TextEditingController(text: t)));
        while (_pollOptionControllers.length < 2) {
          _pollOptionControllers.add(TextEditingController());
        }
      });
    } catch (_) {}
  }

  void _scheduleDraftSave() {
    _draftDebounce?.cancel();
    _draftDebounce = Timer(const Duration(seconds: 2), () async {
      try {
        final filledOptions = _pollOptionControllers
            .where((c) => c.text.trim().isNotEmpty)
            .map((c) => c.text.trim())
            .toList();
        final hasContent = _bodyController.text.trim().isNotEmpty ||
            _pollQuestionController.text.trim().isNotEmpty;
        if (!hasContent) return;
        final repo = ref.read(feedRepositoryProvider);
        final res = await repo.saveDraft(Draft(
          id: _serverDraftId,
          postType: _postType,
          body: _bodyController.text.trim(),
          visibility: _visibility,
          locationLabel: _locationLabel,
          locationLat: double.tryParse(_locationLat ?? ''),
          locationLng: double.tryParse(_locationLng ?? ''),
          pollQuestion: _pollQuestionController.text.trim(),
          pollOptions: filledOptions,
          pollAllowMultiple: _pollAllowMultiple,
          pollMinSelections: _pollMinSelections,
          pollMaxSelections: _pollMaxSelections,
          // Persist studio media (paths + trim/sound metadata) as a JSON
          // entry inside mediaUrls so the draft survives app restarts.
          mediaUrls: _media.isEmpty
              ? const <String>[]
              : <String>[
                  jsonEncode({
                    'buddyup_media': _media
                        .map((m) => {
                              'path': m.path,
                              'name': m.name,
                              'type': m.type,
                              'trim_start_ms': m.trimStartMs,
                              'trim_end_ms': m.trimEndMs,
                              'sound_id': m.soundId,
                              'sound_volume': m.soundVolume,
                            })
                        .toList(),
                  }),
                ],
        ));
        final savedId = (res['data'] as Map<String, dynamic>?)?['id'] as String?;
        if (savedId != null) _serverDraftId = savedId;
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _draftDebounce?.cancel();
    _bodyController.removeListener(_scheduleDraftSave);
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
          final item = ComposerMedia(path: file.path, name: file.name, type: 'video');
          if (!mounted) return;
          // Route through the studio for trim → sound → audience steps.
          final result = await Navigator.of(context).push<VideoStudioResult>(
            MaterialPageRoute(
              builder: (_) => VideoStudioScreen(
                video: item,
                initialVisibility: _visibility,
              ),
            ),
          );
          if (!mounted || result == null) return;
          setState(() {
            _media.add(item.copyWith(
              trimStartMs: result.trimStartMs,
              trimEndMs: result.trimEndMs,
              soundId: result.soundId,
              soundVolume: result.soundVolume,
            ));
            _visibility = result.visibility;
            _commentsEnabled = result.commentsEnabled;
          });
        }
        break;
      case 'file':
      case 'document':
        final result = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: _docExtensions,
        );
        for (final f in result.take(remaining)) {
          // file_picker v3 platform interface exposes content via xFile.
          final bytes = await f.xFile.readAsBytes();
          if (!mounted) return;
          setState(() {
            _media.add(ComposerMedia(
              path: f.path ?? '',
              name: f.name,
              type: f.path == null ? 'document' : _mediaKind,
              bytes: bytes,
            ));
          });
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
    int publishedMediaCount = 0;
    String? publishedSoundId;
    if (_gymTag != null) data['gym_tag'] = _gymTag;
    if (_locationLabel.isNotEmpty) {
      data['location_label'] = _locationLabel;
      if (_locationLat != null) data['location_lat'] = _locationLat;
      if (_locationLng != null) data['location_lng'] = _locationLng;
    }

    if (_postType == 'poll') {
      final filled = _pollOptionControllers.where((c) => c.text.trim().isNotEmpty).length;
      data['poll_question'] = _pollQuestionController.text.trim();
      data['poll_options'] =
          _pollOptionControllers.where((c) => c.text.trim().isNotEmpty).map((c) => c.text.trim()).toList();
      data['poll_allow_multiple'] = '$_pollAllowMultiple';
      if (_pollAllowMultiple) {
        final maxSel = _pollMaxSelections < 2 ? 2 : (_pollMaxSelections > filled ? filled : _pollMaxSelections);
        data['poll_min_selections'] =
            '${_pollMinSelections < 1 ? 1 : (_pollMinSelections > maxSel ? maxSel : _pollMinSelections)}';
        data['poll_max_selections'] = '$maxSel';
      }
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
      final uploadable =
          _media.isNotEmpty && !_media.any((m) => m.type == 'file' || m.type == 'document');
      data['comments_disabled'] = '$_commentsEnabled';
      var mediaJson = const <Map<String, dynamic>>[];
      if (uploadable) {
        mediaJson = await _uploadMediaViaCloudinary();
        if (!mounted) return;
      }
      if (mediaJson.isNotEmpty) {
        // Direct Cloudinary upload succeeded — submit the media JSON.
        data['media'] = jsonEncode(mediaJson);
        publishedMediaCount = mediaJson.length;
        publishedSoundId = _media
            .map((m) => m.soundId)
            .firstWhere((s) => s != null, orElse: () => null);
      } else {
        // Legacy multipart fallback (sign unavailable / upload failed).
        data['media'] = _media.map(_fileToMultipart).toList();
      }
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
      AnalyticsService.instance.track(
        'create.published',
        surface: 'composer_studio',
        objectType: 'post',
        objectId: post.id,
        properties: {
          'post_type': _postType,
          'media_count': publishedMediaCount,
          'sound_id': ?publishedSoundId,
        },
      );
      widget.onPostCreated?.call();
      if (_serverDraftId != null) {
        try { await repo.deleteDraft(_serverDraftId!); } catch (_) {}
        _serverDraftId = null;
      }
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

  /// TikTok-style publish pipeline:
  /// 1. *Finalizing* — video compression runs once here, before any upload.
  /// 2. *Uploading* — signed Cloudinary uploads with a byte-weighted overall
  ///    percentage across all items.
  /// Returns the media JSON entries, or an empty list when signing is
  /// unavailable (503) or anything fails — callers fall back to multipart.
  Future<List<Map<String, dynamic>>> _uploadMediaViaCloudinary() async {
    final uploader = CloudinaryUploader(ref.read(apiClientProvider).dio);
    final uploaded = <Map<String, dynamic>>[];
    try {
      // ── Stage 1: Finalizing (compression, before any upload) ─────────────
      if (mounted) {
        setState(() {
          _publishStage = 'finalizing';
          _uploadStatus = 'Finalizing your edits…';
        });
      }
      final prepared = <({ComposerMedia m, File file, int? width, int? height})>[];
      var totalBytes = 0;
      for (final m in _media) {
        final isVideo = m.type == 'video';
        var file = File(m.path);
        int? width;
        int? height;
        if (isVideo) {
          final prep = await uploader.prepareVideo(file);
          file = prep.file;
          width = prep.width;
          height = prep.height;
        }
        if (file.existsSync()) totalBytes += file.lengthSync();
        prepared.add((m: m, file: file, width: width, height: height));
      }

      // ── Stage 2: Uploading (byte-weighted overall percentage) ────────────
      if (mounted) {
        setState(() {
          _publishStage = 'uploading';
          _overallProgress = 0;
        });
      }
      var sentBefore = 0;
      for (var i = 0; i < prepared.length; i++) {
        final (:m, :file, width: finalWidth, height: finalHeight) = prepared[i];
      var width = finalWidth;
      var height = finalHeight;
        if (mounted) {
          setState(() => _uploadStatus = 'Uploading ${m.name}… (${i + 1}/${prepared.length})');
        }
        final sign = await uploader.sign(
          resourceType: m.type == 'video' ? 'video' : 'image',
          filename: m.name,
        );
        if (sign == null) return const [];

        final res = await uploader.upload(
          file: file,
          sign: sign,
          onProgress: (sent, total) {
            if (!mounted || total <= 0) return;
            setState(() => _uploadProgress[i] = sent / total);
            if (totalBytes > 0) {
              setState(() =>
                  _overallProgress = (sentBefore + sent).clamp(0, totalBytes) / totalBytes);
            }
          },
        );
        sentBefore += file.existsSync() ? file.lengthSync() : 0;
        if (m.type == 'video') {
          width = res.width ?? width;
          height = res.height ?? height;
        }

        uploaded.add(<String, dynamic>{
          'url': res.url,
          'media_type': m.type == 'video' ? 'video' : 'image',
          'width': ?width,
          'height': ?height,
          if (res.durationMs != null) 'duration_ms': res.durationMs,
          'poster_url': ?res.posterUrl,
          if (m.type == 'video' && m.trimStartMs > 0) 'trim_start_ms': m.trimStartMs,
          if (m.type == 'video' && m.trimEndMs > 0) 'trim_end_ms': m.trimEndMs,
          'sound_id': ?m.soundId,
          'sound_volume': ?m.soundVolume,
        });
        AnalyticsService.instance.track(
          'upload.completed',
          surface: 'composer_studio',
          objectType: 'media',
          objectId: m.name,
          properties: {
            'media_type': m.type == 'video' ? 'video' : 'image',
            if (res.durationMs != null) 'duration_ms': res.durationMs,
          },
        );
      }
      return uploaded;
    } catch (e) {
      debugPrint('direct upload failed, falling back to multipart: $e');
      return const [];
    } finally {
      if (mounted) {
        setState(() {
          _uploadStatus = '';
          _publishStage = '';
          _overallProgress = 0;
        });
      }
    }
  }

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
        CheckboxListTile(
          value: _pollAllowMultiple,
          activeColor: BuddyColors.green,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          title: const Text('Allow multiple selections',
              style: TextStyle(color: BuddyColors.textPrimary, fontSize: 14)),
          onChanged: (on) {
            setState(() {
              _pollAllowMultiple = on ?? false;
              if (_pollAllowMultiple) {
                if (_pollMaxSelections < 2) _pollMaxSelections = 2;
                _pollMinSelections = 1;
              }
            });
          },
        ),
        if (_pollAllowMultiple) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BuddyColors.surfaceRaised.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _buildPollBoundStepper('Minimum choices', _pollMinSelections, 1,
                    (v) => setState(() => _pollMinSelections = v)),
                const SizedBox(height: 8),
                _buildPollBoundStepper('Maximum choices', _pollMaxSelections, 2,
                    (v) => setState(() => _pollMaxSelections = v)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPollBoundStepper(String label, int value, int floor, void Function(int) onChanged) {
    final filled = _pollOptionControllers.where((c) => c.text.trim().isNotEmpty).length;
    final ceiling = filled > floor ? filled : floor;
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 13))),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, size: 20),
          color: value <= floor ? BuddyColors.textSecondary : BuddyColors.green,
          onPressed: value <= floor ? null : () => onChanged(value - 1),
        ),
        Text('$value',
            style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 20),
          color: value >= ceiling ? BuddyColors.textSecondary : BuddyColors.green,
          onPressed: value >= ceiling ? null : () => onChanged(value + 1),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) => _buildSmallThumb(
              items[i],
              () => onRemove(i),
              progress: _uploadProgress[i],
            ),
          ),
        ),
        if (_uploadStatus.isNotEmpty) ...[
          const SizedBox(height: 6),
          if (_publishStage == 'uploading') ...[
            // Overall percentage across all items (byte-weighted).
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _overallProgress,
                      minHeight: 5,
                      backgroundColor: BuddyColors.surfaceRaised,
                      color: BuddyColors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${(_overallProgress * 100).round()}%',
                  style: const TextStyle(
                    color: BuddyColors.green,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          Row(
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _uploadStatus,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: BuddyColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSmallThumb(ComposerMedia m, VoidCallback onRemove, {double? progress}) {
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
        if (progress != null)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
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