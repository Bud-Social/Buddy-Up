import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/marketplace.dart';

class ProgrammeActivityFocusScreen extends ConsumerStatefulWidget {
  final String programmeId;
  final int weekIndex;
  final String day;
  final int activityIndex;

  const ProgrammeActivityFocusScreen({
    super.key,
    required this.programmeId,
    required this.weekIndex,
    required this.day,
    required this.activityIndex,
  });

  @override
  ConsumerState<ProgrammeActivityFocusScreen> createState() =>
      _ProgrammeActivityFocusScreenState();
}

class _ProgrammeActivityFocusScreenState
    extends ConsumerState<ProgrammeActivityFocusScreen> {
  bool _isCompleted = false;
  int _currentSection = 0;
  final List<String> _sections = ['Overview', 'Instructions', 'Tips & Cautions', 'Notes'];

  @override
  Widget build(BuildContext context) {
    final programmeAsync = ref.watch(programmeDetailProvider(widget.programmeId));

    return programmeAsync.when(
      data: (programme) {
        final activity = _extractActivity(programme);
        if (activity == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Activity')),
            body: const Center(child: Text('Activity not found')),
          );
        }

        return Scaffold(
          backgroundColor: BuddyColors.black,
          body: CustomScrollView(
            slivers: [
              _buildAppBar(activity),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Completion banner
                    if (_isCompleted)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        color: BuddyColors.green.withValues(alpha: 0.15),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle, color: BuddyColors.green, size: 20),
                            SizedBox(width: 8),
                            Text('Activity completed! Great work! 💪',
                                style: TextStyle(
                                    color: BuddyColors.green, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),

                    // Stats row
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          _StatChip(Icons.timer_outlined,
                              '${activity['duration_minutes'] ?? 30} min'),
                          const SizedBox(width: 8),
                          _StatChip(Icons.repeat, '${activity['sets'] ?? 3} sets'),
                          const SizedBox(width: 8),
                          _StatChip(Icons.fitness_center, '${activity['reps'] ?? 10} reps'),
                          if ((activity['session_type'] ?? '').isNotEmpty) ...[
                            const SizedBox(width: 8),
                            _StatChip(Icons.wb_sunny_outlined,
                                activity['session_type'] as String? ?? 'Morning'),
                          ],
                        ],
                      ),
                    ),

                    // Section tabs
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _sections.asMap().entries.map((entry) {
                            final isSelected = _currentSection == entry.key;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _currentSection = entry.key),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? BuddyColors.green
                                        : BuddyColors.surface,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? Colors.black : BuddyColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    _buildSection(activity),

                    const SizedBox(height: 24),
                    // Mark complete button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => setState(() => _isCompleted = !_isCompleted),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _isCompleted ? BuddyColors.surfaceRaised : BuddyColors.green,
                            foregroundColor:
                                _isCompleted ? BuddyColors.textSecondary : Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(
                            _isCompleted ? '✓ Completed' : 'Mark as Complete',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Activity')),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildAppBar(Map<String, dynamic> activity) {
    final name = activity['name'] as String? ?? 'Activity';
    final videoUrl = activity['video_url'] as String? ?? '';

    return SliverAppBar(
      expandedHeight: videoUrl.isNotEmpty ? 200 : 120,
      pinned: true,
      backgroundColor: BuddyColors.surface,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        background: videoUrl.isNotEmpty
            ? Stack(fit: StackFit.expand, children: [
                Container(
                  color: BuddyColors.surfaceRaised,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_outline, size: 56, color: BuddyColors.green),
                      SizedBox(height: 8),
                      Text('Tap to play video',
                          style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black54],
                    ),
                  ),
                ),
              ])
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF60A5FA).withValues(alpha: 0.4),
                      BuddyColors.surface,
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.fitness_center, size: 48, color: BuddyColors.textSecondary),
                ),
              ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isCompleted ? Icons.check_circle : Icons.check_circle_outline,
            color: _isCompleted ? BuddyColors.green : null,
          ),
          onPressed: () => setState(() => _isCompleted = !_isCompleted),
        ),
      ],
    );
  }

  Widget _buildSection(Map<String, dynamic> activity) {
    switch (_currentSection) {
      case 0: // Overview
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('About This Activity',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Text(
              (activity['description'] as String?)?.isNotEmpty == true
                  ? activity['description'] as String
                  : 'No description provided.',
              style: const TextStyle(color: BuddyColors.textSecondary, height: 1.6),
            ),
            if ((activity['relevance'] as String?)?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              _InfoBlock('Why This Activity?', activity['relevance'] as String,
                  Icons.lightbulb_outline, const Color(0xFFFBBF24)),
            ],
            if ((activity['side_effects'] as String?)?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              _InfoBlock('Side Effects', activity['side_effects'] as String,
                  Icons.info_outline, const Color(0xFF60A5FA)),
            ],
          ]),
        );

      case 1: // Instructions
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('How To Do It', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            if ((activity['transcript'] as String?)?.isNotEmpty == true)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: BuddyColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(activity['transcript'] as String,
                    style: const TextStyle(height: 1.7, fontSize: 14)),
              )
            else
              const Text('Detailed instructions not provided.',
                  style: TextStyle(color: BuddyColors.textSecondary)),
            if ((activity['diy'] as String?)?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              _InfoBlock('DIY Modification', activity['diy'] as String,
                  Icons.build_outlined, BuddyColors.green),
            ],
          ]),
        );

      case 2: // Tips & Cautions
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if ((activity['tips'] as String?)?.isNotEmpty == true) ...[
              _InfoBlock('Tips 💡', activity['tips'] as String, Icons.lightbulb_outline, BuddyColors.green),
              const SizedBox(height: 12),
            ],
            if ((activity['cautions'] as String?)?.isNotEmpty == true) ...[
              _InfoBlock('Cautions ⚠️', activity['cautions'] as String,
                  Icons.warning_amber_outlined, const Color(0xFFFBBF24)),
              const SizedBox(height: 12),
            ],
            if ((activity['tips'] == null || (activity['tips'] as String).isEmpty) &&
                (activity['cautions'] == null || (activity['cautions'] as String).isEmpty))
              const Text('No tips or cautions provided.',
                  style: TextStyle(color: BuddyColors.textSecondary)),
          ]),
        );

      case 3: // Notes
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Your Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextFormField(
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Write your personal notes here...',
                filled: true,
                fillColor: BuddyColors.surface,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ]),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Map<String, dynamic>? _extractActivity(TrainingProgramme programme) {
    // programme.schedule is Map<String, dynamic> where keys are week numbers
    // Access: schedule[weekIndex][day][activityIndex]
    try {
      final weekData = (programme as dynamic).schedule;
      if (weekData == null) return null;
      final weekMap = weekData['${widget.weekIndex}'] as Map<String, dynamic>?;
      if (weekMap == null) return null;
      final dayActivities = weekMap[widget.day] as List<dynamic>?;
      if (dayActivities == null || widget.activityIndex >= dayActivities.length) return null;
      return dayActivities[widget.activityIndex] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Icon(icon, size: 14, color: BuddyColors.textSecondary),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 12, color: BuddyColors.textSecondary)),
      ]),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;

  const _InfoBlock(this.title, this.content, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
        ]),
        const SizedBox(height: 8),
        Text(content, style: const TextStyle(height: 1.6, fontSize: 13)),
      ]),
    );
  }
}
