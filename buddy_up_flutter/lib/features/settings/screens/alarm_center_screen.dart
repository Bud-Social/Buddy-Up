import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/alarm.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/toast.dart';
import '../providers/alarm_providers.dart';

/// Settings → Alarm Center: alarms, custom sounds, buddy shares and
/// suggestions. Mirrors the web Alarm Center against the same API.
class AlarmCenterScreen extends ConsumerWidget {
  const AlarmCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarms = ref.watch(alarmsProvider);
    final sounds = ref.watch(alarmSoundsProvider);
    final shares = ref.watch(alarmSharesInboxProvider);
    final suggestions = ref.watch(alarmSuggestionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Alarm Center')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(alarmsProvider);
          ref.invalidate(alarmSoundsProvider);
          ref.invalidate(alarmSharesInboxProvider);
          ref.invalidate(alarmSuggestionsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _AlarmsCard(alarms: alarms, sounds: sounds),
            const SizedBox(height: 12),
            _SoundsCard(sounds: sounds),
            const SizedBox(height: 12),
            _SharesCard(shares: shares),
            const SizedBox(height: 12),
            _SuggestionsCard(suggestions: suggestions),
            const SizedBox(height: 12),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How alarms work',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 6),
                    Text(
                      'Alarms ring anywhere in BuddyUp while the app is open — '
                      'no need to sit on this page. One-off alarms switch '
                      'themselves off after ringing; repeating alarms re-arm '
                      'for their next day. Keep the app open and your volume '
                      'up, and keep a backup alarm on your phone clock for '
                      'mission-critical wake-ups.',
                      style: TextStyle(
                          fontSize: 12, color: BuddyColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Alarms ─────────────────────────────────────────────────────────────────

class _AlarmsCard extends ConsumerWidget {
  const _AlarmsCard({required this.alarms, required this.sounds});

  final AsyncValue<List<Alarm>> alarms;
  final AsyncValue<List<AlarmSound>> sounds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(alarmRepositoryProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My alarms',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            alarms.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (e, _) => Text(
                apiErrorMessage(e, fallback: 'Could not load your alarms.'),
                style: const TextStyle(
                    fontSize: 12, color: BuddyColors.textSecondary),
              ),
              data: (rows) => rows.isEmpty
                  ? const EmptyState(
                      icon: Icons.alarm_off_outlined,
                      title: 'No alarms yet',
                      subtitle: 'Set your first wake-up call below.',
                    )
                  : Column(
                      children: [
                        for (final alarm in rows)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(alarm.time,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              '${formatAlarmDays(alarm.daysMask)}'
                              '${alarm.sound != null ? ' · ${alarm.sound!.name}' : ' · Default sound'}'
                              ' · Snooze ${alarm.snoozeMinutes}m',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: alarm.enabled,
                                  onChanged: (value) async {
                                    try {
                                      await repo.updateAlarm(
                                          alarm.id, {'enabled': value});
                                      ref.invalidate(alarmsProvider);
                                    } catch (e) {
                                      if (context.mounted) {
                                        showToast(
                                          context,
                                          apiErrorMessage(e,
                                              fallback:
                                                  'Failed to update alarm'),
                                          type: ToastType.error,
                                        );
                                      }
                                    }
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Delete alarm',
                                  icon: const Icon(Icons.delete_outline,
                                      size: 20),
                                  onPressed: () async {
                                    try {
                                      await repo.deleteAlarm(alarm.id);
                                      ref.invalidate(alarmsProvider);
                                    } catch (e) {
                                      if (context.mounted) {
                                        showToast(
                                          context,
                                          apiErrorMessage(e,
                                              fallback:
                                                  'Failed to delete alarm'),
                                          type: ToastType.error,
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
            const Divider(height: 24),
            _NewAlarmForm(
                sounds: sounds.asData?.value ?? const <AlarmSound>[],
              ),
          ],
        ),
      ),
    );
  }
}

class _NewAlarmForm extends ConsumerStatefulWidget {
  const _NewAlarmForm({required this.sounds});

  final List<AlarmSound> sounds;

  @override
  ConsumerState<_NewAlarmForm> createState() => _NewAlarmFormState();
}

class _NewAlarmFormState extends ConsumerState<_NewAlarmForm> {
  TimeOfDay _time = const TimeOfDay(hour: 7, minute: 0);
  int _days = 127;
  final _labelController = TextEditingController();
  String? _soundId;
  int _snooze = 5;
  bool _saving = false;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  String get _timeText =>
      '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _create() async {
    setState(() => _saving = true);
    try {
      await ref.read(alarmRepositoryProvider).createAlarm({
        'time': _timeText,
        'days_mask': _days,
        'label': _labelController.text.trim(),
        'sound': _soundId,
        'enabled': true,
        'snooze_minutes': _snooze,
      });
      _labelController.clear();
      setState(() => _soundId = null);
      ref.invalidate(alarmsProvider);
      if (mounted) {
        showToast(context, 'Alarm set — sleep tight, champ',
            type: ToastType.success);
      }
    } catch (e) {
      if (mounted) {
        showToast(context,
            apiErrorMessage(e, fallback: 'Failed to create alarm'),
            type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('New alarm',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _pickTime,
              icon: const Icon(Icons.schedule, size: 16),
              label: Text(_timeText),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  const Text('Snooze', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Slider(
                      value: _snooze.toDouble(),
                      min: 1,
                      max: 30,
                      divisions: 29,
                      label: '$_snooze min',
                      onChanged: (v) => setState(() => _snooze = v.round()),
                    ),
                  ),
                  Text('${_snooze}m', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: [
            for (var i = 0; i < 7; i++)
              FilterChip(
                label: Text(alarmDayLabels[i],
                    style: const TextStyle(fontSize: 11)),
                selected: _days & (1 << i) != 0,
                onSelected: (_) =>
                    setState(() => _days = _days ^ (1 << i)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _labelController,
          decoration: const InputDecoration(
            labelText: 'Label (optional)',
            hintText: 'Leg day',
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String?>(
          initialValue: _soundId,
          decoration: const InputDecoration(
              labelText: 'Sound', isDense: true),
          items: [
            const DropdownMenuItem<String?>(
                value: null, child: Text('Default sound')),
            for (final sound in widget.sounds)
              DropdownMenuItem<String?>(
                value: sound.id,
                child: Text(sound.isMine
                    ? sound.name
                    : '${sound.name} (shared)'),
              ),
          ],
          onChanged: (value) => setState(() => _soundId = value),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _saving ? null : _create,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Set alarm'),
          ),
        ),
      ],
    );
  }
}

// ── Sounds ─────────────────────────────────────────────────────────────────

class _SoundsCard extends ConsumerStatefulWidget {
  const _SoundsCard({required this.sounds});

  final AsyncValue<List<AlarmSound>> sounds;

  @override
  ConsumerState<_SoundsCard> createState() => _SoundsCardState();
}

class _SoundsCardState extends ConsumerState<_SoundsCard> {
  bool _uploading = false;

  static const int _maxBytes = 2 * 1024 * 1024;

  Future<void> _upload() async {
    final picked = await FilePicker.pickFiles(type: FileType.audio);
    if (picked.isEmpty) return;
    final file = picked.first;
    final List<int> bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (_) {
      _error('Could not read that file — try again.');
      return;
    }
    if (bytes.length > _maxBytes) {
      _error('Sound file is too big (max 2 MB).');
      return;
    }
    setState(() => _uploading = true);
    try {
      await ref.read(alarmRepositoryProvider).uploadSound(
            MultipartFile.fromBytes(bytes, filename: file.name),
            file.name.replaceAll(RegExp(r'\.[^.]+$'), ''),
            'private',
          );
      ref.invalidate(alarmSoundsProvider);
      if (mounted) {
        showToast(context, 'Sound uploaded', type: ToastType.success);
      }
    } catch (e) {
      if (mounted) {
        showToast(context,
            apiErrorMessage(e, fallback: 'Failed to upload sound'),
            type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _error(String message) {
    if (mounted) {
      showToast(context, message, type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My sounds',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text(
              'Upload a short clip (max 30s, 2 MB). Buddies can also send you theirs.',
              style:
                  TextStyle(fontSize: 11, color: BuddyColors.textSecondary),
            ),
            const SizedBox(height: 8),
            widget.sounds.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => Text(
                apiErrorMessage(e, fallback: 'Could not load your sounds.'),
                style: const TextStyle(
                    fontSize: 12, color: BuddyColors.textSecondary),
              ),
              data: (rows) {
                final mine = rows.where((s) => s.isMine).toList();
                if (mine.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No custom sounds yet — upload your wake-up anthem.',
                      style: TextStyle(
                          fontSize: 12, color: BuddyColors.textSecondary),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final sound in mine)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.graphic_eq,
                            color: BuddyColors.green),
                        title: Text(sound.name,
                            style: const TextStyle(fontSize: 14)),
                        subtitle: Text(
                          '${sound.visibility}'
                          '${sound.durationMs > 0 ? ' · ${(sound.durationMs / 1000).round()}s' : ''}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _uploading ? null : _upload,
                icon: _uploading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_file, size: 16),
                label: const Text('Upload sound'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shares ─────────────────────────────────────────────────────────────────

class _SharesCard extends ConsumerWidget {
  const _SharesCard({required this.shares});

  final AsyncValue<List<AlarmShare>> shares;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(alarmRepositoryProvider);

    Future<void> respond(AlarmShare share, bool accept) async {
      try {
        await repo.respondToShare(share.id, {'accept': accept});
        ref.invalidate(alarmSharesInboxProvider);
        ref.invalidate(alarmSoundsProvider);
        if (context.mounted) {
          showToast(context, accept ? 'Sound added' : 'Share declined',
              type: ToastType.success);
        }
      } catch (e) {
        if (context.mounted) {
          showToast(context,
              apiErrorMessage(e, fallback: 'Failed to respond to share'),
              type: ToastType.error);
        }
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Shared with me',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            shares.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => Text(
                apiErrorMessage(e, fallback: 'Could not load shares.'),
                style: const TextStyle(
                    fontSize: 12, color: BuddyColors.textSecondary),
              ),
              data: (rows) => rows.isEmpty
                  ? const Text(
                      'Nothing shared yet — your buddies are holding out on you.',
                      style: TextStyle(
                          fontSize: 12, color: BuddyColors.textSecondary),
                    )
                  : Column(
                      children: [
                        for (final share in rows)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(share.sound.name,
                                style: const TextStyle(fontSize: 14)),
                            subtitle: Text(
                              'from ${share.sender?.displayName ?? share.sender?.username ?? 'a buddy'}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: () => respond(share, true),
                                  child: const Text('Accept'),
                                ),
                                TextButton(
                                  onPressed: () => respond(share, false),
                                  child: const Text('Decline'),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Suggestions ────────────────────────────────────────────────────────────

class _SuggestionsCard extends ConsumerStatefulWidget {
  const _SuggestionsCard({required this.suggestions});

  final AsyncValue<List<AlarmSuggestion>> suggestions;

  @override
  ConsumerState<_SuggestionsCard> createState() => _SuggestionsCardState();
}

class _SuggestionsCardState extends ConsumerState<_SuggestionsCard> {
  final _recipient = TextEditingController();
  final _title = TextEditingController();
  final _note = TextEditingController();
  final _url = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _recipient.dispose();
    _title.dispose();
    _note.dispose();
    _url.dispose();
    super.dispose();
  }

  Future<void> _respond(AlarmSuggestion suggestion, String decision) async {
    try {
      await ref
          .read(alarmRepositoryProvider)
          .respondToSuggestion(suggestion.id, {'decision': decision});
      ref.invalidate(alarmSuggestionsProvider);
      if (mounted) {
        showToast(context, 'Suggestion $decision', type: ToastType.success);
      }
    } catch (e) {
      if (mounted) {
        showToast(context,
            apiErrorMessage(e, fallback: 'Failed to respond'),
            type: ToastType.error);
      }
    }
  }

  Future<void> _send() async {
    if (_recipient.text.trim().isEmpty || _title.text.trim().isEmpty) {
      showToast(context, 'Pick a buddy and give your suggestion a title',
          type: ToastType.error);
      return;
    }
    final url = _url.text.trim();
    if (url.isNotEmpty && !url.startsWith('http')) {
      showToast(context, 'Link must start with http:// or https://',
          type: ToastType.error);
      return;
    }
    setState(() => _sending = true);
    try {
      await ref.read(alarmRepositoryProvider).sendSuggestion({
        'recipient_profile_id': _recipient.text.trim(),
        'title': _title.text.trim(),
        if (_note.text.trim().isNotEmpty) 'note': _note.text.trim(),
        if (url.isNotEmpty) 'url': url,
      });
      _recipient.clear();
      _title.clear();
      _note.clear();
      _url.clear();
      ref.invalidate(alarmSuggestionsProvider);
      if (mounted) {
        showToast(context, 'Suggestion sent', type: ToastType.success);
      }
    } catch (e) {
      if (mounted) {
        showToast(context,
            apiErrorMessage(e, fallback: 'Failed to send suggestion'),
            type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Suggestions',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            widget.suggestions.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => Text(
                apiErrorMessage(e, fallback: 'Could not load suggestions.'),
                style: const TextStyle(
                    fontSize: 12, color: BuddyColors.textSecondary),
              ),
              data: (rows) => rows.isEmpty
                  ? const Text('No suggestions right now.',
                      style: TextStyle(
                          fontSize: 12, color: BuddyColors.textSecondary))
                  : Column(
                      children: [
                        for (final suggestion in rows)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(suggestion.title,
                                style: const TextStyle(fontSize: 14)),
                            subtitle: Text(
                              [
                                if (suggestion.note?.isNotEmpty ?? false)
                                  suggestion.note!,
                                if (suggestion.sender?.displayName != null)
                                  'from ${suggestion.sender!.displayName}',
                              ].join(' · '),
                              style: const TextStyle(fontSize: 11),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: () =>
                                      _respond(suggestion, 'accepted'),
                                  child: const Text('Accept'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      _respond(suggestion, 'dismissed'),
                                  child: const Text('Dismiss'),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
            const Divider(height: 24),
            const Text('Send a suggestion',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _recipient,
              decoration: const InputDecoration(
                  labelText: 'Buddy profile ID', isDense: true),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                  labelText: 'Title', hintText: 'Try this sunrise alarm',
                  isDense: true),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _note,
              decoration: const InputDecoration(
                  labelText: 'Note (optional)', isDense: true),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _url,
              decoration: const InputDecoration(
                  labelText: 'Link (optional, https://…)', isDense: true),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: _sending ? null : _send,
                child: _sending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send suggestion'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
