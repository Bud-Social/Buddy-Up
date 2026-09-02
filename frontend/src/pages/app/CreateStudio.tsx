/**
 * CreateStudio — TikTok/IG-style full-screen creation wizard for Bud Press.
 *
 * Steps: Pick → Edit (trim) → Sound → Cover → Captions → Audience + Publish.
 * TikTok upload model: picking creates a LOCAL copy only (auto-saved to
 * IndexedDB so a refresh never loses the edit); upload starts ONLY when the
 * user hits Publish, after a short finalizing pass, with a percentage-based
 * progress stage. Publish sends a structured `media` JSON payload.
 */
import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Camera, ChevronLeft, ChevronRight, Clapperboard, Image as ImageIcon,
  Loader2, Music, Plus, Scissors, Trash2, Type, Users, X,
} from 'lucide-react';
import { feedApi, type Sound } from '@/api/feed';
import {
  compressImage, uploadToCloudinary, UploadError, extractServerError,
  type UploadedMedia, type UploadProgress,
} from '@/lib/uploader';
import { buildMediaPayload, MAX_MEDIA_ITEMS } from '@/lib/createStudio';
import {
  saveStudioDraft, loadStudioDraft, clearStudioDraft,
  type DraftMediaItem,
} from '@/lib/createDrafts';
import { track } from '@/lib/analytics';
import { TrimEditor, type TrimRangeValue } from '@/components/create/TrimEditor';
import { SoundPicker, type SelectedSound } from '@/components/create/SoundPicker';
import { CoverPicker } from '@/components/create/CoverPicker';
import { CaptionsPanel, type CaptionSegment } from '@/components/create/CaptionsPanel';
import { AudienceSheet } from '@/components/create/AudienceSheet';
import type { Visibility } from '@/types';

type StepKey = 'pick' | 'edit' | 'sound' | 'cover' | 'captions' | 'post';
type PublishStage = 'finalizing' | 'uploading' | 'creating';

interface StudioItem {
  id: string;
  file: File;
  kind: 'image' | 'video';
  previewUrl: string;
  status: 'ready' | 'uploading' | 'done' | 'error';
  progress: number;
  media?: UploadedMedia;
  durationMs: number | null;
  trim: TrimRangeValue | null;
  altText: string;
  coverOffsetSec: number | null;
}

interface UploadState {
  itemName: string;
  pct: number;
  loadedBytes: number;
  totalBytes: number;
}

function formatBytes(bytes: number): string {
  if (bytes >= 1024 * 1024) return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  if (bytes >= 1024) return `${(bytes / 1024).toFixed(0)} KB`;
  return `${bytes} B`;
}

const STEP_META: Record<StepKey, { title: string; blurb: string }> = {
  pick: { title: 'Pick media', blurb: 'Choose up to 12 photos and videos' },
  edit: { title: 'Trim clips', blurb: 'Set the best in and out points' },
  sound: { title: 'Add sound', blurb: 'Pick a sound or keep original audio' },
  cover: { title: 'Choose cover', blurb: 'Pick the frame people see first' },
  captions: { title: 'Captions', blurb: 'Auto or manual timed captions' },
  post: { title: 'Post', blurb: 'Caption, audience & publish' },
};

export default function CreateStudio() {
  const navigate = useNavigate();

  const [items, setItems] = useState<StudioItem[]>([]);
  const [stepIdx, setStepIdx] = useState(0);
  const [showSoundPicker, setShowSoundPicker] = useState(false);
  const [sound, setSound] = useState<SelectedSound | null>(null);
  const [autoCaptions, setAutoCaptions] = useState(true);
  const [segments, setSegments] = useState<CaptionSegment[]>([]);
  const [visibility, setVisibility] = useState<Visibility>('public');
  const [commentsDisabled, setCommentsDisabled] = useState(false);
  const [body, setBody] = useState('');
  const [publishStage, setPublishStage] = useState<PublishStage | null>(null);
  const [uploadState, setUploadState] = useState<UploadState | null>(null);
  const [publishError, setPublishError] = useState('');
  const [draftRestored, setDraftRestored] = useState(false);

  const abortMapRef = useRef<Map<string, AbortController>>(new Map());
  const idempotencyRef = useRef<string | null>(null);
  const itemsRef = useRef<StudioItem[]>([]);
  const galleryInputRef = useRef<HTMLInputElement>(null);
  const cameraVideoInputRef = useRef<HTMLInputElement>(null);
  const cameraPhotoInputRef = useRef<HTMLInputElement>(null);

  // Active video per Edit/Cover step.
  const videoItems = useMemo(() => items.filter((it) => it.kind === 'video'), [items]);
  const [activeVideoId, setActiveVideoId] = useState<string | null>(null);
  const activeVideo = videoItems.find((it) => it.id === activeVideoId) ?? videoItems[0] ?? null;

  const hasVideo = videoItems.length > 0;
  useEffect(() => { itemsRef.current = items; }, [items]);
  const steps: StepKey[] = useMemo(() => {
    const s: StepKey[] = ['pick'];
    if (hasVideo) s.push('edit', 'sound', 'cover');
    s.push('captions', 'post');
    return s;
  }, [hasVideo]);
  const step = steps[stepIdx] ?? steps[steps.length - 1];
  const isLastStep = stepIdx === steps.length - 1;

  // Keep the step index valid when the step list shrinks (e.g. videos removed).
  useEffect(() => {
    setStepIdx((i) => Math.min(i, steps.length - 1));
  }, [steps.length]);

  // ── Local draft (IndexedDB): load once, autosave on change, clear on publish ──
  useEffect(() => {
    let cancelled = false;
    (async () => {
      const draft = await loadStudioDraft();
      if (cancelled || !draft || draft.items.length === 0) return;
      const restored: StudioItem[] = draft.items.map((d: DraftMediaItem) => {
        const file = new File([d.blob], d.name, { type: d.type });
        return {
          id: d.id,
          file,
          kind: d.kind,
          previewUrl: URL.createObjectURL(file),
          status: 'ready' as const,
          progress: 0,
          durationMs: d.duration_ms ?? null,
          trim: d.trim_start_ms != null && d.trim_end_ms != null
            ? { start_ms: d.trim_start_ms, end_ms: d.trim_end_ms }
            : null,
          altText: d.alt_text ?? '',
          coverOffsetSec: d.cover_offset_sec ?? null,
        };
      });
      setItems(restored);
      setBody(draft.text);
      setVisibility((draft.visibility as Visibility) || 'public');
      setCommentsDisabled(draft.commentsDisabled);
      if (draft.items.some((d) => d.sound)) {
        const ds = draft.items.find((d) => d.sound)!.sound!;
        setSound({ id: ds.id, name: ds.name, artist: ds.artist, volume: ds.volume });
      }
      setDraftRestored(true);
    })();
    return () => { cancelled = true; };
  }, []);

  // Debounced autosave — media Blobs are structured-cloneable into IDB.
  useEffect(() => {
    if (publishStage) return;
    const timer = setTimeout(() => {
      if (items.length === 0 && !body) return;
      const draftItems: DraftMediaItem[] = items.map((it) => ({
        id: it.id,
        kind: it.kind,
        name: it.file.name,
        type: it.file.type,
        size: it.file.size,
        blob: it.file,
        duration_ms: it.durationMs ?? undefined,
        trim_start_ms: it.trim?.start_ms,
        trim_end_ms: it.trim?.end_ms,
        sound: sound && it.kind === 'video' ? sound : undefined,
        alt_text: it.altText || undefined,
        cover_offset_sec: it.coverOffsetSec,
      }));
      void saveStudioDraft({
        savedAt: Date.now(),
        text: body,
        hashtags: '',
        visibility,
        commentsDisabled,
        items: draftItems,
      });
    }, 800);
    return () => clearTimeout(timer);
  }, [items, body, visibility, commentsDisabled, sound, publishStage]);

  // Revoke object previews on unmount.
  useEffect(() => () => {
    itemsRef.current.forEach((it) => URL.revokeObjectURL(it.previewUrl));
  }, []);

  // ── Pick: local copy only — no network. ────────────────────────────────────
  const handleFiles = useCallback((fileList: FileList | null) => {
    if (!fileList) return;
    const remaining = MAX_MEDIA_ITEMS - itemsRef.current.length;
    const picked = Array.from(fileList)
      .filter((f) => f.type.startsWith('image/') || f.type.startsWith('video/'))
      .slice(0, Math.max(0, remaining));
    if (picked.length === 0) return;
    track('create.started', { surface: 'create', properties: { count: picked.length } });
    setDraftRestored(false);
    const newItems: StudioItem[] = picked.map((file) => ({
      id: crypto.randomUUID(),
      file,
      kind: file.type.startsWith('video/') ? 'video' : 'image',
      previewUrl: URL.createObjectURL(file),
      status: 'ready',
      progress: 0,
      durationMs: null,
      trim: null,
      altText: '',
      coverOffsetSec: null,
    }));
    setItems((prev) => [...prev, ...newItems]);
  }, []);

  const removeItem = (id: string) => {
    const item = itemsRef.current.find((it) => it.id === id);
    if (item) URL.revokeObjectURL(item.previewUrl);
    setItems((prev) => prev.filter((it) => it.id !== id));
  };

  const handleTrimChange = (itemId: string) => (trim: TrimRangeValue, meta: { clamped: boolean }) => {
    setItems((prev) => prev.map((it) => (it.id === itemId ? { ...it, trim } : it)));
    track('create.trim_set', {
      surface: 'create',
      properties: { item_id: itemId, start_ms: trim.start_ms, end_ms: trim.end_ms, clamped: meta.clamped },
    });
  };

  const handleSoundSelect = (selected: Sound | null, volume: number) => {
    setSound(selected ? { id: selected.id, name: selected.name, artist: selected.artist, volume } : null);
    setShowSoundPicker(false);
    if (selected) {
      track('create.sound_added', {
        surface: 'create',
        object_type: 'sound',
        object_id: selected.id,
        properties: { volume },
      });
    }
  };

  const handleVisibilityChange = (v: Visibility) => {
    setVisibility(v);
    track('create.audience_set', { surface: 'create', properties: { visibility: v, comments_disabled: commentsDisabled } });
  };

  const handleCommentsDisabledChange = (disabled: boolean) => {
    setCommentsDisabled(disabled);
    track('create.audience_set', { surface: 'create', properties: { visibility, comments_disabled: disabled } });
  };

  const allUploaded = true; // uploads now happen at publish, not per-item
  const canProceed =
    step === 'pick' ? items.length > 0 : step === 'post' ? items.length > 0 : true;

  const goBack = () => {
    if (stepIdx === 0) {
      exitStudio();
    } else {
      setStepIdx((i) => i - 1);
    }
  };

  const exitStudio = () => {
    if (publishStage) return; // never abandon a running publish silently
    if ((items.length > 0 || body) && !window.confirm('Leave? Your draft is saved automatically.')) return;
    navigate('/feed/bud-press');
  };

  // ── Publish: Finalize → Upload (percentage) → Create ───────────────────────
  const publish = async () => {
    if (items.length === 0 || publishStage) return;
    setPublishError('');
    const controller = new AbortController();
    abortMapRef.current.set('__publish__', controller);
    const uploaded: { item: StudioItem; media: UploadedMedia }[] = [];

    try {
      // 1) Finalize: images are downscaled here (the "export your edit" pass);
      //    videos ship as-is — trim/sound render parametrically at delivery.
      setPublishStage('finalizing');
      const finalized: StudioItem[] = [];
      for (const it of items) {
        const file = it.kind === 'image' ? await compressImage(it.file) : it.file;
        finalized.push({ ...it, file });
      }

      // 2) Upload with byte-accurate percentage.
      setPublishStage('uploading');
      for (let i = 0; i < finalized.length; i++) {
        const it = finalized[i];
        setUploadState({ itemName: it.file.name, pct: 0, loadedBytes: 0, totalBytes: it.file.size });
        setItems((prev) => prev.map((p) => (p.id === it.id ? { ...p, status: 'uploading', progress: 0 } : p)));
        const media = await uploadToCloudinary(it.file, {
          signal: controller.signal,
          onProgress: (p: UploadProgress) => {
            setUploadState({ itemName: it.file.name, ...p });
            setItems((prev) => prev.map((pp) => (pp.id === it.id ? { ...pp, progress: p.pct } : pp)));
          },
        });
        uploaded.push({ item: it, media });
        setItems((prev) =>
          prev.map((pp) =>
            pp.id === it.id
              ? { ...pp, status: 'done', progress: 100, media, durationMs: media.duration_ms ?? pp.durationMs }
              : pp,
          ),
        );
        track('upload.completed', {
          surface: 'create',
          object_type: 'media',
          properties: { media_type: it.kind, bytes: media.bytes, duration_ms: media.duration_ms },
        });
      }

      // 3) Create the post — it appears immediately; captions arrive async.
      setPublishStage('creating');
      const mediaJson = buildMediaPayload(
        uploaded.map(({ item: it, media }) => ({
          kind: it.kind,
          media,
          trim_start_ms: it.kind === 'video' ? (it.trim?.start_ms ?? 0) : null,
          trim_end_ms: it.kind === 'video' ? (it.trim?.end_ms ?? it.durationMs ?? 0) : null,
          sound: it.kind === 'video' && sound ? { id: sound.id, volume: sound.volume } : null,
          alt_text: it.altText || null,
          coverOffsetSec: it.kind === 'video' ? it.coverOffsetSec : null,
        })),
      );
      const formData = new FormData();
      formData.append('body', body.trim());
      formData.append('visibility', visibility);
      formData.append('post_type', uploaded.some(({ item: i }) => i.kind === 'video') ? 'short_video' : 'photo');
      formData.append('media', JSON.stringify(mediaJson));
      if (commentsDisabled) formData.append('comments_disabled', 'true');
      formData.append('auto_captions', String(autoCaptions));
      const cleanSegments = segments.filter((s) => s.text.trim() && s.end_ms > s.start_ms);
      if (cleanSegments.length > 0) {
        formData.append(
          'captions',
          JSON.stringify(cleanSegments.map(({ start_ms, end_ms, text }) => ({ start_ms, end_ms, text: text.trim() }))),
        );
      }
      // Keep one key across retries so a re-submit never double-posts.
      const key = idempotencyRef.current ?? crypto.randomUUID();
      idempotencyRef.current = key;
      await feedApi.createPost(formData, key);
      idempotencyRef.current = null;
      track('create.published', {
        surface: 'create',
        properties: {
          media_count: uploaded.length,
          image_count: uploaded.filter(({ item: i }) => i.kind === 'image').length,
          video_count: uploaded.filter(({ item: i }) => i.kind === 'video').length,
          has_sound: !!sound,
          auto_captions: autoCaptions,
        },
      });
      await clearStudioDraft();
      navigate('/feed/bud-press');
    } catch (err) {
      if (err instanceof DOMException && err.name === 'AbortError') {
        setPublishError('Upload canceled. Your draft is saved on this device.');
      } else {
        const serverMessage =
          err instanceof UploadError && err.message && err.message !== 'Upload failed'
            ? err.message
            : '';
        setPublishError(
          serverMessage ||
            extractServerError(err, '') ||
            'Could not publish. Check your connection and try again.',
        );
        track('upload.failed', { surface: 'create', object_type: 'media' });
      }
      setPublishStage(null);
      setUploadState(null);
    } finally {
      abortMapRef.current.delete('__publish__');
    }
  };

  const cancelPublish = () => {
    abortMapRef.current.get('__publish__')?.abort();
  };

  // ── Render helpers ─────────────────────────────────────────────────────────
  const renderPick = () => (
    <div className="flex-1 overflow-y-auto px-4 pb-4 space-y-3">
      <div className="grid grid-cols-2 gap-2">
        <div className="flex flex-col items-center justify-center gap-1.5 py-4 rounded-2xl bg-buddy-surface-raised hover:bg-buddy-surface transition-colors">
          <span className="flex items-center gap-1.5 text-buddy-green">
            <Camera size={22} />
            <span className="text-sm font-semibold text-buddy-text-primary">Camera</span>
          </span>
          <span className="text-[10px] text-buddy-text-secondary">Capture now</span>
          <div className="flex gap-1.5 mt-1">
            <button
              onClick={() => cameraVideoInputRef.current?.click()}
              className="px-3 py-1.5 rounded-lg bg-buddy-green text-buddy-black text-xs font-bold"
            >
              Record
            </button>
            <button
              onClick={() => cameraPhotoInputRef.current?.click()}
              className="px-3 py-1.5 rounded-lg bg-buddy-surface text-buddy-text-primary text-xs font-semibold hover:text-buddy-green"
            >
              Snap
            </button>
          </div>
        </div>
        <button
          onClick={() => galleryInputRef.current?.click()}
          className="flex flex-col items-center gap-1.5 py-5 rounded-2xl bg-buddy-green text-buddy-black hover:bg-buddy-green/90 transition-colors"
        >
          <Plus size={22} strokeWidth={3} />
          <span className="text-sm font-bold">Gallery</span>
          <span className="text-[10px] opacity-80">Photos &amp; videos</span>
        </button>
      </div>

      {items.length > 0 && (
        <div className="space-y-2">
          <p className="text-xs font-semibold text-buddy-text-secondary uppercase tracking-wide">
            {items.length}/{MAX_MEDIA_ITEMS} selected
          </p>
          <div className="grid grid-cols-3 gap-2">
            {items.map((it) => (
              <div key={it.id} className="relative rounded-xl overflow-hidden bg-buddy-surface-raised aspect-[3/4] group">
                {it.kind === 'image' ? (
                  <img src={it.previewUrl} alt="" className="absolute inset-0 w-full h-full object-cover" />
                ) : (
                  <video src={it.previewUrl} muted playsInline className="absolute inset-0 w-full h-full object-cover" />
                )}
                <span className="absolute top-1.5 left-1.5 p-1 rounded-full bg-black/60 text-white">
                  {it.kind === 'video' ? <Clapperboard size={10} /> : <ImageIcon size={10} />}
                </span>
                <button
                  onClick={() => removeItem(it.id)}
                  className="absolute top-1.5 right-1.5 p-1 rounded-full bg-black/60 text-white opacity-0 group-hover:opacity-100 hover:bg-black/80 transition-opacity"
                  aria-label="Remove"
                >
                  <Trash2 size={11} />
                </button>
                {it.kind === 'video' && it.durationMs != null && (
                  <span className="absolute bottom-1.5 left-1.5 px-1 rounded bg-black/60 text-white text-[9px] font-semibold">
                    {Math.round(it.durationMs / 1000)}s
                  </span>
                )}
              </div>
            ))}
          </div>
          {draftRestored && (
            <p className="text-[11px] text-buddy-green flex items-center gap-1.5">
              ✓ Draft restored — pick up right where you left off.
            </p>
          )}
        </div>
      )}
    </div>
  );

  const videoStrip = () => (
    <div className="flex gap-2 overflow-x-auto scrollbar-none pb-1">
      {videoItems.map((it) => (
        <button
          key={it.id}
          onClick={() => setActiveVideoId(it.id)}
          className={`relative w-14 h-20 rounded-lg overflow-hidden shrink-0 ring-2 transition-all ${
            activeVideo?.id === it.id ? 'ring-buddy-green' : 'ring-transparent opacity-60'
          }`}
        >
          <video src={it.previewUrl} muted playsInline preload="metadata" className="w-full h-full object-cover" />
        </button>
      ))}
    </div>
  );

  const renderEdit = () =>
    activeVideo ? (
      <div className="flex-1 overflow-y-auto px-4 pb-4 space-y-3">
        {videoItems.length > 1 && videoStrip()}
        <TrimEditor
          videoUrl={activeVideo.previewUrl}
          durationMs={activeVideo.durationMs ?? activeVideo.media?.duration_ms ?? null}
          trim={activeVideo.trim ?? { start_ms: 0, end_ms: activeVideo.durationMs ?? 0 }}
          onChange={handleTrimChange(activeVideo.id)}
          onDuration={(ms) =>
            setItems((prev) => prev.map((it) => (it.id === activeVideo.id ? { ...it, durationMs: ms } : it)))
          }
        />
      </div>
    ) : null;

  const renderSound = () => (
    <div className="flex-1 overflow-y-auto px-4 pb-4 space-y-3">
      <button
        onClick={() => setShowSoundPicker(true)}
        className={`w-full flex items-center gap-3 px-4 py-4 rounded-2xl transition-colors ${
          sound ? 'bg-buddy-green/15' : 'bg-buddy-surface-raised hover:bg-buddy-surface'
        }`}
      >
        <span className="p-2.5 rounded-full bg-buddy-surface text-buddy-green">
          <Music size={18} />
        </span>
        <span className="flex-1 text-left min-w-0">
          {sound ? (
            <>
              <span className="block text-sm font-semibold text-buddy-green truncate">{sound.name}</span>
              <span className="block text-[11px] text-buddy-text-secondary truncate">{sound.artist} · {sound.volume}% volume</span>
            </>
          ) : (
            <>
              <span className="block text-sm font-semibold">Original audio only</span>
              <span className="block text-[11px] text-buddy-text-secondary">Tap to browse trending sounds</span>
            </>
          )}
        </span>
        <ChevronRight size={16} className="text-buddy-text-secondary" />
      </button>
      <p className="text-[11px] text-buddy-text-secondary px-1">
        Your clips keep their original audio — a chosen sound plays on top at the volume you set.
      </p>
      {sound && (
        <button onClick={() => handleSoundSelect(null, 0)} className="text-xs text-buddy-text-secondary hover:text-buddy-red">
          Remove sound — back to original audio only
        </button>
      )}
    </div>
  );

  const renderCover = () =>
    activeVideo ? (
      <div className="flex-1 overflow-y-auto px-4 pb-4 space-y-3">
        {videoItems.length > 1 && videoStrip()}
        <CoverPicker
          videoUrl={activeVideo.previewUrl}
          durationMs={activeVideo.durationMs ?? activeVideo.media?.duration_ms ?? null}
          offsetSec={activeVideo.coverOffsetSec}
          onChange={(offsetSec) =>
            setItems((prev) => prev.map((it) => (it.id === activeVideo.id ? { ...it, coverOffsetSec: offsetSec } : it)))
          }
        />
      </div>
    ) : null;

  const renderCaptions = () => (
    <div className="flex-1 overflow-y-auto px-4 pb-4">
      <CaptionsPanel
        hasVideo={hasVideo}
        autoCaptions={autoCaptions}
        onToggleAuto={(on) => {
          setAutoCaptions(on);
          track('create.captions_toggled', { surface: 'create', properties: { auto: on } });
        }}
        segments={segments}
        onChangeSegments={setSegments}
      />
    </div>
  );

  const renderPost = () => (
    <div className="flex-1 overflow-y-auto px-4 pb-4 space-y-4">
      <div className="rounded-2xl bg-buddy-surface-raised p-3">
        <div className="flex items-center gap-1.5 mb-2 text-buddy-text-secondary">
          <Type size={13} />
          <span className="text-xs font-semibold uppercase tracking-wide">Caption &amp; hashtags</span>
        </div>
        <textarea
          value={body}
          onChange={(e) => setBody(e.target.value)}
          rows={3}
          maxLength={2200}
          placeholder="Describe your post… add #hashtags"
          className="w-full bg-transparent text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 outline-none resize-none"
        />
      </div>

      {/* Accessibility: alt text per item */}
      <div className="space-y-2">
        <p className="text-xs font-semibold text-buddy-text-secondary uppercase tracking-wide flex items-center gap-1.5">
          <ImageIcon size={13} /> Alt text
        </p>
        {items.map((it, i) => (
          <input
            key={it.id}
            value={it.altText}
            onChange={(e) =>
              setItems((prev) => prev.map((x) => (x.id === it.id ? { ...x, altText: e.target.value } : x)))
            }
            placeholder={`${it.kind === 'video' ? 'Video' : 'Photo'} ${i + 1} description (for screen readers)`}
            className="w-full bg-buddy-surface-raised rounded-xl px-3 py-2 text-sm outline-none focus:ring-1 focus:ring-buddy-green/40"
          />
        ))}
      </div>

      <div>
        <p className="text-xs font-semibold text-buddy-text-secondary uppercase tracking-wide flex items-center gap-1.5 mb-2">
          <Users size={13} /> Audience
        </p>
        <AudienceSheet
          visibility={visibility}
          commentsDisabled={commentsDisabled}
          onVisibilityChange={handleVisibilityChange}
          onCommentsDisabledChange={handleCommentsDisabledChange}
        />
      </div>
    </div>
  );

  const stepIcons: Record<StepKey, React.ReactNode> = {
    pick: <Plus size={13} />,
    edit: <Scissors size={13} />,
    sound: <Music size={13} />,
    cover: <ImageIcon size={13} />,
    captions: <Type size={13} />,
    post: <Users size={13} />,
  };

  return (
    <div className="fixed inset-0 z-50 bg-buddy-black flex flex-col">
      {/* Hidden pickers — camera capture rides the input's capture attribute */}
      <input
        ref={galleryInputRef}
        type="file"
        accept="image/*,video/*"
        multiple
        className="hidden"
        onChange={(e) => { handleFiles(e.target.files); e.target.value = ''; }}
      />
      <input
        ref={cameraVideoInputRef}
        type="file"
        accept="video/*"
        capture="environment"
        className="hidden"
        onChange={(e) => { handleFiles(e.target.files); e.target.value = ''; }}
      />
      <input
        ref={cameraPhotoInputRef}
        type="file"
        accept="image/*"
        capture="environment"
        className="hidden"
        onChange={(e) => { handleFiles(e.target.files); e.target.value = ''; }}
      />

      {/* Header */}
      <div className="flex items-center gap-3 px-4 py-3 border-b border-buddy-surface shrink-0">
        <button onClick={goBack} className="p-2 -ml-2 rounded-full text-buddy-text-secondary hover:text-buddy-text-primary" aria-label="Back">
          <ChevronLeft size={22} />
        </button>
        <div className="flex-1 min-w-0">
          <h1 className="font-heading font-bold text-base leading-tight truncate">{STEP_META[step].title}</h1>
          <p className="text-[11px] text-buddy-text-secondary truncate">{STEP_META[step].blurb}</p>
        </div>
        <button onClick={exitStudio} className="p-2 rounded-full text-buddy-text-secondary hover:text-buddy-text-primary" aria-label="Close studio">
          <X size={20} />
        </button>
      </div>

      {/* Step dots */}
      <div className="flex items-center justify-center gap-1.5 py-2 shrink-0">
        {steps.map((s, i) => (
          <span
            key={s}
            className={`p-1 rounded-full flex items-center justify-center ${
              i === stepIdx ? 'text-buddy-green' : i < stepIdx ? 'text-buddy-green/40' : 'text-buddy-text-secondary/30'
            }`}
            title={STEP_META[s].title}
          >
            {stepIcons[s]}
          </span>
        ))}
      </div>

      {/* Step body */}
      {step === 'pick' && renderPick()}
      {step === 'edit' && renderEdit()}
      {step === 'sound' && renderSound()}
      {step === 'cover' && renderCover()}
      {step === 'captions' && renderCaptions()}
      {step === 'post' && renderPost()}

      {/* Footer */}
      <div className="border-t border-buddy-surface px-4 py-3 shrink-0 space-y-2">
        {publishError && (
          <p className="text-sm text-buddy-red bg-buddy-red/10 rounded-xl px-3 py-2">{publishError}</p>
        )}
        {publishStage && publishStage !== 'creating' && (
          <div className="rounded-xl bg-buddy-surface-raised px-3 py-2.5 space-y-1.5">
            {publishStage === 'uploading' && uploadState ? (
              <>
                <div className="flex items-center justify-between text-xs">
                  <span className="font-semibold text-buddy-text-primary truncate max-w-[55%]">
                    Uploading {uploadState.itemName}
                  </span>
                  <span className="font-bold text-buddy-green tabular-nums">{uploadState.pct}%</span>
                </div>
                <div className="h-1.5 rounded-full bg-buddy-surface overflow-hidden">
                  <div
                    className="h-full bg-buddy-green transition-all"
                    style={{ width: `${uploadState.pct}%` }}
                  />
                </div>
                <div className="flex items-center justify-between text-[10px] text-buddy-text-secondary">
                  <span>
                    {formatBytes(uploadState.loadedBytes)} / {formatBytes(uploadState.totalBytes)}
                  </span>
                  <button
                    onClick={cancelPublish}
                    className="font-semibold text-buddy-text-secondary hover:text-buddy-red"
                  >
                    Cancel
                  </button>
                </div>
              </>
            ) : (
              <div className="flex items-center gap-2 text-xs text-buddy-text-secondary">
                <Loader2 size={13} className="animate-spin text-buddy-green" />
                {publishStage === 'finalizing' ? 'Finalizing your edit…' : 'Publishing…'}
              </div>
            )}
          </div>
        )}
        <div className="flex items-center gap-3">
          {stepIdx > 0 && !publishStage && (
            <button
              onClick={() => setStepIdx((i) => i - 1)}
              className="px-4 py-2.5 rounded-xl bg-buddy-surface-raised text-sm font-semibold hover:bg-buddy-surface transition-colors"
            >
              Back
            </button>
          )}
          <button
            onClick={() => (isLastStep ? void publish() : setStepIdx((i) => i + 1))}
            disabled={!canProceed || !!publishStage}
            className="flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl bg-buddy-green text-buddy-black text-sm font-bold disabled:opacity-40 disabled:cursor-not-allowed hover:bg-buddy-green/90 transition-colors"
          >
            {publishStage && <Loader2 size={15} className="animate-spin" />}
            {isLastStep ? (publishStage ? 'Publishing…' : 'Publish') : 'Next'}
          </button>
        </div>
      </div>

      <SoundPicker
        open={showSoundPicker}
        selected={sound}
        videoHasAudio={hasVideo}
        onSelect={handleSoundSelect}
        onVolumeChange={(volume) => setSound((s) => (s ? { ...s, volume } : s))}
        onClose={() => setShowSoundPicker(false)}
      />
    </div>
  );
}
