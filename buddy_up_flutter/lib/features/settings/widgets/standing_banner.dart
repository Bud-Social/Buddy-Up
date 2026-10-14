import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/moderation_provider.dart';

/// The account-standing notice, shown across the whole app.
///
/// A suspension or ban that lives only on a Settings sub-page is one the user
/// finds out about by failing to post. This banner puts the three facts that
/// matter — what a moderator did, why, and when it ends — in front of anyone
/// who has an action still in force, and links straight to the appeal surface.
///
/// It does **not** post the appeal. `POST /moderation/appeals/` needs the
/// `ModerationAction` id and a written reason, and it refuses an action that was
/// not applied to this account; the form on `/settings/moderation` has all
/// three. The banner's job is to make sure that form is reachable in one tap
/// from wherever the user is standing when they read the notice.
///
/// Facts come from the user's own notification feed, because that is the only
/// member-readable surface that carries them — `GET /moderation/actions/` is
/// `IsAdminUser`. A failed or empty load renders **nothing**, never an alarming
/// empty banner: an account with nothing on it must not be told it is in
/// trouble because a request timed out.
///
/// A reversed action is history, not standing, and is filtered out — see
/// [buildStanding].
class StandingBanner extends ConsumerWidget {
  const StandingBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final standing = ref.watch(currentStandingProvider);

    return standing.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (notice) => notice == null ? const SizedBox.shrink() : _Banner(notice),
    );
  }
}

class _Banner extends StatelessWidget {
  final MyModerationNotice notice;

  const _Banner(this.notice);

  /// Gold, not red: this is a notice, not an error state. A red bar pinned
  /// above the feed reads as the app being broken rather than as a decision
  /// someone made about the account. The severity is already carried by the
  /// icon and the wording.
  static const Color _tint = BuddyColors.gold;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final appealTarget = notice.isAppealable
        ? '/settings/moderation?action=${notice.actionId}'
        : '/settings/moderation';

    return Material(
      color: cs.surface,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        decoration: BoxDecoration(
          color: _tint.withValues(alpha: 0.05),
          border: Border(
            bottom: BorderSide(color: _tint.withValues(alpha: 0.3)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.shield_outlined, size: 18, color: _tint),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notice.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  if (notice.reason.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        notice.reason,
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      notice.endDateLabel,
                      style:
                          TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: TextButton.icon(
                      onPressed: () => context.push(appealTarget),
                      style: TextButton.styleFrom(
                        foregroundColor: BuddyColors.green,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                      icon: const Icon(Icons.balance_outlined, size: 14),
                      label: Text(
                        notice.isAppealable
                            ? 'See it and appeal'
                            : 'See the full record and appeal options',
                        style: const TextStyle(fontSize: 12),
                      ),
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
