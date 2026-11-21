import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';

class _SupportLink {
  final IconData icon;
  final String title;
  final String body;
  final String url;
  final bool wide;

  const _SupportLink({
    required this.icon,
    required this.title,
    required this.body,
    required this.url,
    this.wide = false,
  });
}

String _envUrl(String key) => (dotenv.env[key] ?? '').trim();

List<_SupportLink> _supportLinks() => [
  _SupportLink(
    icon: LucideIcons.heart,
    title: 'Donate',
    body: 'Chip in to our fundraiser and keep BuddyUp Fit free for everyone.',
    url: _envUrl('FUNDRAISER_URL'),
  ),
  _SupportLink(
    icon: LucideIcons.clipboardList,
    title: 'Pledge Funding',
    body: "Pledge funding and we'll be in touch about next steps.",
    url: _envUrl('PLEDGE_FORM_URL'),
  ),
  _SupportLink(
    icon: LucideIcons.briefcase,
    title: 'Partnership Proposal for Brands',
    body:
        "Sponsor challenges, events, and gym spaces — put your brand in front of Kenya's fitness family.",
    url: _envUrl('PARTNERSHIP_FORM_URL'),
    wide: true,
  ),
  _SupportLink(
    icon: LucideIcons.trendingUp,
    title: 'Investor Relations',
    body:
        "Backing BuddyUp Fit? Tell us about yourself and we'll set up a conversation.",
    url: _envUrl('INVESTOR_FORM_URL'),
    wide: true,
  ),
];

/// Web-parity Support dialog (`SupportDialog.tsx`): Donate, pledge funding,
/// brand partnership and investor links. Unconfigured links stay visible but
/// disabled, exactly like the web build.
Future<void> showSupportDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.75),
    builder: (context) => const _SupportDialog(),
  );
}

class _SupportDialog extends StatelessWidget {
  const _SupportDialog();

  Future<void> _open(BuildContext context, String url) async {
    if (url.isEmpty) return;
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open that link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final links = _supportLinks();
    return Dialog(
      backgroundColor: BuddyColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: BuddyColors.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Support BuddyUp Fit',
                      style: TextStyle(
                        color: BuddyColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      LucideIcons.x,
                      color: BuddyColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Text(
                'Help us keep building your fitness family. Donate to our fundraiser, pledge funding, or partner your brand with us to power what’s next.',
                style: TextStyle(
                  color: BuddyColors.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final twoCol = constraints.maxWidth >= 460;
                  final cards = [
                    for (final link in links)
                      _SupportCard(
                        link: link,
                        onTap: link.url.isEmpty
                            ? null
                            : () => _open(context, link.url),
                        fullWidth: !twoCol || link.wide,
                      ),
                  ];
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: cards
                        .map(
                          (card) => SizedBox(
                            width: card.fullWidth || !twoCol
                                ? constraints.maxWidth
                                : (constraints.maxWidth - 12) / 2,
                            child: card,
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final _SupportLink link;
  final VoidCallback? onTap;
  final bool fullWidth;

  const _SupportCard({
    required this.link,
    required this.onTap,
    required this.fullWidth,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Opacity(
      opacity: disabled ? 0.6 : 1,
      child: Material(
        color: BuddyColors.surfaceRaised,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(link.icon, size: 26, color: BuddyColors.green),
                const SizedBox(height: 10),
                Text(
                  link.title,
                  style: const TextStyle(
                    color: BuddyColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  disabled
                      ? 'Coming soon — the link is not configured in this build.'
                      : link.body,
                  style: const TextStyle(
                    color: BuddyColors.textSecondary,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
