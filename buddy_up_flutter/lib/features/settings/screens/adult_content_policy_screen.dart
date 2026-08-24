import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/legal_page.dart';

class AdultContentPolicyScreen extends StatelessWidget {
  const AdultContentPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const p = TextStyle(color: BuddyColors.textSecondary, fontSize: 13, height: 1.5);
    return const LegalPage(
      title: 'Adult Content Policy',
      updatedAt: 'August 2026',
      sections: [
        LegalSection(title: 'Retired Policy', children: [
          Text(
            'The Adult Content Policy (Mature Category) is no longer active. All content standards are now governed by the Community Guidelines.',
            style: p,
          ),
        ]),
      ],
    );
  }
}
