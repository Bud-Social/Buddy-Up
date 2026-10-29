import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:uuid/uuid.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/post.dart';
import '../../../shared/widgets/caption_overlay.dart';
import '../../../shared/widgets/creative_overlays.dart';
import '../../../shared/widgets/toast.dart';
import '../models/composer_media.dart';
import '../providers/feed_provider.dart';
import '../providers/sounds_provider.dart';

Color _parseColor(dynamic v, [Color fallback = Colors.white]) {
  if (v == null) return fallback;
  var h = v.toString().replaceAll('#', '');
  if (h.length == 6) h = 'FF$h';
  if (h.length != 8) return fallback;
  return Color(int.tryParse(h, radix: 16) ?? 0xFFFFFFFF);
}

Color _parseBgColor(dynamic v) {
  if (v == null || v == 'none') return Colors.transparent;
  return _parseColor(v, Colors.black.withValues(alpha: 0.15));
}

String _fmtMs(int ms) {
  final total = (ms / 1000).round();
  return '${total ~/ 60}:${(total % 60).toString().padLeft(2, '0')}';
}

/// One editable layer in the Bud Press studio: a photo, video, audio clip or
/// styled text block. Layers render in order and each keeps its own trim,
/// captions, overlays, cover offset, sound and edit metadata — exactly what
/// the backend ``media[]`` contract stores.
class StudioLayer {
  final ComposerMedia media;
  StudioLayer({required this.media});
}

/// Result of the studio: the edited layers (in order), visibility and whether
/// comments are enabled. The composer turns these into the publish payload.
class BudPressStudioResult {
  final List<ComposerMedia> layers;
  final String visibility;
  final bool commentsEnabled;

  const BudPressStudioResult({
    required this.layers,
    required this.visibility,
    required this.commentsEnabled,
  });
}

/// Bud Press creation studio — universal, layerable post editor.
///
/// Edits any mix of photos, videos, audio clips and styled text blocks as
/// layers on a strip. Every layer keeps its own trim, captions, overlays,
/// cover offset, sound and edit metadata, so a single post can be a photo
/// carousel, a video with a voice-over, a text-only story card, or any mix.
class BudPressStudioScreen extends ConsumerStatefulWidget {
  final List<ComposerMedia> initialLayers;
  final String initialVisibility;

  const BudPressStudioScreen({
    super.key,
    required this.initialLayers,
    this.initialVisibility = 'public',
  });

  @override
  ConsumerState<BudPressStudioScreen> createState() => _BudPressStudioScreenState();
}

class _BudPressStudioScreenState extends ConsumerState<BudPressStudioScreen> {
  late List<ComposerMedia> _layers;
  int _activeIndex = 0;
  String _tab = 'preview'; // preview | edit | captions | overlays | cover | audience
  String _visibility = 'public';
  bool _commentsEnabled = true;

  // Preview
  Player? _player;
  VideoController? _controller;
  StreamSubscription<Duration>? _positionSub;
  int _durationMs = 0;
  int _previewPositionMs = 0;
  bool _loopPreview = false;
  bool _isPlaying = false;

  TextEditingController _textBodyCtrl = TextEditingController(text: '');

  static const int _maxTrimMs = 180 * 1000;

  ComposerMedia get _active => _layers.isEmpty
      ? ComposerMedia(path: '', name: 'Untitled', type: 'text', studioItemId: const Uuid().v4())
      : _layers[_activeIndex];

  bool get _isVideo => _active.type == 'video';
  bool get _isPhoto => _active.type == 'image';
  bool get _isText => _active.type == 'text';
  bool get _isAudio => _active.type == 'audio';

  @override
  void initState() {
    super.initState();
    _layers = List<ComposerMedia>.from(widget.initialLayers);
    if (_layers.isEmpty) {
      _layers.add(ComposerMedia(path: '', name: 'Untitled', type: 'text', studioItemId: const Uuid().v4()));
    }
    _visibility = widget.initialVisibility;
    _textBodyCtrl = TextEditingController(text: _active.textContent ?? '');
    _textBodyCtrl.addListener(() {
      final layer = _layers[_activeIndex];
      _layers[_activeIndex] = layer.copyWith(textContent: _textBodyCtrl.text.trim());
    });
    AnalyticsService.instance.track(
      'create.started',
      surface: 'bud_press_studio',
      objectType: 'mixed',
      objectId: _active.name,
      properties: {'layer_count': _layers.length},
    );
    _setupPreview();
    if (_active.studioItemId != null) {
      _loadSavedCaptions();
    }
  }

  void _setupPreview() {
    _positionSub?.cancel();
    _player?.dispose();
    if (_isVideo && _active.path.isNotEmpty) {
      final player = Player();
      _player = player;
      _controller = VideoController(player);
      _positionSub = player.stream.position.listen((p) {
        if (!mounted) return;
        setState(() => _previewPositionMs = p.inMilliseconds);
        final end = _active.trimEndMs > _active.trimStartMs
            ? _active.trimEndMs
            : _durationMs;
        if (_loopPreview && end > _active.trimStartMs && p.inMilliseconds >= end) {
          player.seek(Duration(milliseconds: _active.trimStartMs));
        }
      });
      player.stream.duration.listen((d) {
        if (!mounted || d.inMilliseconds <= 0) return;
        setState(() {
          _durationMs = d.inMilliseconds;
          if (_active.trimEndMs == 0 || _active.trimEndMs > d.inMilliseconds) {
            _layers[_activeIndex] = _active.copyWith(trimEndMs: d.inMilliseconds);
          }
        });
      });
      player.open(Media(_active.path), play: false);
    } else {
      _player = null;
      _controller = null;
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _player?.dispose();
    _textBodyCtrl.dispose();
    super.dispose();
  }

  // ── layer management ──────────────────────────────────────────────────

  void _addLayer(String type) {
    final id = const Uuid().v4();
    ComposerMedia layer;
    switch (type) {
      case 'video':
      case 'image':
        layer = ComposerMedia(
          path: '', name: type == 'video' ? 'Video' : 'Photo', type: type,
          studioItemId: id,
        );
        break;
      case 'audio':
        layer = ComposerMedia(
          path: '', name: 'Audio', type: 'audio', studioItemId: id,
        );
        break;
      default: // text
        layer = ComposerMedia(
          path: '', name: 'Text', type: 'text',
          studioItemId: id,
          textContent: '',
          textStyle: {
            'background': 'none',
            'font': 'classic',
            'color': '#FFFFFF',
            'effect': 'none',
            'size': 1.0,
            'alignment': 'center',
          },
        );
    }
    setState(() {
      _layers.add(layer);
      _activeIndex = _layers.length - 1;
      _textBodyCtrl = TextEditingController(text: _active.textContent ?? '');
      _textBodyCtrl.addListener(() {
        final layer = _layers[_activeIndex];
        _layers[_activeIndex] = layer.copyWith(textContent: _textBodyCtrl.text.trim());
      });
      _setupPreview();
    });
    AnalyticsService.instance.track(
      'studio.layer_added',
      surface: 'bud_press_studio',
      objectType: type,
      properties: {'layer_count': _layers.length},
    );
    showToast(context, '$type layer added', type: ToastType.success);
  }

  void _moveLayer(int from, int to) {
    if (from < 0 || to < 0 || from >= _layers.length || to >= _layers.length) return;
    setState(() {
      final layer = _layers.removeAt(from);
      _layers.insert(to, layer);
      _activeIndex = to;
    });
  }

  void _duplicateLayer(int index) {
    if (index < 0 || index >= _layers.length) return;
    final layer = _layers[index];
    setState(() {
      _layers.insert(index + 1, layer.copyWith(studioItemId: const Uuid().v4()));
      _activeIndex = index + 1;
      _textBodyCtrl = TextEditingController(text: _active.textContent ?? '');
      _textBodyCtrl.addListener(() {
        final layer = _layers[_activeIndex];
        _layers[_activeIndex] = layer.copyWith(textContent: _textBodyCtrl.text.trim());
      });
      _setupPreview();
    });
    showToast(context, 'Layer duplicated', type: ToastType.success);
  }

  void _deleteLayer(int index) {
    if (_layers.length <= 1) {
      showToast(context, 'Keep at least one layer', type: ToastType.info);
      return;
    }
    setState(() {
      _layers.removeAt(index);
      if (_activeIndex >= _layers.length) _activeIndex = _layers.length - 1;
      _textBodyCtrl = TextEditingController(text: _active.textContent ?? '');
      _textBodyCtrl.addListener(() {
        final layer = _layers[_activeIndex];
        _layers[_activeIndex] = layer.copyWith(textContent: _textBodyCtrl.text.trim());
      });
      _setupPreview();
    });
    showToast(context, 'Layer removed', type: ToastType.info);
  }

  void _selectLayer(int index) {
    setState(() {
      _activeIndex = index;
      _textBodyCtrl = TextEditingController(text: _active.textContent ?? '');
      _textBodyCtrl.addListener(() {
        final layer = _layers[_activeIndex];
        _layers[_activeIndex] = layer.copyWith(textContent: _textBodyCtrl.text.trim());
      });
      _setupPreview();
      if (_active.studioItemId != null) {
        _loadSavedCaptions();
      }
    });
  }

  // ── captions ──────────────────────────────────────────────────────────

  // ignore: unused_element
  List<Map<String, dynamic>> get _captions =>
      List<Map<String, dynamic>>.from(_active.captions);

  Future<void> _loadSavedCaptions() async {
    if (_active.studioItemId == null) return;
    try {
      final raw = await ref.read(feedRepositoryProvider).getStudioCaptions(_active.studioItemId!);
      final data = (raw['data'] as Map<String, dynamic>?) ?? {};
      final segments = data['captions'];
      if (segments is List) {
      setState(() {
        final parsed = <Map<String, dynamic>>[];
        for (final s in segments) {
          if (s is Map) {
            parsed.add({
              'start_ms': (s['start_ms'] as num?)?.toInt() ?? 0,
              'end_ms': (s['end_ms'] as num?)?.toInt() ?? 0,
              'text': (s['text'] as String?) ?? '',
            });
          }
        }
        _layers[_activeIndex] = _active.copyWith(captions: parsed);
      });
      }
    } catch (_) {
      // captions optional
    }
  }

  Future<void> _persistCaptions() async {
    if (_active.studioItemId == null) return;
    try {
      await ref.read(feedRepositoryProvider).saveStudioCaptions(
        _active.studioItemId!,
        {'captions': _layers[_activeIndex].captions},
      );
    } catch (_) {
      if (mounted) {
        showToast(context, 'Captions saved locally — they publish with the post.', type: ToastType.info);
      }
    }
  }

  // ignore: unused_element
  void _setCaption(int index, String field, dynamic value) {
    if (index < 0 || index >= _active.captions.length) return;
    final cap = Map<String, dynamic>.from(_active.captions[index]);
    cap[field] = value;
    setState(() {
      _layers[_activeIndex] = _active.copyWith(
        captions: [
          for (var i = 0; i < _active.captions.length; i++)
            i == index ? Map<String, dynamic>.from(cap) : _active.captions[i]
        ],
      );
    });
    _persistCaptions();
  }

  void _addCaptionLine() {
    final now = _previewPositionMs.clamp(0, _durationMs > 0 ? _durationMs : 60000);
    final end = (now + 3000).clamp(0, _durationMs > 0 ? _durationMs : now + 3000);
    setState(() {
      _layers[_activeIndex] = _active.copyWith(
        captions: [
          ..._active.captions,
          {'start_ms': now, 'end_ms': end, 'text': ''},
        ],
      );
    });
    _persistCaptions();
    showToast(context, 'Caption line added', type: ToastType.success);
  }

  void _removeCaption(int index) {
    setState(() {
      _layers[_activeIndex] = _active.copyWith(
        captions: [..._active.captions]..removeAt(index),
      );
    });
    _persistCaptions();
  }

  // ── done ──────────────────────────────────────────────────────────────

  void _done() {
    Navigator.of(context).pop(
      BudPressStudioResult(
        layers: _layers,
        visibility: _visibility,
        commentsEnabled: _commentsEnabled,
      ),
    );
  }

  // ── preview render ────────────────────────────────────────────────────

  Widget _buildPreview() {
    final active = _active;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: BuddyColors.surfaceRaised),
            if (_isVideo && _controller != null)
              Video(controller: _controller!, controls: NoVideoControls)
            else if (_isPhoto && active.path.isNotEmpty)
              Image.file(File(active.path), fit: BoxFit.cover, width: double.infinity)
            else if (_isText)
              _TextPreview(text: active.textContent ?? '', style: active.textStyle ?? const {})
            else if (_isAudio)
              _AudioPreview(
                title: active.name,
                durationMs: active.durationMs ?? 0,
                positionMs: _previewPositionMs,
                onSeek: (ms) => setState(() => _previewPositionMs = ms),
              )
            else
              const Center(child: Icon(Icons.add_a_photo, color: BuddyColors.textSecondary)),
            // Captions overlay (active at preview position).
            if (_active.captions.isNotEmpty)
              CaptionOverlay(
                captions: [
                  for (final c in _active.captions)
                    CaptionSegment(
                      startMs: (c['start_ms'] as num?)?.toInt() ?? 0,
                      endMs: (c['end_ms'] as num?)?.toInt() ?? 0,
                      text: (c['text'] as String?) ?? '',
                    ),
                ],
                positionMs: _previewPositionMs,
                style: (active.editMeta ?? {})['captions_style'] as Map<String, dynamic>?,
              ),
            // Layerable overlays (text overlays + stickers).
            if ((active.editMeta ?? {}).containsKey('text_overlays') ||
                (active.editMeta ?? {}).containsKey('stickers'))
              CreativeOverlays(
                meta: active.editMeta,
                positionMs: _previewPositionMs,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayerStrip() {
    return SizedBox(
      height: 84,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _layers.length,
        itemBuilder: (_, i) {
          final layer = _layers[i];
          final selected = i == _activeIndex;
          return GestureDetector(
            onTap: () => _selectLayer(i),
            child: Container(
              width: 76,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: selected ? BuddyColors.green : BuddyColors.surfaceRaised,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? BuddyColors.green : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _layerThumb(layer),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    layer.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? BuddyColors.black : BuddyColors.textPrimary,
                      fontSize: 10,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (_active.captions.isNotEmpty && i == _activeIndex)
                    const Icon(Icons.closed_caption, size: 12, color: BuddyColors.green),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.move_up, size: 14),
                        onPressed: i > 0 ? () => _moveLayer(i, i - 1) : null,
                        color: BuddyColors.textSecondary,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.move_down, size: 14),
                        onPressed: i < _layers.length - 1 ? () => _moveLayer(i, i + 1) : null,
                        color: BuddyColors.textSecondary,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.content_copy, size: 14),
                        onPressed: () => _duplicateLayer(i),
                        color: BuddyColors.textSecondary,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 14),
                        onPressed: () => _deleteLayer(i),
                        color: BuddyColors.textSecondary,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _layerThumb(ComposerMedia m) {
    if (m.type == 'image' && m.path.isNotEmpty) {
      return Image.file(File(m.path), width: 60, height: 60, fit: BoxFit.cover);
    }
    if (m.type == 'video' && m.path.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(m.path), width: 60, height: 60, fit: BoxFit.cover),
          const Center(child: Icon(Icons.play_circle_outline, size: 24, color: Colors.white70)),
        ],
      );
    }
    if (m.type == 'text') {
      return Container(
        width: 60,
        height: 60,
        color: _parseBgColor(m.textStyle?['background']),
        alignment: Alignment.center,
        child: Text(
          (m.textContent ?? '').isNotEmpty ? (m.textContent!).substring(0, 1) : 'T',
          style: TextStyle(
            color: _parseColor(m.textStyle?['color'], Colors.white),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    if (m.type == 'audio') {
      return const Center(child: Icon(Icons.audiotrack, size: 24, color: BuddyColors.textSecondary));
    }
    return const Center(child: Icon(Icons.image_outlined, size: 24, color: BuddyColors.textSecondary));
  }

  // ── tabs ──────────────────────────────────────────────────────────────

  List<_Tab> _tabs() {
    final tabs = <_Tab>[
      _Tab('preview', Icons.preview, 'Preview'),
    ];
    if (_isVideo) {
      tabs.addAll([
        _Tab('trim', Icons.content_cut, 'Trim'),
        _Tab('sound', Icons.music_note, 'Sound'),
        _Tab('captions', Icons.closed_caption, 'Captions'),
        _Tab('overlays', Icons.sticky_note_2, 'Overlays'),
      ]);
    } else if (_isPhoto) {
      tabs.addAll([
        _Tab('crop', Icons.crop, 'Crop'),
        _Tab('filter', Icons.tune, 'Filter'),
        _Tab('overlays', Icons.sticky_note_2, 'Overlays'),
      ]);
    } else if (_isText) {
      tabs.addAll([
        _Tab('style', Icons.text_fields, 'Style'),
        _Tab('captions', Icons.closed_caption, 'Captions'),
      ]);
    } else if (_isAudio) {
      tabs.addAll([
        _Tab('sound', Icons.music_note, 'Sound'),
      ]);
    }
    tabs.addAll([
      _Tab('cover', Icons.image_outlined, 'Cover'),
      _Tab('audience', Icons.visibility, 'Audience'),
    ]);
    return tabs;
  }

  Widget _tabChip(_Tab tab) {
    final selected = _tab == tab.key;
    return GestureDetector(
      onTap: () => setState(() => _tab = tab.key),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? BuddyColors.green : BuddyColors.surfaceRaised,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tab.icon, size: 14, color: selected ? BuddyColors.black : BuddyColors.textSecondary),
            const SizedBox(width: 4),
            Text(tab.label, style: TextStyle(
              color: selected ? BuddyColors.black : BuddyColors.textPrimary,
              fontSize: 11,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            )),
          ],
        ),
      ),
    );
  }

  // ── editor panels ─────────────────────────────────────────────────────

  Widget _buildPanel() {
    switch (_tab) {
      case 'preview':
        return const _EmptyPanel();
      case 'trim':
        return _TrimPanel(
          durationMs: _durationMs,
          trimStartMs: _active.trimStartMs,
          trimEndMs: _active.trimEndMs,
          maxTrimMs: _maxTrimMs,
          onChange: (v) {
            setState(() {
              _layers[_activeIndex] = _active.copyWith(trimStartMs: v.start, trimEndMs: v.end);
              _setupPreview();
            });
          },
        );
      case 'crop':
        return _CropPanel(
          onAspect: (aspect) {
            setState(() {
              final meta = Map<String, dynamic>.from(_active.editMeta ?? {});
              meta['aspect'] = aspect;
              _layers[_activeIndex] = _active.copyWith(editMeta: meta);
            });
          },
        );
      case 'filter':
        return _FilterPanel(
          onFilter: (f) {
            setState(() {
              final meta = Map<String, dynamic>.from(_active.editMeta ?? {});
              meta['filter'] = f.filter;
              if (f.strength != 100) meta['filter_strength'] = f.strength;
              _layers[_activeIndex] = _active.copyWith(editMeta: meta);
            });
          },
        );
      case 'sound':
        return _SoundPanel(
          selectedSoundId: _active.soundId,
          volume: (_active.soundVolume ?? 100),
          onSelect: (v) {
            ref.read(soundsProvider.notifier).markUsed(v.sound!.id);
            setState(() {
              _layers[_activeIndex] = _active.copyWith(soundId: v.sound!.id, soundVolume: v.volume);
            });
            showToast(context, 'Sound added', type: ToastType.success);
          },
          onVolume: (v) {
            setState(() => _layers[_activeIndex] = _active.copyWith(soundVolume: v));
          },
        );
      case 'captions':
        return _CaptionsPanel(
          captions: _active.captions,
          durationMs: _durationMs,
          positionMs: _previewPositionMs,
          onChange: (captions) {
            setState(() => _layers[_activeIndex] = _active.copyWith(captions: captions));
            _persistCaptions();
          },
          onAddLine: _addCaptionLine,
          onRemove: (i) => _removeCaption(i),
        );
      case 'overlays':
        return _OverlaysPanel(
          meta: _active.editMeta ?? {},
          onChange: (meta) {
            setState(() => _layers[_activeIndex] = _active.copyWith(editMeta: meta));
          },
        );
      case 'style':
        return _TextStylePanel(
          style: _active.textStyle ?? const {},
          onChange: (style) {
            setState(() => _layers[_activeIndex] = _active.copyWith(textStyle: style));
            _textBodyCtrl.text = _active.textContent ?? '';
          },
        );
      case 'cover':
        return _CoverPanel(
          durationMs: _durationMs,
          offsetSec: _active.coverOffsetSec ?? 0.0,
          onChange: (sec) {
            setState(() => _layers[_activeIndex] = _active.copyWith(coverOffsetSec: sec));
          },
        );
      case 'audience':
        return _AudiencePanel(
          visibility: _visibility,
          commentsEnabled: _commentsEnabled,
          onChange: (v) {
            setState(() {
              _visibility = v.visibility;
              _commentsEnabled = v.commentsEnabled;
            });
          },
        );
      default:
        return const _EmptyPanel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bud Press Studio'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddLayerSheet(), tooltip: 'Add layer'),
          const SizedBox(width: 6),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: BuddyColors.green, foregroundColor: BuddyColors.black),
            onPressed: _done,
            child: const Text('Done'),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            '${_layers.length} layer${_layers.length == 1 ? '' : 's'}',
            style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 4),
          _buildLayerStrip(),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    _buildPreview(),
                    if (_durationMs > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Slider(
                          min: 0,
                          max: _durationMs.toDouble(),
                          value: _previewPositionMs.clamp(0.0, _durationMs.toDouble()).toDouble(),
                          onChanged: (double v) => setState(() => _previewPositionMs = v.round()),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${_fmtMs(_previewPositionMs)} / ${_fmtMs(_durationMs)}',
                            style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 11)),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: Icon(_loopPreview ? Icons.loop : Icons.repeat),
                          onPressed: () => setState(() => _loopPreview = !_loopPreview),
                          tooltip: 'Loop preview',
                        ),
                        if (_player != null)
                          IconButton(
                            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                            onPressed: () async {
                              if (_isPlaying) {
                                await _player!.pause();
                                setState(() => _isPlaying = false);
                              } else {
                                await _player!.seek(Duration(milliseconds: _active.trimStartMs));
                                await _player!.play();
                                setState(() => _isPlaying = true);
                              }
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: BuddyColors.surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: _tabs().map((t) => _tabChip(t)).toList(),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 220,
                  child: _buildPanel(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddLayerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: BuddyColors.surface,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add layer', style: TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 12),
              ...[
                ('photo', Icons.add_a_photo, 'Photo'),
                ('video', Icons.videocam, 'Video'),
                ('audio', Icons.audiotrack, 'Audio'),
                ('text', Icons.text_fields, 'Styled text'),
              ].map((entry) {
                return ListTile(
                  leading: Icon(entry.$2, color: BuddyColors.textSecondary),
                  title: Text(entry.$3, style: const TextStyle(color: BuddyColors.textPrimary)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addLayer(entry.$1);
                  },
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  // ── editor panels ─────────────────────────────────────────────────────
}

// ─── Panels (compact) ──────────────────────────────────────────────────

class _TrimPanel extends StatelessWidget {
  final int durationMs, trimStartMs, trimEndMs, maxTrimMs;
  final ValueChanged<({int start, int end})> onChange;
  const _TrimPanel({required this.durationMs, required this.trimStartMs, required this.trimEndMs, required this.maxTrimMs, required this.onChange});

  @override
  Widget build(BuildContext context) {
    double start = trimStartMs.toDouble(), end = (trimEndMs > 0 ? trimEndMs : durationMs).toDouble();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Trim video', style: TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        RangeSlider(
          min: 0, max: durationMs.toDouble(), values: RangeValues(start, end),
          onChanged: (v) {
            var s = v.start, e = v.end;
            if (e - s > maxTrimMs) { if (s != start) s = e - maxTrimMs; else e = s + maxTrimMs; }
            start = s; end = e;
          },
          onChangeEnd: (v) => onChange((start: v.start.round(), end: v.end.round())),
          activeColor: BuddyColors.green,
        ),
      ],
    );
  }
}

class _CropPanel extends StatelessWidget {
  final ValueChanged<String> onAspect;
  const _CropPanel({required this.onAspect});
  @override
  Widget build(BuildContext context) {
    final aspects = ['9:16', '1:1', '4:5', '16:9'];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Aspect ratio', style: TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: aspects.map((a) => ChoiceChip(
            label: Text(a),
            selected: false,
            onSelected: (_) => onAspect(a),
          )).toList(),
        ),
      ],
    );
  }
}

class _FilterPanel extends StatelessWidget {
  final ValueChanged<({String filter, int strength})> onFilter;
  const _FilterPanel({required this.onFilter});
  final _filters = const ['none', 'vivid', 'muted', 'warm', 'cool', 'dramatic'];
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Filter', style: TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _filters.map((f) => ChoiceChip(
            label: Text(f[0].toUpperCase() + f.substring(1)),
            selected: false,
            onSelected: (_) => onFilter((filter: f, strength: 100)),
          )).toList(),
        ),
      ],
    );
  }
}

class _SoundPanel extends ConsumerWidget {
  final String? selectedSoundId;
  final double volume;
  final ValueChanged<({Sound? sound, double volume})> onSelect;
  final ValueChanged<double> onVolume;
  const _SoundPanel({required this.selectedSoundId, required this.volume, required this.onSelect, required this.onVolume});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(soundsProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sound', style: TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        if (state.isLoading) const CircularProgressIndicator() else
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.volume_off_outlined),
              title: const Text('Original only'),
              trailing: selectedSoundId == null ? const Icon(Icons.check, color: BuddyColors.green) : null,
              onTap: () => onSelect((sound: null, volume: volume)),
            ),
            const Divider(height: 1),
            ...state.items.map((s) => ListTile(
              leading: Icon(Icons.play_circle_outline, color: BuddyColors.green),
              title: Text(s.name, style: const TextStyle(fontSize: 13)),
              subtitle: Text('${s.artist} · ${s.usageCount} uses', style: const TextStyle(fontSize: 11, color: BuddyColors.textSecondary)),
              trailing: selectedSoundId == s.id ? const Icon(Icons.check_circle, color: BuddyColors.green) : Icon(Icons.add_circle_outline, color: BuddyColors.green),
              onTap: () => onSelect((sound: s, volume: volume)),
            )),
            const SizedBox(height: 12),
            Slider(
              value: volume, min: 0, max: 100, divisions: 100,
              label: '${volume.round()}',
              onChanged: (double v) => onVolume(v),
              activeColor: BuddyColors.green,
            ),
          ],
        ),
      ],
    );
  }
}

class _CaptionsPanel extends StatelessWidget {
  final List<Map<String, dynamic>> captions;
  final int durationMs;
  final int positionMs;
  final ValueChanged<List<Map<String, dynamic>>> onChange;
  final VoidCallback onAddLine;
  final ValueChanged<int> onRemove;
  const _CaptionsPanel({required this.captions, required this.durationMs, required this.positionMs, required this.onChange, required this.onAddLine, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Captions', style: TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
            const Spacer(),
            IconButton(icon: const Icon(Icons.add, size: 16, color: BuddyColors.green), onPressed: onAddLine, tooltip: 'Add line'),
          ],
        ),
        const SizedBox(height: 6),
        if (captions.isEmpty)
          const Text('Generate or add captions — they publish with the video.', style: TextStyle(color: BuddyColors.textSecondary, fontSize: 12))
        else
          ...List.generate(captions.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      decoration: const InputDecoration(hintText: 'Caption', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                      onChanged: (v) => onChange([
                        for (var j = 0; j < captions.length; j++)
                          j == i ? {...captions[j], 'text': v} : captions[j],
                      ]),
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(width: 56,
                    child: TextField(
                      decoration: const InputDecoration(hintText: 'start', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4)),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n == null) return;
                        onChange([
                          for (var j = 0; j < captions.length; j++)
                            j == i ? {...captions[j], 'start_ms': n} : captions[j],
                        ]);
                      },
                    )),
                  const SizedBox(width: 4),
                  SizedBox(width: 56,
                    child: TextField(
                      decoration: const InputDecoration(hintText: 'end', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4)),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n == null) return;
                        onChange([
                          for (var j = 0; j < captions.length; j++)
                            j == i ? {...captions[j], 'end_ms': n} : captions[j],
                        ]);
                      },
                    )),
                  IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () => onRemove(i)),
                ],
              ),
            );
          }),
      ],
    );
  }
}

class _OverlaysPanel extends StatelessWidget {
  final Map<String, dynamic> meta;
  final ValueChanged<Map<String, dynamic>> onChange;
  const _OverlaysPanel({required this.meta, required this.onChange});

  void _addOverlay(BuildContext context) {
    var kind = 'text';
    var content = '';
    var position = 'bottom';
    var size = 1.0;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add overlay'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: kind,
              items: ['text', 'emoji'].map((e) => DropdownMenuItem(value: e, child: Text(e == 'text' ? 'Text overlay' : 'Emoji/sticker'))).toList(),
              onChanged: (v) => kind = v!,
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(hintText: 'Text / emoji'),
              onChanged: (v) => content = v,
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: position,
              items: ['bottom', 'center', 'top'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => position = v!,
            ),
            const SizedBox(height: 8),
            DropdownButton<double>(
              value: size,
              items: [0.8, 1.0, 1.3, 1.6].map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
              onChanged: (v) => size = v!,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: content.trim().isEmpty ? null : () {
              final y = {'bottom': 80, 'center': 50, 'top': 20}[position]!;
              final overlay = {
                'text': content.trim(),
                'start_ms': 0,
                'end_ms': 60000,
                'x': 50,
                'y': y,
                'size': size,
                'color': '#FFFFFF',
                'effect': 'shadow',
                'bg': 'block',
                'font': 'classic',
              };
              final overlays = List<Map<String, dynamic>>.from((meta['text_overlays'] as List?)?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[]);
              overlays.add(overlay);
              onChange({...meta, 'text_overlays': overlays});
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final overlays = List<Map<String, dynamic>>.from((meta['text_overlays'] as List?)?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[]);
    final stickers = List<Map<String, dynamic>>.from((meta['stickers'] as List?)?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[]);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Overlays', style: TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
            const Spacer(),
            IconButton(icon: const Icon(Icons.add, size: 16, color: BuddyColors.green), onPressed: () => _addOverlay(context), tooltip: 'Add overlay'),
          ],
        ),
        const SizedBox(height: 6),
        if (overlays.isEmpty && stickers.isEmpty)
          const Text('Add text overlays or stickers — they render relative to the video frame.', style: TextStyle(color: BuddyColors.textSecondary, fontSize: 12))
        else ...[
          for (final o in overlays)
            ListTile(
              title: Text((o['text'] as String?) ?? '', style: const TextStyle(fontSize: 13)),
              subtitle: Text('size=${o['size']} · ${o['placement'] ?? 'bottom'}', style: const TextStyle(fontSize: 11, color: BuddyColors.textSecondary)),
              trailing: IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () {
                overlays.remove(o);
                onChange({...meta, 'text_overlays': overlays});
              }),
            ),
          for (final s in stickers)
            ListTile(
              title: Text((s['content'] as String?) ?? '', style: const TextStyle(fontSize: 13)),
              trailing: IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () {
                stickers.remove(s);
                onChange({...meta, 'stickers': stickers});
              }),
            ),
        ],
      ],
    );
  }
}

class _TextStylePanel extends StatelessWidget {
  final Map<String, dynamic> style;
  final ValueChanged<Map<String, dynamic>> onChange;
  const _TextStylePanel({required this.style, required this.onChange});

  @override
  Widget build(BuildContext context) {
    var bg = style['background'] as String? ?? 'none';
    var font = style['font'] as String? ?? 'classic';
    var color = style['color'] as String? ?? '#FFFFFF';
    var effect = style['effect'] as String? ?? 'none';
    var size = ((style['size'] as num?)?.toDouble() ?? 1.0).clamp(0.5, 2.0);
    var alignment = style['alignment'] as String? ?? 'center';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Text style', style: TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: bg, isExpanded: true,
          items: ['none', 'gradient:sunrise', 'gradient:midnight', 'solid:black', 'solid:white'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => onChange({...style, 'background': v}),
        ),
        const SizedBox(height: 6),
        DropdownButton<String>(
          value: font, isExpanded: true,
          items: ['classic', 'serif', 'bangers', 'marker', 'soft', 'typewriter'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => onChange({...style, 'font': v}),
        ),
        const SizedBox(height: 6),
        DropdownButton<String>(
          value: color, isExpanded: true,
          items: ['#FFFFFF', '#FFD400', '#FF3CA7', '#00FF9D', '#38E1FF', '#111111'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => onChange({...style, 'color': v}),
        ),
        const SizedBox(height: 6),
        DropdownButton<String>(
          value: effect, isExpanded: true,
          items: ['none', 'pop', 'glow', 'neon', 'bubble', 'shadow', 'outline'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => onChange({...style, 'effect': v}),
        ),
        const SizedBox(height: 6),
        Slider(
          value: size, min: 0.5, max: 2.0, divisions: 30,
          label: '${(size * 100).round()}%',
          onChanged: (double v) => onChange({...style, 'size': v}),
        ),
        const SizedBox(height: 6),
        DropdownButton<String>(
          value: alignment, isExpanded: true,
          items: ['center', 'start', 'end'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => onChange({...style, 'alignment': v}),
        ),
        const SizedBox(height: 10),
        const Text('Preview', style: TextStyle(color: BuddyColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        _TextPreview(text: 'Hello world', style: {...style, 'size': size}),
      ],
    );
  }
}

class _CoverPanel extends StatelessWidget {
  final int durationMs;
  final double offsetSec;
  final ValueChanged<double> onChange;
  const _CoverPanel({required this.durationMs, required this.offsetSec, required this.onChange});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cover frame', style: TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        Slider(
          min: 0, max: durationMs > 0 ? durationMs.toDouble() : 100,
          value: offsetSec.clamp(0.0, durationMs > 0 ? durationMs.toDouble() : 100),
          onChanged: onChange,
          activeColor: BuddyColors.green,
        ),
        Text('Cover at ${_CoverPanelFmt.fmt(offsetSec.round())} / ${_CoverPanelFmt.fmt(durationMs)}', style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 6),
        const Text('Sent with the post as the cover hint (Cloudinary ``so_N``).', style: TextStyle(color: BuddyColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}

class _CoverPanelFmt {
  static String fmt(int ms) {
    final total = (ms / 1000).round();
    return '${total ~/ 60}:${(total % 60).toString().padLeft(2, '0')}';
  }
}

class _AudiencePanel extends StatelessWidget {
  final String visibility;
  final bool commentsEnabled;
  final ValueChanged<({String visibility, bool commentsEnabled})> onChange;
  const _AudiencePanel({required this.visibility, required this.commentsEnabled, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Audience', style: TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        ...['public', 'buddies', 'gym_members', 'private'].map((v) => RadioListTile<String>(
          value: v,
          groupValue: visibility,
          title: Text(_label(v)),
          onChanged: (nv) => onChange((visibility: nv ?? visibility, commentsEnabled: commentsEnabled)),
        )),
        const Divider(height: 1),
        SwitchListTile(
          title: const Text('Allow comments'),
          value: commentsEnabled,
          onChanged: (v) => onChange((visibility: visibility, commentsEnabled: v)),
        ),
      ],
    );
  }
  String _label(String k) => switch (k) {
    'public' => 'Public — anyone on Buddy-Up',
    'buddies' => 'Buddies — your buddies only',
    'gym_members' => 'Gym members — your gyms',
    _ => 'Private — only you',
  };
}

class _Tab {
  final String key;
  final IconData icon;
  final String label;
  _Tab(this.key, this.icon, this.label);
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel();
  @override
  Widget build(BuildContext context) => const Center(child: Text('Pick a tool to edit this layer.', style: TextStyle(color: BuddyColors.textSecondary)));
}

// ─── Preview widgets ───────────────────────────────────────────────────

class _TextPreview extends StatelessWidget {
  final String text;
  final Map<String, dynamic> style;
  const _TextPreview({required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    final size = ((style['size'] as num?)?.toDouble() ?? 1.0).clamp(0.5, 2.0);
    final color = _parseColor(style['color'] as String?, Colors.white);
    final bg = style['background'] as String? ?? 'none';
    final alignment = style['alignment'] as String? ?? 'center';
    return Container(
      alignment: alignment == 'start' ? Alignment.centerLeft : alignment == 'end' ? Alignment.centerRight : Alignment.center,
      padding: const EdgeInsets.all(24),
      color: _parseBgColor(bg),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 20 * size,
          fontWeight: FontWeight.bold,
          shadows: [
            const Shadow(color: Color(0x8C000000), offset: Offset(0, 2), blurRadius: 4),
          ],
        ),
      ),
    );
  }
}

class _AudioPreview extends StatelessWidget {
  final String title;
  final int durationMs;
  final int positionMs;
  final ValueChanged<int> onSeek;
  const _AudioPreview({required this.title, required this.durationMs, required this.positionMs, required this.onSeek});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      color: BuddyColors.surfaceRaised.withValues(alpha: 0.5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.audiotrack, size: 48, color: BuddyColors.textSecondary),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Slider(
            min: 0,
            max: durationMs > 0 ? durationMs.toDouble() : 100,
            value: positionMs.clamp(0.0, durationMs > 0 ? durationMs.toDouble() : 100).toDouble(),
            onChanged: (double v) => onSeek(v.round()),
            activeColor: BuddyColors.green,
          ),
          Text('${_fmtMs(positionMs)} / ${_fmtMs(durationMs)}', style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}
