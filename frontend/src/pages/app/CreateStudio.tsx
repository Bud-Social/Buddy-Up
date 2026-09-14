/**
 * CreateStudio — TikTok/IG-style full-screen creation wizard for Bud Press.
 *
 * Steps: Pick → Edit (trim) → Sound → Cover → Captions → Audience + Publish.
 * TikTok upload model: picking creates a LOCAL copy only (auto-saved to
 * IndexedDB so a refresh never loses the edit); upload starts ONLY when the
 * user hits Publish — as a BACKGROUND job (see lib/uploadManager) with
 * percentage progress. Navigating away never aborts a running upload while
 * the SPA is alive; the draft is cleared only after post-create success.
 * Captions are owned per clip (captionsByItem) and ship with each video.
 */
import { useEffect, useMemo, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  ArrowLeft, ArrowRight, Camera, Captions, ChevronLeft, ChevronRight, Clapperboard, Copy, Image as ImageIcon,
  Loader2, Music, Pause, Play, Plus, RotateCcw, Redo2, Scissors, Trash2, Type, Undo2, Users, X,
} from 'lucide-react';
import { feedApi, type Sound } from '@/api/feed';
import { getOrExportTrimmedVideo } from '@/lib/uploader';
import {
  MAX_MEDIA_ITEMS, defaultEditMeta, splitTrim, partitionTimedElements,
  normalizeTrimExport, shouldExportTrimmedVideo,
  cleanCaptionSegments, cloneCaptionSegments, newCaptionId, partitionCaptionsForSplit,
  UndoStack,
  type AudioTrack, type CaptionsByItem, type CaptionsStyle, type EditMeta, type TrimRangeValue,
} from '@/lib/createStudio';
import {
  saveStudioDraft, loadStudioDraft,
  extractCaptionsByItem, isQuotaError,
  type DraftMediaItem,
} from '@/lib/createDrafts';
import { uploadManager, type EnqueueSpec, type JobSnapshot, type PersistedSession } from '@/lib/uploadManager';
import { track } from '@/lib/analytics';
import { EditStage } from '@/components/create/EditStage';
import { SoundPicker, type SelectedSound } from '@/components/create/SoundPicker';
import { CoverPicker } from '@/components/create/CoverPicker';
import { CaptionsPanel, type AutoCaptionJob, type CaptionSegment } from '@/components/create/CaptionsPanel';
import { AudienceSheet } from '@/components/create/AudienceSheet';
import type { Visibility } from '@/types';

type StepKey = 'pick' | 'edit' | 'sound' | 'cover' | 'captions' | 'post';

interface StudioItem {
  id: string;
  file: File;
  kind: 'image' | 'video';
  previewUrl: string;
  durationMs: number | null;
  trim: TrimRangeValue | null;
  editMeta: EditMeta;
  altText: string;
  coverOffsetSec: number | null;
}

interface StudioSnap {
  items: StudioItem[];
  captionsByItem: CaptionsByItem;
  captionStylesByItem: Record<string, CaptionsStyle>;
  sound: SelectedSound | null;
}

function formatBytes(bytes: number): string {
  if (bytes >= 1024 * 1024) return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  if (bytes >= 1024) return `${(bytes / 1024).toFixed(0)} KB`;
  return `${bytes} B`;
}

function cloneEditMeta(meta: EditMeta): EditMeta {
  return {
    ...meta,
    adjust: { ...meta.adjust },
    textOverlays: meta.textOverlays.map((o) => ({ ...o })),
    stickers: (meta.stickers || []).map((s) => ({ ...s })),
    audioTracks: meta.audioTracks.map((t) => ({ ...t })),
    captions_style: meta.captions_style ? { ...meta.captions_style } : meta.captions_style,
  };
}

const STEP_META: Record<StepKey, { title: string; blurb: string }> = {
  pick: { title: 'Pick media', blurb: 'Choose up to 12 photos and videos' },
  edit: { title: 'Trim clips', blurb: 'Set the best in and out points' },
  sound: { title: 'Add sound', blurb: 'Pick a sound or keep original audio' },
  cover: { title: 'Choose cover', blurb: 'Pick the frame people see first' },
  captions: { title: 'Captions', blurb: 'Review & style per clip' },
  post: { title: 'Post', blurb: 'Caption, audience & publish' },
};

export default function CreateStudio() {
  const navigate = useNavigate();

  const [items, setItems] = useState<StudioItem[]>([]);
  const [captionsByItem, setCaptionsByItem] = useState<CaptionsByItem>({});
  const [captionStylesByItem, setCaptionStylesByItem] = useState<Record<string, CaptionsStyle>>({});
  const [autoStateByItem, setAutoStateByItem] = useState<Record<string, AutoCaptionJob>>({});
  const [stepIdx, setStepIdx] = useState(0);
  const [showSoundPicker, setShowSoundPicker] = useState(false);
  const [sound, setSound] = useState<SelectedSound | null>(null);
  const [autoCaptions, setAutoCaptions] = useState(true);
  const [visibility, setVisibility] = useState<Visibility>('public');
  const [commentsDisabled, setCommentsDisabled] = useState(false);
  const [body, setBody] = useState('');
  const [publishError, setPublishError] = useState('');
  const [draftRestored, setDraftRestored] = useState(false);
  const [storageFull, setStorageFull] = useState(false);
  const [jobId, setJobId] = useState<string | null>(null);
  const [jobSnap, setJobSnap] = useState<JobSnapshot | null>(null);
  const [sessions, setSessions] = useState<PersistedSession[]>([]);
  const [, setHistTick] = useState(0);

  const autoCtrlRef = useRef<Map<string, AbortController>>(new Map());
  const itemsRef = useRef<StudioItem[]>([]);
  const captionsRef = useRef<CaptionsByItem>({});
  const stylesRef = useRef<Record<string, CaptionsStyle>>({});
  const soundRef = useRef<SelectedSound | null>(null);
  const historyRef = useRef(new UndoStack<StudioSnap>(50));
  const lastHistPushRef = useRef(0);
  const urlsRef = useRef<Set<string>>(new Set());
  const galleryInputRef = useRef<HTMLInputElement>(null);
  const cameraVideoInputRef = useRef<HTMLInputElement>(null);
  const cameraPhotoInputRef = useRef<HTMLInputElement>(null);

  // Active video per Edit/Cover/Captions step.
  const videoItems = useMemo(() => items.filter((it) => it.kind === 'video'), [items]);
  const [activeVideoId, setActiveVideoId] = useState<string | null>(null);
  const activeVideo = videoItems.find((it) => it.id === activeVideoId) ?? videoItems[0] ?? null;
  const activeIdx = activeVideo ? videoItems.findIndex((it) => it.id === activeVideo.id) : -1;

  const hasVideo = videoItems.length > 0;
  useEffect(() => { itemsRef.current = items; }, [items]);
  useEffect(() => { captionsRef.current = captionsByItem; }, [captionsByItem]);
  useEffect(() => { stylesRef.current = captionStylesByItem; }, [captionStylesByItem]);
  useEffect(() => { soundRef.current = sound; }, [sound]);
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

  // ── Bounded undo/redo (trim/text/stickers/captions/audio/filter/speed) ──
  const snapshotNow = (): StudioSnap => ({
    items: itemsRef.current,
    captionsByItem: captionsRef.current,
    captionStylesByItem: stylesRef.current,
    sound: soundRef.current,
  });
  const pushHistory = (mode: 'discrete' | 'coalesce' = 'discrete') => {
    const now = Date.now();
    if (mode === 'coalesce' && now - lastHistPushRef.current < 1500) return;
    lastHistPushRef.current = now;
    historyRef.current.push(snapshotNow());
    setHistTick((t) => t + 1);
  };
  const restoreSnap = (s: StudioSnap) => {
    setItems(s.items);
    setCaptionsByItem(s.captionsByItem);
    setCaptionStylesByItem(s.captionStylesByItem);
    setSound(s.sound);
  };
  const undo = () => {
    const prev = historyRef.current.undo(snapshotNow());
    if (prev) {
      restoreSnap(prev);
      setHistTick((t) => t + 1);
    }
  };
  const redo = () => {
    const next = historyRef.current.redo(snapshotNow());
    if (next) {
      restoreSnap(next);
      setHistTick((t) => t + 1);
    }
  };

  // ── Local draft (IndexedDB): load once, autosave on change ────────────────
  // Cleared only by the upload manager after post-create success.
  useEffect(() => {
    let cancelled = false;
    (async () => {
      const draft = await loadStudioDraft();
      if (cancelled || !draft || draft.items.length === 0) return;
      const restored: StudioItem[] = draft.items.map((d: DraftMediaItem) => {
        const file = new File([d.blob], d.name, { type: d.type });
        const previewUrl = URL.createObjectURL(file);
        urlsRef.current.add(previewUrl);
        return {
          id: d.id,
          file,
          kind: d.kind,
          previewUrl,
          durationMs: d.duration_ms ?? null,
          trim: d.trim_start_ms != null && d.trim_end_ms != null
            ? { start_ms: d.trim_start_ms, end_ms: d.trim_end_ms }
            : null,
          altText: d.alt_text ?? '',
          coverOffsetSec: d.cover_offset_sec ?? null,
          editMeta: { ...defaultEditMeta(), ...(d.edit_meta ?? {}) },
        };
      });
      const perClip = extractCaptionsByItem(draft);
      const seeded: CaptionsByItem = {};
      for (const [id, list] of Object.entries(perClip)) {
        seeded[id] = list.map((s) => ({ id: newCaptionId(), start_ms: s.start_ms, end_ms: s.end_ms, text: s.text }));
      }
      const seededStyles: Record<string, CaptionsStyle> = {};
      for (const d of draft.items) {
        if (d.edit_meta?.captions_style) seededStyles[d.id] = { ...d.edit_meta.captions_style };
      }
      setItems(restored);
      setCaptionsByItem(seeded);
      setCaptionStylesByItem(seededStyles);
      setBody(draft.text);
      setVisibility((draft.visibility as Visibility) || 'public');
      setCommentsDisabled(draft.commentsDisabled);
      if (draft.items.some((d) => d.sound)) {
        const ds = draft.items.find((d) => d.sound)!.sound!;
        setSound({
          id: ds.id, name: ds.name, artist: ds.artist, volume: ds.volume,
          ...(ds.start_offset_ms != null ? { startOffsetMs: ds.start_offset_ms } : {}),
          ...(ds.fade_in_ms != null ? { fadeInMs: ds.fade_in_ms } : {}),
          ...(ds.fade_out_ms != null ? { fadeOutMs: ds.fade_out_ms } : {}),
        });
      }
      setDraftRestored(true);
    })();
    return () => { cancelled = true; };
  }, []);

  // Debounced autosave — media Blobs are structured-cloneable into IDB.
  // Quota failures keep the memory copy and surface a banner (never discard).
  useEffect(() => {
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
        sound: sound && it.kind === 'video'
          ? {
            id: sound.id, name: sound.name, artist: sound.artist, volume: sound.volume,
            ...(sound.startOffsetMs != null ? { start_offset_ms: sound.startOffsetMs } : {}),
            ...(sound.fadeInMs != null ? { fade_in_ms: sound.fadeInMs } : {}),
            ...(sound.fadeOutMs != null ? { fadeOutMs: sound.fadeOutMs } : {}),
          }
          : undefined,
        alt_text: it.altText || undefined,
        cover_offset_sec: it.coverOffsetSec,
        edit_meta: it.kind === 'video'
          ? {
            ...it.editMeta,
            ...(captionStylesByItem[it.id] ? { captions_style: captionStylesByItem[it.id] } : {}),
          }
          : undefined,
        captions: it.kind === 'video' && captionsByItem[it.id]?.length
          ? cleanCaptionSegments(captionsByItem[it.id])
          : undefined,
      }));
      void saveStudioDraft({
        savedAt: Date.now(),
        text: body,
        hashtags: '',
        visibility,
        commentsDisabled,
        items: draftItems,
      }).then((res) => {
        setStorageFull(!res.ok && res.quota);
      }).catch((err) => {
        setStorageFull(isQuotaError(err));
      });
    }, 800);
    return () => clearTimeout(timer);
  }, [items, captionsByItem, captionStylesByItem, body, visibility, commentsDisabled, sound]);

  // Revoke object previews on unmount (shared URLs are revoked once via set).
  useEffect(() => () => {
    const urls = urlsRef.current;
    urls.forEach((u) => {
      try {
        URL.revokeObjectURL(u);
      } catch {
        // Already revoked.
      }
    });
    autoCtrlRef.current.forEach((c) => {
      try {
        c.abort();
      } catch {
        // ignore
      }
    });
  }, []);

  // Re-attach to a running job after remount (same SPA session) and follow it.
  useEffect(() => {
    if (!jobId) {
      const active = uploadManager.getAllSnapshots().find((s) =>
        ['queued', 'finalizing', 'uploading', 'creating', 'paused', 'failed'].includes(s.status),
      );
      if (active) setJobId(active.jobId);
    }
    setSessions(uploadManager.getPersistedSessions().filter((s) => s.status !== 'done' && s.status !== 'canceled'));
  }, [jobId]);

  useEffect(() => {
    if (!jobId) return;
    setJobSnap(uploadManager.getSnapshot(jobId));
    const unsub = uploadManager.subscribe((ev) => {
      if (ev.snapshot.jobId !== jobId) return;
      setJobSnap(ev.snapshot);
      setSessions(uploadManager.getPersistedSessions().filter((s) => s.status !== 'done' && s.status !== 'canceled'));
      if (ev.type === 'done') {
        track('create.published', {
          surface: 'create',
          properties: { media_count: ev.snapshot.items.length },
        });
        navigate('/feed/bud-press');
      } else if (ev.type === 'failed') {
        track('upload.failed', { surface: 'create', object_type: 'media' });
      }
    });
    return unsub;
  }, [jobId, navigate]);

  // ── Pick: local copy only — no network. ────────────────────────────────────
  const handleFiles = (fileList: FileList | null) => {
    if (!fileList) return;
    const remaining = MAX_MEDIA_ITEMS - itemsRef.current.length;
    const picked = Array.from(fileList)
      .filter((f) => f.type.startsWith('image/') || f.type.startsWith('video/'))
      .slice(0, Math.max(0, remaining));
    if (picked.length === 0) return;
    track('create.started', { surface: 'create', properties: { count: picked.length } });
    setDraftRestored(false);
    const newItems: StudioItem[] = picked.map((file) => {
      const previewUrl = URL.createObjectURL(file);
      urlsRef.current.add(previewUrl);
      return {
        id: crypto.randomUUID(),
        file,
        kind: file.type.startsWith('video/') ? 'video' : 'image',
        previewUrl,
        durationMs: null,
        trim: null,
        editMeta: defaultEditMeta(),
        altText: '',
        coverOffsetSec: null,
      };
    });
    pushHistory();
    setItems((prev) => [...prev, ...newItems]);
  };

  const removeItem = (id: string) => {
    pushHistory();
    setItems((prev) => prev.filter((it) => it.id !== id));
    setCaptionsByItem((prev) => {
      if (!(id in prev)) return prev;
      const next = { ...prev };
      delete next[id];
      return next;
    });
    setCaptionStylesByItem((prev) => {
      if (!(id in prev)) return prev;
      const next = { ...prev };
      delete next[id];
      return next;
    });
    setAutoStateByItem((prev) => {
      if (!(id in prev)) return prev;
      const next = { ...prev };
      delete next[id];
      return next;
    });
    // Preview URLs are revoked once on unmount (undo may restore the item).
  };

  /** Clip-strip reorder: captions/styles ride along (keyed by item id). */
  const moveItem = (id: string, dir: -1 | 1) => {
    const idx = items.findIndex((it) => it.id === id);
    const j = idx + dir;
    if (idx < 0 || j < 0 || j >= items.length) return;
    pushHistory();
    setItems((prev) => {
      const next = [...prev];
      const at = next.findIndex((it) => it.id === id);
      if (at < 0 || at + dir < 0 || at + dir >= next.length) return prev;
      const [moved] = next.splice(at, 1);
      next.splice(at + dir, 0, moved);
      return next;
    });
  };

  /** Clip-strip duplicate: same bytes, copied trim/edits/captions, fresh id. */
  const duplicateItem = (id: string) => {
    const item = items.find((it) => it.id === id);
    if (!item || items.length >= MAX_MEDIA_ITEMS) return;
    pushHistory();
    const nid = crypto.randomUUID();
    const copy: StudioItem = { ...item, id: nid, trim: item.trim ? { ...item.trim } : null, editMeta: cloneEditMeta(item.editMeta) };
    setItems((prev) => {
      const at = prev.findIndex((it) => it.id === id);
      if (at < 0) return prev;
      const next = [...prev];
      next.splice(at + 1, 0, copy);
      return next;
    });
    const caps = captionsByItem[id];
    if (caps?.length) {
      const cloned = cloneCaptionSegments(caps);
      setCaptionsByItem((prev) => ({ ...prev, [nid]: cloned }));
    }
    const st = captionStylesByItem[id] ?? item.editMeta.captions_style;
    if (st) setCaptionStylesByItem((prev) => ({ ...prev, [nid]: { ...st } }));
    track('create.clip_duplicated', { surface: 'create', properties: { kind: item.kind } });
  };

  const handleTrimChange = (itemId: string) => (trim: TrimRangeValue, _meta?: { clamped: boolean }) => {
    pushHistory('coalesce');
    setItems((prev) => prev.map((it) => (it.id === itemId ? { ...it, trim } : it)));
    track('create.trim_set', {
      properties: { item_id: itemId, start_ms: trim.start_ms, end_ms: trim.end_ms },
    });
  };

  const handleMetaChange = (itemId: string) => (patch: Partial<EditMeta>) => {
    pushHistory('coalesce');
    setItems((prev) => prev.map((it) =>
      it.id === itemId ? { ...it, editMeta: { ...it.editMeta, ...patch } } : it,
    ));
  };

  /** TikTok-style split-at-playhead: clone the clip into two ordered halves. */
  const handleSplitItem = (itemId: string) => (atMs: number) => {
    const item = items.find((it) => it.id === itemId);
    if (!item || item.kind !== 'video' || !item.trim) return;
    if (items.length >= MAX_MEDIA_ITEMS) return;
    pushHistory();
    const [leftRange, rightRange] = splitTrim(item.trim, atMs);
    const partition = <T extends { start_ms: number; end_ms: number }>(els: T[]) =>
      partitionTimedElements(els, [leftRange, rightRange]);
    const [leftOverlays, rightOverlays] = partition(item.editMeta.textOverlays);
    const [leftStickers, rightStickers] = partition(item.editMeta.stickers || []);
    const [leftTracks, rightTracks] = partition(
      item.editMeta.audioTracks.map((t) => ({ ...t, end_ms: (t.start_ms || 0) + (t.duration_ms || 0) })),
    );
    const trackRange = (tracks: Array<AudioTrack & { end_ms: number }>): AudioTrack[] =>
      tracks.map(({ end_ms, ...rest }) => ({ ...rest, duration_ms: Math.max(0, end_ms - rest.start_ms) }));
    const [leftCaps, rightCaps] = partitionCaptionsForSplit(captionsByItem[itemId] ?? [], leftRange, rightRange);
    const style = captionStylesByItem[itemId] ?? item.editMeta.captions_style;
    const leftId = crypto.randomUUID();
    const rightId = crypto.randomUUID();
    const makeHalf = (
      id: string,
      range: typeof leftRange,
      overlays: typeof leftOverlays,
      stickers: typeof leftStickers,
      tracks: AudioTrack[],
    ): StudioItem => ({
      ...item,
      id,
      trim: range,
      editMeta: { ...item.editMeta, textOverlays: overlays, stickers, audioTracks: tracks },
    });
    setItems((prev) => {
      const next: StudioItem[] = [];
      let replaced = false;
      for (const it of prev) {
        if (it.id !== itemId) { next.push(it); continue; }
        replaced = true;
        next.push(makeHalf(leftId, leftRange, leftOverlays, leftStickers, trackRange(leftTracks)));
        next.push(makeHalf(rightId, rightRange, rightOverlays, rightStickers, trackRange(rightTracks)));
      }
      return replaced ? next : prev;
    });
    setCaptionsByItem((prev) => {
      const next = { ...prev };
      delete next[itemId];
      if (leftCaps.length) next[leftId] = leftCaps;
      if (rightCaps.length) next[rightId] = rightCaps;
      return next;
    });
    if (style) {
      setCaptionStylesByItem((prev) => {
        const next = { ...prev };
        delete next[itemId];
        next[leftId] = { ...style };
        next[rightId] = { ...style };
        return next;
      });
    } else {
      setCaptionStylesByItem((prev) => {
        if (!(itemId in prev)) return prev;
        const next = { ...prev };
        delete next[itemId];
        return next;
      });
    }
    setActiveVideoId(leftId);
    track('create.clip_split', { surface: 'create', properties: { item_id: itemId } });
  };

  // ── Per-clip auto-captions (trimmed snippet + offset re-anchor) ────────────
  const generateAutoCaptions = async (itemId: string) => {
    const item = itemsRef.current.find((it) => it.id === itemId);
    if (!item || item.kind !== 'video') return;
    autoCtrlRef.current.get(itemId)?.abort();
    const ctrl = new AbortController();
    autoCtrlRef.current.set(itemId, ctrl);
    setAutoStateByItem((prev) => ({ ...prev, [itemId]: { status: 'working' } }));
    try {
      const plan = normalizeTrimExport(item.trim?.start_ms, item.trim?.end_ms, item.durationMs);
      let mediaForTranscription = item.file;
      let offsetMs = 0;
      if (plan && shouldExportTrimmedVideo(plan)) {
        const trimmed = await getOrExportTrimmedVideo(item.file, plan.start_ms, plan.end_ms, {
          durationMs: item.durationMs,
          signal: ctrl.signal,
        });
        if (ctrl.signal.aborted) return;
        if (trimmed.trimmed) {
          mediaForTranscription = trimmed.file;
          offsetMs = plan.start_ms;
        }
      }
      const res = await feedApi.transcribeStudioMedia(mediaForTranscription, { signal: ctrl.signal });
      if (ctrl.signal.aborted) return;
      const rawSegments = res.data?.segments ?? [];
      const segments: CaptionSegment[] = rawSegments.map((s) => ({
        id: newCaptionId(),
        start_ms: s.start_ms + offsetMs,
        end_ms: s.end_ms + offsetMs,
        text: s.text,
      }));
      pushHistory();
      setCaptionsByItem((prev) => ({ ...prev, [itemId]: segments }));
      setAutoStateByItem((prev) => ({ ...prev, [itemId]: { status: 'done' } }));
      track('create.studio_captions_generated', { surface: 'create', properties: { segments: segments.length } });
    } catch (err) {
      if (err instanceof DOMException && err.name === 'AbortError') {
        setAutoStateByItem((prev) => ({ ...prev, [itemId]: { status: 'idle' } }));
        return;
      }
      const status = (err as { response?: { status?: number } })?.response?.status;
      const message = (err as { response?: { data?: { message?: string } } })?.response?.data?.message;
      setAutoStateByItem((prev) => ({
        ...prev,
        [itemId]: {
          status: 'error',
          error: status === 0 || err instanceof TypeError
            ? 'Could not reach the transcription service — try again.'
            : (message || 'Transcription failed. Try again or add captions manually.'),
        },
      }));
    } finally {
      if (autoCtrlRef.current.get(itemId) === ctrl) autoCtrlRef.current.delete(itemId);
    }
  };

  const cancelAutoCaptions = (itemId: string) => {
    autoCtrlRef.current.get(itemId)?.abort();
    autoCtrlRef.current.delete(itemId);
    setAutoStateByItem((prev) => ({ ...prev, [itemId]: { status: 'idle' } }));
  };

  const handleCaptionSegments = (itemId: string) => (next: CaptionSegment[]) => {
    pushHistory('coalesce');
    setCaptionsByItem((prev) => ({ ...prev, [itemId]: next }));
  };

  const handleCaptionStyle = (itemId: string) => (cs: CaptionsStyle) => {
    pushHistory('coalesce');
    setCaptionStylesByItem((prev) => ({ ...prev, [itemId]: cs }));
  };

  const activeStyle: CaptionsStyle | null = activeVideo
    ? (captionStylesByItem[activeVideo.id] ?? activeVideo.editMeta.captions_style ?? null)
    : null;
  const activeSegments: CaptionSegment[] = activeVideo ? (captionsByItem[activeVideo.id] ?? []) : [];

  const handleSoundSelect = (selected: Sound | null, volume: number) => {
    pushHistory();
    setSound((prev) => selected
      ? {
        id: selected.id, name: selected.name, artist: selected.artist, volume,
        ...(prev?.id === selected.id ? { startOffsetMs: prev.startOffsetMs, fadeInMs: prev.fadeInMs, fadeOutMs: prev.fadeOutMs } : {}),
      }
      : null);
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

  const canProceed =
    step === 'pick' ? items.length > 0 : step === 'post' ? items.length > 0 : true;

  const goBack = () => {
    if (stepIdx === 0) {
      exitStudio();
    } else {
      setStepIdx((i) => i - 1);
    }
  };

  const jobActive = !!jobSnap && ['queued', 'finalizing', 'uploading', 'creating'].includes(jobSnap.status);

  const exitStudio = () => {
    // A running background job owns its own lifecycle — leaving is safe.
    if (jobActive || jobSnap?.status === 'paused') {
      navigate('/feed/bud-press');
      return;
    }
    if ((items.length > 0 || body) && !window.confirm('Leave? Your draft is saved automatically.')) return;
    navigate('/feed/bud-press');
  };

  // ── Publish: enqueue a background job (finalize → upload → create) ────────
  const publish = () => {
    if (items.length === 0 || jobActive) return;
    setPublishError('');
    const spec: EnqueueSpec = {
      body,
      visibility,
      postType: items.some((i) => i.kind === 'video') ? 'short_video' : 'photo',
      commentsDisabled,
      autoCaptions,
      items: items.map((it) => ({
        id: it.id,
        kind: it.kind,
        name: it.file.name,
        file: it.file,
        durationMs: it.durationMs,
        trimStartMs: it.trim?.start_ms ?? null,
        trimEndMs: it.trim?.end_ms ?? it.durationMs ?? null,
        editMeta: it.editMeta,
        captions: cleanCaptionSegments(captionsByItem[it.id] ?? []),
        captionsStyle: captionStylesByItem[it.id] ?? it.editMeta.captions_style ?? null,
        sound: it.kind === 'video' && sound
          ? {
            id: sound.id,
            volume: sound.volume,
            ...(sound.startOffsetMs ? { start_ms: sound.startOffsetMs } : {}),
            ...(sound.fadeInMs ? { fade_in_ms: sound.fadeInMs } : {}),
            ...(sound.fadeOutMs ? { fade_out_ms: sound.fadeOutMs } : {}),
          }
          : null,
        altText: it.altText || null,
        coverOffsetSec: it.coverOffsetSec,
      })),
    };
    // Keep one draft copy until the manager clears it on post-create success.
    track('create.publish_enqueued', {
      surface: 'create',
      properties: {
        media_count: spec.items.length,
        video_count: spec.items.filter((i) => i.kind === 'video').length,
        captioned_clips: spec.items.filter((i) => (i.captions?.length ?? 0) > 0).length,
      },
    });
    setJobId(uploadManager.enqueue(spec));
  };

  const dismissJob = () => {
    if (jobId) uploadManager.dismissJob(jobId);
    setJobId(null);
    setJobSnap(null);
  };

  const tryResumeSession = (s: PersistedSession) => {
    const files = new Map<string, File>();
    for (const it of s.items) {
      const local = itemsRef.current.find((x) => x.id === it.id);
      if (!local) {
        setPublishError('Could not resume: the saved draft no longer has those clips.');
        return;
      }
      files.set(it.id, local.file);
    }
    const id = uploadManager.resumeSession(s.jobId, files);
    if (id) {
      setPublishError('');
      setJobId(id);
    } else {
      setPublishError('Could not resume that upload — it may have already finished.');
    }
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
                {it.kind === 'video' && (captionsByItem[it.id]?.length ?? 0) > 0 && (
                  <span className="absolute bottom-1.5 right-1.5 flex items-center gap-0.5 px-1 rounded bg-buddy-green/90 text-buddy-black text-[9px] font-bold">
                    <Captions size={9} /> {captionsByItem[it.id].length}
                  </span>
                )}
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

  /** Clip strip with per-clip caption badges + reorder/duplicate/delete. */
  const videoStrip = (withActions = false) => (
    <div className="space-y-1.5">
      <div className="flex gap-2 overflow-x-auto scrollbar-none pb-1">
        {videoItems.map((it, i) => {
          const count = captionsByItem[it.id]?.length ?? 0;
          return (
            <button
              key={it.id}
              onClick={() => setActiveVideoId(it.id)}
              className={`relative w-14 h-20 rounded-lg overflow-hidden shrink-0 ring-2 transition-all ${
                activeVideo?.id === it.id ? 'ring-buddy-green' : 'ring-transparent opacity-60'
              }`}
              aria-label={`Clip ${i + 1}${count ? `, ${count} captions` : ''}`}
            >
              <video src={it.previewUrl} muted playsInline preload="metadata" className="w-full h-full object-cover" />
              <span className="absolute bottom-0.5 left-0.5 px-1 rounded bg-black/60 text-white text-[9px] font-bold">
                {i + 1}
              </span>
              {count > 0 && (
                <span className="absolute top-0.5 right-0.5 flex items-center gap-0.5 px-1 rounded bg-buddy-green/90 text-buddy-black text-[9px] font-bold">
                  <Captions size={9} />{count}
                </span>
              )}
            </button>
          );
        })}
      </div>
      {withActions && activeVideo && (
        <div className="flex items-center gap-1.5">
          <span className="text-[11px] text-buddy-text-secondary mr-1">Clip {activeIdx + 1}/{videoItems.length}</span>
          <button
            onClick={() => moveItem(activeVideo.id, -1)}
            disabled={activeIdx <= 0}
            className="p-1.5 rounded-lg bg-buddy-surface-raised text-buddy-text-secondary hover:text-buddy-text-primary disabled:opacity-30"
            aria-label="Move clip earlier"
          >
            <ArrowLeft size={13} />
          </button>
          <button
            onClick={() => moveItem(activeVideo.id, 1)}
            disabled={activeIdx >= videoItems.length - 1}
            className="p-1.5 rounded-lg bg-buddy-surface-raised text-buddy-text-secondary hover:text-buddy-text-primary disabled:opacity-30"
            aria-label="Move clip later"
          >
            <ArrowRight size={13} />
          </button>
          <button
            onClick={() => duplicateItem(activeVideo.id)}
            disabled={items.length >= MAX_MEDIA_ITEMS}
            className="flex items-center gap-1 px-2 py-1.5 rounded-lg bg-buddy-surface-raised text-[11px] font-semibold text-buddy-text-secondary hover:text-buddy-text-primary disabled:opacity-30"
          >
            <Copy size={12} /> Duplicate
          </button>
          <button
            onClick={() => removeItem(activeVideo.id)}
            className="flex items-center gap-1 px-2 py-1.5 rounded-lg bg-buddy-surface-raised text-[11px] font-semibold text-buddy-text-secondary hover:text-buddy-red"
          >
            <Trash2 size={12} /> Delete
          </button>
        </div>
      )}
    </div>
  );

  const renderEdit = () =>
    activeVideo ? (
      <div className="flex-1 overflow-y-auto px-4 pb-4 space-y-3">
        {videoItems.length > 1 && videoStrip(true)}
        <EditStage
          previewUrl={activeVideo.previewUrl}
          durationMs={activeVideo.durationMs}
          trim={activeVideo.trim ?? { start_ms: 0, end_ms: activeVideo.durationMs ?? 0 }}
          editMeta={activeVideo.editMeta}
          previewCaptions={activeSegments}
          sourceFile={activeVideo.file}
          captionSegments={activeSegments}
          onCaptionSegments={handleCaptionSegments(activeVideo.id)}
          autoCaption={autoStateByItem[activeVideo.id] ?? { status: 'idle' }}
          onAutoCaptions={() => void generateAutoCaptions(activeVideo.id)}
          onCancelAutoCaptions={() => cancelAutoCaptions(activeVideo.id)}
          captionStyle={activeStyle}
          onCaptionStyleChange={handleCaptionStyle(activeVideo.id)}
          onTrimChange={handleTrimChange(activeVideo.id)}
          onSplit={handleSplitItem(activeVideo.id)}
          onMetaChange={handleMetaChange(activeVideo.id)}
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
        <div className="rounded-2xl bg-buddy-surface-raised p-3 space-y-2.5">
          <div className="flex items-center gap-2 text-xs">
            <span className="text-buddy-text-secondary w-20 shrink-0">Starts at</span>
            <input
              type="number" min={0} step={0.5}
              value={sound.startOffsetMs != null ? sound.startOffsetMs / 1000 : 0}
              onChange={(e) => {
                const v = Math.max(0, Number(e.target.value) * 1000);
                pushHistory('coalesce');
                setSound((s) => (s ? { ...s, startOffsetMs: Math.round(v) } : s));
              }}
              className="w-20 bg-buddy-surface rounded-lg px-2 py-1.5 font-mono outline-none focus:ring-1 focus:ring-buddy-green/40"
              aria-label="Sound start offset (seconds)"
            />
            <span className="text-buddy-text-secondary">s into the sound</span>
          </div>
          {([
            ['fadeInMs', 'Fade in'],
            ['fadeOutMs', 'Fade out'],
          ] as const).map(([key, label]) => (
            <div key={key} className="flex items-center gap-2 text-xs">
              <span className="text-buddy-text-secondary w-20 shrink-0">{label}</span>
              <input
                type="range" min={0} max={3000} step={100}
                value={sound[key] ?? 0}
                onChange={(e) => {
                  const v = Number(e.target.value);
                  pushHistory('coalesce');
                  setSound((s) => (s ? { ...s, [key]: v } : s));
                }}
                className="flex-1 accent-buddy-green"
                aria-label={`Sound ${label.toLowerCase()} (milliseconds)`}
              />
              <span className="font-mono w-10 text-right text-buddy-text-secondary">{((sound[key] ?? 0) / 1000).toFixed(1)}s</span>
            </div>
          ))}
          <button onClick={() => handleSoundSelect(null, 0)} className="text-xs text-buddy-text-secondary hover:text-buddy-red">
            Remove sound — back to original audio only
          </button>
        </div>
      )}
    </div>
  );

  const renderCover = () =>
    activeVideo ? (
      <div className="flex-1 overflow-y-auto px-4 pb-4 space-y-3">
        {videoItems.length > 1 && videoStrip()}
        <CoverPicker
          videoUrl={activeVideo.previewUrl}
          durationMs={activeVideo.durationMs}
          offsetSec={activeVideo.coverOffsetSec}
          onChange={(offsetSec) =>
            setItems((prev) => prev.map((it) => (it.id === activeVideo.id ? { ...it, coverOffsetSec: offsetSec } : it)))
          }
        />
      </div>
    ) : null;

  const renderCaptions = () => (
    <div className="flex-1 overflow-y-auto px-4 pb-4 space-y-3">
      {hasVideo && activeVideo && videoItems.length > 1 && videoStrip()}
      {hasVideo && activeVideo ? (
        <CaptionsPanel
          hasVideo
          autoCaptions={autoCaptions}
          onToggleAuto={(on) => {
            setAutoCaptions(on);
            track('create.captions_toggled', { surface: 'create', properties: { auto: on } });
          }}
          segments={activeSegments}
          onChangeSegments={handleCaptionSegments(activeVideo.id)}
          style={activeStyle}
          onStyleChange={handleCaptionStyle(activeVideo.id)}
          clipLabel={videoItems.length > 1 ? `Clip ${activeIdx + 1} of ${videoItems.length}` : undefined}
          autoJob={autoStateByItem[activeVideo.id] ?? { status: 'idle' }}
          onGenerateAuto={() => void generateAutoCaptions(activeVideo.id)}
          onCancelAuto={() => cancelAutoCaptions(activeVideo.id)}
        />
      ) : (
        <div className="rounded-2xl bg-buddy-surface-raised p-4 text-sm text-buddy-text-secondary">
          Add a video to use timed captions — they ship with each clip for review before posting.
        </div>
      )}
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

  const renderJobCard = () => {
    if (!jobSnap) return null;
    const s = jobSnap;
    const isActive = ['queued', 'finalizing', 'uploading', 'creating'].includes(s.status);
    const activeItem = s.items.find((it) => it.status === 'uploading' || it.status === 'finalizing')
      ?? s.items.find((it) => it.status !== 'done');
    return (
      <div className="rounded-xl bg-buddy-surface-raised px-3 py-2.5 space-y-1.5">
        {s.status === 'done' ? (
          <p className="text-xs font-semibold text-buddy-green">Published ✓ — taking you to the feed…</p>
        ) : s.status === 'failed' ? (
          <div className="space-y-1.5">
            <p className="text-xs font-semibold text-buddy-red">Upload paused with an error — nothing was lost.</p>
            {s.error && <p className="text-[11px] text-buddy-text-secondary">{s.error}</p>}
            <div className="flex gap-2">
              <button
                onClick={() => jobId && uploadManager.retryJob(jobId)}
                className="flex-1 flex items-center justify-center gap-1.5 py-2 rounded-xl bg-buddy-green text-buddy-black text-xs font-bold"
              >
                <RotateCcw size={13} /> Retry upload
              </button>
              <button
                onClick={dismissJob}
                className="px-3 py-2 rounded-xl bg-buddy-surface text-xs font-semibold text-buddy-text-secondary"
              >
                Dismiss
              </button>
            </div>
          </div>
        ) : s.status === 'canceled' ? (
          <div className="flex items-center gap-2">
            <p className="text-xs text-buddy-text-secondary flex-1">Upload canceled — your draft is saved on this device.</p>
            <button
              onClick={dismissJob}
              className="px-3 py-1.5 rounded-xl bg-buddy-surface text-xs font-semibold text-buddy-text-secondary"
            >
              Dismiss
            </button>
          </div>
        ) : (
          <>
            <div className="flex items-center justify-between text-xs">
              <span className="font-semibold text-buddy-text-primary truncate max-w-[55%]">
                {s.status === 'creating'
                  ? 'Creating your post…'
                  : s.status === 'finalizing'
                    ? 'Trimming clips…'
                    : activeItem
                      ? `Uploading ${activeItem.name}`
                      : 'Starting upload…'}
              </span>
              <span className="font-bold text-buddy-green tabular-nums">{s.overallPct}%</span>
            </div>
            <div className="h-1.5 rounded-full bg-buddy-surface overflow-hidden">
              <div className="h-full bg-buddy-green transition-all" style={{ width: `${s.overallPct}%` }} />
            </div>
            <div className="flex items-center justify-between text-[10px] text-buddy-text-secondary">
              <span>
                {s.items.filter((it) => it.status === 'done').length}/{s.items.length} clips ·{' '}
                {formatBytes(s.loadedBytes)} / {formatBytes(s.totalBytes)}
              </span>
              <span className="flex gap-2">
                {s.status === 'paused' ? (
                  <button
                    onClick={() => jobId && uploadManager.resumeJob(jobId)}
                    className="flex items-center gap-1 font-semibold text-buddy-green"
                  >
                    <Play size={11} /> Resume
                  </button>
                ) : (
                  isActive && (
                    <button
                      onClick={() => jobId && uploadManager.pauseJob(jobId)}
                      className="flex items-center gap-1 font-semibold hover:text-buddy-text-primary"
                    >
                      <Pause size={11} /> Pause
                    </button>
                  )
                )}
                <button
                  onClick={() => jobId && uploadManager.cancelJob(jobId)}
                  className="font-semibold hover:text-buddy-red"
                >
                  Cancel
                </button>
              </span>
            </div>
            {isActive && (
              <p className="text-[10px] text-buddy-text-secondary">
                Safe to leave — the upload continues in the background while this tab stays open.
              </p>
            )}
          </>
        )}
      </div>
    );
  };

  const stepIcons: Record<StepKey, React.ReactNode> = {
    pick: <Plus size={13} />,
    edit: <Scissors size={13} />,
    sound: <Music size={13} />,
    cover: <ImageIcon size={13} />,
    captions: <Type size={13} />,
    post: <Users size={13} />,
  };

  const resumableSessions = sessions.filter((sn) => sn.jobId !== jobId);

  return (
    <div className="fixed inset-0 z-50 bg-buddy-black flex flex-col sm:mx-auto sm:w-full sm:max-w-[520px] sm:border-x sm:border-buddy-surface">
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
        <button
          onClick={undo}
          disabled={!historyRef.current.canUndo}
          className="p-2 rounded-full text-buddy-text-secondary hover:text-buddy-text-primary disabled:opacity-30"
          aria-label="Undo edit"
          title="Undo"
        >
          <Undo2 size={18} />
        </button>
        <button
          onClick={redo}
          disabled={!historyRef.current.canRedo}
          className="p-2 rounded-full text-buddy-text-secondary hover:text-buddy-text-primary disabled:opacity-30"
          aria-label="Redo edit"
          title="Redo"
        >
          <Redo2 size={18} />
        </button>
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
        {storageFull && (
          <p className="text-xs text-buddy-gold bg-buddy-gold/10 rounded-xl px-3 py-2">
            Device storage is full — your work is kept in memory for this session. Free up space to keep autosave.
          </p>
        )}
        {publishError && (
          <p className="text-sm text-buddy-red bg-buddy-red/10 rounded-xl px-3 py-2">{publishError}</p>
        )}
        {renderJobCard()}
        {resumableSessions.length > 0 && !jobSnap && (
          <div className="rounded-xl bg-buddy-surface-raised px-3 py-2.5 space-y-1.5">
            <p className="text-xs font-semibold">Interrupted uploads</p>
            {resumableSessions.slice(0, 3).map((sn) => (
              <div key={sn.jobId} className="flex items-center gap-2 text-[11px] text-buddy-text-secondary">
                <span className="flex-1 truncate">
                  {sn.items.length} clips · {sn.status}
                  {sn.error ? ` — ${sn.error}` : ''}
                </span>
                <button
                  onClick={() => tryResumeSession(sn)}
                  className="px-2.5 py-1 rounded-lg bg-buddy-green/15 text-buddy-green font-semibold"
                >
                  Resume
                </button>
              </div>
            ))}
          </div>
        )}
        <div className="flex items-center gap-3">
          {stepIdx > 0 && !jobActive && (
            <button
              onClick={() => setStepIdx((i) => i - 1)}
              className="px-4 py-2.5 rounded-xl bg-buddy-surface-raised text-sm font-semibold hover:bg-buddy-surface transition-colors"
            >
              Back
            </button>
          )}
          <button
            onClick={() => (isLastStep ? publish() : setStepIdx((i) => i + 1))}
            disabled={!canProceed || jobActive}
            className="flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl bg-buddy-green text-buddy-black text-sm font-bold disabled:opacity-40 disabled:cursor-not-allowed hover:bg-buddy-green/90 transition-colors"
          >
            {jobActive && <Loader2 size={15} className="animate-spin" />}
            {isLastStep ? (jobActive ? 'Uploading in background…' : 'Publish') : 'Next'}
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
