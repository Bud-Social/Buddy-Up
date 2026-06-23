import { useState, useEffect } from 'react';
import { X, Send, Heart } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Avatar } from '@/components/ui/Avatar';
import { feedApi } from '@/api';
import type { Comment } from '@/types';

interface CommentSheetProps {
  postId: string;
  isOpen: boolean;
  onClose: () => void;
}

export function CommentSheet({ postId, isOpen, onClose }: CommentSheetProps) {
  const [comments, setComments] = useState<Comment[]>([]);
  const [body, setBody] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [sort, setSort] = useState<'newest' | 'oldest' | 'top'>('newest');

  useEffect(() => {
    if (!isOpen) return;
    feedApi.getComments(postId).then((res) => setComments(res.data || [])).catch(() => {});
  }, [isOpen, postId]);

  const handleSubmit = async () => {
    if (!body.trim()) return;
    setIsLoading(true);
    try {
      const res = await feedApi.comment(postId, body.trim());
      setComments((prev) => [res.data as unknown as Comment, ...prev]);
      setBody('');
    } catch {} finally { setIsLoading(false); }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex flex-col bg-buddy-black">
      <div className="flex items-center justify-between p-4 border-b border-buddy-surface">
        <h2 className="font-heading font-semibold text-lg">Comments</h2>
        <button onClick={onClose} className="p-1 rounded-lg hover:bg-buddy-surface text-buddy-text-secondary">
          <X size={22} />
        </button>
      </div>

      <div className="flex gap-2 px-4 py-2 border-b border-buddy-surface">
        {(['newest', 'oldest', 'top'] as const).map((s) => (
          <button key={s} onClick={() => setSort(s)}
            className={`text-xs px-3 py-1.5 rounded-full capitalize transition-colors ${sort === s ? 'bg-buddy-green text-buddy-black font-medium' : 'text-buddy-text-secondary hover:text-buddy-text-primary'}`}
          >{s}</button>
        ))}
      </div>

      <div className="flex-1 overflow-y-auto px-4 py-3 space-y-4">
        {comments.length === 0 ? (
          <div className="text-center py-12 text-buddy-text-secondary">No comments yet. Be the first!</div>
        ) : (
          comments.map((c) => (
            <div key={c.id} className="flex gap-3">
              <Avatar src={c.author_data?.avatar_url} alt={c.author_data?.display_name || 'User'} size="sm" />
              <div className="flex-1 min-w-0">
                <p className="text-sm">
                  <span className="font-medium">{c.author_data?.display_name}</span>
                  <span className="text-buddy-text-secondary text-xs ml-1">@{c.author_data?.username}</span>
                </p>
                <p className="text-sm mt-0.5">{c.body}</p>
                <div className="flex items-center gap-3 mt-1">
                  <span className="text-xs text-buddy-text-secondary">{new Date(c.created_at).toLocaleDateString()}</span>
                  <button className="text-xs text-buddy-text-secondary hover:text-buddy-green">
                    <Heart size={12} className="inline mr-0.5" /> Reply
                  </button>
                </div>
              </div>
            </div>
          ))
        )}
      </div>

      <div className="p-4 border-t border-buddy-surface">
        <div className="flex gap-3 items-center">
          <input
            type="text"
            value={body}
            onChange={(e) => setBody(e.target.value)}
            placeholder="Add a comment..."
            className="flex-1 bg-buddy-surface rounded-xl px-4 py-3 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30"
            onKeyDown={(e) => e.key === 'Enter' && handleSubmit()}
          />
          <Button size="sm" onClick={handleSubmit} isLoading={isLoading} disabled={!body.trim()}>
            <Send size={14} />
          </Button>
        </div>
      </div>
    </div>
  );
}
