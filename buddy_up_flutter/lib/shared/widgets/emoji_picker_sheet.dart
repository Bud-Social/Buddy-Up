import 'package:flutter/material.dart';

/// Curated emoji picker matching the web's emoji-picker-react surfaces in the
/// post composer, comment box and chat. Keyless and offline — no new deps.
const List<String> composerEmojis = [
  '😀', '😂', '🥲', '😍', '🥳', '😎', '🤔', '😤',
  '💪', '🔥', '🏋️', '🤝', '👏', '❤️', '💯', '✨',
  '🎉', '✅', '🙌', '👍', '👀', '🚀', '⚡', '🎯',
  '🏃', '🚴', '🧘', '🥗', '💧', '😴', '💀', '😂',
];

Future<String?> showEmojiPickerSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add an emoji',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final emoji in composerEmojis)
                  InkWell(
                    onTap: () => Navigator.of(context).pop(emoji),
                    borderRadius: BorderRadius.circular(8),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
