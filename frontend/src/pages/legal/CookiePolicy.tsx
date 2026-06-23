export default function CookiePolicy() {
  return (
    <div className="min-h-screen bg-buddy-black">
      <div className="max-w-3xl mx-auto px-6 py-16">
        <h1 className="font-display text-4xl font-extrabold mb-2">Cookie Policy</h1>
        <p className="text-buddy-text-secondary text-sm mb-12">Last updated June 2025</p>

        <div className="prose prose-invert max-w-none space-y-8 text-sm leading-relaxed text-buddy-text-secondary">
          <p className="text-buddy-text-primary">This policy explains how BuddyUp uses cookies and similar technologies on our website and platform.</p>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">1. What Are Cookies?</h2>
            <p>Cookies are small text files stored on your device when you visit a website. They help the site remember your preferences and improve your experience.</p>
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">2. How We Use Cookies</h2>
            <p>BuddyUp uses only strictly necessary cookies by default. No tracking, advertising, or third-party analytics cookies are deployed without your consent.</p>
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">3. Cookie Categories</h2>

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
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">4. Managing Cookies</h2>
            <p>You can control cookie preferences through the cookie banner on your first visit and through your browser settings. Disabling strictly necessary cookies may affect platform functionality.</p>
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">5. PWA Storage</h2>
            <p>When using BuddyUp as a Progressive Web App (PWA) on your mobile device, we use local storage and IndexedDB for offline functionality and performance. This data remains on your device and is not transmitted to our servers.</p>
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">6. Updates</h2>
            <p>We may update this policy periodically. Changes will be posted on this page with an updated date.</p>
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">7. Contact</h2>
            <p>For questions about our cookie practices, contact us at privacy@buddyup.app.</p>
          </section>
        </div>
      </div>
    </div>
  );
}
