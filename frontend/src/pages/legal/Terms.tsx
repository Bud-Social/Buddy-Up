export default function Terms() {
  return (
    <div className="min-h-screen bg-buddy-black">
      <div className="max-w-3xl mx-auto px-6 py-16">
        <h1 className="font-display text-4xl font-extrabold mb-2">Terms of Service</h1>
        <p className="text-buddy-text-secondary text-sm mb-12">Version 1.0 — Last updated June 2025</p>

        <div className="prose prose-invert max-w-none space-y-8 text-sm leading-relaxed text-buddy-text-secondary">
          <p className="text-buddy-text-primary">Welcome to BuddyUp. By accessing or using our platform, you agree to these Terms of Service. Please read them carefully.</p>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">1. Age Requirement</h2>
            <p>You must be 16 years of age or older to use BuddyUp. By creating an account, you confirm that you meet this age requirement. BuddyUp reserves the right to terminate any account where the user is found to be under 16, without refund of any virtual currency balance.</p>
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">2. Account Ownership</h2>
            <p>Accounts are personal and non-transferable. You are responsible for all activity under your account, including maintaining the confidentiality of your password. You must provide accurate, current, and complete information during registration and keep your account information updated.</p>
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">3. Content Licence</h2>
            <p>By posting content on BuddyUp (including posts, comments, photos, videos, workout logs, and live sessions), you grant BuddyUp a non-exclusive, royalty-free, worldwide licence to display, distribute, and promote the content on and through the platform. You retain full ownership of your content. This licence ends when you delete your content or your account, except where content has been shared with others and they have not deleted it.</p>
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">4. Virtual Currency (Fitness Artifacts)</h2>
            <p>Fitness Artifacts are virtual tokens with no cash value outside the BuddyUp platform. They cannot be exchanged for real currency except through BuddyUp's approved withdrawal process. BuddyUp reserves the right to adjust the artifact economy, including pricing and exchange rates, with reasonable notice. Unused artifact balances are non-refundable except as required by applicable law.</p>
            <p className="mt-2">Purchases of artifacts are final unless required otherwise by law. Withdrawn balances are subject to platform fees (2.5%) and payment processor fees. Minimum withdrawal amount: $10.00 USD equivalent.</p>
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">5. Trainer & Practitioner Liability</h2>
            <p>BuddyUp is a connection platform. We do not employ, endorse, or guarantee the qualifications of trainers, health practitioners, or any service providers on the platform. While we verify credentials to the best of our ability, users engage these professionals at their own risk. BuddyUp is not liable for any harm, injury, or loss arising from:</p>
            <ul className="list-disc list-inside mt-2 space-y-1">
              <li>Following fitness, nutrition, or health advice obtained on the platform</li>
              <li>Participating in live workout sessions</li>
              <li>Using meal plans, training programmes, or supplements purchased through the marketplace</li>
              <li>Services provided by trainers or practitioners</li>
            </ul>
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">6. Community Guidelines</h2>
            <p>All users must comply with our Community Guidelines, which are incorporated into these Terms. Violations may result in content removal, account suspension, or permanent termination. Repeated or severe violations will result in account termination without refund.</p>
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">7. Platform Modifications</h2>
            <p>BuddyUp reserves the right to modify, suspend, or discontinue any aspect of the platform at any time. We will provide 30 days' notice for material changes to these Terms. Continued use after such notice constitutes acceptance of the modified Terms.</p>
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">8. Dispute Resolution</h2>
            <p>All disputes must first go through BuddyUp's internal resolution process. If unresolved, binding arbitration applies. Jurisdiction: Republic of Kenya, with users outside Kenya subject to international arbitration under UNCITRAL rules. Users waive the right to participate in class action lawsuits.</p>
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">9. Limitation of Liability</h2>
            <p>To the maximum extent permitted by law, BuddyUp shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising from your use of the platform. Our total liability is limited to the amount you have paid to BuddyUp in the 12 months preceding the claim.</p>
          </section>

          <section>
            <h2 className="font-heading text-lg font-semibold text-buddy-text-primary mb-3">10. Contact</h2>
            <p>For questions about these Terms, contact us at legal@buddyup.app.</p>
          </section>
        </div>
      </div>
    </div>
  );
}
