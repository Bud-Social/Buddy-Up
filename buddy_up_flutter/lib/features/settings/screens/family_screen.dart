import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/auth/auth_provider.dart';
import '../providers/settings_providers.dart';
import '../../../data/models/guardian.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/input.dart';

/// Family: guardians manage linked teens (invite, dashboard, permissions,
/// unlink); teens see guardian links and pending invites.
class FamilyScreen extends ConsumerStatefulWidget {
  const FamilyScreen({super.key});

  @override
  ConsumerState<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends ConsumerState<FamilyScreen> {
  final _teenEmailCtrl = TextEditingController();
  final _teenNameCtrl = TextEditingController();
  DateTime? _teenDob;
  bool _isInviting = false;
  bool _isLoading = true;
  List<GuardianLink> _asGuardian = [];
  List<GuardianLink> _asTeen = [];
  List<GuardianDashboardEntry> _dashboard = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _teenEmailCtrl.dispose();
    _teenNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = ref.read(settingsGuardianRepoProvider);
      final rawLinks = await repo.getLinks();
      final linksMap = _payload(rawLinks);
      List<GuardianLink> parseList(dynamic raw) => raw is List
          ? raw
              .whereType<Map<String, dynamic>>()
              .map(GuardianLink.fromJson)
              .toList()
          : <GuardianLink>[];
      _asGuardian = parseList(linksMap?['as_guardian']);
      _asTeen = parseList(linksMap?['as_teen']);
      if (ref.read(authProvider).user?.isAdult == true) {
        final rawDash = await repo.getGuardianDashboard();
        _dashboard = extractDataList(rawDash)
            .whereType<Map<String, dynamic>>()
            .map(GuardianDashboardEntry.fromJson)
            .toList();
      }
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic>? _payload(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) return data;
      return raw;
    }
    return null;
  }

  Future<void> _inviteTeen() async {
    final email = _teenEmailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email for your teen')),
      );
      return;
    }
    setState(() => _isInviting = true);
    try {
      final repo = ref.read(settingsGuardianRepoProvider);
      await repo.inviteTeen(<String, dynamic>{
        'teen_email': email,
        if (_teenNameCtrl.text.trim().isNotEmpty)
          'teen_name': _teenNameCtrl.text.trim(),
        if (_teenDob != null)
          'teen_dob':
              '${_teenDob!.year.toString().padLeft(4, '0')}-${_teenDob!.month.toString().padLeft(2, '0')}-${_teenDob!.day.toString().padLeft(2, '0')}',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invite sent to $email')),
        );
        _teenEmailCtrl.clear();
        _teenNameCtrl.clear();
        setState(() => _teenDob = null);
      }
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isInviting = false);
    }
  }

  Future<void> _pickTeenDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 16),
      firstDate: DateTime(now.year - 19),
      lastDate: now,
    );
    if (picked != null) setState(() => _teenDob = picked);
  }

  Future<void> _acceptLink(GuardianLink link) async {
    try {
      await ref.read(settingsGuardianRepoProvider).acceptLink(link.id);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  Future<void> _declineLink(GuardianLink link) async {
    try {
      await ref.read(settingsGuardianRepoProvider).deleteLink(link.id);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  Future<void> _togglePermission(GuardianLink link, String key, bool value) async {
    try {
      await ref.read(settingsGuardianRepoProvider).updatePermissions(
        link.id,
        {key: value},
      );
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdult = ref.watch(authProvider).user?.isAdult == true;
    return Scaffold(
      appBar: AppBar(title: const Text('Family')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text('Could not load: $_error',
                          style: const TextStyle(color: BuddyColors.red, fontSize: 13)),
                    ),
                  if (isAdult) ...[
                    _inviteCard(),
                    const SizedBox(height: 16),
                    ..._dashboard.map(_dashboardCard),
                    const SizedBox(height: 8),
                    ..._asGuardian.map(_guardianLinkCard),
                    if (_asGuardian.isEmpty && _dashboard.isEmpty)
                      const Text(
                        'No linked teens yet. Send an invite to get started.',
                        style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
                      ),
                  ] else ...[
                    const Text('Guardian Links',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._asTeen.map(_teenLinkCard),
                    if (_asTeen.isEmpty)
                      const Text(
                        'No guardians linked to your account. A parent or guardian can invite you by email.',
                        style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
                      ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _inviteCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Invite a Teen',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          BuddyInput(
            label: 'Teen Email',
            controller: _teenEmailCtrl,
            hint: 'teen@email.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 8),
          BuddyInput(
            label: 'Teen Name (optional)',
            controller: _teenNameCtrl,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Date of birth (optional)',
                  style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
              const Spacer(),
              TextButton(
                onPressed: _pickTeenDob,
                child: Text(_teenDob == null
                    ? 'Pick date'
                    : '${_teenDob!.year}-${_teenDob!.month.toString().padLeft(2, '0')}-${_teenDob!.day.toString().padLeft(2, '0')}'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          BuddyButton(
            label: 'Send Invite',
            isLoading: _isInviting,
            icon: Icons.mail_outline,
            fullWidth: true,
            onPressed: _inviteTeen,
          ),
        ],
      ),
    );
  }

  Widget _dashboardCard(GuardianDashboardEntry entry) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: BuddyColors.green.withValues(alpha: 0.2),
                backgroundImage: entry.teen.avatarUrl.isNotEmpty
                    ? NetworkImage(entry.teen.avatarUrl)
                    : null,
                child: entry.teen.avatarUrl.isEmpty
                    ? Text(
                        entry.teen.displayName.isNotEmpty
                            ? entry.teen.displayName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: BuddyColors.green, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(entry.teen.displayName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Account age: ${entry.accountAgeDays} days · '
            'Last active: ${entry.lastActive.isEmpty ? '—' : entry.lastActive}\n'
            'Posts (7d): ${entry.postsLast7d} · Workouts (7d): ${entry.workoutsLast7d} · '
            'Upcoming sessions: ${entry.upcomingSessions}',
            style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _guardianLinkCard(GuardianLink link) {
    final teen = link.teen;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  teen?.displayName ?? link.inviteEmail,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                link.status,
                style: TextStyle(
                  fontSize: 12,
                  color: link.status == 'accepted' ? BuddyColors.green : BuddyColors.gold,
                ),
              ),
            ],
          ),
          if (link.status == 'accepted') ...[
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('Allow direct messages', style: TextStyle(fontSize: 13)),
              value: link.permissions['allow_direct_messages'] == true,
              onChanged: (v) => _togglePermission(link, 'allow_direct_messages', v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('Allow spends', style: TextStyle(fontSize: 13)),
              value: link.permissions['allow_spends'] == true,
              onChanged: (v) => _togglePermission(link, 'allow_spends', v),
            ),
          ],
          const SizedBox(height: 8),
          BuddyButton(
            label: 'Unlink',
            variant: BuddyButtonVariant.destructive,
            fullWidth: true,
            onPressed: () => _declineLink(link),
          ),
        ],
      ),
    );
  }

  Widget _teenLinkCard(GuardianLink link) {
    final guardian = link.guardian;
    final pending = link.status != 'accepted';
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            guardian?.displayName ?? link.inviteEmail,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            pending ? 'Pending invite' : 'Linked since ${link.acceptedAt ?? link.createdAt}',
            style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
          ),
          if (pending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: BuddyButton(
                    label: 'Accept',
                    fullWidth: true,
                    onPressed: () => _acceptLink(link),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BuddyButton(
                    label: 'Decline',
                    variant: BuddyButtonVariant.destructive,
                    fullWidth: true,
                    onPressed: () => _declineLink(link),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
