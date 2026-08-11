import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Shared scaffold for Buddy-Up legal / policy pages, mirroring the web
/// LegalPage shell so Terms, Privacy, Guidelines, Cookie, Medical Disclaimer,
/// Sponsorship and Adult Content pages render as a coherent set.
class LegalPage extends StatelessWidget {
  final String title;
  final String updatedAt;
  final List<LegalSection> sections;

  const LegalPage({
    super.key,
    required this.title,
    this.updatedAt = 'August 2026',
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
              style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 20),
            ...sections.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: s,
                )),
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
