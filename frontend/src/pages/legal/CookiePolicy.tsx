import LegalPage, { LegalSection, LegalNotice } from './LegalPage';

export default function CookiePolicy() {
  return (
    <LegalPage
      title="Cookie Policy"
      subtitle="How BuddyUp uses cookies and similar technologies on our website and platform."
      updatedAt="August 2026"
    >
      <LegalSection title="1. What Are Cookies?">
        <p>Cookies are small text files stored on your device when you visit a website. They help the site remember your preferences and improve your experience.</p>
      </LegalSection>

      <LegalSection title="2. How We Use Cookies">
        <p>BuddyUp uses only strictly necessary cookies by default. No tracking, advertising, or third-party analytics cookies are deployed without your consent.</p>
      </LegalSection>

      <LegalSection title="3. Cookie Categories">
        <h3 className="font-medium text-buddy-text-primary mt-4 mb-2">Strictly Necessary (Always Active)</h3>
        <ul className="list-disc list-inside space-y-1">
          <li><strong>Session cookies</strong> — Required for authentication and keeping you logged in</li>
          <li><strong>Security cookies</strong> — CSRF protection, rate limiting, and fraud prevention</li>
          <li><strong>Preference cookies</strong> — Remembering your theme (dark/light) and language settings</li>
        </ul>

        <h3 className="font-medium text-buddy-text-primary mt-4 mb-2">Analytics (Optional — Requires Consent)</h3>
        <ul className="list-disc list-inside space-y-1">
          <li><strong>Plausible Analytics</strong> — Privacy-compliant, cookie-less analytics (no personal data collected)</li>
          <li><strong>Performance monitoring</strong> — Error tracking via Sentry for app stability</li>
        </ul>

        <h3 className="font-medium text-buddy-text-primary mt-4 mb-2">What We Do NOT Use</h3>
        <ul className="list-disc list-inside space-y-1">
          <li>Advertising cookies</li>
          <li>Third-party tracking cookies</li>
          <li>Social media tracking pixels</li>
          <li>Google Analytics or any Google tracking</li>
          <li>Fingerprinting or cross-site tracking</li>
        </ul>
      </LegalSection>

      <LegalSection title="4. Managing Cookies">
        <p>You can control cookie preferences through the cookie banner on your first visit and through your browser settings. Disabling strictly necessary cookies may affect platform functionality.</p>
      </LegalSection>

      <LegalSection title="5. PWA Storage">
        <p>When using BuddyUp as a Progressive Web App (PWA) on your mobile device, we use local storage and IndexedDB for offline functionality and performance. This data remains on your device and is not transmitted to our servers.</p>
      </LegalSection>

      <LegalSection title="6. Versioned Consent">
        <p>Acceptance of this Cookie Policy is recorded at registration, along with the exact version you accepted. If this policy is materially updated, you will be asked to re-confirm it. You can review the version you accepted at any time under Settings → Your Data → Consent &amp; Policy Versions.</p>
        <LegalNotice>
          We never use advertising cookies, third-party tracking, or fingerprinting. No cross-site tracking of any kind.
        </LegalNotice>
      </LegalSection>

      <LegalSection title="7. Updates">
        <p>We may update this policy periodically. Material changes are notified with at least 30 days' notice; other changes are posted here with a revised effective date.</p>
      </LegalSection>

      <LegalSection title="8. Contact">
        <p>For questions about our cookie practices, contact us at <strong>privacy@buddyup.app</strong>.</p>
      </LegalSection>
    </LegalPage>
  );
}
