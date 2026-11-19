import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/messaging.dart';

const String kSeenStoriesPrefKey = 'buddyup-seen-stories';

/// Loads the set of story ids this device has seen. Ids are small strings;
/// a corrupt or missing value degrades to "nothing seen", never a crash.
Future<Set<String>> loadSeenStories() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(kSeenStoriesPrefKey) ?? const <String>[]).toSet();
  } catch (_) {
    return {};
  }
}

Future<void> saveSeenStories(Set<String> ids) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(kSeenStoriesPrefKey, ids.toList());
  } catch (_) { /* storage is best effort */ }
}

/// Horizontal strip of story reels — buddies and people you follow, newest
/// first. A reel with any unseen story gets the green-gradient ring; tapping
/// opens the fullscreen viewer at that reel.
class StoryStrip extends StatelessWidget {
  final List<StoryReel> reels;
  final Set<String> seenIds;
  final void Function(int reelIndex) onOpen;
  final VoidCallback? onAddStory;

  const StoryStrip({
    super.key,
    required this.reels,
    required this.seenIds,
    required this.onOpen,
    this.onAddStory,
  });

  @override
  Widget build(BuildContext context) {
    if (reels.isEmpty && onAddStory == null) return const SizedBox.shrink();
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: (onAddStory != null ? 1 : 0) + reels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          if (onAddStory != null && i == 0) {
            return Semantics(
              label: 'Add your story',
              button: true,
              child: GestureDetector(
                onTap: onAddStory,
                child: SizedBox(
                  width: 64,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2.5),
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: BuddyColors.surface),
                            child: const SizedBox(width: 50, height: 50, child: Center(child: Icon(Icons.person, size: 26, color: BuddyColors.textSecondary))),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: BuddyColors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: BuddyColors.black, width: 2),
                              ),
                              child: const Icon(Icons.add, size: 14, color: BuddyColors.black),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('Your story',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: BuddyColors.textSecondary, fontSize: 10)),
                    ],
                  ),
                ),
              ),
            );
          }

          final reelIndex = onAddStory != null ? i - 1 : i;
          final reel = reels[reelIndex];
          final unread = reel.stories.any((s) => !seenIds.contains(s.id));
          return GestureDetector(
            onTap: () => onOpen(reelIndex),
            child: SizedBox(
              width: 64,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: unread
                          ? const LinearGradient(
                              colors: [BuddyColors.green, Color(0xFF34D399), Color(0xFFA3E635)],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                            )
                          : null,
                      color: unread ? null : BuddyColors.surface,
                    ),
                    child: Avatar(
                      src: reel.user.avatarUrl,
                      alt: reel.user.displayName,
                      size: AvatarSize.md,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reel.user.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 10),
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
