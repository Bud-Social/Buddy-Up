import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/messaging.dart';
import '../providers/community_activities_provider.dart';

/// Events, lives and schedule slots for a community, mirroring the web
/// "Activities" tab. Members get read access (plus anyone viewing a public
/// community); only owner/admin can create or remove.
class CommunityActivitiesScreen extends ConsumerWidget {
  final String communityId;
  final String communityName;
  final bool canManage;

  const CommunityActivitiesScreen({
    super.key,
    required this.communityId,
    required this.communityName,
    this.canManage = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(communityActivitiesProvider(communityId));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('$communityName · Activities'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.event), text: 'Events'),
              Tab(icon: Icon(Icons.radio), text: 'Lives'),
              Tab(icon: Icon(Icons.schedule), text: 'Schedules'),
            ],
          ),
        ),
        floatingActionButton: canManage
            ? Builder(
                builder: (context) => FloatingActionButton(
                      backgroundColor: BuddyColors.green,
                      foregroundColor: BuddyColors.black,
                      onPressed: () => _openCreate(context, ref),
                      child: const Icon(Icons.add),
                    ),
              )
            : null,
        body: async.when(
          loading: () =>
              const Center(child: CircularProgressIndicator(color: BuddyColors.green)),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Could not load activities: $e', textAlign: TextAlign.center),
            ),
          ),
          data: (state) => TabBarView(
            children: [
              _EventList(
                communityId: communityId,
                canManage: canManage,
                events: state.events.where((e) => !e.isCancelled).toList(),
              ),
              _LiveList(
                communityId: communityId,
                canManage: canManage,
                lives: state.lives.toList(),
              ),
              _ScheduleList(
                communityId: communityId,
                canManage: canManage,
                slots: state.schedules.toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCreate(BuildContext context, WidgetRef ref) {
    final tabIndex = DefaultTabController.of(context).index;
    switch (tabIndex) {
      case 0:
        _showEventForm(context, ref);
      case 1:
        _showLiveForm(context, ref);
      default:
        _showScheduleForm(context, ref);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static DateTime? _parse(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    try {
      return DateTime.parse(iso).toLocal();
    } catch (_) {
      return null;
    }
  }

  static String _fmtDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${weekdays[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]}, $hour12:$minute $ampm';
  }

  String _dtOrNull(DateTime? dt) => dt?.toUtc().toIso8601String() ?? '';

  // ── Event form ─────────────────────────────────────────────────────────────

  void _showEventForm(BuildContext context, WidgetRef ref) {
    final titleC = TextEditingController();
    final descC = TextEditingController();
    final locationC = TextEditingController();
    final onlineC = TextEditingController();
    String eventType = 'in_person';
    bool isFree = true;
    DateTime? start;
    DateTime? end;

    Future<void> pickDateTime(BuildContext ctx, bool isEnd) async {
      final now = DateTime.now();
      final base = start ?? now;
      final date = await showDatePicker(
        context: ctx,
        initialDate: base.add(const Duration(days: 1)),
        firstDate: now,
        lastDate: now.add(const Duration(days: 365 * 2)),
      );
      if (!ctx.mounted || date == null) return;
      final time = await showTimePicker(
        context: ctx,
        initialTime: const TimeOfDay(hour: 9, minute: 0),
      );
      if (time == null) return;
      final picked =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (isEnd) {
        end = picked;
      } else {
        start = picked;
        end ??= picked.add(const Duration(hours: 2));
      }
    }

    Widget chip(String value, String label, String current, VoidCallback onTap) {
      final selected = value == current;
      return ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: BuddyColors.green.withValues(alpha: 0.25),
        labelStyle: TextStyle(
          color: selected ? BuddyColors.green : BuddyColors.textSecondary,
          fontSize: 11,
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Add community event',
                      style: Theme.of(ctx).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  TextField(
                    controller: titleC,
                    decoration: const InputDecoration(labelText: 'Title'),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descC,
                    decoration: const InputDecoration(labelText: 'Description (optional)'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: [
                      chip('in_person', 'In person', eventType,
                          () => setSheetState(() => eventType = 'in_person')),
                      chip('online', 'Online', eventType,
                          () => setSheetState(() => eventType = 'online')),
                      chip('hybrid', 'Hybrid', eventType,
                          () => setSheetState(() => eventType = 'hybrid')),
                    ],
                  ),
                  if (eventType != 'online')
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextField(
                        controller: locationC,
                        decoration: const InputDecoration(labelText: 'Location'),
                      ),
                    ),
                  if (eventType != 'in_person')
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextField(
                        controller: onlineC,
                        decoration: const InputDecoration(labelText: 'Online link (optional)'),
                        keyboardType: TextInputType.url,
                      ),
                    ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(start == null
                        ? 'Pick start'
                        : 'Starts ${_fmtDate(start!)}'),
                    trailing: const Icon(Icons.calendar_today, size: 18),
                    onTap: () async {
                      await pickDateTime(ctx, false);
                      setSheetState(() {});
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(end == null ? 'Pick end' : 'Ends ${_fmtDate(end!)}'),
                    trailing: const Icon(Icons.calendar_today, size: 18),
                    onTap: () async {
                      await pickDateTime(ctx, true);
                      setSheetState(() {});
                    },
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: isFree,
                    onChanged: (v) => setSheetState(() => isFree = v ?? true),
                    title: const Text('Free to attend'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BuddyColors.green,
                            foregroundColor: BuddyColors.black,
                          ),
                          onPressed: (titleC.text.trim().isEmpty || start == null || end == null)
                              ? null
                              : () async {
                                  final notifier = ref.read(
                                    communityActivitiesProvider(communityId).notifier,
                                  );
                                  try {
                                    await notifier.createEvent({
                                      'title': titleC.text.trim(),
                                      'description': descC.text.trim(),
                                      'event_type': eventType,
                                      'location': locationC.text.trim(),
                                      if (onlineC.text.trim().isNotEmpty)
                                        'online_url': onlineC.text.trim(),
                                      'start_datetime': _dtOrNull(start),
                                      'end_datetime': _dtOrNull(end),
                                      'is_free': isFree,
                                    });
                                    if (ctx.mounted) Navigator.pop(ctx);
                                  } catch (e) {
                                    if (ctx.mounted) {
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        SnackBar(content: Text('Could not add event: $e')),
                                      );
                                    }
                                  }
                                },
                          child: const Text('Add event'),
                        ),
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

  // ── Live form ──────────────────────────────────────────────────────────────

  void _showLiveForm(BuildContext context, WidgetRef ref) {
    final titleC = TextEditingController();
    final categoryC = TextEditingController(text: 'fitness');
    String liveType = 'buddy_circle';
    String access = 'public';
    DateTime? scheduled;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          Future<void> pickScheduled() async {
            final now = DateTime.now();
            final date = await showDatePicker(
              context: ctx,
              initialDate: now.add(const Duration(days: 1)),
              firstDate: now,
              lastDate: now.add(const Duration(days: 365)),
            );
            if (!ctx.mounted || date == null) return;
            final time = await showTimePicker(
              context: ctx,
              initialTime: const TimeOfDay(hour: 10, minute: 0),
            );
            if (time == null) return;
            setSheetState(() => scheduled =
                DateTime(date.year, date.month, date.day, time.hour, time.minute));
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(
              16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Schedule a live',
                      style: Theme.of(ctx).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  TextField(
                    controller: titleC,
                    decoration: const InputDecoration(labelText: 'Title (e.g. Mobility Q&A)'),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: categoryC,
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: liveType,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: const [
                      DropdownMenuItem(value: 'buddy_circle', child: Text('Buddy circle')),
                      DropdownMenuItem(value: 'open_sweat', child: Text('Open sweat')),
                      DropdownMenuItem(value: 'audio', child: Text('Audio live')),
                    ],
                    onChanged: (v) => setSheetState(() => liveType = v ?? 'buddy_circle'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: access,
                    decoration: const InputDecoration(labelText: 'Audience'),
                    items: const [
                      DropdownMenuItem(value: 'public', child: Text('Public')),
                      DropdownMenuItem(value: 'buddies', child: Text('Buddies only')),
                      DropdownMenuItem(value: 'private', child: Text('Only me')),
                    ],
                    onChanged: (v) => setSheetState(() => access = v ?? 'public'),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(scheduled == null
                        ? 'Pick start time'
                        : 'Starts ${_fmtDate(scheduled!)}'),
                    trailing: const Icon(Icons.calendar_today, size: 18),
                    onTap: pickScheduled,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BuddyColors.green,
                            foregroundColor: BuddyColors.black,
                          ),
                          onPressed: titleC.text.trim().isEmpty
                              ? null
                              : () async {
                                  final notifier = ref.read(
                                    communityActivitiesProvider(communityId).notifier,
                                  );
                                  try {
                                    await notifier.createLive({
                                      'title': titleC.text.trim(),
                                      'live_type': liveType,
                                      'category': categoryC.text.trim(),
                                      'access': access,
                                      'scheduled_for': _dtOrNull(scheduled),
                                    });
                                    if (ctx.mounted) Navigator.pop(ctx);
                                  } catch (e) {
                                    if (ctx.mounted) {
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        SnackBar(content: Text('Could not schedule: $e')),
                                      );
                                    }
                                  }
                                },
                          child: const Text('Schedule live'),
                        ),
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

  // ── Schedule form ──────────────────────────────────────────────────────────

  void _showScheduleForm(BuildContext context, WidgetRef ref) {
    final titleC = TextEditingController();
    final contentC = TextEditingController();
    final customC = TextEditingController();
    final slotsC = TextEditingController(text: '0');
    String activityType = 'other';
    String locationMode = 'in_house';
    String recurrence = 'none';
    DateTime? start;
    DateTime? end;

    Future<void> pickDateTime(BuildContext ctx, bool isEnd) async {
      final now = DateTime.now();
      final date = await showDatePicker(
        context: ctx,
        initialDate: now.add(const Duration(days: 1)),
        firstDate: now,
        lastDate: now.add(const Duration(days: 365)),
      );
      if (!ctx.mounted || date == null) return;
      final time = await showTimePicker(
        context: ctx,
        initialTime: const TimeOfDay(hour: 9, minute: 0),
      );
      if (time == null) return;
      final picked =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (isEnd) {
        end = picked;
      } else {
        start = picked;
        end ??= picked.add(const Duration(hours: 1));
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Add a session',
                      style: Theme.of(ctx).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  TextField(
                    controller: titleC,
                    decoration: const InputDecoration(labelText: 'Session title'),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: contentC,
                    decoration: const InputDecoration(labelText: 'Details (optional)'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: activityType,
                    decoration: const InputDecoration(labelText: 'Activity'),
                    items: const [
                      DropdownMenuItem(value: 'strength', child: Text('Strength')),
                      DropdownMenuItem(value: 'cardio', child: Text('Cardio')),
                      DropdownMenuItem(value: 'yoga', child: Text('Yoga')),
                      DropdownMenuItem(value: 'hiit', child: Text('HIIT')),
                      DropdownMenuItem(value: 'session', child: Text('Session')),
                      DropdownMenuItem(value: 'live_stream', child: Text('Live stream')),
                      DropdownMenuItem(value: 'workshop', child: Text('Workshop')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: (v) => setSheetState(() => activityType = v ?? 'other'),
                  ),
                  if (activityType == 'other')
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextField(
                        controller: customC,
                        decoration: const InputDecoration(labelText: 'Custom activity'),
                      ),
                    ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: locationMode,
                    decoration: const InputDecoration(labelText: 'Where'),
                    items: const [
                      DropdownMenuItem(value: 'in_house', child: Text('In person')),
                      DropdownMenuItem(value: 'online', child: Text('Online')),
                      DropdownMenuItem(value: 'hybrid', child: Text('Hybrid')),
                    ],
                    onChanged: (v) => setSheetState(() => locationMode = v ?? 'in_house'),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(start == null ? 'Starts' : 'Starts ${_fmtDate(start!)}'),
                    trailing: const Icon(Icons.calendar_today, size: 18),
                    onTap: () async {
                      await pickDateTime(ctx, false);
                      setSheetState(() {});
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(end == null ? 'Ends' : 'Ends ${_fmtDate(end!)}'),
                    trailing: const Icon(Icons.calendar_today, size: 18),
                    onTap: () async {
                      await pickDateTime(ctx, true);
                      setSheetState(() {});
                    },
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: recurrence,
                    decoration: const InputDecoration(labelText: 'Repeats'),
                    items: const [
                      DropdownMenuItem(value: 'none', child: Text('Does not repeat')),
                      DropdownMenuItem(value: 'daily', child: Text('Daily')),
                      DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                      DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                    ],
                    onChanged: (v) => setSheetState(() => recurrence = v ?? 'none'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: slotsC,
                    decoration: const InputDecoration(labelText: 'Max slots (0 = unlimited)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BuddyColors.green,
                            foregroundColor: BuddyColors.black,
                          ),
                          onPressed: () async {
                            final notifier = ref.read(
                              communityActivitiesProvider(communityId).notifier,
                            );
                            try {
                              await notifier.createSchedule({
                                'title': titleC.text.trim(),
                                'content': contentC.text.trim(),
                                'activity_type': activityType,
                                'custom_activity_type': customC.text.trim(),
                                'location_mode': locationMode,
                                'start_time': _dtOrNull(start),
                                'end_time': _dtOrNull(end),
                                'recurrence': recurrence,
                                'max_slots': int.tryParse(slotsC.text.trim()) ?? 0,
                              });
                              if (ctx.mounted) Navigator.pop(ctx);
                            } catch (e) {
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(content: Text('Could not add session: $e')),
                                );
                              }
                            }
                          },
                          child: const Text('Add session'),
                        ),
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
}

// ── Event list ────────────────────────────────────────────────────────────────

class _EventList extends ConsumerWidget {
  final String communityId;
  final bool canManage;
  final List<CommunityEvent> events;

  const _EventList({
    required this.communityId,
    required this.canManage,
    required this.events,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (events.isEmpty) {
      return const _EmptyState(icon: Icons.event, text: 'No upcoming events.');
    }
    return RefreshIndicator(
      color: BuddyColors.green,
      onRefresh: () =>
          ref.read(communityActivitiesProvider(communityId).notifier).reload(),
      child: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return _ActivityCard(
            leading: const Icon(Icons.event, color: BuddyColors.green),
            title: event.title,
            subtitle: [
              CommunityActivitiesScreen._fmtDate(
                CommunityActivitiesScreen._parse(event.startDatetime) ?? DateTime.now(),
              ),
              if (event.location.isNotEmpty) event.location,
              if (event.onlineUrl.isNotEmpty) 'online',
            ].join(' · '),
            trailing: canManage
                ? IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: BuddyColors.red,
                    onPressed: () => _confirmDelete(
                      context,
                      ref,
                      () => ref
                          .read(communityActivitiesProvider(communityId).notifier)
                          .deleteEvent(event.id),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() delete,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove this activity?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: BuddyColors.red)),
          ),
        ],
      ),
    );
    if (ok == true) await delete();
  }
}

// ── Live list ─────────────────────────────────────────────────────────────────

class _LiveList extends ConsumerWidget {
  final String communityId;
  final bool canManage;
  final List<CommunityLive> lives;

  const _LiveList({
    required this.communityId,
    required this.canManage,
    required this.lives,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (lives.isEmpty) {
      return const _EmptyState(icon: Icons.radio, text: 'No lives scheduled.');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: lives.length,
      itemBuilder: (context, index) {
        final live = lives[index];
        final isLive = live.status == 'live';
        return _ActivityCard(
          leading: Icon(
            isLive ? Icons.radio : Icons.videocam_outlined,
            color: isLive ? BuddyColors.red : BuddyColors.green,
          ),
          title: live.title,
          subtitle: [
            if (isLive)
              'Live now'
            else if (live.scheduledFor != null)
              CommunityActivitiesScreen._fmtDate(
                CommunityActivitiesScreen._parse(live.scheduledFor) ?? DateTime.now(),
              ),
            live.liveType.replaceAll('_', ' '),
          ].join(' · '),
          trailing: canManage
              ? IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: BuddyColors.red,
                  onPressed: () => _confirmDelete(
                    context,
                    ref,
                    () => ref
                        .read(communityActivitiesProvider(communityId).notifier)
                        .deleteLive(live.id),
                  ),
                )
              : null,
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() delete,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove this live?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: BuddyColors.red)),
          ),
        ],
      ),
    );
    if (ok == true) await delete();
  }
}

// ── Schedule list ─────────────────────────────────────────────────────────────

class _ScheduleList extends ConsumerWidget {
  final String communityId;
  final bool canManage;
  final List<CommunitySchedule> slots;

  const _ScheduleList({
    required this.communityId,
    required this.canManage,
    required this.slots,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (slots.isEmpty) {
      return const _EmptyState(icon: Icons.schedule, text: 'No sessions scheduled.');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final title = slot.title.isNotEmpty
            ? slot.title
            : slot.customActivityType.isNotEmpty
                ? slot.customActivityType
                : slot.activityType;
        return _ActivityCard(
          leading: const Icon(Icons.schedule, color: BuddyColors.gold),
          title: title,
          subtitle: [
            if (slot.startTime != null)
              CommunityActivitiesScreen._fmtDate(
                CommunityActivitiesScreen._parse(slot.startTime) ?? DateTime.now(),
              ),
            if (slot.recurrence != 'none') 'repeats ${slot.recurrence}',
            if (slot.maxSlots > 0) '${slot.maxSlots} slots',
          ].join(' · '),
          trailing: canManage
              ? IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: BuddyColors.red,
                  onPressed: () => _confirmDelete(
                    context,
                    ref,
                    () => ref
                        .read(communityActivitiesProvider(communityId).notifier)
                        .deleteSchedule(slot.id),
                  ),
                )
              : null,
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() delete,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: BuddyColors.red)),
          ),
        ],
      ),
    );
    if (ok == true) await delete();
  }
}

// ── Shared bits ───────────────────────────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _ActivityCard({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: BuddyColors.surfaceRaised,
          child: leading,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: trailing,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyState({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: BuddyColors.textSecondary),
          const SizedBox(height: 10),
          Text(text, style: const TextStyle(color: BuddyColors.textSecondary)),
        ],
      ),
    );
  }
}
