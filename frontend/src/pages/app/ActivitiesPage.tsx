import { useState, useEffect } from 'react';
import {
  MapPin, Timer, Flame, Calculator, Share2, X, Maximize, Smartphone, Image, Video,
} from 'lucide-react';
import { analyticsApi } from '@/api/analytics';
import type { ActivityRecent } from '@/types/analytics';

const ACTIVITY_ICONS: Record<string, React.ComponentType<any>> = {
  walk: MapPin,
  run: Timer,
  hike: MapPin,
  cycle: MapPin,
};

const ACTIVITY_LABELS: Record<string, string> = {
  walk: 'Walking',
  run: 'Running',
  hike: 'Hiking',
  cycle: 'Cycling',
};

const VISIBILITY_OPTIONS: { value: 'public' | 'buddies' | 'gym_members' | 'private'; label: string }[] = [
  { value: 'public', label: 'Public' },
  { value: 'buddies', label: 'Buddies' },
  { value: 'gym_members', label: 'Gym Members' },
  { value: 'private', label: 'Private' },
];

export default function ActivitiesPage() {
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

  useEffect(() => {
    analyticsApi.getActivities().then((res) => {
      const apiResponse = res.data as { data?: ActivityRecent[] } | undefined;
      const data = apiResponse?.data ?? [];
      setActivities(Array.isArray(data) ? data : []);
      setLoading(false);
    }).catch((err) => {
      setError(err?.response?.data?.message || 'Failed to load activities');
      setLoading(false);
    });
  }, []);

  const formatDuration = (seconds: number) => {
    const h = Math.floor(seconds / 3600);
    const m = Math.floor((seconds % 3600) / 60);
    const s = seconds % 60;
    return h ? `${h}h ${m}m ${s}s` : `${m}m ${s}s`;
  };

  const formatPace = (paceSecPerKm: number | null, distanceKm: number) => {
    if (!paceSecPerKm || !distanceKm) return '--';
    const mins = Math.floor(paceSecPerKm);
    const secs = Math.round((paceSecPerKm - mins) * 60);
    return `${mins}:${secs.toString().padStart(2, '0')} /km`;
  };

  const handleShare = (activity: ActivityRecent) => {
    setShareActivity(activity);
    setShareCaption(`🏃 Just finished a ${ACTIVITY_LABELS[activity.activity_type] ?? activity.activity_type} — ${activity.distance_km?.toFixed(1) ?? 0} km in ${formatDuration(activity.duration_seconds)}.`);
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

  const handleMediaChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files || []);
    setShareMedia(files);
  };

  const handleDownloadVideo = async (postId: string) => {
    setVideoDownloadState({ postId, status: 'processing', videoUrl: null, error: null });
    try {
      const result = await analyticsApi.videoDownload(postId);
      if (result.status === 'ready') {
        setVideoDownloadState({ postId, status: 'ready', videoUrl: result.video_url, error: null });
      } else {
        // Poll for watermark readiness
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

  return (
    <div className="p-4 max-w-5xl mx-auto space-y-6">
      {/* Header + summary stats */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h1 className="font-display text-2xl font-bold">Activities</h1>
          <p className="text-sm text-buddy-text-secondary mt-0.5">
            Your walk, run, hike and cycle sessions — with map replay and sharing.
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

      {error && (
        <div className="rounded-lg bg-buddy-error/10 p-3 border border-buddy-error/20 text-buddy-error text-sm">{error}</div>
      )}

      {/* Activities list */}
      <div className="bg-buddy-surface rounded-xl border border-buddy-border">
        <div className="p-4 border-b border-buddy-border flex items-center justify-between">
          <h3 className="font-semibold">Recent Activities</h3>
          <span className="text-xs text-buddy-text-secondary">{activities.length} session{activities.length !== 1 ? 's' : ''}</span>
        </div>

        <div className="divide-y divide-buddy-border">
          {activities.map((activity) => (
            <div
              key={activity.id}
              onClick={() => setSelected(selected?.id === activity.id ? null : activity)}
              className={`cursor-pointer p-4 transition-colors hover:bg-buddy-surface/50 ${selected?.id === activity.id ? 'bg-buddy-green/5' : ''}`}
            >
              <div className="flex items-start justify-between gap-3">
                <div className="flex items-center gap-3 shrink-0">
                  {(() => {
                    const Icon = ACTIVITY_ICONS[activity.activity_type] ?? MapPin;
                    const bgClass = activity.activity_type === 'run' ? 'bg-red-100 text-red-600' :
                      activity.activity_type === 'walk' ? 'bg-green-100 text-green-600' :
                      activity.activity_type === 'hike' ? 'bg-yellow-100 text-yellow-600' :
                      'bg-blue-100 text-blue-600';
                    return (
                      <div className={`p-2 rounded-lg ${bgClass}`}>
                        <Icon size={20} />
                      </div>
                    );
                  })()}
                  <div>
                    <div className="font-medium text-buddy-text-primary">{ACTIVITY_LABELS[activity.activity_type] ?? activity.activity_type}</div>
                    <div className="text-xs text-buddy-text-secondary">
                      {new Date(activity.started_at || '').toLocaleDateString()} • {formatDuration(activity.duration_seconds)}
                    </div>
                  </div>
                </div>
                <div className="text-right">
                  <div className="font-semibold text-buddy-text-primary">{activity.distance_km?.toFixed(1) ?? 0} km</div>
                  <div className="text-xs text-buddy-text-secondary">{formatPace(activity.avg_pace, activity.distance_km)} pace</div>
                </div>
              </div>
              {activity.route && activity.route.length > 0 && (
                <div className="mt-3 pt-3 border-t border-buddy-border/50">
                  <div className="flex items-center gap-2 mb-2 text-xs font-medium text-buddy-text-secondary">
                    <MapPin size={12} /> Route map ({activity.route.length} trackpoints)
                  </div>
                  <div className="aspect-video bg-buddy-surface rounded-lg border border-buddy-border flex items-center justify-center min-h-[200px]">
                    <div className="text-sm text-buddy-text-secondary">
                      Interactive map — tap to view full route replay
                    </div>
                  </div>
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
          ))}
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
              {/* Activity preview */}
              <div className="flex items-center gap-3 p-3 bg-buddy-surface/50 rounded-lg border border-buddy-border/50">
                <div className={`p-2 rounded-lg ${
                  shareActivity.activity_type === 'run' ? 'bg-red-100 text-red-600' :
                  shareActivity.activity_type === 'walk' ? 'bg-green-100 text-green-600' :
                  shareActivity.activity_type === 'hike' ? 'bg-yellow-100 text-yellow-600' :
                  'bg-blue-100 text-blue-600'
                }`}>
                  {(() => {
                    const Icon = ACTIVITY_ICONS[shareActivity.activity_type] ?? MapPin;
                    return <Icon size={20} />;
                  })()}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="font-medium text-buddy-text-primary">{ACTIVITY_LABELS[shareActivity.activity_type] ?? shareActivity.activity_type}</div>
                  <div className="text-xs text-buddy-text-secondary">
                    {shareActivity.distance_km?.toFixed(1)} km • {formatDuration(shareActivity.duration_seconds)}
                  </div>
                </div>
              </div>

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
