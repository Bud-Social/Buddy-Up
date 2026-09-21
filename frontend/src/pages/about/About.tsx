import { Link } from 'react-router-dom';
import { Handshake, Heart, Radio, Globe, ShieldCheck, TrendingUp, ArrowLeft } from 'lucide-react';
import { Logo } from '@/components/ui/Logo';
import { Button } from '@/components/ui/Button';
import { CONTACT_EMAILS, mailtoLink } from '@/config/contact';

const values = [
  { icon: Handshake, title: 'Accountability is social', desc: 'Consistency is easier with someone in your corner. Every feature we build starts from real human connection, not engagement tricks.' },
  { icon: Heart, title: 'Free where it matters', desc: 'Finding a buddy, joining a gym, and training together are free — permanently. We monetise extras, never the basics.' },
  { icon: ShieldCheck, title: 'Verified, not anonymous', desc: 'Trainers and practitioners are credential-verified before they can sell. Health claims without a licence are not tolerated.' },
  { icon: Globe, title: 'Built where it\'s used', desc: 'We launch from Nairobi for African fitness communities first — M-Pesa, low-data mode, local language — then take it to the world.' },
  { icon: TrendingUp, title: 'Outcomes over optics', desc: 'We measure success in streaks kept and habits built, not in follower counts or crash-diet transformations.' },
  { icon: Radio, title: 'Live by default', desc: 'Workouts are better together in real time. Live sessions, Random Drops, and Buddy Circles are the heartbeat of the app.' },
];

const milestones = [
  { when: 'The idea', what: 'Two friends kept failing at 5am runs alone — and never missed one together. BuddyUp started as the answer to "why isn\'t there an app for this?"' },
  { when: 'Private beta', what: 'A closed group of test users trained, posted, and broke things — shaping everything from Random Drops to the age-verification flow.' },
  { when: 'Launching November', what: 'Public launch across Kenya: gyms, verified trainers, live sessions, and the buddy system — free at the core.' },
  { when: 'What\'s next', what: 'M-Pesa top-ups, offline-lite mode, SMS nudges, Swahili, wearables — see the full roadmap on the landing page.' },
];

export default function About() {
  return (
    <div className="min-h-screen bg-buddy-black overflow-x-hidden">
      {/* ── HERO ── */}
      <header className="relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-b from-buddy-green/5 to-transparent pointer-events-none" />
        <div className="max-w-4xl mx-auto px-6 pt-20 pb-16 text-center relative z-10">
          <Link to="/" className="inline-flex items-center gap-2 text-sm text-buddy-text-secondary hover:text-buddy-text-primary transition-colors mb-10">
            <ArrowLeft size={16} /> Back to home
          </Link>
          <div className="flex justify-center mb-6"><Logo size="xl" /></div>
          <h1 className="font-display text-4xl sm:text-5xl font-extrabold text-white mb-6 leading-tight">
            We're building the app that makes<br />
            <span className="text-buddy-green">consistency social.</span>
          </h1>
          <p className="text-lg text-buddy-text-secondary max-w-2xl mx-auto leading-relaxed">
            BuddyUp pairs you with real accountability partners, live workouts, and communities
            that notice when you show up — and when you don't.
          </p>
        </div>
      </header>

      {/* ── STORY ── */}
      <section className="max-w-3xl mx-auto px-6 py-16">
        <h2 className="font-display text-3xl font-extrabold mb-8">The <span className="text-buddy-green">story</span></h2>
        <div className="space-y-6 text-buddy-text-secondary leading-relaxed">
          <p>
            Most fitness apps are built for the person who already loves training. They optimise
            for metrics, streaks, and photo dumps — and quietly assume you'll motivate yourself.
            That works until week three, when the alarm goes off and nobody would ever know if you
            stayed in bed.
          </p>
          <p>
            BuddyUp exists for that moment. Instead of another dashboard, it gives you people: a
            buddy matched to your goals and schedule, a gym community that counts on you, live
            sessions where showing up is the whole point, and trainers who are verified before they
            ever take a shilling.
          </p>
          <p>
            We're building it from Nairobi, for African fitness communities first — then the world.
            The core will always be free, because accountability shouldn't be a premium feature.
          </p>
        </div>
      </section>

      {/* ── VALUES ── */}
      <section className="max-w-6xl mx-auto px-6 py-16">
        <h2 className="font-display text-3xl font-extrabold text-center mb-16">What we <span className="text-buddy-green">believe</span></h2>
        <div className="grid md:grid-cols-3 gap-6 min-w-0 [&>div]:min-w-0">
          {values.map(({ icon: Icon, title, desc }) => (
            <div key={title} className="bg-buddy-surface rounded-2xl p-6">
              <Icon size={28} className="text-buddy-green mb-4" />
              <h3 className="font-heading text-lg font-semibold mb-2">{title}</h3>
              <p className="text-sm text-buddy-text-secondary">{desc}</p>
            </div>
          ))}
        </div>
      </section>

      {/* ── MILESTONES ── */}
      <section className="max-w-3xl mx-auto px-6 py-16">
        <h2 className="font-display text-3xl font-extrabold mb-8">Where we're <span className="text-buddy-green">headed</span></h2>
        <div>
          {milestones.map(({ when, what }, i) => (
            <div key={when} className="flex gap-6">
              <div className="flex flex-col items-center">
                <div className="w-3 h-3 rounded-full bg-buddy-green flex-shrink-0 mt-1.5" />
                {i < milestones.length - 1 && <div className="w-px flex-1 bg-buddy-surface my-1" />}
              </div>
              <div className="pb-10 min-w-0">
                <h3 className="font-heading font-semibold mb-1">{when}</h3>
                <p className="text-sm text-buddy-text-secondary leading-relaxed">{what}</p>
              </div>
            </div>
          ))}
        </div>
        <div className="mt-4">
          <Link to="/">
            <Button variant="outline" className="gap-2">See the full roadmap</Button>
          </Link>
        </div>
      </section>

      {/* ── CONTACT ── */}
      <section className="max-w-3xl mx-auto px-6 pb-24">
        <div className="bg-buddy-surface rounded-2xl p-8">
          <h2 className="font-heading text-xl font-semibold mb-6">Get in touch</h2>
          <div className="grid sm:grid-cols-2 gap-4 text-sm">
            <div>
              <p className="text-buddy-text-secondary mb-1">General &amp; press</p>
              <a href={mailtoLink('info')} className="text-buddy-green hover:underline break-all">{CONTACT_EMAILS.info}</a>
            </div>
            <div>
              <p className="text-buddy-text-secondary mb-1">Support</p>
              <a href={mailtoLink('support')} className="text-buddy-green hover:underline break-all">{CONTACT_EMAILS.support}</a>
            </div>
            <div>
              <p className="text-buddy-text-secondary mb-1">Safety &amp; reports</p>
              <a href={mailtoLink('report')} className="text-buddy-green hover:underline break-all">{CONTACT_EMAILS.report}</a>
            </div>
            <div>
              <p className="text-buddy-text-secondary mb-1">Sponsorships</p>
              <a href={mailtoLink('sponsor')} className="text-buddy-green hover:underline break-all">{CONTACT_EMAILS.sponsor}</a>
            </div>
          </div>
          <div className="mt-8">
            <Link to="/signup">
              <Button size="lg" className="w-full sm:w-auto">Join the waiting list</Button>
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}
