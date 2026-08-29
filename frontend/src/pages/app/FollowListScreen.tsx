import { useState, useEffect, useMemo } from 'react';
import { useNavigate, useParams, useLocation } from 'react-router-dom';
import { ArrowLeft } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Avatar } from '@/components/ui/Avatar';
import { Loader2 } from 'lucide-react';
import { profilesApi } from '@/api/profiles';
import type { Profile } from '@/types';

type ListKind = 'followers' | 'following';

/**
 * FollowListScreen — followers / following list behind the Profile stat cards.
 */
export default function FollowListScreen() {
  const { username } = useParams<{ username: string }>();
  const location = useLocation();
  const kind: ListKind = location.pathname.endsWith('/following') ? 'following' : 'followers';
  const navigate = useNavigate();
  const [list, setList] = useState<Profile[] | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    if (!username) return;
    setIsLoading(true);
    const fetcher = kind === 'following'
      ? profilesApi.getFollowing(username)
      : profilesApi.getFollowers(username);
    fetcher
      .then((res) => setList(res.data || []))
      .catch(() => setError('Could not load this list.'))
      .finally(() => setIsLoading(false));
  }, [username, kind]);

  const title = useMemo(() => (kind === 'following' ? 'Following' : 'Followers'), [kind]);

  return (
    <div className="max-w-lg mx-auto p-4">
      <div className="flex items-center gap-3 mb-4">
        <button onClick={() => navigate(-1)} className="p-2 rounded-full hover:bg-buddy-surface transition-colors">
          <ArrowLeft size={20} />
        </button>
        <h1 className="font-display text-xl font-extrabold">{title}</h1>
      </div>

      {isLoading ? (
        <div className="flex justify-center py-12"><Loader2 className="animate-spin text-buddy-green" size={24} /></div>
      ) : error ? (
        <Card className="p-6 text-center text-buddy-text-secondary">{error}</Card>
      ) : !list || list.length === 0 ? (
        <Card className="p-8 text-center text-buddy-text-secondary">
          Nobody here yet.
        </Card>
      ) : (
        <div className="space-y-2">
          {list.map((p) => (
            <Card
              key={p.user_id}
              className="p-3 flex items-center gap-3 cursor-pointer hover:border-buddy-green/40 transition-colors"
              onClick={() => navigate(`/${p.username}`)}
            >
              <Avatar src={p.avatar_url} alt={p.display_name} size="md" verificationStatus={p.verification_status} />
              <div className="min-w-0 flex-1">
                <p className="font-semibold text-sm truncate">{p.display_name}</p>
                <p className="text-xs text-buddy-text-secondary truncate">@{p.username}</p>
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
