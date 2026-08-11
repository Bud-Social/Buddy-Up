import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/legal_page.dart';

class AdultContentPolicyScreen extends StatelessWidget {
  const AdultContentPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const p = TextStyle(color: BuddyColors.textSecondary, fontSize: 13, height: 1.5);
    return LegalPage(
      title: 'Adult Content Policy (Mature Category)',
      updatedAt: 'August 2026',
      sections: [
        LegalSection(title: '1. What Belongs in the Mature Category', children: [
          const Text(
            'The Mature category is a separate, hidden-by-default section of Buddy-Up for adult fitness content. It includes, without limitation:',
            style: p,
          ),
          const SizedBox(height: 8),
          const Text('• Nude or suggestive trainer and creator profiles', style: p),
          const Text('• Adult-only live sessions and recordings', style: p),
          const Text('• Adult marketplace items — events, products, training programmes, and more', style: p),
          const Text('• Nude or adult-themed gyms', style: p),
          const SizedBox(height: 8),
          const Text(
            'Content is placed in the Mature category by the creator at the time of posting. Adult content that appears anywhere else on the platform is a violation of this policy and the Community Guidelines.',
            style: p,
          ),
        ]),
        LegalSection(title: '2. Age Gate & Country-Aware Threshold', children: [
          const Text('Access to the Mature category requires passing a country-aware age check:', style: p),
          const SizedBox(height: 8),
          const Text('• 18+ by default in every country, including Kenya', style: p),
          const Text('• 16+ only where local law permits', style: p),
          const SizedBox(height: 8),
          const Text('The age gate is applied on entry and re-checked periodically. Misrepresenting your age or country to access the category is a serious violation.', style: p),
        ]),
        LegalSection(title: '3. Prohibited Content', children: [
          const Text('The Mature category is not an exemption from any other rule. The following remain strictly prohibited:', style: p),
          const SizedBox(height: 8),
          const Text('• Depictions of sexual activity or explicit sexual content', style: p),
          const Text('• Any content sexualising minors, or CSAM', style: p),
          const Text('• Non-consensual content or content created without depicted adults\' consent', style: p),
          const Text('• Medical or treatment claims and undisclosed sponsorship', style: p),
          const Text('• Violence, hate speech, or harassment', style: p),
        ]),
        LegalSection(title: '4. Consent & Documentation', children: [
          const Text(
            'Everyone depicted in Mature content must be an adult who has freely consented. Creators must be able to verify the age and consent of everyone depicted when requested by Trust & Safety.',
            style: p,
          ),
        ]),
        LegalSection(title: '5. Creator Obligations', children: [
          const Text('• Classify content as mature accurately at posting', style: p),
          const Text('• Keep adult content inside the Mature category', style: p),
          const Text('• Do not promote mature content to minors', style: p),
          const Text('• Continue to comply with disclosure, health-claim and scope-of-practice rules', style: p),
        ]),
        LegalSection(title: '6. Moderation & Enforcement', children: [
          const Text(
            'Adult content posted outside the Mature category is flagged, hidden, and reviewed by a human moderator. Violations follow the enforcement ladder in the Community Guidelines; repeated or severe violations can lead to suspension or permanent removal.',
            style: p,
          ),
        ]),
        LegalSection(title: '7. Reporting', children: [
          const Text(
            'Report abusive or non-consensual Mature content via the Report button or safety@buddyup.app. Reports are reviewed within 24 hours; reports of harm are escalated within 1 hour.',
            style: p,
          ),
        ]),
      ],
    );
  }
}
