import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/distance.dart';
import '../buddy_nearby_provider.dart';

/// Discovery card for one nearby buddy.
///
/// Rectangular by design (the grid gives it a 3:4 box): the photo, the facts
/// that decide whether you keep talking — age band, intents, goals, pace,
/// mode, availability, distance — and exactly two things to do about it,
/// message or like. Tapping the body opens the full Find-a-Buddy profile;
/// the two actions sit on their own bar so they never swallow a body tap.
class BuddyDiscoveryCard extends StatelessWidget {
  final NearbyBuddy buddy;

  /// A like request is in flight — the heart disables itself.
  final bool liking;

  final VoidCallback onOpenProfile;
  final VoidCallback onMessage;
  final VoidCallback onLike;

  const BuddyDiscoveryCard({
    super.key,
    required this.buddy,
    required this.onOpenProfile,
    required this.onMessage,
    required this.onLike,
    this.liking = false,
  });

  String get username => buddy.username;

  @override
  Widget build(BuildContext context) {
    final name = buddy.displayName.isNotEmpty ? buddy.displayName : 'Buddy';
    final distance = formatDistanceBadge(buddy.distanceKm);
    final intents = buddy.customIntent.isNotEmpty
        ? [buddy.customIntent]
        : buddy.intents.map(_humanise).toList();
    final modes = buddy.modes.map(_humanise).toList();
    final meta = _metaLine;

    return Card(
      margin: EdgeInsets.zero,
      color: BuddyColors.surface,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _photo(name, distance)),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: BuddyColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  buddy.ageBand.isNotEmpty ? buddy.ageBand : '@$username',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: BuddyColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                if (intents.isNotEmpty || modes.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (final label in [...intents, ...modes].take(3))
                        _Chip(label: label),
                    ],
                  ),
                ],
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    meta,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: BuddyColors.textSecondary,
                      fontSize: 10,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Photo banner with the availability/distance badges, the "Liked you"
  /// back-signal and the message/like bar.
  Widget _photo(String name, String? distance) {
    final avatar = buddy.photos.isNotEmpty
        ? buddy.photos.first
        : buddy.profile['avatar_url'] as String?;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Only the picture itself opens the profile, so the action controls
        // below never have to fight the body tap for the gesture arena.
        GestureDetector(
          onTap: onOpenProfile,
          child: _photoOrInitials(avatar, name),
        ),
        if (buddy.availableNow || (buddy.likedMe && !buddy.likedByMe))
          Positioned(
            top: 8,
            left: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (buddy.availableNow)
                  const _OverlayBadge(label: 'Available now', icon: Icons.bolt),
                if (buddy.likedMe && !buddy.likedByMe) ...[
                  const SizedBox(height: 4),
                  _LikedYouBadge(username: username),
                ],
              ],
            ),
          ),
        if (distance != null)
          Positioned(
            top: 8,
            right: 8,
            child: _OverlayBadge(label: distance, icon: Icons.near_me),
          ),
        Positioned(left: 0, right: 0, bottom: 0, child: _actionBar(name)),
      ],
    );
  }

  Widget _photoOrInitials(String? src, String name) {
    return src != null && src.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: src,
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(color: BuddyColors.surfaceRaised),
            errorWidget: (_, _, _) => _initials(name),
          )
        : _initials(name);
  }

  Widget _initials(String name) {
    return Container(
      color: BuddyColors.surfaceRaised,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: BuddyColors.textSecondary,
            fontSize: 26,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Message + like. Solid scrim (no gradient) so the controls stay legible
  /// over any photo, and so a tap here never reaches the body handler.
  Widget _actionBar(String name) {
    return Container(
      decoration: BoxDecoration(
        color: BuddyColors.black.withValues(alpha: 0.72),
        border: const Border(
          top: BorderSide(color: BuddyColors.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton.icon(
              key: ValueKey('buddy-card-message-$username'),
              onPressed: onMessage,
              icon: const Icon(Icons.message_outlined, size: 15, color: BuddyColors.green),
              label: const Text(
                'Message',
                style: TextStyle(color: BuddyColors.textPrimary, fontSize: 11),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 6),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          _LikeButton(
            key: ValueKey('buddy-card-like-$username'),
            liked: buddy.likedByMe,
            liking: liking,
            semanticLabel: name,
            onPressed: onLike,
          ),
        ],
      ),
    );
  }

  /// Goals and pace — the "would I actually enjoy training with them" line.
  String get _metaLine {
    final parts = <String>[
      if (buddy.goals.isNotEmpty) buddy.goals.map(_humanise).join(', '),
      if (buddy.pace.isNotEmpty) _humanise(buddy.pace),
    ];
    return parts.join(' · ');
  }

  static String _humanise(String raw) => raw.replaceAll('_', ' ');
}

class _LikeButton extends StatelessWidget {
  final bool liked;
  final bool liking;
  final String semanticLabel;
  final VoidCallback onPressed;

  const _LikeButton({
    super.key,
    required this.liked,
    required this.liking,
    required this.semanticLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final color = liked ? BuddyColors.green : BuddyColors.textSecondary;
    return Semantics(
      label: liked ? 'Unlike $semanticLabel' : 'Like $semanticLabel',
      button: true,
      child: IconButton(
        onPressed: liking ? null : onPressed,
        iconSize: 20,
        tooltip: liked ? 'Unlike' : 'Like',
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 32),
        icon: Icon(
          liked ? Icons.favorite : Icons.favorite_border,
          color: color,
        ),
      ),
    );
  }
}

/// The one-way back-signal: they liked you and you have not yet. Distinct from
/// the heart so a mutual-like never reads as "they are waiting on you".
class _LikedYouBadge extends StatelessWidget {
  final String username;

  const _LikedYouBadge({required this.username});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('buddy-card-liked-you-$username'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: BuddyColors.green,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'Liked you',
        style: TextStyle(
          color: BuddyColors.black,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Distance / availability pill overlaid on the photo.
class _OverlayBadge extends StatelessWidget {
  final String label;
  final IconData icon;

  const _OverlayBadge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: BuddyColors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: BuddyColors.green),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              color: BuddyColors.green,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: BuddyColors.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(color: BuddyColors.green, fontSize: 10),
      ),
    );
  }
}