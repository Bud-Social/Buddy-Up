import { useCallback, useEffect, useMemo, useRef, useState, type FormEvent } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  ChevronLeft, CheckCircle2, Truck, Store, MapPin, Coins, Percent, DollarSign,
  Smartphone, CreditCard, Wallet as WalletIcon, Navigation, Pill,
  Utensils, Dumbbell, Calendar, AlertCircle,
} from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { Input } from '@/components/ui/Input';
import { useToast } from '@/components/ui/Toast';
import { formatDistance, requestLocation, type Coords } from '@/lib/geo';
import {
  marketplaceApi,
  checkoutErrorMessage,
  type CartItemPayload,
  type CartPayload,
  type CheckoutDeliveryAddress,
  type CheckoutPaymentMethod,
  type CheckoutPayload,
  type CheckoutResult,
  type FulfillmentType,
} from '@/api/marketplace';
import { walletApi, type BalanceItem } from '@/api/wallet';
import {
  stationsApi,
  hasStationDistance,
  isStationsUnavailable,
  sortStationsByDistance,
  stationAreaLabel,
  stationOpeningHoursLabel,
  stationsErrorMessage,
  type PaymentIntent,
  type PickupStation,
} from '@/api/stations';

/**
 * Standalone checkout: review → choose fulfillment → choose payment → receipt.
 *
 * This page replaced two nested modals that used to live inside the cart, so it
 * owns the whole flow and is deep-linkable at `/marketplace/checkout`. Two
 * rules shape everything below:
 *
 *  1. Only offer a fulfillment type the cart can actually fulfill. Products are
 *     the only item type with `delivery_modes`; meal plans, programmes and event
 *     tickets are digital by construction, so pickup/delivery are absent — not
 *     disabled — when nothing physical is in the cart.
 *  2. Never destroy the buyer's input on a failure. A rejected checkout (most
 *     often `Insufficient <token> tokens.`) leaves every field exactly where it
 *     was and renders the server's own wording inline.
 */

const FULFILLMENT_VALUES: readonly FulfillmentType[] = ['digital', 'pickup', 'delivery'];

const FULFILLMENT_OPTIONS: ReadonlyArray<{ value: FulfillmentType; label: string; icon: typeof Store; hint: string }> = [
  { value: 'digital', label: 'Digital', icon: CheckCircle2, hint: 'Unlocked instantly' },
  { value: 'pickup', label: 'Pickup', icon: Store, hint: 'Collect in person' },
  { value: 'delivery', label: 'Delivery', icon: Truck, hint: 'Shipped to your address' },
];

const PAYMENT_OPTIONS: ReadonlyArray<{
  value: CheckoutPaymentMethod;
  label: string;
  icon: typeof Store;
  note: string;
}> = [
  { value: 'artifacts', label: 'Artifacts', icon: WalletIcon, note: 'Deducts from your wallet instantly.' },
  { value: 'mpesa', label: 'M-Pesa', icon: Smartphone, note: 'Confirm the prompt on your phone first.' },
  { value: 'card', label: 'Card', icon: CreditCard, note: 'Confirmed by the card provider.' },
];

const FULFILLMENT_LABELS: Record<FulfillmentType, string> = {
  digital: 'Digital',
  pickup: 'Pickup',
  delivery: 'Delivery',
};

const PAYMENT_LABELS: Record<CheckoutPaymentMethod, string> = {
  artifacts: 'Artifacts (wallet)',
  mpesa: 'M-Pesa',
  card: 'Card',
};

const ITEM_ICONS: Record<string, typeof Pill> = {
  meal_plan: Utensils,
  programme: Dumbbell,
  product: Pill,
  event_ticket: Calendar,
};

const ITEM_FK_KEYS: Record<string, string> = {
  meal_plan: 'meal_plan',
  programme: 'programme',
  product: 'product',
  event_ticket: 'event',
};

const ADDRESS_FIELDS = ['line1', 'line2', 'city', 'postal_code', 'country', 'phone', 'notes'] as const;
type AddressField = (typeof ADDRESS_FIELDS)[number];

/** 7–15 digits, optionally with a leading +, spaces, dashes or brackets. */
const PHONE_PATTERN = /^\+?[0-9][0-9\s().-]{5,18}$/;

function isValidPhone(value: string): boolean {
  const digits = value.replace(/\D/g, '');
  return PHONE_PATTERN.test(value.trim()) && digits.length >= 7 && digits.length <= 15;
}

function validateAddress(address: CheckoutDeliveryAddress): Partial<Record<AddressField, string>> {
  const errors: Partial<Record<AddressField, string>> = {};
  if (!address.line1?.trim()) errors.line1 = 'Enter the street address.';
  if (!address.city?.trim()) errors.city = 'Enter the city.';
  if (!address.country?.trim()) errors.country = 'Enter the country.';
  const phone = address.phone?.trim() ?? '';
  if (!phone) errors.phone = 'Enter a phone number for the courier.';
  else if (!isValidPhone(phone)) errors.phone = 'Use 7–15 digits, e.g. +254 712 345 678.';
  return errors;
}

/**
 * Fulfillment types this cart can actually fulfill.
 *
 * Digital is always possible. Pickup and delivery are added only by a product
 * that lists them in `delivery_modes`, matching the backend's own
 * `_suggested_fulfillment` composition rules.
 */
function availableFulfillmentTypes(items: CartItemPayload[]): FulfillmentType[] {
  const available = new Set<FulfillmentType>(['digital']);
  for (const item of items) {
    if (item.item_type !== 'product') continue;
    const modes = item.product_detail?.delivery_modes;
    if (!Array.isArray(modes) || modes.length === 0) continue;
    for (const mode of modes) {
      if ((FULFILLMENT_VALUES as readonly string[]).includes(mode)) available.add(mode as FulfillmentType);
    }
  }
  return FULFILLMENT_VALUES.filter((value) => available.has(value));
}

/** True when a physical item is present, which is what unlocks pickup/delivery. */
function hasPhysicalItem(items: CartItemPayload[]): boolean {
  return items.some((item) => item.item_type === 'product');
}

function getItemDetail(item: CartItemPayload): Record<string, unknown> | null {
  const fk = ITEM_FK_KEYS[item.item_type];
  return (fk && item[`${fk}_detail` as keyof CartItemPayload] as Record<string, unknown> | undefined) || null;
}

function getItemName(item: CartItemPayload): string {
  const detail = getItemDetail(item);
  if (!detail) return item.item_type.replace('_', ' ');
  if (item.item_type === 'product') return String(detail.name ?? 'Product');
  return String(detail.title ?? detail.name ?? item.item_type.replace('_', ' '));
}

function getItemImage(item: CartItemPayload): string | null {
  const detail = getItemDetail(item);
  if (!detail) return null;
  if (item.item_type === 'product') return (detail.image_url as string) ?? null;
  return (detail.cover_image_url as string) ?? null;
}

function artifactDisplay(artifacts: Record<string, number> | null | undefined): string {
  if (!artifacts) return '';
  return Object.entries(artifacts)
    .filter(([, v]) => v > 0)
    .map(([k, v]) => `${v} ${k}`)
    .join(', ');
}

/**
 * Savings the cart endpoint does not spell out.
 *
 * `total_artifacts` is already post-discount while each line's
 * `item_total_artifacts` is not, so the gap between the summed lines and the
 * total is exactly what the discount took off.
 */
function deriveSavings(items: CartItemPayload[], total: Record<string, number> | undefined): Record<string, number> {
  const original: Record<string, number> = {};
  for (const item of items) {
    for (const [type, qty] of Object.entries(item.item_total_artifacts ?? {})) {
      original[type] = (original[type] ?? 0) + qty;
    }
  }
  const savings: Record<string, number> = {};
  for (const [type, qty] of Object.entries(original)) {
    const delta = qty - (total?.[type] ?? 0);
    if (delta > 0) savings[type] = delta;
  }
  return savings;
}

interface AddressFormProps {
  value: CheckoutDeliveryAddress;
  errorFor: (field: AddressField) => string | undefined;
  onChange: (field: AddressField, value: string) => void;
  onBlur: (field: AddressField) => void;
}

function AddressForm({ value, errorFor, onChange, onBlur }: AddressFormProps) {
  return (
    <div className="space-y-3 rounded-xl bg-buddy-surface-raised/40 p-3" role="group" aria-label="Delivery address">
      <div className="flex items-center gap-1.5 text-xs font-semibold text-buddy-text-secondary">
        <MapPin size={12} className="text-buddy-green" /> Delivery address
      </div>
      <Input
        label="Address line 1"
        value={value.line1 ?? ''}
        onChange={(e) => onChange('line1', e.target.value)}
        onBlur={() => onBlur('line1')}
        error={errorFor('line1')}
        placeholder="Mombasa Road, Westlands"
        autoComplete="address-line1"
      />
      <Input
        label="Address line 2"
        helperText="Apartment, floor or landmark (optional)"
        value={value.line2 ?? ''}
        onChange={(e) => onChange('line2', e.target.value)}
        onBlur={() => onBlur('line2')}
        error={errorFor('line2')}
        autoComplete="address-line2"
      />
      <div className="grid grid-cols-2 gap-3">
        <Input
          label="City"
          value={value.city ?? ''}
          onChange={(e) => onChange('city', e.target.value)}
          onBlur={() => onBlur('city')}
          error={errorFor('city')}
          autoComplete="address-level2"
        />
        <Input
          label="Postal code"
          helperText="Optional"
          value={value.postal_code ?? ''}
          onChange={(e) => onChange('postal_code', e.target.value)}
          onBlur={() => onBlur('postal_code')}
          error={errorFor('postal_code')}
          autoComplete="postal-code"
        />
      </div>
      <div className="grid grid-cols-2 gap-3">
        <Input
          label="Country"
          value={value.country ?? ''}
          onChange={(e) => onChange('country', e.target.value)}
          onBlur={() => onBlur('country')}
          error={errorFor('country')}
          autoComplete="country-name"
        />
        <Input
          label="Phone"
          value={value.phone ?? ''}
          onChange={(e) => onChange('phone', e.target.value)}
          onBlur={() => onBlur('phone')}
          error={errorFor('phone')}
          helperText="For the courier"
          placeholder="+254 712 345 678"
          inputMode="tel"
          autoComplete="tel"
        />
      </div>
      <div>
        <label htmlFor="checkout-delivery-notes" className="block text-sm font-medium text-buddy-text-secondary mb-1.5">
          Notes
        </label>
        <textarea
          id="checkout-delivery-notes"
          rows={2}
          value={value.notes ?? ''}
          onChange={(e) => onChange('notes', e.target.value)}
          onBlur={() => onBlur('notes')}
          placeholder="Gate code, best time to drop off (optional)"
          className="w-full bg-buddy-surface border border-transparent rounded-xl px-4 py-3 text-buddy-text-primary placeholder:text-buddy-text-secondary/50 font-body text-sm transition-colors focus:outline-none focus:ring-2 focus:ring-buddy-green/30 resize-none"
        />
        {errorFor('notes') && <p className="mt-1 text-sm text-buddy-red">{errorFor('notes')}</p>}
      </div>
    </div>
  );
}

interface StationPickerProps {
  stations: PickupStation[];
  loading: boolean;
  located: boolean;
  locating: boolean;
  unavailable: boolean;
  error: string | null;
  query: string;
  manualLocation: string;
  selectedId: string | null;
  selectionError: string | undefined;
  manualError: string | undefined;
  onQueryChange: (value: string) => void;
  onManualChange: (value: string) => void;
  onSelect: (id: string) => void;
  onUseLocation: () => void;
}

function StationPicker({
  stations, loading, located, locating, unavailable, error, query, manualLocation,
  selectedId, selectionError, manualError, onQueryChange, onManualChange, onSelect, onUseLocation,
}: StationPickerProps) {
  const needle = query.trim().toLowerCase();
  const visible = needle
    ? stations.filter((station) =>
        [station.name, stationAreaLabel(station), station.instructions, station.city].some((value) =>
          typeof value === 'string' && value.toLowerCase().includes(needle),
        ),
      )
    : stations;

  return (
    <div className="space-y-3 rounded-xl bg-buddy-surface-raised/40 p-3" role="group" aria-label="Pickup station">
      <div className="flex items-center justify-between gap-2">
        <p className="text-xs font-semibold flex items-center gap-1.5">
          <Store size={12} className="text-buddy-green" /> Pickup station
        </p>
        {!located && (
          <button
            type="button"
            onClick={onUseLocation}
            disabled={locating}
            className="inline-flex items-center gap-1 text-xs font-medium text-buddy-green disabled:opacity-50"
          >
            <Navigation size={11} /> {locating ? 'Locating…' : 'Use my location'}
          </button>
        )}
      </div>

      {!located && !loading && (
        <p className="text-xs text-buddy-text-secondary">
          No location shared, so stations are not ranked by distance — search by name or area instead.
        </p>
      )}

      {stations.length > 0 && !located && (
        <Input
          label="Search stations"
          value={query}
          onChange={(e) => onQueryChange(e.target.value)}
          placeholder="Search by name or area"
        />
      )}

      {loading && (
        <div className="space-y-2" aria-busy="true">
          {[0, 1].map((i) => (
            <div key={i} className="h-14 rounded-xl bg-buddy-surface-raised animate-pulse" />
          ))}
        </div>
      )}

      {!loading && stations.length > 0 && visible.length === 0 && (
        <p className="text-xs text-buddy-text-secondary">No station matches “{query.trim()}”.</p>
      )}

      {!loading && visible.length > 0 && (
        <div className="space-y-2">
          {visible.map((station, index) => {
            const id = String(station.id ?? '');
            const distance = hasStationDistance(station) ? formatDistance(station.distance_km) : null;
            return (
              <label
                key={id || station.name}
                className={`flex gap-2.5 rounded-xl border p-3 cursor-pointer transition-colors ${
                  selectedId === id
                    ? 'border-buddy-green bg-buddy-green/10'
                    : 'border-buddy-surface-raised hover:border-buddy-text-secondary/30'
                }`}
              >
                <input
                  type="radio"
                  name="pickup-station"
                  value={id}
                  checked={selectedId === id}
                  onChange={() => onSelect(id)}
                  className="mt-1 accent-buddy-green"
                />
                <span className="flex-1 min-w-0">
                  <span className="flex flex-wrap items-center gap-2">
                    <span className="text-sm font-medium">{station.name || 'Pickup station'}</span>
                    {station.is_primary && <Badge variant="gold" label="Primary" size="sm" />}
                    {index === 0 && distance && <Badge variant="green" label="Nearest" size="sm" />}
                  </span>
                  <span className="mt-0.5 block text-xs text-buddy-text-secondary">{stationAreaLabel(station)}</span>
                  <span className="mt-0.5 block text-xs text-buddy-text-secondary">
                    {stationOpeningHoursLabel(station.opening_hours)}
                  </span>
                  {distance && <span className="mt-0.5 block text-xs text-buddy-text-secondary">{distance}</span>}
                </span>
              </label>
            );
          })}
        </div>
      )}

      {selectionError && (
        <p className="text-xs font-medium text-buddy-red">{selectionError}</p>
      )}

      {!loading && stations.length === 0 && (
        <div className="space-y-2">
          <p className="text-xs text-buddy-text-secondary">
            {unavailable
              ? 'Station picking is unavailable right now, so tell us where to hand the order over.'
              : 'No pickup stations are listed yet, so tell us where to hand the order over.'}
          </p>
          {error && (
            <p className="flex items-start gap-1.5 text-xs text-buddy-gold">
              <AlertCircle size={12} className="mt-0.5 flex-shrink-0" /> {error}
            </p>
          )}
          <Input
            label="Collection point"
            value={manualLocation}
            onChange={(e) => onManualChange(e.target.value)}
            error={manualError ?? undefined}
            placeholder="e.g. Karura Fitness, Westlands"
          />
        </div>
      )}
    </div>
  );
}

interface Placement {
  result: CheckoutResult;
  method: CheckoutPaymentMethod;
  fulfillment: FulfillmentType;
  station: PickupStation | null;
  stationManual: string;
  address: CheckoutDeliveryAddress | null;
}

function paymentStatusBadge(status: string): { variant: 'green' | 'gold' | 'red' | 'silver'; label: string } {
  switch (status) {
    case 'paid':
    case 'succeeded':
      return { variant: 'green', label: 'Paid' };
    case 'pending':
    case 'awaiting_confirmation':
    case 'initiated':
      return { variant: 'gold', label: 'Awaiting provider confirmation' };
    case 'failed':
      return { variant: 'red', label: 'Failed' };
    case 'refunded':
      return { variant: 'silver', label: 'Refunded' };
    default:
      return { variant: 'silver', label: status.replace(/_/g, ' ') };
  }
}

export default function CheckoutPage() {
  const navigate = useNavigate();
  const { toast } = useToast();

  const [cart, setCart] = useState<CartPayload | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [balance, setBalance] = useState<BalanceItem[]>([]);
  const [balanceLoaded, setBalanceLoaded] = useState(false);

  const [fulfillmentType, setFulfillmentType] = useState<FulfillmentType>('digital');
  const fulfillmentTouched = useRef(false);

  const [address, setAddress] = useState<CheckoutDeliveryAddress>({});
  const [addressTouched, setAddressTouched] = useState<Partial<Record<AddressField, boolean>>>({});

  const [coords, setCoords] = useState<Coords | null>(null);
  const [locating, setLocating] = useState(false);
  const [stations, setStations] = useState<PickupStation[]>([]);
  const [stationsLoading, setStationsLoading] = useState(false);
  const [stationsDown, setStationsDown] = useState(false);
  const [stationsError, setStationsError] = useState<string | null>(null);
  const [stationId, setStationId] = useState<string | null>(null);
  const [stationQuery, setStationQuery] = useState('');
  const [manualPickup, setManualPickup] = useState('');

  const [paymentMethod, setPaymentMethod] = useState<CheckoutPaymentMethod>('artifacts');
  const [mpesaPhone, setMpesaPhone] = useState('');

  const [attempted, setAttempted] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [serverError, setServerError] = useState<string | null>(null);
  const [placement, setPlacement] = useState<Placement | null>(null);
  const [paymentIntent, setPaymentIntent] = useState<PaymentIntent | null>(null);
  const [intentError, setIntentError] = useState<string | null>(null);

  const fetchCart = useCallback(() => {
    setIsLoading(true);
    setLoadError(null);
    Promise.all([marketplaceApi.getCart(), walletApi.getBalance().catch(() => null)])
      .then(([cartRes, balRes]) => {
        const data = cartRes?.data ?? null;
        setCart(data);
        if (balRes?.data?.regular_balance) {
          setBalance(balRes.data.regular_balance);
          setBalanceLoaded(true);
        }
        const suggested = data?.suggested_fulfillment?.type as FulfillmentType | undefined;
        if (!fulfillmentTouched.current && suggested) {
          // Only honour the server's suggestion when this cart can fulfill it.
          if (availableFulfillmentTypes(data?.items ?? []).includes(suggested)) setFulfillmentType(suggested);
        }
        const pickup = (data?.suggested_fulfillment?.detail as { pickup_location?: unknown } | undefined)?.pickup_location;
        if (typeof pickup === 'string' && pickup) setManualPickup((prev) => prev || pickup);
      })
      .catch((err) => setLoadError(checkoutErrorMessage(err, 'We could not load your cart.')))
      .finally(() => setIsLoading(false));
  }, []);

  useEffect(() => { fetchCart(); }, [fetchCart]);

  const locate = useCallback(() => {
    if (typeof navigator === 'undefined' || !('geolocation' in navigator)) return;
    setLocating(true);
    requestLocation()
      .then((next) => setCoords(next))
      .catch(() => undefined)
      .finally(() => setLocating(false));
  }, []);

  useEffect(() => { locate(); }, [locate]);

  const items = useMemo(() => cart?.items ?? [], [cart]);
  const itemCount = items.reduce((sum, item) => sum + (item.quantity ?? 0), 0);
  const availableTypes = useMemo(() => availableFulfillmentTypes(items), [items]);
  const physical = useMemo(() => hasPhysicalItem(items), [items]);
  const fulfillment: FulfillmentType = availableTypes.includes(fulfillmentType) ? fulfillmentType : 'digital';

  useEffect(() => {
    if (placement || fulfillment !== 'pickup') return;
    let cancelled = false;
    setStationsLoading(true);
    setStationsError(null);
    setStationsDown(false);
    stationsApi
      .list({ lat: coords?.lat, lng: coords?.lng, radius_km: coords ? 25 : undefined })
      .then((res) => {
        if (cancelled) return;
        setStations(sortStationsByDistance(res?.data ?? []));
      })
      .catch((err) => {
        if (cancelled) return;
        setStations([]);
        setStationsDown(isStationsUnavailable(err));
        setStationsError(stationsErrorMessage(err, 'Pickup stations could not be loaded.'));
      })
      .finally(() => {
        if (!cancelled) setStationsLoading(false);
      });
    return () => { cancelled = true; };
  }, [coords, fulfillment, placement]);

  const baseCurrency = cart?.base_currency || 'USD';
  const localCurrency = cart?.local_currency || 'KES';
  const conversionRate = cart?.conversion_rate ?? 0;
  const totalUsd = cart?.total_usd ?? 0;
  const totalLocal = cart?.total_local_currency ?? totalUsd * conversionRate;
  const totals = cart?.total_artifacts ?? {};
  const savings = useMemo(() => deriveSavings(items, cart?.total_artifacts), [items, cart?.total_artifacts]);
  const discountLabel = (() => {
    const discount = cart?.discount_code;
    if (!discount) return null;
    if (discount.discount_type === 'percentage' && discount.discount_pct) return `${discount.code} — ${discount.discount_pct}% off`;
    if (discount.discount_type === 'fixed_artifacts') return `${discount.code} — fixed artifact discount`;
    return discount.code || null;
  })();

  const balanceFor = (type: string) => balance.find((b) => b.artifact_type === type)?.quantity ?? 0;
  /**
   * Payment gate. The wallet read is the only evidence we have of what the buyer
   * holds, so a shortfall is only asserted once that read succeeded — an
   * unreadable balance is not proof of a shortage, and the server still has the
   * final say. Artifacts are disabled when short; M-Pesa and Card always work,
   * which is why a short cart never blocks the page outright.
   */
  const shortfall = balanceLoaded
    ? Object.entries(totals).filter(([, qty]) => qty > 0).find(([type, qty]) => balanceFor(type) < qty) ?? null
    : null;
  const methodEnabled: Record<CheckoutPaymentMethod, boolean> = {
    artifacts: !shortfall,
    mpesa: true,
    card: true,
  };
  const enabledMethods = PAYMENT_OPTIONS.filter((option) => methodEnabled[option.value]);
  const method: CheckoutPaymentMethod | null =
    enabledMethods.find((option) => option.value === paymentMethod)?.value ?? null;
  const afterPurchase = (type: string) => Math.max(0, balanceFor(type) - (totals[type] || 0));
  /** Name the rail being charged, not just the button — the amount differs per rail. */
  const payLabel = !method
    ? 'Confirm Order'
    : method === 'artifacts'
      ? `Pay ${artifactDisplay(totals) || ''}`.trim()
      : conversionRate > 0
        ? `Pay ${localCurrency} ${totalLocal.toFixed(2)}`
        : method === 'mpesa'
          ? 'Pay with M-Pesa'
          : 'Pay with Card';

  const addressErrors = useMemo(() => validateAddress(address), [address]);
  const errorFor = (field: AddressField): string | undefined =>
    attempted || addressTouched[field] ? addressErrors[field] : undefined;
  const stationSelectionError =
    attempted && fulfillment === 'pickup' && stations.length > 0 && !stationId
      ? 'Choose the station you will collect from.'
      : undefined;
  const manualPickupError =
    attempted && fulfillment === 'pickup' && stations.length === 0 && !manualPickup.trim()
      ? 'Enter where you will collect the order.'
      : undefined;
  const mpesaPhoneError =
    attempted && method === 'mpesa' && !isValidPhone(mpesaPhone.trim())
      ? 'Enter the M-Pesa number to charge, e.g. 0712 345 678.'
      : undefined;

  const selectedStation = useMemo(
    () => stations.find((station) => station.id === stationId) ?? null,
    [stations, stationId],
  );

  const setAddressField = (field: AddressField, value: string) => {
    setAddress((prev) => ({ ...prev, [field]: value }));
    setServerError(null);
  };

  const touchAddress = (field: AddressField) =>
    setAddressTouched((prev) => ({ ...prev, [field]: true }));

  const choosePayment = (value: CheckoutPaymentMethod) => {
    if (!methodEnabled[value]) return;
    setPaymentMethod(value);
    setServerError(null);
    if (value === 'mpesa') setMpesaPhone((prev) => prev || (address.phone ?? ''));
  };

  const handleSubmit = async (event: FormEvent) => {
    event.preventDefault();
    setAttempted(true);
    setServerError(null);

    // Client-side gate first: never spend a round trip on a form we know is
    // incomplete, and never clear what the buyer typed to say so.
    if (!method) {
      setServerError('Choose how you want to pay.');
      return;
    }
    if (fulfillment === 'delivery' && Object.keys(addressErrors).length > 0) {
      setServerError('Check the delivery address — a few fields still need attention.');
      return;
    }
    if (fulfillment === 'pickup') {
      if (stations.length > 0 && !stationId) {
        setServerError('Choose a pickup station to continue.');
        return;
      }
      if (stations.length === 0 && !manualPickup.trim()) {
        setServerError('Enter a collection point to continue.');
        return;
      }
    }
    if (method === 'mpesa' && !isValidPhone(mpesaPhone.trim())) {
      setServerError('Enter a valid M-Pesa phone number to continue.');
      return;
    }

    const payload: CheckoutPayload = { fulfillment_type: fulfillment, payment_method: method };
    if (fulfillment === 'delivery') {
      payload.delivery_address = {
        line1: address.line1?.trim(),
        line2: address.line2?.trim(),
        city: address.city?.trim(),
        postal_code: address.postal_code?.trim(),
        country: address.country?.trim(),
        phone: address.phone?.trim(),
        notes: address.notes?.trim(),
      };
    }
    if (fulfillment === 'pickup') {
      payload.pickup_station_id = selectedStation?.id ?? null;
      payload.pickup_details = {
        venue: selectedStation?.name,
        location: selectedStation?.name ?? manualPickup.trim(),
        instructions: selectedStation?.instructions ?? '',
      };
    }

    setSubmitting(true);
    try {
      const res = await marketplaceApi.checkoutCart(payload);
      const result = res?.data;
      // No order reference means we cannot prove what was charged. Failing loud
      // beats letting the buyer retry into a duplicate order.
      if (!result?.order_id) {
        setServerError('Checkout returned an unexpected response. Check your orders before trying again.');
        return;
      }
      setPlacement({
        result,
        method,
        fulfillment,
        station: selectedStation,
        stationManual: manualPickup.trim(),
        address: fulfillment === 'delivery' ? { ...payload.delivery_address } : null,
      });
      setPaymentIntent(null);
      setIntentError(null);
      toast('success', 'Order placed!');

      const newBalance = result.new_balance;
      if (newBalance && Object.keys(newBalance).length > 0) {
        setBalance((prev) =>
          prev.map((entry) =>
            newBalance[entry.artifact_type] !== undefined
              ? { ...entry, quantity: newBalance[entry.artifact_type] }
              : entry,
          ),
        );
      } else {
        walletApi.getBalance()
          .then((b) => b.data?.regular_balance && setBalance(b.data.regular_balance))
          .catch(() => {});
      }
      window.dispatchEvent(new CustomEvent('cart-updated'));

      // Real money settles asynchronously. A missing endpoint must not cost the
      // buyer their receipt, so a failure here is noted on the receipt instead.
      if (method !== 'artifacts') {
        stationsApi
          .createPaymentIntent({
            order_id: result.order_id,
            method,
            ...(method === 'mpesa' && mpesaPhone.trim() ? { phone: mpesaPhone.trim() } : {}),
          })
          .then((intentRes) => setPaymentIntent(intentRes?.data ?? null))
          .catch((err) => setIntentError(stationsErrorMessage(err, 'We could not start this payment. Retry it from the order page.')));
      }
    } catch (err) {
      // Inline, with the server's own wording (e.g. "Insufficient dumbbell
      // tokens."), and every field left exactly as the buyer left it.
      const message = checkoutErrorMessage(err);
      setServerError(message);
      toast('error', message);
    } finally {
      setSubmitting(false);
    }
  };

  const receipt = placement?.result ?? null;
  const receiptUsd = receipt?.spent_usd ?? totalUsd;
  const receiptLocal = receipt?.spent_usd != null ? receipt.spent_usd * conversionRate : totalLocal;
  const receiptPaymentStatus = receipt?.payment_status ?? (placement?.method === 'artifacts' ? 'paid' : 'pending');
  const receiptStationName = placement?.station?.name || placement?.stationManual || '';
  const receiptAddress = receipt?.delivery_address ?? placement?.address ?? null;

  return (
    <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto p-4 space-y-4">
      <div className="flex items-center gap-3 mb-2">
        <button onClick={() => navigate('/marketplace/cart')} className="p-2 rounded-full hover:bg-buddy-surface">
          <ChevronLeft size={20} />
        </button>
        <h1 className="font-display text-2xl font-extrabold">Checkout</h1>
        {itemCount > 0 && <Badge variant="green" label={`${itemCount}`} size="sm" />}
      </div>

      {isLoading ? (
        <div className="space-y-3">
          {Array.from({ length: 3 }).map((_, i) => (
            <Card key={i} className="p-4 animate-pulse"><div className="h-16 bg-buddy-surface-raised rounded-xl" /></Card>
          ))}
        </div>
      ) : loadError ? (
        <div className="rounded-xl bg-buddy-red/10 border border-buddy-red/30 px-4 py-3 text-sm text-buddy-red space-y-3">
          <p>{loadError}</p>
          <Button variant="outline" size="sm" onClick={fetchCart}>Try again</Button>
        </div>
      ) : items.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 text-buddy-text-secondary">
          <Coins size={48} className="mb-4 opacity-30" />
          <p className="text-lg font-medium mb-1">There is nothing to check out</p>
          <p className="text-sm mb-6">Add something from the marketplace first</p>
          <Button onClick={() => navigate('/marketplace')} variant="primary">Browse Marketplace</Button>
        </div>
      ) : receipt && placement ? (
        /* ---------------- Receipt ---------------- */
        <div className="space-y-4">
          <Card className="p-5 space-y-4">
            <div className="flex flex-col items-center gap-2 py-1 text-center">
              <CheckCircle2 size={44} className="text-buddy-green" />
              <p className="font-display text-lg font-extrabold">Order placed</p>
              <p className="text-sm text-buddy-text-secondary">
                Order #{receipt.order_number || receipt.order_id.slice(0, 8).toUpperCase()}
              </p>
            </div>

            <div className="grid grid-cols-2 gap-2 text-sm">
              <div className="rounded-xl bg-buddy-surface-raised/50 p-3">
                <p className="text-xs text-buddy-text-secondary">Paid with</p>
                <p className="font-medium mt-0.5">{PAYMENT_LABELS[placement.method]}</p>
                <div className="mt-1">
                  <Badge variant={paymentStatusBadge(receiptPaymentStatus).variant} label={paymentStatusBadge(receiptPaymentStatus).label} size="sm" />
                </div>
              </div>
              <div className="rounded-xl bg-buddy-surface-raised/50 p-3">
                <p className="text-xs text-buddy-text-secondary">Fulfillment</p>
                <p className="font-medium mt-0.5">{FULFILLMENT_LABELS[placement.fulfillment]}</p>
                <p className="text-xs text-buddy-text-secondary mt-1">Status: {receipt.status || 'paid'}</p>
              </div>
            </div>

            {placement.fulfillment === 'pickup' && (
              <div className="rounded-xl bg-buddy-surface-raised/50 p-3 text-sm">
                <p className="text-xs text-buddy-text-secondary flex items-center gap-1"><Store size={11} /> Collecting from</p>
                <p className="font-medium mt-0.5">{receiptStationName || 'Pickup station'}</p>
                {placement.station && <p className="text-xs text-buddy-text-secondary">{stationAreaLabel(placement.station)}</p>}
                {placement.station?.opening_hours && (
                  <p className="text-xs text-buddy-text-secondary">{stationOpeningHoursLabel(placement.station.opening_hours)}</p>
                )}
              </div>
            )}

            {placement.fulfillment === 'delivery' && receiptAddress && (
              <div className="rounded-xl bg-buddy-surface-raised/50 p-3 text-sm">
                <p className="text-xs text-buddy-text-secondary flex items-center gap-1"><Truck size={11} /> Delivering to</p>
                <p className="font-medium mt-0.5">{[receiptAddress.line1, receiptAddress.line2].filter(Boolean).join(', ')}</p>
                <p className="text-xs text-buddy-text-secondary">
                  {[receiptAddress.city, receiptAddress.postal_code, receiptAddress.country].filter(Boolean).join(', ')}
                </p>
                {receiptAddress.phone && <p className="text-xs text-buddy-text-secondary">{receiptAddress.phone}</p>}
                {receiptAddress.notes && <p className="text-xs text-buddy-text-secondary mt-0.5">{receiptAddress.notes}</p>}
              </div>
            )}

            {placement.method !== 'artifacts' && (
              <div className="rounded-xl bg-buddy-gold/10 border border-buddy-gold/25 p-3 text-xs text-buddy-text-secondary space-y-1">
                <p>
                  {placement.method === 'mpesa'
                    ? 'Approve the M-Pesa prompt on your phone to settle this order.'
                    : 'Your card provider still needs to confirm this payment.'}
                  {' '}The order stays {paymentStatusBadge(receiptPaymentStatus).label.toLowerCase()} until they do.
                </p>
                {paymentIntent?.provider_reference && <p>Reference: {paymentIntent.provider_reference}</p>}
                {paymentIntent?.status && <p>Provider status: {paymentIntent.status.replace(/_/g, ' ')}</p>}
                {intentError && <p className="text-buddy-red">{intentError}</p>}
              </div>
            )}

            <div className="space-y-2 border-t border-buddy-surface-raised pt-3">
              {(receipt.items ?? []).map((item, index) => (
                <div key={index} className="flex items-center justify-between gap-2 text-xs">
                  <span className="truncate">{item.title} × {item.quantity}</span>
                  <span className="font-medium flex-shrink-0">
                    {artifactDisplay(item.paid_artifacts) || artifactDisplay(item.total_artifacts)}
                  </span>
                </div>
              ))}
            </div>

            <div className="space-y-1.5 text-sm border-t border-buddy-surface-raised pt-3">
              {artifactDisplay(receipt.original_artifacts) && (
                <div className="flex justify-between text-xs">
                  <span className="text-buddy-text-secondary">Original total</span>
                  <span>{artifactDisplay(receipt.original_artifacts)}</span>
                </div>
              )}
              {artifactDisplay(receipt.savings_artifacts) && (
                <div className="flex justify-between text-xs text-buddy-green">
                  <span className="flex items-center gap-1">
                    <Percent size={11} /> Savings{receipt.discount_code ? ` (${receipt.discount_code})` : ''}
                  </span>
                  <span>-{artifactDisplay(receipt.savings_artifacts)}</span>
                </div>
              )}
              <div className="flex justify-between text-base font-bold pt-1 border-t border-buddy-surface-raised">
                <span>You paid</span>
                <span className="text-buddy-green">{artifactDisplay(receipt.total_artifacts)}</span>
              </div>
              <div className="flex justify-between text-xs text-buddy-text-secondary">
                <span className="flex items-center gap-1"><DollarSign size={11} /> Value ({baseCurrency})</span>
                <span>{baseCurrency} {receiptUsd.toFixed(2)}</span>
              </div>
              {conversionRate > 0 && (
                <div className="flex justify-between text-xs text-buddy-text-secondary">
                  <span>Value ({localCurrency})</span>
                  <span>{localCurrency} {receiptLocal.toFixed(2)}</span>
                </div>
              )}
              {artifactDisplay(receipt.new_balance) && (
                <div className="flex justify-between text-xs text-buddy-text-secondary">
                  <span>Remaining balance</span>
                  <span>{artifactDisplay(receipt.new_balance)}</span>
                </div>
              )}
            </div>

            <div className="space-y-2">
              <Button className="w-full" onClick={() => navigate(`/marketplace/orders/${receipt.order_id}`)}>
                View Order
              </Button>
              <Button variant="ghost" className="w-full" onClick={() => navigate('/marketplace')}>
                Back to Marketplace
              </Button>
            </div>
          </Card>
        </div>
      ) : (
        /* ---------------- Review & confirm ---------------- */
        <form noValidate onSubmit={handleSubmit} className="space-y-4">
          <Card className="p-4 space-y-3">
            <h2 className="text-sm font-semibold flex items-center gap-2">
              <Coins size={14} className="text-buddy-green" /> Order summary
            </h2>
            <div className="space-y-2">
              {items.map((item) => {
                const Icon = ITEM_ICONS[item.item_type] || Coins;
                const image = getItemImage(item);
                return (
                  <div key={item.id} className="flex gap-3 items-center">
                    <div className="w-12 h-12 bg-buddy-surface-raised rounded-xl flex items-center justify-center flex-shrink-0 overflow-hidden">
                      {image
                        ? <img src={image} alt="" className="w-full h-full object-cover" />
                        : <Icon size={18} className="text-buddy-text-secondary/40" />}
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium truncate">{getItemName(item)}</p>
                      <p className="text-xs text-buddy-text-secondary">× {item.quantity}</p>
                    </div>
                    <div className="text-right flex-shrink-0">
                      {artifactDisplay(item.item_total_artifacts) && (
                        <p className="text-xs font-medium text-buddy-green">{artifactDisplay(item.item_total_artifacts)}</p>
                      )}
                      {typeof item.item_total_usd === 'number' && item.item_total_usd > 0 && (
                        <p className="text-xs text-buddy-text-secondary">
                          {baseCurrency} {item.item_total_usd.toFixed(2)}
                          {conversionRate > 0 && ` · ${localCurrency} ${(item.item_total_usd * conversionRate).toFixed(2)}`}
                        </p>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>

            <div className="space-y-1.5 text-sm border-t border-buddy-surface-raised pt-3">
              {discountLabel && (
                <div className="flex justify-between text-xs text-buddy-green">
                  <span className="font-mono">{discountLabel}</span>
                  <span>applied at checkout</span>
                </div>
              )}
              {artifactDisplay(savings) && (
                <div className="flex justify-between text-xs text-buddy-green">
                  <span className="flex items-center gap-1"><Percent size={11} /> You save</span>
                  <span>-{artifactDisplay(savings)}</span>
                </div>
              )}
              <div className="flex justify-between">
                <span className="text-buddy-text-secondary">Total in artifacts</span>
                <span className="font-semibold text-buddy-green">{artifactDisplay(totals) || 'Free'}</span>
              </div>
              <div className="flex justify-between">
                <span className="flex items-center gap-1 text-buddy-text-secondary">
                  <DollarSign size={12} /> Total ({baseCurrency})
                </span>
                <span className="font-semibold">{baseCurrency} {totalUsd.toFixed(2)}</span>
              </div>
              {conversionRate > 0 && (
                <div className="flex justify-between">
                  <span className="text-buddy-text-secondary">Total ({localCurrency})</span>
                  <span className="font-semibold">{localCurrency} {totalLocal.toFixed(2)}</span>
                </div>
              )}
            </div>
          </Card>

          <Card className="p-4 space-y-3">
            <h2 className="text-sm font-semibold flex items-center gap-2">
              <Truck size={14} className="text-buddy-green" /> How you get it
            </h2>
            <div className="grid grid-cols-3 gap-2">
              {FULFILLMENT_OPTIONS.filter((option) => availableTypes.includes(option.value)).map(({ value, label, icon: Icon, hint }) => (
                <button
                  key={value}
                  type="button"
                  aria-pressed={fulfillment === value}
                  onClick={() => {
                    fulfillmentTouched.current = true;
                    setFulfillmentType(value);
                    setServerError(null);
                  }}
                  className={`rounded-xl border p-2.5 text-xs font-medium flex flex-col items-center gap-1 transition-colors ${
                    fulfillment === value
                      ? 'border-buddy-green bg-buddy-green/10 text-buddy-green'
                      : 'border-buddy-surface-raised text-buddy-text-secondary hover:border-buddy-text-secondary/30'
                  }`}
                >
                  <Icon size={14} />
                  {label}
                  <span className="text-[10px] font-normal opacity-70 text-center">{hint}</span>
                </button>
              ))}
            </div>
            {!physical && (
              <p className="text-xs text-buddy-text-secondary">
                Meal plans, programmes and event tickets are delivered digitally, so pickup and delivery are not
                offered for this cart.
              </p>
            )}
            {cart?.suggested_fulfillment?.type && fulfillment === cart.suggested_fulfillment.type && (
              <p className="text-xs text-buddy-green">
                Auto-detected: {cart.suggested_fulfillment.type} delivery.
              </p>
            )}

            {fulfillment === 'delivery' && (
              <AddressForm
                value={address}
                errorFor={errorFor}
                onChange={setAddressField}
                onBlur={touchAddress}
              />
            )}

            {fulfillment === 'pickup' && (
              <StationPicker
                stations={stations}
                loading={stationsLoading}
                located={coords !== null}
                locating={locating}
                unavailable={stationsDown}
                error={stationsError}
                query={stationQuery}
                manualLocation={manualPickup}
                selectedId={stationId}
                selectionError={stationSelectionError}
                manualError={manualPickupError}
                onQueryChange={setStationQuery}
                onManualChange={(value) => { setManualPickup(value); setServerError(null); }}
                onSelect={(id) => { setStationId(id); setServerError(null); }}
                onUseLocation={locate}
              />
            )}
          </Card>

          <Card className="p-4 space-y-3">
            <h2 className="text-sm font-semibold flex items-center gap-2">
              <WalletIcon size={14} className="text-buddy-green" /> How you pay
            </h2>
            <p className="text-xs text-buddy-text-secondary">
              Artifacts leave your wallet the moment the order is placed. M-Pesa and Card are only marked paid once
              the provider confirms them.
            </p>
            <div className="space-y-2">
              {PAYMENT_OPTIONS.map(({ value, label, icon: Icon, note }) => {
                const enabled = methodEnabled[value];
                const selected = method === value;
                return (
                  <button
                    key={value}
                    type="button"
                    disabled={!enabled}
                    aria-disabled={!enabled}
                    aria-pressed={selected}
                    onClick={() => choosePayment(value)}
                    className={`w-full rounded-xl border p-3 text-left flex items-start gap-2.5 transition-colors ${
                      selected
                        ? 'border-buddy-green bg-buddy-green/10'
                        : enabled
                          ? 'border-buddy-surface-raised hover:border-buddy-text-secondary/30'
                          : 'border-buddy-surface-raised opacity-60 cursor-not-allowed'
                    }`}
                  >
                    <Icon size={16} className={`mt-0.5 flex-shrink-0 ${selected ? 'text-buddy-green' : 'text-buddy-text-secondary'}`} />
                    <span className="flex-1 min-w-0">
                      <span className="flex flex-wrap items-center gap-2">
                        <span className="text-sm font-medium">{label}</span>
                        {value === 'artifacts' && selected && <Badge variant="green" label="Instant" size="sm" />}
                        {value !== 'artifacts' && selected && <Badge variant="gold" label="Needs confirmation" size="sm" />}
                      </span>
                      <span className="mt-0.5 block text-xs text-buddy-text-secondary">{note}</span>
                      {!enabled && shortfall && value === 'artifacts' && (
                        <span className="mt-1 block text-xs text-buddy-red">
                          This order needs {shortfall[1]} {shortfall[0]}, you have {balanceFor(shortfall[0])}.
                        </span>
                      )}
                      {enabled && value === 'artifacts' && Object.entries(totals).filter(([, qty]) => qty > 0).map(([type]) => (
                        <span key={type} className="mt-1 block text-xs text-buddy-text-secondary">
                          Balance {balanceFor(type)} {type} · {afterPurchase(type)} after this order
                        </span>
                      ))}
                    </span>
                  </button>
                );
              })}
            </div>

            {method === 'mpesa' && (
              <Input
                label="M-Pesa phone"
                value={mpesaPhone}
                onChange={(e) => { setMpesaPhone(e.target.value); setServerError(null); }}
                error={mpesaPhoneError}
                helperText="The number that will receive the payment prompt"
                placeholder="0712 345 678"
                inputMode="tel"
                autoComplete="tel"
              />
            )}
          </Card>

          {shortfall && (
            <div className="rounded-xl bg-buddy-red/10 border border-buddy-red/30 px-4 py-2.5 text-xs text-buddy-red">
              Not enough {shortfall[0]} — this cart needs {shortfall[1]}, you have {balanceFor(shortfall[0])}. Top up in
              Wallet, or pay with M-Pesa or a card.
            </div>
          )}

          {serverError && (
            <div role="alert" className="rounded-xl bg-buddy-red/10 border border-buddy-red/30 px-4 py-2.5 text-xs text-buddy-red">
              {serverError}
            </div>
          )}

          <div className="flex gap-3">
            <Button type="button" variant="ghost" className="flex-1" onClick={() => navigate('/marketplace/cart')} disabled={submitting}>
              Back to Cart
            </Button>
            <Button type="submit" className="flex-1" isLoading={submitting} disabled={submitting || !method}>
              {payLabel}
            </Button>
          </div>
          {!method && (
            <p className="text-center text-xs text-buddy-text-secondary">
              Pick a payment method above to confirm this order.
            </p>
          )}
        </form>
      )}
    </div>
  );
}
