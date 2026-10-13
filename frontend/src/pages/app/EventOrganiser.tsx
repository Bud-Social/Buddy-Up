import { useCallback, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { CalendarRange, CheckCircle2, ClipboardCheck, Copy, RotateCcw, Ticket, Users, ExternalLink } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { Input } from '@/components/ui/Input';
import { ArtifactIcon } from '@/components/ui/ArtifactIcon';
import { marketplaceApi, eventActionErrorMessage, checkoutErrorMessage } from '@/api/marketplace';
import type { CheckInResult, EventAttendee, EventStats, OrganiserEvent } from '@/api/marketplace';
import { RoleDashboardShell, RoleSectionTitle } from './roles/RoleShell';

const TICKET_STATUSES = [
  { value: '', label: 'Any status' },
  { value: 'valid', label: 'Valid' },
  { value: 'used', label: 'Used' },
  { value: 'cancelled', label: 'Cancelled' },
  { value: 'refunded', label: 'Refunded' },
];

/**
 * Organiser dashboard.
 *
 * The check-in panel and the attendee table are the working surface; the event
 * list is the selector. Check-in errors are shown inline and verbatim — the
 * 409 already-checked-in response names who checked the ticket in and when,
 * which is exactly the information a door staff member needs.
 */
export default function EventOrganiser() {
  const navigate = useNavigate();

  const [events, setEvents] = useState<OrganiserEvent[]>([]);
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [stats, setStats] = useState<EventStats | null>(null);
  const [attendees, setAttendees] = useState<EventAttendee[]>([]);

  const [loading, setLoading] = useState(true);
  const [eventsError, setEventsError] = useState<string | null>(null);

  const [code, setCode] = useState('');
  const [checkInBusy, setCheckInBusy] = useState(false);
  const [checkInError, setCheckInError] = useState<string | null>(null);
  const [checkInNotice, setCheckInNotice] = useState<string | null>(null);

  const [checkedIn, setCheckedIn] = useState<'' | boolean>('');
  const [status, setStatus] = useState('');
  const [tier, setTier] = useState('');

  const [copied, setCopied] = useState(false);
  const [attendeesError, setAttendeesError] = useState<string | null>(null);

  const loadEvents = useCallback(async () => {
    setLoading(true);
    setEventsError(null);
    try {
      const res = await marketplaceApi.getOrganisedEvents();
      const rows = Array.isArray(res?.data) ? res.data : [];
      setEvents(rows);
      setSelectedId((current) => current ?? (rows[0]?.id ?? null));
    } catch (e) {
      // 403 = signed in but not an organiser. That is an expected state, so it
      // gets a real message rather than a blank page.
      setEventsError(checkoutErrorMessage(e, 'We could not load your events.'));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { loadEvents(); }, [loadEvents]);

  const loadAttendees = useCallback(async (eventId: string) => {
    setAttendeesError(null);
    try {
      const res = await marketplaceApi.getEventAttendees(eventId, {
        checked_in: checkedIn,
        status: status || undefined,
        tier: tier || undefined,
      });
      setAttendees(Array.isArray(res?.data) ? res.data : []);
    } catch (e) {
      setAttendees([]);
      setAttendeesError(checkoutErrorMessage(e, 'Could not load attendees.'));
    }
  }, [checkedIn, status, tier]);

  useEffect(() => {
    if (!selectedId) return;
    marketplaceApi.getEventStats(selectedId).then((r) => setStats(r.data)).catch(() => setStats(null));
    loadAttendees(selectedId);
  }, [selectedId, loadAttendees]);

  const handleCheckIn = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!code.trim()) return;
    await handleCheckInForCode(code.trim());
  };

  /** Shared by the paste field and the per-row button so both behave identically. */
  const handleCheckInForCode = async (ticketCode: string) => {
    if (!selectedId) return;
    setCheckInBusy(true);
    setCheckInError(null);
    setCheckInNotice(null);
    try {
      const res = await marketplaceApi.checkInAttendee(selectedId, ticketCode);
      // The confirmation may ride on the envelope's `message` or inside `data`;
      // either is the server's wording, so take whichever is present.
      const confirmed = res?.data as CheckInResult | undefined;
      setCheckInNotice(res?.message || confirmed?.message || `Checked in ${ticketCode}.`);
      setCode('');
      await loadAttendees(selectedId);
      marketplaceApi.getEventStats(selectedId).then((r) => setStats(r.data)).catch(() => undefined);
    } catch (err) {
      // 404 unknown code / 409 already checked in / 400 cancelled ticket. The
      // server's message is shown as-is so the attendee detail is not lost.
      setCheckInError(eventActionErrorMessage(err, 'Check-in failed.'));
    } finally {
      setCheckInBusy(false);
    }
  };

  const handleCheckOut = async (attendee: EventAttendee) => {
    if (!selectedId || !attendee.ticket_code) return;
    setCheckInBusy(true);
    setCheckInError(null);
    setCheckInNotice(null);
    try {
      await marketplaceApi.checkOutAttendee(selectedId, attendee.ticket_code);
      setCheckInNotice(`Reversed check-in for ${attendee.ticket_code}.`);
      await loadAttendees(selectedId);
      marketplaceApi.getEventStats(selectedId).then((r) => setStats(r.data)).catch(() => undefined);
    } catch (err) {
      setCheckInError(eventActionErrorMessage(err, 'Could not reverse that check-in.'));
    } finally {
      setCheckInBusy(false);
    }
  };

  const ticketCodes = useMemo(
    () => attendees.map((a) => a.ticket_code).filter((c): c is string => Boolean(c)),
    [attendees],
  );

  const copyCodes = async () => {
    if (ticketCodes.length === 0) return;
    try {
      await navigator.clipboard.writeText(ticketCodes.join('\n'));
      setCopied(true);
      window.setTimeout(() => setCopied(false), 2000);
    } catch {
      setCheckInError('Could not copy to clipboard.');
    }
  };

  const selected = events.find((e) => e.id === selectedId) ?? null;

  return (
    <RoleDashboardShell
      title="My events"
      subtitle="Organise, check in, and track attendance"
      backTo="/marketplace"
      actions={<Button size="sm" variant="outline" onClick={() => navigate('/marketplace/events/create')}><CalendarRange size={14} className="mr-1" /> New event</Button>}
    >
      {eventsError && (
        <div className="bg-buddy-red/5 border border-buddy-red/20 text-buddy-red text-xs rounded-xl px-3 py-2">{eventsError}</div>
      )}

      {loading ? (
        <div className="space-y-3" role="status" aria-busy="true" aria-label="Loading">
          <Card className="h-16 animate-pulse bg-buddy-surface-raised" />
          <Card className="h-16 animate-pulse bg-buddy-surface-raised" />
        </div>
      ) : events.length === 0 ? (
        <Card className="p-8 text-center space-y-2">
          <p className="text-sm text-buddy-text-secondary">You have not created any events yet.</p>
          <Button size="sm" onClick={() => navigate('/marketplace/events/create')}>Create your first event</Button>
        </Card>
      ) : (
        <>
          {/* My events */}
          <section className="space-y-2">
            <RoleSectionTitle>My events</RoleSectionTitle>
            <div className="flex gap-2 overflow-x-auto scrollbar-hide pb-1">
              {events.map((event) => (
                <button
                  key={event.id}
                  onClick={() => setSelectedId(event.id)}
                  aria-pressed={selectedId === event.id}
                  className={`flex-shrink-0 text-left px-3 py-2 rounded-xl border transition-colors ${selectedId === event.id ? 'border-buddy-green bg-buddy-green/15' : 'border-buddy-surface-raised bg-buddy-surface hover:bg-buddy-surface-raised'}`}
                >
                  <p className="text-sm font-semibold truncate max-w-[180px]">{event.title || 'Untitled event'}</p>
                  <p className="text-[11px] text-buddy-text-secondary">{event.start_datetime ? new Date(event.start_datetime).toLocaleDateString() : 'No date'}</p>
                </button>
              ))}
            </div>
            {selected && (
              <div className="flex items-center gap-2 text-xs text-buddy-text-secondary">
                {selected.is_cancelled && <Badge variant="red" label="Cancelled" size="sm" />}
                {!selected.is_published && !selected.is_cancelled && <Badge variant="silver" label="Draft" size="sm" />}
                <Button size="sm" variant="ghost" onClick={() => navigate(`/marketplace/events/${selected.id}`)}>
                  View event page <ExternalLink size={12} className="ml-1" />
                </Button>
              </div>
            )}
          </section>

          {selected && (
            <>
              {/* Stats */}
              <section className="space-y-2">
                <RoleSectionTitle>Attendance</RoleSectionTitle>
                <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                  <Card className="p-3">
                    <p className="text-xs text-buddy-text-secondary">Tickets sold</p>
                    <p className="font-display font-extrabold text-xl">{stats?.tickets_sold ?? selected.tickets_sold_count ?? 0}</p>
                  </Card>
                  <Card className="p-3">
                    <p className="text-xs text-buddy-text-secondary">Checked in</p>
                    <p className="font-display font-extrabold text-xl text-buddy-green">{stats?.checked_in ?? 0}</p>
                  </Card>
                  <Card className="p-3">
                    <p className="text-xs text-buddy-text-secondary">Capacity</p>
                    <p className="font-display font-extrabold text-xl">{stats?.capacity ?? selected.capacity ?? 0}</p>
                  </Card>
                  <Card className="p-3">
                    <p className="text-xs text-buddy-text-secondary">Gross</p>
                    <p className="font-display font-extrabold text-xl">
                      {Object.keys(stats?.gross_artifacts || {}).length
                        ? <ArtifactIcon artifact={Object.keys(stats!.gross_artifacts!)[0]} quantity={Object.values(stats!.gross_artifacts!)[0]} size={18} />
                        : '—'}
                    </p>
                  </Card>
                </div>
                {Array.isArray(stats?.sold_by_tier) && stats.sold_by_tier.length > 0 && (
                  <Card className="p-4 space-y-2">
                    <p className="text-xs font-bold text-buddy-text-secondary uppercase">Sold by tier</p>
                    {stats.sold_by_tier.map((row, i) => (
                      <div key={i} className="flex items-center justify-between text-xs">
                        <span className="capitalize">{row.tier || 'General'}</span>
                        <span className="text-buddy-text-secondary">{row.count ?? 0} sold</span>
                      </div>
                    ))}
                  </Card>
                )}
              </section>

              {/* Check-in */}
              <section className="space-y-2">
                <RoleSectionTitle>Check-in</RoleSectionTitle>
                <Card className="p-4 space-y-3">
                  <form onSubmit={handleCheckIn} className="flex flex-col sm:flex-row gap-2 sm:items-end">
                    <div className="flex-1">
                      <Input
                        label="Ticket code"
                        placeholder="Paste or type a ticket code"
                        value={code}
                        onChange={(e: React.ChangeEvent<HTMLInputElement>) => setCode(e.target.value)}
                      />
                    </div>
                    <Button type="submit" isLoading={checkInBusy} disabled={!code.trim()}>
                      <ClipboardCheck size={14} className="mr-1" /> Check in
                    </Button>
                  </form>
                  {checkInError && (
                    <div className="bg-buddy-red/5 border border-buddy-red/20 text-buddy-red text-xs rounded-xl px-3 py-2" role="alert">{checkInError}</div>
                  )}
                  {checkInNotice && (
                    <div className="bg-buddy-green/10 border border-buddy-green/20 text-buddy-green text-xs rounded-xl px-3 py-2" role="status">{checkInNotice}</div>
                  )}
                </Card>
              </section>

              {/* Attendees */}
              <section className="space-y-2">
                <RoleSectionTitle
                  action={ticketCodes.length > 0 && (
                    <Button size="sm" variant="ghost" onClick={copyCodes}>
                      {copied ? <CheckCircle2 size={12} className="mr-1" /> : <Copy size={12} className="mr-1" />}
                      {copied ? 'Copied' : 'Copy codes'}
                    </Button>
                  )}
                >
                  Attendees ({attendees.length})
                </RoleSectionTitle>

                <Card className="p-3 flex flex-wrap items-center gap-2">
                  <div role="group" aria-label="Checked-in filter" className="flex items-center gap-1.5">
                    <span className="text-xs text-buddy-text-secondary">Check-in</span>
                    {[
                      { value: '' as const, label: 'All' },
                      { value: false as const, label: 'Not in' },
                      { value: true as const, label: 'In' },
                    ].map((opt) => (
                      <button
                        key={String(opt.value)}
                        onClick={() => setCheckedIn(opt.value)}
                        aria-pressed={checkedIn === opt.value}
                        className={`px-2 py-1 text-[11px] font-semibold rounded-lg transition-colors ${checkedIn === opt.value ? 'bg-buddy-green/15 text-buddy-green' : 'text-buddy-text-secondary hover:bg-buddy-surface-raised'}`}
                      >
                        {opt.label}
                      </button>
                    ))}
                  </div>
                  <label className="inline-flex items-center gap-1.5 text-xs text-buddy-text-secondary">
                    <span>Status</span>
                    <select value={status} onChange={(e) => setStatus(e.target.value)} aria-label="Filter by ticket status" className="bg-buddy-surface-raised border border-buddy-surface rounded-lg px-2 py-1.5 text-xs focus:outline-none focus:border-buddy-green">
                      {TICKET_STATUSES.map((s) => <option key={s.value} value={s.value}>{s.label}</option>)}
                    </select>
                  </label>
                  <label className="inline-flex items-center gap-1.5 text-xs text-buddy-text-secondary">
                    <span>Tier</span>
                    <input
                      value={tier}
                      onChange={(e) => setTier(e.target.value)}
                      placeholder="Any tier"
                      aria-label="Filter by tier"
                      className="bg-buddy-surface-raised border border-buddy-surface rounded-lg px-2 py-1.5 text-xs focus:outline-none focus:border-buddy-green"
                    />
                  </label>
                </Card>

                {attendeesError && (
                  <div className="bg-buddy-red/5 border border-buddy-red/20 text-buddy-red text-xs rounded-xl px-3 py-2">{attendeesError}</div>
                )}

                {attendees.length === 0 ? (
                  <Card className="p-8 text-center text-buddy-text-secondary">
                    <Users size={28} className="mx-auto mb-2 opacity-30" />
                    <p className="text-sm">No attendees match these filters.</p>
                  </Card>
                ) : (
                  <div className="space-y-2">
                    {attendees.map((a) => (
                      <Card key={a.id} className="p-3 flex items-center gap-3">
                        <Ticket size={14} className="text-buddy-text-secondary flex-shrink-0" />
                        <div className="flex-1 min-w-0">
                          <p className="text-sm font-medium truncate">{a.display_name || a.username || 'Attendee'}</p>
                          <p className="text-xs text-buddy-text-secondary font-mono truncate">{a.ticket_code}</p>
                        </div>
                        <Badge variant={a.is_checked_in ? 'green' : 'silver'} label={a.is_checked_in ? 'In' : 'Not in'} size="sm" />
                        {a.is_checked_in ? (
                          <Button size="sm" variant="ghost" disabled={checkInBusy} onClick={() => handleCheckOut(a)} title="Reverse check-in">
                            <RotateCcw size={12} className="mr-1" /> Undo
                          </Button>
                        ) : (
                          <Button
                            size="sm"
                            variant="outline"
                            disabled={checkInBusy || !a.ticket_code}
                            onClick={() => a.ticket_code && handleCheckInForCode(a.ticket_code)}
                            aria-label={`Check in ${a.ticket_code || a.display_name || 'attendee'}`}
                          >
                            Check in
                          </Button>
                        )}
                      </Card>
                    ))}
                  </div>
                )}
              </section>
            </>
          )}
        </>
      )}
    </RoleDashboardShell>
  );
}