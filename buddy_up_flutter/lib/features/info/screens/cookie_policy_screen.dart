import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/legal_page.dart';

const _cookieSubtitle =
    'How BuddyUp Fit uses cookies and similar technologies on our website and platform.';

const _body = TextStyle(
  color: BuddyColors.textSecondary,
  fontSize: 13,
  height: 1.6,
);

class CookiePolicyScreen extends StatelessWidget {
  const CookiePolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPage(
      title: 'Cookie Policy',
      subtitle: _cookieSubtitle,
      updatedAt: 'August 2026',
      sections: [
        LegalSection(
          title: '1. What Are Cookies?',
          children: [
            LegalText(
              TextSpan(
                text:
                    'Cookies are small text files stored on your device when you visit a website. They help the site remember your preferences and improve your experience.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '2. How We Use Cookies',
          children: [
            LegalText(
              TextSpan(
                text:
                    'BuddyUp Fit uses only strictly necessary cookies by default. No tracking, advertising, or third-party analytics cookies are deployed without your consent.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '3. Cookie Categories',
          children: [
            LegalSubheading('Strictly Necessary (Always Active)'),
            LegalBulletList([
              'Session cookies — Required for authentication and keeping you logged in',
              'Security cookies — CSRF protection, rate limiting, and fraud prevention',
              'Preference cookies — Remembering your theme (dark/light) and language settings',
            ]),
            LegalSubheading('Analytics (Optional — Requires Consent)'),
            LegalBulletList([
              'Plausible Analytics — Privacy-compliant, cookie-less analytics (no personal data collected)',
              'Performance monitoring — Error tracking via Sentry for app stability',
            ]),
            LegalSubheading('What We Do NOT Use'),
            LegalBulletList([
              'Advertising cookies',
              'Third-party tracking cookies',
              'Social media tracking pixels',
              'Google Analytics or any Google tracking',
              'Fingerprinting or cross-site tracking',
            ]),
          ],
        ),
        LegalSection(
          title: '4. Managing Cookies',
          children: [
            LegalText(
              TextSpan(
                text:
                    'You can control cookie preferences through the cookie banner on your first visit and through your browser settings. Disabling strictly necessary cookies may affect platform functionality.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '5. PWA Storage',
          children: [
            LegalText(
              TextSpan(
                text:
                    'When using BuddyUp Fit as a Progressive Web App (PWA) on your mobile device, we use local storage and IndexedDB for offline functionality and performance. This data remains on your device and is not transmitted to our servers.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '6. Versioned Consent',
          children: [
            LegalText(
              TextSpan(
                text:
                    'Acceptance of this Cookie Policy is recorded at registration, along with the exact version you accepted. If this policy is materially updated, you will be asked to re-confirm it. You can review the version you accepted at any time under Settings → Your Data → Consent & Policy Versions.',
                style: _body,
              ),
            ),
            LegalNotice(
              text:
                  'We never use advertising cookies, third-party tracking, or fingerprinting. No cross-site tracking of any kind.',
              tone: LegalNoticeTone.green,
            ),
          ],
        ),
        LegalSection(
          title: '7. Updates',
          children: [
            LegalText(
              TextSpan(
                text:
                    'We may update this policy periodically. Material changes are notified with at least 30 days\' notice; other changes are posted here with a revised effective date.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '8. Contact',
          children: [
            LegalText(
              TextSpan(
                text:
                    'For questions about our cookie practices, contact us at privacy@buddyup.com.',
                style: _body,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
