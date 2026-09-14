# Bud Press Edit Studio — TikTok/IG-Grade Upgrade Plan

Scope: frontend `CreateStudio`/`EditStage` + feed playback of edits (`PostCard`), backend `edit_meta` sanitization, Cloudinary upload transform. Keep the **parametric edit_meta architecture** (no ffmpeg.wasm, no re-encode) — everything stays JSON replayed live by the player, which is how TikTok-style speed/text/filters already ship.

## Bug fixes first (root causes)

1. **"No audio" root cause A — Web Audio context suspended:** `EditStage.tsx` creates `AudioContext` via `createMediaElementSource`; if the context is `suspended` (autoplay policy) audio routes nowhere, and `el.volume` stops working once the source node exists. Fix: call `ctx.resume()` on user gestures (play press), route volume through a `GainNode` in the graph, and never `.catch{}` silently — surface a retry.
2. **Root cause B — Cloudinary eager transform:** `backend/apps/feed/uploads.py:13` `EAGER_TRANSFORMS['video'] = 'vc_h264:q_auto:so_auto,w_1080,c_limit'` re-encodes with no audio codec clause; unsupported source audio can be dropped. Fix: append explicit audio codec (`ac_aac` per Cloudinary video codec docs — verify qualifier on Cloudinary docs at implementation; fallback: drop the eager `vc_h264` re-encode entirely so originals stream untouched). New uploads keep their audio track; playback in editor/render then works.
3. **Feed ignores `edit_meta.volume`:** apply it in `PostCard.tsx` player (video el volume / Web Audio gain).

## Data model (frontend `lib/createStudio.ts` + backend)

Extend `EditMeta` (additive, backward compatible; backend `sanitize_edit_meta` in `apps/feed/views.py:137` gets matching validators + caps; JSONField so **no migration needed**):

```
EditMeta {
  filter, filter_strength: 0-100,
  speed, volume,
  enhance: 'off' | 'voice_isolate' (noise reduction chain),
  voice_effect: null | 'chipmunk' | 'deep' | 'robot' | 'echo',
  adjust: { brightness, contrast, saturation, vignette } (0-100 each),
  aspect: 'original' | '9:16' | '1:1' | '4:5' | '16:9' (+focus_y for cover crop),
  text_overlays: [{ id, text, start_ms, end_ms, x, y, rotation,
                    font: fontId, size, color, bg: 'none'|'pill'|'block',
                    bg_color, animation: 'fade'|'pop'|'karaoke'|'slide' }],
  stickers: [{ id, emoji|kind: 'countdown'|'mention', x, y, start_ms, end_ms, scale }],
  audio_tracks: [{ id, kind: 'sound'|'voiceover'|'url', sound_id|url,
                   volume 0-200, start_ms, duration, effects: [] }],
  captions_style: { preset, font, size, color, bg }
}
```

Backend validation caps: keep current style limits (≤10 text_overlays → raise to 50; ≤12 stickers; ≤3 audio_tracks; strings length-capped; numeric ranges clamped). Update `sanitizeEditMeta` + `buildMediaPayload` symmetrically.

## Split / multi-clip ("splitting", "adding new video/photos")

- **Split:** pure frontend — split item into two `PublishableMediaItem` entries sharing the same `media.url` with complementary `trim_start_ms/end_ms` and re-anchored overlays/tracks. UI: "Split at playhead" in Trim tab + a clip strip (thumbnails per segment, reorderable, delete per-clip).
- **Add media:** existing picker reused; items share one edit pipeline. MAX_MEDIA_ITEMS 12 stays.
- **Feed playback of multi-clip:** extend `PostCard.tsx`/feed players to play ordered video `media[]` sequentially (queue advance on `ended`, aggregate trim offsets, per-clip edit_meta). Single-video posts unchanged.

## Audio features (Web Audio mixer engine)

New `frontend/src/lib/audioMixer.ts` + `<Player>` refactor shared by EditStage and feed:
- One graph per playback container: video element source → gain (original volume) → destination; N `<audio>`/"sound" sources → gain → effects chain → destination; user gesture resumes contexts.
- Track sync: drift-checked resync on play/pause/seek (`audio.currentTime = (video.currentTime - track.start_ms)`), auto stop at `duration`.
- **Noise reduction ("voice isolate"):** upgraded chain — highpass 100 Hz → lowpass ~14 kHz → compressor-as-expander (noise gate approximation) → soft compressor → makeup gain. Applied to voiceover/original; toggle 'off' | 'on'.
- **Voice effects** (Web Audio native, applied to voiceover/added tracks; original-audio effects via `playbackRate`-preserving graph only where safe): chipmunk/deep = `detune`/pitch via `AudioParam` detune on an offline-resampled buffer (preprocess with OfflineAudioContext, cache), robot = ring-mod oscillator, echo = delay node.
- **Voiceover recording:** MediaRecorder capture in Sound tab (countdown → record over clip, auto trim-matched), upload via existing `uploadToCloudinary` audio path → pushed to `audio_tracks` (kind='voiceover', url). Renamed tab "Audio".
- **Mixer UI:** per-track faders (original + added), mute/solo per track (TikTok-style).
- **Split audio:** wired automatically after split (track offsets re-anchored).

## Sounds library content

`apps/feed/sounds_seed.json` is all-empty (`audio_url: ""` → inactive) so the sound picker has nothing real. Add a seeding task/improvement: accept admin-uploading of curated tracks (license + attribution), and make `SoundListCreateView` filter/pagination ready. (Content licensing is a product decision — ship with a handful of CC0 tracks uploaded to Cloudinary at implementation.)

## Text upgrade

- Fonts: add 5–6 web fonts (TikTok-ish set: classic, typewriter, neon, handwriting, serif, mono) — load locally in editor, and at feed render (same CSS helpers in `createStudio.ts`, applied in `PostCard`).
- Controls: color any-HEX picker + swatches, **background** `none | pill | block` with adjustable bg color + padding, per-overlay **x/y drag** on the preview + rotation, size slider replaces 0/1/2, animation presets (fade/pop/karaoke word-bounce/slide-in) implemented as CSS classes shared editor/feed.
- Timeline: adjust overlay start/end on the trim track (drag bars), not only numeric.

## Visual upgrade

- New filter sets (extend `EDIT_FILTERS`) + **strength slider** (CSS interpolation via opacity-blend of filtered layer or filter function weighting).
- **Adjust tab:** brightness/contrast/saturation/vignette sliders with reset (CSS + box-shadow inset vignette overlay div).
- **Aspect crop:** `aspect` + `focus_y` applied as object-fit/transform crop container, parametrically replayed in feed. Mask-aware editing preview.

## Stickers + CTA

- Emoji sticker tray (categories: memes, vibes, workout/food given the domain) rendered absolutely over preview, draggable + resizeable (pointer events), time-gated like text.
- CTA stickers: countdown (renders live from local time at `end_ms`), @mention (links to profile), poll placeholder via existing poll fields (out of scope if model lacks support — check; else skip).

## Captions (auto, editable, synced)

- Pipeline stays: publish → whisper → `PostMedia.captions`. Upgrade `CaptionsPanel.tsx`:
  - Fetch/regenerate status; **editable segments** (edit text, merge/split, adjust times, delete).
  - Style presets (classic white, TikTok pop, karaoke highlight, minimal) → stored in `captions_style` in edit_meta; rendered by feed with the same style classes.
  - Manual-add fallback retained.
- Show captions live inside EditStage preview too (overlay renderer shared with feed).

## Shared rendering surface (key refactor)

Extract the overlay/conf rendering from PostCard into a reusable `<CreativeLayer meta={editMeta} …/>` used by **EditStage preview, CaptionPanel, PostCard, FullScreenVideoFeed** — one source of truth for filters/adjust/text/stickers/captions/aspect, no drift between editor and feed.

## Backend touch points

- `apps/feed/views.py` `sanitize_edit_meta`: new fields + caps (still ≤180 s logic untouched; speed options extended to 0.3–3).
- `apps/feed/uploads.py` eager transform audio fix (+ unit test asserting the signed params contain the audio clause).
- `apps/feed/serializers.py` nothing new (edit_meta already passthrough via PostMediaSerializer) — confirm.
- Optional: `transcribe_post_media` already fine; captions writable path stays server-side.

## Verification

- Vitest (frontend): `createStudio.ts` pure functions — `sanitizeEditMeta` new fields, split logic, mixer offset math, captions normalize. Existing tests in `frontend/src/lib/__tests__/` extended.
- pytest: `sanitize_edit_meta` new-field caps; uploads sign params include audio codec.
- Manual `/browse` QA: full edit flow pick→edit(trim/split/text/stickers/filter/adjust/aspect/audio mix/captions)→publish → verify feed playback shows identical result with audio, multi-clip sequence, captions sync.

## Suggested build order

1. Bug fixes (audio ctx + Cloudinary transform) — smallest diff, unblocks everything.
2. `CreativeLayer` refactor + feed applies `edit_meta.volume`.
3. Data model + sanitizers (frontend+backend) with tests.
4. Audio mixer engine + voiceover + noise reduction + voice effects UI.
5. Text + fonts + backgrounds + drag/timeline.
6. Visual (filters/adjust/aspect) + stickers/CTA.
7. Split + multi-clip feed playback.
8. Captions panel upgrade + styles.
9. Sound library seeding.
10. QA pass with /browse.
