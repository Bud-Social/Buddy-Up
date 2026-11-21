import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/gym.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/badge.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/role_dashboard_shell.dart';
import '../providers/gym_manage_provider.dart';
import '../providers/gym_provider.dart';
import '../widgets/gym_insights_tabs.dart';
import '../widgets/gym_posts_tab.dart';
import '../../feed/widgets/gym_actor_identity.dart';


/// Gym management.
///
/// Reuses the exact data sources and cards `GymDetailScreen` already renders —
/// same members, schedule posts and reviews, same `gymsApi` calls — and adds the
/// two surfaces an owner needs that the public page has no affordance for:
/// approving join requests and sending invites, plus posting a schedule update
/// and replying to a review.
///
/// There is no dedicated gym-manage endpoint set: every panel below is built on
/// endpoints the app already wraps.
///
/// A non-owner who deep-links here still gets a working screen — the read-only
/// panels render — with an explicit note that the write actions are limited,
/// rather than a wall.
class GymManageScreen extends ConsumerWidget {
  final String slug;

  const GymManageScreen({super.key, required this.slug});

  /// Privileged surfaces. Owners, co-owners and moderators see the full
  /// roster (Overview/Members/Team/Requests/...); a regular member only sees
  /// the read-only panels with an explicit notice.
  static const adminTabs = ['Overview', 'Members', 'Team', 'Requests', 'Posts', 'Schedule', 'Reviews', 'Sessions', 'Messages', 'Community', 'Analytics', 'Logs'];
  static const memberTabs = ['Members', 'Requests', 'Schedule', 'Reviews'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gymAsync = ref.watch(gymDetailProvider(slug));

    return gymAsync.when(
      loading: () => const RoleDashboardShell(
        title: 'Manage gym',
        body: PageLoader(),
      ),
      error: (error, _) => RoleDashboardShell(
        title: 'Manage gym',
        body: ErrorView(
          message: gymManageErrorMessage(error, fallback: 'Could not load this gym.'),
          onRetry: () => ref.invalidate(gymDetailProvider(slug)),
        ),
      ),
      data: (gym) => _ManageBody(slug: slug, gym: gym),
    );
  }
}

class _ManageBody extends ConsumerStatefulWidget {
  final String slug;
  final Gym gym;

  const _ManageBody({
    required this.slug,
    required this.gym,
  });

  @override
  ConsumerState<_ManageBody> createState() => _ManageBodyState();
}

class _ManageBodyState extends ConsumerState<_ManageBody> {
  int _tabIndex = 0;
  String? _actionError;
  String? _notice;
  String? _busyId;

  Gym get gym => widget.gym;

  bool get isAdmin => isGymAdminRole(gym.membershipRole);

  void _clearMessages() {
    if (_actionError != null || _notice != null) {
      setState(() {
        _actionError = null;
        _notice = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestsCount = ref
            .watch(gymManageJoinRequestsProvider(widget.slug))
            .value
            ?.length ??
        0;

    // Overview/Team/Logs are privileged surfaces — a regular member deep-linking
    // here gets the traffic they can act on instead of 403 furniture.
    final panelByTab = <String, Widget Function()>{
      'Overview': _overviewTab,
      'Members': _membersTab,
      'Team': _teamTab,
      'Requests': _requestsTab,
      'Schedule': _scheduleTab,
      'Reviews': _reviewsTab,
      'Sessions': () => GymSessionsTab(slug: widget.slug),
      'Messages': () => GymMessagesTab(slug: widget.slug),
      'Community': () => GymCommunitiesTab(slug: widget.slug, gymName: gym.name),
      'Posts': () => GymPostsTab(
            slug: widget.slug,
            identity: GymActorIdentity(
              id: gym.id,
              name: gym.name,
              logoUrl: gym.logoUrl,
              isVerified: gym.isVerified,
              tier: gym.tier,
            ),
          ),
      'Analytics': () => GymAnalyticsTab(slug: widget.slug, gymName: gym.name),
      'Logs': _logsTab,
    };
    final tabs = isAdmin ? GymManageScreen.adminTabs : GymManageScreen.memberTabs;
    final panels = [for (final tab in tabs) (tab, panelByTab[tab]!)];
    if (_tabIndex >= panels.length) _tabIndex = 0;
    final labels = [for (final panel in panels) panel.$1];

    return RoleDashboardShell(
      title: gym.name,
      subtitle: 'Manage @${gym.handle}',
      actions: [
        IconButton(
          icon: const Icon(Icons.open_in_new, size: 18),
          tooltip: 'View gym',
          onPressed: () => context.pushReplacement('/gyms/${gym.handle}'),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(gymManageMembersProvider),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            if (!isAdmin)
              const RoleNotice(
                message:
                    'You are not an owner or co-owner of this gym, so management '
                    'actions are limited.',
              ),
            if (_actionError != null)
              RoleNotice(message: _actionError!, isError: true),
            if (_notice != null) RoleNotice(message: _notice!),
            RoleFilterChips<String>(
              options: labels,
              selected: labels[_tabIndex],
              label: (tab) => tab == 'Requests' && requestsCount > 0
                  ? '$tab ($requestsCount)'
                  : tab,
              onSelected: (tab) {
                _clearMessages();
                setState(() => _tabIndex = labels.indexOf(tab));
              },
            ),
            const SizedBox(height: 16),
            panels[_tabIndex].$2(),
          ],
        ),
      ),
    );
  }

  Widget _overviewTab() {
    if (!isAdmin) {
      return const Column(
        children: [
          RoleSectionTitle('Overview'),
          _PanelEmpty('Gym analytics are available to owners, co-owners and moderators.'),
        ],
      );
    }

    final metricsAsync = ref.watch(gymPartnerMetricsProvider(widget.slug));
    return Column(
      children: [
        const RoleSectionTitle('Overview'),
        metricsAsync.when(
          loading: () => const PageLoader(fullScreen: false),
          error: (error, _) => RoleNotice(
            message: gymManageErrorMessage(
              error,
              fallback: 'Could not load gym analytics.',
            ),
            isError: true,
          ),
          data: (metrics) => Column(
            children: [
              // Each tile names its window. Active members is a gauge and
              // check-ins is a delta; putting them under one bare "Overview"
              // heading is how a dashboard starts lying to whoever reads it.
              Row(
                children: [
                  Expanded(child: _MetricTile(label: 'Active members', value: '${metrics.activeMembers}')),
                  const SizedBox(width: 10),
                  Expanded(child: _MetricTile(label: 'Check-ins (30d)', value: '${metrics.checkIns30d}')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: _MetricTile(
                          label: 'Attendees (30d)', value: '${metrics.uniqueAttendees30d}')),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _MetricTile(
                          label: 'Activities (30d)', value: '${metrics.scheduledActivities30d}')),
                ],
              ),
              const SizedBox(height: 10),
              _MetricTile(
                label: 'Activation rate (30d)',
                value: '${(metrics.activationRate30d * 100).round()}%',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _membersTab() {
    final membersAsync = ref.watch(gymManageMembersProvider(widget.slug));
    return Column(
      children: [
        RoleSectionTitle(
          'Members',
          trailing: isAdmin
              ? TextButton.icon(
                  onPressed: _openInvite,
                  icon: const Icon(Icons.person_add_alt, size: 14),
                  label: const Text('Invite',
                      style: TextStyle(fontSize: 11)),
                )
              : null,
        ),
        membersAsync.when(
          loading: () => const PageLoader(fullScreen: false),
          error: (error, _) => RoleNotice(
            message: gymManageErrorMessage(
              error,
              fallback: 'Could not load members.',
            ),
            isError: true,
          ),
          data: (members) => members.isEmpty
              ? const _PanelEmpty('No members yet.')
              : Column(
                  children: [
                    for (final membership in members)
                      _MemberCard(
                        membership: membership,
                        slug: widget.slug,
                        // Owner/co-owner rows are out of reach: the endpoint
                        // refuses them and ownership moves by transfer.
                        canManage: isAdmin &&
                            !const {'owner', 'co_owner'}.contains(membership.role),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _requestsTab() {
    final requestsAsync =
        ref.watch(gymManageJoinRequestsProvider(widget.slug));
    return Column(
      children: [
        const RoleSectionTitle('Join requests'),
        requestsAsync.when(
          loading: () => const PageLoader(fullScreen: false),
          error: (error, _) => RoleNotice(
            message: gymManageErrorMessage(
              error,
              fallback: 'Could not load join requests.',
            ),
            isError: true,
          ),
          data: (requests) => requests.isEmpty
              ? const _PanelEmpty('No pending join requests.')
              : Column(
                  children: [
                    for (final request in requests)
                      _JoinRequestCard(
                        request: request,
                        busy: _busyId == request.id,
                        enabled: isAdmin,
                        onDecide: (decision) =>
                            _decide(request, decision),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _scheduleTab() {
    final postsAsync =
        ref.watch(gymManageSchedulePostsProvider(widget.slug));
    return Column(
      children: [
        RoleSectionTitle(
          'Schedule updates',
          trailing: isAdmin
              ? TextButton.icon(
                  onPressed: _openSchedulePost,
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Post', style: TextStyle(fontSize: 11)),
                )
              : null,
        ),
        postsAsync.when(
          loading: () => const PageLoader(fullScreen: false),
          error: (error, _) => RoleNotice(
            message: gymManageErrorMessage(
              error,
              fallback: 'Could not load schedule updates.',
            ),
            isError: true,
          ),
          data: (posts) => posts.isEmpty
              ? const _PanelEmpty('No schedule updates posted yet.')
              : Column(
                  children: [for (final post in posts) _ScheduleCard(post: post)],
                ),
        ),
      ],
    );
  }

  Widget _reviewsTab() {
    final reviewsAsync = ref.watch(gymManageReviewsProvider(widget.slug));
    return Column(
      children: [
        const RoleSectionTitle('Reviews'),
        reviewsAsync.when(
          loading: () => const PageLoader(fullScreen: false),
          error: (error, _) => RoleNotice(
            message: gymManageErrorMessage(
              error,
              fallback: 'Could not load reviews.',
            ),
            isError: true,
          ),
          data: (reviews) => reviews.isEmpty
              ? const _PanelEmpty('No reviews yet.')
              : Column(
                  children: [
                    for (final review in reviews)
                      _ReviewCard(
                        review: review,
                        canReply: isAdmin && review.replyText.isEmpty,
                        onReply: (text) => _reply(review, text),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _teamTab() {
    final membersAsync = ref.watch(gymManageMembersProvider(widget.slug));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RoleSectionTitle('Team'),
        membersAsync.when(
          loading: () => const PageLoader(fullScreen: false),
          error: (error, _) => RoleNotice(
            message: gymManageErrorMessage(
              error,
              fallback: 'Could not load team.',
            ),
            isError: true,
          ),
          data: (members) {
            const staffRoles = {'owner', 'co_owner', 'moderator', 'trainer'};
            final staff = members
                .where((m) => staffRoles.contains(m.role))
                .toList()
              ..sort((a, b) => _roleRank(a.role).compareTo(_roleRank(b.role)));
            final counts = <String, int>{};
            for (final member in members) {
              counts[member.role] = (counts[member.role] ?? 0) + 1;
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    for (final role in const ['owner', 'co_owner', 'moderator', 'trainer']) ...[
                      Expanded(child: _TeamCountTile(label: _roleLabel(role), count: counts[role] ?? 0)),
                      if (role != 'trainer') const SizedBox(width: 8),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Promote a member to Trainer to post routines under the gym. '
                  'Moderators triage the queue but cannot touch tier, wallet or '
                  'deletion. Only owners and co-owners can change these roles.',
                  style: TextStyle(fontSize: 10, color: BuddyColors.textSecondary),
                ),
                const SizedBox(height: 10),
                if (staff.isEmpty)
                  const _PanelEmpty('No staff yet. Invite someone from the Members tab and promote them here.')
                else
                  for (final membership in staff)
                    _TeamMemberCard(membership: membership, slug: widget.slug),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _logsTab() {
    final logsAsync = ref.watch(gymManageActionLogsProvider(widget.slug));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RoleSectionTitle(
          'Action log',
          trailing: TextButton.icon(
            onPressed: () => ref.invalidate(gymManageActionLogsProvider(widget.slug)),
            icon: const Icon(Icons.refresh, size: 14),
            label: const Text('Refresh', style: TextStyle(fontSize: 11)),
          ),
        ),
        logsAsync.when(
          loading: () => const PageLoader(fullScreen: false),
          error: (error, _) => RoleNotice(
            message: gymManageErrorMessage(
              error,
              fallback: 'Could not load the action log.',
            ),
            isError: true,
          ),
          data: (logs) => logs.isEmpty
              ? const _PanelEmpty('Nothing logged yet. Role changes, venues, coaches, announcements and events will appear here.')
              : Column(children: [
                  for (final entry in logs) _ActionLogTile(entry: entry),
                ]),
        ),
      ],
    );
  }

  Future<void> _decide(JoinRequest request, String decision) async {
    setState(() {
      _busyId = request.id;
      _actionError = null;
      _notice = null;
    });
    try {
      await ref
          .read(gymJoinRequestActionsProvider)
          .decide(widget.slug, request.id, decision);
      if (!mounted) return;
      setState(() => _notice = 'Join request $decision.');
    } catch (error) {
      if (!mounted) return;
      setState(() => _actionError =
          gymManageErrorMessage(error, fallback: 'Could not update that request.'));
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _reply(GymReview review, String text) async {
    setState(() {
      _busyId = review.id;
      _actionError = null;
      _notice = null;
    });
    try {
      await ref
          .read(gymReviewReplyActionsProvider)
          .reply(widget.slug, review.id, text);
      if (!mounted) return;
      setState(() => _notice = 'Reply posted.');
    } catch (error) {
      if (!mounted) return;
      setState(() => _actionError =
          gymManageErrorMessage(error, fallback: 'Could not post that reply.'));
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _openInvite() async {
    final target = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: BuddyColors.black,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _InviteSheet(),
    );
    final value = target?.trim() ?? '';
    if (value.isEmpty || !mounted) return;

    setState(() {
      _actionError = null;
      _notice = null;
    });
    try {
      await ref.read(gymInviteActionsProvider).send(widget.slug, value);
      if (!mounted) return;
      setState(() => _notice = 'Invite sent to $value.');
    } catch (error) {
      if (!mounted) return;
      setState(() => _actionError =
          gymManageErrorMessage(error, fallback: 'Could not send that invite.'));
    }
  }

  Future<void> _openSchedulePost() async {
    final payload = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: BuddyColors.black,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _SchedulePostSheet(),
    );
    if (payload == null || !mounted) return;

    setState(() {
      _actionError = null;
      _notice = null;
    });
    try {
      await ref
          .read(gymSchedulePostActionsProvider)
          .create(widget.slug, payload);
      if (!mounted) return;
      setState(() => _notice = 'Schedule update posted.');
    } catch (error) {
      if (!mounted) return;
      setState(() => _actionError =
          gymManageErrorMessage(error, fallback: 'Could not post that update.'));
    }
  }
}

class _PanelEmpty extends StatelessWidget {
  final String message;

  const _PanelEmpty(this.message);

  @override
  Widget build(BuildContext context) {
    return RoleCard(
      padding: const EdgeInsets.all(24),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          color: BuddyColors.textSecondary,
        ),
      ),
    );
  }
}

class _MemberCard extends ConsumerWidget {
  final GymMembership membership;
  final String slug;

  /// Whether the viewer may act on this member at all.
  final bool canManage;

  const _MemberCard(
      {required this.membership, required this.slug, required this.canManage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _MemberCardBody(
      membership: membership,
      canManage: canManage,
      onRemove: canManage ? () => _remove(context, ref) : null,
      onChangeRole: canManage ? () => _changeRole(context, ref) : null,
    );
  }

  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: BuddyColors.surface,
        title: const Text('Remove member',
            style: TextStyle(color: BuddyColors.textPrimary)),
        content: const Text(
          'They lose access to this gym immediately and are notified.',
          style: TextStyle(color: BuddyColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: BuddyColors.textSecondary)),
          ),
          TextButton(
            key: const Key('manage-remove-confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove', style: TextStyle(color: BuddyColors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await ref.read(gymRepositoryProvider).removeMember(slug, membership.memberId);
    ref.invalidate(gymManageMembersProvider(slug));
  }

  Future<void> _changeRole(BuildContext context, WidgetRef ref) async {
    final role = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: BuddyColors.surface,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Change role',
                  style: TextStyle(
                      color: BuddyColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
            ),
            for (final option in const ['member', 'trainer', 'moderator'])
              ListTile(
                key: Key('manage-role-$option'),
                title: Text(option.replaceAll('_', ' '),
                    style: const TextStyle(color: BuddyColors.textPrimary)),
                onTap: () => Navigator.of(sheetContext).pop(option),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (role == null || !context.mounted) return;

    await ref
        .read(gymRepositoryProvider)
        .manageMember(slug, membership.memberId, {'role': role});
    ref.invalidate(gymManageMembersProvider(slug));
  }
}

class _MemberCardBody extends StatelessWidget {
  final GymMembership membership;
  final bool canManage;
  final VoidCallback? onRemove;
  final VoidCallback? onChangeRole;

  const _MemberCardBody(
      {required this.membership,
      required this.canManage,
      this.onRemove,
      this.onChangeRole});

  @override
  Widget build(BuildContext context) {
    final member = membership.memberData;
    return RoleCard(
      padding: const EdgeInsets.all(12),
      onTap: () => context.push('/${member.username}'),
      child: Row(
        children: [
          Avatar(
            src: member.avatarUrl,
            alt: member.displayName,
            size: AvatarSize.sm,
            verificationStatus: member.verificationStatus,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.displayName.isEmpty ? member.username : member.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Text(
                  '@${member.username}',
                  style: const TextStyle(
                      fontSize: 11, color: BuddyColors.textSecondary),
                ),
              ],
            ),
          ),
          BuddyBadge(
            label: membership.role.replaceAll('_', ' '),
            color: _roleColor(membership.role),
          ),
          if (canManage)
            PopupMenuButton<String>(
              key: Key('manage-member-menu-${membership.memberId}'),
              color: BuddyColors.surface,
              icon: const Icon(Icons.more_horiz,
                  color: BuddyColors.textSecondary, size: 18),
              onSelected: (action) {
                if (action == 'remove') onRemove?.call();
                if (action == 'change_role') onChangeRole?.call();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                    value: 'change_role',
                    child: Text('Change role',
                        style: TextStyle(color: BuddyColors.textPrimary))),
                PopupMenuItem(
                    value: 'remove',
                    child:
                        Text('Remove', style: TextStyle(color: BuddyColors.red))),
              ],
            ),
        ],
      ),
    );
  }
}

/// One figure with the window it covers spelled out on the tile itself.
class _MetricTile extends StatelessWidget {
  final String label;
  final String value;

  const _MetricTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return RoleCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: BuddyColors.textSecondary)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _JoinRequestCard extends StatelessWidget {
  final JoinRequest request;
  final bool busy;
  final bool enabled;
  final ValueChanged<String> onDecide;

  const _JoinRequestCard({
    required this.request,
    required this.busy,
    required this.enabled,
    required this.onDecide,
  });

  @override
  Widget build(BuildContext context) {
    final requester = request.requesterData;
    return RoleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(
                src: requester.avatarUrl,
                alt: requester.displayName,
                size: AvatarSize.sm,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      requester.displayName.isEmpty
                          ? requester.username
                          : requester.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '@${requester.username} · ${_day(request.createdAt)}',
                      style: const TextStyle(
                          fontSize: 11, color: BuddyColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (request.message.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              request.message,
              style: const TextStyle(
                fontSize: 12,
                color: BuddyColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
          if (enabled) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: busy ? null : () => onDecide('approved'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    textStyle:
                        const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Approve'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: busy ? null : () => onDecide('rejected'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    foregroundColor: BuddyColors.red,
                    side: const BorderSide(color: BuddyColors.red),
                    textStyle:
                        const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Reject'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final GymSchedulePost post;

  const _ScheduleCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return RoleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(
                src: post.authorData.avatarUrl,
                alt: post.authorData.displayName,
                size: AvatarSize.sm,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  post.authorData.displayName.isEmpty
                      ? post.authorData.username
                      : post.authorData.displayName,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              if (post.activityType.isNotEmpty)
                BuddyBadge(
                  label: post.activityType.replaceAll('_', ' '),
                  color: BuddyColors.gold,
                ),
            ],
          ),
          if (post.title.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              post.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
          if (post.content.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              post.content,
              style: const TextStyle(fontSize: 13, height: 1.45),
            ),
          ],
          if (post.startTime != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.access_time,
                    size: 13, color: BuddyColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _moment(post.startTime!),
                    style: const TextStyle(
                        fontSize: 12, color: BuddyColors.textSecondary),
                  ),
                ),
                if (post.locationMode.isNotEmpty)
                  BuddyBadge(
                    label: post.locationMode.replaceAll('_', ' '),
                    color: BuddyColors.textSecondary,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewCard extends StatefulWidget {
  final GymReview review;
  final bool canReply;
  final ValueChanged<String> onReply;

  const _ReviewCard({
    required this.review,
    required this.canReply,
    required this.onReply,
  });

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  final _controller = TextEditingController();
  bool _replying = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final reviewer = review.reviewerData;

    return RoleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(
                src: reviewer.avatarUrl,
                alt: reviewer.displayName,
                size: AvatarSize.sm,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reviewer.displayName.isEmpty
                          ? reviewer.username
                          : reviewer.displayName,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        Text(
                          '@${reviewer.username}',
                          style: const TextStyle(
                              fontSize: 11, color: BuddyColors.textSecondary),
                        ),
                        if (review.rating > 0) ...[
                          const Text(' · ',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: BuddyColors.textSecondary)),
                          Row(
                            children: [
                              for (var i = 0; i < review.rating; i++)
                                const Icon(Icons.star,
                                    size: 10, color: BuddyColors.gold),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(review.comment,
                style: const TextStyle(fontSize: 13, height: 1.45)),
          ],
          if (review.replyText.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: BuddyColors.surfaceRaised
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
                border: const Border(
                    left: BorderSide(color: BuddyColors.green, width: 2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${review.repliedByData?.displayName ?? 'Gym admin'} replied',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review.replyText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: BuddyColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (widget.canReply && !_replying)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => setState(() => _replying = true),
                icon: const Icon(Icons.chat_bubble_outline, size: 14),
                label: const Text('Reply', style: TextStyle(fontSize: 12)),
              ),
            ),
          if (_replying) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 3,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Write your response…',
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => setState(() {
                    _replying = false;
                    _controller.clear();
                  }),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _controller.text.trim().isEmpty
                      ? null
                      : () => widget.onReply(_controller.text),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    textStyle:
                        const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Post reply'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InviteSheet extends StatefulWidget {
  const _InviteSheet();

  @override
  State<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends State<_InviteSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Invite members',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          const Text(
            'Search by username, or enter an email address.',
            style: TextStyle(fontSize: 12, color: BuddyColors.textSecondary),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            autofocus: true,
            style: const TextStyle(fontSize: 15),
            decoration: const InputDecoration(
              labelText: 'Username or email',
              hintText: 'karen or karen@example.com',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final value = _controller.text.trim();
                    if (value.isNotEmpty) Navigator.pop(context, value);
                  },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Send invite'),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The activity types the schedule-post endpoint accepts.
const List<String> _activityTypes = [
  'yoga',
  'hiit',
  'strength',
  'cardio',
  'live_stream',
  'workshop',
  'event',
  'session',
  'other',
];

class _SchedulePostSheet extends StatefulWidget {
  const _SchedulePostSheet();

  @override
  State<_SchedulePostSheet> createState() => _SchedulePostSheetState();
}

class _SchedulePostSheetState extends State<_SchedulePostSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _activity = 'other';
  DateTime? _start;
  DateTime? _end;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pick(bool isStart) async {
    final base = isStart ? _start : _end;
    final date = await showDatePicker(
      context: context,
      initialDate: base ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (!mounted) return;
    final picked = DateTime(date.year, date.month, date.day, time?.hour ?? 8, time?.minute ?? 0);
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          const Text('Post schedule update',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 14),
          TextField(
            controller: _titleController,
            style: const TextStyle(fontSize: 15),
            decoration: const InputDecoration(labelText: 'Title (optional)'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _activity,
            decoration: const InputDecoration(labelText: 'Activity type'),
            items: [
              for (final type in _activityTypes)
                DropdownMenuItem(
                  value: type,
                  child: Text(type.replaceAll('_', ' '),
                      style: const TextStyle(fontSize: 14)),
                ),
            ],
            onChanged: (value) => setState(() => _activity = value ?? 'other'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pick(true),
                  icon: const Icon(Icons.schedule, size: 14),
                  label: Text(
                    _start == null
                        ? 'Start'
                        : DateFormat.MMMd().add_jm().format(_start!),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pick(false),
                  icon: const Icon(Icons.schedule, size: 14),
                  label: Text(
                    _end == null
                        ? 'End'
                        : DateFormat.MMMd().add_jm().format(_end!),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contentController,
            maxLines: 3,
            style: const TextStyle(fontSize: 15),
            decoration: const InputDecoration(
              labelText: "What's the schedule update?",
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, {
                    if (_titleController.text.trim().isNotEmpty)
                      'title': _titleController.text.trim(),
                    'content': _contentController.text.trim(),
                    'activity_type': _activity,
                    'location_mode': 'in_house',
                    // Local time is sent as a UTC instant; the backend stores
                    // whatever it is given and the gym's timezone is a property
                    // of the gym, not of this form.
                    if (_start != null) 'start_time': _start!.toUtc().toIso8601String(),
                    if (_end != null) 'end_time': _end!.toUtc().toIso8601String(),
                  }),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Post'),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _roleColor(String role) {
  switch (role) {
    case 'owner':
      return BuddyColors.gold;
    case 'co_owner':
      return BuddyColors.green;
    case 'trainer':
      return BuddyColors.textSecondary;
    case 'moderator':
      return BuddyColors.textSecondary;
    default:
      return BuddyColors.textSecondary;
  }
}

String _day(String iso) {
  final parsed = DateTime.tryParse(iso);
  return parsed == null ? '' : DateFormat.yMMMd().format(parsed);
}

String _moment(String iso) {
  final parsed = DateTime.tryParse(iso);
  return parsed == null ? iso : DateFormat.MMMd().add_jm().format(parsed);
}


int _roleRank(String role) {
  switch (role) {
    case 'owner':
      return 0;
    case 'co_owner':
      return 1;
    case 'moderator':
      return 2;
    case 'trainer':
      return 3;
    default:
      return 4;
  }
}

String _roleLabel(String role) {
  switch (role) {
    case 'owner':
      return 'Owners';
    case 'co_owner':
      return 'Co-owners';
    case 'moderator':
      return 'Moderators';
    case 'trainer':
      return 'Trainers';
    default:
      return role.replaceAll('_', ' ');
  }
}

/// Headcount tile for the staff roster — one per privileged role.
class _TeamCountTile extends StatelessWidget {
  final String label;
  final int count;

  const _TeamCountTile({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return RoleCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Text('$count',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 9,
                  color: BuddyColors.textSecondary,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

/// One staff row with the same promotion grammar as the members tab:
/// trainer ↔ moderator toggle, demote to member, and remove.
class _TeamMemberCard extends ConsumerWidget {
  final GymMembership membership;
  final String slug;

  const _TeamMemberCard({required this.membership, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = membership.memberData;
    final gymAsync = ref.watch(gymDetailProvider(slug));
    final viewerRole = gymAsync.value?.membershipRole;
    final canManage = viewerRole == 'owner' || viewerRole == 'co_owner';
    final editable = canManage && !const {'owner', 'co_owner'}.contains(membership.role);

    Future<void> changeRole(String role) async {
      await ref
          .read(gymRepositoryProvider)
          .manageMember(slug, membership.memberId, {'role': role});
      ref.invalidate(gymManageMembersProvider(slug));
    }

    Future<void> remove() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: BuddyColors.surface,
          title: const Text('Remove from the gym?',
              style: TextStyle(color: BuddyColors.textPrimary)),
          content: Text(
            '${member.displayName.isEmpty ? member.username : member.displayName} loses access to this gym immediately.',
            style: const TextStyle(color: BuddyColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Keep', style: TextStyle(color: BuddyColors.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Remove', style: TextStyle(color: BuddyColors.red)),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await ref.read(gymRepositoryProvider).removeMember(slug, membership.memberId);
      ref.invalidate(gymManageMembersProvider(slug));
    }

    return RoleCard(
      child: Row(
        children: [
          Avatar(
            src: member.avatarUrl,
            alt: member.displayName,
            size: AvatarSize.sm,
            verificationStatus: member.verificationStatus,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.displayName.isEmpty ? member.username : member.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Text('@${member.username}',
                    style: const TextStyle(fontSize: 11, color: BuddyColors.textSecondary)),
              ],
            ),
          ),
          BuddyBadge(label: membership.role.replaceAll('_', ' '), color: _roleColor(membership.role)),
          if (editable) ...[
            _TeamActionPill(
              key: Key('team-demote-${membership.memberId}'),
              icon: Icons.remove_circle_outline,
              label: 'Demote',
              tint: BuddyColors.gold,
              onPressed: () => changeRole('member'),
            ),
            _TeamActionPill(
              key: Key('team-toggle-${membership.memberId}'),
              icon: Icons.swap_horiz,
              label: 'Toggle',
              onPressed: () => changeRole(membership.role == 'trainer' ? 'moderator' : 'trainer'),
            ),
            _TeamActionPill(
              key: Key('team-remove-${membership.memberId}'),
              icon: Icons.close,
              label: 'Remove',
              tint: BuddyColors.red,
              onPressed: remove,
            ),
          ],
        ],
      ),
    );
  }
}

/// One audit-trail row — expands to the before/after state delta.
class _ActionLogTile extends StatefulWidget {
  final GymActionLogEntry entry;

  const _ActionLogTile({required this.entry});

  @override
  State<_ActionLogTile> createState() => _ActionLogTileState();
}

class _ActionLogTileState extends State<_ActionLogTile> {
  bool _open = false;

  IconData get _icon {
    final action = widget.entry.action;
    if (action.startsWith('gym.venue')) return Icons.place_outlined;
    if (action.startsWith('gym.coach')) return Icons.fitness_center;
    if (action.startsWith('gym.member')) return Icons.manage_accounts_outlined;
    if (action.startsWith('gym.announce')) return Icons.campaign_outlined;
    if (action.startsWith('gym.events')) return Icons.event_outlined;
    if (action.startsWith('gym.shops')) return Icons.storefront_outlined;
    if (action.startsWith('gym.tier')) return Icons.workspace_premium_outlined;
    if (action.startsWith('gym.registration')) return Icons.description_outlined;
    if (action.startsWith('gym.update')) return Icons.edit_outlined;
    return Icons.receipt_long_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final hasDelta = entry.before != null || entry.after != null;
    return RoleCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: hasDelta ? () => setState(() => _open = !_open) : null,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: BuddyColors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_icon, size: 16, color: BuddyColors.green),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.action.replaceAll('.', ' · ').toUpperCase(),
                        style: const TextStyle(
                            fontSize: 9,
                            color: BuddyColors.textSecondary,
                            letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 2),
                      Text(entry.summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text('@${entry.actor}${entry.createdAt != null ? ' · ${_moment(entry.createdAt!.toIso8601String())}' : ''}',
                          style: const TextStyle(
                              fontSize: 10, color: BuddyColors.textSecondary)),
                    ],
                  ),
                ),
                if (hasDelta)
                  Icon(_open ? Icons.expand_less : Icons.expand_more,
                      size: 18, color: BuddyColors.textSecondary),
              ],
            ),
          ),
          if (_open && hasDelta) ...[
            const SizedBox(height: 8),
            _DeltaTable(before: entry.before, after: entry.after),
          ],
        ],
      ),
    );
  }
}

/// Small horizontally-stretched action pill for team rows. Cicular icon-only
/// buttons had to go; these keep the affordance stretched like the organiser
/// activator, with the label spelled out.
class _TeamActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? tint;
  final VoidCallback onPressed;

  const _TeamActionPill({
    super.key,
    required this.icon,
    required this.label,
    this.tint,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final color = tint ?? BuddyColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 12, color: color),
        label: Text(label, style: TextStyle(fontSize: 10, color: color)),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.4)),
          backgroundColor: color.withValues(alpha: 0.06),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          minimumSize: const Size(0, 26),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const StadiumBorder(),
        ),
      ),
    );
  }
}

/// Before/after table for one state delta. Never renders message/content fields.
class _DeltaTable extends StatelessWidget {
  final Map<String, dynamic>? before;
  final Map<String, dynamic>? after;

  const _DeltaTable({this.before, this.after});

  @override
  Widget build(BuildContext context) {
    final keys = <String>{
      ...?before?.keys,
      ...?after?.keys,
    }.toList()
      ..sort();
    Widget cell(dynamic value) =>
        Text(value == null ? '—' : '$value', maxLines: 3, overflow: TextOverflow.ellipsis);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: BuddyColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        border: const TableBorder(
          horizontalInside: BorderSide(color: BuddyColors.border, width: 0.5),
        ),
        columnWidths: const {
          0: FlexColumnWidth(0.9),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(2),
        },
        children: [
          const TableRow(
            decoration: BoxDecoration(color: BuddyColors.surfaceRaised),
            children: [
              Padding(padding: EdgeInsets.all(6), child: Text('Field', style: TextStyle(fontSize: 9, color: BuddyColors.textSecondary))),
              Padding(padding: EdgeInsets.all(6), child: Text('Before', style: TextStyle(fontSize: 9, color: BuddyColors.textSecondary))),
              Padding(padding: EdgeInsets.all(6), child: Text('After', style: TextStyle(fontSize: 9, color: BuddyColors.textSecondary))),
            ],
          ),
          for (final key in keys)
            TableRow(
              children: [
                Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(key,
                        style: const TextStyle(
                            fontSize: 9,
                            fontFamily: 'monospace',
                            color: BuddyColors.textSecondary))),
                Padding(padding: const EdgeInsets.all(6), child: cell(before?[key])),
                Padding(padding: const EdgeInsets.all(6), child: cell(after?[key])),
              ],
            ),
        ],
      ),
    );
  }
}
