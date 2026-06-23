import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Heart, MessageCircle, Repeat2, Bookmark, BookmarkCheck, MoreHorizontal, Dumbbell, Utensils, TrendingUp, BarChart3 } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Avatar } from '@/components/ui/Avatar';
import { ReactionBar } from './ReactionBar';
import type { Post } from '@/types';

interface PostCardProps {
  post: Post;
  onComment?: (postId: string) => void;
  onSave?: (postId: string) => void;
}

const reactionIcons: Record<string, string> = {
  pump: '💪', fire: '🔥', respect: '🤝', grind: '😤', lets_go: '🏋️', haha: '😂', too_hard: '💀',
};

function WorkoutLogCard({ data }: { data: Record<string, unknown> }) {
  return (
    <div className="bg-buddy-surface-raised rounded-xl p-4 mt-3">
      <div className="flex items-center gap-2 mb-2">
        <Dumbbell size={16} className="text-buddy-green" />
        <span className="font-heading font-semibold text-sm">{data.exercise as string || 'Workout'}</span>
      </div>
      <div className="grid grid-cols-3 gap-3 text-center">
        <div>
          <p className="font-mono font-bold text-lg text-buddy-green">{data.sets as string || '-'}</p>
          <p className="text-xs text-buddy-text-secondary">Sets</p>
        </div>
        <div>
          <p className="font-mono font-bold text-lg text-buddy-green">{data.reps as string || '-'}</p>
          <p className="text-xs text-buddy-text-secondary">Reps</p>
        </div>
        <div>
          <p className="font-mono font-bold text-lg text-buddy-orange">{data.calories as string || '-'}</p>
          <p className="text-xs text-buddy-text-secondary">Cal</p>
        </div>
      </div>
    </div>
  );
}

function MealCard({ data }: { data: Record<string, unknown> }) {
  return (
    <div className="bg-buddy-surface-raised rounded-xl p-4 mt-3">
      <div className="flex items-center gap-2 mb-2">
        <Utensils size={16} className="text-buddy-orange" />
        <span className="font-heading font-semibold text-sm">{data.meal_type as string || 'Meal'}</span>
      </div>
      <div className="space-y-2">
        {(['protein', 'carbs', 'fats'] as const).map((macro) => {
          const val = (data[macro] as number) || 0;
          const max = { protein: 50, carbs: 80, fats: 30 }[macro];
          const pct = Math.min((val / max) * 100, 100);
          const colors = { protein: 'bg-buddy-electric', carbs: 'bg-buddy-orange', fats: 'bg-buddy-gold' };
          return (
            <div key={macro} className="flex items-center gap-2">
              <span className="text-xs text-buddy-text-secondary w-12 capitalize">{macro}</span>
              <div className="flex-1 h-1.5 bg-buddy-surface rounded-full overflow-hidden">
                <div className={`h-full rounded-full ${colors[macro]}`} style={{ width: `${pct}%` }} />
              </div>
              <span className="text-xs font-mono w-8 text-right">{val}g</span>
            </div>
          );
        })}
      </div>
    </div>
  );
}

function ProgressCard({ data }: { data: Record<string, unknown> }) {
  return (
    <div className="bg-buddy-surface-raised rounded-xl p-4 mt-3">
      <div className="flex items-center gap-2 mb-3">
        <TrendingUp size={16} className="text-buddy-electric" />
        <span className="font-heading font-semibold text-sm">{(data as { label?: string }).label || 'Transformation'}</span>
      </div>
      <div className="grid grid-cols-2 gap-1">
        {(data as { before_url?: string; after_url?: string }).before_url && (
          <div className="aspect-square bg-buddy-surface rounded-lg overflow-hidden relative">
            <img src={(data as { before_url?: string }).before_url} alt="Before" className="w-full h-full object-cover" />
            <span className="absolute top-2 left-2 bg-buddy-black/70 text-xs px-2 py-0.5 rounded-full">Before</span>
          </div>
        )}
        {(data as { after_url?: string }).after_url && (
          <div className="aspect-square bg-buddy-surface rounded-lg overflow-hidden relative">
            <img src={(data as { after_url?: string }).after_url} alt="After" className="w-full h-full object-cover" />
            <span className="absolute top-2 right-2 bg-buddy-green/70 text-xs px-2 py-0.5 rounded-full">After</span>
          </div>
        )}
      </div>
    </div>
  );
}

function MediaGallery({ urls }: { urls: string[] }) {
  const [idx, setIdx] = useState(0);
  if (!urls.length) return null;
  const isVideo = urls[0]?.match(/\.(mp4|mov|webm)/i);
  return (
    <div className="mt-3 relative rounded-xl overflow-hidden">
      {isVideo ? (
        <video src={urls[0]} controls className="w-full max-h-96 object-cover rounded-xl" />
      ) : (
        <img src={urls[idx]} alt="" className="w-full max-h-96 object-cover rounded-xl" loading="lazy" />
      )}
      {urls.length > 1 && (
        <div className="absolute bottom-3 left-1/2 -translate-x-1/2 flex gap-1">
          {urls.map((_, i) => (
            <button key={i} onClick={() => setIdx(i)}
              className={`w-1.5 h-1.5 rounded-full transition-colors ${i === idx ? 'bg-buddy-green' : 'bg-white/40'}`}
            />
          ))}
        </div>
      )}
    </div>
  );
}

export function PostCard({ post, onComment, onSave }: PostCardProps) {
  const navigate = useNavigate();
  const [showReactions, setShowReactions] = useState(false);
  const [isSaved, setIsSaved] = useState(post.is_saved ?? false);

  const totalReactions = Object.values(post.reaction_counts || {}).reduce((a, b) => a + b, 0);
  const topReactions = Object.entries(post.reaction_counts || {}).sort((a, b) => b[1] - a[1]).slice(0, 3);

  return (
    <Card className="p-0 overflow-hidden">
      {post.is_repost && post.quote_body && (
        <div className="px-4 pt-4 pb-2 text-sm text-buddy-text-secondary border-b border-buddy-surface">
          <Repeat2 size={14} className="inline mr-1" /> Reposted
        </div>
      )}

      {/* Header */}
      <div className="flex items-center gap-3 p-4 pb-2">
        <div onClick={() => navigate(`/${post.author_data?.username}`)} className="cursor-pointer">
          <Avatar src={post.author_data?.avatar_url} alt={post.author_data?.display_name || 'User'} size="md" />
        </div>
        <div className="flex-1 min-w-0">
          <button onClick={() => navigate(`/${post.author_data?.username}`)}
            className="font-medium text-sm truncate hover:text-buddy-green transition-colors block">
            {post.author_data?.display_name}
          </button>
          <p className="text-xs text-buddy-text-secondary">
            @{post.author_data?.username} · {new Date(post.created_at).toLocaleDateString()}
            {post.location_label && ` · 📍 ${post.location_label}`}
          </p>
        </div>
        <button className="p-1 rounded-lg hover:bg-buddy-surface text-buddy-text-secondary">
          <MoreHorizontal size={18} />
        </button>
      </div>

      {/* Body */}
      {post.body && <p className="px-4 pb-2 text-sm whitespace-pre-wrap">{post.body}</p>}

      {/* Rich content cards */}
      {post.post_type === 'workout_log' && post.workout_log_data && <div className="px-4"><WorkoutLogCard data={post.workout_log_data} /></div>}
      {post.post_type === 'meal' && post.meal_data && <div className="px-4"><MealCard data={post.meal_data} /></div>}
      {post.post_type === 'progress' && post.progress_data && <div className="px-4"><ProgressCard data={post.progress_data} /></div>}

      {/* Media */}
      <MediaGallery urls={post.media_urls || []} />

      {/* Repost original */}
      {post.is_repost && post.original_post_id && (
        <div className="m-3 border border-buddy-surface rounded-xl p-3 text-sm text-buddy-text-secondary">
          Original post view placeholder
        </div>
      )}

      {/* Action bar */}
      <div className="flex items-center justify-between px-4 py-2 mt-1 border-t border-buddy-surface">
        <div className="flex items-center gap-4">
          <ReactionBar postId={post.id} reactionCounts={post.reaction_counts} userReaction={post.user_reaction}
            topReactions={topReactions} totalReactions={totalReactions}
          />
          <button onClick={() => onComment?.(post.id)}
            className="flex items-center gap-1 text-buddy-text-secondary hover:text-buddy-green transition-colors text-sm">
            <MessageCircle size={16} />
            <span>{post.comment_count || 0}</span>
          </button>
          <button
            className="flex items-center gap-1 text-buddy-text-secondary hover:text-buddy-electric transition-colors text-sm">
            <Repeat2 size={16} />
            <span>{post.repost_count || 0}</span>
          </button>
        </div>
        <button onClick={() => { setIsSaved(!isSaved); onSave?.(post.id); }}
          className={`transition-colors ${isSaved ? 'text-buddy-green' : 'text-buddy-text-secondary hover:text-buddy-green'}`}>
          {isSaved ? <BookmarkCheck size={18} /> : <Bookmark size={18} />}
        </button>
      </div>
    </Card>
  );
}
