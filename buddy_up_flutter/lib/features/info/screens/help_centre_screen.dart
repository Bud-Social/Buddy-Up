import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../widgets/info_blocks.dart';

const _faq = <(String, String)>[
  (
    'How do I report a post or profile?',
    'Use the Report button on any post, comment, or profile. Reports are reviewed within 24 hours; severe categories (imminent harm, CSAM) are escalated immediately.',
  ),
  (
    'Why was my post flagged or removed?',
    'Posts are automatically screened for prohibited content including medical claims, undisclosed sponsorships, and safety violations. Every automatic flag is reviewed by a human moderator before action. You can appeal within 14 days.',
  ),
  (
    'What counts as a medical claim on BuddyUp Fit?',
    'Any content claiming a meal plan or programme "treats", "cures", or "manages" a medical condition. Sharing your own experience is fine; giving professional advice outside a verified practitioner relationship is not. See the Medical Disclaimer.',
  ),
  (
    'Do I have to disclose gifted products?',
    'Yes. If you received anything of value in exchange for content, disclose it clearly at the start of your post (#ad, Sponsored, Paid partnership). Hidden disclosures are treated as non-disclosure. See the Sponsorship Policy.',
  ),
  (
    'How does verification work?',
    'Go to Settings → Verification. You can verify your identity, or apply for Trainer, Practitioner, Shop, or Gym verification. Practitioners must provide credential details including issuer and scope of practice.',
  ),
  (
    'How do I export or delete my data?',
    'Go to Settings → Your Data. You can export a full JSON archive of your data or request account deletion. Deletion takes effect after a 30-day grace period during which you can recover the account.',
  ),
  (
    'I am 16 or 17. How do I use BuddyUp Fit?',
    'Users aged 16–17 must be co-owned by a verified parent or guardian. You will be asked to provide their name and contact details during registration.',
  ),
  (
    'How do I get in touch with support?',
    'Email support@buddyup.com for account help, report@buddyup.co.ke for safety or content concerns, and privacy@buddyup.com for data protection requests.',
  ),
];

const _legalLinks = <(String, String)>[
  ('Terms of Service', '/terms'),
  ('Privacy Policy', '/privacy'),
  ('Community Guidelines', '/community-guidelines'),
  ('Cookie Policy', '/cookie-policy'),
  ('Medical & Wellness Disclaimer', '/medical-disclaimer'),
  ('Sponsorship & Disclosure Policy', '/sponsorship-policy'),
];

class HelpCentreScreen extends StatelessWidget {
  const HelpCentreScreen({super.key});

  Future<void> _mail(String address) async {
    await launchUrl(
      Uri.parse('mailto:$address'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InfoScaffold(
      title: 'Help Centre',
      leadingIcon: LucideIcons.helpCircle,
      subtitle:
          'Answers to common questions, plus how to reach our support, safety, and data protection teams.',
      footer: const Text(
        'BuddyUp Fit is a fitness and wellness platform, not a medical service. If you are experiencing a medical emergency, contact your local emergency services immediately.',
        style: TextStyle(color: BuddyColors.gold, fontSize: 11, height: 1.5),
      ),
      children: [
        const InfoSectionTitle('Frequently asked questions'),
        for (final item in _faq)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InfoCard(
              padding: EdgeInsets.zero,
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  splashColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  iconColor: BuddyColors.green,
                  collapsedIconColor: BuddyColors.textSecondary,
                  title: Text(
                    item.$1,
                    style: const TextStyle(
                      color: BuddyColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        item.$2,
                        style: const TextStyle(
                          color: BuddyColors.textSecondary,
                          fontSize: 13,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        const InfoSectionTitle('How to report'),
        InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'You can report content in three ways:',
                style: TextStyle(
                  color: BuddyColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),
              const InfoBullet(
                'In-app: the Report button on any post, comment, profile, or live session',
              ),
              const InfoBullet(
                'By email: report@buddyup.co.ke for content or safety concerns',
              ),
              const InfoBullet('For data matters: privacy@buddyup.com'),
              const SizedBox(height: 6),
              const Text(
                'Emergency or imminent-harm situations are escalated immediately. You can report anonymously and our team will keep your identity private where possible.',
                style: TextStyle(
                  color: BuddyColors.textSecondary,
                  fontSize: 12,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _EmailChip(
                    label: 'Email support',
                    address: 'support@buddyup.com',
                    onTap: () => _mail('support@buddyup.com'),
                  ),
                  _EmailChip(
                    label: 'Report content',
                    address: 'report@buddyup.co.ke',
                    onTap: () => _mail('report@buddyup.co.ke'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const InfoSectionTitle('Legal documents'),
        InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final link in _legalLinks)
                InfoLink(
                  link.$1,
                  onTap: () => context.push(link.$2),
                  icon: LucideIcons.chevronRight,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmailChip extends StatelessWidget {
  final String label;
  final String address;
  final VoidCallback onTap;

  const _EmailChip({
    required this.label,
    required this.address,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: BuddyColors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: BuddyColors.green.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.mail, size: 14, color: BuddyColors.green),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: BuddyColors.green,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
