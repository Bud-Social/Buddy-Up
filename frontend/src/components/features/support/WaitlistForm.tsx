import { useEffect, useState, type FormEvent } from 'react';
import axios from 'axios';
import { BellRing, Briefcase, CalendarDays, Check, Dumbbell, GraduationCap, Store, Truck, User } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { joinWaitlist, type WaitlistInterest } from '@/api/waitlist';
import { COUNTRIES } from '@/config/countries';
import { useVisitorCountry } from '@/hooks/useVisitorCountry';

export const WAITLIST_INTEREST_EVENT = 'buddyup:waitlist-interest';

/** Ask the nearest waitlist form to switch to an interest tab, then scroll to it. */
export function requestWaitlistInterest(interest: WaitlistInterest) {
  window.dispatchEvent(new CustomEvent<WaitlistInterest>(WAITLIST_INTEREST_EVENT, { detail: interest }));
  document.getElementById('waitlist')?.scrollIntoView({ behavior: 'smooth' });
}

const INTERESTS: { key: WaitlistInterest; label: string; icon: typeof User }[] = [
  { key: 'user', label: 'Member', icon: User },
  { key: 'gym', label: 'Gym', icon: Dumbbell },
  { key: 'trainer', label: 'Trainer', icon: GraduationCap },
  { key: 'corporate', label: 'Corporate', icon: Briefcase },
  { key: 'organiser', label: 'Events', icon: CalendarDays },
  { key: 'supplier', label: 'Supplier', icon: Store },
  { key: 'distributor', label: 'Distributor', icon: Truck },
];

const GYM_TYPES = ['physical', 'virtual', 'hybrid'];
const GYM_SIZES = ['Just me', '2–10 members', '11–50 members', '50+ members'];
const TRAINER_ROLES = ['trainer', 'practitioner'];
const TEAM_SIZES = ['1–10', '11–50', '51–200', '200+'];
const CORPORATE_PACKAGES = [
  { value: 'challenges', label: 'Team challenges' },
  { value: 'branded_space', label: 'Branded gym space' },
  { value: 'sponsored_events', label: 'Sponsored events' },
  { value: 'awareness', label: 'Awareness campaigns' },
];
const EVENT_TYPES = [
  { value: 'fitness', label: 'Fitness classes' },
  { value: 'competition', label: 'Competitions' },
  { value: 'workshop', label: 'Workshops' },
  { value: 'social', label: 'Social meetups' },
  { value: 'wellness', label: 'Wellness retreats' },
];
const AUDIENCE_SIZES = ['Under 50', '50–200', '200–1,000', '1,000+'];
const PRODUCT_CATEGORIES = [
  { value: 'supplements', label: 'Supplements' },
  { value: 'equipment', label: 'Gym equipment' },
  { value: 'apparel', label: 'Apparel & gear' },
  { value: 'nutrition', label: 'Nutrition & meal prep' },
  { value: 'digital', label: 'Digital products' },
];

export function WaitlistForm({ initialInterest = 'user' }: { initialInterest?: WaitlistInterest }) {
  const [interest, setInterest] = useState<WaitlistInterest>(initialInterest);
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [country, setCountry] = useState('');
  const [status, setStatus] = useState<'idle' | 'loading' | 'done' | 'error'>('idle');
  const [message, setMessage] = useState('');
  // Gym-specific lead details.
  const [gymName, setGymName] = useState('');
  const [city, setCity] = useState('');
  const [gymType, setGymType] = useState('physical');
  const [gymSize, setGymSize] = useState(GYM_SIZES[0]);
  const [onboardCoaches, setOnboardCoaches] = useState(false);
  // Trainer-specific lead details.
  const [trainerRole, setTrainerRole] = useState('trainer');
  const [specialties, setSpecialties] = useState('');
  const [credential, setCredential] = useState('');
  const [mobile, setMobile] = useState(false);
  const [virtual, setVirtual] = useState(false);
  // Corporate-specific lead details.
  const [companyName, setCompanyName] = useState('');
  const [teamSize, setTeamSize] = useState(TEAM_SIZES[0]);
  const [packages, setPackages] = useState<string[]>([]);
  const [corporateMessage, setCorporateMessage] = useState('');
  // Organiser / supplier / distributor lead details (shared business name).
  const [businessName, setBusinessName] = useState('');
  const [eventTypes, setEventTypes] = useState<string[]>([]);
  const [audienceSize, setAudienceSize] = useState(AUDIENCE_SIZES[0]);
  const [productCategories, setProductCategories] = useState<string[]>([]);
  const [hasShop, setHasShop] = useState(false);
  const [coverage, setCoverage] = useState('');
  const [offerings, setOfferings] = useState('');

  function togglePackage(value: string) {
    setPackages((prev) => prev.includes(value) ? prev.filter((p) => p !== value) : [...prev, value]);
  }

  function toggleInList(list: string[], value: string, set: (v: string[]) => void) {
    set(list.includes(value) ? list.filter((v) => v !== value) : [...list, value]);
  }

  // Best-effort guess (Vercel geo header / browser locale) to pre-select
  // the country; the user can always change it and must confirm it.
  const visitorCountry = useVisitorCountry();
  const countryGuess = country || visitorCountry || '';

  useEffect(() => {
    const handler = (e: Event) => {
      const next = (e as CustomEvent<WaitlistInterest>).detail;
      if (INTERESTS.some((i) => i.key === next)) {
        setInterest(next);
        setStatus('idle');
        setMessage('');
      }
    };
    window.addEventListener(WAITLIST_INTEREST_EVENT, handler);
    return () => window.removeEventListener(WAITLIST_INTEREST_EVENT, handler);
  }, []);

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    if (status === 'loading') return;
    setStatus('loading');
    setMessage('');
    const metadata: Record<string, unknown> =
      interest === 'gym'
        ? {
            gym_name: gymName.trim(), city: city.trim(), gym_type: gymType,
            gym_size: gymSize, onboard_coaches: onboardCoaches,
          }
        : interest === 'trainer'
          ? {
              role: trainerRole, city: city.trim(),
              specialties: specialties.split(',').map((s) => s.trim()).filter(Boolean),
              credential: credential.trim(), mobile, virtual,
            }
          : interest === 'corporate'
            ? {
                company_name: companyName.trim(), city: city.trim(),
                team_size: teamSize, packages, message: corporateMessage.trim(),
              }
            : interest === 'organiser'
              ? {
                  brand: businessName.trim(), city: city.trim(),
                  event_types: eventTypes, audience: audienceSize,
                }
              : interest === 'supplier'
                ? {
                    business: businessName.trim(), city: city.trim(),
                    categories: productCategories, has_shop: hasShop,
                  }
                : interest === 'distributor'
                  ? {
                      business: businessName.trim(), city: city.trim(),
                      coverage: coverage.trim(), offerings: offerings.trim(),
                    }
                  : {};
    try {
      // The signup is written by the same-origin Vercel function (api/waitlist.ts)
      // to Supabase, which also mirrors to Google Sheets server-side — the
      // webhook URL and service key are deliberately not in the client bundle.
      const res = await joinWaitlist({
        email: email.trim(),
        name: name.trim(),
        country: countryGuess,
        interest,
        metadata,
      });
      setMessage(res.message || 'You joined the waitlist.');
      setStatus('done');
    } catch (err) {
      if (axios.isAxiosError(err)) {
        const errors = err.response?.data?.errors;
        const first = errors ? Object.values(errors).flat()[0] : null;
        setMessage(
          (typeof first === 'string' ? first : null)
          || err.response?.data?.message
          || 'Something went wrong. Please try again.',
        );
      } else {
        setMessage('Something went wrong. Please try again.');
      }
      setStatus('error');
    }
  }

  if (status === 'done') {
    return (
      <div className="flex items-start gap-3 bg-buddy-surface-raised rounded-2xl p-5" role="status">
        <span className="flex-shrink-0 w-10 h-10 rounded-full bg-buddy-green/15 flex items-center justify-center">
          <Check size={20} className="text-buddy-green" />
        </span>
        <div>
          <p className="font-heading font-semibold">You&apos;re on the list</p>
          <p className="text-sm text-buddy-text-secondary">{message} We&apos;ll email you when it&apos;s your turn.</p>
        </div>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-3" noValidate={false}>
      <div className="flex items-center gap-2 mb-1">
        <BellRing size={20} className="text-buddy-green" />
        <h3 className="font-heading font-semibold">Join the Waiting List</h3>
      </div>
      <p className="text-sm text-buddy-text-secondary">
        We are launching in November. Join the list and be first through the door.
      </p>
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-2" role="tablist" aria-label="Waitlist type">
        {INTERESTS.map(({ key, label, icon: Icon }) => (
          <button
            key={key}
            type="button"
            role="tab"
            aria-selected={interest === key}
            onClick={() => setInterest(key)}
            className={`flex items-center justify-center gap-1.5 px-3 py-2 rounded-xl border text-sm transition-colors ${interest === key ? 'border-buddy-green bg-buddy-green/10 text-buddy-text-primary font-medium' : 'border-buddy-surface-raised text-buddy-text-secondary hover:border-buddy-green/40'}`}
          >
            <Icon size={14} /> {label}
          </button>
        ))}
      </div>
      {interest === 'gym' && (
        <>
          <Input
            label="Gym name"
            type="text"
            required
            value={gymName}
            onChange={(e) => setGymName(e.target.value)}
            placeholder="Nairobi Iron House"
            autoComplete="organization"
          />
          <div className="grid grid-cols-2 gap-3">
            <Input
              label="City"
              type="text"
              required
              value={city}
              onChange={(e) => setCity(e.target.value)}
              placeholder="Nairobi"
              autoComplete="address-level2"
            />
            <div className="w-full">
              <label htmlFor="waitlist-gym-type" className="block text-sm font-medium text-buddy-text-secondary mb-1.5">
                Gym type
              </label>
              <select
                id="waitlist-gym-type"
                value={gymType}
                onChange={(e) => setGymType(e.target.value)}
                className="w-full appearance-none bg-buddy-surface border rounded-xl px-4 py-3 text-buddy-text-primary font-body transition-colors focus:outline-none focus:ring-2 min-h-touch focus:ring-buddy-green/30 border-transparent"
              >
                {GYM_TYPES.map((t) => (
                  <option key={t} value={t} className="capitalize">{t}</option>
                ))}
              </select>
            </div>
          </div>
          <div className="w-full">
            <label htmlFor="waitlist-gym-size" className="block text-sm font-medium text-buddy-text-secondary mb-1.5">
              Community size
            </label>
            <select
              id="waitlist-gym-size"
              value={gymSize}
              onChange={(e) => setGymSize(e.target.value)}
              className="w-full appearance-none bg-buddy-surface border rounded-xl px-4 py-3 text-buddy-text-primary font-body transition-colors focus:outline-none focus:ring-2 min-h-touch focus:ring-buddy-green/30 border-transparent"
            >
              {GYM_SIZES.map((s) => (
                <option key={s} value={s}>{s}</option>
              ))}
            </select>
          </div>
          <label className="flex items-start gap-2 text-sm text-buddy-text-secondary cursor-pointer">
            <input type="checkbox" checked={onboardCoaches} onChange={(e) => setOnboardCoaches(e.target.checked)} className="mt-1 rounded accent-buddy-green" />
            <span>We&apos;d like to onboard our coaches to the platform too.</span>
          </label>
        </>
      )}
      {interest === 'trainer' && (
        <>
          <div className="grid grid-cols-2 gap-2">
            {TRAINER_ROLES.map((r) => (
              <button
                key={r}
                type="button"
                onClick={() => setTrainerRole(r)}
                className={`px-3 py-2 rounded-xl border text-sm capitalize transition-colors ${trainerRole === r ? 'border-buddy-green bg-buddy-green/10 text-buddy-text-primary font-medium' : 'border-buddy-surface-raised text-buddy-text-secondary hover:border-buddy-green/40'}`}
              >
                {r === 'trainer' ? 'Trainer / Coach' : 'Health Practitioner'}
              </button>
            ))}
          </div>
          <div className="grid grid-cols-2 gap-3">
            <Input
              label="City"
              type="text"
              required
              value={city}
              onChange={(e) => setCity(e.target.value)}
              placeholder="Nairobi"
              autoComplete="address-level2"
            />
            <Input
              label="Specialties"
              type="text"
              value={specialties}
              onChange={(e) => setSpecialties(e.target.value)}
              placeholder="Strength, HIIT"
            />
          </div>
          <Input
            label="Credential / license (optional)"
            type="text"
            value={credential}
            onChange={(e) => setCredential(e.target.value)}
            placeholder="e.g. ACE Certified, KNUT…"
          />
          <div className="flex gap-4 text-sm text-buddy-text-secondary">
            <label className="flex items-center gap-2 cursor-pointer">
              <input type="checkbox" checked={mobile} onChange={(e) => setMobile(e.target.checked)} className="rounded accent-buddy-green" />
              <span>I train clients in person / travel to them</span>
            </label>
            <label className="flex items-center gap-2 cursor-pointer">
              <input type="checkbox" checked={virtual} onChange={(e) => setVirtual(e.target.checked)} className="rounded accent-buddy-green" />
              <span>I coach online</span>
            </label>
          </div>
        </>
      )}
      {interest === 'corporate' && (
        <>
          <Input
            label="Company / organisation"
            type="text"
            required
            value={companyName}
            onChange={(e) => setCompanyName(e.target.value)}
            placeholder="Acme Ltd"
            autoComplete="organization"
          />
          <div className="grid grid-cols-2 gap-3">
            <Input
              label="City"
              type="text"
              required
              value={city}
              onChange={(e) => setCity(e.target.value)}
              placeholder="Nairobi"
              autoComplete="address-level2"
            />
            <div className="w-full">
              <label htmlFor="waitlist-team-size" className="block text-sm font-medium text-buddy-text-secondary mb-1.5">
                Team size
              </label>
              <select
                id="waitlist-team-size"
                value={teamSize}
                onChange={(e) => setTeamSize(e.target.value)}
                className="w-full appearance-none bg-buddy-surface border rounded-xl px-4 py-3 text-buddy-text-primary font-body transition-colors focus:outline-none focus:ring-2 min-h-touch focus:ring-buddy-green/30 border-transparent"
              >
                {TEAM_SIZES.map((s) => (
                  <option key={s} value={s}>{s}</option>
                ))}
              </select>
            </div>
          </div>
          <div className="w-full">
            <p className="block text-sm font-medium text-buddy-text-secondary mb-1.5">
              Packages of interest
            </p>
            <div className="flex flex-wrap gap-2">
              {CORPORATE_PACKAGES.map((p) => (
                <button
                  key={p.value}
                  type="button"
                  onClick={() => togglePackage(p.value)}
                  aria-pressed={packages.includes(p.value)}
                  className={`px-3 py-1.5 rounded-full text-xs whitespace-nowrap transition-colors ${packages.includes(p.value) ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface-raised text-buddy-text-secondary hover:border-buddy-green/40'}`}
                >
                  {p.label}
                </button>
              ))}
            </div>
          </div>
          <div className="w-full">
            <label htmlFor="waitlist-corporate-message" className="block text-sm font-medium text-buddy-text-secondary mb-1.5">
              Anything we should know? (optional)
            </label>
            <textarea
              id="waitlist-corporate-message"
              value={corporateMessage}
              onChange={(e) => setCorporateMessage(e.target.value)}
              placeholder="Goals, timelines, team interests…"
              rows={2}
              maxLength={1000}
              className="w-full bg-buddy-surface border border-transparent rounded-xl px-4 py-3 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30 resize-none min-h-touch"
            />
          </div>
        </>
      )}
      {interest === 'organiser' && (
        <>
          <Input
            label="Event brand / organisation"
            type="text"
            required
            value={businessName}
            onChange={(e) => setBusinessName(e.target.value)}
            placeholder="Nairobi Run Club"
            autoComplete="organization"
          />
          <div className="grid grid-cols-2 gap-3">
            <Input
              label="City"
              type="text"
              required
              value={city}
              onChange={(e) => setCity(e.target.value)}
              placeholder="Nairobi"
              autoComplete="address-level2"
            />
            <div className="w-full">
              <label htmlFor="waitlist-audience" className="block text-sm font-medium text-buddy-text-secondary mb-1.5">
                Typical audience
              </label>
              <select
                id="waitlist-audience"
                value={audienceSize}
                onChange={(e) => setAudienceSize(e.target.value)}
                className="w-full appearance-none bg-buddy-surface border rounded-xl px-4 py-3 text-buddy-text-primary font-body transition-colors focus:outline-none focus:ring-2 min-h-touch focus:ring-buddy-green/30 border-transparent"
              >
                {AUDIENCE_SIZES.map((s) => (
                  <option key={s} value={s}>{s}</option>
                ))}
              </select>
            </div>
          </div>
          <div className="w-full">
            <p className="block text-sm font-medium text-buddy-text-secondary mb-1.5">
              Event types you run
            </p>
            <div className="flex flex-wrap gap-2">
              {EVENT_TYPES.map((t) => (
                <button
                  key={t.value}
                  type="button"
                  onClick={() => toggleInList(eventTypes, t.value, setEventTypes)}
                  aria-pressed={eventTypes.includes(t.value)}
                  className={`px-3 py-1.5 rounded-full text-xs whitespace-nowrap transition-colors ${eventTypes.includes(t.value) ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface-raised text-buddy-text-secondary hover:border-buddy-green/40'}`}
                >
                  {t.label}
                </button>
              ))}
            </div>
          </div>
        </>
      )}
      {interest === 'supplier' && (
        <>
          <Input
            label="Business / shop name"
            type="text"
            required
            value={businessName}
            onChange={(e) => setBusinessName(e.target.value)}
            placeholder="FitFuel Supplies"
            autoComplete="organization"
          />
          <Input
            label="City"
            type="text"
            required
            value={city}
            onChange={(e) => setCity(e.target.value)}
            placeholder="Nairobi"
            autoComplete="address-level2"
          />
          <div className="w-full">
            <p className="block text-sm font-medium text-buddy-text-secondary mb-1.5">
              What do you supply?
            </p>
            <div className="flex flex-wrap gap-2">
              {PRODUCT_CATEGORIES.map((c) => (
                <button
                  key={c.value}
                  type="button"
                  onClick={() => toggleInList(productCategories, c.value, setProductCategories)}
                  aria-pressed={productCategories.includes(c.value)}
                  className={`px-3 py-1.5 rounded-full text-xs whitespace-nowrap transition-colors ${productCategories.includes(c.value) ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface-raised text-buddy-text-secondary hover:border-buddy-green/40'}`}
                >
                  {c.label}
                </button>
              ))}
            </div>
          </div>
          <label className="flex items-start gap-2 text-sm text-buddy-text-secondary cursor-pointer">
            <input type="checkbox" checked={hasShop} onChange={(e) => setHasShop(e.target.checked)} className="mt-1 rounded accent-buddy-green" />
            <span>We have a physical shop or outlet.</span>
          </label>
        </>
      )}
      {interest === 'distributor' && (
        <>
          <Input
            label="Business name"
            type="text"
            required
            value={businessName}
            onChange={(e) => setBusinessName(e.target.value)}
            placeholder="GymEquip East Africa"
            autoComplete="organization"
          />
          <div className="grid grid-cols-2 gap-3">
            <Input
              label="City"
              type="text"
              required
              value={city}
              onChange={(e) => setCity(e.target.value)}
              placeholder="Nairobi"
              autoComplete="address-level2"
            />
            <Input
              label="Coverage"
              type="text"
              value={coverage}
              onChange={(e) => setCoverage(e.target.value)}
              placeholder="Kenya, Uganda…"
            />
          </div>
          <div className="w-full">
            <label htmlFor="waitlist-offerings" className="block text-sm font-medium text-buddy-text-secondary mb-1.5">
              Equipment & services you distribute
            </label>
            <textarea
              id="waitlist-offerings"
              value={offerings}
              onChange={(e) => setOfferings(e.target.value)}
              placeholder="e.g. Strength machines, flooring, installation & maintenance"
              rows={2}
              maxLength={1000}
              className="w-full bg-buddy-surface border border-transparent rounded-xl px-4 py-3 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30 resize-none min-h-touch"
            />
          </div>
        </>
      )}
      <Input
        label={interest === 'user' ? 'Name (optional)' : 'Contact name'}
        type="text"
        value={name}
        onChange={(e) => setName(e.target.value)}
        placeholder="Alex"
        autoComplete="name"
      />
      <Input
        label="Email"
        type="email"
        required
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="you@example.com"
        autoComplete="email"
      />
      <div className="w-full">
        <label
          htmlFor="waitlist-country"
          className="block text-sm font-medium text-buddy-text-secondary mb-1.5"
        >
          Country
        </label>
        <select
          id="waitlist-country"
          required
          value={countryGuess}
          onChange={(e) => setCountry(e.target.value)}
          className={`w-full appearance-none bg-buddy-surface border rounded-xl px-4 py-3 text-buddy-text-primary font-body transition-colors focus:outline-none focus:ring-2 min-h-touch focus:ring-buddy-green/30 border-transparent ${COUNTRIES.includes(countryGuess) ? '' : 'text-buddy-text-secondary/50'}`}
        >
          <option value="" disabled>
            Select your country…
          </option>
          {COUNTRIES.map((c) => (
            <option key={c} value={c}>
              {c}
            </option>
          ))}
        </select>
      </div>
      {status === 'error' && (
        <p className="text-sm text-red-500" role="alert">{message}</p>
      )}
      <Button type="submit" className="w-full" disabled={status === 'loading'}>
        {status === 'loading' ? 'Joining…' : 'Notify me'}
      </Button>
    </form>
  );
}
