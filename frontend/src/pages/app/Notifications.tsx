import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { Bell, UserPlus, Users, Zap, Heart, MessageCircle, RefreshCcw, Radio } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { notificationsApi, profilesApi } from '@/api';
import { useNotificationStore } from '@/store/notificationStore';

const iconMap: Record<string, typeof Bell> = {
  buddy_request: UserPlus,
  buddy_accepted: Users,
  buddy_declined: Users,
  new_follower: UserPlus,
  accountability_ping: Zap,
  comment: MessageCircle,
  comment_reply: MessageCircle,
  post_reaction: Heart,
  post_repost: RefreshCcw,
  streak_milestone: Zap,
  live_starting: Radio,
  live_reminder: Radio,
  default: Bell,
};

function LiveCountdown({ scheduledFor }: { scheduledFor?: string | null }) {
  const [now, setNow] = useState(() => Date.now());
  useEffect(() => {
    const t = setInterval(() => setNow(Date.now()), 30000);
    return () => clearInterval(t);
  }, []);
  if (!scheduledFor) return null;
  const start = new Date(scheduledFor).getTime();
  const diff = start - now;
  if (diff <= 0) return <span className="text-buddy-red font-medium">Live now — join!</span>;
  const mins = Math.max(1, Math.ceil(diff / 60000));
  const label = mins >= 60 ? `${Math.floor(mins / 60)}h ${mins % 60}m` : `${mins}m`;
  return <span className="text-buddy-green font-medium">Starts in {label}</span>;
}

export default function Notifications() {
  const { notifications, unreadCount, setNotifications, markAllRead } = useNotificationStore();
  const [isLoading, setIsLoading] = useState(true);
  const navigate = useNavigate();

  const fetchNotifications = useCallback(async () => {
    try {
      const res = await notificationsApi.getList();
      setNotifications(res.data);
    } catch {} finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => { fetchNotifications(); }, [fetchNotifications]);

  const handleMarkRead = async (id: string) => {
    try {
      await notificationsApi.markRead(id);
      useNotificationStore.getState().markRead(id);
    } catch {}
  };

  const handleMarkAllRead = async () => {
    try {
      await notificationsApi.markAllRead();
      markAllRead();
    } catch {}
  };

  const handleAcceptBuddy = async (username: string, notificationId: string) => {
    try {
      await profilesApi.acceptBuddyRequest(username);
      handleMarkRead(notificationId);
    } catch {}
  };

  return (
    <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto p-4">
      <div className="flex items-center justify-between mb-6">
        <h1 className="font-display text-2xl font-extrabold">Notifications</h1>
        {unreadCount > 0 && (
          <Button variant="ghost" size="sm" onClick={handleMarkAllRead}>Mark all read</Button>
        )}
      </div>

      {isLoading ? (
        <div className="space-y-3">
          {Array.from({ length: 5 }).map((_, i) => (
            <Card key={i} className="p-4 animate-pulse"><div className="h-4 bg-buddy-surface-raised rounded w-3/4" /></Card>
          ))}
        </div>
      ) : notifications.length === 0 ? (
        <div className="text-center py-20">
          <Bell size={48} className="mx-auto text-buddy-text-secondary/30 mb-4" />
          <p className="text-buddy-text-secondary text-lg">No notifications yet</p>
          <p className="text-buddy-text-secondary/50 text-sm mt-1">When something happens, you'll see it here.</p>
        </div>
      ) : (
        <div className="space-y-2">
          {notifications.map((n) => {
            const Icon = iconMap[n.notification_type] || iconMap.default;
            const isBuddyRequest = n.notification_type === 'buddy_request';
            const isLive = n.notification_type === 'live_starting' || n.notification_type === 'live_reminder';
            const username = (n.metadata as { from_username?: string })?.from_username;
            const liveId = (n.metadata as { live_id?: string })?.live_id;
            const scheduledFor = (n.metadata as { scheduled_for?: string | null })?.scheduled_for;

            return (
              <Card
                key={n.id}
                className={`p-4 flex items-start gap-3 transition-colors ${n.is_read ? 'opacity-60' : 'bg-buddy-surface-raised'}`}
                onClick={() => handleMarkRead(n.id)}
              >
                <div className={`w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0 ${n.is_read ? 'bg-buddy-surface' : 'bg-buddy-green/10'}`}>
                  <Icon size={18} className={n.is_read ? 'text-buddy-text-secondary' : 'text-buddy-green'} />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium">{n.title}</p>
                  {n.body && <p className="text-xs text-buddy-text-secondary mt-0.5">{n.body}</p>}
                  <p className="text-xs text-buddy-text-secondary/50 mt-1">
                    {new Date(n.created_at).toLocaleDateString()}
                  </p>
                  {isBuddyRequest && !n.is_read && username && (
                    <div className="flex gap-2 mt-2">
                      <Button size="sm" onClick={(e) => { e.stopPropagation(); handleAcceptBuddy(username, n.id); }}>
                        Accept
                      </Button>
                      <Button size="sm" variant="ghost" onClick={(e) => { e.stopPropagation(); handleMarkRead(n.id); }}>
                        Ignore
                      </Button>
                    </div>
                  )}
                  {isLive && liveId && (
                    <div className="flex items-center gap-3 mt-2">
                      <LiveCountdown scheduledFor={scheduledFor} />
                      <Button size="sm" onClick={(e) => { e.stopPropagation(); handleMarkRead(n.id); navigate(`/live/${liveId}`); }}>
                        <Radio size={12} className="mr-1" /> Open Live
                      </Button>
                    </div>
                  )}
                </div>
                {!n.is_read && (
                  <div className="w-2 h-2 rounded-full bg-buddy-green flex-shrink-0 mt-2" />
                )}
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );
}
