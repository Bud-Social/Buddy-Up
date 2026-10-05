import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  ArrowLeft, Flag, Heart, Loader2, LocateFixed, MessageCircle, ShieldOff, UserRound, Users,
} from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { useToast } from '@/components/ui/Toast';
import { messagingApi } from '@/api';
import { feedApi, REPORT_REASONS, type ReportReason } from '@/api/feed';
import { profilesApi, type UserBuddySearchProfile } from '@/api/profiles';
import { requestLocation } from '@/lib/geo';
import { formatDistanceBadge } from './FindBuddy';

/** Prefer the server's message — every refusal here comes back explained. */
function serverMessage(err: unknown, fallback: string): string {
  const e = err as { response?: { data?: { message?: string } } } | null;
  const m = e?.response?.data?.message;
  return typeof m === 'string' && m.length > 0 ? m : fallback;
}

function formatUntil(iso: string | null | undefined): string | null {
  if (!iso) return null;
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return null;
  return `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
}

/**
 * Full Find-a-Buddy profile for one person: their search photos, what they're
 * looking for, and the two actions that matter here — message, or show interest.
 * The main profile lives one click away at the bottom.
 */
export default function FindBuddyProfile() {
  const { username } = useParams<{ username: string }>();
  const navigate = useNavigate();
  const { toast } = useToast();
  const [sp, setSp] = useState<UserBuddySearchProfile | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [missing, setMissing] = useState(false);
  const [photoIndex, setPhotoIndex] = useState(0);
  const [liked, setLiked] = useState(false);
  const [likeBusy, setLikeBusy] = useState(false);
  const [msgBusy, setMsgBusy] = useState(false);
  const [reportOpen, setReportOpen] = useState(false);
  const [reason, setReason] = useState<ReportReason>('spam');
  const [description, setDescription] = useState('');
  const [reportBusy, setReportBusy] = useState(false);
  const [blockBusy, setBlockBusy] = useState(false);

  const fetchProfile = useCallback(async () => {
    if (!username) return;
    setIsLoading(true);
    try {
      let coords: { lat: number; lng: number } | undefined;
      try {
        const c = await requestLocation();
        coords = c;
      } catch { coords = undefined; }
      const res = await profilesApi.getUserSearchProfile(username, coords);
      const data = res.data as UserBuddySearchProfile | null;
      if (!data) {
        setMissing(true);
        setSp(null);
      } else {
        setMissing(false);
        setSp(data);
        setLiked(!!data.liked_by_me);
        setPhotoIndex(0);
      }
    } catch {
      setMissing(true);
      setSp(null);
    } finally {
      setIsLoading(false);
    }
  }, [username]);

  useEffect(() => { fetchProfile(); }, [fetchProfile]);

  const toggleLike = async () => {
    if (!sp || likeBusy) return;
    const wasLiked = liked;
    setLikeBusy(true);
    setLiked(!wasLiked);
    try {
      const res = wasLiked ? await profilesApi.unlikeBuddy(sp.username) : await profilesApi.likeBuddy(sp.username);
      setSp((prev) => (prev ? { ...prev, liked_by_me: !wasLiked, liked_me: res.data?.liked_me ?? prev.liked_me } : prev));
      toast('success', wasLiked ? `Interest removed from @${sp.username}` : `Sent to @${sp.username}`);
    } catch (err) {
      setLiked(wasLiked);
      toast('error', serverMessage(err, wasLiked ? 'Could not undo interest.' : 'Could not show interest.'));
    } finally {
      setLikeBusy(false);
    }
  };

  const handleMessage = async () => {
    if (!sp || msgBusy) return;
    setMsgBusy(true);
    try {
      const res = await messagingApi.startConversation([sp.username], undefined, 'discovery');
      const convoId = res.data?.id;
      navigate(convoId ? `/buddies/messages/${convoId}` : '/buddies/messages');
    } catch (err) {
      toast('error', serverMessage(err, 'Could not start the conversation.'));
    } finally {
      setMsgBusy(false);
    }
  };

  const handleBlock = async () => {
    if (!sp || blockBusy) return;
    setBlockBusy(true);
    try {
      await profilesApi.block(sp.username);
      toast('success', `Blocked @${sp.username}`);
      navigate(-1);
    } catch (err) {
      toast('error', serverMessage(err, 'Could not block this profile.'));
      setBlockBusy(false);
    }
  };

  const submitReport = async () => {
    if (!sp || reportBusy) return;
    setReportBusy(true);
    try {
      let targetUser = sp.username;
      try {
        const prof = await profilesApi.getProfile(sp.username);
        targetUser = prof.data?.user_id ?? sp.username;
      } catch { /* fall back to the username; the server validates */ }
      await feedApi.submitReport({
        target_user: targetUser,
        reason,
        ...(description.trim() ? { description: `Buddy profile ${sp.username} — ${description.trim()}` } : {}),
        content_url: `${window.location.origin}/buddies/find/${sp.username}`,
      });
      setReportOpen(false);
      setDescription('');
      toast('success', 'Thanks — our team will review this profile.');
    } catch (err) {
      toast('error', serverMessage(err, 'Could not submit your report.'));
    } finally {
      setReportBusy(false);
    }
  };

  if (isLoading) {
    return (
      <div className="max-w-lg lg:max-w-2xl mx-auto p-4">
        <Card className="h-64 animate-pulse" />
      </div>
    );
  }

  if (missing || !sp) {
    return (
      <div className="max-w-lg lg:max-w-2xl mx-auto p-4 space-y-4">
        <Button variant="ghost" size="sm" onClick={() => navigate(-1)}>
          <ArrowLeft size={16} /> Back
        </Button>
        <div className="text-center py-16">
          <UserRound size={40} className="mx-auto text-buddy-text-secondary/30 mb-3" />
          <p className="text-buddy-text-secondary">
            This buddy search profile isn't available right now.
          </p>
          <Button variant="outline" size="sm" className="mt-4" onClick={() => navigate(`/buddies/find`)}>
            Back to Find a buddy
          </Button>
        </div>
      </div>
    );
  }

  const photos = sp.photos?.length ? sp.photos : sp.avatar_url ? [sp.avatar_url] : [];
  const name = sp.display_name || sp.username;
  const intents = (sp.intents || []).map((i) => i.replace(/_/g, ' '));
  const until = formatUntil(sp.available_until);
  const likedMe = !!sp.liked_me;

  return (
    <div className="max-w-lg lg:max-w-2xl mx-auto p-4 space-y-4 pb-24">
      <div className="flex items-center justify-between">
        <Button variant="ghost" size="sm" onClick={() => navigate(-1)}>
          <ArrowLeft size={16} /> Back
        </Button>
        <Button variant="ghost" size="sm" onClick={() => setReportOpen((v) => !v)} aria-pressed={reportOpen}>
          <Flag size={14} /> Report
        </Button>
      </div>

      <Card className="overflow-hidden">
        {photos.length > 0 ? (
          <div className="relative aspect-[4/3] bg-buddy-surface-raised">
            <img
              src={photos[photoIndex]}
              alt={`${name}'s photo ${photoIndex + 1} of ${photos.length}`}
              className="h-full w-full object-cover"
            />
            {photos.length > 1 && (
              <>
                <button
                  type="button"
                  aria-label="Previous photo"
                  onClick={() => setPhotoIndex((i) => (i - 1 + photos.length) % photos.length)}
                  className="absolute left-2 top-1/2 -translate-y-1/2 p-2 rounded-full bg-buddy-black/70 text-buddy-white"
                >
                  <ArrowLeft size={14} />
                </button>
                <button
                  type="button"
                  aria-label="Next photo"
                  onClick={() => setPhotoIndex((i) => (i + 1) % photos.length)}
                  className="absolute right-2 top-1/2 -translate-y-1/2 p-2 rounded-full bg-buddy-black/70 text-buddy-white"
                >
                  <ArrowLeft size={14} className="rotate-180" />
                </button>
                <span className="absolute bottom-2 right-2 rounded-md bg-buddy-black/75 px-1.5 py-0.5 font-mono text-[11px] font-bold text-buddy-green tabular-nums">
                  {photoIndex + 1}/{photos.length}
                </span>
              </>
            )}
          </div>
        ) : (
          <div className="flex aspect-[4/3] items-center justify-center bg-buddy-surface-raised">
            <span className="font-display text-6xl font-bold text-buddy-green/70">{name.charAt(0).toUpperCase()}</span>
          </div>
        )}

        <div className="space-y-3 p-4">
          <div className="flex items-start justify-between gap-3">
            <div className="min-w-0">
              <h1 className="font-display text-xl font-extrabold truncate">{name}</h1>
              <p className="text-xs text-buddy-text-secondary truncate">
                @{sp.username}
                {sp.age_band ? ` · ${sp.age_band}` : ''}
                {sp.distance_km != null
                  ? ` · ${formatDistanceBadge(sp.distance_km) ?? 'Nearby'}`
                  : ''}
              </p>
            </div>
            {sp.available_now && (
              <Badge variant="green" label={until ? `Available until ${until}` : 'Available now'} />
            )}
          </div>

          <div className="flex flex-wrap gap-1.5">
            {intents.map((i) => (
              <Badge key={i} variant="green" label={i} size="sm" />
            ))}
            {sp.custom_intent && <Badge variant="gold" label={sp.custom_intent} size="sm" />}
            {(sp.modes || []).map((m) => (
              <Badge key={m} variant="silver" label={m.replace(/_/g, ' ')} size="sm" />
            ))}
            {(sp.goals || []).map((g) => (
              <Badge key={g} variant="silver" label={g.replace(/_/g, ' ')} size="sm" />
            ))}
          </div>

          {sp.pace && (
            <p className="text-xs text-buddy-text-secondary flex items-center gap-1.5">
              <LocateFixed size={12} /> Pace: <span className="text-buddy-text-primary">{sp.pace}</span>
            </p>
          )}
          {sp.neighbourhood && (
            <p className="text-xs text-buddy-text-secondary">Around {sp.neighbourhood}</p>
          )}
          {sp.bio ? (
            <p className="text-sm text-buddy-text-primary whitespace-pre-line">{sp.bio}</p>
          ) : (
            <p className="text-sm text-buddy-text-secondary">No buddy-search bio yet.</p>
          )}

          <div className="flex items-center gap-2 pt-1">
            <Button className="flex-1" onClick={handleMessage} disabled={msgBusy || !sp.can_message}>
              {msgBusy ? <Loader2 size={16} className="animate-spin" /> : <MessageCircle size={16} />} Message
            </Button>
            <span className="relative">
              <Button
                variant="outline"
                onClick={toggleLike}
                disabled={likeBusy}
                aria-pressed={liked}
                aria-label={liked ? `Remove interest in @${sp.username}` : `Show interest in @${sp.username}`}
                className={liked ? 'border-buddy-red/50 text-buddy-red' : ''}
              >
                <Heart size={16} fill={liked ? 'currentColor' : 'none'} /> Interested
              </Button>
              {likedMe && !liked && (
                <span className="absolute -top-2 -right-1 rounded-full bg-buddy-gold px-1.5 py-0.5 text-[9px] font-bold leading-none text-buddy-black">
                  Liked you
                </span>
              )}
            </span>
          </div>
          {likedMe && !liked && (
            <p className="text-xs text-buddy-gold">@{sp.username} is looking for a buddy too — send interest to match.</p>
          )}
          {sp.is_buddy && (
            <p className="text-xs text-buddy-green flex items-center gap-1.5">
              <Users size={12} /> You are already buddies.
            </p>
          )}
          {!sp.can_message && !sp.is_buddy && (
            <p className="text-xs text-buddy-text-secondary">Messaging isn't available on this profile right now.</p>
          )}
        </div>
      </Card>

      {reportOpen && (
        <Card className="p-4 space-y-3">
          <p className="text-sm font-semibold">Why are you reporting this profile?</p>
          <div role="radiogroup" aria-label="Report reason" className="space-y-0.5">
            {REPORT_REASONS.map((r) => (
              <button
                key={r.value}
                role="menuitemradio"
                aria-checked={reason === r.value}
                onClick={() => setReason(r.value)}
                className={`flex w-full items-center gap-2 rounded-lg px-2.5 py-1.5 text-left text-[13px] ${
                  reason === r.value
                    ? 'bg-buddy-green/10 text-buddy-green font-medium'
                    : 'text-buddy-text-primary hover:bg-buddy-surface-raised'
                }`}
              >
                <span
                  aria-hidden
                  className={`w-3.5 h-3.5 rounded-full border flex items-center justify-center shrink-0 ${
                    reason === r.value ? 'border-buddy-green' : 'border-buddy-text-secondary'
                  }`}
                >
                  {reason === r.value && <span className="w-1.5 h-1.5 rounded-full bg-buddy-green" />}
                </span>
                {r.label}
              </button>
            ))}
          </div>
          <textarea
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="Details (optional)"
            rows={2}
            aria-label="Report details"
            className="w-full bg-buddy-surface-raised rounded-lg px-3 py-2 text-[13px] text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-1 focus:ring-buddy-green/40 resize-none"
          />
          <div className="flex gap-2">
            <Button variant="ghost" size="sm" className="flex-1" onClick={() => setReportOpen(false)}>
              Cancel
            </Button>
            <Button size="sm" className="flex-1" onClick={submitReport} disabled={reportBusy}>
              {reportBusy ? 'Sending…' : 'Submit report'}
            </Button>
          </div>
        </Card>
      )}

      <Button variant="ghost" size="sm" onClick={handleBlock} disabled={blockBusy}>
        <ShieldOff size={14} /> Block @{sp.username}
      </Button>

      <Button variant="outline" className="w-full" onClick={() => navigate(`/${sp.username}`)}>
        View main profile
      </Button>
    </div>
  );
}
