import { useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import {
  Activity, BookOpen, CalendarDays, ChevronDown, Dumbbell, GraduationCap,
  Menu, MessagesSquare, Radio, Utensils, X,
} from 'lucide-react';
import { Logo } from '@/components/ui/Logo';
import { Button } from '@/components/ui/Button';

const SERVICES: { icon: typeof Radio; title: string; desc: string; to: string }[] = [
  { icon: Radio, title: 'Live Workouts', desc: 'HIIT, yoga, strength — live or on demand.', to: '/services#service-live' },
  { icon: Dumbbell, title: 'Gyms', desc: 'Nearby, virtual, and hybrid communities.', to: '/services#service-gyms' },
  { icon: GraduationCap, title: 'Trainers & Practitioners', desc: 'Verified pros, mobile or online.', to: '/services#service-trainers' },
  { icon: MessagesSquare, title: 'Communities & Messaging', desc: 'Group chats that notice when you show up.', to: '/services#service-communities' },
  { icon: CalendarDays, title: 'Events', desc: 'Runs, games, and workshops near you.', to: '/services#service-events' },
  { icon: Utensils, title: 'Marketplace', desc: 'Meal plans, programmes, and gear.', to: '/services#service-marketplace' },
  { icon: BookOpen, title: 'Training Programmes', desc: 'Structured multi-week plans.', to: '/services#service-programmes' },
  { icon: Activity, title: 'Activity Analytics', desc: 'Runs, walks, hikes — tracked and streaked.', to: '/services#service-analytics' },
];

const NAV_LINKS = [
  { label: 'About Us', to: '/about' },
  { label: 'Careers', to: '/careers' },
  { label: 'Contact Us', to: '/contact' },
];

export function Navbar() {
  const navigate = useNavigate();
  const [scrolled, setScrolled] = useState(false);
  const [servicesOpen, setServicesOpen] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 24);
    onScroll();
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        setServicesOpen(false);
        setMobileOpen(false);
      }
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, []);

  const goWaitlist = () => {
    setMobileOpen(false);
    setServicesOpen(false);
    if (window.location.pathname !== '/') {
      navigate('/#waitlist');
    } else {
      document.getElementById('waitlist')?.scrollIntoView({ behavior: 'smooth' });
    }
  };

  return (
    <nav
      aria-label="Primary"
      className={`fixed top-0 left-0 right-0 z-40 transition-colors ${
        scrolled || mobileOpen || servicesOpen
          ? 'bg-buddy-black/90 backdrop-blur border-b border-buddy-surface'
          : 'bg-transparent border-b border-transparent'
      }`}
    >
      <div className="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between gap-4">
        <Link to="/" aria-label="BuddyUp Fit home" onClick={() => setMobileOpen(false)}>
          <Logo size="md" />
        </Link>

        {/* Desktop links — every item shares one box model so all labels
            sit on exactly the same baseline (text-only links and the
            icon-bearing Services button included). */}
        <div className="hidden md:flex items-center gap-1">
          <Link
            to="/about"
            className="inline-flex items-center px-4 py-2 text-sm leading-6 text-buddy-text-secondary hover:text-buddy-text-primary transition-colors"
          >
            About Us
          </Link>
          <div className="relative" onMouseLeave={() => setServicesOpen(false)}>
            <button
              type="button"
              aria-expanded={servicesOpen}
              aria-haspopup="true"
              onClick={() => setServicesOpen((v) => !v)}
              onMouseEnter={() => setServicesOpen(true)}
              className="inline-flex items-center gap-1 px-4 py-2 text-sm leading-6 text-buddy-text-secondary hover:text-buddy-text-primary transition-colors"
            >
              Services <ChevronDown size={14} className={`shrink-0 transition-transform ${servicesOpen ? 'rotate-180' : ''}`} />
            </button>
            {servicesOpen && (
              <div className="absolute left-1/2 -translate-x-1/2 top-full pt-2 w-[32rem]">
                <div className="grid grid-cols-2 gap-1 bg-buddy-surface border border-buddy-surface-raised rounded-2xl p-3 shadow-2xl">
                  {SERVICES.map(({ icon: Icon, title, desc, to }) => (
                    <Link
                      key={title}
                      to={to}
                      onClick={() => setServicesOpen(false)}
                      className="flex items-start gap-3 p-3 rounded-xl hover:bg-buddy-surface-raised transition-colors"
                    >
                      <span className="flex-shrink-0 w-9 h-9 rounded-xl bg-buddy-green/10 flex items-center justify-center">
                        <Icon size={18} className="text-buddy-green" />
                      </span>
                      <span>
                        <span className="block text-sm font-medium text-buddy-text-primary">{title}</span>
                        <span className="block text-xs text-buddy-text-secondary mt-0.5">{desc}</span>
                      </span>
                    </Link>
                  ))}
                </div>
              </div>
            )}
          </div>
          {NAV_LINKS.slice(1).map(({ label, to }) => (
            <Link
              key={to}
              to={to}
              className="inline-flex items-center px-4 py-2 text-sm leading-6 text-buddy-text-secondary hover:text-buddy-text-primary transition-colors"
            >
              {label}
            </Link>
          ))}
        </div>

        <div className="hidden md:flex items-center gap-3">
          <Button size="sm" onClick={goWaitlist}>Join waiting list</Button>
        </div>

        {/* Mobile toggle */}
        <button
          type="button"
          className="md:hidden p-2 text-buddy-text-primary"
          aria-expanded={mobileOpen}
          aria-label={mobileOpen ? 'Close menu' : 'Open menu'}
          onClick={() => setMobileOpen((v) => !v)}
        >
          {mobileOpen ? <X size={22} /> : <Menu size={22} />}
        </button>
      </div>

      {/* Mobile panel */}
      {mobileOpen && (
        <div className="md:hidden border-t border-buddy-surface bg-buddy-black/95 backdrop-blur px-6 py-4 space-y-1 max-h-[70vh] overflow-y-auto">
          <p className="text-xs text-buddy-text-secondary pb-2">Find your fitness family.</p>
          {[{ label: 'About Us', to: '/about' }, ...NAV_LINKS.slice(1)].map(({ label, to }) => (
            <Link
              key={to}
              to={to}
              onClick={() => setMobileOpen(false)}
              className="block py-2.5 text-sm font-medium text-buddy-text-primary border-b border-buddy-surface"
            >
              {label}
            </Link>
          ))}
          <p className="pt-3 pb-1 text-xs font-semibold uppercase tracking-wide text-buddy-text-secondary">Services</p>
          <div className="grid grid-cols-1 gap-1 pb-3">
            {SERVICES.map(({ icon: Icon, title, to }) => (
              <Link
                key={title}
                to={to}
                onClick={() => setMobileOpen(false)}
                className="flex items-center gap-3 py-2 text-sm text-buddy-text-primary"
              >
                <Icon size={16} className="text-buddy-green flex-shrink-0" /> {title}
              </Link>
            ))}
          </div>
          <div className="pt-1">
            <Button className="w-full" onClick={goWaitlist}>Join waiting list</Button>
          </div>
        </div>
      )}
    </nav>
  );
}
