import { Link } from 'react-router-dom';
import {
  Activity, ArrowRight, BookOpen, CalendarDays, Dumbbell, GraduationCap,
  MessagesSquare, Radio, Utensils,
} from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Navbar } from '@/components/landing/Navbar';

const SERVICES: {
  key: string;
  icon: typeof Radio;
  title: string;
  story: string;
  points: string[];
  cta: string;
  to: string;
}[] = [
  {
    key: 'live',
    icon: Radio,
    title: 'Live Workouts',
    story: 'Fitness is better together in real time. Drop into a live HIIT class, flow through sunrise yoga, or let a Random Drop surprise you — led by real trainers, surrounded by real buddies.',
    points: ['Open Sweat — public, free sessions', 'Buddy Circle — private group lives', 'Random Drop — surprise match workouts', 'Gym scheduled lives with RSVP'],
    cta: 'Browse live sessions',
    to: '/lives',
  },
  {
    key: 'gyms',
    icon: Dumbbell,
    title: 'Gyms',
    story: 'Your fitness family needs a home. Discover nearby physical gyms, train from your living room with virtual gyms, or join hybrid communities doing both — all with verified badges and member reviews.',
    points: ['Nearby, virtual & hybrid discovery', 'Public, private, or secret gyms', 'Trainer & moderator roles', 'Gym wallet with revenue splits'],
    cta: 'Discover gyms',
    to: '/gyms',
  },
  {
    key: 'trainers',
    icon: GraduationCap,
    title: 'Trainers & Practitioners',
    story: 'General advice is free everywhere; accountability from a verified professional is rare. Find certified trainers and licensed health practitioners — mobile, near you, virtual, or affiliated with your gym.',
    points: ['Verified badges & reviews', 'Session booking & escrow', 'Async training programmes', 'Availability calendar'],
    cta: 'Find your trainer',
    to: '/trainers',
  },
  {
    key: 'communities',
    icon: MessagesSquare,
    title: 'Communities & Messaging',
    story: 'Motivation fades; people who notice don\'t. Join communities around your goals and keep the conversation going in group chats — the buddy system, with receipts.',
    points: ['Goal-based communities', 'Group messages & buddy circles', 'Accountability pings', 'Streaks your circle can see'],
    cta: 'Meet your community',
    to: '/discover',
  },
  {
    key: 'events',
    icon: CalendarDays,
    title: 'Events',
    story: 'Train for something. Sunrise runs, hybrid competitions, workshops, and social meetups — in person, virtual, or both, with tickets and QR check-in built in.',
    points: ['In-person, virtual & hybrid formats', 'Tickets with QR check-in', 'Gym & trainer-hosted', 'Free and paid entry'],
    cta: 'Explore events',
    to: '/marketplace',
  },
  {
    key: 'marketplace',
    icon: Utensils,
    title: 'Marketplace',
    story: 'Fuel the work. Meal plans from verified nutritionists, training programmes from certified coaches, and gear from trusted sellers — one wallet, zero guesswork.',
    points: ['Verified sellers only', 'Meal plans & programmes', 'Supplements, gear & apparel', 'Reviews on everything'],
    cta: 'Shop the marketplace',
    to: '/marketplace',
  },
  {
    key: 'programmes',
    icon: BookOpen,
    title: 'Training Programmes',
    story: 'Random workouts give random results. Follow structured multi-week programmes from verified trainers — strength blocks, run plans, conditioning — with progress tracking built in.',
    points: ['Multi-week structured plans', 'Verified trainer authors', 'Enrolment & progress tracking', 'Bundle with 1:1 sessions'],
    cta: 'Browse programmes',
    to: '/marketplace',
  },
  {
    key: 'analytics',
    icon: Activity,
    title: 'Activity Analytics',
    story: 'What gets measured gets kept. GPS-track every run, walk, hike, and ride, log strength and yoga sessions, and watch streaks, distances, and progress reports compound.',
    points: ['GPS tracking for runs, walks, hikes & rides', 'Strength, cardio, HIIT & yoga logs', 'Streaks that keep you honest', 'Shareable progress reports'],
    cta: 'See your stats',
    to: '/analytics',
  },
];

export default function Services() {
  return (
    <div className="min-h-screen bg-buddy-black overflow-x-hidden">
      <Navbar />
      <header className="relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-b from-buddy-green/5 to-transparent pointer-events-none" />
        <div className="max-w-4xl mx-auto px-6 pt-28 pb-12 text-center relative z-10">
          <h1 className="font-display text-4xl sm:text-5xl font-extrabold text-white mb-5 leading-tight">
            Everything your fitness life needs,<br />
            <span className="text-buddy-green">in one place.</span>
          </h1>
          <p className="text-lg text-buddy-text-secondary max-w-2xl mx-auto leading-relaxed">
            Buddies, gyms, trainers, events, and the numbers that prove you&apos;re
            improving — eight services, one fitness family.
          </p>
        </div>
      </header>

      <main className="max-w-5xl mx-auto px-6 pb-24 space-y-6">
        {SERVICES.map(({ key, icon: Icon, title, story, points, cta, to }, i) => (
          <section key={key} id={`service-${key}`} className="scroll-mt-20">
            <Card className={`p-6 sm:p-8 bg-buddy-surface ${i % 2 === 1 ? 'md:ml-12' : 'md:mr-12'}`}>
              <div className="flex items-start gap-4">
                <span className="flex-shrink-0 w-12 h-12 rounded-2xl bg-buddy-green/10 flex items-center justify-center">
                  <Icon size={24} className="text-buddy-green" />
                </span>
                <div className="min-w-0">
                  <h2 className="font-display text-2xl font-extrabold mb-2">{title}</h2>
                  <p className="text-buddy-text-secondary leading-relaxed mb-5">{story}</p>
                  <ul className="grid sm:grid-cols-2 gap-2 mb-6">
                    {points.map((p) => (
                      <li key={p} className="flex items-start gap-2 text-sm">
                        <span className="mt-1.5 w-1.5 h-1.5 rounded-full bg-buddy-green flex-shrink-0" />
                        <span>{p}</span>
                      </li>
                    ))}
                  </ul>
                  <Link to={to}>
                    <Button variant="outline" className="gap-2">
                      {cta} <ArrowRight size={16} />
                    </Button>
                  </Link>
                </div>
              </div>
            </Card>
          </section>
        ))}

        <Card className="p-8 bg-buddy-surface text-center">
          <h2 className="font-display text-2xl font-extrabold mb-3">
            Not launched yet? <span className="text-buddy-green">Get in line.</span>
          </h2>
          <p className="text-buddy-text-secondary mb-6 max-w-xl mx-auto">
            BuddyUp Fit launches in November. Join the waiting list and be first
            through the door — members, gyms, trainers, and corporates welcome.
          </p>
          <Link to="/#waitlist">
            <Button size="lg">Join the waiting list</Button>
          </Link>
        </Card>
      </main>
    </div>
  );
}
