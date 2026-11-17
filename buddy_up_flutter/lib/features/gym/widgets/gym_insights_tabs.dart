import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/role_dashboard_shell.dart';
import '../../messaging/providers/messaging_provider.dart';
import '../providers/gym_insights_provider.dart';
import '../providers/gym_manage_provider.dart';
import '../../../data/models/gym_insights.dart';
import '../../../data/models/gym.dart' as gym_models;

// ---------------------------------------------------------------------------
// Shared bits
// ---------------------------------------------------------------------------

class _KpiTile extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;

  const _KpiTile({required this.label, required this.value, this.sub});

  @override
  Widget build(BuildContext context) {
    return RoleCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              color: BuddyColors.textSecondary,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 3),
          Text(value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: BuddyColors.textPrimary)),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(sub!,
                style: const TextStyle(fontSize: 9, color: BuddyColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

class _GrowthChip extends StatelessWidget {
  final String label;
  final double pct;

  const _GrowthChip({required this.label, required this.pct});

  @override
  Widget build(BuildContext context) {
    final up = pct >= 0;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(up ? Icons.trending_up : Icons.trending_down,
                  size: 13, color: up ? BuddyColors.green : BuddyColors.red),
              const SizedBox(width: 3),
              Text('${up ? '+' : ''}${pct.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: up ? BuddyColors.green : BuddyColors.red,
                  )),
            ],
          ),
          const SizedBox(height: 2),
          Text(label.toUpperCase(),
              style: const TextStyle(fontSize: 8, color: BuddyColors.textSecondary)),
        ],
      ),
    );
  }
}

/// A minimal bar chart, one bar per day. No chart package — peak-scaled,
/// same visual language as the admin analytics bars.
class _BucketBars extends StatelessWidget {
  final List<DailyCount> series;
  final Color color;

  const _BucketBars({required this.series, required this.color});

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty || series.every((p) => p.count == 0)) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: Text('Nothing yet in the last 30 days.',
              style: TextStyle(fontSize: 11, color: BuddyColors.textSecondary)),
        ),
      );
    }
    var peak = 0.0;
    for (final p in series) {
      if (p.count > peak) peak = p.count;
    }
    return SizedBox(
      height: 96,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final point in series)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Tooltip(
                  message: '${point.count.toInt()} on ${_shortDay(point.day)}',
                  child: Container(
                    height: peak > 0 ? (point.count / peak) * 84 + 2 : 2,
                    decoration: BoxDecoration(
                      color: point.count == 0
                          ? BuddyColors.surfaceRaised
                          : color,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _shortDay(DateTime? d) => d == null ? '' : '${d.day}/${d.month}';
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 4, 2, 6),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            color: BuddyColors.textSecondary,
            letterSpacing: 0.6,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

class _TileGrid extends StatelessWidget {
  final List<Widget> tiles;
  const _TileGrid({required this.tiles});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cols = width >= 720 ? 6 : (width >= 480 ? 3 : 2);
        const spacing = 8.0;
        final tileWidth = (width - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [for (final tile in tiles) SizedBox(width: tileWidth, child: tile)],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Sessions tab
// ---------------------------------------------------------------------------

class GymSessionsTab extends ConsumerWidget {
  final String slug;
  const GymSessionsTab({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(gymSessionsProvider(slug));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RoleSectionTitle('Sessions'),
        async.when(
          loading: () => const PageLoader(fullScreen: false),
          error: (error, _) => const RoleNotice(
            message: 'Could not load sessions. Pull to refresh, or try again later.',
            isError: true,
          ),
          data: (data) {
            final s = data.summary;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionLabel('Coaches, bookings & door check-ins · 30d'),
                _TileGrid(tiles: [
                  _KpiTile(label: 'Sessions done', value: '${s.sessions30d}'),
                  _KpiTile(label: 'Upcoming 30d', value: '${s.upcoming30d}'),
                  _KpiTile(label: 'Cancelled', value: '${s.cancelled30d}'),
                  _KpiTile(label: 'No-shows', value: '${s.noShows30d}'),
                  _KpiTile(label: 'Check-ins', value: '${s.checkIns30d}'),
                  _KpiTile(label: 'Unique attendees', value: '${s.uniqueAttendees30d}'),
                ]),
                const SizedBox(height: 10),
                RoleCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel('Door check-ins · last 30 days'),
                      _BucketBars(series: data.checkInsDaily, color: BuddyColors.green),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const _SectionLabel('Bookings on gym coaches'),
                if (data.bookings.isEmpty)
                  const RoleNotice(
                    message: 'No bookings against your gym’s coaches yet. When '
                        'a member books a coach tied to this gym, it lands here.',
                  )
                else
                  for (final booking in data.bookings)
                    _BookingTile(booking: booking),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _BookingTile extends StatelessWidget {
  final GymInsightBooking booking;
  const _BookingTile({required this.booking});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (booking.status) {
      'confirmed' => BuddyColors.green,
      'pending' => BuddyColors.gold,
      'completed' => BuddyColors.textSecondary,
      _ => BuddyColors.red,
    };
    final when = booking.scheduledAt == null
        ? '—'
        : '${booking.scheduledAt!.day}/${booking.scheduledAt!.month} · ${booking.scheduledAt!.hour.toString().padLeft(2, '0')}:${booking.scheduledAt!.minute.toString().padLeft(2, '0')}';
    return RoleCard(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Avatar(src: booking.clientAvatar, alt: booking.clientDisplay, size: AvatarSize.sm),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${booking.clientDisplay} with ${booking.trainerDisplay}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                Text(
                  '$when${booking.durationMinutes != null ? ' · ${booking.durationMinutes} min' : ''}${booking.sessionType.isNotEmpty ? ' · ${booking.sessionType.replaceAll('_', ' ')}' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: BuddyColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: statusColor.withValues(alpha: 0.35)),
            ),
            child: Text(
              booking.status.replaceAll('_', ' ').toUpperCase(),
              style: TextStyle(fontSize: 9, color: statusColor, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Messages tab
// ---------------------------------------------------------------------------

class GymMessagesTab extends ConsumerStatefulWidget {
  final String slug;
  const GymMessagesTab({super.key, required this.slug});

  @override
  ConsumerState<GymMessagesTab> createState() => _GymMessagesTabState();
}

class _GymMessagesTabState extends ConsumerState<GymMessagesTab> {
  String _filter = 'all';
  GymInboxConversation? _active;
  bool _memberPickerOpen = false;
  String _memberQuery = '';

  @override
  Widget build(BuildContext context) {
    final slug = widget.slug;
    if (_active != null) {
      return _GymThreadView(
        slug: slug,
        conversation: _active!,
        onBack: () => setState(() {
          _active = null;
          ref.invalidate(gymInboxProvider(slug));
        }),
      );
    }

    final async = ref.watch(gymMessagesProvider(slug));
    final inboxAsync = ref.watch(gymInboxProvider(slug));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RoleSectionTitle(
          'Messages',
          trailing: IconButton(
            icon: const Icon(Icons.refresh, size: 18),
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(gymMessagesProvider(slug));
              ref.invalidate(gymInboxProvider(slug));
            },
          ),
        ),
        const SizedBox(height: 8),
        const _SectionLabel('Gym inbox — members, team & clients'),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _openTeamChat(slug),
                icon: const Icon(Icons.groups_2_rounded, size: 16),
                label: const Text('Team chat', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 33),
                  backgroundColor: BuddyColors.blue.withValues(alpha: 0.18),
                  foregroundColor: BuddyColors.blue,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => setState(() => _memberPickerOpen = !_memberPickerOpen),
                icon: const Icon(Icons.person_add_alt_rounded, size: 16),
                label: Text(_memberPickerOpen ? 'Hide members' : 'Message a member',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                style: FilledButton.styleFrom(minimumSize: const Size(0, 33)),
              ),
            ),
          ],
        ),
        if (_memberPickerOpen) ...[
          const SizedBox(height: 8),
          _MemberPicker(slug: slug, query: _memberQuery,
              onQueryChanged: (v) => setState(() => _memberQuery = v),
              onOpenConversation: (c) => setState(() => _active = c)),
        ],
        const SizedBox(height: 8),
        inboxAsync.when(
          loading: () => const PageLoader(fullScreen: false),
          error: (_, _) => const RoleNotice(
            message: 'Could not load the gym inbox.',
            isError: true,
          ),
          data: (inbox) => inbox.isEmpty
              ? const RoleNotice(
                  message: 'No gym conversations yet — start the Team chat, message a member, or wait for a client to reach out.',
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [for (final conv in inbox) _GymInboxTile(conversation: conv, onTap: () => setState(() {
                    _active = conv;
                    _memberPickerOpen = false;
                  }))],
                ),
        ),
        const SizedBox(height: 10),
        async.when(
          loading: () => const PageLoader(fullScreen: false),
          error: (error, _) => const RoleNotice(
            message: 'Could not load community chats.',
            isError: true,
          ),
          data: (data) {
            final convs = data.conversations
                .where((c) => _filter == 'all' || c.kind == _filter)
                .toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionLabel('Community chats'),
                _TileGrid(tiles: [
                  _KpiTile(label: 'Community chats', value: '${data.communityChats}'),
                  _KpiTile(label: 'Group chats', value: '${data.groupChats}'),
                  _KpiTile(label: 'Direct threads', value: '${data.directThreads}'),
                  _KpiTile(label: 'Client msgs · 7d', value: '${data.inbound7d}'),
                ]),
                const SizedBox(height: 10),
                RoleFilterChips<String>(
                  options: const ['all', 'community', 'group', 'direct'],
                  selected: _filter,
                  label: (v) => switch (v) {
                    'all' => 'All',
                    'community' => 'Community',
                    'group' => 'Groups',
                    _ => 'Direct',
                  },
                  onSelected: (v) => setState(() => _filter = v),
                ),
                const SizedBox(height: 8),
                if (convs.isEmpty)
                  RoleNotice(
                    message: _filter == 'all'
                        ? 'No community conversations yet.'
                        : 'No $_filter conversations yet.',
                  )
                else
                  for (final conv in convs) _ConversationTile(conversation: conv),
                const SizedBox(height: 10),
                const _SectionLabel('From real clients'),
                if (data.recentInbound.isEmpty)
                  const RoleNotice(
                    message: 'No client messages yet. When a member messages you — classes, pricing, a coach — it lands here.',
                  )
                else
                  for (final message in data.recentInbound.take(20))
                    _InboundMessageTile(message: message),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _openTeamChat(String slug) async {
    try {
      final conv = await gymInboxOpenConversation(slug, audience: 'team');
      if (!mounted) return;
      setState(() => _active = conv);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the team chat.')),
      );
    }
  }
}

class _GymInboxTile extends StatelessWidget {
  final GymInboxConversation conversation;
  final VoidCallback onTap;
  const _GymInboxTile({required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final audience = switch (conversation.conversationKind) {
      'team' => const (label: 'TEAM', color: BuddyColors.blue),
      'client' => const (label: 'CLIENT', color: BuddyColors.gold),
      _ => const (label: 'MEMBER', color: BuddyColors.textSecondary),
    };
    return RoleCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: BuddyColors.surfaceRaised,
                backgroundImage:
                    conversation.avatarUrl.isNotEmpty ? NetworkImage(conversation.avatarUrl) : null,
                child: conversation.avatarUrl.isEmpty
                    ? Icon(
                        conversation.isTeam ? Icons.groups_rounded : Icons.person,
                        size: 20,
                        color: BuddyColors.textSecondary,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: audience.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            audience.label,
                            style: TextStyle(
                              fontSize: 8,
                              color: audience.color,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (conversation.unreadCount > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: BuddyColors.green,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${conversation.unreadCount}',
                              style: const TextStyle(
                                fontSize: 9,
                                color: BuddyColors.black,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      '${conversation.memberCount} participants${conversation.lastMessage.isNotEmpty ? ' · ${conversation.lastMessage}' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, color: BuddyColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberPicker extends ConsumerWidget {
  final String slug;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final void Function(GymInboxConversation) onOpenConversation;
  const _MemberPicker({
    required this.slug,
    required this.query,
    required this.onQueryChanged,
    required this.onOpenConversation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(gymManageMembersProvider(slug)).when(
      data: (rows) => rows,
      loading: () => const <gym_models.GymMembership>[],
      error: (_, _) => const <gym_models.GymMembership>[],
    );
    final q = query.trim().toLowerCase();
    final matches = members
        .where((m) => m.role != 'owner')
        .where((m) => q.isEmpty ||
            m.memberData.username.toLowerCase().contains(q) ||
            m.memberData.displayName.toLowerCase().contains(q))
        .take(12)
        .toList();
    return RoleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            autofocus: false,
            onChanged: onQueryChanged,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search, size: 18),
              hintText: 'Search members…',
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          if (matches.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No one matches that search.', style: TextStyle(fontSize: 11, color: BuddyColors.textSecondary)),
            )
          else
            for (final member in matches)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Avatar(
                  src: member.memberData.avatarUrl,
                  alt: member.memberData.displayName,
                  size: AvatarSize.sm,
                ),
                title: Text(member.memberData.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                subtitle: Text('@${member.memberData.username} · ${member.role}',
                    style: const TextStyle(fontSize: 10, color: BuddyColors.textSecondary)),
                trailing: const Icon(Icons.chat_bubble_outline, size: 16),
                onTap: () async {
                  try {
                    final conv = await gymInboxOpenConversation(
                      slug,
                      audience: 'member',
                      participantId: member.memberId,
                    );
                    if (context.mounted) onOpenConversation(conv);
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not open the conversation.')),
                      );
                    }
                  }
                },
              ),
        ],
      ),
    );
  }
}

class _GymThreadView extends ConsumerStatefulWidget {
  final String slug;
  final GymInboxConversation conversation;
  final VoidCallback onBack;
  const _GymThreadView({required this.slug, required this.conversation, required this.onBack});

  @override
  ConsumerState<_GymThreadView> createState() => _GymThreadViewState();
}

class _GymThreadViewState extends ConsumerState<_GymThreadView> {
  final TextEditingController _draft = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _sending = false;
  final List<GymInboxMessage> _pending = [];

  @override
  void dispose() {
    _draft.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conv = widget.conversation;
    final async = ref.watch(gymInboxMessagesProvider((slug: widget.slug, conversationId: conv.id)));
    final all = [
      ...async.when(
        data: (rows) => rows,
        loading: () => const <GymInboxMessage>[],
        error: (_, _) => const <GymInboxMessage>[],
      ),
      ..._pending,
    ];
    return Column(
      children: [
        const SizedBox(height: 8),
        RoleCard(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                tooltip: 'Back to inbox',
                onPressed: widget.onBack,
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: BuddyColors.surfaceRaised,
                backgroundImage:
                    conv.avatarUrl.isNotEmpty ? NetworkImage(conv.avatarUrl) : null,
                child: conv.avatarUrl.isEmpty
                    ? Icon(conv.isTeam ? Icons.groups_rounded : Icons.person, size: 20)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(conv.label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    Text(
                      conv.isTeam ? 'Team chat — gym staff only' : 'Gym conversation — stays with the gym, never your DMs',
                      style: const TextStyle(fontSize: 9, color: BuddyColors.green),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (_, _) => const Center(child: Text('Could not load this conversation.')),
            data: (_) => ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: all.length,
              itemBuilder: (context, index) {
                final message = all[index];
                final mine = message.isMine;
                return Align(
                  alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    constraints: const BoxConstraints(maxWidth: 260),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: mine ? BuddyColors.green.withValues(alpha: 0.14) : BuddyColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(message.body, style: const TextStyle(fontSize: 12, color: BuddyColors.textPrimary)),
                  ),
                );
              },
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _draft,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Message ${conv.label}…',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: _sending
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send_rounded, size: 18),
                  tooltip: 'Send',
                  onPressed: _sending ? null : _send,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _send() async {
    final body = _draft.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    _draft.clear();
    try {
      final message = await gymInboxSendMessage(widget.slug, widget.conversation.id, body);
      _pending.add(GymInboxMessage(
        id: message.id,
        senderUsername: message.senderUsername,
        senderDisplay: message.senderDisplay,
        body: message.body,
        createdAt: message.createdAt,
        isMine: true,
      ));
      ref.invalidate(gymInboxMessagesProvider((slug: widget.slug, conversationId: widget.conversation.id)));
      ref.invalidate(gymInboxProvider(widget.slug));
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not send that message.')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }
}

class _ConversationTile extends StatelessWidget {
  final GymMessageConversation conversation;
  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final kindStyle = switch (conversation.kind) {
      'community' => const (label: 'COMMUNITY', color: BuddyColors.blue),
      'group' => const (label: 'GROUP', color: BuddyColors.gold),
      _ => const (label: 'DIRECT', color: BuddyColors.textSecondary),
    };
    return RoleCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.push('/messages/${conversation.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Avatar(
                src: conversation.members.isNotEmpty ? conversation.members.first.avatarUrl : null,
                alt: conversation.name.isNotEmpty ? conversation.name : 'Chat',
                size: AvatarSize.md,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: kindStyle.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            kindStyle.label,
                            style: TextStyle(
                                fontSize: 8,
                                color: kindStyle.color,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${conversation.members.length} member${conversation.members.length == 1 ? '' : 's'}${conversation.lastMessage.isNotEmpty ? ' · ${conversation.lastMessage}' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, color: BuddyColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InboundMessageTile extends StatelessWidget {
  final GymInboundMessage message;
  const _InboundMessageTile({required this.message});

  @override
  Widget build(BuildContext context) {
    return RoleCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.push('/messages/${message.conversation}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Avatar(src: message.senderAvatar, alt: message.senderDisplay, size: AvatarSize.sm),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message.senderDisplay,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(message.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: BuddyColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Communities tab
// ---------------------------------------------------------------------------

class GymCommunitiesTab extends ConsumerStatefulWidget {
  final String slug;
  const GymCommunitiesTab({super.key, required this.slug});

  @override
  ConsumerState<GymCommunitiesTab> createState() => _GymCommunitiesTabState();
}

class _GymCommunitiesTabState extends ConsumerState<GymCommunitiesTab> {
  String? _activeFeedId;
  List<Map<String, dynamic>>? _posts;
  bool _postsLoading = false;
  String? _feedError;
  bool _sending = false;
  String? _busyId;
  String? _error;
  final _draft = TextEditingController();

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  Future<void> _refresh() async => ref.invalidate(gymCommunitiesProvider(widget.slug));

  Future<void> _loadPosts(String communityId) async {
    setState(() {
      _postsLoading = true;
      _feedError = null;
      _posts = null;
    });
    try {
      final raw = await ref
          .read(messagingRepositoryProvider)
          .getCommunityPosts(communityId);
      final rows = _listOf(raw);
      if (!mounted) return;
      setState(() {
        _posts = rows;
        _postsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _posts = const [];
        _postsLoading = false;
        _feedError = 'Could not load posts.';
      });
    }
  }

  void _toggleFeed(String communityId) {
    if (_activeFeedId == communityId) {
      setState(() {
        _activeFeedId = null;
        _posts = null;
      });
      return;
    }
    setState(() {
      _activeFeedId = communityId;
      _posts = null;
    });
    _loadPosts(communityId);
  }

  Future<void> _submitPost(String communityId) async {
    final body = _draft.text.trim();
    if (body.isEmpty) return;
    setState(() {
      _sending = true;
      _feedError = null;
    });
    try {
      await ref
          .read(messagingRepositoryProvider)
          .createCommunityPost(communityId, {'body': body});
      _draft.clear();
      await _loadPosts(communityId);
    } catch (_) {
      if (!mounted) return;
      setState(() => _feedError = 'Could not post that.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _toggleMembership(GymLinkedCommunity community) async {
    setState(() => _busyId = community.id);
    try {
      final repo = ref.read(messagingRepositoryProvider);
      if (community.isMember) {
        await repo.leaveCommunity(community.id);
      } else {
        await repo.joinCommunity(community.id, const {});
      }
      await _refresh();
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not update membership.');
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _link(GymDiscoverableCommunity community) async {
    setState(() => _busyId = community.id);
    try {
      await ref
          .read(gymCommunityActionsProvider)
          .linkCommunity(widget.slug, community.id);
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request sent to ${community.name} — their owner or an admin will review it.')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not link that community.');
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _unlink(GymLinkedCommunity community) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unlink community?'),
        content: Text(
            '${community.name} stays as a community — it just stops being attached to this gym.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Keep')),
          FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Unlink')),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _busyId = community.id);
    try {
      await ref
          .read(gymCommunityActionsProvider)
          .unlinkCommunity(widget.slug, community.id);
      if (_activeFeedId == community.id) {
        setState(() {
          _activeFeedId = null;
          _posts = null;
        });
      }
      await _refresh();
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not unlink that community.');
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _openCreate() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    var isPublic = true;
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create a gym community'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Community name — e.g. Saturday Runners',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: "What's this community about?",
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              SwitchListTile(
                value: isPublic,
                onChanged: (v) => setDialogState(() => isPublic = v),
                title: Text(isPublic ? 'Public — anyone can join' : 'Private — invite only'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
    if (created != true) return;
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    if (name.isEmpty) return;
    setState(() => _error = null);
    try {
      await ref.read(gymCommunityActionsProvider).createCommunity(
            widget.slug,
            name: name,
            description: description,
            isPublic: isPublic,
          );
      await _refresh();
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not create that community.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final slug = widget.slug;
    final async = ref.watch(gymCommunitiesProvider(slug));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RoleSectionTitle(
          'Communities',
          trailing: TextButton.icon(
            onPressed: _openCreate,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('New community', style: TextStyle(fontSize: 12)),
          ),
        ),
        if (_error != null) RoleNotice(message: _error!, isError: true),
        async.when(
          loading: () => const PageLoader(fullScreen: false),
          error: (error, _) => const RoleNotice(
            message: 'Could not load communities.',
            isError: true,
          ),
          data: (data) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data.linked.isEmpty) ...[
                const RoleCard(
                  child: Column(
                    children: [
                      SizedBox(height: 8),
                      Icon(Icons.groups_rounded, size: 28, color: BuddyColors.textSecondary),
                      SizedBox(height: 8),
                      Text('No communities yet',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      SizedBox(height: 4),
                      Text(
                        'Form your own with “New community”, or link one below — a local '
                        'run club, a lifting cohort, anything your members belong to.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: BuddyColors.textSecondary),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
              ] else
                for (final community in data.linked) ...[
                  _LinkedCommunityCard(
                    community: community,
                    busy: _busyId == community.id,
                    activeFeed: _activeFeedId == community.id,
                    onToggleFeed: () => _toggleFeed(community.id),
                    onToggleMembership: () => _toggleMembership(community),
                    onUnlink: () => _unlink(community),
                    posts: _posts,
                    postsLoading: _postsLoading,
                    feedError: _feedError,
                    draftController: _draft,
                    sending: _sending,
                    onSubmitPost: () => _submitPost(community.id),
                  ),
                ],
              const _SectionLabel('Discover & link a community'),
              if (data.discoverable.isEmpty)
                const Text('No public communities to discover right now.',
                    style: TextStyle(fontSize: 11, color: BuddyColors.textSecondary))
              else
                _DiscoverGrid(
                  communities: data.discoverable,
                  busyId: _busyId,
                  onLink: _link,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

List<Map<String, dynamic>> _listOf(dynamic raw) {
  dynamic rows = raw;
  if (rows is Map) rows = rows['data'] ?? rows['results'] ?? const [];
  if (rows is Map) rows = rows['items'] ?? rows['posts'] ?? const [];
  if (rows is! List) return const [];
  return rows.whereType<Map>().map(Map<String, dynamic>.from).toList();
}

class _LinkedCommunityCard extends StatelessWidget {
  final GymLinkedCommunity community;
  final bool busy;
  final bool activeFeed;
  final VoidCallback onToggleFeed;
  final VoidCallback onToggleMembership;
  final VoidCallback onUnlink;
  final List<Map<String, dynamic>>? posts;
  final bool postsLoading;
  final String? feedError;
  final TextEditingController draftController;
  final bool sending;
  final VoidCallback onSubmitPost;

  const _LinkedCommunityCard({
    required this.community,
    required this.busy,
    required this.activeFeed,
    required this.onToggleFeed,
    required this.onToggleMembership,
    required this.onUnlink,
    required this.posts,
    required this.postsLoading,
    required this.feedError,
    required this.draftController,
    required this.sending,
    required this.onSubmitPost,
  });

  @override
  Widget build(BuildContext context) {
    return RoleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Avatar(src: community.avatarUrl, alt: community.name, size: AvatarSize.md),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(_clip(community.name, 46),
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                        if (community.status == 'pending')
                          const _Badge(label: 'PENDING', color: BuddyColors.gold),
                        if (community.isGymFormed)
                          const _Badge(label: 'GYM-FORMED', color: BuddyColors.green),
                        if (community.isPrimary && community.status == 'active')
                          const _Badge(label: 'PRIMARY', color: BuddyColors.gold),
                        _Badge(
                          label: community.isPublic ? 'PUBLIC' : 'PRIVATE',
                          color: BuddyColors.textSecondary,
                        ),
                      ],
                    ),
                    if (community.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(_clip(community.description, 88),
                            style: const TextStyle(fontSize: 11, color: BuddyColors.textSecondary)),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '${community.memberCount} member${community.memberCount == 1 ? '' : 's'}${community.postCount > 0 ? ' · ${community.postCount} posts' : ''}',
                      style: const TextStyle(fontSize: 10, color: BuddyColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [
                        _MiniAction(
                          label: activeFeed ? 'Hide feed' : 'View feed & post',
                          onPressed: onToggleFeed,
                        ),
                        if (community.status != 'pending')
                          _MiniAction(
                            label: community.isMember ? 'Leave' : 'Join',
                            filled: !community.isMember,
                            onPressed: busy ? null : onToggleMembership,
                          ),
                        _MiniAction(
                          icon: Icons.link_off,
                          label: community.status == 'pending' ? 'Cancel request' : '',
                          destructive: true,
                          onPressed: busy ? null : onUnlink,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (activeFeed) ...[
            const Divider(height: 20, color: BuddyColors.surfaceRaised),
            TextField(
              controller: draftController,
              minLines: 1,
              maxLines: 3,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSubmitPost(),
              decoration: InputDecoration(
                hintText: 'Post to ${community.name}…',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: sending
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: BuddyColors.green))
                      : const Icon(Icons.send_rounded, size: 18),
                  onPressed: sending ? null : onSubmitPost,
                ),
              ),
            ),
            if (feedError != null) ...[
              const SizedBox(height: 6),
              Text(feedError!, style: const TextStyle(fontSize: 10, color: BuddyColors.red)),
            ],
            const SizedBox(height: 6),
            if (postsLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: PageLoader(fullScreen: false)),
              )
            else if (posts != null && posts!.isNotEmpty)
              for (final post in posts!)
                _CommunityPostTile(post: post)
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('No posts yet — be the first to say something.',
                    style: TextStyle(fontSize: 11, color: BuddyColors.textSecondary)),
              ),
          ],
        ],
      ),
    );
  }
}

class _CommunityPostTile extends StatelessWidget {
  final Map<String, dynamic> post;
  const _CommunityPostTile({required this.post});

  @override
  Widget build(BuildContext context) {
    final author = _mapOf(post['author_data']);
    final name = (author['display_name'] ?? author['username'] ?? 'Member').toString();
    final body = (post['body'] ?? '').toString();
    final likes = _int(post['like_count']);
    final comments = _int(post['comment_count']);
    final created = DateTime.tryParse((post['created_at'] ?? '').toString());
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Avatar(src: (author['avatar_url'] ?? '').toString(), alt: name, size: AvatarSize.xs),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 6),
                    Text(_relativeTime(created),
                        style: const TextStyle(fontSize: 9, color: BuddyColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(body, style: const TextStyle(fontSize: 11)),
                const SizedBox(height: 2),
                Text('$likes likes · $comments comments',
                    style: const TextStyle(fontSize: 9, color: BuddyColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoverGrid extends StatelessWidget {
  final List<GymDiscoverableCommunity> communities;
  final String? busyId;
  final Future<void> Function(GymDiscoverableCommunity) onLink;

  const _DiscoverGrid({
    required this.communities,
    required this.busyId,
    required this.onLink,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 720 ? 2 : 1;
        const spacing = 8.0;
        final tileWidth = (constraints.maxWidth - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final community in communities)
              SizedBox(
                width: tileWidth,
                child: RoleCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Avatar(src: community.avatarUrl, alt: community.name, size: AvatarSize.md),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_clip(community.name, 34),
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                            if (community.description.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(_clip(community.description, 72),
                                    style: const TextStyle(fontSize: 10, color: BuddyColors.textSecondary)),
                              ),
                            const SizedBox(height: 2),
                            Text('${community.memberCount} members',
                                style: const TextStyle(fontSize: 9, color: BuddyColors.textSecondary)),
                            const SizedBox(height: 6),
                            FilledButton.icon(
                              onPressed: busyId == community.id ? null : () => onLink(community),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(0, 30),
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                              icon: busyId == community.id
                                  ? const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(strokeWidth: 1.6, color: BuddyColors.black))
                                  : const Icon(Icons.link, size: 14),
                              label: Text(busyId == community.id ? 'Linking…' : 'Link to gym'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 8, fontWeight: FontWeight.w800, color: color)),
      );
}

class _MiniAction extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool filled;
  final bool destructive;
  final VoidCallback? onPressed;

  const _MiniAction({
    required this.label,
    this.icon,
    this.filled = false,
    this.destructive = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (destructive) {
      return IconButton(
        onPressed: onPressed,
        tooltip: label.isNotEmpty ? label : 'Unlink community',
        icon: Icon(icon ?? Icons.link_off, size: 16, color: BuddyColors.red),
        visualDensity: VisualDensity.compact,
      );
    }
    final style = filled
        ? FilledButton.styleFrom(
            minimumSize: const Size(0, 28),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          )
        : TextButton.styleFrom(
            minimumSize: const Size(0, 28),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            foregroundColor: BuddyColors.textSecondary,
          );
    return label.isNotEmpty
        ? filled
            ? FilledButton(
                onPressed: onPressed,
                style: style,
                child: Text(label),
              )
            : TextButton(
                onPressed: onPressed,
                style: style,
                child: Text(label),
              )
        : const SizedBox.shrink();
  }
}

Map<String, dynamic> _mapOf(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

int _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('${value ?? ''}'.split('.').first) ?? 0;
}

String _clip(String value, int max) =>
    value.length <= max ? value : '${value.substring(0, max - 1)}…';

String _relativeTime(DateTime? time) {
  if (time == null) return '';
  final seconds = DateTime.now().difference(time).inSeconds.abs();
  if (seconds < 60) return 'just now';
  if (seconds < 3600) return '${seconds ~/ 60}m ago';
  if (seconds < 86400) return '${seconds ~/ 3600}h ago';
  if (seconds < 7 * 86400) return '${seconds ~/ 86400}d ago';
  return '${time.day}/${time.month}';
}

// ---------------------------------------------------------------------------
// Analytics tab
// ---------------------------------------------------------------------------

class GymAnalyticsTab extends ConsumerStatefulWidget {
  final String slug;
  final String gymName;
  const GymAnalyticsTab({super.key, required this.slug, required this.gymName});

  @override
  ConsumerState<GymAnalyticsTab> createState() => _GymAnalyticsTabState();
}

class _GymAnalyticsTabState extends ConsumerState<GymAnalyticsTab> {
  String _segment = 'overview';

  Future<void> _share(GymAnalyticsData data) async {
    final text = data.shareCard.isNotEmpty ? data.shareCard : '${widget.gymName} insights';
    await SharePlus.instance.share(
      ShareParams(subject: widget.gymName, text: text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slug = widget.slug;
    final async = ref.watch(gymAnalyticsProvider(slug));
    final messagesAsync = ref.watch(gymMessagesProvider(slug));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RoleSectionTitle(
          'Analytics',
          trailing: async.asData?.value != null
              ? IconButton(
                  icon: const Icon(Icons.share_outlined, size: 18),
                  tooltip: 'Share gym insights',
                  onPressed: () => _share(async.asData!.value),
                )
              : null,
        ),
        async.when(
          loading: () => const PageLoader(fullScreen: false),
          error: (error, _) => const RoleNotice(
            message: 'Could not load analytics.',
            isError: true,
          ),
          data: (data) {
            final k = data.kpis;
            final g = data.growth;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionLabel('Growth · vs previous 30 days'),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _GrowthChip(label: 'Audience', pct: g.audiencePct),
                      _GrowthChip(label: 'Check-ins', pct: g.checkInsPct),
                      _GrowthChip(label: 'Bookings', pct: g.bookingsPct),
                      _GrowthChip(label: 'Posts', pct: g.postsPct),
                      _GrowthChip(label: 'Messages', pct: g.messagesPct),
                      _GrowthChip(label: 'Revenue', pct: g.revenuePct),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                RoleFilterChips<String>(
                  options: const ['overview', 'posts', 'messaging', 'shop'],
                  selected: _segment,
                  label: (v) => switch (v) {
                    'overview' => 'Overview',
                    'posts' => 'Posts',
                    'messaging' => 'Messaging',
                    _ => 'Connected shop',
                  },
                  onSelected: (v) => setState(() => _segment = v),
                ),
                const SizedBox(height: 10),
                if (_segment == 'overview') ...[
                  const _SectionLabel('Audience & retention'),
                  _TileGrid(tiles: [
                    _KpiTile(label: 'Active members', value: '${k.activeMembers}'),
                    _KpiTile(label: 'New · 30d', value: '+${k.newMembers30d}'),
                    _KpiTile(label: 'Churned · 30d', value: '${k.churned30d}'),
                    _KpiTile(label: 'Retention', value: '${k.retentionRate30d.toStringAsFixed(1)}%'),
                    _KpiTile(label: 'Activation', value: '${k.activationRate30d.toStringAsFixed(1)}%'),
                    _KpiTile(label: 'Community members', value: '${k.communityMembers}'),
                  ]),
                  const SizedBox(height: 10),
                  const _SectionLabel('Door & coaching'),
                  _TileGrid(tiles: [
                    _KpiTile(label: 'Check-ins', value: '${k.checkIns30d}'),
                    _KpiTile(label: 'Per day', value: k.avgCheckInsPerDay.toStringAsFixed(1)),
                    _KpiTile(label: 'Unique attendees', value: '${k.uniqueAttendees30d}'),
                    _KpiTile(label: 'Visit rate', value: k.visitRate30d.toStringAsFixed(1),
                        sub: 'Check-ins / member'),
                    _KpiTile(label: 'Bookings', value: '${k.bookings30d}'),
                    _KpiTile(label: 'Completed', value: '${k.completedBookings30d}'),
                  ]),
                  const SizedBox(height: 10),
                  const _SectionLabel('Conversion'),
                  Row(
                    children: [
                      Expanded(child: _ConversionCard(
                        title: 'Join-request conversion',
                        percent: k.joinConversion30d,
                        caption: '${k.joinRequestsApproved30d} of ${k.joinRequests30d} requests approved',
                        color: BuddyColors.green,
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: _ConversionCard(
                        title: 'Member activation',
                        percent: k.activationRate30d,
                        caption: '${k.uniqueAttendees30d} of ${k.activeMembers} checked in',
                        color: BuddyColors.blue,
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: _ConversionCard(
                        title: 'Retention',
                        percent: k.retentionRate30d,
                        caption: 'Active vs ${k.churned30d} churned',
                        color: BuddyColors.gold,
                      )),
                    ],
                  ),
                  const SizedBox(height: 10),
                  RoleCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionLabel('Revenue artifacts · last 30 days'),
                        _BucketBars(series: data.revenueArtifacts, color: BuddyColors.gold),
                      ],
                    ),
                  ),
                ] else if (_segment == 'posts') ...[
                  _TileGrid(tiles: [
                    _KpiTile(label: 'Posts · 30d', value: '${k.posts30d}',
                        sub: 'Routine posts & classes'),
                    _KpiTile(label: 'Avg per day', value: (k.posts30d / 30).toStringAsFixed(1)),
                    _KpiTile(label: 'Audience growth', value: '${g.audiencePct.toStringAsFixed(1)}%',
                        sub: 'New members vs prev. 30d'),
                    _KpiTile(label: 'Visit rate', value: k.visitRate30d.toStringAsFixed(1),
                        sub: 'Check-ins / member'),
                  ]),
                  const SizedBox(height: 10),
                  RoleCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionLabel('Posts per day · last 30 days'),
                        _BucketBars(series: data.posts, color: BuddyColors.blue),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Routine posts and class sessions feed this curve; announcements and the gym feed live in the Posts tab.',
                    style: TextStyle(fontSize: 9, color: BuddyColors.textSecondary),
                  ),
                ] else if (_segment == 'messaging') ...[
                  _TileGrid(tiles: [
                    _KpiTile(label: 'Messages · 30d', value: '${k.messages30d}',
                        sub: 'Your inbox & linked communities'),
                    _KpiTile(label: 'From real clients', value: '${k.inboundClientMessages30d}',
                        sub: 'Not your staff'),
                    _KpiTile(label: 'Messaging growth', value: '${g.messagesPct.toStringAsFixed(1)}%',
                        sub: 'vs previous 30d'),
                    _KpiTile(label: 'Community members', value: '${k.communityMembers}',
                        sub: 'Linked communities'),
                  ]),
                  const SizedBox(height: 10),
                  RoleCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionLabel('Messages per day · last 30 days'),
                        _BucketBars(series: data.messages, color: BuddyColors.green),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const _SectionLabel('Latest from real clients'),
                  messagesAsync.when(
                    loading: () => const PageLoader(fullScreen: false),
                    error: (_, _) => const Text('Could not load messages.',
                        style: TextStyle(fontSize: 11, color: BuddyColors.red)),
                    data: (messages) => messages.recentInbound.isEmpty
                        ? const Text('No client messages in the last 30 days.',
                            style: TextStyle(fontSize: 11, color: BuddyColors.textSecondary))
                        : Column(
                            children: [
                              for (final message in messages.recentInbound.take(4))
                                _InboundMessageTile(message: message),
                            ],
                          ),
                  ),
                ] else ...[
                  _TileGrid(tiles: [
                    _KpiTile(label: 'Paid orders · 30d', value: '${k.shopOrders30d}',
                        sub: 'Across connected shops'),
                    _KpiTile(label: 'Revenue · 30d', value: '${k.revenue30dArtifacts}',
                        sub: 'Artifacts · joins + shops + events'),
                    _KpiTile(label: 'Revenue growth', value: '${g.revenuePct.toStringAsFixed(1)}%',
                        sub: 'vs previous 30d'),
                    _KpiTile(label: 'Lifetime artifacts', value: '${k.revenueLifetimeArtifacts}'),
                  ]),
                  const SizedBox(height: 8),
                  _TileGrid(tiles: [
                    _ShopCategoryTile(icon: Icons.event_rounded, label: 'Events hosted',
                        now: k.eventsHosted30d, total: k.eventsHosted, color: const Color(0xFF7B61FF)),
                    _ShopCategoryTile(icon: Icons.shopping_bag_outlined, label: 'Products sold',
                        now: k.productsSold30d, total: k.productsSold, color: const Color(0xFFFF6B35)),
                    _ShopCategoryTile(icon: Icons.school_outlined, label: 'Programmes sold',
                        now: k.programmesSold30d, total: k.programmesSold, color: BuddyColors.green),
                    _ShopCategoryTile(icon: Icons.restaurant_menu, label: 'Meal plans sold',
                        now: k.mealPlansSold30d, total: k.mealPlansSold, color: BuddyColors.gold),
                  ]),
                  const SizedBox(height: 4),
                  const Text(
                    '30-day vs all-time sales for events, products, programmes and meal plans sold by the shop(s) connected to this gym. Connect a shop from the Shops tab to see this fill in.',
                    style: TextStyle(fontSize: 9, color: BuddyColors.textSecondary),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ConversionCard extends StatelessWidget {
  final String title;
  final double percent;
  final String caption;
  final Color color;

  const _ConversionCard({
    required this.title,
    required this.percent,
    required this.caption,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RoleCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: const TextStyle(fontSize: 8, color: BuddyColors.textSecondary, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text('${percent.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (percent / 100).clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: BuddyColors.surfaceRaised,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 4),
          Text(caption,
              style: const TextStyle(fontSize: 8, color: BuddyColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _ShopCategoryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int now;
  final int total;
  final Color color;

  const _ShopCategoryTile({
    required this.icon,
    required this.label,
    required this.now,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RoleCard(
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 2,
            decoration: BoxDecoration(color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(icon, size: 13, color: color),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      label.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 8,
                        color: BuddyColors.textSecondary,
                        letterSpacing: 0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('$now',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('$total all-time',
                  style: const TextStyle(fontSize: 9, color: BuddyColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
