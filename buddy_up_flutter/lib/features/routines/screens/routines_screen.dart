import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/routine.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/page_loader.dart';
import '../providers/routines_provider.dart';
import '../utils/routine_share_card.dart';

const List<String> _dayShort = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

/// Routines — the daily streak system from the web app.
///
/// The list is the product: every row shows headline type, days, streak and
/// a check-in button the size of a thumb. The detail/create flow lives in
/// [RoutineEditorScreen] and mirrors the web form field for field.
class RoutinesScreen extends ConsumerStatefulWidget {
  const RoutinesScreen({super.key});

  @override
  ConsumerState<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends ConsumerState<RoutinesScreen> {
  bool _reorderMode = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(routinesProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(routinesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_reorderMode ? 'Reorder routines' : 'Routines'),
        actions: [
          if (state.routines.length > 1)
            IconButton(
              tooltip: _reorderMode ? 'Done reordering' : 'Reorder',
              icon: Icon(_reorderMode ? Icons.check : Icons.swap_vert),
              onPressed: () => setState(() => _reorderMode = !_reorderMode),
            ),
          IconButton(
            tooltip: 'Analytics',
            icon: const Icon(Icons.insights_outlined),
            onPressed: () => context.push('/analytics'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: BuddyColors.green,
        onPressed: () => context.push('/routines/create'),
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.surface),
      ),
      body: state.isLoading && state.routines.isEmpty
          ? const PageLoader()
          : state.error != null && state.routines.isEmpty
              ? ErrorView(
                  message: state.error!,
                  onRetry: () =>
                      ref.read(routinesProvider.notifier).load(),
                )
              : state.routines.isEmpty
                  ? const EmptyState(
                      icon: Icons.repeat_rounded,
                      title: 'No routines yet',
                      subtitle: 'Create your first routine — even “10 push-ups '
                          'every morning” counts.',
                    )
                  : _reorderMode
                      ? _buildReorderList(state.routines)
                      : RefreshIndicator(
                      onRefresh: () =>
                          ref.read(routinesProvider.notifier).load(),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                        children: [
                          _SummaryBar(routines: state.routines),
                          const SizedBox(height: 12),
                          const _QuickAdd(),
                          for (final routine in state.routines)
                            _RoutineCard(
                              routine: routine,
                              onEdit: () => context.push(
                                '/routines/${routine.id}/edit',
                              ),
                              onDelete: () => _confirmDelete(routine.id),
                              onHighlights: () => _showHighlights(routine),
                              onShare: () => _showShare(routine),
                            ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildReorderList(List<Routine> routines) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            'Long-press a routine and drag to change the order. '
            'The order is saved to your account.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
            itemCount: routines.length,
            onReorderItem: (oldIndex, newIndex) {
              final ids = routines.map((r) => r.id).toList();
              final moved = ids.removeAt(oldIndex);
              ids.insert(newIndex, moved);
              ref.read(routinesProvider.notifier).reorder(ids);
            },
            itemBuilder: (context, index) {
              final routine = routines[index];
              return Padding(
                key: ValueKey(routine.id),
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const Icon(Icons.drag_indicator, size: 20),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _RoutineCard(
                        routine: routine,
                        onEdit: () => context.push(
                          '/routines/${routine.id}/edit',
                        ),
                        onDelete: () => _confirmDelete(routine.id),
                        onHighlights: () => _showHighlights(routine),
                        onShare: () => _showShare(routine),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete routine?'),
        content: const Text(
          'The streak and check-in history disappear with it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(routinesProvider.notifier).deleteRoutine(id);
    }
  }

  /// Highlights studio — photo, video or voice files attached to a routine.
  /// Mirrors the web studio's Highlights tab; the media is what the share
  /// sheet then uses as the post's image.
  Future<void> _showHighlights(Routine routine) async {
    var highlights = List<RoutineHighlight>.of(routine.highlights);
    var kind = 'photo';
    var busy = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: BuddyColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          Future<void> refresh() async {
            final raw = await ref
                .read(routineRepositoryProvider)
                .getHighlights(routine.id);
            final data = raw is Map ? raw['data'] : raw;
            final list = (data is List ? data : const [])
                .whereType<Map>()
                .map((e) =>
                    RoutineHighlight.fromJson(Map<String, dynamic>.from(e)))
                .toList();
            if (ctx.mounted) setSheetState(() => highlights = list);
          }

          Future<void> add() async {
            setSheetState(() => busy = true);
            try {
              String? path;
              String filename = '';
              if (kind == 'photo') {
                final picked = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 88,
                );
                path = picked?.path;
                filename = picked?.name ?? '';
              } else if (kind == 'video') {
                final picked = await ImagePicker().pickVideo(
                  source: ImageSource.gallery,
                );
                path = picked?.path;
                filename = picked?.name ?? '';
              } else {
                final result = await FilePicker.pickFiles(
                  type: FileType.audio,
                );
                path = result.firstOrNull?.path;
                filename = result.firstOrNull?.name ?? '';
              }
              if (path == null) {
                setSheetState(() => busy = false);
                return;
              }
              await ref.read(routineRepositoryProvider).uploadHighlight(
                    routine.id,
                    await MultipartFile.fromFile(path, filename: filename),
                    kind,
                    '',
                    '0',
                  );
              await refresh();
              await ref.read(routinesProvider.notifier).load();
            } catch (_) {
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Could not upload that highlight.')),
                );
              }
            } finally {
              if (ctx.mounted) setSheetState(() => busy = false);
            }
          }

          Future<void> remove(RoutineHighlight highlight) async {
            try {
              await ref
                  .read(routineRepositoryProvider)
                  .deleteHighlight(routine.id, highlight.id);
              await refresh();
              await ref.read(routinesProvider.notifier).load();
            } catch (_) {
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Could not remove that highlight.')),
                );
              }
            }
          }

          final visible = highlights.where((h) => h.kind == kind).toList();
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Highlights',
                    style: TextStyle(
                      color: Theme.of(ctx).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    routine.displayName,
                    style: TextStyle(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final option in const ['photo', 'video', 'voice'])
                        ChoiceChip(
                          label: Text(switch (option) {
                            'photo' => 'Photos',
                            'video' => 'Videos',
                            _ => 'Voice',
                          }),
                          selected: kind == option,
                          selectedColor:
                              BuddyColors.green.withValues(alpha: 0.2),
                          onSelected: (_) =>
                              setSheetState(() => kind = option),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: visible.isEmpty
                        ? Center(
                            child: Text(
                              'No $kind highlights yet.',
                              style: TextStyle(
                                color: Theme.of(ctx)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: visible.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                              final highlight = visible[i];
                              return Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(ctx).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: BuddyColors.border),
                                ),
                                child: Row(
                                  children: [
                                    if (highlight.kind == 'photo' &&
                                        highlight.fileUrl.isNotEmpty)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.network(
                                          highlight.fileUrl,
                                          width: 44,
                                          height: 44,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) =>
                                              const Icon(Icons.image_outlined),
                                        ),
                                      )
                                    else
                                      Icon(
                                        highlight.kind == 'video'
                                            ? Icons.videocam_outlined
                                            : Icons.mic_none,
                                        color: BuddyColors.green,
                                      ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        highlight.caption.isNotEmpty
                                            ? highlight.caption
                                            : highlight.fileUrl
                                                .split('/')
                                                .last,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Theme.of(ctx)
                                              .colorScheme
                                              .onSurface,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Remove highlight',
                                      icon: const Icon(Icons.delete_outline,
                                          size: 18),
                                      onPressed: () => remove(highlight),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: busy ? null : add,
                    icon: busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_photo_alternate_outlined,
                            size: 18),
                    label: Text(busy ? 'Uploading…' : 'Add a $kind highlight'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Share studio — a routine becomes a moment (story) or a workout-log post.
  /// The server owns the metrics card; the overlay position and visibility are
  /// the choices the web studio exposes.
  Future<void> _showShare(Routine routine) async {
    var asStory = true;
    var overlay = 'middle';
    var visibility = 'public';
    var busy = false;
    String? message;
    final bodyController = TextEditingController(
      text: '${routine.displayName} — ${routine.streak} day streak '
          '(${routine.target} ${routine.unit}).',
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: BuddyColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          Future<void> share() async {
            setSheetState(() {
              busy = true;
              message = null;
            });
            final result = await ref.read(routinesProvider.notifier).shareRoutine(
                  routine.id,
                  asStory: asStory,
                  overlayPosition: overlay,
                  visibility: visibility,
                  body: bodyController.text,
                  mediaUrl: routine.highlights.isNotEmpty
                      ? routine.highlights.first.fileUrl
                      : null,
                );
            if (!ctx.mounted) return;
            setSheetState(() {
              busy = false;
              message = result == null
                  ? (ref.read(routinesProvider).error ??
                      'Could not share the routine.')
                  : 'Shared as ${result == 'moment' ? 'a story' : 'a post'} ($result).';
            });
          }

          Future<void> shareCard() async {
            setSheetState(() => busy = true);
            try {
              final file = await RoutineShareCardRenderer().render(routine);
              await SharePlus.instance.share(ShareParams(
                files: [XFile(file.path)],
                text: 'My ${routine.displayName} routine on BuddyUp Fit',
                subject: 'BuddyUp Fit routine',
              ));
              if (ctx.mounted) setSheetState(() => message = 'Routine card ready to share.');
            } catch (_) {
              if (ctx.mounted) setSheetState(() => message = 'Could not build the routine card.');
            } finally {
              if (ctx.mounted) setSheetState(() => busy = false);
            }
          }

          Future<void> downloadCard() async {
            setSheetState(() => busy = true);
            try {
              final file = await RoutineShareCardRenderer().render(routine);
              if (ctx.mounted) setSheetState(() => message = 'Card saved: ${file.path}');
            } catch (_) {
              if (ctx.mounted) setSheetState(() => message = 'Could not save the routine card.');
            } finally {
              if (ctx.mounted) setSheetState(() => busy = false);
            }
          }

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Share routine',
                      style: TextStyle(
                        color: Theme.of(ctx).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      routine.displayName,
                      style: TextStyle(
                        color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Metrics overlay',
                      style: TextStyle(
                        color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'top', label: Text('Top')),
                        ButtonSegment(value: 'middle', label: Text('Middle')),
                        ButtonSegment(value: 'bottom', label: Text('Bottom')),
                      ],
                      selected: {overlay},
                      onSelectionChanged: (value) =>
                          setSheetState(() => overlay = value.first),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Share as a story (moment)'),
                      value: asStory,
                      activeThumbColor: BuddyColors.green,
                      onChanged: (value) =>
                          setSheetState(() => asStory = value),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      initialValue: visibility,
                      decoration: const InputDecoration(
                        labelText: 'Visibility',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'public', child: Text('Public')),
                        DropdownMenuItem(value: 'buddies', child: Text('Buddies')),
                        DropdownMenuItem(
                            value: 'gym_members', child: Text('Gym members')),
                        DropdownMenuItem(value: 'private', child: Text('Private')),
                      ],
                      onChanged: (value) => setSheetState(
                          () => visibility = value ?? 'public'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bodyController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Caption',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (routine.highlights.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Using your ${routine.highlights.first.kind} highlight '
                        'as media (${routine.highlights.length} saved).',
                        style: TextStyle(
                          color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: busy ? null : downloadCard,
                            icon: const Icon(Icons.download_outlined),
                            label: const Text('Save card'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: busy ? null : shareCard,
                            icon: const Icon(Icons.ios_share_outlined),
                            label: const Text('Share card'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (message != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          message!,
                          style: TextStyle(
                            color: message!.startsWith('Shared')
                                ? BuddyColors.green
                                : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    FilledButton(
                      onPressed: busy ? null : share,
                      child: busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Share'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    bodyController.dispose();
  }
}

class _QuickAddType {
  final String key;
  final String label;
  final String hint;
  final IconData icon;
  final Color color;
  final int target;
  final String unit;

  const _QuickAddType({
    required this.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.color,
    required this.target,
    required this.unit,
  });
}

class _QuickAdd extends ConsumerStatefulWidget {
  const _QuickAdd();

  @override
  ConsumerState<_QuickAdd> createState() => _QuickAddState();
}

class _QuickAddState extends ConsumerState<_QuickAdd> {
  static const _types = <_QuickAddType>[
    _QuickAddType(key: 'walk', label: 'Walking', hint: '5,000 steps', icon: Icons.directions_walk, color: Color(0xFF00C896), target: 5000, unit: 'steps'),
    _QuickAddType(key: 'run', label: 'Running', hint: '5 km', icon: Icons.directions_run, color: Color(0xFFFF4757), target: 5, unit: 'km'),
    _QuickAddType(key: 'cycle', label: 'Cycling', hint: '10 km', icon: Icons.directions_bike, color: BuddyColors.electric, target: 10, unit: 'km'),
    _QuickAddType(key: 'hike', label: 'Hiking', hint: '5 km', icon: Icons.terrain, color: Color(0xFFFF6B35), target: 5, unit: 'km'),
    _QuickAddType(key: 'workout', label: 'Workout', hint: '30 min', icon: Icons.fitness_center, color: BuddyColors.gold, target: 30, unit: 'min'),
    _QuickAddType(key: 'gym', label: 'Gym', hint: '4 sessions', icon: Icons.warehouse_outlined, color: Color(0xFF3B82F6), target: 4, unit: 'sessions'),
    _QuickAddType(key: 'other', label: 'Other', hint: 'Custom', icon: Icons.repeat_rounded, color: BuddyColors.textSecondary, target: 10, unit: 'min'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Routine types',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pick one to start tracking',
                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 700;
              final crossAxisCount = isWide ? 7 : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: crossAxisCount == 7 ? 0.82 : 0.98,
                children: [
                  for (final t in _types)
                    _QuickAddTile(
                      key: ValueKey(t.key),
                      icon: t.icon,
                      label: t.label,
                      hint: t.hint,
                      color: t.color,
                      onTap: () => _quickAdd(context, t),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _quickAdd(BuildContext context, _QuickAddType t) async {
    if (t.key == 'other') {
      final name = await showDialog<String>(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx2, setState2) {
            final controller = TextEditingController();
            return AlertDialog(
              title: const Text('New custom routine'),
              content: TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Routine name',
                  hintText: 'e.g. Cold shower',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, null),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, controller.text),
                  child: const Text('Next'),
                ),
              ],
            );
          },
        ),
      );
      if (name == null) return;
      final trimmed = name.trim();
      if (trimmed.isEmpty) return;
      final created = await ref
          .read(routinesProvider.notifier)
          .createOrUpdate(
        type: 'other',
        customName: trimmed,
        name: trimmed,
        target: t.target,
        unit: t.unit,
        days: const [],
        reminderMinutes: const [],
        activation: 'week',
        tracking: 'app',
      );
      if (context.mounted && !created) {
        // createOrUpdate surfaces the error state on the notifier.
      }
      return;
    }

    final created = await ref
        .read(routinesProvider.notifier)
        .createOrUpdate(
      type: t.key,
      name: t.label,
      target: t.target,
      unit: t.unit,
      days: const [],
      reminderMinutes: const [],
      activation: 'week',
      tracking: 'app',
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(created ? 'Routine created — started one for you.' : 'Could not create that routine.')),
      );
    }
  }
}

class _QuickAddTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final Color color;
  final VoidCallback onTap;

  const _QuickAddTile({
    super.key,
    required this.icon,
    required this.label,
    required this.hint,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.onSurface),
            ),
            const SizedBox(height: 2),
            Text(
              hint,
              style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  final List<Routine> routines;

  const _SummaryBar({required this.routines});

  @override
  Widget build(BuildContext context) {
    final active = routines.length;
    final totalStreak = routines.fold<int>(
      0,
      (prev, r) => prev + r.streak,
    );
    final doneToday = routines.where((r) => r.completedToday).length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [BuddyColors.green, BuddyColors.gold],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _stat('Active routines', '$active', Colors.white),
          ),
          Container(width: 1, height: 36, color: Colors.white54),
          Expanded(
            child: _stat('Total streak', '$totalStreak', Colors.white),
          ),
          Container(width: 1, height: 36, color: Colors.white54),
          Expanded(
            child: _stat('Done today', '$doneToday', Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color.withValues(alpha: 0.9),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RoutineCard extends ConsumerWidget {
  final Routine routine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onHighlights;
  final VoidCallback onShare;

  const _RoutineCard({
    required this.routine,
    required this.onEdit,
    required this.onDelete,
    required this.onHighlights,
    required this.onShare,
  });

  static IconData _iconFor(String type) {
    switch (type) {
      case 'walk':
        return Icons.directions_walk;
      case 'run':
        return Icons.directions_run;
      case 'cycle':
        return Icons.directions_bike;
      case 'hike':
        return Icons.terrain;
      case 'workout':
        return Icons.fitness_center;
      case 'gym':
        return Icons.warehouse_outlined;
      default:
        return Icons.repeat_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final days = routine.days;
    final completedToday = routine.completedToday;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: completedToday
              ? BuddyColors.green.withValues(alpha: 0.5)
              : cs.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: double.infinity,
            decoration: BoxDecoration(
              color: BuddyColors.green.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
            ),
            child: Icon(_iconFor(routine.type as String? ?? 'other'),
                color: BuddyColors.green, size: 26),
          ),
          Expanded(
            child: InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            routine.displayName.isNotEmpty
                                ? routine.displayName
                                : (routine.name.isNotEmpty
                                    ? routine.name
                                    : 'Other'),
                            style: TextStyle(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (routine.autoGenerated) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: BuddyColors.green.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Auto',
                              style: TextStyle(
                                color: BuddyColors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department_outlined,
                            size: 13, color: BuddyColors.gold),
                        const SizedBox(width: 3),
                        Text(
                          '${routine.streak} streak',
                          style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.75),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${routine.target} ${routine.unit}',
                          style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (var i = 0; i < 7; i++)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Container(
                              width: 22,
                              height: 22,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: days.contains(i)
                                    ? BuddyColors.green.withValues(alpha: 0.2)
                                    : cs.surfaceContainerHighest,
                              ),
                              child: Text(
                                _dayShort[i],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: days.contains(i)
                                      ? BuddyColors.green
                                      : cs.onSurface
                                          .withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.icon(
                  onPressed: completedToday
                      ? null
                      : () => _checkIn(context, ref, routine.id),
                  style: FilledButton.styleFrom(
                    backgroundColor: BuddyColors.green,
                    foregroundColor: Theme.of(context).colorScheme.surface,
                    disabledBackgroundColor: BuddyColors.green.withValues(alpha: 0.25),
                    disabledForegroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
                    minimumSize: const Size(88, 40),
                  ),
                  icon: Icon(
                    completedToday ? Icons.check_rounded : Icons.check,
                    size: 18,
                  ),
                  label: Text(completedToday ? 'Done' : 'Check in'),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Routine options',
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                      case 'highlights':
                        onHighlights();
                      case 'share':
                        onShare();
                      case 'delete':
                        onDelete();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'highlights',
                      child: Row(children: [
                        Icon(Icons.photo_library_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('Highlights'),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'share',
                      child: Row(children: [
                        Icon(Icons.share_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('Share'),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline, size: 16),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkIn(BuildContext context, WidgetRef ref, String id) async {
    final created = await ref.read(routinesProvider.notifier).checkIn(id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(created == null ? 'Check-in failed' : 'Checked in — nice work!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
