import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AttachmentMenu extends StatelessWidget {
  final void Function(String type)? onSelect;

  const AttachmentMenu({super.key, this.onSelect});

  static const _items = [
    {'type': 'photo', 'icon': Icons.photo, 'label': 'Photo'},
    {'type': 'camera', 'icon': Icons.camera_alt, 'label': 'Camera'},
    {'type': 'video', 'icon': Icons.videocam, 'label': 'Video'},
    {'type': 'file', 'icon': Icons.insert_drive_file, 'label': 'File'},
    {'type': 'location', 'icon': Icons.location_on, 'label': 'Location'},
    {'type': 'poll', 'icon': Icons.poll, 'label': 'Poll'},
    {'type': 'event', 'icon': Icons.calendar_today, 'label': 'Event'},
    {'type': 'voice', 'icon': Icons.mic, 'label': 'Voice'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4,
            decoration: BoxDecoration(color: BuddyColors.textSecondary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _items.length,
            itemBuilder: (_, i) {
              final item = _items[i];
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  onSelect?.call(item['type'] as String);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: BuddyColors.surfaceRaised,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(item['icon'] as IconData, color: BuddyColors.green, size: 24),
                    ),
                    const SizedBox(height: 6),
                    Text(item['label'] as String,
                      style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
