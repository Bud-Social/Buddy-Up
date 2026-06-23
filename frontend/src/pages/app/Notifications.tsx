import { useState, useEffect, useCallback } from 'react';
import { Bell, UserPlus, Users, Zap, Heart, MessageCircle, RefreshCcw } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { notificationsApi, profilesApi } from '@/api';
import type { AppNotification } from '@/store/notificationStore';
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
  default: Bell,
};

export default function Notifications() {
  const { notifications, unreadCount, setNotifications, addNotification, markAllRead } = useNotificationStore();
  const [isLoading, setIsLoading] = useState(true);

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
    <div className="max-w-lg mx-auto p-4">
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
            const username = (n.metadata as { from_username?: string })?.from_username;

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
