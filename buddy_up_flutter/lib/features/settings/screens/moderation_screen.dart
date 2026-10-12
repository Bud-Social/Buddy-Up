import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/admin_portal.dart';
import '../../notifications/providers/notification_provider.dart';
import '../providers/moderation_provider.dart';
import '../providers/settings_providers.dart';

/// Settings → Help & Safety → your moderation record.
///
/// Exists because an action a user cannot see is an action they cannot appeal.
/// Every warning, removal, suspension and ban raises a notification, and this
/// screen is where that notification becomes actionable: it shows the reason a
/// moderator wrote, the date the restriction lifts when there is one, and the
/// appeal button for it.
///
/// The action ids come from the notification metadata, because a non-staff user
/// has no endpoint that lists their own `ModerationAction` rows — see
/// `moderation_provider.dart`.
class ModerationScreen extends ConsumerStatefulWidget {
  /// Deep-link from a notification: pre-selects the action to appeal.
  final String? appealActionId;

  const ModerationScreen({super.key, this.appealActionId});

  @override
  ConsumerState<ModerationScreen> createState() => _ModerationScreenState();
}

class _ModerationScreenState extends ConsumerState<ModerationScreen> {
  String? _error;
  String? _notice;

  @override
  void initState() {
    super.initState();
    // Arriving from a notification with an action to appeal should land on the
    // form, not on a list they then have to find the row in.
    final actionId = widget.appealActionId;
    if (actionId != null && actionId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openAppealSheet(context, actionId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notices = ref.watch(myModerationNoticesProvider);
    final appeals = ref.watch(myAppealsProvider);
    final commendations = ref.watch(myCommendationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Help & Safety')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myModerationNoticesProvider);
          ref.invalidate(myAppealsProvider);
          ref.invalidate(myCommendationsProvider);
          ref.invalidate(notificationsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _SectionHeading(
              title: 'Your moderation record',
              blurb: 'Every action taken against your account, with the reason '
                  'a moderator recorded.',
            ),
            const SizedBox(height: 12),
            if (_error != null) ...[
              _ErrorCard(message: _error!),
              const SizedBox(height: 12),
            ],
            if (_notice != null) ...[
              _NoticeCard(message: _notice!),
              const SizedBox(height: 12),
            ],
            ...notices.when(
              loading: () => const [_LoadingCard()],
              error: (e, _) => [
                _ErrorCard(message: apiErrorMessage(
                  e,
                  fallback: 'Could not load your moderation record.',
                )),
              ],
              data: (rows) => [
                if (rows.isEmpty)
                  const _EmptyCard(
                    icon: Icons.verified_user_outlined,
                    title: 'Nothing on your record.',
                    hint: 'Warnings, removals, suspensions and bans appear '
                        'here with their reason, and you can appeal any of them.',
                  )
                else
                  for (final notice in rows) _noticeCard(notice),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionHeading(
              title: 'Your appeals',
              blurb: 'An appeal is reviewed by a moderator who was not the one '
                  'who issued the action.',
            ),
            const SizedBox(height: 12),
            ...appeals.when(
              loading: () => const [_LoadingCard()],
              error: (e, _) => [
                _ErrorCard(message: apiErrorMessage(
                  e,
                  fallback: 'Could not load your appeals.',
                )),
              ],
              data: (page) => [
                if (page.items.isEmpty)
                  const _EmptyCard(
                    icon: Icons.balance_outlined,
                    title: 'You have not appealed anything.',
                    hint: 'If you think a decision was wrong, open the action '
                        'above and tap Appeal.',
                  )
                else
                  for (final appeal in page.items) _appealCard(appeal),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionHeading(
              title: 'Commendations',
              blurb: 'Recorded by staff. You can remove one from your profile.',
            ),
            const SizedBox(height: 12),
            ...commendations.when(
              loading: () => const [_LoadingCard()],
              error: (e, _) => [
                _ErrorCard(message: apiErrorMessage(
                  e,
                  fallback: 'Could not load your commendations.',
                )),
              ],
              data: (page) => [
                if (page.items.isEmpty)
                  const _EmptyCard(
                    icon: Icons.workspace_premium_outlined,
                    title: 'No commendations yet.',
                    hint: 'Staff record commendations here when you have done '
                        'something the platform wants to mark.',
                  )
                else
                  for (final commendation in page.items)
                    _commendationCard(commendation),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _noticeCard(MyModerationNotice notice) {
    final cs = Theme.of(context).colorScheme;
    final tint = notice.restrictsAccess ? BuddyColors.red : BuddyColors.gold;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tint.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_iconFor(notice.kind), size: 18, color: tint),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  notice.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
          if (notice.reason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Reason given: ${notice.reason}',
              style: TextStyle(fontSize: 13, color: cs.onSurface, height: 1.4),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.schedule, size: 13, color: cs.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  notice.endDateLabel,
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
          if (notice.durationDays != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Term: ${notice.durationDays} day(s)',
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _shortDateTime(notice.createdAt),
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: notice.isAppealable
                  ? () => _openAppealSheet(context, notice.actionId)
                  : null,
              style: TextButton.styleFrom(
                foregroundColor: BuddyColors.green,
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.balance_outlined, size: 14),
              label: const Text('Appeal this decision',
                  style: TextStyle(fontSize: 12)),
            ),
          ),
          if (!notice.isAppealable)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'This action cannot be appealed from the app. Contact support '
                'and quote the date above.',
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }

  Widget _appealCard(ModerationAppeal appeal) {
    final cs = Theme.of(context).colorScheme;
    final open = appeal.isOpen;
    final tint = switch (appeal.status) {
      'approved' => BuddyColors.green,
      'denied' => BuddyColors.red,
      'under_review' => BuddyColors.gold,
      _ => BuddyColors.gold,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Appeal · ${appeal.status.replaceAll('_', ' ')}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  appeal.status.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold, color: tint),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('You said: ${appeal.reason}',
              style: TextStyle(fontSize: 12, color: cs.onSurface, height: 1.4)),
          if (appeal.resolutionNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: BuddyColors.surfaceRaised,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Moderator replied',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(appeal.resolutionNote,
                      style: TextStyle(fontSize: 12, color: cs.onSurface)),
                ],
              ),
            ),
          ],
          if (appeal.reviewedAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Reviewed ${_shortDateTime(appeal.reviewedAt)}',
                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
            ),
          if (open)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Under review. You can only file one appeal per action, so this '
                'one has to be decided before another can be raised.',
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }

  Widget _commendationCard(ModerationCommendation commendation) {
    final cs = Theme.of(context).colorScheme;
    final title = commendation.categoryDisplay.isNotEmpty
        ? commendation.categoryDisplay
        : commendation.category.replaceAll('_', ' ');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium_outlined,
                  size: 18, color: BuddyColors.green),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Remove from my profile',
                onPressed: () => _deleteCommendation(commendation),
                icon: const Icon(Icons.delete_outline, size: 18),
                color: BuddyColors.textSecondary,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(commendation.message,
              style: TextStyle(fontSize: 13, color: cs.onSurface, height: 1.4)),
          const SizedBox(height: 6),
          Text(_shortDateTime(commendation.createdAt),
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }

  Future<void> _openAppealSheet(BuildContext context, String actionId) async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetCtx) => _AppealSheet(actionId: actionId),
    );
    if (reason == null || reason.trim().isEmpty) return;

    setState(() {
      _error = null;
      _notice = null;
    });
    try {
      await ref.read(settingsAdminRepoProvider).createModerationAppeal({
        'action': actionId,
        'reason': reason.trim(),
      });
      if (!mounted) return;
      setState(() => _notice =
          'Appeal submitted. A moderator other than the one who issued the '
          'decision will review it.');
      ref.invalidate(myAppealsProvider);
    } catch (e) {
      if (mounted) {
        setState(() => _error = apiErrorMessage(
              e,
              fallback: 'Could not submit the appeal.',
            ));
      }
    }
  }

  Future<void> _deleteCommendation(ModerationCommendation commendation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Remove this commendation?'),
        content: const Text(
          'It disappears from your profile. This only removes it for you — the '
          'staff record of issuing it is unaffected.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Keep', style: TextStyle(fontSize: 12)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: TextButton.styleFrom(foregroundColor: BuddyColors.red),
            child: const Text('Remove', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _error = null;
      _notice = null;
    });
    try {
      await ref
          .read(settingsAdminRepoProvider)
          .deleteModerationCommendation(commendation.id!);
      if (!mounted) return;
      setState(() => _notice = 'Commendation removed from your profile.');
      ref.invalidate(myCommendationsProvider);
    } catch (e) {
      if (mounted) {
        setState(() => _error = apiErrorMessage(
              e,
              fallback: 'Could not remove the commendation.',
            ));
      }
    }
  }

  static IconData _iconFor(ModerationNoticeKind kind) => switch (kind) {
        ModerationNoticeKind.warning => Icons.report_problem_outlined,
        ModerationNoticeKind.contentRemoved => Icons.delete_outline,
        ModerationNoticeKind.suspension => Icons.pause_circle_outline,
        ModerationNoticeKind.ban => Icons.block,
      };

  static String _shortDateTime(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    return iso.replaceFirst('T', ' ').split('.').first.split('+').first;
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String blurb;

  const _SectionHeading({required this.title, required this.blurb});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface)),
        const SizedBox(height: 2),
        Text(blurb, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String hint;

  const _EmptyCard({required this.icon, required this.title, required this.hint});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 26, color: BuddyColors.green.withValues(alpha: 0.5)),
          const SizedBox(height: 10),
          Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: cs.onSurface)),
          const SizedBox(height: 4),
          Text(hint,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: BuddyColors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BuddyColors.red.withValues(alpha: 0.25)),
      ),
      child: Text(message,
          style: const TextStyle(fontSize: 12, color: BuddyColors.red, height: 1.4)),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final String message;

  const _NoticeCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: BuddyColors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BuddyColors.green.withValues(alpha: 0.25)),
      ),
      child: Text(message,
          style: const TextStyle(fontSize: 12, color: BuddyColors.green, height: 1.4)),
    );
  }
}

/// The appeal form.
///
/// The server allows exactly one appeal per (action, appellant) — a database
/// constraint, not a validation rule — so the form says so on the button
/// rather than letting the user discover it from a server error after writing
/// out their explanation.
class _AppealSheet extends StatefulWidget {
  final String actionId;

  const _AppealSheet({required this.actionId});

  @override
  State<_AppealSheet> createState() => _AppealSheetState();
}

class _AppealSheetState extends State<_AppealSheet> {
  final TextEditingController _controller = TextEditingController();

  /// Matches `ModerationAppeal.reason`, which the server bounds at 1500.
  static const int minReason = 20;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _ready => _controller.text.trim().length >= minReason;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Appeal this decision',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: cs.onSurface)),
          const SizedBox(height: 4),
          Text(
            'Action ${widget.actionId.substring(0, widget.actionId.length > 8 ? 8 : widget.actionId.length)}. '
            'Write what the moderator should reconsider — the appeal is judged '
            'on this text.',
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            maxLines: 5,
            minLines: 3,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Why this decision is wrong, and what the moderator '
                  'should look at again.',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: !_ready ? null : () => Navigator.pop(context, _controller.text),
              style: FilledButton.styleFrom(
                backgroundColor: BuddyColors.green,
                foregroundColor: BuddyColors.black,
              ),
              icon: const Icon(Icons.send, size: 16),
              label: const Text('Submit appeal', style: TextStyle(fontSize: 13)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _ready
                ? 'One appeal per decision. If it is declined this cannot be '
                    'resubmitted.'
                : 'Write at least $minReason characters — a short appeal has '
                    'nothing for a reviewer to work with.',
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}