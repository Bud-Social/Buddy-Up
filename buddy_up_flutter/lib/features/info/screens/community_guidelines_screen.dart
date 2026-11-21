import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/legal_page.dart';

const _guidelinesSubtitle =
    'BuddyUp Fit exists to help people find their fitness family. These guidelines keep our community safe, inclusive, and focused on health and wellness.';

const _body = TextStyle(
  color: BuddyColors.textSecondary,
  fontSize: 13,
  height: 1.6,
);

class CommunityGuidelinesScreen extends StatelessWidget {
  const CommunityGuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPage(
      title: 'Community Guidelines',
      subtitle: _guidelinesSubtitle,
      updatedAt: 'August 2026',
      sections: [
        LegalSection(
          title: '1. Health & Safety',
          children: [
            LegalText(
              TextSpan(
                text:
                    'No promotion of eating disorders. Content promoting extreme restriction, purging, or other disordered eating behaviours is prohibited.',
                style: _body,
              ),
            ),
            LegalText(
              TextSpan(
                text:
                    'No dangerous health advice. Do not promote unverified supplements, unlicensed drugs, or dangerous practices.',
                style: _body,
              ),
            ),
            LegalText(
              TextSpan(
                text:
                    'No medical claims outside a licensed relationship. Sharing your own fitness story is welcome. Advising specific treatment, dosing, or diagnosis is not. Claims that a meal plan or programme "treats", "cures", or "manages" a medical condition (e.g. diabetes, PCOS, insulin resistance) are prohibited unless made within a verified practitioner relationship.',
                style: _body,
              ),
            ),
            LegalText(
              TextSpan(
                text:
                    'Professional guidance disclaimer. Users who are not verified practitioners must include a disclaimer when sharing health information. Only verified practitioners may present advice as professional guidance, and only within their verified scope of practice.',
                style: _body,
              ),
            ),
            LegalText(
              TextSpan(
                text:
                    'No PED promotion. Promotion of performance-enhancing drugs is prohibited except for factual educational content from verified practitioners.',
                style: _body,
              ),
            ),
            LegalText(
              TextSpan(
                text:
                    'No dangerous stunts. Content depicting extreme self-harm in the context of fitness or misuse of equipment will be removed.',
                style: _body,
              ),
            ),
            LegalText(
              TextSpan(
                text:
                    'Scope of practice. Coaches and trainers must provide guidance only within their verified scope (general fitness and wellness) and must not present meal plans as personalised medical nutrition therapy.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '2. Sponsored Content & Gifting Disclosure',
          children: [
            LegalText(
              TextSpan(
                text:
                    'Disclose material connections. If you received anything of value — gifted products, free programme access, payment, affiliate benefits, trips, or event invitations — in exchange for content, you must disclose it clearly and prominently ("#ad", "Sponsored", or "Paid partnership" near the top of the post).',
                style: _body,
              ),
            ),
            LegalText(
              TextSpan(
                text:
                    'No hidden disclosures. Burying a disclosure in a long caption or fine print is treated as non-disclosure. Undisclosed promotional content may be flagged, labelled, or removed.',
                style: _body,
              ),
            ),
            LegalText(
              TextSpan(
                text:
                    'No fake reviews. Reviews must reflect genuine experiences. Do not post incentivised reviews without disclosure.',
                style: _body,
              ),
            ),
            LegalText(
              TextSpan(
                text:
                    'No artificial metrics. Do not purchase followers, likes, or engagement. Do not use bots.',
                style: _body,
              ),
            ),
            LegalText(
              TextSpan(
                text:
                    'No fraudulent services. Do not claim certifications you do not hold or take payment without delivering promised services.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '3. AI-Generated Content',
          children: [
            LegalText(
              TextSpan(
                text:
                    'Label AI output. Every AI-generated text, image, recommendation, or ranking is labelled with its source model and a limitation statement.',
                style: _body,
              ),
            ),
            LegalText(
              TextSpan(
                text:
                    'No impersonation by AI. You may not repost AI output as your own advice or present it as professional guidance.',
                style: _body,
              ),
            ),
            LegalText(
              TextSpan(
                text:
                    'No medical claims by AI. AI must not produce diagnosis, prescription, or legal interpretation.',
                style: _body,
              ),
            ),
            LegalText(
              TextSpan(
                text:
                    'Human review. Automated moderation flags are reviewed by a human moderator before any removal action is taken.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '4. Age Safety',
          children: [
            LegalText(
              TextSpan(
                text:
                    'Platform strictly 16+. Any accounts confirmed to belong to persons under 16 are permanently terminated.',
                style: _body,
              ),
            ),
            LegalText(
              TextSpan(
                text:
                    'Parental co-owner for 16–17. Users aged 16–17 must be co-owned by a verified parent or guardian.',
                style: _body,
              ),
            ),
            LegalText(
              TextSpan(
                text:
                    'No content targeting minors. No content sexualising minors or designed to appeal inappropriately to persons under 16.',
                style: _body,
              ),
            ),
            LegalText(
              TextSpan(
                text:
                    'Zero tolerance for CSAM. Any creation or sharing of child sexual abuse material results in immediate account termination and reporting to NCMEC and local law enforcement.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '5. Respect & Inclusion',
          children: [
            LegalText(
              TextSpan(
                text:
                    'No hate speech. Zero tolerance for hate speech targeting any person based on body size/shape, race, ethnicity, religion, gender, sexual orientation, disability, or nationality.',
                style: _body,
              ),
            ),
            LegalText(
              TextSpan(
                text:
                    'No body-shaming. No fat-phobia, body-shaming, diet-culture extremism, or derogatory comments about anyone\'s appearance or abilities.',
                style: _body,
              ),
            ),
            LegalText(
              TextSpan(
                text:
                    'No bullying or harassment. No targeted abuse, intimidation, or coordinated attacks.',
                style: _body,
              ),
            ),
            LegalText(
              TextSpan(
                text:
                    'No spam. No coordinated inauthentic behaviour, spam, or artificial engagement.',
                style: _body,
              ),
            ),
            LegalText(
              TextSpan(
                text:
                    'No impersonation. No impersonation of verified trainers, practitioners, or public figures.',
                style: _body,
              ),
            ),
            LegalText(
              TextSpan(
                text:
                    'No doxxing. Do not share another person\'s private information without consent.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '6. Live Sessions',
          children: [
            LegalText(
              TextSpan(
                text:
                    'Host controls. Hosts may mute, remove, and ban viewers. Recording requires explicit consent from the host and visible participants.',
                style: _body,
              ),
            ),
            LegalText(
              TextSpan(
                text:
                    'Viewer conduct. No doxxing, no sexual content, no medical advice, no commercial solicitation outside authorised paid sessions.',
                style: _body,
              ),
            ),
            LegalText(
              TextSpan(
                text:
                    'Safety. Every live session shows the host\'s emergency contact and a BuddyUp Fit safety shortcut.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '7. Enforcement',
          children: [
            LegalBulletList([
              '1st minor violation: Warning + content removal',
              '2nd minor / 1st moderate: 24-hour content posting suspension',
              '3rd minor / 2nd moderate / 1st severe: 7-day full suspension',
              '4th / 2nd severe: 30-day suspension + mandatory account review',
              '5th / any critical: Permanent ban + potential law enforcement referral',
            ]),
            LegalText(
              TextSpan(
                text:
                    'Undisclosed sponsorship and medical claims are treated as moderate-to-severe violations. Users may appeal enforcement actions within 14 days through Settings → Help & Safety.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '8. Reporting',
          children: [
            LegalText(
              TextSpan(
                text:
                    'Report violations via the Report button on any post, comment, or profile, or email report@buddyup.co.ke. Reports are reviewed within 24 hours; severe categories are escalated within 1 hour. Reports involving imminent harm bypass the queue.',
                style: _body,
              ),
            ),
            LegalNotice(
              text:
                  'Health misinformation, medical claims, and undisclosed sponsorships are automatically flagged by our moderation systems and always reviewed by a human moderator before action.',
              tone: LegalNoticeTone.orange,
            ),
          ],
        ),
      ],
    );
  }
}
