import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
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

class _CountdownsScreenState extends ConsumerState<CountdownsScreen> {
  String? _creatingTemplateId;
  final TextEditingController _customReasonController = TextEditingController();
  int _targetCount = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(countdownsProvider.notifier).load());
  }

  @override
  void dispose() {
    _customReasonController.dispose();
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
                const Text(
                  'Choose a reason',
                  style: TextStyle(
                    color: BuddyColors.textSecondary,
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
                              : BuddyColors.textSecondary,
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
                    const Expanded(
                      child: Text(
                        'Target (optional)',
                        style: TextStyle(
                          color: BuddyColors.textSecondary,
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
                            color: BuddyColors.textSecondary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: BuddyColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: BuddyColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
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
                          foregroundColor: BuddyColors.textSecondary,
                          side: BorderSide(color: BuddyColors.border),
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
                          foregroundColor: BuddyColors.black,
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
          color: BuddyColors.textSecondary.withValues(alpha: 0.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: BuddyColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: BuddyColors.green),
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
      backgroundColor: BuddyColors.black,
      appBar: AppBar(
        title: const Text('Countdowns & Streaks'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(countdownsProvider.notifier).load(isActive: true),
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
              onRefresh: () =>
                  ref.read(countdownsProvider.notifier).load(isActive: true),
              child: _buildBody(state),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: ref.watch(countdownsProvider).isLoading ? null : _showCreateSheet,
        backgroundColor: BuddyColors.green,
        foregroundColor: BuddyColors.black,
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

    final active = state.countdowns.where((c) => c.isActive).toList();
    final completed = state.countdowns.where((c) => !c.isActive).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Active countdowns section
        if (active.isNotEmpty) ...[
          const Text(
            'Active',
            style: TextStyle(
              color: BuddyColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...active.map((c) => _countdownCard(c, isCompleted: false)),
          const SizedBox(height: 24),
        ],
        // Completed countdowns section
        if (completed.isNotEmpty) ...[
          const Text(
            'Completed',
            style: TextStyle(
              color: BuddyColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...completed.map((c) => _countdownCard(c, isCompleted: true)),
        ],
        if (state.countdowns.isEmpty)
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined,
                    size: 64, color: BuddyColors.textSecondary),
                SizedBox(height: 16),
                Text(
                  'No countdowns yet',
                  style: TextStyle(
                    color: BuddyColors.textSecondary,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Track sobriety, gym attendance, walking days and more.',
                  style: TextStyle(color: BuddyColors.textSecondary),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _countdownCard(UserCountdown c, {required bool isCompleted}) {
    final color = _colorFor(
      c.templateDetail ?? CountdownTemplate(code: '', title: '', color: '#6B7280'),
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
                            color: BuddyColors.textSecondary,
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
                      color: BuddyColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                Text(
                  'Day ${c.daysSinceStart}',
                  style: TextStyle(
                    color: BuddyColors.textSecondary,
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
                        side: BorderSide(color: BuddyColors.green),
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
                      foregroundColor: BuddyColors.textSecondary,
                      side: BorderSide(color: BuddyColors.border),
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
                      side: BorderSide(color: Colors.red),
                      minimumSize: const Size(double.infinity, 36),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Started ${_formatDate(c.startDate)}',
              style: TextStyle(
                color: BuddyColors.textSecondary.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          ],
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
        content: const Text(
          'This will set your progress back to zero.',
          style: TextStyle(color: BuddyColors.textSecondary),
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
              foregroundColor: BuddyColors.black,
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
            const Text(
              'Reason',
              style: TextStyle(
                color: BuddyColors.textSecondary,
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
                  color: BuddyColors.textSecondary.withValues(alpha: 0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: BuddyColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: BuddyColors.green),
                ),
                fillColor: BuddyColors.surface,
                filled: true,
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Target',
                    style: TextStyle(
                      color: BuddyColors.textSecondary,
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
                        color: BuddyColors.textSecondary.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: BuddyColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: BuddyColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: BuddyColors.green),
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
                      foregroundColor: BuddyColors.textSecondary,
                      side: BorderSide(color: BuddyColors.border),
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
                      foregroundColor: BuddyColors.black,
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
