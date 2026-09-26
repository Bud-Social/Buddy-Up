import { useState, useEffect, useRef } from 'react';
import { Link } from 'react-router-dom';
import { Check, ChevronRight, Play, Download, Radio, Dumbbell, Handshake, Flame, Search, User, GraduationCap, Utensils, Newspaper, Smartphone, Monitor, Heart, ClipboardList, Globe, HeartPulse, Sparkles, Activity, CalendarDays, BookOpen, Building2, BellRing, Briefcase, Users, UsersRound, MessageCircle, QrCode, Watch, Trophy, Languages, TrendingUp } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Logo } from '@/components/ui/Logo';
import { useDeviceType } from '@/hooks/useDeviceType';
import { isReducedMotionEnabled } from '@/lib/reducedMotion';
import { APP_URL } from '@/config/downloads';
import { FUNDRAISER_URL, PLEDGE_FORM_URL, GYM_SUITE_FORM_URL, TRAINER_INTAKE_FORM_URL, PARTNERSHIP_FORM_URL, INVESTOR_FORM_URL } from '@/config/support';
import { CONTACT_EMAILS, mailtoLink } from '@/config/contact';
import { Navbar } from '@/components/landing/Navbar';
import { SupportDialog } from '@/components/features/support/SupportDialog';
import { WaitlistForm, requestWaitlistInterest } from '@/components/features/support/WaitlistForm';
import { WaitlistModal } from '@/components/features/support/WaitlistModal';
import type { WaitlistInterest } from '@/api/waitlist';
import { SuggestionForm } from '@/components/features/support/SuggestionForm';
import { ContactForm } from '@/components/features/support/ContactForm';
import { Modal } from '@/components/ui/Modal';
import { Typewriter } from '@/components/features/landing/Typewriter';
import { X } from 'lucide-react';

const features = {
  live: {
    title: 'Live Sessions',
    desc: 'Drop into live HIIT, yoga, or strength sessions anytime. Host your own or join a trainer.',
    points: ['Open Sweat — public, free lives', 'Buddy Circle — private group sessions', 'Random Drop — surprise match!', 'Gym scheduled lives with RSVP'],
  },
  gyms: {
    title: 'Gyms',
    desc: 'Discover nearby, virtual, and hybrid gyms — or register your own fitness community with live schedules, member feeds, and subscription tiers.',
    points: ['Nearby, virtual & hybrid discovery', 'Public, private, or secret gyms', 'Trainer & moderator roles', 'Gym wallet with revenue splits', 'Verified badges & member reviews'],
  },
  trainers: {
    title: 'Trainers',
    desc: 'Find certified trainers and health practitioners — mobile, near you, virtual, verified, or affiliated with your gym. Book 1:1 sessions, buy programmes, and train with confidence.',
    points: ['Mobile, nearby & virtual pros', 'Verified badges & reviews', 'Gym-affiliated trainers', 'Session booking & escrow', 'Async training programmes', 'Availability calendar'],
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
  analytics: {
    title: 'Activity Analytics',
    desc: 'Track every run, walk, hike, and ride with GPS — plus strength, cardio, HIIT, and yoga sessions. Distances, paces, streaks, and progress reports in one dashboard.',
    points: ['GPS tracking for runs, walks, hikes & rides', 'Strength, cardio, HIIT & yoga logs', 'Streaks that keep you honest', 'Shareable progress reports'],
  },
  events: {
    title: 'Events',
    desc: 'Find sunrise runs, hybrid competitions, workshops, and community meetups — in person, virtual, or both. Grab a ticket and show up.',
    points: ['In-person, virtual & hybrid events', 'Tickets with QR check-in', 'Gym & trainer-hosted', 'Free and paid entry'],
  },
  programmes: {
    title: 'Training Programmes',
    desc: 'Follow structured multi-week programmes from verified trainers — strength blocks, run plans, and conditioning, with progress tracking built in.',
    points: ['Multi-week structured plans', 'Verified trainer authors', 'Progress & enrolment tracking', 'Bundle with 1:1 sessions'],
  },
};

/** Lifetime goals — the mission section that replaced beta testimonials. */
const lifetimeGoals = [
  { icon: Handshake, title: 'Help a million people find their fitness family', desc: 'Accountability works when it comes from real people who know your name. We want a million BuddyUp Fit members who check in on each other daily.' },
  { icon: Heart, title: 'Keep the core free, forever', desc: 'The buddy system, public gyms, and open live sessions never go behind a paywall. Premium buys extras — never the essentials.' },
  { icon: Radio, title: '100,000 live sessions every month', desc: 'From Nairobi living rooms to global studios — live workouts running in every time zone, hosted by real people.' },
  { icon: Globe, title: 'Africa-first, world-ready', desc: 'Built in Nairobi, launched for Kenya first — M-Pesa payments, low-data mode, Swahili — then taken to the world.' },
  { icon: GraduationCap, title: 'A thriving verified-trainer economy', desc: 'Thousands of certified trainers and nutritionists earning a sustainable living from verified profiles, sessions, and programmes.' },
  { icon: Dumbbell, title: 'Gyms in every format', desc: 'Physical gyms around the corner, virtual gyms in your living room, and hybrid gyms doing both — all with verified badges and member reviews.' },
  { icon: CalendarDays, title: 'Events & programmes for everyone', desc: 'From weekend fun runs to multi-week training blocks — community events and structured programmes that keep the whole fitness family moving.' },
  { icon: HeartPulse, title: 'Health outcomes, not vanity metrics', desc: 'We measure success in streaks kept, consistency built, and wellbeing improved — not just before-and-after photos.' },
];

/**
 * Roadmap: real scenarios our community keeps raising that BuddyUp Fit does not
 * address yet. Shipped honestly as "planned" — no fake screenshots.
 */
const plannedFeatures = [
  { horizon: 'Near', icon: Smartphone, title: 'Low-data & offline-lite mode', desc: 'A stripped-down experience that survives patchy connectivity — train, log your session offline, sync when you\'re back.' },
  { horizon: 'Near', icon: Users, title: 'Schedule-compatible buddy matching', desc: 'Buddy suggestions that fit around your work hours and commute — not just your fitness level.' },
  { horizon: 'Soon', icon: MessageCircle, title: 'SMS & WhatsApp delivery for nudges', desc: 'Session reminders, streak nudges, and accountability pings already live in-app — coming to SMS and WhatsApp, where you actually read messages.' },
  { horizon: 'Soon', icon: QrCode, title: 'Gym QR check-ins', desc: 'Scan in at partner gyms, prove attendance, and let your streaks count real-world visits.' },
  { horizon: 'Soon', icon: Watch, title: 'Wearable & health-app sync', desc: 'Pull steps, heart rate, and sleep from your watch into your progress feed automatically.' },
  { horizon: 'Soon', icon: Building2, title: 'Corporate awareness packages', desc: 'Team step-count challenges, branded gym spaces, sponsored events, and workplace wellness campaigns for companies that want healthier teams.' },
  { horizon: 'Soon', icon: UsersRound, title: 'Group & family access packages', desc: 'One plan for the whole household or crew — shared memberships, family challenges, and group streaks that keep everyone accountable.' },
  { horizon: 'Soon', icon: Trophy, title: 'Streak rewards & seasonal leagues', desc: 'Holiday leagues, community challenges, and rewards you can actually redeem — earned through consistency, not spending.' },
  { horizon: 'Later', icon: Languages, title: 'Multilanguage interface', desc: 'The whole app in your language — starting with Swahili and expanding from there.' },
];

const horizonStyles: Record<string, string> = {
  Near: 'text-buddy-text-secondary border-buddy-surface-raised bg-buddy-surface-raised/40',
  Soon: 'text-buddy-text-secondary border-buddy-surface-raised bg-buddy-surface-raised/40',
  Later: 'text-buddy-text-secondary border-buddy-surface-raised bg-buddy-surface-raised/40',
};

// Horizon is encoded once, on the icon chip — never as a full-card tint.
const horizonChip: Record<string, string> = {
  Near: 'bg-buddy-green/10',
  Soon: 'bg-buddy-gold/10',
  Later: 'bg-buddy-surface-raised',
};

const horizonChipIcon: Record<string, string> = {
  Near: 'text-buddy-green',
  Soon: 'text-buddy-gold',
  Later: 'text-buddy-text-secondary',
};


interface PricingTier {
  name: string;
  price: string;
  period: string;
  color: string;
  popular?: boolean;
  features: string[];
  cta: string;
  /** Which waitlist interest tab the CTA preselects (popped instead of signup). */
  interest: WaitlistInterest;
}

const pricingTiers: PricingTier[] = [
  {
    name: 'Free',
    price: '$0',
    period: '/month',
    color: 'border-buddy-surface',
    features: ['Buddy system', 'Basic feed & posts', 'Join public gyms', 'Open Sweat lives', 'Reactions & comments', '5 artifacts/month'],
    cta: 'Join the Waiting List — Free',
    interest: 'user',
  },
  {
    name: 'Premium',
    price: '$4.99',
    period: '/month',
    color: 'border-buddy-green',
    popular: true,
    features: ['Everything in Free', 'Create private gyms', 'Full live suite', 'Priority feed ranking', 'Custom workout plans', '50 artifacts/month', 'Analytics dashboard'],
    cta: 'Join the Waiting List — Premium',
    interest: 'user',
  },
  {
    name: 'Trainer Pro',
    price: '$14.99',
    period: '/month',
    color: 'border-buddy-electric',
    features: ['Everything in Premium', 'Verified trainer badge', 'Session booking & escrow', 'Sell programmes', 'Advanced analytics', 'Revenue dashboard', '200 artifacts/month'],
    cta: 'Join the Waiting List — Trainer Pro',
    interest: 'trainer',
  },
];

export default function Landing() {
  const [activeFeature, setActiveFeature] = useState('live');
  /** Auto-rotation of the feature showcase. Stops for good once the user
   * picks a tab manually; pauses while hovered/focused. */
  const [autoRotate, setAutoRotate] = useState(true);
  const [featurePaused, setFeaturePaused] = useState(false);
  const [supportOpen, setSupportOpen] = useState(false);
  const [heroWaitlistOpen, setHeroWaitlistOpen] = useState(false);
  const [suggestOpen, setSuggestOpen] = useState(false);
  const [installWaitlistOpen, setInstallWaitlistOpen] = useState(false);
  /** Popup waitlist for the "Get Started"-family CTAs — the signup flow is
   * closed prelaunch, so these buttons pop the waiting list instead. */
  const [waitlistModal, setWaitlistModal] = useState<{ open: boolean; interest: WaitlistInterest; tier?: string }>({ open: false, interest: 'user' });
  const openWaitlist = (interest: WaitlistInterest = 'user', tier?: string) => setWaitlistModal({ open: true, interest, tier });
  const closeWaitlist = () => setWaitlistModal((m) => ({ ...m, open: false }));
  const { isMobile, isTablet, isDesktop, os } = useDeviceType();
  const [canInstall, setCanInstall] = useState(false);
  const [isInstalled, setIsInstalled] = useState(false);
  const deferredPrompt = useRef<{ prompt: () => void } | null>(null);

  const installPwa = async () => {
    const prompt = deferredPrompt.current;
    if (prompt) {
      prompt.prompt();
      deferredPrompt.current = null;
      setCanInstall(false);
    }
  };

  useEffect(() => {
    const promptHandler = (e: Event) => {
      e.preventDefault();
      deferredPrompt.current = e as unknown as { prompt: () => void };
      setCanInstall(true);
    };
    const installedHandler = () => {
      setIsInstalled(true);
      setCanInstall(false);
      deferredPrompt.current = null;
    };
    // Already running as the installed app (Android standalone or iOS home-screen).
    try {
      if (
        window.matchMedia('(display-mode: standalone)').matches
        || (window.navigator as unknown as { standalone?: boolean }).standalone === true
      ) {
        setIsInstalled(true);
      }
    } catch { /* matchMedia unavailable — ignore */ }
    window.addEventListener('beforeinstallprompt', promptHandler);
    window.addEventListener('appinstalled', installedHandler);
    return () => {
      window.removeEventListener('beforeinstallprompt', promptHandler);
      window.removeEventListener('appinstalled', installedHandler);
    };
  }, []);

  // Auto-rotate the "Everything in one place" tabs every 5s. Honours the
  // reduced-motion preference (device + app setting), pauses on hover/focus,
  // and stops permanently after a manual tab selection.
  useEffect(() => {
    if (!autoRotate || featurePaused) return;
    if (isReducedMotionEnabled()) return;
    try {
      if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
    } catch { /* matchMedia unavailable — continue */ }
    const order = ['live', 'gyms', 'trainers', 'analytics', 'events', 'programmes', 'mealPlans', 'buddyFeed'];
    const id = window.setInterval(() => {
      setActiveFeature((current) => order[(order.indexOf(current) + 1) % order.length]);
    }, 5000);
    return () => window.clearInterval(id);
  }, [autoRotate, featurePaused]);

  return (
    <div className="min-h-screen bg-buddy-black overflow-x-hidden">
      <Navbar />
      {/* ── 1. HERO ── */}
      <header className="relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-b from-buddy-green/5 to-transparent pointer-events-none" />
        <div className="max-w-6xl mx-auto px-6 pt-24 pb-36 text-center relative z-10">
          {/* Icon centred on its own line (nudged slightly right of true centre),
              wordmark centred beneath it. */}
          <div className="flex flex-col items-center gap-3 mb-4">
            <div className="translate-x-2 sm:translate-x-3">
              <Logo size="xl" type="icon" />
            </div>
            <span className="font-display font-extrabold text-5xl sm:text-6xl md:text-7xl leading-none">
              <span className="buddy-duo-swap">Buddy</span>
              <span className="buddy-duo-swap-rev">Up</span>
              <span className="text-buddy-green"> Fit</span>
            </span>
          </div>
          {/* Typewriter tagline sits on its own line below the logo lockup. */}
          <p className="font-mono text-buddy-green text-base sm:text-xl min-h-[1.5em] mb-2">
            <span className="sr-only">Buddy Up Fit (Bud). Your Bud is waiting. Find your fitness family.</span>
            <span aria-hidden="true">
              <Typewriter />
            </span>
          </p>
          <h1 className="font-display text-5xl sm:text-6xl md:text-7xl font-extrabold text-white mb-6 leading-tight">
            Find your<br />
            <span className="text-buddy-green">fitness family.</span>
          </h1>
          <p className="text-lg sm:text-xl text-buddy-text-secondary max-w-2xl mx-auto mb-10 leading-relaxed">
            Train with buddies, join live workouts, eat better, and stay accountable — all in one place.
          </p>
          <div className="w-full max-w-2xl mx-auto">
            {/* CTAs — collapse away when the waiting list form opens */}
            <div
              className={`grid transition-all duration-500 ease-out ${
                heroWaitlistOpen ? 'grid-rows-[0fr] opacity-0 pointer-events-none' : 'grid-rows-[1fr] opacity-100'
              }`}
              aria-hidden={heroWaitlistOpen}
            >
              <div className="overflow-hidden">
                <div className="flex flex-col sm:flex-row gap-4 justify-center py-1">
                  <Button
                    size="lg"
                    className="text-base px-10 py-4 rounded-2xl shadow-lg shadow-buddy-green/25"
                    onClick={() => setHeroWaitlistOpen(true)}
                  >
                    Join Waiting List — Launching November
                  </Button>
                  <a href="#how-it-works">
                    <Button size="lg" variant="outline" className="text-base px-10 py-4 rounded-2xl gap-2">
                      <Play size={18} /> Watch how it works
                    </Button>
                  </a>
                  <Button size="lg" variant="outline" className="text-base px-10 py-4 rounded-2xl" onClick={() => setSupportOpen(true)}>
                    Fund Us
                  </Button>
                </div>
              </div>
            </div>
            {/* Waiting list form — expands in place of the CTAs */}
            <div
              className={`grid transition-all duration-500 ease-out ${
                heroWaitlistOpen ? 'grid-rows-[1fr] opacity-100' : 'grid-rows-[0fr] opacity-0 pointer-events-none'
              }`}
              aria-hidden={!heroWaitlistOpen}
            >
              <div className="overflow-hidden">
                <Card className="p-6 sm:p-8 bg-buddy-surface text-left relative">
                  <button
                    type="button"
                    onClick={() => setHeroWaitlistOpen(false)}
                    aria-label="Close waiting list form"
                    className="absolute top-3 right-3 p-2 text-buddy-text-secondary hover:text-buddy-text-primary rounded-lg hover:bg-buddy-surface-raised transition-colors"
                  >
                    <X size={18} />
                  </button>
                  <WaitlistForm />
                </Card>
              </div>
            </div>
          </div>
          <p className="mt-8 text-sm text-buddy-text-secondary">
            Join 500,000+ people already training together
          </p>
        </div>
      </header>

      {/* ── 2. VALUE PROPS ── */}
      <section className="max-w-6xl mx-auto px-6 py-24">
        <h2 className="font-display text-3xl font-extrabold text-center mb-16">Why <span className="text-buddy-green">BuddyUp Fit</span>?</h2>
        <div className="grid md:grid-cols-3 gap-8 min-w-0 [&>div]:min-w-0">
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
      <section
        id="showcase"
        className="max-w-6xl mx-auto px-6 py-24 scroll-mt-16"
        onMouseEnter={() => setFeaturePaused(true)}
        onMouseLeave={() => setFeaturePaused(false)}
        onFocus={() => setFeaturePaused(true)}
        onBlur={() => setFeaturePaused(false)}
      >
        <h2 className="font-display text-3xl font-extrabold text-center mb-4">Everything in <span className="text-buddy-green">One Place</span></h2>
        <p className="text-buddy-text-secondary text-center mb-12">All the tools you need to reach your fitness goals.</p>

        <div className="flex flex-wrap sm:flex-nowrap sm:overflow-x-auto gap-2 mb-8 scrollbar-hide sm:justify-center justify-center px-2 [scroll-padding-left:0.5rem]">
          {['live', 'gyms', 'trainers', 'analytics', 'events', 'programmes', 'mealPlans', 'buddyFeed'].map((key) => {
            const tabIcons: Record<string, React.ReactNode> = {
              live: <Radio size={16} />,
              gyms: <Dumbbell size={16} />,
              trainers: <GraduationCap size={16} />,
              analytics: <Activity size={16} />,
              events: <CalendarDays size={16} />,
              programmes: <BookOpen size={16} />,
              mealPlans: <Utensils size={16} />,
              buddyFeed: <Newspaper size={16} />,
            };
            return (
              <button
                key={key}
                onClick={() => { setActiveFeature(key); setAutoRotate(false); }}
                aria-pressed={activeFeature === key}
                className={`px-5 py-2.5 rounded-full text-sm font-medium whitespace-nowrap transition-colors flex items-center gap-2 ${
                  activeFeature === key ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary hover:text-buddy-text-primary border border-buddy-surface'
                }`}
              >{tabIcons[key]} {features[key as keyof typeof features].title}</button>
            );
          })}
        </div>

        <Card className="p-6 sm:p-8 md:p-12 overflow-hidden">
          <div className="grid md:grid-cols-2 gap-8 items-center min-w-0">
            <div className="min-w-0">
              <h3 className="font-heading text-2xl font-semibold mb-4 break-words">{features[activeFeature as keyof typeof features].title}</h3>
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
                  analytics: <Activity size={96} className="text-buddy-green" />,
                  events: <CalendarDays size={96} className="text-buddy-green" />,
                  programmes: <BookOpen size={96} className="text-buddy-green" />,
                  mealPlans: <Utensils size={96} className="text-buddy-green" />,
                  buddyFeed: <Sparkles size={96} className="text-buddy-green" />,
                };
                return featureIcons[activeFeature];
              })()}
            </div>
          </div>
        </Card>
      </section>

      {/* ── 5. OUR MISSION + ROADMAP ── */}
      <section className="max-w-6xl mx-auto px-6 py-24">
        <h2 className="font-display text-3xl font-extrabold text-center mb-4">Our <span className="text-buddy-green">Mission</span></h2>
        <p className="text-buddy-text-secondary text-center mb-16 max-w-2xl mx-auto">
          BuddyUp Fit exists to make consistency social. These are the goals we're building towards.
        </p>
        <div className="grid md:grid-cols-3 gap-6 min-w-0 [&>div]:min-w-0">
          {lifetimeGoals.map(({ icon: Icon, title, desc }) => (
            <Card key={title} className="p-8 bg-buddy-surface-raised">
              <div className="mb-6 flex justify-center"><Icon size={48} className="text-buddy-green" /></div>
              <h3 className="font-heading text-xl font-semibold mb-3">{title}</h3>
              <p className="text-buddy-text-secondary">{desc}</p>
            </Card>
          ))}
        </div>
      </section>

      {/* ── 5b. ROADMAP (planned, not shipped) ── */}
      <section className="max-w-6xl mx-auto px-6 py-24">
        <h2 className="font-display text-3xl font-extrabold text-center mb-4">What's <span className="text-buddy-green">Coming Next</span></h2>
        <p className="text-buddy-text-secondary text-center mb-16 max-w-2xl mx-auto">
          Real requests from our community that we haven't built yet — shown honestly as planned, not shipped.
        </p>
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6 min-w-0 [&>div]:min-w-0">
          {plannedFeatures.map(({ title, horizon, desc, icon: Icon }) => (
            <Card key={title} className="p-6 bg-buddy-surface">
              <div className="flex items-center justify-between mb-4">
                <span className={`w-12 h-12 rounded-2xl flex items-center justify-center flex-shrink-0 ${horizonChip[horizon]}`}>
                  <Icon size={24} className={horizonChipIcon[horizon]} />
                </span>
                <span className={`text-[11px] font-semibold uppercase tracking-wide border rounded-full px-2.5 py-1 ${horizonStyles[horizon]}`}>
                  Planned · {horizon}
                </span>
              </div>
              <h3 className="font-heading text-lg font-semibold mb-2">{title}</h3>
              <p className="text-sm text-buddy-text-secondary">{desc}</p>
            </Card>
          ))}
        </div>
        <div className="text-center mt-12">
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Button
              variant="outline"
              size="lg"
              className="gap-2"
              onClick={() => setSuggestOpen((v) => !v)}
              aria-expanded={suggestOpen}
            >
              <Sparkles size={18} /> Suggest a feature
            </Button>
            <Button
              variant="outline"
              size="lg"
              className="gap-2"
              onClick={() => requestWaitlistInterest('corporate')}
            >
              <Briefcase size={18} /> Corporate waiting list
            </Button>
          </div>
          <p className="mt-3 text-sm text-buddy-text-secondary">
            Tell us what to build next — straight to the product team.
          </p>
        </div>
        <div
          className={`grid transition-all duration-500 ease-out ${
            suggestOpen ? 'grid-rows-[1fr] opacity-100 mt-8' : 'grid-rows-[0fr] opacity-0 pointer-events-none'
          }`}
          aria-hidden={!suggestOpen}
        >
          <div className="overflow-hidden">
            <Card className="p-6 sm:p-8 bg-buddy-surface text-left max-w-2xl mx-auto">
              <SuggestionForm />
            </Card>
          </div>
        </div>
      </section>

      {/* ── 6. TRAINERS CTA ── */}
      <section className="py-24">
        <div className="max-w-4xl mx-auto px-6 text-center">
          <GraduationCap size={48} className="text-buddy-green mx-auto" />
          <h2 className="font-display text-3xl font-extrabold mt-6 mb-4">Are you a trainer or health professional?</h2>
          <p className="text-buddy-text-secondary max-w-xl mx-auto mb-4">
            BuddyUp Fit helps you reach clients, run live sessions, and build your fitness community. Verified profiles. Real revenue.
          </p>
          <p className="text-sm text-buddy-text-secondary max-w-xl mx-auto mb-8">
            Train where your clients are — in person, online, or on the move. Already coaching at a
            gym? Bring your classes and clients with you. Prelaunch onboarding
            collects your intro video and credentials for verification.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Button size="lg" className="gap-2" onClick={() => openWaitlist('trainer', 'Trainer')}>
              Join as a Trainer <ChevronRight size={18} />
            </Button>
            {TRAINER_INTAKE_FORM_URL ? (
              <a href={TRAINER_INTAKE_FORM_URL} target="_blank" rel="noreferrer noopener">
                <Button size="lg" variant="outline" className="gap-2">Book a prelaunch slot</Button>
              </a>
            ) : (
              <Button size="lg" variant="outline" className="gap-2" onClick={() => openWaitlist('trainer', 'Trainer')}>
                Join the trainer waiting list
              </Button>
            )}
          </div>
        </div>
      </section>

      {/* ── 7. GYM FOUNDERS CTA ── */}
      <section className="py-24 border-t border-buddy-surface">
        <div className="max-w-4xl mx-auto px-6 text-center">
          <Building2 size={48} className="text-buddy-green mx-auto" />
          <h2 className="font-display text-3xl font-extrabold mt-6 mb-4">Run a gym? Bring it to BuddyUp Fit</h2>
          <p className="text-buddy-text-secondary max-w-xl mx-auto mb-4">
            Build a paid or free fitness community. Set a schedule. Grow your tribe.
          </p>
          <p className="text-sm text-buddy-text-secondary max-w-xl mx-auto mb-8">
            List your nearby physical space, run virtual classes, or do both as a hybrid gym —
            with verified badges and member reviews at launch. Gyms can also offload their
            coaches onto the platform, so your trainers keep earning between floor shifts.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Button size="lg" className="gap-2" onClick={() => openWaitlist('gym', 'Gym')}>
              Create a Gym <Dumbbell size={18} />
            </Button>
            {GYM_SUITE_FORM_URL ? (
              <a href={GYM_SUITE_FORM_URL} target="_blank" rel="noreferrer noopener">
                <Button size="lg" variant="outline" className="gap-2">Book a gym-suite slot</Button>
              </a>
            ) : (
              <Button size="lg" variant="outline" className="gap-2" onClick={() => openWaitlist('gym', 'Gym')}>
                Join the gym waiting list
              </Button>
            )}
          </div>
        </div>
      </section>

      {/* ── 8. PRICING ── */}
      <section className="max-w-5xl mx-auto px-6 py-24">
        <h2 className="font-display text-3xl font-extrabold text-center mb-4">Simple <span className="text-buddy-green">Pricing</span></h2>
        <p className="text-buddy-text-secondary text-center mb-3">Start free. Upgrade when you're ready.</p>
        <p className="text-center text-xs text-buddy-text-secondary mb-16">
          <span className="inline-block px-3 py-1 rounded-full bg-buddy-green/10 text-buddy-green font-semibold mr-2">Launching November</span>
          Prices shown are planned launch pricing — joining adds you to the waiting list.
        </p>
        <div className="grid md:grid-cols-3 gap-6 min-w-0 [&>div]:min-w-0">
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
              <Button variant={tier.popular ? 'primary' : 'outline'} className="w-full" onClick={() => openWaitlist(tier.interest, tier.name)}>
                {tier.cta}
              </Button>
            </Card>
          ))}
        </div>
        <p className="text-center text-sm text-buddy-text-secondary mt-10">
          Beat the launch rush —{' '}
          <a href="#waitlist" className="text-buddy-green hover:underline font-semibold">
            join the waiting list for the November launch
          </a>
          .
        </p>
      </section>

      {/* ── 9. APP DOWNLOAD ── */}
      <section className="bg-buddy-surface py-24">
        <div className="max-w-4xl mx-auto px-6 text-center">
          <Download size={48} className="mx-auto text-buddy-green mb-6" />
          <h2 className="font-display text-3xl font-extrabold mb-4">Train anytime, anywhere</h2>
          <p className="text-buddy-text-secondary mb-8">{isMobile || isTablet ? 'Get the BuddyUp Fit app on your phone.' : 'Get the BuddyUp Fit app on any device.'}</p>
          <div className="mb-8">
            <Button size="lg" variant="outline" className="gap-2" onClick={() => setInstallWaitlistOpen(true)}>
              <BellRing size={18} /> Notify me when the app is out
            </Button>
          </div>
          <div className="flex gap-4 justify-center flex-wrap">
            {(isMobile || isTablet) && (
              <div className="flex flex-col items-center gap-4 w-full max-w-md">
                {isInstalled ? (
                  <a href={APP_URL} className="inline-flex items-center gap-3 bg-buddy-green text-buddy-black rounded-2xl px-6 py-4 hover:brightness-110 transition-all w-full justify-center font-heading font-semibold">
                    <Smartphone size={24} />
                    <div className="text-left"><p className="text-xs opacity-70">Installed</p><p className="font-heading font-semibold">Open BuddyUp Fit app</p></div>
                  </a>
                ) : canInstall ? (
                  <button
                    type="button"
                    onClick={installPwa}
                    className="inline-flex items-center gap-3 bg-buddy-green text-buddy-black rounded-2xl px-6 py-4 hover:brightness-110 transition-all w-full justify-center"
                  >
                    <Download size={24} />
                    <div className="text-left"><p className="text-xs opacity-70">Free · under a minute</p><p className="font-heading font-semibold">Install BuddyUp Fit app</p></div>
                  </button>
                ) : os === 'ios' ? (
                  <Card className="p-5 bg-buddy-black text-left w-full">
                    <p className="font-heading font-semibold text-sm mb-2">Install in 3 taps</p>
                    <ol className="text-sm text-buddy-text-secondary space-y-1.5 list-decimal list-inside">
                      <li>Tap the <span className="text-buddy-text-primary font-medium">Share</span> button below</li>
                      <li>Choose <span className="text-buddy-text-primary font-medium">Add to Home Screen</span></li>
                      <li>Tap <span className="text-buddy-text-primary font-medium">Add</span> — find BuddyUp Fit on your home screen</li>
                    </ol>
                  </Card>
                ) : (
                  <Card className="p-5 bg-buddy-black text-left w-full">
                    <p className="font-heading font-semibold text-sm mb-2">Install in 3 taps</p>
                    <ol className="text-sm text-buddy-text-secondary space-y-1.5 list-decimal list-inside">
                      <li>Tap the <span className="text-buddy-text-primary font-medium">⋮ menu</span> (top right)</li>
                      <li>Choose <span className="text-buddy-text-primary font-medium">Install app</span> or <span className="text-buddy-text-primary font-medium">Add to Home screen</span></li>
                      <li>Confirm — find BuddyUp Fit on your home screen</li>
                    </ol>
                  </Card>
                )}
              </div>
            )}
            {isDesktop && (
              <div className="flex flex-col items-center gap-4 w-full max-w-md">
                <button
                  type="button"
                  onClick={installPwa}
                  disabled={!canInstall}
                  className="inline-flex items-center gap-3 bg-buddy-black rounded-2xl px-6 py-4 hover:bg-buddy-surface-raised transition-colors disabled:opacity-50 disabled:cursor-not-allowed w-full justify-center"
                >
                  <Monitor size={24} className="text-buddy-text-secondary" />
                  <div className="text-left"><p className="text-xs text-buddy-text-secondary">Desktop & PWA</p><p className="font-heading font-semibold">{canInstall ? 'Install BuddyUp Fit' : 'Open Web App'}</p></div>
                </button>
                {!canInstall && (
                  <a href={APP_URL} className="text-sm text-buddy-green hover:underline">Use the web app directly</a>
                )}
              </div>
            )}
          </div>
          {isDesktop && !canInstall && (
            <p className="text-xs text-buddy-text-secondary mt-6">
              On desktop you can install BuddyUp Fit as a PWA from your browser's address bar, or use it directly in the browser.
            </p>
          )}
        </div>
      </section>

      {/* ── 10. SUPPORT + WAITLIST ── */}
      <section id="waitlist" className="max-w-5xl mx-auto px-6 py-24 scroll-mt-16">
        <h2 className="font-display text-3xl font-extrabold text-center mb-4">
          Fuel the <span className="text-buddy-green">mission</span>
        </h2>
        <p className="text-buddy-text-secondary text-center mb-12 max-w-2xl mx-auto">
          BuddyUp Fit is free for everyone. Chip in, pledge funding, or join the waitlist to shape what ships next.
        </p>
        <div className="grid md:grid-cols-2 gap-6 min-w-0 [&>div]:min-w-0">
          <Card className="p-8 bg-buddy-surface flex flex-col">
            <h3 className="font-heading text-xl font-semibold mb-2">Support BuddyUp Fit</h3>
            <p className="text-sm text-buddy-text-secondary mb-6">
              Your contribution keeps the lights on and new features coming. Brands can
              partner with us to reach Kenya&apos;s fitness family.
            </p>
            <div className="flex flex-col gap-3 mt-auto">
              {FUNDRAISER_URL ? (
                <a
                  href={FUNDRAISER_URL}
                  target="_blank"
                  rel="noreferrer noopener"
                  className="flex items-start gap-3 rounded-2xl border border-buddy-surface-raised p-4 text-left hover:bg-buddy-surface-raised transition-colors"
                >
                  <span className="flex-shrink-0 w-10 h-10 rounded-full bg-buddy-green/15 flex items-center justify-center">
                    <Heart size={18} className="text-buddy-green" />
                  </span>
                  <span>
                    <span className="block font-heading font-semibold text-sm">Donate</span>
                    <span className="block text-xs text-buddy-text-secondary mt-0.5">
                      Chip in to keep BuddyUp Fit free for everyone.
                    </span>
                  </span>
                </a>
              ) : null}
              {PLEDGE_FORM_URL ? (
                <a
                  href={PLEDGE_FORM_URL}
                  target="_blank"
                  rel="noreferrer noopener"
                  className="flex items-start gap-3 rounded-2xl border border-buddy-surface-raised p-4 text-left hover:bg-buddy-surface-raised transition-colors"
                >
                  <span className="flex-shrink-0 w-10 h-10 rounded-full bg-buddy-green/15 flex items-center justify-center">
                    <ClipboardList size={18} className="text-buddy-green" />
                  </span>
                  <span>
                    <span className="block font-heading font-semibold text-sm">Pledge funding</span>
                    <span className="block text-xs text-buddy-text-secondary mt-0.5">
                      Pledge now — we&apos;ll be in touch about next steps.
                    </span>
                  </span>
                </a>
              ) : null}
              {PARTNERSHIP_FORM_URL ? (
                <a
                  href={PARTNERSHIP_FORM_URL}
                  target="_blank"
                  rel="noreferrer noopener"
                  className="flex items-start gap-3 rounded-2xl border border-buddy-surface-raised p-4 text-left hover:bg-buddy-surface-raised transition-colors"
                >
                  <span className="flex-shrink-0 w-10 h-10 rounded-full bg-buddy-green/15 flex items-center justify-center">
                    <Briefcase size={18} className="text-buddy-green" />
                  </span>
                  <span>
                    <span className="block font-heading font-semibold text-sm">Partnership proposal for brands</span>
                    <span className="block text-xs text-buddy-text-secondary mt-0.5">
                      Sponsor challenges, events, and gym spaces.
                    </span>
                  </span>
                </a>
              ) : (
                <button
                  type="button"
                  onClick={() => setSupportOpen(true)}
                  className="flex items-start gap-3 rounded-2xl border border-buddy-surface-raised p-4 text-left hover:bg-buddy-surface-raised transition-colors"
                >
                  <span className="flex-shrink-0 w-10 h-10 rounded-full bg-buddy-green/15 flex items-center justify-center">
                    <Briefcase size={18} className="text-buddy-green" />
                  </span>
                  <span>
                    <span className="block font-heading font-semibold text-sm">Partnership proposal for brands</span>
                    <span className="block text-xs text-buddy-text-secondary mt-0.5">
                      Sponsor challenges, events, and gym spaces.
                    </span>
                  </span>
                </button>
              )}
              {INVESTOR_FORM_URL ? (
                <a
                  href={INVESTOR_FORM_URL}
                  target="_blank"
                  rel="noreferrer noopener"
                  className="flex items-start gap-3 rounded-2xl border border-buddy-surface-raised p-4 text-left hover:bg-buddy-surface-raised transition-colors"
                >
                  <span className="flex-shrink-0 w-10 h-10 rounded-full bg-buddy-green/15 flex items-center justify-center">
                    <TrendingUp size={18} className="text-buddy-green" />
                  </span>
                  <span>
                    <span className="block font-heading font-semibold text-sm">Investor relations</span>
                    <span className="block text-xs text-buddy-text-secondary mt-0.5">
                      Backing BuddyUp Fit? Let&apos;s talk.
                    </span>
                  </span>
                </a>
              ) : (
                <button
                  type="button"
                  onClick={() => setSupportOpen(true)}
                  className="flex items-start gap-3 rounded-2xl border border-buddy-surface-raised p-4 text-left hover:bg-buddy-surface-raised transition-colors"
                >
                  <span className="flex-shrink-0 w-10 h-10 rounded-full bg-buddy-green/15 flex items-center justify-center">
                    <TrendingUp size={18} className="text-buddy-green" />
                  </span>
                  <span>
                    <span className="block font-heading font-semibold text-sm">Investor relations</span>
                    <span className="block text-xs text-buddy-text-secondary mt-0.5">
                      Backing BuddyUp Fit? Let&apos;s talk.
                    </span>
                  </span>
                </button>
              )}
              {!FUNDRAISER_URL && !PLEDGE_FORM_URL && !PARTNERSHIP_FORM_URL && !INVESTOR_FORM_URL ? (
                <Button onClick={() => setSupportOpen(true)} className="w-full">
                  <Heart size={16} /> Support us
                </Button>
              ) : null}
            </div>
          </Card>
          <Card className="p-8 bg-buddy-surface">
            <WaitlistForm />
          </Card>
        </div>
      </section>

      {/* ── 11. FOOTER ── */}
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
                <Link to="/medical-disclaimer" className="block hover:text-buddy-text-primary">Medical Disclaimer</Link>
                <Link to="/sponsorship-policy" className="block hover:text-buddy-text-primary">Sponsorship Policy</Link>
                <Link to="/help" className="block hover:text-buddy-text-primary">Help</Link>
                <Link to="/about" className="block hover:text-buddy-text-primary">About Us</Link>
                <Link to="/careers" className="block hover:text-buddy-text-primary">Careers</Link>
                <Link to="/contact" className="block hover:text-buddy-text-primary">Contact Us</Link>
                <button onClick={() => setSupportOpen(true)} className="block hover:text-buddy-text-primary">Fund Us</button>
              </div>
            </div>
          </div>
          <div className="grid md:grid-cols-2 gap-8 mb-12 border-t border-buddy-surface pt-12">
            <div>
              <h4 className="font-heading font-semibold text-sm mb-4">Contact</h4>
              <p className="text-sm text-buddy-text-secondary mb-2">
                Prefer email? Reach us directly at{' '}
                <a href={mailtoLink('direct')} className="text-buddy-green hover:underline break-all">{CONTACT_EMAILS.direct}</a>
              </p>
              <p className="text-xs text-buddy-text-secondary">
                Partnerships, gym onboarding, press, or support — one inbox, routed to the right team.
              </p>
            </div>
            <Card className="p-6 bg-buddy-surface">
              <ContactForm />
            </Card>
          </div>
          <div className="border-t border-buddy-surface pt-8 flex flex-col md:flex-row justify-between items-center gap-4">
            <p className="text-xs text-buddy-text-secondary">&copy; 2026 BuddyUp Fit. All rights reserved.</p>
            <div className="flex gap-6 text-sm text-buddy-text-secondary">
              <span className="hover:text-buddy-text-primary cursor-pointer">Instagram</span>
              <span className="hover:text-buddy-text-primary cursor-pointer">TikTok</span>
              <span className="hover:text-buddy-text-primary cursor-pointer">YouTube</span>
              <span className="hover:text-buddy-text-primary cursor-pointer">Twitter/X</span>
            </div>
          </div>
        </div>
      </footer>
      <SupportDialog open={supportOpen} onClose={() => setSupportOpen(false)} />
      <WaitlistModal isOpen={waitlistModal.open} onClose={closeWaitlist} interest={waitlistModal.interest} tier={waitlistModal.tier} />
      <Modal isOpen={installWaitlistOpen} onClose={() => setInstallWaitlistOpen(false)} title="Get notified at launch" size="md">
        <WaitlistForm />
      </Modal>
    </div>
  );
}
