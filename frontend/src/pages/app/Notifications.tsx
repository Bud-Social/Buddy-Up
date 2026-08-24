import { useState, useEffect, useCallback, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Bell, UserPlus, Users, Zap, Heart, MessageCircle, RefreshCcw, Radio,
  ShoppingBag, CreditCard, Repeat, AtSign, Ticket, Calendar, Dumbbell,
  CheckCircle2, CheckCheck,
} from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { notificationsApi, profilesApi } from '@/api';
import { useNotificationStore } from '@/store/notificationStore';
import type { Notification } from '@/api/notifications';

type FilterTab = 'all' | 'social' | 'live' | 'commerce';

const iconMap: Record<string, typeof Bell> = {
  buddy_request: UserPlus,
  buddy_accepted: Users,
  buddy_declined: Users,
  new_follower: UserPlus,
  accountability_ping: Zap,
  comment: MessageCircle,
  comment_reply: MessageCircle,
  post_reaction: Heart,
  post_repost: Repeat,
  repost: Repeat,
  post_quote: Repeat,
  mention: AtSign,
  streak_milestone: Zap,
  live_starting: Radio,
  live_reminder: Radio,
  community_invite: Users,
  community_member: Users,
  community_join_request: Users,
  community_join_approved: CheckCircle2,
  event_ticket_purchased: Ticket,
  order_status_changed: ShoppingBag,
  new_purchase: ShoppingBag,
  payout_processed: CreditCard,
  withdrawal_processed: CreditCard,
  payment_received: CreditCard,
  session_booked: Calendar,
  session_reminder: Calendar,
  gym_invite: Dumbbell,
  default: Bell,
};

const SOCIAL_TYPES = new Set([
  'like', 'post_reaction', 'comment', 'comment_reply',
  'follow', 'new_follower', 'buddy_request', 'buddy_accepted',
  'mention', 'repost', 'post_repost', 'post_quote', 'community_post',
  'community_comment', 'community_reaction',
]);

const LIVE_TYPES = new Set([
  'live_start', 'live_starting', 'live_reminder',
]);

const COMMERCE_TYPES = new Set([
  'event_ticket_purchased', 'order_status_changed', 'payout_processed',
  'payment_received', 'withdrawal_processed', 'new_purchase',
  'session_booked', 'session_reminder', 'session_cancelled',
]);

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
  const [filter, setFilter] = useState<FilterTab>('all');
  const navigate = useNavigate();

  const fetchNotifications = useCallback(async () => {
    try {
      const res = await notificationsApi.getList();
      setNotifications(res.data);
    } catch {} finally {
      setIsLoading(false);
    }
  }, [setNotifications]);

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

  const handleNotificationClick = (n: Notification) => {
    handleMarkRead(n.id);
    const meta = (n.metadata || {}) as Record<string, any>;
    const type = n.notification_type;

    if (type === 'live_starting' || type === 'live_reminder' || type === 'live_start') {
      const liveId = meta.live_id;
      if (liveId) navigate(`/live/${liveId}`);
      return;
    }

    if (type === 'event_ticket_purchased') {
      const eventId = meta.event_id;
      if (eventId) navigate(`/marketplace/events/${eventId}`);
      return;
    }

    if (type === 'order_status_changed' || type === 'new_purchase') {
      navigate('/creator-studio');
      return;
    }

    if (type === 'payout_processed' || type === 'withdrawal_processed' || type === 'payment_received') {
      navigate('/wallet');
      return;
    }

    if (type === 'community_join_approved' || type === 'community_post') {
      const commId = meta.community_id;
      if (commId) navigate(`/community/${commId}`);
      return;
    }

    if (type === 'repost' || type === 'post_repost' || type === 'mention' || type === 'post_reaction' || type === 'comment') {
      const postId = meta.post_id;
      if (postId) navigate(`/feed?post=${postId}`);
      return;
    }
  };

  const filteredNotifications = useMemo(() => {
    return notifications.filter((n) => {
      if (filter === 'social') return SOCIAL_TYPES.has(n.notification_type);
      if (filter === 'live') return LIVE_TYPES.has(n.notification_type);
      if (filter === 'commerce') return COMMERCE_TYPES.has(n.notification_type);
      return true;
    });
  }, [notifications, filter]);

  const groupedNotifications = useMemo(() => {
    const groups: { label: string; items: Notification[] }[] = [
      { label: 'Today', items: [] },
      { label: 'Yesterday', items: [] },
      { label: 'Earlier', items: [] },
    ];

    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime();
    const yesterday = today - 86400000;

    for (const n of filteredNotifications) {
      const itemTime = new Date(n.created_at).getTime();
      if (itemTime >= today) {
        groups[0].items.push(n);
      } else if (itemTime >= yesterday) {
        groups[1].items.push(n);
      } else {
        groups[2].items.push(n);
      }
    }

    return groups.filter((g) => g.items.length > 0);
  }, [filteredNotifications]);

  const tabs: { key: FilterTab; label: string }[] = [
    { key: 'all', label: 'All' },
    { key: 'social', label: 'Social' },
    { key: 'live', label: 'Live' },
    { key: 'commerce', label: 'Commerce' },
  ];

  return (
    <div className="max-w-lg lg:max-w-2xl xl:max-w-3xl mx-auto p-4 space-y-4">
      {/* Header */}
      <div className="flex items-center justify-between">
        <h1 className="font-display text-2xl font-extrabold">Notifications</h1>
        <Button variant="ghost" size="sm" onClick={handleMarkAllRead} className="text-xs text-buddy-green">
          <CheckCheck size={16} className="mr-1" /> Mark all read
        </Button>
      </div>

      {/* Filter Tabs */}
      <div className="flex gap-1 bg-buddy-surface rounded-xl p-1">
        {tabs.map(({ key, label }) => (
          <button
            key={key}
            onClick={() => setFilter(key)}
            className={`flex-1 py-1.5 text-xs sm:text-sm font-medium rounded-lg transition-colors ${
              filter === key
                ? 'bg-buddy-green text-buddy-black font-semibold'
                : 'text-buddy-text-secondary hover:text-buddy-text-primary'
            }`}
          >
            {label}
          </button>
        ))}
      </div>

      {/* Content */}
      {isLoading ? (
        <div className="space-y-3 pt-2">
          {Array.from({ length: 5 }).map((_, i) => (
            <Card key={i} className="p-4 animate-pulse">
              <div className="h-4 bg-buddy-surface-raised rounded w-3/4" />
            </Card>
          ))}
        </div>
      ) : groupedNotifications.length === 0 ? (
        <div className="text-center py-20">
          <Bell size={48} className="mx-auto text-buddy-text-secondary/30 mb-4" />
          <p className="text-buddy-text-secondary text-lg">No notifications</p>
          <p className="text-buddy-text-secondary/50 text-sm mt-1">When something happens, you'll see it here.</p>
        </div>
      ) : (
        <div className="space-y-6 pt-1">
          {groupedNotifications.map((group) => (
            <div key={group.label} className="space-y-2">
              <h2 className="text-xs font-bold uppercase tracking-wider text-buddy-text-secondary/70 px-1">
                {group.label}
              </h2>
              <div className="space-y-2">
                {group.items.map((n) => {
                  const Icon = iconMap[n.notification_type] || iconMap.default;
                  const isBuddyRequest = n.notification_type === 'buddy_request';
                  const isLive = n.notification_type === 'live_starting' || n.notification_type === 'live_reminder';
                  const username = (n.metadata as { from_username?: string })?.from_username;
                  const liveId = (n.metadata as { live_id?: string })?.live_id;
                  const scheduledFor = (n.metadata as { scheduled_for?: string | null })?.scheduled_for;

                  return (
                    <Card
                      key={n.id}
                      className={`p-4 flex items-start gap-3 transition-colors cursor-pointer hover:border-buddy-green/30 ${
                        n.is_read ? 'opacity-65' : 'bg-buddy-surface-raised border-buddy-green/20'
                      }`}
                      onClick={() => handleNotificationClick(n)}
                    >
                      <div className={`w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0 ${
                        n.is_read ? 'bg-buddy-surface' : 'bg-buddy-green/10'
                      }`}>
                        <Icon size={18} className={n.is_read ? 'text-buddy-text-secondary' : 'text-buddy-green'} />
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className={`text-sm ${n.is_read ? 'font-normal' : 'font-semibold text-buddy-text-primary'}`}>
                          {n.title}
                        </p>
                        {n.body && <p className="text-xs text-buddy-text-secondary mt-0.5">{n.body}</p>}
                        <p className="text-[11px] text-buddy-text-secondary/50 mt-1">
                          {new Date(n.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
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
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
