export default function Privacy() {
  return (
    <div className="min-h-screen bg-buddy-black">
      <div className="max-w-3xl mx-auto px-6 py-16">
        <h1 className="font-display text-4xl font-extrabold mb-2">Privacy Policy</h1>
        <p className="text-buddy-text-secondary text-sm mb-12">Version 1.0 — Last updated June 2025</p>

        <div className="prose prose-invert max-w-none space-y-8 text-sm leading-relaxed text-buddy-text-secondary">
          <p className="text-buddy-text-primary">BuddyUp is committed to protecting your privacy. This policy explains how we collect, use, and safeguard your personal data.</p>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">1. Data We Collect</h2>
            <h3 className="font-medium text-buddy-text-primary mt-4 mb-2">Identity Data</h3>
            <p>Name, username, email address, phone number, date of birth (hashed), profile photo, and government-issued ID (for verified users).</p>
            <h3 className="font-medium text-buddy-text-primary mt-4 mb-2">Health & Fitness Data</h3>
            <p>Fitness goals, activity level, dietary preferences, workout logs, meal data, body measurements, and progress photos (all user-provided).</p>
            <h3 className="font-medium text-buddy-text-primary mt-4 mb-2">Device & Usage Data</h3>
            <p>IP address, device type, operating system, browser type, approximate location (from IP), pages visited, features used, and session duration.</p>
            <h3 className="font-medium text-buddy-text-primary mt-4 mb-2">Payment Data</h3>
            <p>Payment method tokens (no raw card data stored — handled by Stripe, M-Pesa, and Flutterwave). Purchase history and transaction records.</p>
            <h3 className="font-medium text-buddy-text-primary mt-4 mb-2">Biometric Data</h3>
            <p>Face detection used only for CSAM screening via automated tools. No facial recognition or biometric profiles are built.</p>
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">2. How We Use Your Data</h2>
            <ul className="list-disc list-inside space-y-1">
              <li>To provide, maintain, and improve the BuddyUp platform</li>
              <li>To personalise content, recommendations, and the AI meal plan system</li>
              <li>To process payments and prevent fraud</li>
              <li>To enforce our Community Guidelines and Terms of Service</li>
              <li>To communicate service updates, account information, and promotional content (with consent)</li>
              <li>To comply with legal obligations</li>
              <li>To ensure the safety and security of all users</li>
            </ul>
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">3. Data Sharing</h2>
            <p>BuddyUp does not sell personal data to third parties. We only share data with:</p>
            <ul className="list-disc list-inside space-y-1 mt-2">
              <li><strong>Payment processors</strong> — Stripe, M-Pesa (Safaricom), Flutterwave — for transaction processing</li>
              <li><strong>Cloud providers</strong> — AWS/GCP for hosting and storage</li>
              <li><strong>Content moderation services</strong> — AWS Rekognition for NSFW detection</li>
              <li><strong>Verification services</strong> — Smile Identity/Onfido for KYC verification</li>
              <li><strong>Analytics</strong> — Plausible or Fathom (privacy-compliant, no Google Analytics)</li>
              <li><strong>Legal authorities</strong> — when required by law or to protect rights and safety</li>
            </ul>
            <p className="mt-2">All third parties are contractually bound to process data only per our instructions and applicable data protection laws.</p>
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">4. Data Retention</h2>
            <ul className="list-disc list-inside space-y-1">
              <li><strong>Active accounts</strong> — Data retained for the lifetime of the account</li>
              <li><strong>Deleted accounts</strong> — PII permanently deleted within 30 days; content anonymised; financial records retained 7 years per legal requirements</li>
              <li><strong>Logs</strong> — 90-day retention for security and debugging</li>
            </ul>
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">5. Your Rights (GDPR / Kenya Data Protection Act)</h2>
            <div className="space-y-3">
              <p><strong>Right to Access</strong> — Request a copy of all personal data we hold about you. Fulfilled within 30 days as a downloadable JSON archive.</p>
              <p><strong>Right to Rectification</strong> — Update inaccurate or incomplete personal data at any time through your profile settings.</p>
              <p><strong>Right to Erasure</strong> — Request deletion of your account and associated data. Processed within 30 days (soft delete: immediate; hard delete: 30-day grace).</p>
              <p><strong>Right to Portability</strong> — Receive your data in a machine-readable format (JSON) for transfer to another service.</p>
              <p><strong>Right to Object</strong> — Object to processing for direct marketing. Honoured immediately upon opt-out.</p>
              <p><strong>Right to Complain</strong> — Lodge a complaint with the Kenya Office of the Data Protection Commissioner or your local data protection authority.</p>
            </div>
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">6. Security</h2>
            <p>We implement industry-standard security measures: PII encryption at rest (AES-256-GCM), passwords hashed with Argon2id, HTTPS encryption for all communications, and regular security audits. However, no electronic transmission is 100% secure. We cannot guarantee absolute security.</p>
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">7. Children's Privacy</h2>
            <p>BuddyUp is not intended for users under 16. We do not knowingly collect data from persons under 16. If we learn that we have collected data from an under-16 user, we will delete it promptly. Parents may request removal of their child's data within 72 hours.</p>
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">8. International Transfers</h2>
            <p>Your data may be transferred to and processed in countries outside your residence. We ensure appropriate safeguards are in place for such transfers per applicable data protection laws.</p>
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">9. Contact</h2>
            <p>For privacy inquiries or to exercise your data rights, contact us at privacy@buddyup.app or through the Settings → Help & Safety section in the app.</p>
          </section>
        </div>
      </div>
    </div>
  );
}
