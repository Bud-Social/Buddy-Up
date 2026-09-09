import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../../data/models/notification.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/input.dart';

/// Notification preferences — mirrors the backend serializer:
/// channels (push/email/in-app), 12 per-type toggles, quiet hours and
/// timezone. PUT /notifications/preferences/ is a partial update, so only
/// the fields the user touched are sent.
class NotificationPrefsScreen extends ConsumerStatefulWidget {
  const NotificationPrefsScreen({super.key});

  @override
  ConsumerState<NotificationPrefsScreen> createState() =>
      _NotificationPrefsScreenState();
}

class _NotificationPrefsScreenState extends ConsumerState<NotificationPrefsScreen> {
  bool? _pushEnabled;
  bool? _emailEnabled;
  bool? _inAppEnabled;
  String? _quietStart; // HH:MM:SS or null
  String? _quietEnd;
  bool _timezoneTouched = false;
  late TextEditingController _timezoneCtrl;
  final Set<String> _changedTypes = {};
  final Map<String, bool> _typeValues = {};
  bool _isSaving = false;

  static const _typeLabels = <String, String>{
    'buddy_request_push': 'Buddy Requests',
    'buddy_accepted_push': 'Buddy Accepted',
    'new_follower_push': 'New Followers',
    'comment_push': 'Comments',
    'live_starting_push': 'Live Starting',
    'session_reminder_push': 'Session Reminders',
    'streak_milestone_push': 'Streak Milestones',
    'accountability_ping_push': 'Accountability Pings',
    'programme_reminder_push': 'Programme Reminders',
    'meal_reminder_push': 'Meal Reminders',
    'shop_cert_push': 'Shop Certifications',
    'new_purchase_push': 'New Purchases',
  };

  @override
  void initState() {
    super.initState();
    _timezoneCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _timezoneCtrl.dispose();
    super.dispose();
  }

  /// Copy server values into local editing state once per load.
  void _hydrate(NotificationPreference p) {
    _pushEnabled ??= p.pushEnabled;
    _emailEnabled ??= p.emailEnabled;
    _inAppEnabled ??= p.inAppEnabled;
    _quietStart ??= p.quietHoursStart;
    _quietEnd ??= p.quietHoursEnd;
    if (!_timezoneTouched) {
      _timezoneCtrl.text = p.timezone ?? _deviceTimezone();
    }
    for (final key in _typeLabels.keys) {
      _typeValues.putIfAbsent(key, () => _typeBool(p, key));
    }
  }

  bool _typeBool(NotificationPreference p, String key) => switch (key) {
        'buddy_request_push' => p.buddyRequestPush,
        'buddy_accepted_push' => p.buddyAcceptedPush,
        'new_follower_push' => p.newFollowerPush,
        'comment_push' => p.commentPush,
        'live_starting_push' => p.liveStartingPush,
        'session_reminder_push' => p.sessionReminderPush,
        'streak_milestone_push' => p.streakMilestonePush,
        'accountability_ping_push' => p.accountabilityPingPush,
        'programme_reminder_push' => p.programmeReminderPush,
        'meal_reminder_push' => p.mealReminderPush,
        'shop_cert_push' => p.shopCertPush,
        'new_purchase_push' => p.newPurchasePush,
        _ => true,
      };

  String _deviceTimezone() {
    final name = DateTime.now().timeZoneName;
    // Browsers report IANA names (e.g. Europe/London); native platforms
    // often return abbreviations (e.g. CET) which the backend rejects.
    return name.contains('/') ? name : '';
  }

  Future<void> _pickQuietTime({required bool isStart}) async {
    final current = isStart ? _quietStart : _quietEnd;
    TimeOfDay? initial;
    if (current != null) {
      final parts = current.split(':');
      final h = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
      final m = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
      initial = TimeOfDay(hour: h.clamp(0, 23), minute: m.clamp(0, 59));
    }
    final picked = await showTimePicker(
      context: context,
      initialTime: initial ?? TimeOfDay.now(),
    );
    if (picked == null) return;
    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
    setState(() {
      if (isStart) {
        _quietStart = formatted;
      } else {
        _quietEnd = formatted;
      }
    });
  }

  Future<void> _clearQuietTime({required bool isStart}) async {
    setState(() {
      if (isStart) {
        _quietStart = null;
      } else {
        _quietEnd = null;
      }
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final data = <String, dynamic>{
        if (_pushEnabled != null) 'push_enabled': _pushEnabled,
        if (_emailEnabled != null) 'email_enabled': _emailEnabled,
        if (_inAppEnabled != null) 'in_app_enabled': _inAppEnabled,
        if (_quietStart != null) 'quiet_hours_start': _quietStart,
        if (_quietEnd != null) 'quiet_hours_end': _quietEnd,
        if (_timezoneTouched && _timezoneCtrl.text.trim().isNotEmpty)
          'timezone': _timezoneCtrl.text.trim(),
        for (final key in _changedTypes) key: _typeValues[key],
      };
      await ref.read(notificationRepositoryProvider).updatePreferences(data);
      ref.invalidate(notificationPreferencesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification preferences saved'),
            backgroundColor: BuddyColors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefsAsync = ref.watch(notificationPreferencesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Preferences')),
      body: prefsAsync.when(
        data: (prefs) {
          _hydrate(prefs);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionTitle('Channels'),
              _card([
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Push Notifications', style: TextStyle(fontSize: 14)),
                  value: _pushEnabled ?? true,
                  onChanged: (v) => setState(() => _pushEnabled = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Email Notifications', style: TextStyle(fontSize: 14)),
                  value: _emailEnabled ?? true,
                  onChanged: (v) => setState(() => _emailEnabled = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('In-App Notifications', style: TextStyle(fontSize: 14)),
                  value: _inAppEnabled ?? true,
                  onChanged: (v) => setState(() => _inAppEnabled = v),
                ),
              ]),
              const SizedBox(height: 16),
              _sectionTitle('Quiet Hours'),
              _card([
                _quietTimeRow(
                  label: 'Start',
                  value: _quietStart,
                  onPick: () => _pickQuietTime(isStart: true),
                  onClear: () => _clearQuietTime(isStart: true),
                ),
                _quietTimeRow(
                  label: 'End',
                  value: _quietEnd,
                  onPick: () => _pickQuietTime(isStart: false),
                  onClear: () => _clearQuietTime(isStart: false),
                ),
                const SizedBox(height: 8),
                BuddyInput(
                  label: 'Timezone (IANA, e.g. Europe/London)',
                  controller: _timezoneCtrl,
                  hint: 'Timezone',
                  onChanged: (_) => _timezoneTouched = true,
                ),
              ]),
              const SizedBox(height: 16),
              _sectionTitle('Notification Types'),
              _card([
                ..._typeLabels.entries.map(
                  (e) => SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(e.value, style: const TextStyle(fontSize: 14)),
                    value: _typeValues[e.key] ?? true,
                    onChanged: (v) => setState(() {
                      _typeValues[e.key] = v;
                      _changedTypes.add(e.key);
                    }),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              BuddyButton(
                label: 'Save Preferences',
                isLoading: _isSaving,
                fullWidth: true,
                onPressed: _save,
              ),
              const SizedBox(height: 24),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _quietTimeRow({
    required String label,
    required String? value,
    required VoidCallback onPick,
    required VoidCallback onClear,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            child: Text(
              value == null
                  ? 'Not set'
                  : value.split(':').take(2).join(':'),
              style: TextStyle(
                fontSize: 14,
                color: value == null ? BuddyColors.textSecondary : null,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Pick time',
            icon: const Icon(Icons.access_time, size: 20, color: BuddyColors.green),
            onPressed: onPick,
          ),
          if (value != null)
            IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.close, size: 20, color: BuddyColors.textSecondary),
              onPressed: onClear,
            ),
        ],
      ),
    );
  }
}
