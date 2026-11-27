import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../analytics/providers/analytics_provider.dart';
import '../../feed/providers/feed_provider.dart' show composerExpandRequestProvider;
import '../models/countdown_models.dart';
import '../providers/countdown_provider.dart';

/// Color map for template codes (falls back to template.color if not matched).
const Map<String, Color> _templateColors = {
  'sobriety': Color(0xFFEF4444),
  'no_artificial_sugars': Color(0xFFF59E0B),
  'no_animal_proteins': Color(0xFF22C55E),
  'gym_attendance': Color(0xFF3B82F6),
  'walking_days': Color(0xFF10B981),
  'no_drugs': Color(0xFFDC2626),
  'no_nut_month': Color(0xFFA855F7),
  'custom': Color(0xFF6B7280),
};

class CountdownsScreen extends ConsumerStatefulWidget {
  const CountdownsScreen({super.key});

  @override
  ConsumerState<CountdownsScreen> createState() => _CountdownsScreenState();
}

enum _CountdownFilter { all, active, completed, archived }

class _CountdownsScreenState extends ConsumerState<CountdownsScreen> {
  String? _creatingTemplateId;
  final TextEditingController _customReasonController = TextEditingController();
  int _targetCount = 0;
  bool _shareBusy = false;
  String _shareVisibility = 'public';
  final TextEditingController _shareCaptionController = TextEditingController();
  _CountdownFilter _filter = _CountdownFilter.all;
  String? _historyId;
  List<CountdownEvent> _history = const [];
  bool _historyLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(countdownsProvider.notifier).load());
  }

  @override
  void dispose() {
    _customReasonController.dispose();
    _shareCaptionController.dispose();
    super.dispose();
  }

  Color _colorFor(CountdownTemplate template) =>
      _templateColors[template.code] ??
      Color(int.tryParse(template.color.replaceAll('#', '0xFF')) ??
          0xFF6366f1);

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      return DateFormat('MMM d, yyyy').format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }

  /// Show the "new countdown" bottom sheet.
  void _showCreateSheet() {
    _customReasonController.clear();
    _targetCount = 0;
    setState(() => _creatingTemplateId = null);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: BuddyColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Consumer(
        builder: (_, _, _) {
          final templates = ref.watch(countdownsProvider).templates;
          final isLoading = ref.watch(countdownsProvider).isLoading;
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 20,
              bottom: MediaQuery.of(ctx).viewPadding.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'New Countdown',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Choose a reason',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in templates)
                      ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(t.icon, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 6),
                            Text(t.title),
                          ],
                        ),
                        selected: _creatingTemplateId == t.id,
                        onSelected: (_) =>
                            setState(() => _creatingTemplateId = t.id),
                        backgroundColor: BuddyColors.surface,
                        selectedColor: _colorFor(t).withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: _creatingTemplateId == t.id
                              ? _colorFor(t)
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: _creatingTemplateId == t.id
                                ? _colorFor(t)
                                : BuddyColors.border,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_creatingTemplateId != null &&
                    templates.any(
                      (t) => t.id == _creatingTemplateId &&
                          t.code == 'custom',
                    ))
                  _customField(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Target (optional)',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: TextEditingController(
                          text: _targetCount > 0 ? _targetCount.toString() : '',
                        ),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '0 = no target',
                          hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: BuddyColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: BuddyColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: BuddyColors.green,
                            ),
                          ),
                          fillColor: BuddyColors.surface,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (v) {
                          _targetCount = int.tryParse(v) ?? 0;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading ? null : () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                          side: const BorderSide(color: BuddyColors.border),
                          minimumSize: const Size(double.infinity, 44),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _creatingTemplateId == null || isLoading
                            ? null
                            : () async {
                              final t = templates.firstWhere(
                                (x) => x.id == _creatingTemplateId,
                                orElse: () => templates.first,
                              );
                              final custom = t.code == 'custom'
                                  ? _customReasonController.text.trim()
                                  : null;
                              if (t.code == 'custom' && custom!.isEmpty) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please enter a custom reason',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              Navigator.pop(ctx);
                              await ref
                                  .read(countdownsProvider.notifier)
                                  .create(
                                    templateId: _creatingTemplateId!,
                                    customReason: custom,
                                    targetCount: _targetCount,
                                  );
                              _customReasonController.clear();
                              _targetCount = 0;
                              setState(() => _creatingTemplateId = null);
                            },
                        style: FilledButton.styleFrom(
                          backgroundColor: BuddyColors.green,
                          foregroundColor: Theme.of(context).colorScheme.surface,
                          minimumSize: const Size(double.infinity, 44),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Create'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _customField() {
    return TextField(
      controller: _customReasonController,
      maxLines: 2,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'e.g. Days without coffee',
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BuddyColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BuddyColors.green),
        ),
        fillColor: BuddyColors.surface,
        filled: true,
        contentPadding: const EdgeInsets.all(14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(countdownsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Countdowns & Streaks'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(countdownsProvider.notifier).load(),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: ref.watch(countdownsProvider).isLoading ? null : _showCreateSheet,
            tooltip: 'New countdown',
          ),
        ],
      ),
      body: ref.watch(countdownsProvider).isLoading &&
              ref.watch(countdownsProvider).countdowns.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(countdownsProvider.notifier).load(),
              child: _buildBody(state),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: ref.watch(countdownsProvider).isLoading ? null : _showCreateSheet,
        backgroundColor: BuddyColors.green,
        foregroundColor: Theme.of(context).colorScheme.surface,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(CountdownsState state) {
    if (state.error != null && state.countdowns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => ref.read(countdownsProvider.notifier).load(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    bool matches(UserCountdown c) => switch (_filter) {
          _CountdownFilter.all => true,
          _CountdownFilter.active => c.isActive && c.completedAt == null,
          _CountdownFilter.completed => c.completedAt != null,
          _CountdownFilter.archived => !c.isActive && c.completedAt == null,
        };

    final visible = state.countdowns.where(matches).toList();
    final active = visible
        .where((c) => c.isActive && c.completedAt == null)
        .toList();
    final completed = visible.where((c) => c.completedAt != null).toList();
    final archived = visible
        .where((c) => !c.isActive && c.completedAt == null)
        .toList();

    Widget sectionHeader(String label) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final filter in _CountdownFilter.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(switch (filter) {
                      _CountdownFilter.all => 'All',
                      _CountdownFilter.active => 'Active',
                      _CountdownFilter.completed => 'Completed',
                      _CountdownFilter.archived => 'Archived',
                    }),
                    selected: _filter == filter,
                    selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                    onSelected: (_) => setState(() => _filter = filter),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_filter == _CountdownFilter.all) ...[
          if (active.isNotEmpty) ...[
            sectionHeader('Active'),
            ...active.map(_countdownCard),
            const SizedBox(height: 24),
          ],
          if (completed.isNotEmpty) ...[
            sectionHeader('Completed'),
            ...completed.map(_countdownCard),
            const SizedBox(height: 24),
          ],
          if (archived.isNotEmpty) ...[
            sectionHeader('Archived'),
            ...archived.map(_countdownCard),
          ],
        ] else ...[
          ...visible.map(_countdownCard),
        ],
        if (visible.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined,
                    size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(
                  state.countdowns.isEmpty
                      ? 'No countdowns yet'
                      : 'Nothing in this view',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.countdowns.isEmpty
                      ? 'Track sobriety, gym attendance, walking days and more.'
                      : 'Try another filter, or start a new countdown.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _countdownCard(UserCountdown c) {
    final isCompleted = c.completedAt != null;
    final color = _colorFor(
      c.templateDetail ??
          const CountdownTemplate(code: '', title: '', color: '#6B7280'),
    );
    final progress = c.progressPercent;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? BuddyColors.green.withValues(alpha: 0.3)
              : BuddyColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    c.displayIcon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.displayReason,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (c.templateDetail != null &&
                          c.templateDetail!.description.isNotEmpty)
                        Text(
                          c.templateDetail!.description,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: BuddyColors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Completed',
                      style: TextStyle(
                        color: BuddyColors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress / 100,
                minHeight: 6,
                backgroundColor: BuddyColors.border,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${c.currentCount} ${c.unit}${c.currentCount != 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (c.targetCount > 0)
                  Text(
                    'of ${c.targetCount}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                Text(
                  'Day ${c.daysSinceStart}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (!isCompleted && c.countdownType == 'manual') ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: ref.watch(countdownsProvider).isLoading ? null : () => _checkIn(c),
                      icon: const Icon(Icons.check_circle, size: 16),
                      label: const Text('Check in'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: BuddyColors.green,
                        side: const BorderSide(color: BuddyColors.green),
                        minimumSize: const Size(double.infinity, 36),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: ref.watch(countdownsProvider).isLoading ? null : () => _edit(c),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                      side: const BorderSide(color: BuddyColors.border),
                      minimumSize: const Size(double.infinity, 36),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: ref.watch(countdownsProvider).isLoading ? null : () => _reset(c),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Reset'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      minimumSize: const Size(double.infinity, 36),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (isCompleted)
                  TextButton.icon(
                    onPressed: ref.watch(countdownsProvider).isLoading
                        ? null
                        : () => _recreate(c),
                    icon: const Icon(Icons.replay, size: 14),
                    label: const Text('Recreate'),
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: BuddyColors.green,
                      ),
                    ),
                  ),
                TextButton.icon(
                  onPressed: () => _toggleHistory(c),
                  icon: const Icon(Icons.history, size: 14),
                  label: Text(_historyId == c.id ? 'Hide history' : 'History'),
                  style: TextButton.styleFrom(
                    textStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const Spacer(),
                if (isCompleted || c.countdownType == 'manual')
                  TextButton.icon(
                    onPressed: ref.watch(countdownsProvider).isLoading ? null : () => _shareCountdown(c),
                    icon: const Icon(Icons.share, size: 14),
                    label: const Text('Share'),
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: BuddyColors.green,
                      ),
                    ),
                  ),
              ],
            ),
            if (_historyId == c.id) _historyPanel(),
            const SizedBox(height: 8),
            Text(
              'Started ${_formatDate(c.startDate)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Load a countdown's stream — the log of every check-in, automatic advance,
  /// reset and completion. Mirrors the web History disclosure.
  Future<void> _toggleHistory(UserCountdown c) async {
    if (_historyId == c.id) {
      setState(() {
        _historyId = null;
        _history = const [];
      });
      return;
    }
    setState(() {
      _historyId = c.id;
      _history = const [];
      _historyLoading = true;
    });
    try {
      final raw = await ref
          .read(countdownRepositoryProvider)
          .listEvents(c.id, limit: 50);
      final data = raw is Map ? raw['data'] : raw;
      final events = (data is List ? data : const [])
          .whereType<Map>()
          .map((e) => CountdownEvent.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      if (mounted && _historyId == c.id) {
        setState(() => _history = events);
      }
    } catch (_) {
      if (mounted && _historyId == c.id) {
        setState(() => _history = const []);
      }
    } finally {
      if (mounted) setState(() => _historyLoading = false);
    }
  }

  String _eventLabel(String type) => switch (type) {
        'create' => 'Created',
        'checkin' => 'Checked in',
        'reset' => 'Reset',
        'auto_advance' => 'Advanced automatically',
        'complete' => 'Completed',
        'edit' => 'Edited',
        _ => type,
      };

  Widget _historyPanel() {
    if (_historyLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(
              'Loading history…',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }
    if (_history.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'No history yet — check in and it will appear here.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: BuddyColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final event in _history)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _eventLabel(event.eventType),
                      style: TextStyle(
                        color: event.eventType == 'reset'
                            ? Colors.red
                            : event.eventType == 'complete'
                                ? BuddyColors.green
                                : Theme.of(context).colorScheme.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${event.countAfter} ${event.unit}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    event.occurredAt == null
                        ? ''
                        : DateFormat('MMM d, HH:mm')
                            .format(event.occurredAt!.toLocal()),
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Start a fresh run from a completed countdown — the web "Recreate" action.
  Future<void> _recreate(UserCountdown c) async {
    final created = await ref.read(countdownsProvider.notifier).create(
          templateId: c.templateId ?? '',
          customReason: c.customReason,
          countdownType: c.countdownType,
          unit: c.unit,
          targetCount: c.targetCount,
        );
    if (created == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(countdownsProvider).error ?? 'Could not recreate that countdown.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Share a countdown back into the feed — mirrors the web composer hand-off:
  /// prepare a share draft, then drop the user on the inline composer with it.
  Future<void> _shareCountdown(UserCountdown c) async {
    final pct = c.progressPercent;
    final target = c.targetCount;
    _shareVisibility = 'public';
    _shareCaptionController.text = [
      c.displayReason,
      target > 0 ? '${c.currentCount} / $target ${c.unit}' : '${c.currentCount} ${c.unit}',
      'Progress: ${pct.toStringAsFixed(0)}%',
      '#BuddyUp #Countdown #Streak',
    ].join('\n');
    setState(() {});

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: BuddyColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Share countdown',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                c.displayReason,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final v in const ['public', 'buddies', 'private'])
                    OutlinedButton(
                      onPressed: _shareBusy ? null : () => setState(() => _shareVisibility = v),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _shareVisibility == v
                              ? BuddyColors.green
                              : Theme.of(context).colorScheme.outlineVariant,
                        ),
                        foregroundColor: _shareVisibility == v
                            ? BuddyColors.green
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      child: Text(
                        v == 'public' ? 'Public' : v == 'buddies' ? 'Buddies' : 'Private',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _shareCaptionController,
                decoration: const InputDecoration(
                  labelText: 'Caption',
                  hintText: 'Say something about this countdown…',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _shareBusy
                    ? null
                    : () async {
                        setState(() => _shareBusy = true);
                        try {
                          await ref
                              .read(analyticsRepositoryProvider)
                              .sharePrepare(
                            {
                              'kind': 'countdown',
                              'obj_id': c.id,
                              'visibility': _shareVisibility,
                              'body': _shareCaptionController.text,
                            },
                          );
                          if (!mounted) return;
                          Navigator.of(context).pop<void>();
                          ref.read(composerExpandRequestProvider.notifier).bump();
                          context.go('/feed');
                        } catch (_) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Could not prepare that countdown for sharing.')),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _shareBusy = false);
                        }
                      },
                child: _shareBusy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: BuddyColors.black,
                        ),
                      )
                    : const Text('Share'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkIn(UserCountdown c) async {
    final ok = await ref.read(countdownsProvider.notifier).checkIn(c.id);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(countdownsProvider).error ?? 'Check-in failed',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _reset(UserCountdown c) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BuddyColors.surface,
        title: const Text('Reset countdown?'),
        content: Text(
          'This will set your progress back to zero.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Theme.of(context).colorScheme.surface,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await ref.read(countdownsProvider.notifier).reset(c.id);
    }
  }

  Future<void> _edit(UserCountdown c) async {
    _customReasonController.text = c.customReason;
    _targetCount = c.targetCount;
    setState(() => _creatingTemplateId = c.templateId);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: BuddyColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: MediaQuery.of(ctx).viewPadding.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Countdown',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Reason',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _customReasonController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: c.displayReason,
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: BuddyColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: BuddyColors.green),
                ),
                fillColor: BuddyColors.surface,
                filled: true,
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Target',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: TextEditingController(
                      text: c.targetCount > 0
                          ? c.targetCount.toString()
                          : '',
                    ),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '0 = no target',
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: BuddyColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: BuddyColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: BuddyColors.green),
                      ),
                      fillColor: BuddyColors.surface,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (v) {
                      _targetCount = int.tryParse(v) ?? 0;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                      side: const BorderSide(color: BuddyColors.border),
                      minimumSize: const Size(double.infinity, 44),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: ref.watch(countdownsProvider).isLoading
                        ? null
                        : () async {
                          final reason = _customReasonController.text.trim();
                          await ref
                              .read(countdownsProvider.notifier)
                              .update(
                                c.id,
                                UpdateUserCountdown(
                                  customReason: reason.isNotEmpty
                                      ? reason
                                      : null,
                                  targetCount: _targetCount > 0
                                      ? _targetCount
                                      : null,
                                ),
                              );
                          if (ctx.mounted) Navigator.pop(ctx);
                          _customReasonController.clear();
                          _targetCount = 0;
                          setState(() => _creatingTemplateId = null);
                        },
                    style: FilledButton.styleFrom(
                      backgroundColor: BuddyColors.green,
                      foregroundColor: Theme.of(context).colorScheme.surface,
                      minimumSize: const Size(double.infinity, 44),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
