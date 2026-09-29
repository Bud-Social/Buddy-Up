import { useState, useRef, useEffect, useCallback, lazy, Suspense } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Image, FileText, Music, MapPin, BarChart2,
  Smile, X, Send, Globe, Users, Lock, Dumbbell, AtSign, ChevronDown,
  Video, File as FileIcon, Loader2, Paperclip, Minus, Plus,
} from 'lucide-react';
import { Avatar } from '@/components/ui/Avatar';
import { feedApi } from '@/api';
import { profilesApi } from '@/api';
import { useAuthStore } from '@/store/authStore';
import type { Post } from '@/types';
import EmojiPicker, { Theme, EmojiStyle } from 'emoji-picker-react';

const LocationPicker = lazy(() =>
  import('./LocationPicker').then((m) => ({ default: m.LocationPicker })),
);

function getCaretOffset(el: HTMLElement): number {
  const sel = window.getSelection();
  if (!sel || sel.rangeCount === 0) return 0;
  const range = sel.getRangeAt(0).cloneRange();
  range.selectNodeContents(el);
  range.setEnd(sel.getRangeAt(0).endContainer, sel.getRangeAt(0).endOffset);
  return range.toString().length;
}

function extractTextWithEmojis(el: HTMLElement): string {
  let text = '';
  for (const node of Array.from(el.childNodes)) {
    if (node.nodeType === Node.TEXT_NODE) {
      text += node.textContent || '';
    } else if (node.nodeType === Node.ELEMENT_NODE) {
      const element = node as HTMLElement;
      if (element.tagName === 'IMG' && element.hasAttribute('alt')) {
        text += element.getAttribute('alt');
      } else if (element.tagName === 'BR') {
        text += '\n';
      } else if (element.tagName === 'DIV' || element.tagName === 'P') {
        if (text.length > 0 && !text.endsWith('\n')) text += '\n';
        text += extractTextWithEmojis(element);
      } else {
        text += extractTextWithEmojis(element);
      }
    }
  }
  return text;
}

interface MediaItem {
  file: File;
  preview: string | null;
  type: 'image' | 'video' | 'audio' | 'document';
  name: string;
  /** Stable server URL once uploaded — lets drafts survive refresh/device changes. */
  uploadedUrl?: string;
  uploading?: boolean;
}

interface MentionUser {
  user_id: string;
  username: string;
  display_name: string;
  avatar_url: string;
}

interface PollOption {
  text: string;
}

interface PostComposerProps {
  gymId?: string;
  gymName?: string;
  placeholder?: string;
  onPost?: (post: Post) => void;
  fullScreen?: boolean;
  hideVisibility?: boolean;
  onClose?: () => void;
}

const DRAFT_KEY = 'buddyup-post-draft';

function saveDraft(data: Record<string, unknown>) {
  try {
    const existing = JSON.parse(localStorage.getItem(DRAFT_KEY) || '{}');
    localStorage.setItem(DRAFT_KEY, JSON.stringify({ ...existing, ...data, savedAt: Date.now() }));
  } catch {}
}

function loadDraft(): Record<string, unknown> | null {
  try {
    const raw = localStorage.getItem(DRAFT_KEY);
    if (!raw) return null;
    const data = JSON.parse(raw);
    if (Date.now() - (data.savedAt || 0) > 86400000) {
      localStorage.removeItem(DRAFT_KEY);
      return null;
    }
    return data;
  } catch { return null; }
}

function clearDraft() {
  try { localStorage.removeItem(DRAFT_KEY); } catch {}
}

export function PostComposer({ gymId, gymName, placeholder, onPost, fullScreen, hideVisibility, onClose }: PostComposerProps) {
  const navigate = useNavigate();
  const profile = useAuthStore((s) => s.profile);
  const editorRef = useRef<HTMLDivElement>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const mentionDebounce = useRef<ReturnType<typeof setTimeout> | null>(null);
  const draftDebounce = useRef<ReturnType<typeof setTimeout> | null>(null);
  const emojiPickerRef = useRef<HTMLDivElement>(null);
  const emojiToggleRef = useRef<HTMLButtonElement>(null);

  const [content, setContent] = useState('');
  const [mediaFiles, setMediaFiles] = useState<MediaItem[]>([]);
  const [mediaKind, setMediaKind] = useState<'image' | 'video' | 'file' | 'document'>('image');
  const [visibility, setVisibility] = useState<'public' | 'buddies' | 'gym_members' | 'private'>('public');
  const [showVisibility, setShowVisibility] = useState(false);
  const [showEmoji, setShowEmoji] = useState(false);
  const [locationLabel, setLocationLabel] = useState('');
  const [locationLat, setLocationLat] = useState<number | null>(null);
  const [locationLng, setLocationLng] = useState<number | null>(null);
  const [showLocation, setShowLocation] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const submitIdempotencyKeyRef = useRef<string | null>(null);
  const [showDraftRestore, setShowDraftRestore] = useState(false);

  // Poll state
  const [showPoll, setShowPoll] = useState(false);
  const [pollQuestion, setPollQuestion] = useState('');
  const [pollOptions, setPollOptions] = useState<PollOption[]>([{ text: '' }, { text: '' }]);
  const [pollAllowMultiple, setPollAllowMultiple] = useState(false);
  const [pollMinSelections, setPollMinSelections] = useState(1);
  const [pollMaxSelections, setPollMaxSelections] = useState(2);
  const [showAttachMenu, setShowAttachMenu] = useState(false);

  // @mention state
  const [mentionQuery, setMentionQuery] = useState('');
  const [mentionResults, setMentionResults] = useState<MentionUser[]>([]);
  const [showMentionDrop, setShowMentionDrop] = useState(false);
  const [mentionIndex, setMentionIndex] = useState(0);
  const [mentionStartPos, setMentionStartPos] = useState(-1);
  const [taggedUsers, setTaggedUsers] = useState<MentionUser[]>([]);

  // ── Draft restore: newest of (local device, server per-account draft) ────
  const serverDraftIdRef = useRef<string | null>(null);
  const restorableRef = useRef<Record<string, unknown> | null>(null);

  useEffect(() => {
    let cancelled = false;
    const local = loadDraft();
    const hasLocal = !!(local && ((local.body as string)?.trim() || local.pollQuestion || (local.locationLabel as string)?.trim()));
    if (hasLocal) {
      restorableRef.current = { __source: 'local', ...local };
      setShowDraftRestore(true);
    }
    // Server drafts make restores user-based rather than device-based.
    feedApi.getDrafts()
      .then((res) => {
        if (cancelled) return;
        const drafts = (res.data || []) as Array<Record<string, unknown>>;
        if (drafts.length === 0) return;
        const latest = drafts[0];
        serverDraftIdRef.current = (latest.id as string) || null;
        const serverTs = new Date((latest.updated_at as string) || 0).getTime();
        const localTs = Number(local?.savedAt ?? 0);
        const hasServer = !!(
          (latest.body as string)?.trim() ||
          latest.poll_question ||
          (latest.location_label as string)?.trim() ||
          ((latest.media_urls as string[]) || []).length > 0
        );
        if (hasServer && (!hasLocal || serverTs > localTs)) {
          restorableRef.current = { __source: 'server', ...(latest as Record<string, unknown>) };
          setShowDraftRestore(true);
        }
      })
      .catch(() => {});
    return () => { cancelled = true; };
  }, []);

  // Auto-save draft with debounce — mirrored to localStorage (instant,
  // offline) and the server Draft API (per-account, any device).
  const debouncedSave = useCallback(() => {
    if (draftDebounce.current) clearTimeout(draftDebounce.current);
    draftDebounce.current = setTimeout(() => {
      if (!(content || showPoll || mediaFiles.length > 0)) return;
      const savedAt = Date.now();
      const uploadedUrls = mediaFiles.map(m => m.uploadedUrl).filter((u): u is string => !!u);
      saveDraft({
        body: content,
        visibility,
        locationLabel,
        locationLat: locationLat,
        locationLng: locationLng,
        pollQuestion: showPoll ? pollQuestion : '',
        pollOptions: showPoll ? pollOptions : [],
        pollAllowMultiple,
        postType: showPoll ? 'poll' : mediaFiles.length > 0 ? (mediaFiles.some(m => m.type === 'video') ? 'video' : 'photo') : 'text',
        pollMinSelections,
        pollMaxSelections,
        mediaUrls: uploadedUrls,
        savedAt,
      });
      // Fire-and-forget server sync.
      feedApi.saveDraft({
        id: serverDraftIdRef.current ?? undefined,
        post_type: showPoll ? 'poll' : (mediaFiles.some(m => m.type === 'video') ? 'short_video' : mediaFiles.length > 0 ? 'photo' : 'text'),
        body: content,
        visibility,
        location_label: locationLabel,
        location_lat: locationLat,
        location_lng: locationLng,
        poll_question: showPoll ? pollQuestion : '',
        poll_options: showPoll ? pollOptions.map(o => o.text) : [],
        poll_allow_multiple: pollAllowMultiple,
        poll_min_selections: pollMinSelections,
        poll_max_selections: pollMaxSelections,
        media_urls: uploadedUrls,
      }).then((res) => {
        const data = res.data as { id?: string } | undefined;
        if (data?.id) serverDraftIdRef.current = data.id;
      }).catch(() => {});
    }, 2000);
  }, [content, visibility, locationLabel, locationLat, locationLng, pollQuestion, pollOptions, pollAllowMultiple, pollMinSelections, pollMaxSelections, showPoll, mediaFiles]);

  useEffect(() => { debouncedSave(); return () => { if (draftDebounce.current) clearTimeout(draftDebounce.current); }; }, [debouncedSave]);

  const applyRestoredDraft = (draft: Record<string, unknown>) => {
    setShowDraftRestore(false);
    if (draft.body) {
      setContent(draft.body as string);
      if (editorRef.current) editorRef.current.innerText = draft.body as string;
    }
    if (draft.visibility) setVisibility(draft.visibility as typeof visibility);
    if (draft.locationLabel || draft.location_label) setLocationLabel((draft.locationLabel || draft.location_label) as string);
    if (typeof draft.locationLat === 'number') setLocationLat(draft.locationLat as number);
    if (typeof draft.locationLng === 'number') setLocationLng(draft.locationLng as number);
    if (typeof draft.location_lat === 'number') setLocationLat(draft.location_lat as number);
    if (typeof draft.location_lng === 'number') setLocationLng(draft.location_lng as number);
    const question = (draft.pollQuestion || draft.poll_question) as string | undefined;
    if (question) {
      setShowPoll(true);
      setPollQuestion(question);
    }
    const opts = (draft.pollOptions || draft.poll_options) as unknown;
    if (Array.isArray(opts) && opts.length >= 2) {
      setPollOptions(
        opts.map(o => (typeof o === 'string' ? { text: o } : (o as PollOption))),
      );
    }
    const multi = typeof draft.pollAllowMultiple === 'boolean'
      ? (draft.pollAllowMultiple as boolean)
      : typeof draft.poll_allow_multiple === 'boolean'
        ? (draft.poll_allow_multiple as boolean)
        : undefined;
    if (multi !== undefined) {
      togglePollMultiple(multi);
    }
    const minSel = (draft.pollMinSelections ?? draft.poll_min_selections) as number | undefined;
    const maxSel = (draft.pollMaxSelections ?? draft.poll_max_selections) as number | undefined;
    if (typeof minSel === 'number') setPollMinSelections(Math.max(1, minSel));
    if (typeof maxSel === 'number') setPollMaxSelections(Math.max(2, maxSel));

    // Restored media arrive as stable URLs (uploaded at pick time); wrap them
    // in MediaItems whose `file` is a placeholder so previews render and
    // submit uses their uploadedUrl instead of a raw upload.
    const urlsRaw = (draft.mediaUrls || draft.media_urls) as string[] | undefined;
    if (Array.isArray(urlsRaw) && urlsRaw.length > 0) {
      const restored: MediaItem[] = urlsRaw.filter(u => typeof u === 'string' && u).map(u => ({
        file: new File([], u.split('/').pop() || 'media'),
        preview: u,
        type: /\.(mp4|webm|mov|m4v)(\?|$)/i.test(u) ? 'video' : 'image',
        name: u.split('/').pop() || 'media',
        uploadedUrl: u,
      }));
      setMediaFiles(restored.slice(0, MAX_MEDIA));
    }
  };

  const restoreDraft = () => {
    const draft = restorableRef.current;
    if (!draft) return;
    restorableRef.current = null;
    applyRestoredDraft(draft);
  };

  const discardDraft = () => {
    setShowDraftRestore(false);
    clearDraft();
    restorableRef.current = null;
    const sid = serverDraftIdRef.current;
    if (sid) {
      feedApi.deleteDraft(sid).catch(() => {});
      serverDraftIdRef.current = null;
    }
  };

  // Cleanup blob URLs
  useEffect(() => () => {
    mediaFiles.forEach(m => { if (m.preview?.startsWith('blob:')) URL.revokeObjectURL(m.preview); });
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Click outside for emoji picker — stays open during consecutive picks.
  // Touch devices fire synthetic mouse events with the editor as target after
  // an emoji tap, which used to close the picker on the first selection; we
  // therefore guard with a timestamp set from inside the picker itself.
  const lastEmojiPickAt = useRef(0);
  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (
        showEmoji &&
        Date.now() - lastEmojiPickAt.current > 400 &&
        emojiPickerRef.current &&
        !emojiPickerRef.current.contains(e.target as Node) &&
        emojiToggleRef.current &&
        !emojiToggleRef.current.contains(e.target as Node)
      ) {
        setShowEmoji(false);
      }
    };
    // Use 'mousedown' so picker stays open when clicking emoji items inside it
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [showEmoji]);

  const searchMentions = useCallback(async (q: string) => {
    if (!q || q.length < 1) { setMentionResults([]); setShowMentionDrop(false); return; }
    try {
      const res = await profilesApi.searchProfiles({ q, limit: 8 });
      setMentionResults(res.data || []);
      setShowMentionDrop((res.data || []).length > 0);
      setMentionIndex(0);
    } catch {
      setMentionResults([]);
    }
  }, []);

  const handleEditorInput = (e: React.FormEvent<HTMLDivElement>) => {
    const text = extractTextWithEmojis(e.currentTarget);
    setContent(text);

    const cursorPos = getCaretOffset(e.currentTarget);
    const textBefore = text.substring(0, cursorPos);
    const lastAt = textBefore.lastIndexOf('@');

    if (lastAt >= 0) {
      const charBefore = lastAt > 0 ? textBefore[lastAt - 1] : ' ';
      if (lastAt === 0 || /\s/.test(charBefore)) {
        const query = textBefore.substring(lastAt + 1);
        if (query.length >= 1 && !/\s/.test(query)) {
          setMentionStartPos(lastAt);
          setMentionQuery(query);
          if (mentionDebounce.current) clearTimeout(mentionDebounce.current);
          mentionDebounce.current = setTimeout(() => searchMentions(query), 250);
          return;
        }
      }
    }
    setShowMentionDrop(false);
    setMentionQuery('');
    setMentionStartPos(-1);
  };

  const insertMention = (user: MentionUser) => {
    const text = extractTextWithEmojis(editorRef.current!);
    const before = text.substring(0, mentionStartPos);
    const after = text.substring(mentionStartPos + 1 + mentionQuery.length);
    const newText = `${before}@${user.username} ${after}`;
    if (editorRef.current) {
      editorRef.current.innerText = newText;
      // Move caret to end of inserted mention
      const sel = window.getSelection();
      const range = document.createRange();
      range.selectNodeContents(editorRef.current);
      range.collapse(false);
      sel?.removeAllRanges();
      sel?.addRange(range);
    }
    setContent(newText);
    setShowMentionDrop(false);
    setMentionQuery('');
    setMentionStartPos(-1);
    if (!taggedUsers.find(u => u.user_id === user.user_id)) {
      setTaggedUsers(prev => [...prev, user]);
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (showMentionDrop && mentionResults.length > 0) {
      if (e.key === 'ArrowDown') { e.preventDefault(); setMentionIndex(i => (i + 1) % mentionResults.length); }
      else if (e.key === 'ArrowUp') { e.preventDefault(); setMentionIndex(i => (i - 1 + mentionResults.length) % mentionResults.length); }
      else if (e.key === 'Enter' || e.key === 'Tab') { e.preventDefault(); insertMention(mentionResults[mentionIndex]); }
      else if (e.key === 'Escape') setShowMentionDrop(false);
    }
  };

  const MAX_MEDIA = 12;

  const acceptForKind: Record<typeof mediaKind, string> = {
    image: 'image/*',
    video: 'video/*',
    file: 'application/pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.txt,.csv,.md,.zip',
    document: '.pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.txt,.csv,.md,.zip',
  };

  const handleFiles = (files: FileList | null, kindFilter?: 'image' | 'video' | 'file' | 'document') => {
    if (!files) return;
    const remaining = MAX_MEDIA - mediaFiles.length;
    Array.from(files).slice(0, remaining).forEach(file => {
      const isImage = file.type.startsWith('image/');
      const isVideo = file.type.startsWith('video/');
      const isAudio = file.type.startsWith('audio/');
      if (kindFilter === 'image' && !isImage) return;
      if (kindFilter === 'video' && !isVideo) return;
      if (kindFilter === 'file' && (isImage || isVideo)) return;
      const type: MediaItem['type'] = isImage ? 'image' : isVideo ? 'video' : isAudio ? 'audio' : 'document';
      const preview = (isImage || isVideo) ? URL.createObjectURL(file) : null;
      const item: MediaItem = { file, preview, type, name: file.name, uploading: true };
      setMediaFiles(prev => [...prev, item]);
      // Upload immediately so drafts persist a stable URL for this media.
      feedApi.uploadPostMedia(file)
        .then(res => {
          const url = res.data?.url;
          setMediaFiles(prev => prev.map(m => (
            m.file === file ? { ...m, uploadedUrl: url || undefined, uploading: false } : m
          )));
        })
        .catch(() => {
          // Upload failed — the raw File is still submitted at post time.
          setMediaFiles(prev => prev.map(m => (m.file === file ? { ...m, uploading: false } : m)));
        });
    });
  };

  const removeFile = (i: number) => setMediaFiles(prev => prev.filter((_, idx) => idx !== i));

  const addPollOption = () => {
    if (pollOptions.length < 6) setPollOptions(prev => [...prev, { text: '' }]);
  };
  const removePollOption = (i: number) => {
    if (pollOptions.length > 2) setPollOptions(prev => prev.filter((_, idx) => idx !== i));
  };
  const updatePollOption = (i: number, text: string) => {
    setPollOptions(prev => prev.map((o, idx) => idx === i ? { text } : o));
  };
  const filledPollOptions = pollOptions.filter(o => o.text.trim()).length;
  const togglePollMultiple = (on: boolean) => {
    setPollAllowMultiple(on);
    if (!on) {
      setPollMinSelections(1);
      setPollMaxSelections(1);
    } else {
      setPollMaxSelections(m => Math.max(2, Math.min(m, Math.max(filledPollOptions, 2))));
      setPollMinSelections(1);
    }
  };

  const handleSubmit = async () => {
    if (!content.trim() && mediaFiles.length === 0 && !showPoll) {
      return;
    }
    setIsSubmitting(true);
    try {
      const formData = new FormData();
      formData.append('body', content.trim());
      formData.append('visibility', visibility);
      if (gymId) formData.append('gym_tag', gymId);
      if (locationLabel) formData.append('location_label', locationLabel);
      if (locationLat != null && locationLng != null) {
        formData.append('location_lat', String(locationLat));
        formData.append('location_lng', String(locationLng));
      }

      {
        const hasVideo = mediaFiles.some(m => m.type === 'video');
        const postType = showPoll
          ? 'poll'
          : mediaFiles.length > 0
            ? (hasVideo ? 'short_video' : 'photo')
            : 'text';
        formData.append('post_type', postType);
        // Prefer stable uploaded URLs; fall back to raw files for anything
        // whose upload failed so posting never silently drops media.
        const uploadedUrls = mediaFiles.map(m => m.uploadedUrl).filter((u): u is string => !!u);
        if (uploadedUrls.length > 0) {
          formData.append('media_urls', JSON.stringify(uploadedUrls));
        }
        mediaFiles.filter(m => !m.uploadedUrl).forEach(m => formData.append('media', m.file));
        if (showPoll && pollQuestion.trim()) {
          formData.append('poll_question', pollQuestion.trim());
          pollOptions.filter(o => o.text.trim()).forEach(o => formData.append('poll_options', o.text.trim()));
          formData.append('poll_allow_multiple', String(pollAllowMultiple));
          const filled = pollOptions.filter(o => o.text.trim()).length;
          const maxSel = pollAllowMultiple
            ? Math.max(2, Math.min(pollMaxSelections, Math.max(filled, 2)))
            : 1;
          const minSel = pollAllowMultiple ? Math.max(1, Math.min(pollMinSelections, maxSel)) : 1;
          formData.append('poll_min_selections', String(minSel));
          formData.append('poll_max_selections', String(maxSel));
        }
      }

      taggedUsers.forEach(u => formData.append('mentioned_users', u.user_id));

      const idempotencyKey = submitIdempotencyKeyRef.current ?? crypto.randomUUID();
      submitIdempotencyKeyRef.current = idempotencyKey;
      const res = await feedApi.createPost(formData, idempotencyKey);
      if (res.data) onPost?.(res.data);
      submitIdempotencyKeyRef.current = null;

      clearDraft();
      if (serverDraftIdRef.current) {
        feedApi.deleteDraft(serverDraftIdRef.current).catch(() => {});
        serverDraftIdRef.current = null;
      }
      // Video ("Bud Press") posts go straight into the TikTok-style
      // full-screen feed, like posting a clip on TikTok/Reels.
      const postedVideo = mediaFiles.some((m) => m.type === 'video');
      setContent('');
      if (editorRef.current) editorRef.current.innerText = '';
      setMediaFiles([]);
      setTaggedUsers([]);
      setLocationLabel('');
      setLocationLat(null);
      setLocationLng(null);
      setShowPoll(false);
      setPollQuestion('');
      setPollOptions([{ text: '' }, { text: '' }]);
      onClose?.();
      if (postedVideo) navigate('/videos');
    } catch (err) {
      console.error('Post failed:', err);
    } finally {
      setIsSubmitting(false);
    }
  };

  const visibilityOptions = [
    { value: 'public' as const, label: 'Public', icon: Globe },
    { value: 'buddies' as const, label: 'Buddies', icon: Users },
    { value: 'gym_members' as const, label: 'Gym Members', icon: Dumbbell },
    { value: 'private' as const, label: 'Only Me', icon: Lock },
  ];
  const visOpt = visibilityOptions.find(v => v.value === visibility)!;
  const VisIcon = visOpt.icon;

  const canPost =
    Boolean(content.trim() || mediaFiles.length > 0 || (showPoll && pollQuestion.trim() && pollOptions.filter(o => o.text.trim()).length >= 2 && (!pollAllowMultiple || pollMinSelections <= pollMaxSelections))) &&
    !isSubmitting;

  const composerContent = (
    <div className={`flex flex-col ${fullScreen ? 'h-full' : ''}`}>
      {showDraftRestore && (
        <div className="flex items-center gap-2 px-4 py-2 bg-buddy-orange/10 border-b border-buddy-orange/20">
          <p className="text-xs text-buddy-orange flex-1">You have an unsaved draft</p>
          <button onClick={restoreDraft} className="text-xs font-medium text-buddy-green hover:underline">Restore</button>
          <button onClick={discardDraft} className="text-xs text-buddy-text-secondary hover:underline">Discard</button>
        </div>
      )}

      {fullScreen && (
        <div className="flex items-center justify-between px-4 py-3 border-b border-buddy-surface">
          <button onClick={onClose} className="p-1 rounded-lg text-buddy-text-secondary hover:text-buddy-text-primary"><X size={22} /></button>
          <h2 className="font-heading font-semibold text-sm">New Post</h2>
          <button
            onClick={handleSubmit}
            disabled={!canPost}
            className="px-4 py-1.5 rounded-full bg-buddy-green text-buddy-black text-sm font-bold disabled:opacity-40 disabled:cursor-not-allowed"
          >
            {isSubmitting ? 'Posting...' : 'Post'}
          </button>
        </div>
      )}

      <div className={`flex gap-3 ${fullScreen ? 'p-4 flex-1 overflow-y-auto' : 'p-4'}`}>
        {/* Avatar */}
        <div className="flex-shrink-0">
          <Avatar src={profile?.avatar_url} alt={profile?.display_name || 'You'} size="md" />
        </div>

        <div className="flex-1 min-w-0">
          {/* Gym context */}
          {gymName && (
            <div className="text-xs text-buddy-text-secondary mb-2 flex items-center gap-1">
              <Dumbbell size={12} className="text-buddy-green" />
              <span>Posting to <span className="text-buddy-green font-medium">{gymName}</span></span>
            </div>
          )}


          {/* Editor (text/poll posts) */}
          <div className="relative">
            <div
              ref={editorRef}
              contentEditable
              suppressContentEditableWarning
              onInput={handleEditorInput}
              onKeyDown={handleKeyDown}
              className="w-full min-h-[80px] text-sm text-buddy-text-primary bg-transparent outline-none leading-relaxed"
              data-placeholder={placeholder || "What's on your mind? Use @ to mention people"}
              style={{ caretColor: '#00ff9d' }}
            />
            {!content && (
              <p className="absolute top-0 left-0 text-sm text-buddy-text-secondary/50 pointer-events-none">
                {placeholder || "What's on your mind? Use @ to mention people"}
              </p>
            )}

            {/* @mention dropdown */}
            {showMentionDrop && mentionResults.length > 0 && (
              <div className="absolute top-full left-0 z-50 w-full max-w-xs bg-buddy-surface rounded-xl shadow-2xl border border-buddy-surface-raised overflow-hidden max-h-48 overflow-y-auto">
                {mentionResults.map((u, idx) => (
                  <button
                    key={u.user_id}
                    onMouseDown={(e) => { e.preventDefault(); insertMention(u); }}
                    className={`w-full px-3 py-2 flex items-center gap-2 text-left transition-colors ${idx === mentionIndex ? 'bg-buddy-green/10' : 'hover:bg-buddy-surface-raised'}`}
                  >
                    <Avatar src={u.avatar_url} alt={u.display_name} size="sm" />
                    <div className="min-w-0">
                      <p className="text-sm font-medium text-buddy-text-primary truncate">{u.display_name}</p>
                      <p className="text-xs text-buddy-text-secondary">@{u.username}</p>
                    </div>
                  </button>
                ))}
              </div>
            )}
          </div>

          {/* Tagged users chips */}
          {taggedUsers.length > 0 && (
            <div className="flex flex-wrap gap-1.5 mt-2">
              {taggedUsers.map(u => (
                <span key={u.user_id} className="inline-flex items-center gap-1 px-2 py-0.5 bg-buddy-green/15 text-buddy-green rounded-full text-xs font-medium">
                  <AtSign size={10} /> {u.username}
                  <button onClick={() => setTaggedUsers(prev => prev.filter(x => x.user_id !== u.user_id))} className="ml-0.5 hover:text-buddy-green/70"><X size={10} /></button>
                </span>
              ))}
            </div>
          )}

          {/* Media previews */}
          {mediaFiles.length > 0 && (
            <div className={`grid gap-2 mt-3 ${mediaFiles.length === 1 ? 'grid-cols-1' : 'grid-cols-2'}`}>
              {mediaFiles.map((m, i) => (
                <div key={i} className="relative rounded-xl overflow-hidden bg-buddy-surface-raised">
                  {m.type === 'image' && <img src={m.preview!} alt="" className="w-full h-32 object-cover" />}
                  {m.type === 'video' && <video src={m.preview!} className="w-full h-32 object-cover" />}
                  {m.type === 'audio' && (
                    <div className="h-16 flex items-center gap-2 px-3">
                      <Music size={18} className="text-buddy-electric" />
                      <span className="text-xs text-buddy-text-secondary truncate">{m.name}</span>
                    </div>
                  )}
                  {m.type === 'document' && (
                    <div className="h-16 flex items-center gap-2 px-3">
                      <FileText size={18} className="text-buddy-orange" />
                      <span className="text-xs text-buddy-text-secondary truncate">{m.name}</span>
                    </div>
                  )}
                  <button onClick={() => removeFile(i)} className="absolute top-1.5 right-1.5 p-1 bg-black/60 rounded-full text-white hover:bg-black/80">
                    <X size={12} />
                  </button>
                </div>
              ))}
            </div>
          )}

          {/* Location */}
          {showLocation && (
            <div className="mt-3">
              {locationLat != null && locationLng != null ? (
                <div className="flex items-center gap-2 bg-buddy-surface-raised rounded-xl px-3 py-2">
                  <MapPin size={14} className="text-buddy-green flex-shrink-0" />
                  <div className="flex-1 min-w-0">
                    <p className="text-xs text-buddy-text-primary truncate">{locationLabel || `${locationLat.toFixed(5)}, ${locationLng.toFixed(5)}`}</p>
                    <p className="text-[10px] text-buddy-text-secondary font-mono">{locationLat.toFixed(5)}, {locationLng.toFixed(5)}</p>
                  </div>
                  <button onClick={() => setShowLocation(true)} className="text-xs text-buddy-green hover:underline shrink-0">Change</button>
                  <button onClick={() => { setLocationLat(null); setLocationLng(null); setLocationLabel(''); setShowLocation(false); }}>
                    <X size={12} className="text-buddy-text-secondary" />
                  </button>
                </div>
              ) : (
                <div>
                  <Suspense fallback={
                    <button onClick={() => setShowLocation(false)} className="flex items-center gap-2 bg-buddy-surface-raised rounded-xl px-3 py-2 w-full text-left">
                      <Loader2 size={14} className="text-buddy-green animate-spin" />
                      <span className="text-xs text-buddy-text-secondary">Opening map picker…</span>
                    </button>
                  }>
                    <LocationPicker
                      onPick={(loc) => {
                        setLocationLat(loc.lat);
                        setLocationLng(loc.lng);
                        setLocationLabel(loc.label);
                        setShowLocation(false);
                      }}
                      onClose={() => setShowLocation(false)}
                    />
                  </Suspense>
                </div>
              )}
            </div>
          )}

          {/* Poll builder */}
          {showPoll && (
            <div className="mt-3 space-y-2 bg-buddy-surface-raised rounded-xl p-3">
              <input
                value={pollQuestion}
                onChange={e => setPollQuestion(e.target.value)}
                placeholder="Ask a question..."
                className="w-full bg-transparent text-sm font-medium text-buddy-text-primary placeholder:text-buddy-text-secondary/50 outline-none border-b border-buddy-surface pb-2"
              />
              {pollOptions.map((opt, i) => (
                <div key={i} className="flex items-center gap-2">
                  <div className="w-4 h-4 rounded-full border-2 border-buddy-green/40 flex-shrink-0" />
                  <input
                    value={opt.text}
                    onChange={e => updatePollOption(i, e.target.value)}
                    placeholder={`Option ${i + 1}`}
                    className="flex-1 bg-transparent text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 outline-none"
                  />
                  {pollOptions.length > 2 && (
                    <button onClick={() => removePollOption(i)}><X size={14} className="text-buddy-text-secondary" /></button>
                  )}
                </div>
              ))}
              {pollOptions.length < 6 && (
                <button onClick={addPollOption} className="text-xs text-buddy-green font-medium mt-1">+ Add option</button>
              )}
              <label className="flex items-center gap-2 text-xs text-buddy-text-secondary mt-2 cursor-pointer">
                <input type="checkbox" checked={pollAllowMultiple} onChange={e => togglePollMultiple(e.target.checked)} className="accent-buddy-green" />
                Allow multiple selections
              </label>
              {pollAllowMultiple && (
                <div className="mt-2 p-2.5 rounded-xl bg-buddy-surface-raised/60 border border-buddy-surface-raised">
                  <p className="text-[11px] text-buddy-text-secondary mb-2">
                    Voters pick between <span className="text-buddy-green font-semibold">{Math.min(pollMinSelections, Math.max(filledPollOptions, 1))}</span> and{' '}
                    <span className="text-buddy-green font-semibold">{Math.min(pollMaxSelections, Math.max(filledPollOptions, 1))}</span> options.
                    Checkboxes replace radio buttons.
                  </p>
                  {([
                    { label: 'Minimum choices', value: pollMinSelections, set: setPollMinSelections, floor: 1 },
                    { label: 'Maximum choices', value: pollMaxSelections, set: setPollMaxSelections, floor: 2 },
                  ]).map(({ label, value, set, floor }) => {
                    const ceiling = Math.max(floor, filledPollOptions);
                    return (
                      <div key={label} className="flex items-center justify-between gap-2 py-1">
                        <span className="text-xs text-buddy-text-primary">{label}</span>
                        <div className="flex items-center gap-2">
                          <button
                            onClick={() => set(Math.max(floor, value - 1))}
                            disabled={value <= floor}
                            className="p-1 rounded-md bg-buddy-surface text-buddy-text-secondary hover:text-buddy-green disabled:opacity-30"
                            title={`Decrease ${label.toLowerCase()}`}
                          >
                            <Minus size={13} />
                          </button>
                          <span className="text-sm font-bold w-5 text-center">{value}</span>
                          <button
                            onClick={() => set(Math.min(ceiling, value + 1))}
                            disabled={value >= ceiling}
                            className="p-1 rounded-md bg-buddy-surface text-buddy-text-secondary hover:text-buddy-green disabled:opacity-30"
                            title={`Increase ${label.toLowerCase()}`}
                          >
                            <Plus size={13} />
                          </button>
                        </div>
                      </div>
                    );
                  })}
                  {pollMinSelections > pollMaxSelections && (
                    <p className="text-[11px] text-red-400 mt-1">Minimum cannot exceed maximum.</p>
                  )}
                </div>
              )}
            </div>
          )}

          {/* Emoji picker — stays open for consecutive emoji input */}
          {showEmoji && (
            <div
              ref={emojiPickerRef}
              className="mt-3 relative z-20"
              onMouseDown={e => e.stopPropagation()}
              onTouchStart={e => e.stopPropagation()}
            >
              <EmojiPicker
                theme={Theme.DARK}
                emojiStyle={EmojiStyle.APPLE}
                lazyLoadEmojis
                searchDisabled
                skinTonesDisabled
                previewConfig={{ showPreview: false }}
                height={350}
                width="100%"
                onEmojiClick={(emojiData) => {
                  lastEmojiPickAt.current = Date.now();
                  editorRef.current?.focus();

                  // Insert emoji as an image to match Apple style precisely
                  const imgUrl = emojiData.getImageUrl(EmojiStyle.APPLE);
                  const imgHtml = `<img src="${imgUrl}" alt="${emojiData.emoji}" style="display:inline-block; width:1.2em; height:1.2em; vertical-align:middle; margin:0 0.1em; user-select:all;" />`;
                  document.execCommand('insertHTML', false, imgHtml);

                  if (editorRef.current) {
                    setContent(extractTextWithEmojis(editorRef.current));
                  }
                }}
              />
            </div>
          )}
        </div>
      </div>

      {/* Toolbar */}
      <div className="border-t border-buddy-surface px-4 py-2 flex items-center justify-between flex-shrink-0">
        <div className="flex items-center gap-1">
          {/* Media */}
          <input
            ref={fileInputRef}
            type="file"
            multiple
            accept={acceptForKind[mediaKind]}
            capture={mediaKind === 'video' ? 'environment' : undefined}
            className="hidden"
            onChange={e => { handleFiles(e.target.files, mediaKind); e.target.value = ''; }}
          />

          {/* Attachment picker — pops open so the toolbar stays uncluttered */}
          <div className="relative">
            <button
              onClick={() => setShowAttachMenu(p => !p)}
              disabled={mediaFiles.length >= MAX_MEDIA}
              className={`p-2 rounded-full transition-colors disabled:opacity-40 ${showAttachMenu ? 'text-buddy-green bg-buddy-green/10' : 'text-buddy-text-secondary hover:text-buddy-green hover:bg-buddy-green/10'}`}
              title="Attach"
            >
              <Paperclip size={18} />
            </button>
            {showAttachMenu && (
              <>
                <div className="fixed inset-0 z-10" onClick={() => setShowAttachMenu(false)} />
                <div className="absolute bottom-full left-0 mb-2 z-20 bg-buddy-surface rounded-xl shadow-2xl border border-buddy-surface-raised overflow-hidden w-48">
                  {([
                    { key: 'image' as const, icon: Image, label: 'Photo', desc: 'Images from your device' },
                    { key: 'video' as const, icon: Video, label: 'Video', desc: 'Trim, sound & captions studio' },
                    { key: 'file' as const, icon: FileIcon, label: 'File', desc: 'Docs, PDFs, archives' },
                    { key: 'document' as const, icon: FileText, label: 'Document', desc: 'Text & office files' },
                  ]).map(({ key, icon: KIcon, label, desc }) => (
                    <button
                      key={key}
                      onClick={() => {
                        if (key === 'video') {
                          // Video posts open the full creation studio.
                          setShowAttachMenu(false);
                          navigate('/create');
                          return;
                        }
                        setMediaKind(key);
                        setShowAttachMenu(false);
                        // Defer so the hidden input's accept attribute is committed first.
                        requestAnimationFrame(() => fileInputRef.current?.click());
                      }}
                      className="w-full px-3 py-2 flex items-center gap-2.5 text-left transition-colors hover:bg-buddy-surface-raised"
                    >
                      <span className="p-1.5 rounded-lg bg-buddy-surface-raised text-buddy-green">
                        <KIcon size={15} />
                      </span>
                      <span className="min-w-0">
                        <span className="block text-sm font-medium text-buddy-text-primary">{label}</span>
                        <span className="block text-[10px] text-buddy-text-secondary truncate">{desc}</span>
                      </span>
                    </button>
                  ))}
                </div>
              </>
            )}
          </div>

          {/* Poll */}
          <button onClick={() => { setShowPoll(p => !p); setShowEmoji(false); setShowLocation(false); }}
            className={`p-2 rounded-full transition-colors ${showPoll ? 'text-buddy-green bg-buddy-green/10' : 'text-buddy-text-secondary hover:text-buddy-green hover:bg-buddy-green/10'}`}
            title="Add poll">
            <BarChart2 size={18} />
          </button>

          {/* Location */}
          <button onClick={() => { setShowLocation(p => !p); setShowEmoji(false); }}
            className={`p-2 rounded-full transition-colors ${showLocation ? 'text-buddy-green bg-buddy-green/10' : 'text-buddy-text-secondary hover:text-buddy-green hover:bg-buddy-green/10'}`}
            title="Add location">
            <MapPin size={18} />
          </button>

          {/* Emoji */}
          <button ref={emojiToggleRef} onClick={() => { setShowEmoji(p => !p); setShowLocation(false); }}
            className={`p-2 rounded-full transition-colors ${showEmoji ? 'text-buddy-green bg-buddy-green/10' : 'text-buddy-text-secondary hover:text-buddy-green hover:bg-buddy-green/10'}`}
            title="Add emoji">
            <Smile size={18} />
          </button>

          {/* Visibility */}
          {!hideVisibility && (
            <div className="relative">
              <button onClick={() => setShowVisibility(p => !p)}
                className="flex items-center gap-1 px-2 py-1.5 rounded-full text-xs text-buddy-text-secondary hover:bg-buddy-surface-raised transition-colors">
                <VisIcon size={14} />
                <span className="hidden sm:inline">{visOpt.label}</span>
                <ChevronDown size={12} />
              </button>
              {showVisibility && (
                <>
                  <div className="fixed inset-0 z-10" onClick={() => setShowVisibility(false)} />
                  <div className="absolute bottom-full left-0 mb-1 z-20 bg-buddy-surface rounded-xl shadow-2xl border border-buddy-surface-raised overflow-hidden w-44">
                    {visibilityOptions.map(opt => (
                      <button key={opt.value} onClick={() => { setVisibility(opt.value); setShowVisibility(false); }}
                        className={`w-full px-3 py-2 flex items-center gap-2 text-sm text-left transition-colors hover:bg-buddy-surface-raised ${visibility === opt.value ? 'text-buddy-green' : 'text-buddy-text-primary'}`}>
                        <opt.icon size={14} />
                        {opt.label}
                      </button>
                    ))}
                  </div>
                </>
              )}
            </div>
          )}
        </div>

        {/* Character count + Post button */}
        {!fullScreen && (
          <div className="flex items-center gap-3">
            {content.length > 0 && (
              <span className={`text-xs font-mono ${content.length > 2000 ? 'text-red-400' : content.length > 1800 ? 'text-buddy-orange' : 'text-buddy-text-secondary'}`}>
                {2200 - content.length}
              </span>
            )}
            <button
              onClick={handleSubmit}
              disabled={!canPost}
              className="flex items-center gap-1.5 px-4 py-1.5 rounded-full bg-buddy-green text-buddy-black text-sm font-bold disabled:opacity-40 disabled:cursor-not-allowed hover:bg-buddy-green/90 transition-colors"
            >
              <Send size={14} />
              {isSubmitting ? 'Posting...' : 'Post'}
            </button>
          </div>
        )}
      </div>
    </div>
  );

  if (fullScreen) {
    return (
      <div className="fixed inset-0 z-50 bg-buddy-black flex flex-col">
        {composerContent}
      </div>
    );
  }

  return (
    <div className="bg-buddy-surface rounded-2xl border border-buddy-surface-raised shadow-sm overflow-visible">
      {composerContent}
    </div>
  );
}
