import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/messaging.dart';
import '../../../core/theme/app_theme.dart';

class LinkPreviewCard extends StatelessWidget {
  final LinkPreviewData preview;

  const LinkPreviewCard({super.key, required this.preview});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: BuddyColors.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: BuddyColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (preview.image.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: preview.image,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => Container(height: 120, color: BuddyColors.surface),
              ),
            ),
          const SizedBox(height: 6),
          if (preview.title.isNotEmpty)
            Text(preview.title, style: const TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
          if (preview.description.isNotEmpty)
            Text(preview.description, style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
          if (preview.domain.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(preview.domain, style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 10)),
            ),
        ],
      ),
    );
  }
}
