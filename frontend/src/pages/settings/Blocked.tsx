import { useCallback, useEffect, useState } from 'react';
import { Loader, RefreshCw, UserX } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Avatar } from '@/components/ui/Avatar';
import { useToast } from '@/components/ui/Toast';
import { profilesApi } from '@/api';
import type { Profile } from '@/types';
import { SectionShell } from './SectionShell';

export default function Blocked() {
  const { toast } = useToast();
  const [blocked, setBlocked] = useState<Profile[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [unblocking, setUnblocking] = useState<string | null>(null);
  const [refreshing, setRefreshing] = useState(false);

  const load = useCallback((showRefreshing = false) => {
    if (showRefreshing) setRefreshing(true);
    else setLoading(true);
    setError('');
    profilesApi.getBlocked()
      .then((res) => setBlocked(res.data || []))
      .catch(() => setError('Could not load blocked users.'))
      .finally(() => { setLoading(false); setRefreshing(false); });
  }, []);

  useEffect(() => { load(); }, [load]);

  const handleUnblock = async (username: string) => {
    setUnblocking(username);
    try {
      await profilesApi.unblock(username);
      setBlocked((bs) => bs.filter((b) => b.username !== username));
      toast('success', `Unblocked @${username}`);
    } catch {
      toast('error', `Failed to unblock @${username}`);
    } finally {
      setUnblocking(null);
    }
  };

  return (
    <SectionShell title="Blocked Users">
      <div className="space-y-4">
        <div className="flex justify-end">
          <Button size="sm" variant="ghost" onClick={() => load(true)} disabled={refreshing} aria-label="Refresh blocked users">
            <RefreshCw size={14} className={`mr-1 ${refreshing ? 'animate-spin' : ''}`} /> Refresh
          </Button>
        </div>

        {error && (
          <Card className="p-4 text-center">
            <p className="text-sm text-buddy-red mb-2">{error}</p>
            <Button size="sm" variant="outline" onClick={() => load()}>Try Again</Button>
          </Card>
        )}

        {loading ? (
          <Card className="p-8 text-center"><Loader size={24} className="animate-spin text-buddy-text-secondary mx-auto" /></Card>
        ) : !error && blocked.length === 0 ? (
          <Card className="p-8 text-center">
            <UserX size={32} className="mx-auto text-buddy-text-secondary/30 mb-3" />
            <p className="text-sm text-buddy-text-secondary">No blocked users</p>
          </Card>
        ) : (
          !error && blocked.map((u) => (
            <Card key={u.username} className="p-3 flex items-center justify-between">
              <div className="flex items-center gap-3 min-w-0">
                <Avatar src={u.avatar_url} alt={u.display_name} size="sm" />
                <div className="min-w-0">
                  <p className="text-sm font-medium truncate">{u.display_name}</p>
                  <p className="text-xs text-buddy-text-secondary">@{u.username}</p>
                </div>
              </div>
              <Button size="sm" variant="ghost" isLoading={unblocking === u.username} onClick={() => handleUnblock(u.username)}>
                Unblock
              </Button>
            </Card>
          ))
        )}
      </div>
    </SectionShell>
  );
}
