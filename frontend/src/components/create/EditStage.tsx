/**
 * EditStage — TikTok/IG-style editor surface.
 *
 * One shared preview that plays WITH audio, plus tabbed tools:
 *   Trim (split) · Text · Stickers · Filters · Adjust · Speed · Audio
 * Tools mutate a per-video EditMeta object; the preview reflects
 * filter/adjust (CSS), speed (rate), aspect crop and the audio mixer
 * (original chain + added sound/voiceover tracks via Web Audio) live.
 */
import { useEffect, useRef, useState } from 'react';
import {
  Captions, AudioLines, Loader2, Mic, Pause, Play, Plus, Scissors, SlidersHorizontal,
  Smile, Sparkles, TextCursorInput, Trash2, Volume2, VolumeX, Wand2, X,
} from 'lucide-react';
import {
  clampTrim, moveThumb,
  EDIT_FILTERS, SPEED_OPTIONS, TEXT_COLORS, TEXT_COLOR_VALUES,
  FONT_OPTIONS, TEXT_ANIMATIONS, AUDIO_TRACK_EFFECTS, TEXT_EFFECTS,
  CAPTION_PRESETS,
  filterCss, filterCssAt, adjustCss, fontFamilyCss, textEffectCss,
  type AudioTrack, type CaptionsStyle, type EditMeta, type StickerOverlay, type TextOverlay, type TrimRangeValue,
} from '@/lib/createStudio';
import { StudioAudioMixer, TrackSyncer } from '@/lib/audioMixer';
import { feedApi } from '@/api/feed';
import { uploadToCloudinary, trimVideoFile } from '@/lib/uploader';
import { sanitizeEditMeta, normalizeTrimExport, shouldExportTrimmedVideo } from '@/lib/createStudio';
import { SoundPicker } from '@/components/create/SoundPicker';
import { CreativeLayer } from '@/components/create/CreativeLayer';
import { track } from '@/lib/analytics';
import type { Sound } from '@/api/feed';

const TOOL_TABS = [
  { key: 'trim', label: 'Trim', icon: Scissors },
  { key: 'text', label: 'Text', icon: TextCursorInput },
  { key: 'stickers', label: 'Sticker', icon: Smile },
  { key: 'filters', label: 'Filter', icon: Wand2 },
  { key: 'adjust', label: 'Adjust', icon: SlidersHorizontal },
  { key: 'speedx', label: 'Speed', icon: SlidersHorizontal },
  { key: 'audio', label: 'Audio', icon: AudioLines },
  { key: 'captions', label: 'CC', icon: Captions },
] as const;

type ToolKey = typeof TOOL_TABS[number]['key'];

export interface EditStageProps {
  previewUrl: string;
  durationMs: number | null;
  trim: TrimRangeValue;
  editMeta: EditMeta;
  /** Caption segments (manual or whisper) rendered live on the preview. */
  previewCaptions?: Array<{ start_ms: number; end_ms: number; text: string }> | null;
  /** Original picked file — powers in-studio auto-caption generation. */
  sourceFile?: File | null;
  onCaptionSegments?: (segments: CaptionSegment[]) => void;
  captionSegments?: CaptionSegment[];
  /** External auto-caption run state (driven by the studio for per-clip jobs). */
  autoCaption?: { status: 'idle' | 'working' | 'error' | 'done'; error?: string | null } | null;
  /** External auto-caption actions; when absent the stage transcribes itself. */
  onAutoCaptions?: () => void;
  onCancelAutoCaptions?: () => void;
  /** Per-clip caption style (preset/size); edited here, stored by the studio. */
  captionStyle?: CaptionsStyle | null;
  onCaptionStyleChange?: (style: CaptionsStyle) => void;
  /** Overlay safe-area guides on the preview (auto-shown in the CC tool). */
  showSafeArea?: boolean;
  onTrimChange: (trim: TrimRangeValue) => void;
  onMetaChange: (patch: Partial<EditMeta>) => void;
  onDuration?: (ms: number) => void;
  /** TikTok-style split: parent clones the item into two half clips. */
  onSplit?: (atMs: number) => void;
}

export interface CaptionSegment {
  id: string;
  start_ms: number;
  end_ms: number;
  text: string;
}

const fmt = (ms: number): string => {
  const total = Math.max(0, ms) / 1000;
  const m = Math.floor(total / 60);
  const s = total - m * 60;
  return `${m}:${s < 10 ? '0' : ''}${s.toFixed(1)}`;
};

const ASPECT_RATIOS: Record<string, number | null> = { '9:16': 9 / 16, '1:1': 1, '4:5': 4 / 5, '16:9': 16 / 9 };

const QUICK_EMOJI = ['🔥', '😂', '💪', '😍', '🥶', '💀', '🎉', '👀', '🤯', '🏋️', '🥇', '❤️'];

export function EditStage({
  previewUrl, durationMs, trim, editMeta, previewCaptions, sourceFile, captionSegments, onCaptionSegments,
  autoCaption, onAutoCaptions, onCancelAutoCaptions, captionStyle, onCaptionStyleChange, showSafeArea,
  onTrimChange, onMetaChange, onDuration, onSplit,
}: EditStageProps) {
  const videoRef = useRef<HTMLVideoElement>(null);
  const trackRef = useRef<HTMLDivElement>(null);
  const timelineRef = useRef<HTMLDivElement>(null);
  const stageRef = useRef<HTMLDivElement>(null);
  const mixerRef = useRef<StudioAudioMixer>(new StudioAudioMixer());
  const trackSyncRef = useRef<TrackSyncer>(new TrackSyncer());
  const recorderRef = useRef<MediaRecorder | null>(null);
  const dragRef = useRef<'start' | 'end' | null>(null);
  const overlayDrag = useRef<
    | { kind: 'text'; id: string; startX: number; startY: number; ox: number; oy: number }
    | { kind: 'sticker'; id: string; startX: number; startY: number; ox: number; oy: number }
    | null
  >(null);

  const [tool, setTool] = useState<ToolKey>('trim');
  const [playing, setPlaying] = useState(false);
  const [muted, setMuted] = useState(false);
  const [probedMs, setProbedMs] = useState<number | null>(null);
  const [currentMs, setCurrentMs] = useState(0);
  const [editingOverlayId, setEditingOverlayId] = useState<string | null>(null);
  const [dragging, setDragging] = useState(false);
  const [soundPickerOpen, setSoundPickerOpen] = useState(false);
  const [recording, setRecording] = useState(false);
  const [recordBusy, setRecordBusy] = useState(false);
  const [recordError, setRecordError] = useState<string | null>(null);
  const [transcribing, setTranscribing] = useState(false);
  const [transcribeError, setTranscribeError] = useState<string | null>(null);
  const [transcribeDone, setTranscribeDone] = useState(false);
  const transcribeCtrlRef = useRef<AbortController | null>(null);

  // Per-clip caption style: external studio state wins, editMeta is fallback.
  const capStyle: CaptionsStyle = captionStyle ?? editMeta.captions_style ?? { preset: 'classic' };
  const setCapStyle = (next: CaptionsStyle) => {
    if (onCaptionStyleChange) onCaptionStyleChange(next);
    else onMetaChange({ captions_style: next });
  };

  const duration = durationMs ?? probedMs ?? 0;
  const speed = editMeta.speed || 1;

  // ── Loop playback inside trim bounds + keep added tracks synced ───────────
  useEffect(() => {
    const el = videoRef.current;
    if (!el || duration <= 0) return;
    const onTime = () => {
      const t = el.currentTime * 1000;
      setCurrentMs(t);
      trackSyncRef.current.syncAll(t, playing && !muted);
      if (t >= trim.end_ms - 30 || t < trim.start_ms - 250) {
        el.currentTime = trim.start_ms / 1000;
      }
    };
    el.addEventListener('timeupdate', onTime);
    if (el.currentTime * 1000 < trim.start_ms - 250 || el.currentTime * 1000 > trim.end_ms) {
      el.currentTime = trim.start_ms / 1000;
    }
    return () => el.removeEventListener('timeupdate', onTime);
  }, [trim.start_ms, trim.end_ms, duration, playing, muted]);

  // Pause added tracks when playback stops.
  useEffect(() => {
    if (!playing) trackSyncRef.current.syncAll(-1, false);
  }, [playing]);
  useEffect(() => () => trackSyncRef.current.dispose(), []);

  // Sync rate + audio graph with the meta.
  useEffect(() => {
    const el = videoRef.current;
    if (!el) return;
    el.playbackRate = speed;
    mixerRef.current.attach(el);
    mixerRef.current.update({ volume: editMeta.volume ?? 100, enhance: !!editMeta.enhance });
    trackSyncRef.current.useSharedContext(mixerRef.current.audioContext);
  }, [speed, editMeta.volume, editMeta.enhance, previewUrl]);

  // Added tracks lifecycle against editMeta.audioTracks.
  useEffect(() => {
    trackSyncRef.current.setTracks(editMeta.audioTracks.map((t) => ({
      id: t.id,
      url: t.url || '',
      volume: t.volume ?? 100,
      start_ms: t.start_ms ?? 0,
      duration_ms: t.duration_ms ?? undefined,
      effect: t.effect ?? 'none',
      fade_in_ms: t.fade_in_ms ?? undefined,
      fade_out_ms: t.fade_out_ms ?? undefined,
      ducking: t.ducking ?? undefined,
    })).filter((t) => !!t.url));
  }, [editMeta.audioTracks]);

  const togglePlay = () => {
    const el = videoRef.current;
    if (!el) return;
    mixerRef.current.resume();
    if (recording) stopRecording();
    if (el.paused) {
      el.currentTime = trim.start_ms / 1000;
      void el.play().then(() => setPlaying(true)).catch(() => setPlaying(false));
    } else { el.pause(); setPlaying(false); }
  };

  const posMsFrom = (clientX: number): number => {
    const rect = trackRef.current?.getBoundingClientRect();
    if (!rect || rect.width === 0) return 0;
    return Math.min(1, Math.max(0, (clientX - rect.left) / rect.width)) * duration;
  };
  const pct = (ms: number): string => (duration > 0 ? `${(ms / duration) * 100}%` : '0%');

  const commitThumb = (which: 'start' | 'end', posMs: number) => {
    if (duration <= 0) return;
    const next = moveThumb(which, posMs, trim, duration);
    onTrimChange({ start_ms: next.start_ms, end_ms: next.end_ms });
  };

  const onTrimTrackDown = (e: React.PointerEvent) => {
    e.preventDefault();
    mixerRef.current.resume();
    setDragging(false);
    const t = posMsFrom(e.clientX);
    const which: 'start' | 'end' =
      Math.abs(t - trim.start_ms) <= Math.abs(t - trim.end_ms) ? 'start' : 'end';
    dragRef.current = which;
    (e.currentTarget as HTMLElement).setPointerCapture(e.pointerId);
    commitThumb(which, t);
  };

  const seekTo = (clientX: number) => {
    const el = videoRef.current;
    if (!el || duration <= 0) return;
    const ms = Math.min(Math.max(0, posMsFrom(clientX)), duration);
    el.currentTime = ms / 1000;
    setCurrentMs(ms);
  };

  const seekTimeline = (clientX: number) => {
    const rect = timelineRef.current?.getBoundingClientRect();
    const el = videoRef.current;
    if (!rect || !el || duration <= 0) return;
    const ms = Math.min(duration, Math.max(0, ((clientX - rect.left) / rect.width) * duration));
    el.currentTime = ms / 1000;
    setCurrentMs(ms);
  };

  const timelinePct = (ms: number) => duration > 0 ? `${Math.max(0, Math.min(100, (ms / duration) * 100))}%` : '0%';
  const timelineWidth = (start: number, end: number) => duration > 0
    ? `${Math.max(0.8, Math.min(100, ((end - start) / duration) * 100))}%`
    : '0%';

  // ── Text overlays ────────────────────────────────────────────────────────
  const addOverlay = () => {
    mixerRef.current.resume();
    const start = Math.round(Math.max(trim.start_ms, Math.min(currentMs || trim.start_ms, trim.end_ms)));
    const ov: TextOverlay = {
      id: crypto.randomUUID(),
      text: 'New text',
      start_ms: start,
      end_ms: Math.min(trim.end_ms, start + 1500),
      x: 50,
      y: 78,
      size: 1,
      color: 'white',
      font: 'classic',
      bg: 'none',
      animation: 'none',
    };
    onMetaChange({ textOverlays: [...editMeta.textOverlays, ov] });
    setEditingOverlayId(ov.id);
  };

  const updateOverlay = (id: string, patch: Partial<TextOverlay>) =>
    onMetaChange({ textOverlays: editMeta.textOverlays.map((o) => (o.id === id ? { ...o, ...patch } : o)) });

  const removeOverlay = (id: string) => {
    onMetaChange({ textOverlays: editMeta.textOverlays.filter((o) => o.id !== id) });
    if (editingOverlayId === id) setEditingOverlayId(null);
  };

  // ── Stickers ─────────────────────────────────────────────────────────────
  const addSticker = (partial: Partial<StickerOverlay> & { content: string; kind: StickerOverlay['kind'] }) => {
    const start = Math.round(Math.max(trim.start_ms, Math.min(currentMs || trim.start_ms, trim.end_ms)));
    const st: StickerOverlay = {
      id: crypto.randomUUID(),
      x: 50, y: 40,
      start_ms: start,
      end_ms: partial.end_ms ?? Math.min(trim.end_ms, start + 2000),
      scale: 1,
      ...partial,
    };
    onMetaChange({ stickers: [...(editMeta.stickers || []), st] });
  };

  const updateSticker = (id: string, patch: Partial<StickerOverlay>) =>
    onMetaChange({ stickers: (editMeta.stickers || []).map((s) => (s.id === id ? { ...s, ...patch } : s)) });

  const removeSticker = (id: string) =>
    onMetaChange({ stickers: (editMeta.stickers || []).filter((s) => s.id !== id) });

  // Drag overlays / stickers on the preview (editor only): each move
  // recomputes the % position relative to the stage, so no delta math.
  const assignOverlayDrag = (kind: 'text' | 'sticker', id: string) => {
    mixerRef.current.resume();
    setEditingOverlayId(kind === 'text' ? id : null);
    overlayDrag.current = { kind, id, startX: 0, startY: 0, ox: 0, oy: 0 };
  };

  const onStageDragPointerMove = (e: PointerEvent) => {
    const drag = overlayDrag.current as { kind: 'text' | 'sticker'; id: string } | null;
    const rect = stageRef.current?.getBoundingClientRect();
    if (!drag || !rect) return;
    const nx = Math.min(96, Math.max(4, ((e.clientX - rect.left) / rect.width) * 100));
    const ny = Math.min(96, Math.max(6, ((e.clientY - rect.top) / rect.height) * 100));
    if (drag.kind === 'text') updateOverlay(drag.id, { x: nx, y: ny });
    else updateSticker(drag.id, { x: nx, y: ny });
  };

  const onStageDragPointerUp = () => { overlayDrag.current = null; };

  // ── Voiceover recording ──────────────────────────────────────────────────
  const startRecording = async () => {
    setRecordError(null);
    const el = videoRef.current;
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      const recorder = new MediaRecorder(stream);
      recorderRef.current = recorder;
      const chunks: BlobPart[] = [];
      recorder.ondataavailable = (e) => { if (e.data.size > 0) chunks.push(e.data); };
      recorder.onstop = async () => {
        stream.getTracks().forEach((t) => t.stop());
        const blob = new Blob(chunks, { type: 'audio/webm' });
        setRecordBusy(true);
        try {
          const file = new File([blob], `voiceover-${Date.now()}.webm`, { type: 'audio/webm' });
          const up = await uploadToCloudinary(file);
          addSavedTrack({ id: crypto.randomUUID(), kind: 'voiceover', url: up.url, label: 'Voiceover', volume: 100, start_ms: trim.start_ms, duration_ms: undefined });
        } catch {
          setRecordError('Could not upload the voiceover — check your connection.');
        } finally {
          setRecordBusy(false);
          setRecording(false);
        }
      };
      recorder.start();
      setRecording(true);
      // Play the clip underneath so the take lands in time.
      if (el) {
        el.currentTime = trim.start_ms / 1000;
        void el.play().then(() => setPlaying(true)).catch(() => setPlaying(false));
      }
    } catch {
      setRecordError('Microphone access is required to record a voiceover.');
    }
  };

  const stopRecording = () => {
    if (recorderRef.current?.state === 'recording') recorderRef.current.stop();
  };

  // ── Saved sound track selection via SoundPicker ──────────────────────────
  const addSavedTrack = (track: AudioTrack) =>
    onMetaChange({ audioTracks: [...editMeta.audioTracks, track] });

  const addSoundTrack = (sound: Sound, volume: number) => {
    const start = Math.round(Math.max(trim.start_ms, Math.min(currentMs || trim.start_ms, trim.end_ms)));
    addSavedTrack({
      id: crypto.randomUUID(), kind: 'sound',
      sound_id: sound.id, url: sound.audio_url,
      label: `${sound.name} · ${sound.artist}`, volume, start_ms: start, duration_ms: undefined,
    });
  };
  const onSoundPickerSelect = (sound: Sound | null, volume: number) => {
    setSoundPickerOpen(false);
    if (sound && 'audio_url' in sound && sound.audio_url) addSoundTrack(sound, volume);
  };

  const removeAudioTrack = (id: string) =>
    onMetaChange({ audioTracks: editMeta.audioTracks.filter((t) => t.id !== id) });
  const updateAudioTrack = (id: string, patch: Partial<AudioTrack>) =>
    onMetaChange({ audioTracks: editMeta.audioTracks.map((t) => (t.id === id ? { ...t, ...patch } : t)) });

  // ── In-studio auto-captions (whisper) ────────────────────────────────────
  // When the studio drives per-clip jobs (onAutoCaptions), the CC tool is a
  // thin state machine over that job; otherwise the stage transcribes the
  // trimmed snippet itself with cancel support.
  const cancelTranscribe = () => {
    transcribeCtrlRef.current?.abort();
  };

  const generateCaptions = async () => {
    setTranscribeError(null);
    setTranscribeDone(false);
    if (!sourceFile) {
      setTranscribeError('The clip is not available for transcription.');
      return;
    }
    const ctrl = new AbortController();
    transcribeCtrlRef.current?.abort();
    transcribeCtrlRef.current = ctrl;
    setTranscribing(true);
    try {
      // Transcribe the trimmed snippet, not the whole original: smaller upload
      // and timestamps that match the edit. Re-anchor to absolute preview time.
      const plan = normalizeTrimExport(trim.start_ms, trim.end_ms, duration);
      let mediaForTranscription = sourceFile;
      let offsetMs = 0;
      if (plan && shouldExportTrimmedVideo(plan)) {
        const trimmed = await trimVideoFile(sourceFile, plan.start_ms, plan.end_ms, { durationMs: duration, signal: ctrl.signal });
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
        id: crypto.randomUUID(),
        start_ms: s.start_ms + offsetMs,
        end_ms: s.end_ms + offsetMs,
        text: s.text,
      }));
      onCaptionSegments?.(segments);
      setTranscribeDone(segments.length > 0);
      track('create.studio_captions_generated', { properties: { segments: segments.length } });
      // Jump the preview to the first caption so users see it immediately.
      const first = segments[0];
      if (first && videoRef.current) {
        videoRef.current.currentTime = first.start_ms / 1000;
        setCurrentMs(first.start_ms);
      }
    } catch (err) {
      if ((err instanceof DOMException && err.name === 'AbortError') || ctrl.signal.aborted) return;
      const status = (err as { response?: { status?: number } })?.response?.status;
      const message = (err as { response?: { data?: { message?: string } } })?.response?.data?.message;
      setTranscribeError(
        status === 0 || err instanceof TypeError
          ? 'Could not reach the transcription service — try again.'
          : (message || 'Transcription failed. Try again or add captions manually.'),
      );
    } finally {
      if (transcribeCtrlRef.current === ctrl) transcribeCtrlRef.current = null;
      setTranscribing(false);
    }
  };

  useEffect(() => () => transcribeCtrlRef.current?.abort(), []);

  // Effective auto-caption UI state: external per-clip job wins when wired.
  const autoBusy = autoCaption ? autoCaption.status === 'working' : transcribing;
  const autoError = autoCaption
    ? (autoCaption.status === 'error' ? (autoCaption.error ?? 'Transcription failed. Try again.') : null)
    : transcribeError;
  const autoDone = autoCaption ? autoCaption.status === 'done' : transcribeDone;
  const autoFailed = autoCaption ? autoCaption.status === 'error' : !!transcribeError;
  const handleAutoClick = () => {
    if (onAutoCaptions) onAutoCaptions();
    else void generateCaptions();
  };
  const handleAutoCancel = () => {
    if (onCancelAutoCaptions) onCancelAutoCaptions();
    else cancelTranscribe();
  };

  const active = editMeta.filter ?? 'normal';
  const layerMeta = sanitizeEditMeta(editMeta);
  const aspectRatio = ASPECT_RATIOS[editMeta.aspect as keyof typeof ASPECT_RATIOS] ?? null;
  const showPreviewDrag = tool === 'text' || tool === 'stickers';
  const activeCaptions = previewCaptions?.filter(
    (c) => currentMs >= c.start_ms - 40 && currentMs <= c.end_ms + 40,
  ) ?? [];

  return (
    <div className="space-y-3">
      {/* ── Preview stage — plays with audio ── */}
      <div
        ref={stageRef}
        className="relative rounded-2xl overflow-hidden bg-black max-h-[42vh] mx-auto w-auto"
        style={{ aspectRatio: aspectRatio ? `${aspectRatio}` : '9/16' }}
      >
        <video
          ref={videoRef}
          src={previewUrl}
          muted={muted}
          loop
          playsInline
          preload="auto"
          onLoadedMetadata={(e) => {
            const d = e.currentTarget.duration;
            if (Number.isFinite(d) && d > 0) {
              const ms = Math.round(d * 1000);
              setProbedMs(ms);
              onDuration?.(ms);
              if (trim.end_ms <= 0) {
                const init = clampTrim(trim.start_ms, ms, ms);
                onTrimChange({ start_ms: init.start_ms, end_ms: init.end_ms });
              }
            }
          }}
          style={{
            filter: [filterCssAt(editMeta.filter, editMeta.filter_strength ?? 100), adjustCss(editMeta.adjust)].filter(Boolean).join(' '),
            objectFit: aspectRatio ? 'cover' : 'contain',
            objectPosition: `50% ${(editMeta.focus_y ?? 50)}%`,
          }}
          className="absolute inset-0 w-full h-full"
        />
        {/* Vignette */}
        {!!editMeta.adjust?.vignette && (
          <div
            className="absolute inset-0 pointer-events-none"
            style={{ background: 'radial-gradient(circle, transparent 55%, rgba(0,0,0,0.85) 150%)', opacity: Math.min(1, (editMeta.adjust.vignette || 0) / 100) }}
          />
        )}
        <CreativeLayer
          meta={layerMeta}
          timeMs={currentMs}
          activeCaption={activeCaptions.length ? { text: activeCaptions[0].text } : null}
          interactive={showPreviewDrag}
          selectedId={editingOverlayId}
          onOverlayPointerDown={(id, e) => { e.preventDefault(); assignOverlayDrag('text', id); }}
          onStickerPointerDown={(id, e) => { e.preventDefault(); assignOverlayDrag('sticker', id); }}
        >
          {/* Recording indicator */}
          {recording && (
            <span className="absolute top-2 left-1/2 -translate-x-1/2 flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-buddy-red/90 text-white text-[11px] font-semibold z-20">
              <span className="w-2 h-2 rounded-full bg-white animate-pulse" /> REC
            </span>
          )}
        </CreativeLayer>
        <div
          className={showPreviewDrag ? 'absolute inset-0' : 'pointer-events-none absolute inset-0'}
          onPointerMove={(e) => onStageDragPointerMove(e.nativeEvent)}
          onPointerUp={onStageDragPointerUp}
        />
        {/* Safe-area guides: keep captions/text inside the dashed frame so
            player chrome and notches never cover them. */}
        {(tool === 'captions' || showSafeArea) && (
          <div className="absolute inset-0 pointer-events-none z-10" aria-hidden>
            <div className="absolute inset-x-3 top-[8%] bottom-[16%] rounded-lg border border-dashed border-white/50" />
            <span className="absolute top-[8%] left-1/2 -translate-x-1/2 -translate-y-full pb-0.5 text-[9px] font-semibold uppercase tracking-wider text-white/60">
              Safe area
            </span>
          </div>
        )}
        <div className="absolute top-2 right-2 flex items-center gap-1.5 z-20">
          <button
            onClick={() => setMuted((m) => !m)}
            className="p-1.5 rounded-full bg-black/60 text-white hover:bg-black/75"
            aria-label={muted ? 'Unmute preview' : 'Mute preview'}
          >
            {muted ? <VolumeX size={15} /> : <Volume2 size={15} />}
          </button>
          <button
            onClick={togglePlay}
            className="p-1.5 rounded-full bg-black/60 text-white hover:bg-black/75"
            aria-label={playing ? 'Pause preview' : 'Play preview'}
          >
            {playing ? <Pause size={15} /> : <Play size={15} />}
          </button>
        </div>
        <div className="absolute top-2 left-2 z-20 px-2 py-1 rounded-full bg-black/50 text-white text-[11px] font-medium">
          {playing ? `▶ ${fmt(currentMs)}` : `${fmt(duration)} clip`}
        </div>
      </div>

      {/* ── Seek / trim track ── */}
      <div
        ref={trackRef}
        onPointerDown={onTrimTrackDown}
        onPointerMove={(e) => { if (dragRef.current) { setDragging(true); commitThumb(dragRef.current, posMsFrom(e.clientX)); } else if (e.buttons === 1) { seekTo(e.clientX); } }}
        onPointerUp={() => { dragRef.current = null; setTimeout(() => setDragging(false), 50); }}
        onPointerCancel={() => { dragRef.current = null; setTimeout(() => setDragging(false), 60); }}
        className="relative h-10 select-none touch-none cursor-pointer"
        role="group"
        aria-label="Trim range and playback position"
      >
        <div className="absolute top-1/2 -translate-y-1/2 left-0 right-0 h-1.5 rounded-full bg-buddy-surface-raised" />
        <div
          className="absolute top-1/2 -translate-y-1/2 h-1.5 rounded-full bg-buddy-green"
          style={{ left: pct(trim.start_ms), width: pct(trim.end_ms - trim.start_ms) }}
        />
        {/* Playhead */}
        <div
          className="absolute top-1/2 -translate-y-1/2 -translate-x-1/2 w-2.5 h-2.5 rounded-full bg-white shadow"
          style={{ left: pct(Math.min(currentMs, duration)) }}
        />
        {(['start', 'end'] as const).map((which) => (
          <div
            key={which}
            onPointerDown={(e) => { e.stopPropagation(); mixerRef.current.resume(); (e.currentTarget as HTMLElement).setPointerCapture(e.pointerId); dragRef.current = which; }}
            onPointerUp={(e) => { (e.currentTarget as HTMLElement).releasePointerCapture(e.pointerId); dragRef.current = null; setDragging(false); }}
            className="absolute top-1/2 -translate-y-1/2 -translate-x-1/2 w-5 h-9 rounded-lg bg-buddy-green shadow-lg cursor-grab active:cursor-grabbing flex items-center justify-center touch-none z-10"
            style={{ left: pct(which === 'start' ? trim.start_ms : trim.end_ms) }}
            role="slider"
            aria-label={which === 'start' ? 'Trim start' : 'Trim end'}
            aria-valuemin={0}
            aria-valuemax={Math.round(duration)}
            aria-valuenow={Math.round(which === 'start' ? trim.start_ms : trim.end_ms)}
            tabIndex={0}
          >
            <div className="w-0.5 h-4 bg-buddy-black/60 rounded-full" />
          </div>
        ))}
      </div>
      {!dragging && tool === 'trim' && (
        <div className="flex items-center justify-between text-[11px] font-mono text-buddy-text-secondary">
          <span>IN {fmt(trim.start_ms)}</span>
          <span className="text-buddy-text-primary font-semibold">
            {fmt(Math.max(0, trim.end_ms - trim.start_ms))} / {fmt(duration)}
          </span>
          <span>OUT {fmt(trim.end_ms)}</span>
        </div>
      )}

      {/* ── Tool tabs (TikTok-style row, scrolls on narrow phones) ── */}
      <div className="flex justify-start sm:justify-center gap-1 overflow-x-auto scrollbar-none flex-nowrap -mx-1 px-1">
        {TOOL_TABS.map(({ key, label, icon: Icon }) => (
          <button
            key={key}
            onClick={() => setTool(key)}
            className={`shrink-0 flex flex-col items-center gap-0.5 px-2.5 py-1.5 rounded-xl text-[10px] font-medium transition-colors ${
              tool === key ? 'bg-buddy-green/15 text-buddy-green' : 'text-buddy-text-secondary hover:text-buddy-text-primary'
            }`}
          >
            <Icon size={16} /> {label}
          </button>
        ))}
      </div>

      {/* ── Current position readout ── */}
      {tool !== 'trim' && (
        <div className="flex items-center justify-center gap-3 text-[11px] font-mono text-buddy-text-secondary">
          <span>▶ {fmt(currentMs)}</span>
          <span className="text-buddy-green font-semibold">{fmt(Math.max(0, trim.end_ms - trim.start_ms))} selected</span>
        </div>
      )}

      {/* ── Trim tool: split at playhead ── */}
      {tool === 'trim' && onSplit && (
        <button
          onClick={() => {
            const at = Math.min(Math.max(currentMs || trim.start_ms, trim.start_ms + 500), trim.end_ms - 500);
            onSplit(at);
          }}
          className="w-full flex items-center justify-center gap-2 py-2.5 rounded-xl bg-buddy-green/15 text-buddy-green text-sm font-semibold hover:bg-buddy-green/20"
        >
          <Scissors size={15} /> Split at playhead
        </button>
      )}

      {/* ── Text tool ── */}
      {tool === 'text' && (
        <div className="space-y-2">
          <button
            onClick={addOverlay}
            className="w-full flex items-center justify-center gap-2 py-2.5 rounded-xl bg-buddy-green/15 text-buddy-green text-sm font-semibold hover:bg-buddy-green/20"
          >
            <Plus size={15} /> Add text at playhead ({fmt(currentMs || trim.start_ms)})
          </button>
          <div className="rounded-xl border border-buddy-surface-raised bg-buddy-surface-raised/60 p-2.5 space-y-2">
            <div className="flex items-center justify-between">
              <span className="text-[10px] uppercase tracking-wide text-buddy-text-secondary font-semibold">Timeline</span>
              <span className="text-[10px] font-mono text-buddy-text-secondary">click a lane to seek</span>
            </div>
            <div
              ref={timelineRef}
              onPointerDown={(e) => seekTimeline(e.clientX)}
              className="relative h-20 rounded-lg bg-buddy-black/50 overflow-hidden cursor-crosshair touch-none"
              aria-label="Creative timeline"
            >
              <div className="absolute inset-y-0 w-px bg-white/80 z-20" style={{ left: timelinePct(currentMs) }} />
              <TimelineLane label="TEXT" color="bg-buddy-green" items={editMeta.textOverlays} timelinePct={timelinePct} timelineWidth={timelineWidth} />
              <TimelineLane label="STICKERS" color="bg-buddy-gold" items={editMeta.stickers || []} timelinePct={timelinePct} timelineWidth={timelineWidth} top="25%" />
              <TimelineLane label="CC" color="bg-buddy-electric" items={previewCaptions || []} timelinePct={timelinePct} timelineWidth={timelineWidth} top="50%" />
              <TimelineLane label="AUDIO" color="bg-buddy-orange" items={editMeta.audioTracks.map((track) => ({
                start_ms: track.start_ms,
                end_ms: track.start_ms + (track.duration_ms || Math.max(500, trim.end_ms - track.start_ms)),
              }))} timelinePct={timelinePct} timelineWidth={timelineWidth} top="75%" />
            </div>
          </div>
          {editMeta.textOverlays.length === 0 && (
            <p className="text-xs text-buddy-text-secondary text-center py-2">
              Tap an overlay on the video to drag it anywhere, then style it below.
            </p>
          )}
          {editMeta.textOverlays.map((ov) => (
            <div key={ov.id} className={`rounded-xl p-2.5 space-y-2 border transition-colors ${
              editingOverlayId === ov.id ? 'border-buddy-green/50 bg-buddy-green/5' : 'border-buddy-surface bg-buddy-surface-raised'
            }`}>
              <div className="flex items-center gap-2">
                <input
                  value={ov.text}
                  onChange={(e) => updateOverlay(ov.id, { text: e.target.value })}
                  maxLength={200}
                  placeholder="Overlay text…"
                  className="flex-1 bg-buddy-surface rounded-lg px-2.5 py-1.5 text-sm outline-none focus:ring-1 focus:ring-buddy-green/40"
                  aria-label="Overlay text"
                />
                <button
                  onClick={() => setEditingOverlayId(editingOverlayId === ov.id ? null : ov.id)}
                  className={`p-1.5 rounded-lg ${editingOverlayId === ov.id ? 'bg-buddy-green text-buddy-black' : 'bg-buddy-surface text-buddy-green'}`}
                  aria-label="Overlay options"
                >
                  <SlidersHorizontal size={13} />
                </button>
                <button onClick={() => removeOverlay(ov.id)} className="text-buddy-text-secondary hover:text-buddy-red p-1" aria-label="Delete overlay">
                  <Trash2 size={15} />
                </button>
              </div>
              {editingOverlayId === ov.id && (
                <div className="space-y-2">
                  <EditorRow label="Font" scroll>
                    {FONT_OPTIONS.map((f) => (
                      <ChipPill
                        key={f.id}
                        active={ov.font === f.id}
                        style={{ fontFamily: fontFamilyCss(f.id), fontSize: 11 }}
                        onClick={() => updateOverlay(ov.id, { font: f.id })}
                      >
                        {f.label}
                      </ChipPill>
                    ))}
                  </EditorRow>
                  <EditorRow label="Effect" scroll>
                    {TEXT_EFFECTS.map((fx) => (
                      <ChipPill
                        key={fx.id}
                        active={(ov.effect ?? 'none') === fx.id}
                        style={{ ...(fx.id !== 'none' ? textEffectCss(fx.id, '#FFFFFF') : { color: '#FFFFFF' }) }}
                        onClick={() => updateOverlay(ov.id, { effect: fx.id })}
                      >
                        {fx.label}
                      </ChipPill>
                    ))}
                  </EditorRow>
                  <EditorRow label="Color">
                    {TEXT_COLORS.map((c) => (
                      <button
                        key={c}
                        onClick={() => updateOverlay(ov.id, { color: c })}
                        className={`w-5.5 h-5.5 rounded-full border border-white/40 ${ov.color === c ? 'ring-2 ring-buddy-green ring-offset-1 ring-offset-buddy-surface-raised' : ''}`}
                        style={{ background: TEXT_COLOR_VALUES[c], width: 20, height: 20 }}
                        aria-label={`Text color ${c}`}
                      />
                    ))}
                  </EditorRow>
                  <EditorRow label="Size">
                    <input
                      type="range" min={0} max={2} step={0.25} value={ov.size}
                      onChange={(e) => updateOverlay(ov.id, { size: Number(e.target.value) })}
                      className="flex-1 accent-buddy-green"
                      aria-label="Text size"
                    />
                  </EditorRow>
                  <EditorRow label="Background">
                    <ChipPill active={(ov.bg ?? 'none') === 'none'} onClick={() => updateOverlay(ov.id, { bg: 'none' })}>None</ChipPill>
                    <ChipPill active={ov.bg === 'pill'} onClick={() => updateOverlay(ov.id, { bg: 'pill', bg_color: ov.bg_color || '#111111' })}>Pill</ChipPill>
                    <ChipPill active={ov.bg === 'block'} onClick={() => updateOverlay(ov.id, { bg: 'block', bg_color: ov.bg_color || '#111111' })}>Block</ChipPill>
                    {(ov.bg === 'pill' || ov.bg === 'block') && (
                      <input
                        type="color"
                        value={ov.bg_color?.startsWith('#') ? ov.bg_color : '#111111'}
                        onChange={(e) => updateOverlay(ov.id, { bg_color: e.target.value })}
                        className="w-7 h-7 rounded cursor-pointer bg-transparent"
                        aria-label="Background color"
                      />
                    )}
                  </EditorRow>
                  <EditorRow label="Animate">
                    {TEXT_ANIMATIONS.map((a) => (
                      <ChipPill key={a.id} active={(ov.animation ?? 'none') === a.id} onClick={() => updateOverlay(ov.id, { animation: a.id })}>
                        {a.label}
                      </ChipPill>
                    ))}
                  </EditorRow>
                  <EditorRow label="Position">
                    <input
                      type="range" min={4} max={96} value={ov.x ?? 50}
                      onChange={(e) => updateOverlay(ov.id, { x: Number(e.target.value) })}
                      className="flex-1 accent-buddy-green"
                      aria-label="Horizontal position"
                    />
                    <input
                      type="range" min={4} max={96} value={ov.y}
                      onChange={(e) => updateOverlay(ov.id, { y: Number(e.target.value) })}
                      className="flex-1 accent-buddy-green"
                      aria-label="Vertical position"
                    />
                  </EditorRow>
                  <EditorRow label="Timing">
                    <label className="flex items-center gap-1">
                      From
                      <input
                        type="number" min={0} step={0.1} value={ov.start_ms / 1000}
                        onChange={(e) => updateOverlay(ov.id, { start_ms: Math.round(Number(e.target.value) * 1000) })}
                        className="w-16 bg-buddy-surface rounded px-1.5 py-1"
                        aria-label="Overlay start seconds"
                      />
                    </label>
                    <label className="flex items-center gap-1">
                      To
                      <input
                        type="number" min={0} step={0.1} value={ov.end_ms / 1000}
                        onChange={(e) => updateOverlay(ov.id, { end_ms: Math.round(Number(e.target.value) * 1000) })}
                        className="w-16 bg-buddy-surface rounded px-1.5 py-1"
                        aria-label="Overlay end seconds"
                      />
                    </label>
                  </EditorRow>
                </div>
              )}
            </div>
          ))}
        </div>
      )}

      {/* ── Stickers tool ── */}
      {tool === 'stickers' && (
        <div className="space-y-2">
          <div className="grid grid-cols-6 gap-1.5">
            {QUICK_EMOJI.map((emo) => (
              <button
                key={emo}
                onClick={() => addSticker({ kind: 'emoji', content: emo })}
                className="aspect-square rounded-xl bg-buddy-surface-raised hover:bg-buddy-surface flex items-center justify-center text-lg"
                aria-label={`Add sticker ${emo}`}
              >
                {emo}
              </button>
            ))}
          </div>
          <div className="flex gap-2">
            <CountdownAdd onAdd={() =>
              addSticker({ kind: 'countdown', content: '', x: 50, y: 14, end_ms: trim.end_ms })
            } />
            <MentionAdd onAdd={(name) =>
              addSticker({ kind: 'mention', content: name.replace(/^@/, ''), x: 50, y: 22 })
            } />
          </div>
          {(editMeta.stickers || []).length > 0 && (
            <div className="space-y-1.5">
              {(editMeta.stickers || []).map((st) => (
                <div key={st.id} className="flex items-center gap-2 rounded-xl bg-buddy-surface-raised px-2.5 py-2">
                  <span className="text-base w-8 text-center truncate">
                    {st.kind === 'emoji' ? st.content : st.kind === 'mention' ? `@${st.content}` : '⏱'}
                  </span>
                  <span className="text-[11px] text-buddy-text-secondary flex-1 truncate">
                    {fmt(st.start_ms)} → {fmt(st.end_ms)}
                  </span>
                  <button onClick={() => removeSticker(st.id)} className="text-buddy-text-secondary hover:text-buddy-red p-1" aria-label="Delete sticker">
                    <Trash2 size={13} />
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {/* ── Filter tool ── */}
      {tool === 'filters' && (
        <div className="space-y-2">
          <div className="grid grid-cols-4 gap-2">
            {EDIT_FILTERS.map((f) => (
              <button
                key={f.id}
                onClick={() => onMetaChange({ filter: f.id === 'normal' ? null : f.id, filter_strength: 100 })}
                className={`rounded-xl p-1.5 border text-center transition-colors ${
                  active === f.id ? 'border-buddy-green bg-buddy-green/10' : 'border-buddy-surface-raised hover:border-buddy-text-secondary/30'
                }`}
              >
                <div className="aspect-video rounded-lg overflow-hidden bg-buddy-surface mb-1">
                  <div
                    className="w-full h-full bg-cover bg-center"
                    style={{ filter: filterCss(f.id), backgroundImage: 'linear-gradient(135deg,#0f766e 0%,#facc15 50%,#be185d 100%)' }}
                  />
                </div>
                <span className={`text-[10px] ${active === f.id ? 'text-buddy-green font-semibold' : 'text-buddy-text-secondary'}`}>
                  {f.label}
                </span>
              </button>
            ))}
          </div>
          {active && active !== 'normal' && (
            <div className="flex items-center gap-2 text-xs">
              <span className="text-buddy-text-secondary w-14">Strength</span>
              <input
                type="range" min={0} max={100} value={editMeta.filter_strength ?? 100}
                onChange={(e) => onMetaChange({ filter_strength: Number(e.target.value) })}
                className="flex-1 accent-buddy-green"
                aria-label="Filter strength"
              />
              <span className="font-mono w-8 text-right text-buddy-text-secondary">{editMeta.filter_strength ?? 100}%</span>
            </div>
          )}
        </div>
      )}

      {/* ── Adjust tool ── */}
      {tool === 'adjust' && (
        <div className="space-y-2">
          {([
            ['brightness', 'Brightness'],
            ['contrast', 'Contrast'],
            ['saturation', 'Saturation'],
          ] as const).map(([key, label]) => (
            <AdjustSlider
              key={key}
              label={label}
              value={editMeta.adjust?.[key] ?? 50}
              onChange={(v) => onMetaChange({ adjust: { ...defaultAdjustLocal, ...editMeta.adjust, [key]: v } })}
            />
          ))}
          <AdjustSlider
            label="Vignette"
            value={editMeta.adjust?.vignette ?? 0}
            dialect="0-100"
            onChange={(v) => onMetaChange({ adjust: { ...defaultAdjustLocal, ...editMeta.adjust, vignette: v } })}
          />
          <div className="flex items-center gap-2">
            <ChipPill active={editMeta.aspect === 'original'} onClick={() => onMetaChange({ aspect: 'original' })}>Crop: full</ChipPill>
            {(Object.keys(ASPECT_RATIOS) as Array<keyof typeof ASPECT_RATIOS>).map((mode) => (
              <ChipPill key={mode} active={editMeta.aspect === mode} onClick={() => onMetaChange({ aspect: mode as EditMeta['aspect'] })}>{mode}</ChipPill>
            ))}
          </div>
          {(editMeta.aspect ?? 'original') !== 'original' && (
            <div className="flex items-center gap-2 text-xs">
              <span className="text-buddy-text-secondary w-16 shrink-0">Focus Y</span>
              <input
                type="range" min={0} max={100} value={editMeta.focus_y ?? 50}
                onChange={(e) => onMetaChange({ focus_y: Number(e.target.value) })}
                className="flex-1 accent-buddy-green"
                aria-label="Vertical focus"
              />
            </div>
          )}
          <button
            onClick={() => onMetaChange({ adjust: { brightness: 50, contrast: 50, saturation: 50, vignette: 0 } })}
            className="text-xs text-buddy-text-secondary hover:text-buddy-text-primary underline underline-offset-2"
          >
            Reset adjustments
          </button>
        </div>
      )}

      {/* ── Speed tool ── */}
      {tool === 'speedx' && (
        <div className="flex flex-wrap justify-center gap-2 py-1">
          {SPEED_OPTIONS.map((s) => (
            <button
              key={s}
              onClick={() => onMetaChange({ speed: s })}
              className={`px-3.5 py-2 rounded-full text-sm font-medium transition-colors ${
                speed === s ? 'bg-buddy-green text-buddy-black' : 'bg-buddy-surface-raised text-buddy-text-secondary hover:text-buddy-text-primary'
              }`}
            >
              {s === 1 ? '1×' : `${s}×`}
            </button>
          ))}
        </div>
      )}

      {/* ── Audio tool ── */}
      {tool === 'audio' && (
        <div className="space-y-4">
          <div>
            <div className="flex items-center justify-between mb-1.5">
              <p className="text-sm font-medium">Original audio volume</p>
              <span className="text-xs font-mono text-buddy-text-secondary">{editMeta.volume}%</span>
            </div>
            <input
              type="range" min={0} max={200} value={editMeta.volume ?? 100}
              onChange={(e) => onMetaChange({ volume: Number(e.target.value) })}
              className="w-full accent-buddy-green"
              aria-label="Original audio volume"
            />
          </div>
          <button
            onClick={() => onMetaChange({ enhance: !editMeta.enhance })}
            className={`w-full flex items-center gap-3 px-4 py-3.5 rounded-2xl text-left border transition-colors ${
              editMeta.enhance ? 'border-buddy-green/50 bg-buddy-green/5' : 'border-buddy-surface bg-buddy-surface-raised'
            }`}
            aria-pressed={editMeta.enhance}
          >
            <Sparkles size={20} className={editMeta.enhance ? 'text-buddy-green' : 'text-buddy-text-secondary shrink-0'} />
            <div className="flex-1">
              <p className="text-sm font-semibold">Noise reduction</p>
              <p className="text-[11px] text-buddy-text-secondary mt-0.5">
                Voice isolate: cuts rumble and hiss, evens levels — heard live here and saved with your post.
              </p>
            </div>
            <span className={`relative inline-flex h-6 w-11 shrink-0 rounded-full transition-colors ${editMeta.enhance ? 'bg-buddy-green' : 'bg-buddy-surface'}`}>
              <span className={`absolute top-0.5 left-0.5 h-5 w-5 rounded-full bg-white shadow transition-transform ${editMeta.enhance ? 'translate-x-5' : ''}`} />
            </span>
          </button>

          {/* Added tracks */}
          <div className="space-y-2">
            <div className="flex items-center justify-between">
              <p className="text-sm font-medium">Added audio</p>
              <div className="flex gap-2">
                <button onClick={() => void startRecording()} disabled={recording || recordBusy}
                  className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg bg-buddy-surface-raised text-xs text-buddy-text-primary hover:bg-buddy-surface disabled:opacity-50">
                  {recordBusy ? <Loader2 size={13} className="animate-spin" /> : <Mic size={13} className="text-buddy-red" />}
                  {recording ? (recordBusy ? 'Saving…' : 'Stop') : 'Voiceover'}
                </button>
                <button onClick={() => setSoundPickerOpen(true)}
                  className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg bg-buddy-green/15 text-buddy-green text-xs font-semibold hover:bg-buddy-green/20">
                  <Plus size={13} /> Sound
                </button>
              </div>
            </div>
            {recordError && <p className="text-[11px] text-buddy-red">{recordError}</p>}
            {editMeta.audioTracks.length === 0 && (
              <p className="text-xs text-buddy-text-secondary">Mix in library sounds or your own voice — up to 3 tracks.</p>
            )}
            {editMeta.audioTracks.map((t) => (
              <div key={t.id} className="rounded-xl bg-buddy-surface-raised p-2.5 space-y-2">
                <div className="flex items-center gap-2">
                  <AudioLines size={14} className="text-buddy-green shrink-0" />
                  <span className="flex-1 text-xs font-medium truncate">{t.label || (t.kind === 'voiceover' ? 'Voiceover' : 'Sound')}</span>
                  <button onClick={() => removeAudioTrack(t.id)} className="text-buddy-text-secondary hover:text-buddy-red p-0.5" aria-label="Remove track">
                    <X size={13} />
                  </button>
                </div>
                <div className="flex items-center gap-2 text-xs">
                  <span className="text-buddy-text-secondary w-10 shrink-0">Level</span>
                  <input
                    type="range" min={0} max={200} value={t.volume}
                    onChange={(e) => updateAudioTrack(t.id, { volume: Number(e.target.value) })}
                    className="flex-1 accent-buddy-green"
                    aria-label="Track volume"
                  />
                  <span className="font-mono w-9 text-right text-buddy-text-secondary">{t.volume}%</span>
                </div>
                <div className="flex items-center gap-2 text-xs">
                  <span className="text-buddy-text-secondary w-10 shrink-0">Starts</span>
                  <input
                    type="number" min={0} step={0.1} value={Math.round((t.start_ms ?? 0) / 100) / 10}
                    onChange={(e) => updateAudioTrack(t.id, { start_ms: Math.max(0, Math.round(Number(e.target.value) * 1000)) })}
                    className="w-16 bg-buddy-surface rounded px-1.5 py-1 font-mono"
                    aria-label="Track start (seconds)"
                  />
                  <span className="text-buddy-text-secondary">s</span>
                  <button
                    onClick={() => updateAudioTrack(t.id, { ducking: !t.ducking })}
                    className={`ml-auto px-2 py-1 rounded-full text-[11px] font-medium transition-colors ${
                      t.ducking ? 'bg-buddy-green text-buddy-black font-semibold' : 'bg-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'
                    }`}
                    aria-pressed={!!t.ducking}
                    title="Dip other audio while this track plays"
                  >
                    Duck others
                  </button>
                </div>
                <div className="flex items-center gap-2 text-xs">
                  <span className="text-buddy-text-secondary w-10 shrink-0">Fade</span>
                  <input
                    type="range" min={0} max={3000} step={100} value={t.fade_in_ms ?? 0}
                    onChange={(e) => updateAudioTrack(t.id, { fade_in_ms: Number(e.target.value) })}
                    className="flex-1 accent-buddy-green"
                    aria-label="Track fade in (milliseconds)"
                  />
                  <input
                    type="range" min={0} max={3000} step={100} value={t.fade_out_ms ?? 0}
                    onChange={(e) => updateAudioTrack(t.id, { fade_out_ms: Number(e.target.value) })}
                    className="flex-1 accent-buddy-green"
                    aria-label="Track fade out (milliseconds)"
                  />
                  <span className="font-mono w-14 text-right text-buddy-text-secondary">
                    {(t.fade_in_ms ?? 0) / 1000}s/{(t.fade_out_ms ?? 0) / 1000}s
                  </span>
                </div>
                <div className="flex gap-1.5 flex-wrap">
                  {AUDIO_TRACK_EFFECTS.map((fx) => (
                    <ChipPill key={fx.id} active={(t.effect ?? 'none') === fx.id} onClick={() => updateAudioTrack(t.id, { effect: fx.id })}>
                      {fx.label}
                    </ChipPill>
                  ))}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* ── Captions tool (in-studio auto-captions) ── */}
      {tool === 'captions' && (
        <div className="space-y-3">
          {autoBusy ? (
            <div className="rounded-xl bg-buddy-surface-raised p-3 space-y-1.5">
              <div className="flex items-center gap-2 text-sm">
                <Loader2 size={15} className="animate-spin text-buddy-green shrink-0" />
                <span className="font-semibold flex-1">Transcribing the trimmed snippet…</span>
                <button
                  onClick={handleAutoCancel}
                  className="px-2.5 py-1.5 rounded-lg bg-buddy-surface text-xs font-semibold text-buddy-text-secondary hover:text-buddy-red"
                >
                  Cancel
                </button>
              </div>
              <p className="text-[11px] text-buddy-text-secondary">
                Lines preview live on the clip as soon as transcription finishes.
              </p>
            </div>
          ) : (
            <button
              onClick={handleAutoClick}
              disabled={!onAutoCaptions && !sourceFile}
              className="w-full flex items-center justify-center gap-2 py-2.5 rounded-xl bg-buddy-green text-buddy-black text-sm font-bold hover:bg-buddy-green/90 disabled:opacity-50"
            >
              <Captions size={15} />
              {autoFailed ? 'Retry auto-captions' : (captionSegments?.length ? 'Regenerate auto-captions' : 'Auto-captions for this clip')}
            </button>
          )}
          <p className="text-[11px] text-buddy-text-secondary -mt-1">
            Whisper runs right here in the studio — review and style the lines before posting. You can also edit each line below.
          </p>
          {autoError && <p className="text-[11px] text-buddy-red" role="alert">{autoError}</p>}
          {autoDone && !autoError && (
            <p className="text-[11px] text-buddy-green">Done — review the lines and fix anything the mic misheard.</p>
          )}

          <div className="flex gap-1.5 flex-wrap" aria-label="Caption style presets">
            {CAPTION_PRESETS.map((preset) => (
              <ChipPill
                key={preset.id}
                active={(capStyle.preset ?? 'classic') === preset.id}
                onClick={() => setCapStyle({
                  ...capStyle,
                  preset: preset.id,
                  ...(preset.font ? { font: preset.font } : {}),
                  color: preset.color,
                  bg: preset.bg,
                })}
              >
                {preset.label}
              </ChipPill>
            ))}
          </div>
          <div className="flex items-center gap-2 text-xs">
            <span className="text-buddy-text-secondary w-10 shrink-0">Size</span>
            <input
              type="range" min={0.8} max={1.6} step={0.1} value={capStyle.size ?? 1}
              onChange={(e) => setCapStyle({ ...capStyle, size: Number(e.target.value) })}
              className="flex-1 accent-buddy-green"
              aria-label="Caption size"
            />
            <span className="font-mono w-9 text-right text-buddy-text-secondary">{Math.round((capStyle.size ?? 1) * 100)}%</span>
          </div>

          <div className="flex items-center justify-between">
            <p className="text-xs font-semibold text-buddy-text-secondary uppercase tracking-wide">
              Caption segments
            </p>
            <button
              onClick={() => onCaptionSegments?.([
                ...(captionSegments ?? []),
                { id: crypto.randomUUID(), start_ms: Math.round(currentMs), end_ms: Math.round(Math.min(trim.end_ms, currentMs + 1500)), text: '' },
              ])}
              className="flex items-center gap-1 text-xs font-semibold text-buddy-green hover:underline"
            >
              <Plus size={13} /> Add
            </button>
          </div>
          {(captionSegments ?? []).length === 0 ? (
            <div className="rounded-xl border border-dashed border-buddy-surface-raised py-5 text-center text-xs text-buddy-text-secondary">
              No captions yet.
            </div>
          ) : (
            <div className="space-y-2">
              {(captionSegments ?? []).map((seg) => {
                const live = currentMs >= seg.start_ms - 40 && currentMs <= seg.end_ms + 40;
                return (
                <div
                  key={seg.id}
                  className={`rounded-xl p-2 space-y-1.5 border transition-colors ${
                    live ? 'bg-buddy-green/10 border-buddy-green/60' : 'bg-buddy-surface-raised border-transparent'
                  }`}
                >                  <div className="flex items-center gap-1.5">
                    <input
                      type="number" min={0} step={0.1} value={seg.start_ms / 1000}
                      onChange={(e) => onCaptionSegments?.((captionSegments ?? []).map((s) =>
                        s.id === seg.id ? { ...s, start_ms: Math.round(Number(e.target.value) * 1000) } : s))}
                      className="w-14 bg-buddy-surface rounded px-1.5 py-1 text-[11px] font-mono"
                      aria-label="Segment start (seconds)"
                    />
                    <span className="text-buddy-text-secondary text-[11px]">→</span>
                    <input
                      type="number" min={0} step={0.1} value={seg.end_ms / 1000}
                      onChange={(e) => onCaptionSegments?.((captionSegments ?? []).map((s) =>
                        s.id === seg.id ? { ...s, end_ms: Math.round(Number(e.target.value) * 1000) } : s))}
                      className="w-14 bg-buddy-surface rounded px-1.5 py-1 text-[11px] font-mono"
                      aria-label="Segment end (seconds)"
                    />
                    <button
                      onClick={() => onCaptionSegments?.((captionSegments ?? []).filter((s) => s.id !== seg.id))}
                      className="ml-auto p-1.5 rounded-lg text-buddy-text-secondary hover:text-buddy-red"
                      aria-label="Remove segment"
                    >
                      <Trash2 size={13} />
                    </button>
                  </div>
                  <textarea
                    value={seg.text}
                    onChange={(e) => onCaptionSegments?.((captionSegments ?? []).map((s) =>
                      s.id === seg.id ? { ...s, text: e.target.value } : s))}
                    rows={2}
                    placeholder="Caption text…"
                    className="w-full bg-buddy-surface rounded-lg px-2.5 py-1.5 text-sm outline-none resize-none focus:ring-1 focus:ring-buddy-green/40"
                    aria-label="Segment text"
                  />
                </div>
                );
              })}
            </div>
          )}
        </div>
      )}

      <SoundPicker
        open={soundPickerOpen}
        selected={null}
        videoHasAudio={(editMeta.volume ?? 100) > 0}
        onSelect={onSoundPickerSelect}
        onClose={() => setSoundPickerOpen(false)}
      />
    </div>
  );
}

const defaultAdjustLocal = { brightness: 50, contrast: 50, saturation: 50, vignette: 0 };

function TimelineLane({
  label, color, items, timelinePct, timelineWidth, top = '0%',
}: {
  label: string;
  color: string;
  items: Array<{ start_ms: number; end_ms: number }>;
  timelinePct: (ms: number) => string;
  timelineWidth: (start: number, end: number) => string;
  top?: string;
}) {
  return (
    <div className="absolute left-0 right-0 h-1/3" style={{ top }}>
      <span className="absolute left-1 top-1 text-[8px] font-mono text-white/45 z-10">{label}</span>
      {items.map((item, index) => (
        <span
          key={`${item.start_ms}-${item.end_ms}-${index}`}
          className={`absolute top-1/2 -translate-y-1/2 h-3 rounded-sm ${color} opacity-80`}
          style={{ left: timelinePct(item.start_ms), width: timelineWidth(item.start_ms, item.end_ms) }}
        />
      ))}
    </div>
  );
}

function EditorRow({ label, children, scroll }: { label: string; children: React.ReactNode; scroll?: boolean }) {
  return (
    <div className="flex items-center gap-2 text-xs">
      <span className="text-buddy-text-secondary w-20 shrink-0">{label}</span>
      <div className={`flex gap-1.5 items-center ${scroll ? 'overflow-x-auto scrollbar-none flex-nowrap' : 'flex-wrap flex-1'}`}>
        {children}
      </div>
    </div>
  );
}

function ChipPill({ children, active, onClick, style: styleProp }: {
  children: React.ReactNode; active?: boolean; onClick?: () => void; style?: React.CSSProperties;
}) {
  return (
    <button
      onClick={onClick}
      style={styleProp}
      className={`shrink-0 px-2.5 py-1 rounded-full text-[11px] font-medium transition-colors ${
        active ? 'bg-buddy-green text-buddy-black font-semibold' : 'bg-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'
      }`}
    >
      {children}
    </button>
  );
}

function AdjustSlider({ label, value, onChange, dialect }: {
  label: string; value: number; onChange: (v: number) => void; dialect?: string;
}) {
  void dialect;
  return (
    <div className="flex items-center gap-2 text-xs">
      <span className="text-buddy-text-secondary w-20 shrink-0">{label}</span>
      <input
        type="range" min={0} max={100} value={value}
        onChange={(e) => onChange(Number(e.target.value))}
        className="flex-1 accent-buddy-green"
        aria-label={label}
      />
      <span className="font-mono w-8 text-right text-buddy-text-secondary">{value}</span>
    </div>
  );
}

function CountdownAdd({ onAdd }: { onAdd: () => void }) {
  return (
    <button
      onClick={onAdd}
      className="flex-1 flex items-center justify-center gap-1.5 py-2.5 rounded-xl bg-buddy-surface-raised text-xs font-medium text-buddy-text-primary hover:bg-buddy-surface"
    >
      ⏱ Countdown sticker
    </button>
  );
}

function MentionAdd({ onAdd }: { onAdd: (name: string) => void }) {
  const [value, setValue] = useState('');
  return (
    <div className="flex-1 flex items-center gap-1.5">
      <input
        value={value}
        onChange={(e) => setValue(e.target.value)}
        maxLength={30}
        placeholder="@username"
        className="flex-1 min-w-0 bg-buddy-surface rounded-lg px-2.5 py-2 text-xs outline-none focus:ring-1 focus:ring-buddy-green/40"
        aria-label="Mention username"
      />
      <button
        onClick={() => { if (value.trim().replace(/^@/, '')) { onAdd(value.trim().replace(/^@/, '')); setValue(''); } }}
        className="px-3 py-2 rounded-lg bg-buddy-green/15 text-buddy-green text-[11px] font-semibold"
      >
        Mention
      </button>
    </div>
  );
}
