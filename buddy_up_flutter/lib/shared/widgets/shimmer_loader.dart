import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';

class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const ShimmerList({super.key, this.itemCount = 5, this.itemHeight = 100});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: BuddyColors.surfaceRaised,
      highlightColor: BuddyColors.surface,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (_, _) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: itemHeight,
          decoration: BoxDecoration(
            color: BuddyColors.surfaceRaised,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class ShimmerDetail extends StatelessWidget {
  const ShimmerDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: BuddyColors.surfaceRaised,
      highlightColor: BuddyColors.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, backgroundColor: BuddyColors.surfaceRaised),
            const SizedBox(height: 16),
            _box(width: 200, height: 20),
            const SizedBox(height: 8),
            _box(width: 140, height: 14),
            const SizedBox(height: 24),
            _box(height: 16),
            const SizedBox(height: 8),
            _box(height: 60),
            const SizedBox(height: 16),
            _box(height: 16),
            const SizedBox(height: 16),
            _box(height: 48),
            const SizedBox(height: 24),
            _box(width: 100, height: 16),
            const SizedBox(height: 12),
            _box(height: 80),
            const SizedBox(height: 8),
            _box(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _box({double? width, required double height}) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: BuddyColors.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class ShimmerForm extends StatelessWidget {
  const ShimmerForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: BuddyColors.surfaceRaised,
      highlightColor: BuddyColors.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _box(width: 120, height: 16),
            const SizedBox(height: 12),
            _box(height: 48),
            const SizedBox(height: 12),
            _box(height: 48),
            const SizedBox(height: 12),
            _box(height: 48),
            const SizedBox(height: 12),
            _box(height: 48),
            const SizedBox(height: 24),
            _box(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _box({double? width, required double height}) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: BuddyColors.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
