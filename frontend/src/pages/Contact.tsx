import { Link } from 'react-router-dom';
import { Mail, MessageCircle } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Navbar } from '@/components/landing/Navbar';
import { ContactForm } from '@/components/features/support/ContactForm';
import { CONTACT_EMAILS, mailtoLink } from '@/config/contact';

const FAQ = [
  {
    q: 'How fast do you reply?',
    a: 'Within two business days. Partnership and press inquiries usually get a same-week response.',
  },
  {
    q: 'Support or partnership?',
    a: 'Account and app help goes through this form with the Support topic. Brands, gyms, and sponsors: choose Gyms & Partnerships so the right team picks it up.',
  },
  {
    q: 'Something unsafe on the platform?',
    a: 'Use the in-app Report button for the fastest response, or email report@buddyup.co.ke. Emergencies: contact local emergency services first.',
  },
];

export default function Contact() {
  return (
    <div className="min-h-screen bg-buddy-black overflow-x-hidden">
      <Navbar />
      <header className="relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-b from-buddy-green/5 to-transparent pointer-events-none" />
        <div className="max-w-4xl mx-auto px-6 pt-28 pb-12 text-center relative z-10">
          <MessageCircle size={44} className="mx-auto text-buddy-green mb-5" />
          <h1 className="font-display text-4xl sm:text-5xl font-extrabold text-white mb-5 leading-tight">
            Talk to a <span className="text-buddy-green">human.</span>
          </h1>
          <p className="text-lg text-buddy-text-secondary max-w-2xl mx-auto leading-relaxed">
            Real humans, Nairobi time. Partnerships, gym onboarding, press, or support —
            one inbox, routed to the right team.
          </p>
        </div>
      </header>

      <section className="max-w-5xl mx-auto px-6 py-10">
        <div className="grid md:grid-cols-2 gap-6 items-start">
          <Card className="p-6 sm:p-8 bg-buddy-surface">
            <ContactForm />
          </Card>
          <div className="space-y-4">
            <Card className="p-6 bg-buddy-surface">
              <div className="flex items-center gap-2 mb-2">
                <Mail size={18} className="text-buddy-green" />
                <h3 className="font-heading font-semibold text-sm">Prefer email?</h3>
              </div>
              <a href={mailtoLink('direct')} className="text-buddy-green hover:underline break-all text-sm">
                {CONTACT_EMAILS.direct}
              </a>
              <p className="text-xs text-buddy-text-secondary mt-2">
                For safety issues use the in-app Report button or <strong>report@buddyup.co.ke</strong>.
              </p>
            </Card>
            {FAQ.map(({ q, a }) => (
              <Card key={q} className="p-6 bg-buddy-surface">
                <h3 className="font-heading font-semibold text-sm mb-1">{q}</h3>
                <p className="text-sm text-buddy-text-secondary">{a}</p>
              </Card>
            ))}
            <p className="text-sm text-buddy-text-secondary px-1">
              Looking for help using the app?{' '}
              <Link to="/help" className="text-buddy-green hover:underline">Visit the Help Centre</Link>.
            </p>
          </div>
        </div>
      </section>
    </div>
  );
}
