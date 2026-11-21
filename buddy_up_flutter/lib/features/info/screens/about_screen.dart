import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/button.dart';
import '../widgets/info_blocks.dart';

const _values = <(IconData, String, String)>[
  (
    LucideIcons.handshake,
    'Accountability is social',
    'Consistency is easier with someone in your corner. Every feature we build starts from real human connection, not engagement tricks.',
  ),
  (
    LucideIcons.heart,
    'Free where it matters',
    'Finding a buddy, joining a gym, and training together are free — permanently. We monetise extras, never the basics.',
  ),
  (
    LucideIcons.shieldCheck,
    'Verified, not anonymous',
    'Trainers and practitioners are credential-verified before they can sell. Health claims without a licence are not tolerated.',
  ),
  (
    LucideIcons.globe,
    'Built where it’s used',
    'We launch from Nairobi for African fitness communities first — M-Pesa, low-data mode, local language — then take it to the world.',
  ),
  (
    LucideIcons.trendingUp,
    'Outcomes over optics',
    'We measure success in streaks kept and habits built, not in follower counts or crash-diet transformations.',
  ),
  (
    LucideIcons.radio,
    'Live by default',
    'Workouts are better together in real time. Live sessions, Random Drops, and Buddy Circles are the heartbeat of the app.',
  ),
];

const _milestones = <(String, String)>[
  (
    'The idea',
    'Two friends kept failing at 5am runs alone — and never missed one together. BuddyUp Fit started as the answer to "why isn’t there an app for this?"',
  ),
  (
    'Private beta',
    'A closed group of test users trained, posted, and broke things — shaping everything from Random Drops to the age-verification flow.',
  ),
  (
    'Launching November',
    'Public launch across Kenya: gyms, verified trainers, live sessions, and the buddy system — free at the core.',
  ),
  (
    'What’s next',
    'Offline-lite mode, SMS & WhatsApp nudges, corporate wellness packages, group & family plans, multilingual support, wearables.',
  ),
];

const _services = <(IconData, String, String)>[
  (
    LucideIcons.radio,
    'Live Workouts',
    'Drop into live sessions or host your own.',
  ),
  (LucideIcons.dumbbell, 'Gyms', 'Nearby, virtual, and hybrid communities.'),
  (
    LucideIcons.graduationCap,
    'Trainers & Practitioners',
    'Verified pros, mobile or online.',
  ),
  (
    LucideIcons.messageCircle,
    'Communities & Messaging',
    'Group chats that keep you accountable.',
  ),
  (LucideIcons.calendarDays, 'Events', 'Runs, games, and workshops near you.'),
  (LucideIcons.utensils, 'Marketplace', 'Meal plans, programmes, and gear.'),
  (LucideIcons.bookOpen, 'Training Programmes', 'Structured multi-week plans.'),
  (
    LucideIcons.activity,
    'Activity Analytics',
    'Every run, walk, and lift — tracked.',
  ),
];

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _mail(String address) async {
    await launchUrl(
      Uri.parse('mailto:$address'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InfoScaffold(
      title: 'Built for the buddy system.',
      leadingIcon: LucideIcons.handshake,
      subtitle:
          'BuddyUp Fit exists to make consistency social — because showing up is easier when someone is waiting for you.',
      children: [
        InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Our mission',
                style: TextStyle(
                  color: BuddyColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'We believe fitness is a team sport. BuddyUp Fit connects people who want to move with people who will show up — then gives them the gyms, trainers, live sessions and tools to keep going.',
                style: TextStyle(
                  color: BuddyColors.textSecondary,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: BuddyButton(
                      label: 'Explore services',
                      variant: BuddyButtonVariant.outline,
                      onPressed: () => context.push('/services'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: BuddyButton(
                      label: 'Get in touch',
                      onPressed: () => context.push('/contact'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const InfoSectionTitle('What we stand for'),
        for (final value in _values)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InfoCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoGlyph(value.$1),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value.$2,
                          style: const TextStyle(
                            color: BuddyColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          value.$3,
                          style: const TextStyle(
                            color: BuddyColors.textSecondary,
                            fontSize: 12.5,
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        const InfoSectionTitle('The story so far'),
        for (final milestone in _milestones)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    milestone.$1,
                    style: const TextStyle(
                      color: BuddyColors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    milestone.$2,
                    style: const TextStyle(
                      color: BuddyColors.textSecondary,
                      fontSize: 13,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        const InfoSectionTitle('What you can do here'),
        for (final service in _services)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(service.$1, size: 16, color: BuddyColors.green),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: BuddyColors.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: '${service.$2} — ',
                          style: const TextStyle(
                            color: BuddyColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: service.$3),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Talk to us',
                style: TextStyle(
                  color: BuddyColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'General enquiries: info@buddyup.com',
                style: TextStyle(
                  color: BuddyColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                children: [
                  InfoLink(
                    'info@buddyup.com',
                    icon: LucideIcons.mail,
                    onTap: () => _mail('info@buddyup.com'),
                  ),
                  InfoLink('Careers', onTap: () => context.push('/careers')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
