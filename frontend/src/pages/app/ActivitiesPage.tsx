import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  MapPin, Timer, Share2, X, Smartphone, Image,
  Activity,
} from 'lucide-react';
import { analyticsApi } from '@/api/analytics';
import { RouteMap } from '@/components/analytics/RouteMap';
import { activityMetrics } from '@/lib/activityMetrics';
import type { ActivityRecent } from '@/types/analytics';

const ACTIVITY_ICONS: Record<string, React.ComponentType<any>> = {
  walk: MapPin,
  run: Timer,
  hike: MapPin,
  cycle: MapPin,
  workout: Activity,
};

const ACTIVITY_LABELS: Record<string, string> = {
  walk: 'Walking',
  run: 'Running',
  hike: 'Hiking',
  cycle: 'Cycling',
  workout: 'Workout',
};

const ACTIVITY_TARGETS: Record<string, { value: number; unit: string; label: string }> = {
  walk: { value: 5000, unit: 'steps', label: 'Steps' },
  run: { value: 2, unit: 'km', label: 'Distance' },
  hike: { value: 5, unit: 'km', label: 'Distance' },
  cycle: { value: 10, unit: 'km', label: 'Distance' },
  workout: { value: 30, unit: 'min', label: 'Duration' },
};

const ACTIVITY_COLORS: Record<string, { bg: string; text: string; border: string; glow: string }> = {
  walk: { bg: 'bg-buddy-green/10', text: 'text-buddy-green', border: 'border-buddy-green/30', glow: 'shadow-[0_0_20px_rgba(0,200,150,0.3)]' },
  run: { bg: 'bg-buddy-red/10', text: 'text-buddy-red', border: 'border-buddy-red/30', glow: 'shadow-[0_0_20px_rgba(255,71,87,0.3)]' },
  cycle: { bg: 'bg-buddy-electric/10', text: 'text-buddy-electric', border: 'border-buddy-electric/30', glow: 'shadow-[0_0_20px_rgba(123,97,255,0.3)]' },
  hike: { bg: 'bg-buddy-orange/10', text: 'text-buddy-orange', border: 'border-buddy-orange/30', glow: 'shadow-[0_0_20px_rgba(255,107,53,0.3)]' },
  workout: { bg: 'bg-buddy-gold/10', text: 'text-buddy-gold', border: 'border-buddy-gold/30', glow: 'shadow-[0_0_20px_rgba(255,215,0,0.3)]' },
};

const ACTIVITY_CATEGORIES: { key: string; label: string; description: string; icon: React.ComponentType<any>; targetUnit: string }[] = [
  { key: 'walk', label: 'Walking', description: '5,000 steps daily goal', icon: MapPin, targetUnit: 'steps' },
  { key: 'run', label: 'Running', description: '2 km daily goal', icon: Timer, targetUnit: 'km' },
  { key: 'cycle', label: 'Cycling', description: '10 km daily goal', icon: MapPin, targetUnit: 'km' },
  { key: 'hike', label: 'Hiking', description: '5 km trail goal', icon: MapPin, targetUnit: 'km' },
  { key: 'workout', label: 'Workout', description: '30 min gym session', icon: Activity, targetUnit: 'min' },
];

const VISIBILITY_OPTIONS: { value: 'public' | 'buddies' | 'gym_members' | 'private'; label: string }[] = [
  { value: 'public', label: 'Public' },
  { value: 'buddies', label: 'Buddies' },
  { value: 'gym_members', label: 'Gym Members' },
  { value: 'private', label: 'Private' },
];

export default function ActivitiesPage() {
  const navigate = useNavigate();
  const [activities, setActivities] = useState<ActivityRecent[]>([]);
  const [loading, setLoading] = useState(true);
  const [selected, setSelected] = useState<ActivityRecent | null>(null);
  const [error, setError] = useState<string | null>(null);

  // Share composer state
  const [shareOpen, setShareOpen] = useState(false);
  const [shareActivity, setShareActivity] = useState<ActivityRecent | null>(null);
  const [shareCaption, setShareCaption] = useState('');
  const [shareVisibility, setShareVisibility] = useState<'public' | 'buddies' | 'gym_members' | 'private'>('public');
  const [shareMedia, setShareMedia] = useState<File[]>([]);
  const [shareDraftId, setShareDraftId] = useState<string | null>(null);
  const [shareLoading, setShareLoading] = useState(false);
  const [captionCorrected, setCaptionCorrected] = useState<string>('');

  // Video download / watermark state
  const [videoDownloadState, setVideoDownloadState] = useState<{
    postId: string | null;
    status: 'idle' | 'processing' | 'ready' | 'failed';
    videoUrl: string | null;
    error: string | null;
  }>({ postId: null, status: 'idle', videoUrl: null, error: null });

  // Tracking lives on its own page (/activities/new) — see NewActivity.tsx.
  // The target is still chosen here, and carries over to that page.
  const [categoryPopOpen, setCategoryPopOpen] = useState(false);
  const [categoryPopType, setCategoryPopType] = useState<string | null>(null);
  const [trackingTarget, setTrackingTarget] = useState<number | null>(null);

  const closeCategoryPop = () => {
    setCategoryPopOpen(false);
    setCategoryPopType(null);
  };

  useEffect(() => {
    analyticsApi.getActivities().then((res) => {
      // The client hands back the response envelope, so the list is the
      // `data` on it — unwrapping it a second time left the page empty.
      const data = (res.data as ActivityRecent[] | undefined) ?? [];
      setActivities(Array.isArray(data) ? data : []);
      setLoading(false);
    }).catch((err) => {
      setError(err?.response?.data?.message || 'Failed to load activities');
      setLoading(false);
    });
  }, []);

  // Activity filter state (must be before any early returns per React hooks rules)
  const [activityFilter, setActivityFilter] = useState<'all' | 'walk' | 'run' | 'hike' | 'cycle' | 'workout'>('all');

  const ACTIVITY_FILTERS: { key: 'all' | 'walk' | 'run' | 'hike' | 'cycle' | 'workout'; label: string }[] = [
    { key: 'all', label: 'All' },
    { key: 'walk', label: 'Walking' },
    { key: 'run', label: 'Running' },
    { key: 'hike', label: 'Hiking' },
    { key: 'cycle', label: 'Cycling' },
    { key: 'workout', label: 'Workout' },
  ];

  const formatDuration = (seconds: number) => {
    const h = Math.floor(seconds / 3600);
    const m = Math.floor((seconds % 3600) / 60);
    const s = seconds % 60;
    return h ? `${h}h ${m}m ${s}s` : `${m}m ${s}s`;
  };

  const handleShare = (activity: ActivityRecent) => {
    setShareActivity(activity);
    const target = ACTIVITY_TARGETS[activity.activity_type];
    const progress = activity.distance_km && target
      ? Math.min(100, (activity.distance_km / target.value) * 100)
      : activity.duration_seconds && target
        ? Math.min(100, (activity.duration_seconds / (target.value * 60)) * 100)
        : 0;
    setShareCaption(`🏃 ${ACTIVITY_LABELS[activity.activity_type] ?? activity.activity_type}\n${activity.distance_km?.toFixed(1) ?? 0} ${target?.unit || 'km'} in ${formatDuration(activity.duration_seconds)}\nProgress: ${Math.round(progress)}%\n\n#BuddyUp #Activity #${ACTIVITY_LABELS[activity.activity_type] ?? 'Fitness'}`);
    setShareVisibility('public');
    setShareDraftId(null);
    setCaptionCorrected('');
    setShareOpen(true);
  };

  const handleCorrectCaption = async () => {
    if (!shareCaption.trim()) return;
    setShareLoading(true);
    try {
      const result = await analyticsApi.captionCorrect({ caption: shareCaption, context: 'activity_share' });
      setCaptionCorrected(result.corrected);
      setShareCaption(result.corrected);
    } catch (err: any) {
      setCaptionCorrected(shareCaption);
    } finally {
      setShareLoading(false);
    }
  };

  const handlePrepareShare = async () => {
    if (!shareActivity) return;
    setShareLoading(true);
    try {
      const draft = await analyticsApi.sharePrepare({
        kind: 'activity',
        obj_id: shareActivity.id,
        visibility: shareVisibility,
        body: shareCaption,
      });
      setShareDraftId(draft.draft_id);
    } catch (err: any) {
      alert(err?.response?.data?.message || 'Failed to prepare share');
    } finally {
      setShareLoading(false);
    }
  };

  const handlePublishShare = async () => {
    if (!shareDraftId) return;
    setShareLoading(true);
    try {
      await analyticsApi.sharePublish(shareDraftId, {
        body: shareCaption,
        visibility: shareVisibility,
        media_urls: shareMedia.map((f) => URL.createObjectURL(f)),
        tags: ['activity', shareActivity?.activity_type ?? ''],
      });
      setShareOpen(false);
      setShareDraftId(null);
    } catch (err: any) {
      alert(err?.response?.data?.message || 'Failed to publish share');
    } finally {
      setShareLoading(false);
    }
  };

  const handleDownloadVideo = async (postId: string) => {
    setVideoDownloadState({ postId, status: 'processing', videoUrl: null, error: null });
    try {
      const result = await analyticsApi.videoDownload(postId);
      if (result.status === 'ready') {
        setVideoDownloadState({ postId, status: 'ready', videoUrl: result.video_url, error: null });
      } else {
        const poll = async () => {
          for (let i = 0; i < 10; i++) {
            await new Promise((r) => setTimeout(r, 2000));
            const updated = await analyticsApi.pollWatermark(postId);
            if (updated.status === 'ready') {
              setVideoDownloadState({ postId, status: 'ready', videoUrl: updated.video_url, error: null });
              return;
            }
            if (updated.status === 'failed') {
              setVideoDownloadState({ postId, status: 'failed', videoUrl: null, error: 'Watermarking failed' });
              return;
            }
          }
          setVideoDownloadState({ postId, status: 'failed', videoUrl: null, error: 'Watermarking timed out' });
        };
        void poll();
      }
    } catch (err: any) {
      setVideoDownloadState({ postId, status: 'failed', videoUrl: null, error: err?.response?.data?.message || 'Download failed' });
    }
  };

  const openCategoryPop = (type: string) => {
    setCategoryPopType(type);
    setTrackingTarget(ACTIVITY_TARGETS[type as keyof typeof ACTIVITY_TARGETS]?.value ?? null);
    setCategoryPopOpen(true);
  };

  const handleMediaChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files || []);
    setShareMedia(files);
  };

  if (loading) {
    return (
      <div className="p-4 max-w-5xl mx-auto">
        <div className="flex items-center gap-2 text-buddy-text-secondary">Loading activities…</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="p-4 max-w-5xl mx-auto rounded-lg bg-buddy-error/10 p-4 border border-buddy-error/20 text-buddy-error">
        {error}
      </div>
    );
  }

  const totalDistance = activities.reduce((sum, a) => sum + (a.distance_km || 0), 0);
  const totalDuration = activities.reduce((sum, a) => sum + (a.duration_seconds || 0), 0);
  const totalCalories = activities.reduce((sum, a) => sum + (a.calories_burned || 0), 0);

  const filteredActivities = activityFilter === 'all'
    ? activities
    : activities.filter(a => a.activity_type === activityFilter);

  return (
    <div className="p-4 max-w-5xl mx-auto space-y-6">
      {/* Header + summary stats */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h1 className="font-display text-2xl font-bold">Activities</h1>
          <p className="text-sm text-buddy-text-secondary mt-0.5">
            Track walk, run, cycle, hike and workouts — with GPS route, targets and sharing.
          </p>
        </div>
        <div className="flex gap-2 bg-buddy-surface rounded-xl p-1">
          {[
            { label: 'Total', value: `${activities.length}` },
            { label: 'Distance', value: `${totalDistance.toFixed(1)} km` },
            { label: 'Time', value: formatDuration(totalDuration) },
            { label: 'Calories', value: `${Math.round(totalCalories)}` },
          ].map((s) => (
            <div key={s.label} className="px-3 py-2 text-center">
              <div className="text-sm font-bold text-buddy-text-primary">{s.value}</div>
              <div className="text-xs text-buddy-text-secondary">{s.label}</div>
            </div>
          ))}
        </div>
      </div>

      {/* Countdowns live next door — the mobile nav points here now. */}
      <button
        onClick={() => navigate('/countdowns')}
        className="flex items-center justify-between w-full rounded-xl border border-buddy-border bg-buddy-surface px-4 py-3 text-left hover:border-buddy-green/40 transition-colors"
      >
        <span className="flex items-center gap-2.5">
          <span className="w-9 h-9 rounded-xl bg-buddy-green/15 text-buddy-green flex items-center justify-center">
            <Timer size={18} />
          </span>
          <span>
            <span className="block text-sm font-semibold text-buddy-text-primary">Countdowns</span>
            <span className="block text-xs text-buddy-text-secondary">
              Streaks, sobriety, gym attendance and more
            </span>
          </span>
        </span>
        <span className="text-buddy-text-secondary text-sm">→</span>
      </button>

      {/* Activity type tabs */}
      <div className="bg-buddy-surface rounded-xl border border-buddy-border p-1">
        <div className="flex gap-1 px-1 py-1">
          {ACTIVITY_FILTERS.map((f) => (
            <button
              key={f.key}
              onClick={() => setActivityFilter(f.key)}
              className={`flex-1 py-2 text-xs font-medium transition-colors rounded-md ${
                activityFilter === f.key
                  ? 'bg-buddy-green text-white'
                  : 'bg-buddy-surface text-buddy-text-secondary hover:bg-buddy-surface/50'
              }`}
            >
              {f.label}
            </button>
          ))}
        </div>
      </div>

      {/* Activity category cards */}
      <div className="bg-buddy-surface rounded-xl border border-buddy-border p-5">
        <div className="flex items-center justify-between mb-4">
          <h3 className="font-semibold text-buddy-text-primary">Start New Activity</h3>
          <span className="text-xs text-buddy-text-secondary">Tap a category to begin tracking</span>
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-3 lg:grid-cols-5 gap-3">
          {ACTIVITY_CATEGORIES.map((cat) => {
            const color = ACTIVITY_COLORS[cat.key];
            const target = ACTIVITY_TARGETS[cat.key];
            return (
              <button
                key={cat.key}
                onClick={() => {
                  // A workout is not a tracked activity — it has its own form.
                  if (cat.key === 'workout') {
                    navigate('/workout-form');
                    return;
                  }
                  openCategoryPop(cat.key);
                }}
                className={`flex flex-col items-center gap-3 p-5 rounded-2xl border border-buddy-border transition-all duration-200 hover:border-buddy-green hover:shadow-lg ${color.bg} ${color.text} ${color.glow}`}
              >
                <div className={`w-12 h-12 rounded-2xl flex items-center justify-center ${color.bg.replace('/10', '/20')} ${color.text}`}>
                  <cat.icon size={24} />
                </div>
                <div className="font-medium text-sm text-buddy-text-primary">{cat.label}</div>
                <div className="text-xs text-buddy-text-secondary text-center">{cat.description}</div>
                <div className="w-8 h-8 rounded-full flex items-center justify-center bg-buddy-surface/50 text-buddy-text-secondary text-[10px]">
                  {target?.value}
                </div>
              </button>
            );
          })}
        </div>
      </div>

      {error && (
        <div className="rounded-lg bg-buddy-error/10 p-3 border border-buddy-error/20 text-buddy-error text-sm">{error}</div>
      )}

      {/* Activities list */}
      <div className="bg-buddy-surface rounded-xl border border-buddy-border">
        <div className="p-4 border-b border-buddy-border flex items-center justify-between">
          <h3 className="font-semibold text-buddy-text-primary">Recent Activities</h3>
          <span className="text-xs text-buddy-text-secondary">{activities.length} session{activities.length !== 1 ? 's' : ''}</span>
        </div>

        <div className="divide-y divide-buddy-border">
          {filteredActivities.map((activity) => {
            const color = ACTIVITY_COLORS[activity.activity_type];
            const target = ACTIVITY_TARGETS[activity.activity_type];
            const progress = activity.distance_km && target
              ? Math.min(100, (activity.distance_km / target.value) * 100)
              : activity.duration_seconds && target
                ? Math.min(100, (activity.duration_seconds / (target.value * 60)) * 100)
                : 0;
            const isTargetActivity = !!target;
            const achieved = progress >= 100;

            return (
              <div
                key={activity.id}
                onClick={() => setSelected(selected?.id === activity.id ? null : activity)}
                className={`cursor-pointer p-4 transition-colors hover:bg-buddy-surface/50 ${selected?.id === activity.id ? 'bg-buddy-green/5 border-buddy-green/30' : ''} border-buddy-border rounded-xl`}
              >
                <div className="flex items-start justify-between gap-4">
                  <div className="flex items-center gap-3 shrink-0">
                    <div className={`p-3 rounded-xl ${color.bg} ${color.text}`}>
                      {(() => {
                        const Icon = ACTIVITY_ICONS[activity.activity_type] ?? MapPin;
                        return <Icon size={24} />;
                      })()}
                    </div>
                    <div>
                      <div className="flex items-baseline gap-1">
                        <span className={`text-2xl font-display font-bold ${color.text}`}>
                          {isTargetActivity && activity.distance_km
                            ? activity.distance_km.toFixed(1)
                            : activity.duration_seconds
                              ? Math.floor(activity.duration_seconds / 60)
                              : 0}
                        </span>
                        <span className="text-xs text-buddy-text-secondary font-medium">
                          {isTargetActivity && activity.distance_km
                            ? target.unit
                            : 'min'}
                        </span>
                      </div>
                      <div className="text-xs text-buddy-text-secondary">
                        {ACTIVITY_LABELS[activity.activity_type] ?? activity.activity_type}
                      </div>
                    </div>
                  </div>
                  <div className="text-right">
                    <div className={`font-semibold ${achieved ? 'text-buddy-gold' : 'text-buddy-text-primary'}`}>
                      {progress > 0 ? `${Math.round(progress)}%` : '—'}
                    </div>
                    <div className="text-xs text-buddy-text-secondary">
                      {new Date(activity.started_at || '').toLocaleDateString()} • {formatDuration(activity.duration_seconds)}
                    </div>
                  </div>
                </div>

                {isTargetActivity && (
                  <div className="mt-3 pt-3 border-t border-buddy-border/50">
                    <div className="flex items-center justify-between mb-1 text-xs">
                      <span className="text-buddy-text-secondary">Target</span>
                      <span className={achieved ? 'text-buddy-gold font-medium' : 'text-buddy-text-secondary'}>
                        {target.label}: {target.value} {target.unit}
                      </span>
                    </div>
                    <div className="w-full bg-buddy-surface/50 rounded-full h-2 overflow-hidden">
                      <div
                        className={`h-full transition-all duration-500 ${achieved ? 'bg-buddy-gold' : color.bg.replace('/10', '')}`}
                        style={{ width: `${progress}%` }}
                      />
                    </div>
                  </div>
                )}

                {/* The numbers that matter for this kind of activity. */}
                {activityMetrics(activity).length > 0 && (
                  <div className="mt-3 pt-3 border-t border-buddy-border/50 grid grid-cols-2 sm:grid-cols-4 gap-2">
                    {activityMetrics(activity).map((m) => (
                      <div key={m.label} className="bg-buddy-surface/50 rounded-lg px-2.5 py-2">
                        <p className="text-[10px] uppercase tracking-wider text-buddy-text-secondary">{m.label}</p>
                        <p className={`text-sm font-bold font-mono ${m.tone === 'orange' ? 'text-buddy-gold' : 'text-buddy-text-primary'}`}>
                          {m.value}
                        </p>
                      </div>
                    ))}
                  </div>
                )}

                {activity.route && activity.route.length > 0 && (
                  <div className="mt-3 pt-3 border-t border-buddy-border/50">
                    <div className="flex items-center gap-2 mb-2 text-xs font-medium text-buddy-text-secondary">
                      <MapPin size={12} /> Route map ({activity.route.length} trackpoints)
                    </div>
                    <RouteMap route={activity.route} height={200} />
                  </div>
                )}
                <div className="mt-3 flex items-center gap-2 text-xs text-buddy-text-secondary">
                  <button
                    onClick={(e) => { e.stopPropagation(); handleShare(activity); }}
                    className="flex items-center gap-1 px-2 py-1 bg-buddy-surface hover:bg-buddy-surface/80 rounded text-buddy-text-primary text-xs font-medium transition-colors"
                  >
                    <Share2 size={14} /> Share
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Selected activity detail (inline expansion) */}
      {selected && (
        <div className="bg-buddy-surface rounded-xl border border-buddy-border p-5">
          <div className="flex items-start justify-between mb-4">
            <div>
              <h3 className="font-semibold text-buddy-text-primary">{ACTIVITY_LABELS[selected.activity_type] ?? selected.activity_type} Detail</h3>
              <p className="text-sm text-buddy-text-secondary">
                {new Date(selected.started_at || '').toLocaleString()}
              </p>
            </div>
            <button
              onClick={() => setSelected(null)}
              className="text-buddy-text-secondary hover:text-buddy-text-primary"
            >
              ✕
            </button>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-4">
            <div className="bg-buddy-surface/50 rounded-lg p-3">
              <div className="text-xs text-buddy-text-secondary">Distance</div>
              <div className="text-lg font-bold">{selected.distance_km?.toFixed(2) ?? 0} km</div>
            </div>
            <div className="bg-buddy-surface/50 rounded-lg p-3">
              <div className="text-xs text-buddy-text-secondary">Duration</div>
              <div className="text-lg font-bold">{formatDuration(selected.duration_seconds)}</div>
            </div>
            <div className="bg-buddy-surface/50 rounded-lg p-3">
              <div className="text-xs text-buddy-text-secondary">Calories</div>
              <div className="text-lg font-bold">{Math.round(selected.calories_burned || 0)} kcal</div>
            </div>
          </div>
          {selected.route && selected.route.length > 0 && (
            <div className="bg-buddy-surface/50 rounded-lg p-4">
              <div className="text-xs font-medium text-buddy-text-secondary mb-3">Route Replay Map</div>
              <div className="aspect-[4/3] bg-buddy-bg rounded border border-buddy-border flex items-center justify-center min-h-[300px]">
                <div className="text-center text-buddy-text-secondary">
                  <MapPin size={32} className="mx-auto mb-2 opacity-50" />
                  <p>Route replay with street / satellite / terrain layers</p>
                  <button
                    onClick={(e) => { e.stopPropagation(); handleShare(selected); }}
                    className="mt-3 px-3 py-1.5 bg-buddy-green hover:bg-buddy-green/90 text-white rounded text-sm font-medium transition-colors"
                  >
                    <Share2 size={14} className="mr-2" /> Share this activity
                  </button>
                  {selected.id && (
                    <button
                      onClick={(e) => { e.stopPropagation(); handleDownloadVideo(selected.id); }}
                      disabled={videoDownloadState.postId === selected.id && videoDownloadState.status === 'processing'}
                      className={`mt-3 px-3 py-1.5 rounded text-sm font-medium transition-colors ${
                        videoDownloadState.status === 'processing'
                          ? 'bg-buddy-surface text-buddy-text-secondary'
                          : 'bg-buddy-green hover:bg-buddy-green/90 text-white'
                      }`}
                    >
                      {videoDownloadState.status === 'processing' ? 'Watermarking…' : '⬇ Download Video'}
                    </button>
                  )}
                  {videoDownloadState.postId === selected.id && videoDownloadState.status === 'ready' && videoDownloadState.videoUrl && (
                    <a
                      href={videoDownloadState.videoUrl}
                      download={`buddyup-video-${selected.id}.mp4`}
                      className="mt-2 px-3 py-1.5 bg-buddy-green hover:bg-buddy-green/90 text-white rounded text-sm font-medium transition-colors"
                    >
                      📥 Save Watermarked Video
                    </a>
                  )}
                  {videoDownloadState.postId === selected.id && videoDownloadState.status === 'failed' && videoDownloadState.error && (
                    <p className="mt-1 text-xs text-buddy-error">{videoDownloadState.error}</p>
                  )}
                </div>
              </div>
            </div>
          )}
        </div>
      )}

      {/* Target picker — the target carries over to the tracking page. */}
      {categoryPopOpen && categoryPopType && (
        <div className="fixed inset-0 z-[60] flex items-center justify-center">
          <div className="fixed inset-0 bg-black/80 backdrop-blur-md" onClick={closeCategoryPop} />
          <div className="relative bg-buddy-surface rounded-2xl border border-buddy-border p-8 w-full max-w-md z-[61] shadow-2xl">
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center gap-3">
                {(() => {
                  const Icon = ACTIVITY_ICONS[categoryPopType] ?? MapPin;
                  const color = ACTIVITY_COLORS[categoryPopType];
                  return (
                    <div className={`p-3 rounded-xl ${color.bg} ${color.text}`}>
                      <Icon size={24} />
                    </div>
                  );
                })()}
                <div>
                  <h3 className="font-display text-xl font-bold text-buddy-text-primary">
                    {ACTIVITY_LABELS[categoryPopType] ?? categoryPopType} Target
                  </h3>
                  <p className="text-xs text-buddy-text-secondary">
                    Set your target for this session
                  </p>
                </div>
              </div>
              <button onClick={closeCategoryPop} className="text-buddy-text-secondary hover:text-buddy-text-primary">
                <X size={20} />
              </button>
            </div>

            <div className="space-y-4">
              <div className="space-y-2">
                <label className="text-sm font-medium text-buddy-text-secondary">Target value</label>
                <div className="flex items-center gap-2">
                  <input
                    type="number"
                    min="0"
                    step={categoryPopType === 'walk' ? 100 : 1}
                    defaultValue={ACTIVITY_TARGETS[categoryPopType as keyof typeof ACTIVITY_TARGETS]?.value}
                    onChange={(e) => setTrackingTarget(parseInt(e.target.value) || 0)}
                    className="flex-1 px-3 py-2 bg-buddy-bg border border-buddy-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green"
                  />
                  <span className="text-xs text-buddy-text-secondary font-medium">
                    {ACTIVITY_TARGETS[categoryPopType as keyof typeof ACTIVITY_TARGETS]?.unit}
                  </span>
                </div>
              </div>

              <div className="bg-buddy-surface/50 rounded-xl p-4 border border-buddy-border">
                <div className="text-xs text-buddy-text-secondary mb-2">Suggested targets</div>
                <div className="grid grid-cols-2 gap-2">
                  {(() => {
                    const t = ACTIVITY_TARGETS[categoryPopType as keyof typeof ACTIVITY_TARGETS];
                    if (!t) return null;
                    const multipliers = [0.5, 1, 1.5, 2];
                    return multipliers.map((m) => (
                      <button
                        key={m}
                        onClick={() => setTrackingTarget(Math.round(t.value * m))}
                        className={`px-3 py-2 rounded-lg text-xs font-medium border transition-colors ${
                          trackingTarget === Math.round(t.value * m)
                            ? 'bg-buddy-green text-white border-buddy-green'
                            : 'bg-buddy-surface text-buddy-text-secondary border-buddy-border hover:bg-buddy-surface/50'
                        }`}
                      >
                        {Math.round(t.value * m)} {t.unit}
                      </button>
                    ));
                  })()}
                </div>
              </div>

              <div className="pt-4 flex gap-3">
                <button
                  onClick={closeCategoryPop}
                  className="flex-1 py-3 rounded-xl border border-buddy-border text-buddy-text-secondary hover:bg-buddy-surface/50 transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={() => {
                    closeCategoryPop();
                    navigate(
                      `/activities/new?type=${categoryPopType}`
                      + (trackingTarget ? `&target=${trackingTarget}` : ''),
                    );
                  }}
                  disabled={!trackingTarget}
                  className={`flex-1 py-3 rounded-xl text-sm font-medium transition-colors disabled:opacity-50 ${
                    !trackingTarget
                      ? 'bg-buddy-surface text-buddy-text-secondary border-buddy-border cursor-not-allowed'
                      : 'bg-buddy-green text-buddy-black border-buddy-green hover:bg-buddy-green/90'
                  }`}
                >
                  Start Tracking
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Activity Tracking Modal — replaced by the dedicated tracking page. */}

      {/* Share Composer Modal */}
      {shareOpen && shareActivity && (
        <div className="fixed inset-0 z-50 flex items-center justify-center">
          <div className="fixed inset-0 bg-black/60 backdrop-blur-sm" onClick={() => setShareOpen(false)} />
          <div className="relative bg-buddy-surface rounded-2xl border border-buddy-border p-6 w-full max-w-lg max-h-[90vh] overflow-y-auto z-10">
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-semibold text-buddy-text-primary">Share Activity</h3>
              <button onClick={() => setShareOpen(false)} className="text-buddy-text-secondary hover:text-buddy-text-primary">
                <X size={20} />
              </button>
            </div>

            <div className="space-y-4">
              {/* Activity card preview */}
              {shareActivity && (
                <div className="bg-buddy-surface/50 rounded-xl p-4 border border-buddy-border/50 flex items-start gap-4">
                  <div className="shrink-0">
                    <div className={`w-16 h-16 rounded-2xl ${ACTIVITY_COLORS[shareActivity.activity_type]?.bg} ${ACTIVITY_COLORS[shareActivity.activity_type]?.text} flex items-center justify-center`}>
                      <Timer size={24} />
                    </div>
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between gap-2">
                      <h4 className="font-medium text-buddy-text-primary">{ACTIVITY_LABELS[shareActivity.activity_type] ?? shareActivity.activity_type}</h4>
                      <span className="text-xs px-2 py-0.5 rounded-full bg-buddy-surface text-buddy-text-secondary border border-buddy-border">
                        {shareActivity.distance_km?.toFixed(1) ?? 0} km
                      </span>
                    </div>
                    <p className="text-xs text-buddy-text-secondary mt-1">
                      {formatDuration(shareActivity.duration_seconds)} • {new Date(shareActivity.started_at || '').toLocaleDateString()}
                    </p>
                  </div>
                </div>
              )}

              {/* Caption editor */}
              <div className="space-y-2">
                <label className="text-sm font-medium text-buddy-text-secondary">Caption</label>
                <div className="relative">
                  <textarea
                    value={shareCaption}
                    onChange={(e) => setShareCaption(e.target.value)}
                    rows={4}
                    className="w-full px-3 py-2 bg-buddy-bg border border-buddy-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green"
                    placeholder="Write your caption…"
                  />
                  {captionCorrected && captionCorrected !== shareCaption && (
                    <button
                      onClick={handleCorrectCaption}
                      className="absolute right-2 top-2 px-2 py-1 text-xs bg-buddy-green text-white rounded hover:bg-buddy-green/90 transition-colors"
                      disabled={shareLoading}
                    >
                      {shareLoading ? '…' : '✨ Correct grammar'}
                    </button>
                  )}
                </div>
                {captionCorrected && captionCorrected !== shareCaption && (
                  <div className="text-xs text-buddy-text-secondary">
                    Grammar suggestion available — click "Correct grammar" to apply.
                  </div>
                )}
              </div>

              {/* Visibility */}
              <div className="space-y-2">
                <label className="text-sm font-medium text-buddy-text-secondary">Who can see this</label>
                <div className="grid grid-cols-2 gap-2">
                  {VISIBILITY_OPTIONS.map((v) => (
                    <button
                      key={v.value}
                      onClick={() => setShareVisibility(v.value)}
                      className={`px-3 py-2 rounded-lg text-sm font-medium border transition-colors ${
                        shareVisibility === v.value
                          ? 'bg-buddy-green text-white border-buddy-green'
                          : 'bg-buddy-surface text-buddy-text-secondary border-buddy-border hover:bg-buddy-surface/80'
                      }`}
                    >
                      {v.label}
                    </button>
                  ))}
                </div>
              </div>

              {/* Media attachment */}
              <div className="space-y-2">
                <label className="text-sm font-medium text-buddy-text-secondary">Attach media (optional)</label>
                <div className="flex items-center gap-3">
                  <input
                    type="file"
                    accept="image/*,video/*"
                    multiple
                    onChange={handleMediaChange}
                    className="sr-only"
                  />
                  <button
                    onClick={() => {
                      const input = document.querySelector('input[type=file]') as HTMLInputElement | null;
                      input?.click();
                    }}
                    className="flex items-center gap-2 px-3 py-2 border border-buddy-border rounded-lg text-sm text-buddy-text-secondary hover:bg-buddy-surface/50"
                  >
                    <Image size={16} /> {shareMedia.length > 0 ? `${shareMedia.length} file(s)` : 'Add photo/video'}
                  </button>
                  {shareMedia.length > 0 && (
                    <span className="text-xs text-buddy-text-secondary bg-buddy-surface/50 px-2 py-1 rounded">
                      {shareMedia.length} attached
                    </span>
                  )}
                </div>
              </div>

              {/* Draft vs Publish */}
              {shareDraftId ? (
                <div className="bg-buddy-green/10 border border-buddy-green/20 rounded-lg p-3">
                  <div className="flex items-center gap-2 text-sm text-buddy-green mb-2">
                    <Smartphone size={14} /> Draft ready — review and publish
                  </div>
                  <button
                    onClick={handlePublishShare}
                    disabled={shareLoading}
                    className="w-full py-3 bg-buddy-green hover:bg-buddy-green/90 text-white rounded-lg font-medium disabled:opacity-50 transition-colors"
                  >
                    {shareLoading ? 'Publishing…' : 'Publish to Feed'}
                  </button>
                </div>
              ) : (
                <button
                  onClick={handlePrepareShare}
                  disabled={shareLoading || !shareCaption.trim()}
                  className="w-full py-3 bg-buddy-green hover:bg-buddy-green/90 text-white rounded-lg font-medium disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                >
                  {shareLoading ? 'Preparing…' : 'Prepare Share (Edit Before Post)'}
                </button>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
