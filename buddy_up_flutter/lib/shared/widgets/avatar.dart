import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';

enum AvatarSize { xs, sm, md, lg, xl }

class Avatar extends StatelessWidget {
  final String? src;
  final String alt;
  final AvatarSize size;
  final String? verificationStatus;

  const Avatar({
    super.key,
    this.src,
    required this.alt,
    this.size = AvatarSize.md,
    this.verificationStatus,
  });

  double get _dimension {
    switch (size) {
      case AvatarSize.xs:
        return 24;
      case AvatarSize.sm:
        return 32;
      case AvatarSize.md:
        return 40;
      case AvatarSize.lg:
        return 56;
      case AvatarSize.xl:
        return 80;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _dimension,
      height: _dimension,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(_dimension / 2),
            child: src != null && src!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: src!,
                    fit: BoxFit.cover,
                    width: _dimension,
                    height: _dimension,
                    placeholder: (_, _) => _placeholder(),
                    errorWidget: (_, _, _) => _placeholder(),
                  )
                : _placeholder(),
          ),
          if (verificationStatus != null &&
              verificationStatus != 'none' &&
              verificationStatus!.isNotEmpty &&
              size != AvatarSize.xs)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: _dimension * 0.35,
                height: _dimension * 0.35,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: BuddyColors.green,
                ),
                child: Icon(
                  Icons.verified,
                  size: _dimension * 0.22,
                  color: BuddyColors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: BuddyColors.surfaceRaised,
      child: Center(
        child: Text(
          alt.isNotEmpty ? alt[0].toUpperCase() : '?',
          style: TextStyle(
            color: BuddyColors.textSecondary,
            fontSize: _dimension * 0.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
