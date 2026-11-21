import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/legal_page.dart';

const _termsSubtitle =
    'This is not medical, nutritional, legal or professional advice. BuddyUp Fit is a connection and accountability platform. Coaches, trainers and practitioners are independent providers, not employees of BuddyUp Fit.';

const _body = TextStyle(
  color: BuddyColors.textSecondary,
  fontSize: 13,
  height: 1.6,
);

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPage(
      title: 'Terms of Service',
      subtitle: _termsSubtitle,
      updatedAt: 'August 2026',
      sections: [
        LegalSection(
          title: '1. Acceptance and Eligibility',
          children: [
            LegalText(
              TextSpan(
                text:
                    'By creating an account you confirm that you are at least 16 years old, that the information you provide is accurate, and that you accept these Terms, the Privacy Policy, and the Community Guidelines. If you do not accept them, do not use the service.',
                style: _body,
              ),
            ),
            LegalText(
              TextSpan(
                text:
                    'Users aged 16–17 may only use BuddyUp Fit with a verified parental co-owner (parent or guardian), who is bound by the same Terms and may be contacted by our Trust & Safety team. Accounts found to belong to users under 16 are terminated.',
                style: _body,
              ),
            ),
            LegalNotice(
              text:
                  'You must provide accurate, current registration information. BuddyUp Fit may verify age, identity, and credentials, and may block or suspend accounts that rely on false information.',
              tone: LegalNoticeTone.orange,
            ),
          ],
        ),
        LegalSection(
          title: '2. Account Security',
          children: [
            LegalText(
              TextSpan(
                text:
                    'You are responsible for your account credentials and for activity under your account. Enable two-factor authentication where available. Notify us immediately at security@buddyup.com if you suspect unauthorised access.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '3. Service Description',
          children: [
            LegalText(
              TextSpan(
                text:
                    'BuddyUp Fit combines free social and accountability features (posts, buddy circles, live sessions) with optional paid services: gym subscriptions, session bookings, training programmes, meal plans, and marketplace purchases. Funds for booked services are held in escrow and released on completion of the service.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '4. Health, Fitness & Nutrition Information',
          children: [
            LegalText(
              TextSpan(
                text:
                    'BuddyUp Fit provides a platform for users to share fitness experiences and for verified coaches, trainers and practitioners to offer guidance. The platform does not provide medical advice, diagnosis, or treatment.',
                style: _body,
              ),
            ),
            LegalSubheading('Scope of practice.'),
            LegalText(
              TextSpan(
                text:
                    'Only verified practitioners (licensed clinicians, dietitians, physiotherapists) may present advice as professional or clinical guidance. All other users and coaches may only share general wellness information. Content that claims to diagnose, treat, cure, or manage a medical condition (e.g. "reverses insulin resistance", "cures PCOS", "treatment for diabetes") is prohibited outside a licensed professional relationship.',
                style: _body,
              ),
            ),
            LegalSubheading('No guarantees.'),
            LegalText(
              TextSpan(
                text:
                    'Fitness and nutrition outcomes depend on individual factors and are never guaranteed. Meal plans and programmes provided on BuddyUp Fit are general wellness resources, not personalised medical nutrition therapy.',
                style: _body,
              ),
            ),
            LegalNotice(
              text:
                  'AI-generated recommendations are for informational purposes only and are not a substitute for professional judgement. If you have a medical condition, injury, or persistent symptoms, consult a qualified healthcare professional.',
              tone: LegalNoticeTone.red,
            ),
          ],
        ),
        LegalSection(
          title: '5. Sponsored Content & Gifting Disclosure',
          children: [
            LegalText(
              TextSpan(
                text:
                    'Creators, trainers, and members must clearly disclose any material connection to a brand, gym, or programme — including gifted products, free programme access, affiliate arrangements, or paid partnerships. Disclosures must be prominent and placed where they are likely to be seen (for example "#ad", "Sponsored", or "Paid partnership" near the top of the post).',
                style: _body,
              ),
            ),
            LegalText(
              TextSpan(
                text:
                    'Hiding a disclosure in a long caption or fine print is treated as non-disclosure. Undisclosed promotional content may be flagged, labelled, or removed, and repeat violations may lead to suspension.',
                style: _body,
              ),
            ),
            LegalText(
              TextSpan(
                text:
                    'Sponsored and partner placements are never mixed into organic ranking without a visible label.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '6. AI-Generated Content',
          children: [
            LegalText(
              TextSpan(
                text:
                    'Every AI-generated output on BuddyUp Fit is labelled with its source and a limitation statement. You may not repost AI output as your own advice or present it as professional guidance. Automated moderation flags are reviewed by a human moderator before any removal action is taken.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '7. Community Standards & Enforcement',
          children: [
            LegalText(
              TextSpan(
                text:
                    'All users must comply with the Community Guidelines. Violations are handled through a graduated enforcement process (warning → content removal → suspension → permanent removal). You may appeal an enforcement action through Settings → Help & Safety within 14 days.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '8. Verification & Credentials',
          children: [
            LegalText(
              TextSpan(
                text:
                    'Trainers, practitioners, gyms, and marketplace sellers must complete the relevant verification tier. Verification checks credentials against issuing registries where possible and is subject to periodic re-verification and renewal. Listings that rely on false credentials, or that fail to renew on time, may be suspended.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '9. Marketplace Purchases',
          children: [
            LegalText(
              TextSpan(
                text:
                    'Marketplace listings are governed by the seller\'s verification tier and their published cancellation/refund policy. BuddyUp Fit is the platform of record and is not the seller of record except for first-party items. Digital products are refundable within 7 days if not more than 25% consumed.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '10. Payments, Fees & Refunds',
          children: [
            LegalText(
              TextSpan(
                text:
                    'Paid services are billed in Kenyan Shillings via M-Pesa, card, or other approved payment rails. Cancellations follow the partner\'s published policy. Sessions cancelled at least 2 hours before start receive a full refund; later cancellations follow the partner\'s policy (default 50%). No-shows forfeit the session fee. Refund and dispute procedures are described in Settings → Help.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '11. Content Ownership & Licence',
          children: [
            LegalText(
              TextSpan(
                text:
                    'You retain ownership of content you create. You grant BuddyUp Fit a limited, non-exclusive, royalty-free licence to host, display, distribute, and process that content to operate the service (including ranking, search, and replay where applicable). The licence ends when you delete the content or close your account, subject to legal retention obligations.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '12. Suspension & Termination',
          children: [
            LegalText(
              TextSpan(
                text:
                    'BuddyUp Fit may suspend or terminate accounts that breach these Terms, the Community Guidelines, or applicable law, after a proportionate warning except in cases of imminent harm. You may close your account at any time; closure triggers a 30-day recoverable soft-delete followed by permanent deletion.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '13. Disclaimer of Warranties',
          children: [
            LegalText(
              TextSpan(
                text:
                    'The service is provided "as is" and "as available". BuddyUp Fit does not warrant that fitness outcomes will be achieved and is not responsible for the actions, advice, or conduct of independent coaches, trainers, or practitioners. Users engage these professionals at their own risk.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '14. Limitation of Liability',
          children: [
            LegalText(
              TextSpan(
                text:
                    'To the maximum extent permitted by law, BuddyUp Fit\'s aggregate liability for any claim is limited to the fees paid by you to BuddyUp Fit in the 12 months preceding the event giving rise to the claim. BuddyUp Fit is not liable for indirect, incidental, special, or consequential damages.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '15. Disputes',
          children: [
            LegalText(
              TextSpan(
                text:
                    'Disputes are resolved through BuddyUp Fit\'s three-level procedure: (1) Buddy/gym-mediated, (2) Bud Concierge mediation for disputes up to KSh 20,000, and (3) a formal Dispute Panel for larger disputes and fraud/harm allegations. Unresolved disputes are subject to the exclusive jurisdiction of the Kenyan courts and governed by the laws of the Republic of Kenya.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '16. Changes to the Service or Terms',
          children: [
            LegalText(
              TextSpan(
                text:
                    'BuddyUp Fit may add, modify, or remove features with reasonable notice. Material changes affecting your rights (including these Terms and the Privacy Policy) will be communicated by email and in-app at least 30 days before they take effect. Continued use after the effective date constitutes acceptance.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '17. Contact',
          children: [
            LegalText(
              TextSpan(
                text:
                    'BuddyUp Fit Ltd., Nairobi, Kenya. For questions about these Terms, contact legal@buddyup.com. For safety concerns, contact report@buddyup.co.ke.',
                style: _body,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
