import { useState } from 'react';
import { Link } from 'react-router-dom';
import { Check, Star, ChevronRight, Play, Download, Users, Radio, Dumbbell, Handshake, Flame, Search, User, GraduationCap, Utensils, Newspaper, Smartphone } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Avatar } from '@/components/ui/Avatar';
import { Logo } from '@/components/ui/Logo';

const features = {
  live: {
    title: 'Live Sessions',
    desc: 'Drop into live HIIT, yoga, or strength sessions anytime. Host your own or join a trainer.',
    points: ['Open Sweat — public, free lives', 'Buddy Circle — private group sessions', 'Random Drop — surprise match!', 'Gym scheduled lives with RSVP'],
  },
  gyms: {
    title: 'Gyms',
    desc: 'Create or join fitness communities with built-in live schedules, member feeds, and subscription tiers.',
    points: ['Public, private, or secret gyms', 'Trainer & moderator roles', 'Gym wallet with revenue splits', 'Weekly live schedule'],
  },
  trainers: {
    title: 'Trainers',
    desc: 'Find certified trainers and health practitioners. Book 1:1 sessions, buy programmes, and get verified.',
    points: ['Verified badges & reviews', 'Session booking & escrow', 'Async training programmes', 'Availability calendar'],
  },
  mealPlans: {
    title: 'Meal Plans',
    desc: 'Purchase meal plans from verified nutritionists. AI-personalised to your goals and preferences.',
    points: ['11 diet types available', 'AI adjusts portions & macros', 'Shopping list included', 'Verified nutritionist badges'],
  },
  buddyFeed: {
    title: 'Buddy Feed',
    desc: 'Share workouts, meals, progress, and moments with your fitness family.',
    points: ['7 post types to share', 'Fitness-themed reactions', 'Workout & meal log cards', 'Progress transformations'],
  },
};

const testimonials = [
  { name: 'Sarah K.', goal: 'Lost 15kg in 6 months', quote: 'BuddyUp changed everything. Having a buddy to check in with daily kept me accountable like nothing else could.', avatar: '' },
  { name: 'James M.', goal: 'Ran first marathon', quote: 'The Random Drop feature is genius. I\'ve met 12 new running buddies and we train together every week now.', avatar: '' },
  { name: 'Coach Grace', goal: 'Built 100+ client community', quote: 'As a trainer, BuddyUp\'s gym feature let me build a thriving community. The live scheduling tools are incredible.', avatar: '' },
  { name: 'Aisha O.', goal: 'Reversed pre-diabetes', quote: 'The meal plans from verified nutritionists, combined with AI personalisation, completely transformed how I eat.', avatar: '' },
];

const pricingTiers = [
  {
    name: 'Free',
    price: '$0',
    period: '/month',
    color: 'border-buddy-surface',
    features: ['Buddy system', 'Basic feed & posts', 'Join public gyms', 'Open Sweat lives', 'Reactions & comments', '5 artifacts/month'],
    cta: 'Get Started Free',
  },
  {
    name: 'Premium',
    price: '$4.99',
    period: '/month',
    color: 'border-buddy-green',
    popular: true,
    features: ['Everything in Free', 'Create private gyms', 'Full live suite', 'Priority feed ranking', 'Custom workout plans', '50 artifacts/month', 'Analytics dashboard'],
    cta: 'Go Premium',
  },
  {
    name: 'Trainer Pro',
    price: '$14.99',
    period: '/month',
    color: 'border-buddy-electric',
    features: ['Everything in Premium', 'Verified trainer badge', 'Session booking & escrow', 'Sell programmes', 'Advanced analytics', 'Revenue dashboard', '200 artifacts/month'],
    cta: 'Become a Pro',
  },
];

export default function Landing() {
  const [activeFeature, setActiveFeature] = useState('live');

  return (
    <div className="min-h-screen bg-buddy-black overflow-x-hidden">
      {/* ── 1. HERO ── */}
      <header className="relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-b from-buddy-green/5 to-transparent pointer-events-none" />
        <div className="max-w-6xl mx-auto px-6 pt-24 pb-36 text-center relative z-10">
          <div className="flex justify-center mb-6">
            <Logo size="xl" className="mx-auto" />
          </div>
          <h1 className="font-display text-5xl sm:text-6xl md:text-7xl font-extrabold text-white mb-6 leading-tight">
            Find your<br />
            <span className="text-buddy-green">fitness family.</span>
          </h1>
          <p className="text-lg sm:text-xl text-buddy-text-secondary max-w-2xl mx-auto mb-10 leading-relaxed">
            Train with buddies, join live workouts, eat better, and stay accountable — all in one place.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link to="/signup">
              <Button size="lg" className="text-base px-10 py-4 rounded-2xl shadow-lg shadow-buddy-green/25">
                Get Started — It's Free
              </Button>
            </Link>
            <a href="#how-it-works">
              <Button size="lg" variant="outline" className="text-base px-10 py-4 rounded-2xl gap-2">
                <Play size={18} /> Watch how it works
              </Button>
            </a>
          </div>
          <p className="mt-8 text-sm text-buddy-text-secondary">
            Join 500,000+ people already training together
          </p>
        </div>
      </header>

      {/* ── 2. VALUE PROPS ── */}
      <section className="max-w-6xl mx-auto px-6 py-24">
        <h2 className="font-display text-3xl font-extrabold text-center mb-16">Why <span className="text-buddy-green">BuddyUp</span>?</h2>
        <div className="grid md:grid-cols-3 gap-8">
          {[
            { icon: Handshake, title: 'Find Your Buddy', desc: 'Connect with people who match your fitness level, goals, and schedule.' },
            { icon: Radio, title: 'Live Workouts, Anytime', desc: 'Drop into a live HIIT class, run a yoga session, or join a random workout at any time.' },
            { icon: Dumbbell, title: 'Gyms Built Around You', desc: 'Create or join communities that keep you accountable and motivated.' },
          ].map(({ icon: Icon, title, desc }) => (
            <Card key={title} className="p-8 text-center hover:bg-buddy-surface-raised transition-colors">
              <div className="mb-6 flex justify-center"><Icon size={48} className="text-buddy-green" /></div>
              <h3 className="font-heading text-xl font-semibold mb-3">{title}</h3>
              <p className="text-buddy-text-secondary">{desc}</p>
            </Card>
          ))}
        </div>
      </section>

      {/* ── 3. HOW IT WORKS ── */}
      <section id="how-it-works" className="max-w-6xl mx-auto px-6 py-24">
        <h2 className="font-display text-3xl font-extrabold text-center mb-4">How <span className="text-buddy-green">Buddying Up</span> Works</h2>
        <p className="text-buddy-text-secondary text-center mb-16 max-w-xl mx-auto">Five simple steps to your fitness family.</p>
        <div className="grid md:grid-cols-5 gap-6">
          {[
            { step: 1, icon: User, title: 'Create Profile', desc: 'Set your goals, activity level, and preferences.' },
            { step: 2, icon: Search, title: 'Find Buddies', desc: 'Discover people who match your vibe and fitness goals.' },
            { step: 3, icon: Radio, title: 'Train Together', desc: 'Join live sessions or Random Drops with your buddies.' },
            { step: 4, icon: Dumbbell, title: 'Build Your Gym', desc: 'Create a community around your fitness passion.' },
            { step: 5, icon: Flame, title: 'Stay Accountable', desc: 'Track streaks, share progress, and cheer each other on.' },
          ].map(({ step, icon: Icon, title, desc }) => (
            <div key={step} className="text-center">
              <div className="w-16 h-16 rounded-2xl bg-buddy-green/10 flex items-center justify-center mx-auto mb-4 relative">
                <Icon size={24} className="text-buddy-green" />
                <span className="absolute -top-2 -right-2 w-6 h-6 rounded-full bg-buddy-green text-buddy-black font-mono font-bold text-xs flex items-center justify-center">{step}</span>
              </div>
              <h4 className="font-heading font-semibold text-sm mb-1">{title}</h4>
              <p className="text-xs text-buddy-text-secondary">{desc}</p>
            </div>
          ))}
        </div>
      </section>

      {/* ── 4. FEATURE SHOWCASE ── */}
      <section className="max-w-6xl mx-auto px-6 py-24">
        <h2 className="font-display text-3xl font-extrabold text-center mb-4">Everything in <span className="text-buddy-green">One Place</span></h2>
        <p className="text-buddy-text-secondary text-center mb-12">All the tools you need to reach your fitness goals.</p>

        <div className="flex overflow-x-auto gap-2 mb-8 scrollbar-hide justify-center">
          {['live', 'gyms', 'trainers', 'mealPlans', 'buddyFeed'].map((key) => {
            const tabIcons: Record<string, React.ReactNode> = {
              live: <Radio size={16} />,
              gyms: <Dumbbell size={16} />,
              trainers: <GraduationCap size={16} />,
              mealPlans: <Utensils size={16} />,
              buddyFeed: <Newspaper size={16} />,
            };
            return (
              <button key={key} onClick={() => setActiveFeature(key)}
                className={`px-5 py-2.5 rounded-full text-sm font-medium whitespace-nowrap transition-colors flex items-center gap-2 ${
                  activeFeature === key ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary hover:text-buddy-text-primary border border-buddy-surface'
                }`}>{tabIcons[key]} {features[key as keyof typeof features].title}</button>
            );
          })}
        </div>

        <Card className="p-8 md:p-12">
          <div className="grid md:grid-cols-2 gap-8 items-center">
            <div>
              <h3 className="font-heading text-2xl font-semibold mb-4">{features[activeFeature as keyof typeof features].title}</h3>
              <p className="text-buddy-text-secondary mb-6">{features[activeFeature as keyof typeof features].desc}</p>
              <ul className="space-y-3">
                {features[activeFeature as keyof typeof features].points.map((point) => (
                  <li key={point} className="flex items-start gap-2 text-sm">
                    <Check size={16} className="text-buddy-green mt-0.5 flex-shrink-0" />
                    <span>{point}</span>
                  </li>
                ))}
              </ul>
            </div>
            <div className="bg-buddy-surface rounded-2xl p-8 flex items-center justify-center">
              {(() => {
                const featureIcons: Record<string, React.ReactNode> = {
                  live: <Radio size={96} className="text-buddy-green" />,
                  gyms: <Dumbbell size={96} className="text-buddy-green" />,
                  trainers: <GraduationCap size={96} className="text-buddy-green" />,
                  mealPlans: <Utensils size={96} className="text-buddy-green" />,
                  buddyFeed: <Newspaper size={96} className="text-buddy-green" />,
                };
                return featureIcons[activeFeature];
              })()}
            </div>
          </div>
        </Card>
      </section>

      {/* ── 5. TESTIMONIALS ── */}
      <section className="max-w-6xl mx-auto px-6 py-24">
        <h2 className="font-display text-3xl font-extrabold text-center mb-4">What Our <span className="text-buddy-green">Community</span> Says</h2>
        <p className="text-buddy-text-secondary text-center mb-16">Real people. Real results.</p>
        <div className="grid md:grid-cols-2 gap-6">
          {testimonials.map(({ name, goal, quote, avatar }) => (
            <Card key={name} className="p-6 bg-buddy-surface-raised">
              <div className="flex gap-1 mb-3">
                {Array.from({ length: 5 }).map((_, i) => <Star key={i} size={14} className="text-buddy-gold fill-buddy-gold" />)}
              </div>
              <p className="text-sm text-buddy-text-primary mb-4 italic leading-relaxed">"{quote}"</p>
              <div className="flex items-center gap-3">
                <Avatar src={avatar} alt={name} size="md" />
                <div>
                  <p className="text-sm font-medium">{name}</p>
                  <p className="text-xs text-buddy-green">{goal}</p>
                </div>
              </div>
            </Card>
          ))}
        </div>
      </section>

      {/* ── 6. TRAINERS CTA ── */}
      <section className="bg-buddy-surface py-24">
        <div className="max-w-4xl mx-auto px-6 text-center">
          <GraduationCap size={48} className="text-buddy-electric mx-auto" />
          <h2 className="font-display text-3xl font-extrabold mt-6 mb-4">Are you a trainer or health professional?</h2>
          <p className="text-buddy-text-secondary max-w-xl mx-auto mb-8">
            BuddyUp helps you reach clients, run live sessions, and build your fitness community. Verified profiles. Real revenue.
          </p>
          <Link to="/signup">
            <Button size="lg" variant="secondary" className="gap-2">Join as a Trainer <ChevronRight size={18} /></Button>
          </Link>
        </div>
      </section>

      {/* ── 7. GYM FOUNDERS CTA ── */}
      <section className="py-24">
        <div className="max-w-4xl mx-auto px-6 text-center">
          <Dumbbell size={48} className="text-buddy-green mx-auto" />
          <h2 className="font-display text-3xl font-extrabold mt-6 mb-4">Start your own gym on BuddyUp</h2>
          <p className="text-buddy-text-secondary max-w-xl mx-auto mb-8">
            Build a paid or free fitness community. Set a schedule. Grow your tribe.
          </p>
          <Link to="/signup">
            <Button size="lg" className="gap-2">Create a Gym <Dumbbell size={18} /></Button>
          </Link>
        </div>
      </section>

      {/* ── 8. PRICING ── */}
      <section className="max-w-5xl mx-auto px-6 py-24">
        <h2 className="font-display text-3xl font-extrabold text-center mb-4">Simple <span className="text-buddy-green">Pricing</span></h2>
        <p className="text-buddy-text-secondary text-center mb-16">Start free. Upgrade when you're ready.</p>
        <div className="grid md:grid-cols-3 gap-6">
          {pricingTiers.map((tier) => (
            <Card key={tier.name}
              className={`p-8 relative ${tier.popular ? `border-2 ${tier.color} bg-buddy-surface-raised` : 'bg-buddy-surface'}`}
            >
              {tier.popular && (
                <div className="absolute -top-3 left-1/2 -translate-x-1/2 bg-buddy-green text-buddy-black text-xs font-bold px-4 py-1 rounded-full">Most Popular</div>
              )}
              <h3 className="font-heading text-xl font-semibold">{tier.name}</h3>
              <div className="mt-4 mb-6">
                <span className="font-display text-4xl font-extrabold">{tier.price}</span>
                <span className="text-buddy-text-secondary text-sm">{tier.period}</span>
              </div>
              <ul className="space-y-3 mb-8">
                {tier.features.map((f) => (
                  <li key={f} className="flex items-start gap-2 text-sm"><Check size={14} className="text-buddy-green mt-0.5 flex-shrink-0" />{f}</li>
                ))}
              </ul>
              <Link to="/signup">
                <Button variant={tier.popular ? 'primary' : 'outline'} className="w-full">{tier.cta}</Button>
              </Link>
            </Card>
          ))}
        </div>
      </section>

      {/* ── 9. APP DOWNLOAD ── */}
      <section className="bg-buddy-surface py-24">
        <div className="max-w-4xl mx-auto px-6 text-center">
          <Download size={48} className="mx-auto text-buddy-green mb-6" />
          <h2 className="font-display text-3xl font-extrabold mb-4">Train anytime, anywhere</h2>
          <p className="text-buddy-text-secondary mb-8">Get the BuddyUp app on your phone.</p>
          <div className="flex gap-4 justify-center flex-wrap">
            <a href="#" className="inline-flex items-center gap-3 bg-buddy-black rounded-2xl px-6 py-4 hover:bg-buddy-surface-raised transition-colors">
              <Smartphone size={24} className="text-buddy-text-secondary" />
              <div className="text-left"><p className="text-xs text-buddy-text-secondary">Download on the</p><p className="font-heading font-semibold">App Store</p></div>
            </a>
            <a href="#" className="inline-flex items-center gap-3 bg-buddy-black rounded-2xl px-6 py-4 hover:bg-buddy-surface-raised transition-colors">
              <Play size={24} className="text-buddy-text-secondary" />
              <div className="text-left"><p className="text-xs text-buddy-text-secondary">Get it on</p><p className="font-heading font-semibold">Google Play</p></div>
            </a>
          </div>
        </div>
      </section>

      {/* ── 10. FOOTER ── */}
      <footer className="border-t border-buddy-surface py-16">
        <div className="max-w-6xl mx-auto px-6">
          <div className="grid md:grid-cols-4 gap-8 mb-12">
            <div>
              <Logo size="md" className="mb-2" />
              <p className="text-sm text-buddy-text-secondary">Find your fitness family.</p>
            </div>
            <div>
              <h4 className="font-heading font-semibold text-sm mb-4">Features</h4>
              <div className="space-y-2 text-sm text-buddy-text-secondary">
                <p>Live Sessions</p><p>Gyms</p><p>Trainers</p><p>Meal Plans</p><p>Marketplace</p>
              </div>
            </div>
            <div>
              <h4 className="font-heading font-semibold text-sm mb-4">For</h4>
              <div className="space-y-2 text-sm text-buddy-text-secondary">
                <p>Regular Users</p><p>Trainers</p><p>Practitioners</p><p>Gym Owners</p><p>Brands</p>
              </div>
            </div>
            <div>
              <h4 className="font-heading font-semibold text-sm mb-4">Company</h4>
              <div className="space-y-2 text-sm text-buddy-text-secondary">
                <Link to="/terms" className="block hover:text-buddy-text-primary">Terms of Service</Link>
                <Link to="/privacy" className="block hover:text-buddy-text-primary">Privacy Policy</Link>
                <Link to="/community-guidelines" className="block hover:text-buddy-text-primary">Community Guidelines</Link>
                <Link to="/cookie-policy" className="block hover:text-buddy-text-primary">Cookie Policy</Link>
                <p className="hover:text-buddy-text-primary cursor-pointer">Blog</p>
                <p className="hover:text-buddy-text-primary cursor-pointer">Careers</p>
                <p className="hover:text-buddy-text-primary cursor-pointer">Help</p>
              </div>
            </div>
          </div>
          <div className="border-t border-buddy-surface pt-8 flex flex-col md:flex-row justify-between items-center gap-4">
            <p className="text-xs text-buddy-text-secondary">&copy; 2025 BuddyUp. All rights reserved.</p>
            <div className="flex gap-6 text-sm text-buddy-text-secondary">
              <span className="hover:text-buddy-text-primary cursor-pointer">Instagram</span>
              <span className="hover:text-buddy-text-primary cursor-pointer">TikTok</span>
              <span className="hover:text-buddy-text-primary cursor-pointer">YouTube</span>
              <span className="hover:text-buddy-text-primary cursor-pointer">Twitter/X</span>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
