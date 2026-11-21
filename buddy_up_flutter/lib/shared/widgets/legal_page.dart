import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Shared scaffold for Buddy-Up legal / policy pages, mirroring the web
/// LegalPage shell so Terms, Privacy, Guidelines, Cookie, Medical Disclaimer,
/// Sponsorship and Adult Content pages render as a coherent set.
class LegalPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String updatedAt;
  final List<LegalSection> sections;

  const LegalPage({
    super.key,
    required this.title,
    this.subtitle,
    required this.updatedAt,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Last updated $updatedAt',
              style: const TextStyle(
                color: BuddyColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            ...sections.map(
              (s) =>
                  Padding(padding: const EdgeInsets.only(bottom: 24), child: s),
            ),
          ],
        ),
      ),
    );
  }
}

class LegalSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const LegalSection({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: BuddyColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}

/// Body copy for legal pages. Pass plain text or rich `TextSpan`s (bold runs).
class LegalText extends StatelessWidget {
  final TextSpan textSpan;
  final TextStyle? style;

  const LegalText(this.textSpan, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return Text.rich(textSpan, style: style, textAlign: TextAlign.justify);
  }
}

/// Section-level subheading inside a legal section (the web `<h3>` style).
class LegalSubheading extends StatelessWidget {
  final String text;

  const LegalSubheading(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: BuddyColors.textPrimary,
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class LegalBullet extends StatelessWidget {
  final String text;
  final int? number;

  const LegalBullet(this.text, {super.key, this.number});

  @override
  Widget build(BuildContext context) {
    final bullet = Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: BuddyColors.green,
        shape: BoxShape.circle,
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 14,
            child: Center(
              child: number == null
                  ? bullet
                  : Text(
                      '$number.',
                      style: const TextStyle(
                        color: BuddyColors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: BuddyColors.textSecondary,
                fontSize: 13,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LegalBulletList extends StatelessWidget {
  final List<String> items;

  const LegalBulletList(this.items, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items) ...[
          LegalBullet(item),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class LegalNotice extends StatelessWidget {
  final String text;
  final LegalNoticeTone tone;

  const LegalNotice({
    super.key,
    required this.text,
    this.tone = LegalNoticeTone.orange,
  });

  static const Map<LegalNoticeTone, Color> _toneColors = {
    LegalNoticeTone.orange: BuddyColors.orange,
    LegalNoticeTone.red: BuddyColors.red,
    LegalNoticeTone.green: BuddyColors.green,
  };

  Color get _toneColor => _toneColors[tone]!;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _toneColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _toneColor.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: TextStyle(color: _toneColor, fontSize: 12, height: 1.5),
      ),
    );
  }
}

enum LegalNoticeTone { orange, red, green }
