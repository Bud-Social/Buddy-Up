import { useState, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Heart, MessageCircle, Repeat2, Bookmark, BookmarkCheck,
  MoreHorizontal, Dumbbell, Utensils, TrendingUp, MapPin, BarChart2,
  Maximize2, FileText, CheckSquare, CircleDot,
} from 'lucide-react';
import { Avatar } from '@/components/ui/Avatar';
import { feedApi } from '@/api';
import { formatPostDate } from '@/utils/formatDate';
import { EmojiImg } from '@/utils/emojiUtils';
import { useInViewAutoplay } from '@/hooks/useInViewAutoplay';
import type { Post } from '@/types';
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

function MediaGallery({ urls, blurred, postId }: { urls: string[]; blurred?: boolean; postId?: string }) {
  const [idx, setIdx] = useState(0);
  const [revealed, setRevealed] = useState(false);
  const navigate = useNavigate();
  const videoRef = useRef<HTMLVideoElement | null>(null);
  const canAutoplay = !(blurred && !revealed);
  useInViewAutoplay(videoRef, canAutoplay);
  if (!urls.length) return null;
  const currentUrl = urls[idx];
  const isVideo = /\.(mp4|mov|webm|m4v|mpeg|mkv)/i.test(currentUrl);
  const isAudio = /\.(mp3|wav|ogg|m4a|aac)/i.test(currentUrl);
  const isDocument = /\.(pdf|doc|docx|xls|xlsx|ppt|pptx|txt|md|csv)/i.test(currentUrl.split('?')[0]);
  const fileName = currentUrl.split('?')[0].split('/').pop() || 'document';
  return (
    <div className="mt-3 relative rounded-xl overflow-hidden bg-buddy-surface">
      {isVideo ? (
        <div className="relative group">
          <video
            ref={videoRef}
            src={currentUrl}
            controls
            muted
            loop
            playsInline
            preload="metadata"
            className={`w-full max-h-96 object-cover ${blurred && !revealed ? 'blur-xl' : ''}`}
          />
          <button
            onClick={(e) => { e.stopPropagation(); navigate(postId ? `/videos?start=${postId}` : '/videos'); }}
            className="absolute top-2 right-2 p-2 rounded-full bg-black/50 hover:bg-black/70 text-white opacity-0 group-hover:opacity-100 transition-opacity"
            title="Open full-screen video feed"
          ><Maximize2 size={16} /></button>
        </div>
      ) : isAudio ? (
        <div className="p-4 bg-buddy-surface-raised w-full">
          <audio src={currentUrl} controls className="w-full" />
        </div>
      ) : isDocument ? (
        <a href={currentUrl} target="_blank" rel="noreferrer" onClick={(e) => e.stopPropagation()}
          className="flex items-center gap-3 p-4 bg-buddy-surface-raised hover:bg-buddy-surface transition-colors">
          <div className="w-11 h-11 rounded-xl bg-buddy-green/15 text-buddy-green flex items-center justify-center shrink-0">
            <FileText size={22} />
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium truncate">{fileName}</p>
            <p className="text-xs text-buddy-text-secondary">Tap to open document</p>
          </div>
          <Maximize2 size={16} className="text-buddy-text-secondary shrink-0" />
        </a>
      ) : (
        <img src={currentUrl} alt="" className={`w-full max-h-96 object-cover ${blurred && !revealed ? 'blur-xl' : ''}`} loading="lazy" />
      )}
      {blurred && !revealed && (
        <div className="absolute inset-0 flex items-center justify-center bg-black/30">
          <button onClick={(e) => { e.stopPropagation(); setRevealed(true); }}
            className="px-4 py-2 rounded-full bg-buddy-surface text-sm text-buddy-text-primary font-medium hover:bg-buddy-surface-raised transition-colors">
            Sensitive content. Tap to reveal.
          </button>
        </div>
      )}
      {urls.length > 1 && (
        <div className="absolute bottom-2 left-1/2 -translate-x-1/2 flex gap-1">
          {urls.map((_, i) => (
            <button key={i} onClick={(e) => { e.stopPropagation(); setIdx(i); }}
              className={`w-1.5 h-1.5 rounded-full transition-all ${i === idx ? 'bg-buddy-green w-3' : 'bg-white/50'}`} />
          ))}
        </div>
      )}
    </div>
  );
}

// ─── Side action button ───────────────────────────────────────────────────────
function ActionBtn({ icon: Icon, count, active, color, onClick }: {
  icon: React.ElementType; count?: number; active?: boolean;
  color?: string; onClick?: (e: React.MouseEvent) => void;
}) {
  return (
    <button onClick={onClick}
      className={`flex flex-col items-center gap-0.5 group transition-all ${active ? color || 'text-buddy-green' : 'text-buddy-text-secondary hover:text-buddy-green'}`}>
      <div className="p-2 rounded-full group-hover:bg-buddy-green/10 transition-colors">
        <Icon size={20} />
      </div>
      {count !== undefined && <span className="text-[11px] font-medium leading-none">{count}</span>}
    </button>
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
  const [reactionCounts, setReactionCounts] = useState(post.reaction_counts || {});
  const [userReaction, setUserReaction] = useState(post.user_reaction);
  const [showReactionPicker, setShowReactionPicker] = useState(false);
  const [repostCount, setRepostCount] = useState(post.repost_count || 0);
  const [isRepostedByMe, setIsRepostedByMe] = useState(post.is_reposted_by_me ?? false);
  const [heartPop, setHeartPop] = useState<{ show: boolean; x: number; y: number } | null>(null);

  const reactionsArr = Object.entries(reactionCounts)
    .filter(([, count]) => count > 0)
    .sort((a, b) => b[1] - a[1]);
  const topReactions = reactionsArr.slice(0, 3);

  const handleReact = async (emojiStr: string) => {
    setShowReactionPicker(false);
    try {
      if (userReaction === emojiStr) {
        await feedApi.unreact(post.id);
        setUserReaction(null);
        setReactionCounts(prev => {
          const next = { ...prev };
          if (next[emojiStr] > 1) next[emojiStr]--;
          else delete next[emojiStr];
          return next;
        });
      } else {
        await feedApi.react(post.id, emojiStr);
        setReactionCounts(prev => {
          const next = { ...prev };
          if (userReaction && next[userReaction]) {
            if (next[userReaction] > 1) next[userReaction]--;
            else delete next[userReaction];
          }
          next[emojiStr] = (next[emojiStr] || 0) + 1;
          return next;
        });
        setUserReaction(emojiStr);
      }
    } catch {}
  };

  const handleSave = async () => {
    setIsSaved(s => !s);
    try { await feedApi.save(post.id); } catch {}
  };

  const handleRepost = async (e: React.MouseEvent) => {
    e.stopPropagation();
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
    if (userReaction !== '💪') {
      handleReact('💪');
      const rect = e.currentTarget.getBoundingClientRect();
      setHeartPop(null);
      requestAnimationFrame(() => {
        setHeartPop({ show: true, x: e.clientX - rect.left, y: e.clientY - rect.top });
      });
      setTimeout(() => setHeartPop(null), 700);
    }
  };

  const displayPost = (post.is_repost && post.original_post_data) ? post.original_post_data : post;
  const displayAuthor = displayPost.author_data;

  return (
    <article
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
          <div className="flex items-start gap-2.5">
            <button onClick={() => navigate(`/${displayAuthor?.username}`)} className="flex-shrink-0 mt-0.5">
              <Avatar src={displayAuthor?.avatar_url} alt={displayAuthor?.display_name || 'User'} size="md" verificationStatus={displayAuthor?.verification_status} />
            </button>
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-1.5">
                <button onClick={() => navigate(`/${displayAuthor?.username}`)}
                  className="font-semibold text-sm hover:text-buddy-green transition-colors truncate leading-tight">
                  {displayAuthor?.display_name}
                </button>
                {displayAuthor?.verification_status === 'trainer' && (
                  <span className="text-[10px] bg-buddy-green/20 text-buddy-green px-1.5 py-0.5 rounded-full font-medium leading-tight shrink-0">Trainer</span>
                )}
                {displayAuthor?.verification_status === 'practitioner' && (
                  <span className="text-[10px] bg-buddy-gold/20 text-buddy-gold px-1.5 py-0.5 rounded-full font-medium leading-tight shrink-0">Practitioner</span>
                )}
                {displayAuthor?.verification_status === 'shop' && (
                  <span className="text-[10px] bg-buddy-electric/20 text-buddy-electric px-1.5 py-0.5 rounded-full font-medium leading-tight shrink-0">Shop</span>
                )}
                {displayAuthor?.verification_status === 'gym' && (
                  <span className="text-[10px] bg-buddy-green/20 text-buddy-green px-1.5 py-0.5 rounded-full font-medium leading-tight shrink-0">Gym</span>
                )}
              </div>
              <p className="text-xs text-buddy-text-secondary leading-tight">
                @{displayAuthor?.username} · {formatPostDate(displayPost.created_at)}
              </p>
            {/* Gym badge */}
            {(displayPost as any).gym_tag_name && (
              <span className="inline-flex items-center gap-1 text-[10px] bg-buddy-green/10 text-buddy-green px-2 py-0.5 rounded-full mt-1">
                <Dumbbell size={9} /> {(displayPost as any).gym_tag_name}
              </span>
            )}
            {/* Location */}
            {displayPost.location_label && (
              <span className="inline-flex items-center gap-0.5 text-[10px] text-buddy-text-secondary mt-1 ml-1">
                <MapPin size={9} /> {displayPost.location_label}
              </span>
            )}
          </div>
          <button className="p-1 rounded-lg hover:bg-buddy-surface text-buddy-text-secondary flex-shrink-0">
            <MoreHorizontal size={16} />
          </button>
        </div>

          {/* Body */}
          {displayPost.body && (
            <p className="mt-2 text-sm text-buddy-text-primary whitespace-pre-wrap">
              <RichText text={displayPost.body} />
            </p>
          )}

          {/* Rich content */}
          {displayPost.post_type === 'workout_log' && displayPost.workout_log_data && <WorkoutLogCard data={displayPost.workout_log_data as Record<string, unknown>} />}
          {displayPost.post_type === 'meal' && displayPost.meal_data && <MealCard data={displayPost.meal_data} />}
          {displayPost.post_type === 'progress' && displayPost.progress_data && <ProgressCard data={displayPost.progress_data} mediaUrls={displayPost.media_urls || []} />}
          {displayPost.post_type === 'poll' && (displayPost as any).poll && <PollCard poll={(displayPost as any).poll} postId={displayPost.id} />}

          {/* Media */}
          <MediaGallery urls={displayPost.media_urls || []} blurred={post.moderation_status === 'flagged'} postId={displayPost.id} />

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
        <div onClick={e => e.stopPropagation()} className="flex flex-col items-center justify-center gap-1 py-4 pr-2 border-l border-buddy-surface min-w-[52px]">
          {/* React */}
          <div className="relative">
            <button
              onClick={() => setShowReactionPicker(p => !p)}
              className={`flex flex-col items-center gap-0.5 group transition-all ${userReaction ? 'text-buddy-green' : 'text-buddy-text-secondary hover:text-buddy-green'}`}
            >
              <div className="p-2 rounded-full group-hover:bg-buddy-green/10 transition-colors">
                <Heart size={20} />
              </div>
              {reactionsArr.length > 0 && (
                <div className="flex flex-col items-center mt-1">
                  <div className="flex -space-x-1">
                    {topReactions.map(([emojiChar]) => (
                      <EmojiImg key={emojiChar} emoji={emojiChar} size={18} className="z-10 rounded-full" />
                    ))}
                  </div>
                  <span className="text-[10px] mt-0.5">
                    {reactionsArr.reduce((sum, [, count]) => sum + count, 0)}
                  </span>
                </div>
              )}
            </button>

            {/* Reaction picker popup */}
            {showReactionPicker && (
              <>
                <div className="fixed inset-0 z-10" onClick={() => setShowReactionPicker(false)} />
                <div className="absolute right-full top-0 mr-2 z-20 shadow-2xl max-h-[80vh] overflow-y-auto">
                  <EmojiPicker
                    theme={Theme.DARK}
                    emojiStyle={EmojiStyle.APPLE}
                    onEmojiClick={(emojiData) => handleReact(emojiData.emoji)}
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
          <ActionBtn icon={MessageCircle} count={displayPost.comment_count || 0} onClick={() => onComment?.(displayPost.id)} />

          {/* Repost */}
          <div title={isRepostedByMe ? 'Tap to undo repost' : 'Repost'}>
            <ActionBtn icon={Repeat2} count={repostCount} active={isRepostedByMe} onClick={handleRepost} color="text-buddy-electric" />
          </div>

          {/* Save */}
          <button onClick={handleSave}
            className={`flex flex-col items-center gap-0.5 transition-all ${isSaved ? 'text-buddy-green' : 'text-buddy-text-secondary hover:text-buddy-green'}`}>
            <div className="p-2 rounded-full hover:bg-buddy-green/10 transition-colors">
              {isSaved ? <BookmarkCheck size={20} /> : <Bookmark size={20} />}
            </div>
          </button>
        </div>
      </div>
    </article>
  );
}
