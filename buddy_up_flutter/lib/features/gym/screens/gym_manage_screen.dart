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

  static const _tabs = ['Members', 'Requests', 'Schedule', 'Reviews'];

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
      data: (gym) => _ManageBody(
        slug: slug,
        gym: gym,
        tabs: _tabs,
      ),
    );
  }
}

class _ManageBody extends ConsumerStatefulWidget {
  final String slug;
  final Gym gym;
  final List<String> tabs;

  const _ManageBody({
    required this.slug,
    required this.gym,
    required this.tabs,
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
              options: widget.tabs,
              selected: widget.tabs[_tabIndex],
              label: (tab) => tab == 'Requests' && requestsCount > 0
                  ? '$tab ($requestsCount)'
                  : tab,
              onSelected: (tab) {
                _clearMessages();
                setState(() => _tabIndex = widget.tabs.indexOf(tab));
              },
            ),
            const SizedBox(height: 16),
            switch (_tabIndex) {
              0 => _membersTab(),
              1 => _requestsTab(),
              2 => _scheduleTab(),
              _ => _reviewsTab(),
            },
          ],
        ),
      ),
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
                      _MemberCard(membership: membership, isOwner: isAdmin),
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
      backgroundColor: Theme.of(context).colorScheme.surface,
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
      backgroundColor: Theme.of(context).colorScheme.surface,
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
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final GymMembership membership;
  final bool isOwner;

  const _MemberCard({required this.membership, required this.isOwner});

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
                color: Theme.of(context).colorScheme.surfaceContainerHighest
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