import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/session_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/shimmer_loader.dart';

class TrainerProfileScreen extends ConsumerWidget {
  final String username;
  const TrainerProfileScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainerAsync = ref.watch(trainerProvider(username));
    final reviewsAsync = ref.watch(trainerReviewsProvider(username));
    return Scaffold(
      appBar: AppBar(title: const Text('Trainer Profile')),
      body: trainerAsync.when(
        data: (trainer) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Avatar(src: trainer.avatarUrl, alt: trainer.displayName, size: AvatarSize.xl),
                    const SizedBox(height: 12),
                    Text(trainer.displayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    if (trainer.location.isNotEmpty)
                      Text(trainer.location, style: const TextStyle(color: BuddyColors.textSecondary)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text('${trainer.averageRating.toStringAsFixed(1)} (${trainer.reviewCount} reviews)'),
                        const SizedBox(width: 16),
                        const Icon(Icons.fitness_center, size: 18, color: BuddyColors.textSecondary),
                        const SizedBox(width: 4),
                        Text('${trainer.sessionCount} sessions'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (trainer.bio.isNotEmpty) ...[
                const Text('About', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(trainer.bio, style: const TextStyle(height: 1.5)),
                const SizedBox(height: 16),
              ],
              if (trainer.specialties.isNotEmpty) ...[
                const Text('Specialties', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 4, children: trainer.specialties.map((s) =>
                  Chip(label: Text(s), backgroundColor: BuddyColors.surfaceRaised, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
                ).toList()),
                const SizedBox(height: 16),
              ],
              if (trainer.certifications.isNotEmpty) ...[
                const Text('Certifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...trainer.certifications.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    const Icon(Icons.verified, size: 16, color: BuddyColors.green),
                    const SizedBox(width: 8),
                    Text(c),
                  ]),
                )),
                const SizedBox(height: 16),
              ],
              Row(children: [
                const Text('Experience: ', style: TextStyle(color: BuddyColors.textSecondary)),
                Text('${trainer.experienceYears} years'),
                const Spacer(),
                if (trainer.hourlyRate > 0)
                  Text('\$${trainer.hourlyRate.toStringAsFixed(0)}/hr', style: const TextStyle(color: BuddyColors.green, fontSize: 18, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 24),
              BuddyButton(
                label: 'Book Session',
                fullWidth: true,
                icon: Icons.calendar_today,
                onPressed: () => context.push('/book/${trainer.username}'),
              ),
              const SizedBox(height: 32),
              const Text('Reviews', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              reviewsAsync.when(
                data: (reviews) {
                  if (reviews.isEmpty) return const Text('No reviews yet', style: TextStyle(color: BuddyColors.textSecondary));
                  return Column(
                    children: reviews.map((r) => Card(
                      color: BuddyColors.surface,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(r.reviewerUsername[0].toUpperCase())),
                        title: Row(children: [
                          Text(r.reviewerUsername),
                          const SizedBox(width: 8),
                          ...List.generate(5, (i) => Icon(i < r.rating ? Icons.star : Icons.star_border, size: 14, color: Colors.amber)),
                        ]),
                        subtitle: r.comment != null ? Text(r.comment!) : null,
                        trailing: Text(_formatDate(r.createdAt), style: const TextStyle(fontSize: 11, color: BuddyColors.textSecondary)),
                      ),
                    )).toList(),
                  );
                },
                loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator())),
                error: (e, _) => Text('$e'),
              ),
            ],
          ),
        ),
        loading: () => const ShimmerDetail(),
        error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(trainerProvider(username))),
      ),
    );
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}
