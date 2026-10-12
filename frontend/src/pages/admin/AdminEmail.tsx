import { useCallback, useEffect, useMemo, useState } from 'react';
import { Mail, RotateCcw, Send, UserRound } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import {
  adminPortalApi,
  adminPortalErrorMessage,
  type PortalUser,
  type StaffEmailLog,
} from '@/api/adminPortal';
import {
  AdminEmptyState,
  AdminErrorBanner,
  AdminPageHeader,
  AdminPagination,
  AdminSkeleton,
  AdminStatCard,
  DataRow,
  FilterSelect,
  SearchField,
  StatusBadge,
} from './shared';
import { formatDate, shortId, text } from './format';
import { useDebounced, usePortalAction, usePortalList } from './usePortalList';

/**
 * The staff→user assistance console.
 *
 * Three things this page has to be honest about, because each one has already
 * been true in a way a naive UI would hide:
 *
 * 1. **A send is a queue, not a delivery.** The endpoint answers 202 and says
 *    so. Saying "Email sent" would be a lie about something the user may never
 *    receive, and a support agent who believes otherwise will not chase it.
 * 2. **One recipient, registered only.** The API has no list field and refuses
 *    an address matching no account. So the UI has neither: you pick a user.
 * 3. **There is a ceiling.** 20 queued messages per staff member per hour, a
 *    429 rather than a silent cap. The console shows that sentence as the
 *    server wrote it, with the number in it.
 */

const STATUS_OPTIONS = [
  { value: 'all', label: 'Any status' },
  { value: 'queued', label: 'Queued' },
  { value: 'sent', label: 'Sent' },
  { value: 'failed', label: 'Failed' },
  { value: 'skipped', label: 'Skipped' },
];

const MAX_SUBJECT = 300;
const MAX_BODY = 5000;

export default function AdminEmail() {
  const [status, setStatus] = useState('all');
  const [recipientEmail, setRecipientEmail] = useState('');
  const debouncedRecipient = useDebounced(recipientEmail);
  const resend = usePortalAction();

  const filters = useMemo(
    () => ({ status, recipient_email: debouncedRecipient.trim() || undefined }),
    [status, debouncedRecipient],
  );

  const fetcher = useCallback(
    (params: Record<string, unknown>) => adminPortalApi.getEmailLog(params as never),
    [],
  );
  const { items, count, page, pageCount, loading, error, reload, goToPage } =
    usePortalList<StaffEmailLog>(fetcher, filters);

  const retry = useCallback(
    async (row: StaffEmailLog) => {
      const id = row.id;
      if (!id) return;
      const ok = await resend.run(
        id,
        () => adminPortalApi.resendStaffEmail(id),
        { success: 'Requeued for delivery.', failure: 'Failed to resend.' },
      );
      if (ok) reload(true);
    },
    [resend, reload],
  );

  const failed = items.filter((r) => r.status === 'failed').length;
  const queued = items.filter((r) => r.status === 'queued').length;

  return (
    <div className="space-y-6 pb-8">
      <AdminPageHeader
        title="Assistance email"
        description="Message one registered user from your staff account. There is no bulk send, and there is no cc."
        onRefresh={() => reload()}
        refreshing={loading}
      />

      <ComposePanel onSent={() => reload(true)} />

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
        <AdminStatCard label="Matching messages" value={count.toLocaleString()} />
        <AdminStatCard label="On this page" value={items.length} />
        <AdminStatCard label="Queued" value={queued} />
        <AdminStatCard label="Failed" value={failed} />
      </div>

      <Card className="p-4 space-y-3">
        <div className="flex flex-wrap items-center gap-2">
          <FilterSelect label="Status" value={status} options={STATUS_OPTIONS} onChange={setStatus} />
          <SearchField
            value={recipientEmail}
            onChange={setRecipientEmail}
            label="Filter by recipient email"
            placeholder="Recipient email…"
          />
          {(status !== 'all' || recipientEmail) && (
            <Button variant="ghost" size="sm" onClick={() => { setStatus('all'); setRecipientEmail(''); }}>
              Clear filters
            </Button>
          )}
        </div>
      </Card>

      {error && <AdminErrorBanner message={error} onRetry={() => reload()} />}
      {resend.error && <AdminErrorBanner message={resend.error} onRetry={resend.clearError} />}
      {resend.notice && (
        <div className="bg-buddy-green/10 border border-buddy-green/20 text-buddy-green text-xs rounded-xl px-3 py-2">
          {resend.notice}
        </div>
      )}

      {loading && !items.length ? (
        <AdminSkeleton />
      ) : items.length === 0 ? (
        <AdminEmptyState
          icon={<Mail size={32} />}
          title={count === 0 ? 'No messages match the current filters.' : 'No messages on this page.'}
        />
      ) : (
        <div className="space-y-2">
          {items.map((row, index) => {
            const id = row.id || `email-${index}`;
            const busy = resend.actingId === row.id;
            return (
              <Card key={id} className="p-4">
                <div className="flex flex-wrap items-start gap-3">
                  <div className="flex-1 min-w-0">
                    <div className="flex flex-wrap items-center gap-2">
                      <StatusBadge status={row.status} />
                      {row.template_key && <StatusBadge status={row.template_key} />}
                    </div>
                    <p className="text-sm font-semibold mt-1.5 break-words">{text(row.subject, 'No subject recorded.')}</p>
                    <p className="text-xs text-buddy-text-secondary mt-0.5 break-all">
                      to {text(row.recipient_email)}
                      {row.sent_by_email ? ` · from ${row.sent_by_email}` : ''}
                    </p>
                    {row.body_preview && (
                      <p className="text-xs mt-1.5 break-words line-clamp-2">{row.body_preview}</p>
                    )}
                    {row.error && <p className="text-[11px] text-buddy-red mt-1 break-words">{row.error}</p>}
                    <p className="text-[11px] text-buddy-text-secondary mt-1">{formatDate(row.created_at)}</p>
                  </div>
                  <div className="flex flex-wrap items-center gap-1.5 flex-shrink-0">
                    {row.status === 'failed' ? (
                      <Button variant="outline" size="sm" disabled={busy} onClick={() => retry(row)}>
                        <RotateCcw size={14} className="mr-1" /> Resend
                      </Button>
                    ) : (
                      <span className="text-[11px] text-buddy-text-secondary">
                        {row.status === 'sent' ? 'Delivered — not resent' : 'In the queue — not resent'}
                      </span>
                    )}
                  </div>
                </div>
                {(row.related_object_type || row.related_object_id) && (
                  <div className="mt-3 pt-3 border-t border-buddy-surface">
                    <DataRow label="Related object">
                      {text(row.related_object_type)}{row.related_object_id ? ` · ${shortId(row.related_object_id)}` : ''}
                    </DataRow>
                  </div>
                )}
              </Card>
            );
          })}
        </div>
      )}

      <AdminPagination page={page} pageCount={pageCount} count={count} onPage={goToPage} busy={loading} />
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Compose                                                             */
/* ------------------------------------------------------------------ */

function ComposePanel({ onSent }: { onSent: () => void }) {
  const [query, setQuery] = useState('');
  const [picked, setPicked] = useState<PortalUser | null>(null);
  const [candidates, setCandidates] = useState<PortalUser[]>([]);
  const [searching, setSearching] = useState(false);
  const [subject, setSubject] = useState('');
  const [body, setBody] = useState('');
  const [relatedType, setRelatedType] = useState('');
  const [relatedId, setRelatedId] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');
  const debouncedQuery = useDebounced(query, 300);

  // Recipient lookup goes through the portal's user search rather than accepting
  // a typed address: the API only delivers to a registered account, so letting
  // someone type an arbitrary one would only ever produce a 400.
  useEffect(() => {
    const q = debouncedQuery.trim();
    if (!q) {
      setCandidates([]);
      return;
    }
    let cancelled = false;
    setSearching(true);
    adminPortalApi
      .getUsers({ q })
      .then((res) => {
        if (cancelled) return;
        setCandidates((Array.isArray(res?.data) ? res.data : []).slice(0, 6));
      })
      .catch(() => { if (!cancelled) setCandidates([]); })
      .finally(() => { if (!cancelled) setSearching(false); });
    return () => { cancelled = true; };
  }, [debouncedQuery]);

  const canSend = Boolean(picked?.id) && subject.trim().length > 0 && body.trim().length > 0 && !busy;

  const send = useCallback(async () => {
    if (!picked?.id || busy) return;
    setBusy(true);
    setError('');
    setNotice('');
    try {
      const res = await adminPortalApi.sendStaffEmail({
        user_id: picked.id,
        subject: subject.trim(),
        body: body.trim(),
        related_object_type: relatedType.trim() || undefined,
        related_object_id: relatedId.trim() || undefined,
      });
      setNotice(
        res?.message ||
          'Message queued for delivery. It is recorded against your staff account whether or not it arrives.',
      );      setSubject('');
      setBody('');
      setRelatedId('');
      setPicked(null);
      setQuery('');
      onSent();
    } catch (e) {
      // A 429 lands here carrying the server's own ceiling sentence, including
      // the count and the limit. Showing it verbatim is the point.
      setError(adminPortalErrorMessage(e, 'Failed to queue the message.'));
    } finally {
      setBusy(false);
    }
  }, [picked, busy, subject, body, relatedType, relatedId, onSent]);

  return (
    <Card className="p-4 space-y-3">
      <div>
        <h3 className="text-sm font-semibold flex items-center gap-1.5"><Send size={14} /> Compose</h3>
        <p className="text-[11px] text-buddy-text-secondary mt-0.5">
          One message, to one registered account. The ceiling is 20 queued messages per staff member per
          hour.
        </p>
      </div>

      <div>
        <span className="block text-xs text-buddy-text-secondary mb-1">Recipient</span>
        {picked ? (
          <div className="flex items-center gap-2 flex-wrap">
            <span className="inline-flex items-center gap-1.5 text-sm bg-buddy-green/15 text-buddy-green rounded-lg px-2.5 py-1">
              <UserRound size={13} /> {text(picked.display_name || picked.username, text(picked.email, 'user'))}
            </span>
            <span className="text-[11px] text-buddy-text-secondary break-all">{text(picked.email)}</span>
            <Button variant="ghost" size="sm" onClick={() => { setPicked(null); setQuery(''); }}>Change</Button>
          </div>
        ) : (
          <>
            <SearchField value={query} onChange={setQuery} label="Search for the recipient" placeholder="Search by email, username or name…" />
            {searching && <p className="text-[11px] text-buddy-text-secondary mt-2">Searching…</p>}
            {!searching && debouncedQuery.trim() && candidates.length === 0 && (
              <p className="text-[11px] text-buddy-text-secondary mt-2">
                No account matches “{debouncedQuery.trim()}”. This console can only message users who have
                registered.
              </p>
            )}
            {candidates.length > 0 && (
              <div className="flex flex-wrap gap-1.5 mt-2">
                {candidates.map((u) => (
                  <Button key={u.id || u.email} variant="outline" size="sm" onClick={() => setPicked(u)}>
                    {text(u.display_name || u.username, text(u.email, 'user'))}
                  </Button>
                ))}
              </div>
            )}
          </>
        )}
      </div>

      <label className="block text-xs text-buddy-text-secondary">
        <span className="mb-1 block">Subject <span className="text-buddy-red">*</span></span>
        <input
          value={subject}
          onChange={(e) => setSubject(e.target.value)}
          maxLength={MAX_SUBJECT}
          placeholder="A short, specific subject"
          aria-label="Email subject"
          className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm placeholder:text-buddy-text-secondary focus:outline-none focus:border-buddy-green"
        />
        <span className="mt-0.5 block text-[10px] text-buddy-text-secondary/70">{subject.length}/{MAX_SUBJECT}</span>
      </label>

      <label className="block text-xs text-buddy-text-secondary">
        <span className="mb-1 block">Body <span className="text-buddy-red">*</span></span>
        <textarea
          rows={6}
          value={body}
          onChange={(e) => setBody(e.target.value)}
          maxLength={MAX_BODY}
          placeholder="Write the message. It is wrapped in the staff-message template with your name on it."
          aria-label="Email body"
          className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm placeholder:text-buddy-text-secondary focus:outline-none focus:border-buddy-green"
        />
        <span className="mt-0.5 block text-[10px] text-buddy-text-secondary/70">{body.length}/{MAX_BODY}</span>
      </label>

      <details className="text-xs text-buddy-text-secondary">
        <summary className="cursor-pointer select-none">Attach to an object (optional)</summary>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 mt-2">
          <label className="block">
            <span className="mb-1 block">Type</span>
            <input
              value={relatedType}
              onChange={(e) => setRelatedType(e.target.value)}
              placeholder="user, order, ticket…"
              aria-label="Related object type"
              className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm focus:outline-none focus:border-buddy-green"
            />
          </label>
          <label className="block">
            <span className="mb-1 block">Id</span>
            <input
              value={relatedId}
              onChange={(e) => setRelatedId(e.target.value)}
              placeholder="00000000-…"
              aria-label="Related object id"
              className="w-full bg-buddy-surface-raised border border-buddy-surface rounded-xl px-3 py-2 text-sm font-mono focus:outline-none focus:border-buddy-green"
            />
          </label>
        </div>
      </details>

      <div className="flex items-center gap-2">
        <Button size="sm" disabled={!canSend} isLoading={busy} onClick={send}>
          <Send size={14} className="mr-1" /> Queue message
        </Button>
        {!picked && <span className="text-[11px] text-buddy-text-secondary">Pick a registered user first.</span>}
      </div>

      <p className="text-[11px] text-buddy-orange">
        Sending queues the message; it does not confirm delivery. The log records it against your staff
        account whether or not it arrives.
      </p>
      {notice && (
        <div className="bg-buddy-green/10 border border-buddy-green/20 text-buddy-green text-xs rounded-xl px-3 py-2">
          {notice}
        </div>
      )}
      {error && <AdminErrorBanner message={error} />}
    </Card>
  );
}
