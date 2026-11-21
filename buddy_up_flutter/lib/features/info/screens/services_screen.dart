import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/button.dart';
import '../widgets/info_blocks.dart';

class _Service {
  final IconData icon;
  final String title;
  final String story;
  final List<String> points;
  final String cta;
  final String route;

  const _Service(
    this.icon,
    this.title,
    this.story,
    this.points,
    this.cta,
    this.route,
  );
}

const _services = <_Service>[
  _Service(
    LucideIcons.radio,
    'Live Workouts',
    'Fitness is better together in real time. Drop into a live HIIT class, flow through sunrise yoga, or let a Random Drop surprise you — led by real trainers, surrounded by real buddies.',
    [
      'Open Sweat — public, free sessions',
      'Buddy Circle — private group lives',
      'Random Drop — surprise match workouts',
      'Gym scheduled lives with RSVP',
    ],
    'Browse live sessions',
    '/lives',
  ),
  _Service(
    LucideIcons.dumbbell,
    'Gyms',
    'Your fitness family needs a home. Discover nearby physical gyms, train from your living room with virtual gyms, or join hybrid communities doing both — all with verified badges and member reviews.',
    [
      'Nearby, virtual & hybrid discovery',
      'Public, private, or secret gyms',
      'Trainer & moderator roles',
      'Gym wallet with revenue splits',
    ],
    'Discover gyms',
    '/gyms',
  ),
  _Service(
    LucideIcons.graduationCap,
    'Trainers & Practitioners',
    'General advice is free everywhere; accountability from a verified professional is rare. Find certified trainers and licensed health practitioners — mobile, near you, virtual, or affiliated with your gym.',
    [
      'Verified badges & reviews',
      'Session booking & escrow',
      'Async training programmes',
      'Availability calendar',
    ],
    'Find your trainer',
    '/trainers',
  ),
  _Service(
    LucideIcons.usersRound,
    'Communities & Messaging',
    'Motivation fades; people who notice don’t. Join communities around your goals and keep the conversation going in group chats — the buddy system, with receipts.',
    [
      'Goal-based communities',
      'Group messages & buddy circles',
      'Accountability pings',
      'Streaks your circle can see',
    ],
    'Meet your community',
    '/communities',
  ),
  _Service(
    LucideIcons.calendarDays,
    'Events',
    'Train for something. Sunrise runs, hybrid competitions, workshops, and social meetups — in person, virtual, or both, with tickets and QR check-in built in.',
    [
      'In-person, virtual & hybrid formats',
      'Tickets with QR check-in',
      'Gym & trainer-hosted',
      'Free and paid entry',
    ],
    'Explore events',
    '/marketplace/events',
  ),
  _Service(
    LucideIcons.utensils,
    'Marketplace',
    'Fuel the work. Meal plans from verified nutritionists, training programmes from certified coaches, and gear from trusted sellers — one wallet, zero guesswork.',
    [
      'Verified sellers only',
      'Meal plans & programmes',
      'Supplements, gear & apparel',
      'Reviews on everything',
    ],
    'Shop the marketplace',
    '/marketplace',
  ),
  _Service(
    LucideIcons.bookOpen,
    'Training Programmes',
    'Random workouts give random results. Follow structured multi-week programmes from verified trainers — strength blocks, run plans, conditioning — with progress tracking built in.',
    [
      'Multi-week structured plans',
      'Verified trainer authors',
      'Enrolment & progress tracking',
      'Bundle with 1:1 sessions',
    ],
    'Browse programmes',
    '/marketplace',
  ),
  _Service(
    LucideIcons.activity,
    'Activity Analytics',
    'What gets measured gets kept. GPS-track every run, walk, hike, and ride, log strength and yoga sessions, and watch streaks, distances, and progress reports compound.',
    [
      'GPS tracking for runs, walks, hikes & rides',
      'Strength, cardio, HIIT & yoga logs',
      'Streaks that keep you honest',
      'Shareable progress reports',
    ],
    'See your stats',
    '/analytics',
  ),
];

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoScaffold(
      title: 'Everything your fitness life needs, in one place.',
      subtitle:
          'Buddies, gyms, trainers, events, and the numbers that prove you’re improving — eight services, one fitness family.',
      footer: InfoCard(
        child: Column(
          children: [
            const Text(
              'Ready to move?',
              style: TextStyle(
                color: BuddyColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Find a buddy near you and start your first session today.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: BuddyColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            BuddyButton(
              label: 'Find your buddy',
              fullWidth: true,
              onPressed: () => context.push('/buddies/nearby'),
            ),
          ],
        ),
      ),
      children: [
        for (var i = 0; i < _services.length; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          _ServiceCard(service: _services[i]),
        ],
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final _Service service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoGlyph(service.icon),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  service.title,
                  style: const TextStyle(
                    color: BuddyColors.textPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            service.story,
            style: const TextStyle(
              color: BuddyColors.textSecondary,
              fontSize: 13,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 12),
          for (final point in service.points) InfoBullet(point),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => context.push(service.route),
            style: OutlinedButton.styleFrom(
              foregroundColor: BuddyColors.green,
              side: BorderSide(color: BuddyColors.green.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(service.cta, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 6),
                const Icon(LucideIcons.arrowRight, size: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
