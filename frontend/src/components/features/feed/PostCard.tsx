import { useState, useRef, useEffect, useMemo, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Heart, MessageCircle, Repeat2, Bookmark, BookmarkCheck,
  MoreHorizontal, Dumbbell, Utensils, TrendingUp, MapPin, BarChart2,
  Maximize2, FileText, CheckSquare, CircleDot, ChevronLeft, ChevronRight,
  Volume2, VolumeX, Share2, Eye,
} from 'lucide-react';
import { Avatar } from '@/components/ui/Avatar';
import { feedApi } from '@/api';
import { formatPostDate } from '@/utils/formatDate';
import { EmojiImg, toEmoji } from '@/utils/emojiUtils';
import { useInViewAutoplay } from '@/hooks/useInViewAutoplay';
import { RailAction, RAIL_ICON_SIZE, nextReactionState, totalReactions } from './RailAction';
import { AuthorChip } from './AuthorChip';
import { PostShareSheet } from './PostShareSheet';
import { useRecordPostView } from './useRecordPostView';
import { mediaPagesFromPost, type MediaPage } from '@/lib/mediaPages';
import { filterCssAt, adjustCss } from '@/lib/createStudio';
import { CreativeLayer } from '@/components/create/CreativeLayer';
import { FeedTrackAudio } from '@/components/features/feed/FeedTrackAudio';
import { isProfanityFilterEnabled, maskProfanity } from '@/lib/profanity';

function combinedFilterCss(page: MediaPage): string {
  const edits = page.edit_meta;
  if (!edits) return '';
  const parts = [filterCssAt(edits.filter, edits.filter_strength ?? 100), adjustCss(edits.adjust)];
  return parts.filter(Boolean).join(' ');
}
import type { Post, PostCaption, PostMedia } from '@/types';
import EmojiPicker, { Theme, EmojiStyle } from 'emoji-picker-react';
import { RichText } from '@/components/ui/RichText';
import { PostMap } from './PostMap';

// ─── Sub-components ───────────────────────────────────────────────────────────
function WorkoutLogCard({ data }: { data: Record<string, unknown> }) {
  return (
    <div className="bg-buddy-surface-raised rounded-xl p-4 mt-3 border border-buddy-surface">
      <div className="flex items-center gap-2 mb-3">
        <Dumbbell size={15} className="text-buddy-green" />
        <span className="font-heading font-semibold text-sm">{data.exercise as string || 'Workout'}</span>
      </div>
      <div className="grid grid-cols-3 gap-3 text-center">
        {[
          { label: 'Sets',  value: data.sets,     color: 'text-buddy-green' },
          { label: 'Reps',  value: data.reps,     color: 'text-buddy-green' },
          { label: 'Cal',   value: data.calories,  color: 'text-buddy-orange' },
        ].map(({ label, value, color }) => (
          <div key={label}>
            <p className={`font-mono font-bold text-lg ${color}`}>{(value as string) || '—'}</p>
            <p className="text-xs text-buddy-text-secondary mt-0.5">{label}</p>
          </div>
        ))}
      </div>
    </div>
  );
}

function MealCard({ data }: { data: Record<string, unknown> }) {
  const d = data as Record<string, number | string | undefined>;
  const macro = (primary: string, alt: string) => Number(d[primary] ?? d[alt] ?? 0);
  const macros = [
    { label: 'protein', val: macro('protein_g', 'protein'), max: 50, color: 'bg-buddy-electric' },
    { label: 'carbs', val: macro('carbs_g', 'carbs'), max: 80, color: 'bg-buddy-orange' },
    { label: 'fats', val: macro('fat_g', 'fats'), max: 30, color: 'bg-buddy-gold' },
  ];
  const kcal = Number(d.calories ?? 0);
  return (
    <div className="bg-buddy-surface-raised rounded-xl p-4 mt-3 border border-buddy-surface">
      <div className="flex items-center gap-2 mb-3">
        <Utensils size={15} className="text-buddy-orange" />
        <span className="font-heading font-semibold text-sm capitalize">{(d.meal_type as string) || 'Meal'}</span>
        {kcal > 0 && <span className="ml-auto text-sm font-bold text-buddy-orange">{Math.round(kcal)} kcal</span>}
      </div>
      {(d.food_name as string) && (
        <p className="text-sm font-medium mb-3">{d.food_name as string}</p>
      )}
      <div className="space-y-2">
        {macros.map(m => {
          const pct = Math.min((m.val / m.max) * 100, 100);
          return (
            <div key={m.label} className="flex items-center gap-2">
              <span className="text-xs text-buddy-text-secondary w-14 capitalize">{m.label}</span>
              <div className="flex-1 h-1.5 bg-buddy-surface rounded-full overflow-hidden">
                <div className={`h-full rounded-full transition-all ${m.color}`} style={{ width: `${pct}%` }} />
              </div>
              <span className="text-xs font-mono w-8 text-right text-buddy-text-primary">{m.val}g</span>
            </div>
          );
        })}
      </div>
    </div>
  );
}

function ProgressCard({ data, mediaUrls = [] }: { data: Record<string, unknown>; mediaUrls?: string[] }) {
  const d = data as Record<string, number | string | undefined>;
  const weight = Number(d.weight ?? d.weight_kg ?? d.weight_lbs ?? 0);
  const unit = (d.weight_unit as string) || (d.weight !== undefined ? 'kg' : '');
  const mode = (d.mode as string) || 'transformation';
  const beforeCount = Number(d.before_count ?? 0);

  // Prefer explicit URLs, else derive from the post's media list.
  const beforeUrls = (d.before_urls as string[] | undefined) ?? mediaUrls.slice(0, beforeCount || Math.floor(mediaUrls.length / 2));
  const afterUrls = (d.after_urls as string[] | undefined) ?? mediaUrls.slice(beforeCount || Math.floor(mediaUrls.length / 2));

  const showBeforeAfter = mode === 'transformation' && (beforeUrls.length > 0 || afterUrls.length > 0);
  const snaps = afterUrls.length > 0 ? afterUrls : mediaUrls;

  return (
    <div className="bg-buddy-surface-raised rounded-xl p-4 mt-3 border border-buddy-surface">
      <div className="flex items-center gap-2 mb-3">
        <TrendingUp size={15} className="text-buddy-electric" />
        <span className="font-heading font-semibold text-sm">{(d as { label?: string }).label || 'Transformation'}</span>
        {weight > 0 && (
          <span className="ml-auto text-sm font-bold text-buddy-electric">{weight} {unit}</span>
        )}
      </div>
      {showBeforeAfter ? (
        <div className="grid grid-cols-2 gap-2">
          {beforeUrls.length > 0 && (
            <div className="aspect-square bg-buddy-surface rounded-xl overflow-hidden relative">
              <img src={beforeUrls[0]} alt="Before" className="w-full h-full object-cover" loading="lazy" />
              <span className="absolute top-2 left-2 bg-black/70 text-[10px] px-2 py-0.5 rounded-full">Before</span>
            </div>
          )}
          {afterUrls.length > 0 && (
            <div className="aspect-square bg-buddy-surface rounded-xl overflow-hidden relative">
              <img src={afterUrls[0]} alt="After" className="w-full h-full object-cover" loading="lazy" />
              <span className="absolute top-2 right-2 bg-buddy-green/80 text-[10px] px-2 py-0.5 rounded-full">After</span>
            </div>
          )}
        </div>
      ) : snaps.length > 0 ? (
        <div className="grid grid-cols-2 gap-2">
          {snaps.slice(0, 4).map((url, i) => (
            <div key={i} className="aspect-square bg-buddy-surface rounded-xl overflow-hidden relative">
              <img src={url} alt={`Progress ${i + 1}`} className="w-full h-full object-cover" loading="lazy" />
            </div>
          ))}
        </div>
      ) : weight > 0 ? (
        <div className="col-span-2 aspect-[2/1] bg-buddy-surface rounded-xl flex items-center justify-center">
          <span className="text-2xl font-display font-bold text-buddy-electric">{weight} {unit}</span>
        </div>
      ) : null}
    </div>
  );
}

function PollCard({ poll, postId }: { poll: NonNullable<Post['poll']>; postId: string }) {
  const [localPoll, setLocalPoll] = useState(poll);
  const [pendingSelections, setPendingSelections] = useState<string[]>([]);
  const [isSubmittingVote, setIsSubmittingVote] = useState(false);
  const hasVoted = localPoll.user_voted_option_ids && localPoll.user_voted_option_ids.length > 0;
  const total = localPoll.total_votes || 0;
  const isMulti = !!localPoll.allow_multiple;
  const minSel = Math.max(1, localPoll.min_selections ?? 1);
  const maxSel = Math.max(isMulti ? 2 : 1, localPoll.max_selections ?? 1);
  const canReceiveVotes = !hasVoted && !localPoll.is_closed;
  const selectionValid = pendingSelections.length >= minSel && pendingSelections.length <= maxSel;

  const handleSingleVote = async (optionId: string) => {
    if (!canReceiveVotes) return;
    try {
      const res = await feedApi.voteOnPoll(postId, [optionId]);
      if (res.data) setLocalPoll(res.data);
    } catch {}
  };

  const togglePending = (optionId: string) => {
    if (!canReceiveVotes) return;
    setPendingSelections(prev => {
      if (prev.includes(optionId)) return prev.filter(id => id !== optionId);
      if (prev.length >= maxSel) return prev;
      return [...prev, optionId];
    });
  };

  const submitMultiVote = async () => {
    if (!canReceiveVotes || !selectionValid) return;
    setIsSubmittingVote(true);
    try {
      const res = await feedApi.voteOnPoll(postId, pendingSelections);
      if (res.data) setLocalPoll(res.data);
    } catch {} finally {
      setIsSubmittingVote(false);
    }
  };

  return (
    <div className="mt-3 bg-buddy-surface-raised rounded-xl p-4 border border-buddy-surface">
      <div className="flex items-center gap-2 mb-3">
        <BarChart2 size={14} className="text-buddy-electric" />
        <p className="text-sm font-medium">{localPoll.question}</p>
      </div>
      {isMulti && canReceiveVotes && (
        <p className="text-[11px] text-buddy-text-secondary mb-2">
          Select {minSel === maxSel ? minSel : `${minSel}–${maxSel}`} options
        </p>
      )}
      <div className="space-y-2" role={isMulti ? 'group' : 'radiogroup'}>
        {localPoll.options.map(opt => {
          const voted = localPoll.user_voted_option_ids?.includes(opt.id);
          const pct = total > 0 ? Math.round((opt.vote_count / total) * 100) : 0;
          const pending = pendingSelections.includes(opt.id);
          const disabled = localPoll.is_closed || (!!hasVoted && !voted) || (!hasVoted && isMulti && !pending && pendingSelections.length >= maxSel);
          return (
            <button
              key={opt.id}
              onClick={() => (isMulti ? togglePending(opt.id) : handleSingleVote(opt.id))}
              disabled={disabled}
              className={`w-full relative overflow-hidden rounded-lg border text-left text-sm transition-all ${voted || (canReceiveVotes && pending) ? 'border-buddy-green bg-buddy-green/10 text-buddy-green' : 'border-buddy-surface text-buddy-text-primary hover:border-buddy-green/40'} disabled:cursor-default`}
            >
              {hasVoted && (
                <div className="absolute inset-0 rounded-lg bg-buddy-green/5" style={{ width: `${pct}%` }} />
              )}
              <div className="relative flex items-center gap-2.5 px-3 py-2">
                {/* Radio for single-choice, checkbox for multi-select */}
                {(() => {
                  const checked = voted || pending;
                  const Icon = isMulti ? CheckSquare : CircleDot;
                  return (
                    <Icon size={15} className={`shrink-0 transition-colors ${checked ? 'text-buddy-green' : 'text-buddy-text-secondary'}`} fill={checked ? 'currentColor' : 'none'} />
                  );
                })()}
                <span className="flex-1">{opt.text}</span>
                {hasVoted && <span className="text-xs font-mono font-bold">{pct}%</span>}
              </div>
            </button>
          );
        })}
      </div>
      {isMulti && canReceiveVotes && (
        <button
          onClick={submitMultiVote}
          disabled={!selectionValid || isSubmittingVote}
          className="mt-3 w-full py-2 rounded-lg bg-buddy-green text-buddy-black text-sm font-bold disabled:opacity-40 hover:bg-buddy-green/90 transition-colors"
        >
          {isSubmittingVote ? 'Voting…' : `Vote${pendingSelections.length > 0 ? ` (${pendingSelections.length})` : ''}`}
        </button>
      )}
      <p className="text-xs text-buddy-text-secondary mt-2">{total} vote{total !== 1 ? 's' : ''}{localPoll.is_closed ? ' · Closed' : ''}</p>
    </div>
  );
}

/** One video page inside the carousel: muted autoplay-in-view, tap-to-unmute. */
function CarouselVideoPage({
  page, muted, canAutoplay, blur, captions, postId, onToggleMute, onAdvance, onViewRecorded,
}: {
  page: MediaPage;
  muted: boolean;
  canAutoplay: boolean;
  blur: boolean;
  captions: PostCaption[];
  postId?: string;
  onToggleMute: () => void;
  /** Sequential multi-clip posts: next video page when this one ends. */
  onAdvance?: () => void;
  onViewRecorded?: (viewCount: number) => void;
}) {
  const navigate = useNavigate();
  const videoRef = useRef<HTMLVideoElement>(null);
  const [activeCaption, setActiveCaption] = useState('');
  const [isPlaying, setIsPlaying] = useState(false);
  const [progress, setProgress] = useState(0);
  useInViewAutoplay(videoRef, canAutoplay);
  const viewRef = useRecordPostView(postId, { active: isPlaying, progress, onRecorded: onViewRecorded });

  // Creative-studio edits: filter preset + strength + manual adjustments
  // (CSS), playback speed, timed text overlays, stickers. Also honor the
  // editor's trim in-point on first play.
  const edits = page.edit_meta ?? null;
  const [overlayTimeMs, setOverlayTimeMs] = useState(0);
  const speed = edits?.speed && edits.speed !== 1 ? edits.speed : 1;

  useEffect(() => {
    if (videoRef.current) videoRef.current.muted = muted;
    // Editor's original-audio volume applies at playback (browser caps at 1).
    if (videoRef.current && !muted) {
      videoRef.current.volume = Math.min(1, ((page.edit_meta?.volume ?? 100) as number) / 100);
    }
  }, [muted, page.edit_meta?.volume]);

  useEffect(() => {
    if (videoRef.current) videoRef.current.playbackRate = speed;
  }, [speed]);

  const handleTimeUpdate = (e: React.SyntheticEvent<HTMLVideoElement>) => {
    const v = e.currentTarget;
    setOverlayTimeMs(v.currentTime * 1000);
    if (v.duration > 0) setProgress(v.currentTime / v.duration);
    if (captions.length === 0) return;
    const t = v.currentTime * 1000;
    const seg = captions.find((c) => t >= c.start_ms && t < c.end_ms);
    setActiveCaption(seg ? seg.text : '');
  };

  return (
    <div className="relative group/video" ref={viewRef}>
      <video
        ref={videoRef}
        src={page.url}
        poster={page.poster_url ?? undefined}
        muted={muted}
        loop={!onAdvance}
        playsInline
        preload="metadata"
        onClick={(e) => { e.stopPropagation(); onToggleMute(); }}
        onEnded={() => onAdvance?.()}
        onPlay={() => setIsPlaying(true)}
        onPause={() => setIsPlaying(false)}
        onTimeUpdate={handleTimeUpdate}
        onLoadedMetadata={(e) => {
          const startSec = (page.trim_start_ms ?? 0) / 1000;
          if (startSec > 0 && e.currentTarget.currentTime < startSec) {
            e.currentTarget.currentTime = startSec;
          }
        }}
        style={{ filter: combinedFilterCss(page) }}
        className={`w-full max-h-96 object-cover cursor-pointer ${blur ? 'blur-xl' : ''}`}
      />
      {/* Studio edits: text overlays, stickers, captions — shared renderer */}
      <CreativeLayer meta={edits} timeMs={overlayTimeMs} activeCaption={activeCaption ? { text: activeCaption } : null} />
      {/* Studio audio mix: added tracks + attached sound, synced to playback */}
      <FeedTrackAudio
        getVideo={() => videoRef.current}
        editMeta={edits}
        soundUrl={page.sound_audio_url}
        soundVolume={page.sound_volume}
        soundPlacement={edits?.sound_placement}
        trimStartMs={page.trim_start_ms}
        muted={muted}
        active={isPlaying}
      />
      {/* Tap-to-unmute affordance */}
      <button
        onClick={(e) => { e.stopPropagation(); onToggleMute(); }}
        className="absolute top-2 left-2 p-2 rounded-full bg-black/50 hover:bg-black/70 text-white transition-opacity"
        aria-label={muted ? 'Unmute video' : 'Mute video'}
      >
        {muted ? <VolumeX size={14} /> : <Volume2 size={14} />}
      </button>
      <button
        onClick={(e) => { e.stopPropagation(); navigate(postId ? `/videos?start=${postId}` : '/videos'); }}
        className="absolute top-2 right-2 p-2 rounded-full bg-black/50 hover:bg-black/70 text-white opacity-0 group-hover/video:opacity-100 transition-opacity"
        title="Open full-screen video feed"
      ><Maximize2 size={16} /></button>
    </div>
  );
}

function MediaGallery({
  post, blurred, postId, onViewRecorded,
}: {
  post: { media?: PostMedia[] | null; media_urls?: string[] | null; captions?: PostCaption[] | null };
  blurred?: boolean;
  postId?: string;
  onViewRecorded?: (viewCount: number) => void;
}) {
  const [idx, setIdx] = useState(0);
  const [revealed, setRevealed] = useState(false);
  const [muted, setMuted] = useState(true);
  const trackRef = useRef<HTMLDivElement>(null);
  const pages = useMemo(() => mediaPagesFromPost(post), [post]);
  const captions = useMemo(() => post.captions ?? [], [post.captions]);

  const scrollToPage = useCallback((i: number) => {
    const el = trackRef.current;
    if (!el) return;
    const clamped = Math.max(0, Math.min(pages.length - 1, i));
    el.scrollTo({ left: clamped * el.clientWidth, behavior: 'smooth' });
    setIdx(clamped);
  }, [pages.length]);

  const onTrackScroll = () => {
    const el = trackRef.current;
    if (!el || el.clientWidth === 0) return;
    const next = Math.round(el.scrollLeft / el.clientWidth);
    if (next !== idx && next >= 0 && next < pages.length) setIdx(next);
  };

  if (!pages.length) return null;
  const canAutoplay = !(blurred && !revealed);

  return (
    <div className="mt-3 relative rounded-xl overflow-hidden bg-buddy-surface group">
      <div
        ref={trackRef}
        onScroll={onTrackScroll}
        className="flex overflow-x-auto snap-x snap-mandatory scrollbar-none"
      >
        {pages.map((page, i) => (
          <div key={`${page.url}-${i}`} className="w-full shrink-0 snap-center snap-always">
            {page.type === 'video' ? (
              <CarouselVideoPage
                page={page}
                muted={muted}
                canAutoplay={canAutoplay}
                blur={!!blurred && !revealed}
                captions={page.captions ?? captions}
                postId={postId}
                onToggleMute={() => setMuted((m) => !m)}
                onViewRecorded={onViewRecorded}
                onAdvance={
                  pages.length > 1 && i < pages.length - 1 && pages[i + 1].type === 'video'
                    ? () => scrollToPage(i + 1)
                    : undefined
                }
              />
            ) : page.type === 'audio' ? (
              <div className="p-4 bg-buddy-surface-raised w-full">
                <audio src={page.url} controls className="w-full" />
              </div>
            ) : page.type === 'document' ? (
              <a href={page.url} target="_blank" rel="noreferrer" onClick={(e) => e.stopPropagation()}
                className="flex items-center gap-3 p-4 bg-buddy-surface-raised hover:bg-buddy-surface transition-colors">
                <div className="w-11 h-11 rounded-xl bg-buddy-green/15 text-buddy-green flex items-center justify-center shrink-0">
                  <FileText size={22} />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium truncate">{page.url.split('?')[0].split('/').pop() || 'document'}</p>
                  <p className="text-xs text-buddy-text-secondary">Tap to open document</p>
                </div>
                <Maximize2 size={16} className="text-buddy-text-secondary shrink-0" />
              </a>
            ) : (
              <img
                src={page.url}
                alt={page.alt_text ?? ''}
                className={`w-full max-h-96 object-cover ${blurred && !revealed ? 'blur-xl' : ''}`}
                loading="lazy"
              />
            )}
          </div>
        ))}
      </div>

      {blurred && !revealed && (
        <div className="absolute inset-0 flex items-center justify-center bg-black/30">
          <button onClick={(e) => { e.stopPropagation(); setRevealed(true); }}
            className="px-4 py-2 rounded-full bg-buddy-surface text-sm text-buddy-text-primary font-medium hover:bg-buddy-surface-raised transition-colors">
            Sensitive content. Tap to reveal.
          </button>
        </div>
      )}

      {/* Desktop arrows */}
      {idx > 0 && (
        <button
          onClick={(e) => { e.stopPropagation(); scrollToPage(idx - 1); }}
          className="hidden md:flex absolute left-2 top-1/2 -translate-y-1/2 p-1.5 rounded-full bg-black/50 hover:bg-black/70 text-white opacity-0 group-hover:opacity-100 transition-opacity"
          aria-label="Previous media"
        ><ChevronLeft size={16} /></button>
      )}
      {idx < pages.length - 1 && (
        <button
          onClick={(e) => { e.stopPropagation(); scrollToPage(idx + 1); }}
          className="hidden md:flex absolute right-2 top-1/2 -translate-y-1/2 p-1.5 rounded-full bg-black/50 hover:bg-black/70 text-white opacity-0 group-hover:opacity-100 transition-opacity"
          aria-label="Next media"
        ><ChevronRight size={16} /></button>
      )}

      {/* Dots — active elongates */}
      {pages.length > 1 && (
        <div className="absolute bottom-2 left-1/2 -translate-x-1/2 flex gap-1">
          {pages.map((_, i) => (
            <button key={i} onClick={(e) => { e.stopPropagation(); scrollToPage(i); }} aria-label={`Go to media ${i + 1}`}
              className={`h-1.5 rounded-full transition-all ${i === idx ? 'bg-buddy-green w-4' : 'bg-white/50 w-1.5'}`} />
          ))}
        </div>
      )}
    </div>
  );
}

// ─── Main PostCard ────────────────────────────────────────────────────────────
interface PostCardProps {
  post: Post;
  onComment?: (postId: string) => void;
}

export function PostCard({ post: initialPost, onComment }: PostCardProps) {
  const navigate = useNavigate();
  const [post] = useState(initialPost);
  const [isSaved, setIsSaved] = useState(post.is_saved ?? false);
  const [saveCount, setSaveCount] = useState<number | undefined>(post.save_count);
  const [reactionCounts, setReactionCounts] = useState(post.reaction_counts || {});
  const [userReaction, setUserReaction] = useState<string | null>(
    post.user_reaction ? toEmoji(post.user_reaction) : null,
  );
  const [showReactionPicker, setShowReactionPicker] = useState(false);
  const [repostCount, setRepostCount] = useState(post.repost_count || 0);
  const [isRepostedByMe, setIsRepostedByMe] = useState(post.is_reposted_by_me ?? false);
  const [shareCount, setShareCount] = useState(post.share_count ?? 0);
  const [viewCount, setViewCount] = useState(post.view_count ?? 0);
  const [showShareSheet, setShowShareSheet] = useState(false);
  const [heartPop, setHeartPop] = useState<{ show: boolean; x: number; y: number } | null>(null);
  const longPressTimer = useRef<ReturnType<typeof setTimeout> | null>(null);
  const longPressFired = useRef(false);

  const reactionsArr = Object.entries(reactionCounts)
    .filter(([, count]) => count > 0)
    .sort((a, b) => b[1] - a[1]);
  const topReactions = reactionsArr.slice(0, 3);
  const likeCount = totalReactions(reactionCounts);

  /** One-tap toggles 💪 (optimistic w/ rollback). Long-press opens the picker. */
  const togglePump = async () => {
    const prevCounts = reactionCounts;
    const prevReaction = userReaction;
    const next = nextReactionState(reactionCounts, userReaction, '💪');
    setReactionCounts(next.counts);
    setUserReaction(next.userReaction);
    try {
      if (next.removed) await feedApi.unreact(post.id);
      else await feedApi.react(post.id, '💪');
    } catch {
      setReactionCounts(prevCounts);
      setUserReaction(prevReaction);
    }
  };

  const handleReact = async (emojiStr: string) => {
    const emoji = toEmoji(emojiStr);
    setShowReactionPicker(false);
    if (emoji === userReaction) {
      const prevCounts = reactionCounts;
      setUserReaction(null);
      setReactionCounts(prev => {
        const next = { ...prev };
        if (next[emoji] > 1) next[emoji]--;
        else delete next[emoji];
        return next;
      });
      try {
        await feedApi.unreact(post.id);
      } catch {
        setUserReaction(emoji);
        setReactionCounts(prevCounts);
      }
      return;
    }
    const prevCounts = reactionCounts;
    const prevReaction = userReaction;
    const next = nextReactionState(reactionCounts, userReaction, emoji);
    setReactionCounts(next.counts);
    setUserReaction(next.userReaction);
    try {
      await feedApi.react(post.id, emoji);
    } catch {
      setReactionCounts(prevCounts);
      setUserReaction(prevReaction);
    }
  };

  const startLongPress = () => {
    longPressFired.current = false;
    if (longPressTimer.current) clearTimeout(longPressTimer.current);
    longPressTimer.current = setTimeout(() => {
      longPressFired.current = true;
      setShowReactionPicker(true);
    }, 450);
  };
  const cancelLongPress = () => {
    if (longPressTimer.current) { clearTimeout(longPressTimer.current); longPressTimer.current = null; }
  };
  useEffect(() => cancelLongPress, []);

  const handleSave = async () => {
    const prev = isSaved;
    const prevCount = saveCount;
    setIsSaved(!prev);
    if (saveCount !== undefined) setSaveCount(Math.max(0, saveCount + (prev ? -1 : 1)));
    try {
      if (prev) await feedApi.unsave(post.id);
      else await feedApi.save(post.id);
    } catch {
      setIsSaved(prev);
      if (prevCount !== undefined) setSaveCount(prevCount);
    }
  };

  const handleRepost = async (e?: React.MouseEvent) => {
    e?.stopPropagation();
    // Optimistic update
    const wasReposted = isRepostedByMe;
    setIsRepostedByMe(!wasReposted);
    setRepostCount(c => wasReposted ? Math.max(0, c - 1) : c + 1);
    try {
      const res = await feedApi.repost(post.id);
      if (res.data) {
        setRepostCount(res.data.repost_count);
        setIsRepostedByMe(res.data.action === 'reposted');
      }
    } catch {
      // Rollback on error
      setIsRepostedByMe(wasReposted);
      setRepostCount(c => wasReposted ? c + 1 : Math.max(0, c - 1));
    }
  };

  const handleDoubleClick = (e: React.MouseEvent<HTMLDivElement>) => {
    const rect = e.currentTarget.getBoundingClientRect();
    setHeartPop(null);
    requestAnimationFrame(() => {
      setHeartPop({ show: true, x: e.clientX - rect.left, y: e.clientY - rect.top });
    });
    setTimeout(() => setHeartPop(null), 700);
    // Double-tap always likes with 💪 (no-op if already the active reaction).
    if (userReaction !== '💪') void handleReact('💪');
  };

  const displayPost = (post.is_repost && post.original_post_data) ? post.original_post_data : post;
  const displayAuthor = displayPost.author_data;

  return (
    <article
      id={`post-${post.id}`}
      className={`flex gap-1 bg-buddy-surface rounded-2xl border ${post.is_repost ? 'border-buddy-green/30 shadow-[0_0_15px_rgba(0,255,157,0.05)]' : 'border-buddy-surface-raised hover:border-buddy-green/20'} transition-colors select-none flex-col`}
    >
      {/* Repost Header Ribbon */}
      {post.is_repost && (
        <div className="flex items-center gap-2 px-4 py-2.5 bg-buddy-green/10 border-l-4 border-buddy-green shadow-[0_2px_10px_rgba(0,255,157,0.1)] text-xs">
          {(post as any).reposters && (post as any).reposters.length > 0 ? (
            <div className="flex items-center -space-x-2 flex-shrink-0">
              {(post as any).reposters.slice(0, 3).map((reposter: any, idx: number) => (
                <Avatar key={reposter.user_id || idx} src={reposter.avatar_url} alt={reposter.display_name} size="xs" className="ring-2 ring-buddy-green/30" style={{ zIndex: 3 - idx }} verificationStatus={reposter.verification_status} />
              ))}
              {(post as any).reposters.length > 3 && (
                <div className="w-6 h-6 rounded-full bg-buddy-surface-raised text-[10px] font-bold flex items-center justify-center ring-2 ring-buddy-green/30">
                  +{(post as any).reposters.length - 3}
                </div>
              )}
            </div>
          ) : (
            <button onClick={(e) => { e.stopPropagation(); navigate(`/${post.author_data?.username}`); }} className="flex-shrink-0">
              <Avatar src={post.author_data?.avatar_url} alt={post.author_data?.display_name || 'User'} size="xs" className="ring-2 ring-buddy-green/30" verificationStatus={post.author_data?.verification_status} />
            </button>
          )}
          <div className="flex-1 min-w-0 flex items-center gap-1.5">
            <span className="font-semibold text-buddy-green cursor-pointer truncate" onClick={(e) => { e.stopPropagation(); navigate(`/${post.author_data?.username}`); }}>
              {post.author_data?.display_name}
            </span>
            <span className="text-buddy-text-secondary flex-shrink-0">reposted</span>
            {post.quote_body && (
              <span className="text-buddy-text-primary truncate border-l border-buddy-green/40 pl-1.5 italic flex-1">
                "{post.quote_body}"
              </span>
            )}
          </div>
        </div>
      )}

      <div className="flex gap-1">
        {/* Main content — left 88% */}
        <div onDoubleClick={handleDoubleClick} className="relative flex-1 min-w-0 p-4 pt-3">
          {/* Pinned banner */}
          {post.is_pinned && (
            <div className="flex items-center gap-1.5 text-xs text-buddy-gold font-medium mb-2">
              📌 Pinned post
            </div>
          )}

          {/* Header */}
          <div className="flex items-start gap-2">
            <div className="flex-1 min-w-0">
              <AuthorChip author={displayAuthor} />
              <div className="flex items-center gap-1.5 mt-1 ml-[52px] flex-wrap">
                <span className="text-xs text-buddy-text-secondary leading-tight">
                  {formatPostDate(displayPost.created_at)}
                </span>
                {(displayPost as any).gym_tag_name && (
                  <span className="inline-flex items-center gap-1 text-[10px] bg-buddy-green/10 text-buddy-green px-2 py-0.5 rounded-full">
                    <Dumbbell size={9} /> {(displayPost as any).gym_tag_name}
                  </span>
                )}
                {displayPost.location_label && (
                  <span className="inline-flex items-center gap-0.5 text-[10px] text-buddy-text-secondary">
                    <MapPin size={9} /> {displayPost.location_label}
                  </span>
                )}
              </div>
            </div>
            <button className="p-1 rounded-lg hover:bg-buddy-surface text-buddy-text-secondary flex-shrink-0" aria-label="More options">
              <MoreHorizontal size={16} />
            </button>
          </div>

          {/* Body — masked client-side when the profanity filter is on */}
          {displayPost.body && (
            <p className="mt-2 text-sm text-buddy-text-primary whitespace-pre-wrap">
              <RichText text={isProfanityFilterEnabled() ? maskProfanity(displayPost.body) : displayPost.body} />
            </p>
          )}

          {/* Rich content */}
          {displayPost.post_type === 'workout_log' && displayPost.workout_log_data && <WorkoutLogCard data={displayPost.workout_log_data as Record<string, unknown>} />}
          {displayPost.post_type === 'meal' && displayPost.meal_data && <MealCard data={displayPost.meal_data} />}
          {displayPost.post_type === 'progress' && displayPost.progress_data && <ProgressCard data={displayPost.progress_data} mediaUrls={displayPost.media_urls || []} />}
          {displayPost.post_type === 'poll' && (displayPost as any).poll && <PollCard poll={(displayPost as any).poll} postId={displayPost.id} />}

          {/* Media */}
          <MediaGallery post={displayPost} blurred={post.moderation_status === 'flagged'} postId={post.id} onViewRecorded={setViewCount} />

          {/* Map */}
          {displayPost.location_lat != null && displayPost.location_lng != null && (
            <PostMap lat={displayPost.location_lat} lng={displayPost.location_lng} label={displayPost.location_label} />
          )}

          {/* Heart pop overlay */}
          {heartPop?.show && (
            <span
              className="absolute pointer-events-none text-3xl select-none animate-heart-pop"
              style={{ left: heartPop.x, top: heartPop.y }}
            >
              💪
            </span>
          )}
        </div>

        {/* Side action bar — right column */}
        <div onClick={e => e.stopPropagation()} className="flex flex-col items-center justify-center gap-0.5 py-4 pr-2 border-l border-buddy-surface min-w-[52px]">
          {/* Like — one-tap toggles 💪, long-press opens other reactions */}
          <div
            className="relative flex flex-col items-center"
            onPointerDown={startLongPress}
            onPointerUp={cancelLongPress}
            onPointerLeave={cancelLongPress}
          >
            <RailAction
              label={userReaction ? `Liked with ${userReaction}` : 'Like with flexed biceps'}
              title="Tap to 💪 · long-press for more reactions"
              count={likeCount}
              active={!!userReaction}
              testId="rail-like"
              onClick={() => {
                // A completed long-press already opened the picker; skip the tap.
                if (longPressFired.current) { longPressFired.current = false; return; }
                void togglePump();
              }}
              onContextMenu={(e) => { e.preventDefault(); setShowReactionPicker(true); }}
              icon={userReaction ? (
                <EmojiImg emoji={userReaction} size={RAIL_ICON_SIZE} />
              ) : (
                <Heart size={RAIL_ICON_SIZE} />
              )}
            />
            {reactionsArr.length > 0 && (
              <button
                type="button"
                onClick={(e) => { e.stopPropagation(); setShowReactionPicker(p => !p); }}
                className="flex -space-x-1 -mt-1"
                aria-label="See all reactions"
              >
                {topReactions.map(([emojiChar]) => (
                  <EmojiImg key={emojiChar} emoji={emojiChar} size={16} className="z-10 rounded-full ring-1 ring-buddy-surface" />
                ))}
              </button>
            )}

            {/* Reaction picker popup */}
            {showReactionPicker && (
              <>
                <div className="fixed inset-0 z-10" onClick={() => setShowReactionPicker(false)} />
                <div className="absolute right-full top-0 mr-2 z-20 shadow-2xl max-h-[80vh] overflow-y-auto">
                  <EmojiPicker
                    theme={Theme.DARK}
                    emojiStyle={EmojiStyle.APPLE}
                    onEmojiClick={(emojiData) => void handleReact(emojiData.emoji)}
                    lazyLoadEmojis
                    searchDisabled
                    skinTonesDisabled
                    width={320}
                    height={350}
                  />
                </div>
              </>
            )}
          </div>

          {/* Comment */}
          <RailAction
            label="Comments"
            icon={<MessageCircle size={RAIL_ICON_SIZE} />}
            count={displayPost.comment_count || 0}
            testId="rail-comment"
            onClick={() => onComment?.(displayPost.id)}
          />

          {/* Repost */}
          <div title={isRepostedByMe ? 'Tap to undo repost' : 'Repost'}>
            <RailAction
              label={isRepostedByMe ? 'Undo repost' : 'Repost'}
              icon={<Repeat2 size={RAIL_ICON_SIZE} />}
              count={repostCount}
              active={isRepostedByMe}
              activeClassName="text-buddy-electric"
              testId="rail-repost"
              onClick={handleRepost}
            />
          </div>

          {/* Save */}
          <RailAction
            label={isSaved ? 'Unsave' : 'Save'}
            icon={isSaved ? <BookmarkCheck size={RAIL_ICON_SIZE} /> : <Bookmark size={RAIL_ICON_SIZE} />}
            count={saveCount}
            active={isSaved}
            testId="rail-save"
            onClick={() => void handleSave()}
          />

          {/* Share */}
          <RailAction
            label="Share"
            icon={<Share2 size={RAIL_ICON_SIZE} />}
            count={shareCount}
            testId="rail-share"
            onClick={() => setShowShareSheet(true)}
          />

          {/* Views */}
          <RailAction
            label={`${viewCount} views`}
            icon={<Eye size={RAIL_ICON_SIZE} />}
            count={viewCount}
            testId="rail-views"
          />
        </div>
      </div>

      {showShareSheet && (
        <PostShareSheet
          post={post}
          isOpen={showShareSheet}
          onClose={() => setShowShareSheet(false)}
          isSaved={isSaved}
          onToggleSave={() => void handleSave()}
          isReposted={isRepostedByMe}
          onRepost={() => void handleRepost()}
          onShared={setShareCount}
        />
      )}
    </article>
  );
}
