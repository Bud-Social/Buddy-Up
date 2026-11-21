import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/legal_page.dart';

const _privacySubtitle =
    'BuddyUp Fit processes your personal data in accordance with the Kenya Data Protection Act 2019 and applicable law. This policy explains what we collect, why, how long we keep it, and your rights.';

const _body = TextStyle(
  color: BuddyColors.textSecondary,
  fontSize: 13,
  height: 1.6,
);

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPage(
      title: 'Privacy Policy',
      subtitle: _privacySubtitle,
      updatedAt: 'August 2026',
      sections: [
        LegalSection(
          title: '1. Data We Collect',
          children: [
            LegalSubheading('Identity Data'),
            LegalText(
              TextSpan(
                text:
                    'Name, username, email address, phone number, date of birth (stored hashed), profile photo, and government-issued ID (for verified users, sellers, and users receiving payouts above KSh 50,000 in a rolling 30-day period).',
                style: _body,
              ),
            ),
            LegalSubheading('Health & Fitness Data'),
            LegalText(
              TextSpan(
                text:
                    'Fitness goals, activity level, dietary preferences, workout logs, meal data, body measurements, and progress photos. Health data is sensitive personal data under the Kenya Data Protection Act and is processed only with your explicit consent, for the specific purpose you provide it, and with enhanced security controls.',
                style: _body,
              ),
            ),
            LegalSubheading('Parental Co-Owner Data'),
            LegalText(
              TextSpan(
                text:
                    'For users aged 16–17, we collect the name, email, and/or phone of a verified parent or guardian co-owner so they can supervise the account and be contacted by Trust & Safety if needed.',
                style: _body,
              ),
            ),
            LegalSubheading('Device & Usage Data'),
            LegalText(
              TextSpan(
                text:
                    'IP address, device type, operating system, browser type, approximate location (from IP), pages visited, features used, and session duration.',
                style: _body,
              ),
            ),
            LegalSubheading('Payment Data'),
            LegalText(
              TextSpan(
                text:
                    'Payment method tokens (no raw card data is stored — handled by M-Pesa, Stripe, and Flutterwave). Purchase history and transaction records.',
                style: _body,
              ),
            ),
            LegalSubheading('Biometric Data'),
            LegalText(
              TextSpan(
                text:
                    'We do not build facial recognition profiles. Where used for identity or CSAM-screening purposes, it is via automated tools that process images transiently.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '2. What We Do NOT Collect',
          children: [
            LegalBulletList([
              'Health records outside of the opt-in data you explicitly provide',
              'Religious, political, or sexual-orientation data — never',
              "Children's data — the platform is strictly 16+",
            ]),
          ],
        ),
        LegalSection(
          title: '3. How We Use Your Data (Lawful Bases)',
          children: [
            LegalText(
              TextSpan(
                text:
                    'Under the Kenya Data Protection Act 2019, we process personal data on the following bases:',
                style: _body,
              ),
            ),
            LegalBulletList([
              'Consent — default for non-essential processing (marketing, personalisation, sensitive health data)',
              'Contract — to provide the service you signed up for',
              'Legal obligation — tax, anti-fraud, and retention requirements',
              'Legitimate interest — safety, security, and abuse prevention, with a documented balancing test',
            ]),
            LegalText(
              TextSpan(
                text:
                    'Specifically, we use your data to: provide and improve the platform; personalise content and AI recommendations; verify identity and credentials; process payments and prevent fraud; enforce Community Guidelines; communicate service updates (with consent for marketing); and comply with legal obligations.',
                style: _body,
              ),
            ),
            LegalNotice(
              text:
                  'We never sell personal data and never use it for targeted advertising on sensitive categories (health, religion, political views).',
              tone: LegalNoticeTone.green,
            ),
          ],
        ),
        LegalSection(
          title: '4. Data Sharing & Processors',
          children: [
            LegalText(
              TextSpan(
                text:
                    'We share data only with vetted processors and only as needed to operate the service:',
                style: _body,
              ),
            ),
            LegalBulletList([
              'Payment processors — Safaricom M-Pesa (Daraja API), Stripe, Flutterwave',
              'Cloud & storage — AWS/GCP, S3-compatible storage',
              'Content moderation — automated image/text moderation models and services',
              'Verification services — KYC and credential verification providers',
              'Analytics — privacy-compliant analytics (no advertising trackers)',
              'Legal authorities — when required by law or to protect rights and safety',
            ]),
            LegalText(
              TextSpan(
                text:
                    'A sub-processor list is published and updated on this page. All processors are contractually bound to process data only per our instructions and applicable data protection law.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '5. Cross-Border Transfers',
          children: [
            LegalText(
              TextSpan(
                text:
                    'User data is processed in-region where possible. Where cross-border transfer is necessary (e.g. model infrastructure), we ensure protections equivalent to the Kenya Data Protection Act. Personal health information is only transferred cross-border where the Digital Health Act 2023 permits (e.g. health tourism or comparable exception) or with your explicit consent.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '6. Data Retention',
          children: [
            LegalBulletList([
              'Account data — active account + 30-day soft-delete window, then permanent deletion',
              'Safety records — 7 years (audit and regulatory inquiry)',
              'Financial records — per KRA requirements (currently 7 years)',
              'Operational logs — 90 days',
              'Backups — 30 days rolling',
            ]),
          ],
        ),
        LegalSection(
          title: '7. Your Rights',
          children: [
            LegalText(TextSpan(text: 'You have the right to:', style: _body)),
            LegalBulletList([
              'Access — request a copy of your data (downloadable JSON archive)',
              'Rectification — correct inaccurate or incomplete data',
              'Erasure — request deletion (30-day grace period applies)',
              'Portability — receive your data in a machine-readable format',
              'Restriction & Objection — restrict processing or object to marketing',
              'Complain — lodge a complaint with the Kenya Office of the Data Protection Commissioner (ODPC)',
            ]),
            LegalText(
              TextSpan(
                text:
                    'Use Settings → Your Data to export or delete, or email privacy@buddyup.com. We respond within the statutory window.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '8. Security',
          children: [
            LegalText(
              TextSpan(
                text:
                    'We protect data with TLS in transit, encryption at rest, password hashing (Argon2id), role-based access control, intrusion monitoring, and an incident-response plan. Personal data breach notifications are provided within the statutory window.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '9. Children\'s Privacy',
          children: [
            LegalText(
              TextSpan(
                text:
                    'BuddyUp Fit is not directed to users under 16. Users aged 16–17 may use the service only with a verified parental co-owner. If we learn that we have collected data from a user under 16, we will delete it promptly and terminate the account.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '10. Automated Decisions & AI',
          children: [
            LegalText(
              TextSpan(
                text:
                    'Some decisions are partly automated: safety triage, feed ranking, discovery, and buddy suggestions. Significant decisions (account suspension, payment holds, dispute outcomes) always have a human review path. You may request human review of any automated decision that affects you via Settings → Help & Safety.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '11. Cookies & Local Storage',
          children: [
            LegalText(
              TextSpan(
                text:
                    'BuddyUp Fit uses only strictly necessary cookies by default. Functional and analytics cookies require your consent and can be changed at any time from the cookie banner or Settings. No advertising, cross-site tracking, or fingerprinting.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '12. Changes to This Policy',
          children: [
            LegalText(
              TextSpan(
                text:
                    'Material changes are notified by email and in-app at least 30 days before they take effect and may require re-consent. Non-material changes are posted here with a revised effective date.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '13. Contact',
          children: [
            LegalText(
              TextSpan(
                text:
                    'Data Protection Officer, BuddyUp Fit Ltd., Nairobi, Kenya. Email: dpo@buddyup.com. Postal address to be registered with ODPC.',
                style: _body,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
