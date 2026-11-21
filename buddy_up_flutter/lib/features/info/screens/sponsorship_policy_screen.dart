import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/legal_page.dart';

const _sponsorshipSubtitle =
    'BuddyUp Fit is built on trust. When creators are compensated or gifted in exchange for content, that connection must be disclosed clearly and prominently.';

const _body = TextStyle(
  color: BuddyColors.textSecondary,
  fontSize: 13,
  height: 1.6,
);

class SponsorshipPolicyScreen extends StatelessWidget {
  const SponsorshipPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPage(
      title: 'Sponsorship & Disclosure Policy',
      subtitle: _sponsorshipSubtitle,
      updatedAt: 'August 2026',
      sections: [
        LegalSection(
          title: '1. What Counts as a Material Connection',
          children: [
            LegalText(
              TextSpan(
                text:
                    'A material connection exists when a creator receives anything of value in connection with content they post. This includes, without limitation:',
                style: _body,
              ),
            ),
            LegalBulletList([
              'Gifted products, supplements, or fitness equipment',
              'Free or discounted programme access, memberships, or services',
              'Cash payments or performance-based bonuses',
              'Affiliate commissions or referral benefits',
              'Trips, event invitations, or other non-monetary perks',
              'Personal or family relationships with a brand',
            ]),
            LegalText(
              TextSpan(
                text:
                    'Even if the brand did not ask for or control the content, a material connection still exists and must be disclosed.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '2. How to Disclose',
          children: [
            LegalText(
              TextSpan(
                text: 'Disclosures must be clear, prominent, and unambiguous:',
                style: _body,
              ),
            ),
            LegalBulletList([
              'Place the disclosure at the start of the caption or as an on-screen label, not buried in fine print',
              'Use unmistakable language: "#ad", "Sponsored", "Paid partnership", "Gifted by [Brand]"',
              'A disclosure that is easily missed, requires scrolling, or uses vague language ("thanks to my friends at…") does not comply',
              'Disclose in the primary language of the audience',
            ]),
            LegalNotice(
              text:
                  'Hiding a disclosure, placing it only in a comment, or omitting it entirely is treated as non-disclosure and may result in the content being flagged, labelled, or removed, and further enforcement action.',
              tone: LegalNoticeTone.orange,
            ),
          ],
        ),
        LegalSection(
          title: '3. What Cannot Be Sponsored',
          children: [
            LegalText(
              TextSpan(
                text:
                    'The following are prohibited in sponsored or gifted content:',
                style: _body,
              ),
            ),
            LegalBulletList([
              'Medical claims — no product or plan may be presented as treating, curing, or managing a condition',
              'Claims about licensed professionals or therapies outside their verified scope',
              'Unregistered supplements, medicines, or banned substances',
              'Endorsements from users who have not genuinely used the product',
              'Testimonials implying results the creator did not actually experience',
            ]),
          ],
        ),
        LegalSection(
          title: '4. Platforms for Disclosure',
          children: [
            LegalText(
              TextSpan(
                text:
                    'When a BuddyUp Fit content link is shared on external platforms, the disclosure obligation applies there too. Creators must comply with the advertising disclosure rules of the country where the audience is located, including Kenya\'s Consumer Protection Act.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '5. Detection & Enforcement',
          children: [
            LegalText(
              TextSpan(
                text:
                    'Our moderation systems automatically detect promotional patterns (gifting language, brand mentions with affiliate markers) and check for the presence of a disclosure. Content that is promotional without a compliant disclosure is flagged for human review and may be:',
                style: _body,
              ),
            ),
            LegalBulletList([
              'Labelled as undisclosed sponsorship',
              'Removed, with the account subject to the enforcement ladder in the Community Guidelines',
              'Reported to relevant authorities where required by law',
            ]),
          ],
        ),
        LegalSection(
          title: '6. Creators & Trainers Obligations',
          children: [
            LegalText(
              TextSpan(
                text:
                    'Creators, coaches, and trainers who accept gifting or sponsorship remain responsible for the truthfulness of their content. Paid promotional content must not include undisclosed claims, fake testimonials, or results the creator has not experienced. Repeated violations can result in loss of creator and verification benefits.',
                style: _body,
              ),
            ),
            LegalText(
              TextSpan(
                text:
                    'Mature category is not exempt. Sponsorship and gifting disclosure rules apply in full to the Mature (18+/16+) category. Gifted adult content must still carry a clear, prominent disclosure, and all medical-claim prohibitions continue to apply.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '7. Questions',
          children: [
            LegalText(
              TextSpan(
                text:
                    'For questions about this policy or a specific disclosure, contact report@buddyup.co.ke.',
                style: _body,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
