import { useState, useRef, useEffect, useCallback, lazy, Suspense } from 'react';
import {
  Image, FileText, Music, MapPin, BarChart2,
  Smile, X, Send, Globe, Users, Lock, Dumbbell, AtSign, ChevronDown,
  Utensils, Scale, Camera, Video, File as FileIcon, Loader2,
} from 'lucide-react';
import { Avatar } from '@/components/ui/Avatar';
import { feedApi, marketplaceApi } from '@/api';
import { profilesApi } from '@/api';
import { useAuthStore } from '@/store/authStore';
import type { Post } from '@/types';
import EmojiPicker, { Theme, EmojiStyle } from 'emoji-picker-react';

const LocationPicker = lazy(() =>
  import('./LocationPicker').then((m) => ({ default: m.LocationPicker })),
);

type ComposerKind = 'text' | 'meal' | 'progress';

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
  initialMeal?: {
    food_name?: string;
    calories?: number;
    protein_g?: number;
    carbs_g?: number;
    fat_g?: number;
    meal_type?: string;
  } | null;
  initialMealPhotoDataUrl?: string | null;
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

export function PostComposer({ gymId, gymName, placeholder, onPost, fullScreen, hideVisibility, onClose, initialMeal, initialMealPhotoDataUrl }: PostComposerProps) {
  const profile = useAuthStore((s) => s.profile);
  const editorRef = useRef<HTMLDivElement>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const mealPhotoInputRef = useRef<HTMLInputElement>(null);
  const progressBeforeInputRef = useRef<HTMLInputElement>(null);
  const progressAfterInputRef = useRef<HTMLInputElement>(null);
  const mentionDebounce = useRef<ReturnType<typeof setTimeout> | null>(null);
  const draftDebounce = useRef<ReturnType<typeof setTimeout> | null>(null);
  const emojiPickerRef = useRef<HTMLDivElement>(null);
  const emojiToggleRef = useRef<HTMLButtonElement>(null);

  const [kind, setKind] = useState<ComposerKind>('text');
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
  const [showDraftRestore, setShowDraftRestore] = useState(false);

  // Meal-log state
  const [mealType, setMealType] = useState<'breakfast' | 'lunch' | 'dinner' | 'snack' | 'drink' | 'other'>('breakfast');
  const [foodName, setFoodName] = useState('');
  const [mealDesc, setMealDesc] = useState('');
  const [calories, setCalories] = useState('');
  const [proteinG, setProteinG] = useState('');
  const [carbsG, setCarbsG] = useState('');
  const [fatG, setFatG] = useState('');
  const [mealPhotos, setMealPhotos] = useState<MediaItem[]>([]);
  const [analyzingMeal, setAnalyzingMeal] = useState(false);

  // Progress / body-snap state
  const [progressWeight, setProgressWeight] = useState('');
  const [weightUnit, setWeightUnit] = useState<'kg' | 'lbs'>('kg');
  const [progressMode, setProgressMode] = useState<'transformation' | 'milestone'>('transformation');
  const [beforePhotos, setBeforePhotos] = useState<MediaItem[]>([]);
  const [afterPhotos, setAfterPhotos] = useState<MediaItem[]>([]);

  // Poll state
  const [showPoll, setShowPoll] = useState(false);
  const [pollQuestion, setPollQuestion] = useState('');
  const [pollOptions, setPollOptions] = useState<PollOption[]>([{ text: '' }, { text: '' }]);
  const [pollAllowMultiple, setPollAllowMultiple] = useState(false);

  // @mention state
  const [mentionQuery, setMentionQuery] = useState('');
  const [mentionResults, setMentionResults] = useState<MentionUser[]>([]);
  const [showMentionDrop, setShowMentionDrop] = useState(false);
  const [mentionIndex, setMentionIndex] = useState(0);
  const [mentionStartPos, setMentionStartPos] = useState(-1);
  const [taggedUsers, setTaggedUsers] = useState<MentionUser[]>([]);

  // Check for draft on mount and offer restore
  useEffect(() => {
    const draft = loadDraft();
    if (draft && (draft.body || draft.pollQuestion)) {
      setShowDraftRestore(true);
    }
  }, []);

  // Prefill meal form from the food scanner ("Share as Meal Post")
  useEffect(() => {
    if (!initialMeal) return;
    setKind('meal');
    if (initialMeal.food_name) setFoodName(initialMeal.food_name);
    if (initialMeal.meal_type) setMealType(initialMeal.meal_type as typeof mealType);
    if (initialMeal.calories) setCalories(String(Math.round(initialMeal.calories)));
    if (initialMeal.protein_g) setProteinG(String(Math.round(initialMeal.protein_g)));
    if (initialMeal.carbs_g) setCarbsG(String(Math.round(initialMeal.carbs_g)));
    if (initialMeal.fat_g) setFatG(String(Math.round(initialMeal.fat_g)));
    if (initialMealPhotoDataUrl) {
      try { sessionStorage.removeItem('buddyup-meal-photo'); } catch {}
      fetch(initialMealPhotoDataUrl)
        .then((r) => r.blob())
        .then((blob) => {
          const file = new File([blob], 'meal.jpg', { type: blob.type || 'image/jpeg' });
          setMealPhotos((prev) => [...prev, { file, preview: initialMealPhotoDataUrl, type: 'image', name: file.name }]);
        })
        .catch(() => {});
    }
   
  }, [initialMeal, initialMealPhotoDataUrl]);

  // Auto-save draft with debounce
  const debouncedSave = useCallback(() => {
    if (draftDebounce.current) clearTimeout(draftDebounce.current);
    draftDebounce.current = setTimeout(() => {
      if (content || showPoll || mediaFiles.length > 0) {
        saveDraft({
          body: content,
          visibility,
          locationLabel,
          pollQuestion: showPoll ? pollQuestion : '',
          pollOptions: showPoll ? pollOptions : [],
          pollAllowMultiple,
          postType: showPoll ? 'poll' : mediaFiles.length > 0 ? 'photo' : 'text',
        });
      }
    }, 2000);
  }, [content, visibility, locationLabel, pollQuestion, pollOptions, pollAllowMultiple, showPoll, mediaFiles.length]);

  useEffect(() => { debouncedSave(); return () => { if (draftDebounce.current) clearTimeout(draftDebounce.current); }; }, [debouncedSave]);

  const restoreDraft = () => {
    const draft = loadDraft();
    if (!draft) return;
    setShowDraftRestore(false);
    if (draft.body) {
      setContent(draft.body as string);
      if (editorRef.current) editorRef.current.innerText = draft.body as string;
    }
    if (draft.visibility) setVisibility(draft.visibility as typeof visibility);
    if (draft.locationLabel) setLocationLabel(draft.locationLabel as string);
    if (draft.pollQuestion) {
      setShowPoll(true);
      setPollQuestion(draft.pollQuestion as string);
    }
    if (draft.pollOptions) setPollOptions(draft.pollOptions as PollOption[]);
    if (typeof draft.pollAllowMultiple === 'boolean') setPollAllowMultiple(draft.pollAllowMultiple as boolean);
  };

  const discardDraft = () => {
    setShowDraftRestore(false);
    clearDraft();
  };

  // Cleanup blob URLs
  useEffect(() => () => {
    mediaFiles.forEach(m => { if (m.preview?.startsWith('blob:')) URL.revokeObjectURL(m.preview); });
    mealPhotos.forEach(m => { if (m.preview?.startsWith('blob:')) URL.revokeObjectURL(m.preview); });
    beforePhotos.forEach(m => { if (m.preview?.startsWith('blob:')) URL.revokeObjectURL(m.preview); });
    afterPhotos.forEach(m => { if (m.preview?.startsWith('blob:')) URL.revokeObjectURL(m.preview); });
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Click outside for emoji picker — stays open during consecutive picks
  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (
        showEmoji &&
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
      setMediaFiles(prev => [...prev, { file, preview, type, name: file.name }]);
    });
  };

  const removeFile = (i: number) => setMediaFiles(prev => prev.filter((_, idx) => idx !== i));

  const addMealPhotos = (files: FileList | null) => {
    if (!files) return;
    const photos = Array.from(files).filter(f => f.type.startsWith('image/'));
    setMealPhotos(prev => [...prev, ...photos.map(f => ({ file: f, preview: URL.createObjectURL(f), type: 'image' as const, name: f.name }))]);
    if (photos[0] && (!foodName.trim() || !calories.trim())) analyzeMealPhoto(photos[0]);
  };

  const analyzeMealPhoto = async (photo: File) => {
    setAnalyzingMeal(true);
    try {
      const res = await marketplaceApi.recognizeFood(photo);
      const result = res.data;
      if (result?.items?.length) {
        const top = result.items[0];
        setFoodName(prev => prev || top.item);
        setCalories(prev => prev || String(Math.round(result.total_calories || top.nutrition?.calories || 0)));
        setProteinG(prev => prev || String(Math.round(result.total_protein || top.nutrition?.protein || 0)));
        setCarbsG(prev => prev || String(Math.round(result.total_carbs || top.nutrition?.carbs || 0)));
        setFatG(prev => prev || String(Math.round(result.total_fat || top.nutrition?.fat || 0)));
      }
    } catch {} finally {
      setAnalyzingMeal(false);
    }
  };

  const removeMealPhoto = (i: number) => setMealPhotos(prev => prev.filter((_, idx) => idx !== i));

  const addProgressPhotos = (files: FileList | null, bucket: 'before' | 'after') => {
    if (!files) return;
    const photos = Array.from(files).filter(f => f.type.startsWith('image/'));
    const items: MediaItem[] = photos.map(f => ({ file: f, preview: URL.createObjectURL(f), type: 'image' as const, name: f.name }));
    if (bucket === 'before') setBeforePhotos(prev => [...prev, ...items]);
    else setAfterPhotos(prev => [...prev, ...items]);
  };

  const removeProgressPhoto = (bucket: 'before' | 'after', i: number) => {
    if (bucket === 'before') setBeforePhotos(prev => prev.filter((_, idx) => idx !== i));
    else setAfterPhotos(prev => prev.filter((_, idx) => idx !== i));
  };

  const addPollOption = () => {
    if (pollOptions.length < 6) setPollOptions(prev => [...prev, { text: '' }]);
  };
  const removePollOption = (i: number) => {
    if (pollOptions.length > 2) setPollOptions(prev => prev.filter((_, idx) => idx !== i));
  };
  const updatePollOption = (i: number, text: string) => {
    setPollOptions(prev => prev.map((o, idx) => idx === i ? { text } : o));
  };

  const handleSubmit = async () => {
    if (kind === 'meal') {
      if (!foodName.trim() && !calories.trim() && mealPhotos.length === 0) return;
    } else if (kind === 'progress') {
      if (!progressWeight.trim() && beforePhotos.length === 0 && afterPhotos.length === 0) return;
    } else if (!content.trim() && mediaFiles.length === 0 && !showPoll) {
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

      if (kind === 'meal') {
        formData.append('post_type', 'meal');
        const mealData: Record<string, unknown> = {
          meal_type: mealType,
          food_name: foodName.trim(),
          description: mealDesc.trim(),
        };
        if (calories) mealData.calories = Number(calories);
        if (proteinG) mealData.protein_g = Number(proteinG);
        if (carbsG) mealData.carbs_g = Number(carbsG);
        if (fatG) mealData.fat_g = Number(fatG);
        formData.append('meal_data', JSON.stringify(mealData));
        mealPhotos.forEach(mp => formData.append('media', mp.file));
      } else if (kind === 'progress') {
        formData.append('post_type', 'progress');
        const progressData: Record<string, unknown> = {
          weight: progressWeight ? Number(progressWeight) : null,
          weight_unit: weightUnit,
          mode: progressMode,
          before_count: beforePhotos.length,
        };
        formData.append('progress_data', JSON.stringify(progressData));
        beforePhotos.forEach(p => formData.append('media', p.file));
        afterPhotos.forEach(p => formData.append('media', p.file));
      } else {
        const postType = showPoll ? 'poll' : mediaFiles.length > 0 ? 'photo' : 'text';
        formData.append('post_type', postType);
        mediaFiles.forEach(m => formData.append('media', m.file));
        if (showPoll && pollQuestion.trim()) {
          formData.append('poll_question', pollQuestion.trim());
          pollOptions.filter(o => o.text.trim()).forEach(o => formData.append('poll_options', o.text.trim()));
          formData.append('poll_allow_multiple', String(pollAllowMultiple));
        }
      }

      taggedUsers.forEach(u => formData.append('mentioned_users', u.user_id));

      const res = await feedApi.createPost(formData);
      if (res.data) onPost?.(res.data);

      clearDraft();
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
      setKind('text');
      setFoodName(''); setMealDesc(''); setCalories(''); setProteinG(''); setCarbsG(''); setFatG('');
      setMealPhotos([]); setProgressWeight(''); setBeforePhotos([]); setAfterPhotos([]);
      onClose?.();
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
    (kind === 'meal'
      ? Boolean(foodName.trim() || calories.trim() || mealPhotos.length > 0)
      : kind === 'progress'
        ? Boolean(progressWeight.trim() || beforePhotos.length > 0 || afterPhotos.length > 0)
        : Boolean(content.trim() || mediaFiles.length > 0 || (showPoll && pollQuestion.trim() && pollOptions.filter(o => o.text.trim()).length >= 2))) &&
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

          {/* Composer kind switcher */}
          <div className="flex items-center gap-1 bg-buddy-surface rounded-xl p-1 mb-3 w-max">
            <button
              onClick={() => { setKind('text'); setShowEmoji(false); }}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium transition-colors ${kind === 'text' ? 'bg-buddy-green/15 text-buddy-green' : 'text-buddy-text-secondary hover:text-buddy-text-primary'}`}
            >
              <Image size={14} /> Post
            </button>
            <button
              onClick={() => { setKind('meal'); setShowEmoji(false); }}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium transition-colors ${kind === 'meal' ? 'bg-buddy-green/15 text-buddy-green' : 'text-buddy-text-secondary hover:text-buddy-text-primary'}`}
            >
              <Utensils size={14} /> Meal
            </button>
            <button
              onClick={() => { setKind('progress'); setShowEmoji(false); }}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium transition-colors ${kind === 'progress' ? 'bg-buddy-green/15 text-buddy-green' : 'text-buddy-text-secondary hover:text-buddy-text-primary'}`}
            >
              <Scale size={14} /> Progress
            </button>
          </div>

          {/* Meal-log form */}
          {kind === 'meal' && (
            <div className="space-y-3">
              <div className="flex flex-wrap gap-1.5">
                {(['breakfast', 'lunch', 'dinner', 'snack', 'drink', 'other'] as const).map((mt) => (
                  <button
                    key={mt}
                    onClick={() => setMealType(mt)}
                    className={`px-3 py-1 rounded-full text-xs capitalize transition-colors ${
                      mealType === mt
                        ? 'bg-buddy-green text-buddy-black font-medium'
                        : 'border border-buddy-text-secondary/20 hover:border-buddy-green hover:text-buddy-green'
                    }`}
                  >
                    {mt}
                  </button>
                ))}
              </div>
              <div className="flex items-center gap-2">
                <input
                  value={foodName}
                  onChange={(e) => setFoodName(e.target.value)}
                  placeholder="What did you eat? (e.g. Oatmeal & banana)"
                  className="flex-1 bg-buddy-surface border border-buddy-surface-raised rounded-xl px-3 py-2.5 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30"
                />
                <input
                  type="number"
                  value={calories}
                  onChange={(e) => setCalories(e.target.value)}
                  placeholder="kcal"
                  className="w-20 bg-buddy-surface border border-buddy-surface-raised rounded-xl px-3 py-2.5 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30"
                />
              </div>
              <div className="grid grid-cols-3 gap-2">
                <input value={proteinG} onChange={(e) => setProteinG(e.target.value)} type="number" placeholder="Protein (g)" className="w-full bg-buddy-surface border border-buddy-surface-raised rounded-xl px-3 py-2 text-xs text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30" />
                <input value={carbsG} onChange={(e) => setCarbsG(e.target.value)} type="number" placeholder="Carbs (g)" className="w-full bg-buddy-surface border border-buddy-surface-raised rounded-xl px-3 py-2 text-xs text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30" />
                <input value={fatG} onChange={(e) => setFatG(e.target.value)} type="number" placeholder="Fat (g)" className="w-full bg-buddy-surface border border-buddy-surface-raised rounded-xl px-3 py-2 text-xs text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30" />
              </div>
              {mealPhotos.length > 0 && (
                <div className="grid grid-cols-3 gap-2">
                  {mealPhotos.map((mp, i) => (
                    <div key={i} className="relative rounded-xl overflow-hidden aspect-square">
                      <img src={mp.preview!} alt="Meal" className="w-full h-full object-cover" />
                      <button onClick={() => removeMealPhoto(i)} className="absolute top-1 right-1 p-1 bg-black/60 rounded-full text-white hover:bg-black/80"><X size={12} /></button>
                    </div>
                  ))}
                </div>
              )}
              <input ref={mealPhotoInputRef} type="file" accept="image/*" multiple className="hidden"
                onChange={(e) => { addMealPhotos(e.target.files); e.target.value = ''; }} />
              <div className="flex items-center gap-3">
                <button
                  onClick={() => mealPhotoInputRef.current?.click()}
                  className="flex items-center gap-1.5 text-xs text-buddy-text-secondary hover:text-buddy-green transition-colors"
                >
                  <Camera size={14} /> {mealPhotos.length > 0 ? 'Add more photos' : 'Add meal photo'}
                </button>
                {analyzingMeal && (
                  <span className="flex items-center gap-1.5 text-xs text-buddy-green">
                    <Loader2 size={13} className="animate-spin" /> Analyzing meal…
                  </span>
                )}
              </div>
              <p className="text-[11px] text-buddy-text-secondary">
                Food name &amp; calories are auto-filled by the food analyser from your photo — feel free to adjust.
              </p>
            </div>
          )}

          {/* Progress / body-snap form */}
          {kind === 'progress' && (
            <div className="space-y-3">
              {/* Mode toggle */}
              <div className="flex gap-1.5 bg-buddy-surface-raised rounded-xl p-1">
                {([
                  { value: 'transformation' as const, label: 'Before → After' },
                  { value: 'milestone' as const, label: 'Current / Milestone' },
                ]).map((m) => (
                  <button key={m.value} onClick={() => setProgressMode(m.value)}
                    className={`flex-1 py-1.5 rounded-lg text-xs font-medium transition-colors ${progressMode === m.value ? 'bg-buddy-green/15 text-buddy-green' : 'text-buddy-text-secondary hover:text-buddy-text-primary'}`}>
                    {m.label}
                  </button>
                ))}
              </div>

              {/* Weight (optional) */}
              <div className="flex items-center gap-2">
                <Scale size={16} className="text-buddy-green flex-shrink-0" />
                <input
                  type="number"
                  step="0.1"
                  value={progressWeight}
                  onChange={(e) => setProgressWeight(e.target.value)}
                  placeholder="Weight (optional)"
                  className="flex-1 bg-buddy-surface border border-buddy-surface-raised rounded-xl px-3 py-2.5 text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 focus:outline-none focus:ring-2 focus:ring-buddy-green/30"
                />
                <div className="flex gap-1 bg-buddy-surface-raised rounded-xl p-0.5">
                  {(['kg', 'lbs'] as const).map((u) => (
                    <button key={u} onClick={() => setWeightUnit(u)}
                      className={`px-2.5 py-1.5 rounded-lg text-xs font-medium transition-colors ${weightUnit === u ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary'}`}>
                      {u}
                    </button>
                  ))}
                </div>
              </div>

              {/* Photo buckets */}
              {progressMode === 'transformation' ? (
                <div className="grid grid-cols-2 gap-2">
                  <div className="space-y-1.5">
                    <p className="text-[11px] font-medium text-buddy-text-secondary">BEFORE</p>
                    {beforePhotos.length > 0 && (
                      <div className="grid grid-cols-2 gap-1.5">
                        {beforePhotos.map((p, i) => (
                          <div key={i} className="relative rounded-lg overflow-hidden aspect-square">
                            <img src={p.preview!} alt="Before" className="w-full h-full object-cover" />
                            <button onClick={() => removeProgressPhoto('before', i)} className="absolute top-1 right-1 p-0.5 bg-black/60 rounded-full text-white"><X size={10} /></button>
                          </div>
                        ))}
                      </div>
                    )}
                    <input ref={progressBeforeInputRef} type="file" accept="image/*" multiple className="hidden"
                      onChange={(e) => { addProgressPhotos(e.target.files, 'before'); e.target.value = ''; }} />
                    <button
                      onClick={() => progressBeforeInputRef.current?.click()}
                      className="w-full h-20 rounded-xl border-2 border-dashed border-buddy-text-secondary/20 hover:border-buddy-green/50 flex flex-col items-center justify-center gap-1 text-buddy-text-secondary hover:text-buddy-green transition-colors text-[11px]"
                    >
                      <Camera size={16} /> {beforePhotos.length ? 'Add more' : 'Add before'}
                    </button>
                  </div>
                  <div className="space-y-1.5">
                    <p className="text-[11px] font-medium text-buddy-green">AFTER</p>
                    {afterPhotos.length > 0 && (
                      <div className="grid grid-cols-2 gap-1.5">
                        {afterPhotos.map((p, i) => (
                          <div key={i} className="relative rounded-lg overflow-hidden aspect-square">
                            <img src={p.preview!} alt="After" className="w-full h-full object-cover" />
                            <button onClick={() => removeProgressPhoto('after', i)} className="absolute top-1 right-1 p-0.5 bg-black/60 rounded-full text-white"><X size={10} /></button>
                          </div>
                        ))}
                      </div>
                    )}
                    <input ref={progressAfterInputRef} type="file" accept="image/*" multiple className="hidden"
                      onChange={(e) => { addProgressPhotos(e.target.files, 'after'); e.target.value = ''; }} />
                    <button
                      onClick={() => progressAfterInputRef.current?.click()}
                      className="w-full h-20 rounded-xl border-2 border-dashed border-buddy-green/40 hover:border-buddy-green flex flex-col items-center justify-center gap-1 text-buddy-text-secondary hover:text-buddy-green transition-colors text-[11px]"
                    >
                      <Camera size={16} /> {afterPhotos.length ? 'Add more' : 'Add after'}
                    </button>
                  </div>
                </div>
              ) : (
                <div className="space-y-1.5">
                  {afterPhotos.length > 0 && (
                    <div className="grid grid-cols-3 gap-1.5">
                      {afterPhotos.map((p, i) => (
                        <div key={i} className="relative rounded-lg overflow-hidden aspect-square">
                          <img src={p.preview!} alt="Progress" className="w-full h-full object-cover" />
                          <button onClick={() => removeProgressPhoto('after', i)} className="absolute top-1 right-1 p-0.5 bg-black/60 rounded-full text-white"><X size={10} /></button>
                        </div>
                      ))}
                    </div>
                  )}
                  <input ref={progressAfterInputRef} type="file" accept="image/*" multiple className="hidden"
                    onChange={(e) => { addProgressPhotos(e.target.files, 'after'); e.target.value = ''; }} />
                  <button
                    onClick={() => progressAfterInputRef.current?.click()}
                    className="w-full h-24 rounded-xl border-2 border-dashed border-buddy-text-secondary/20 hover:border-buddy-green/50 flex flex-col items-center justify-center gap-1.5 text-buddy-text-secondary hover:text-buddy-green transition-colors"
                  >
                    <Camera size={20} />
                    <span className="text-sm">{afterPhotos.length ? 'Add more body snaps' : 'Add body snap'}</span>
                  </button>
                </div>
              )}
              <p className="text-[11px] text-buddy-text-secondary">
                Your snaps will be posted as a <span className="text-buddy-green font-medium">progress update</span> and counted in your analytics. Weight is optional.
              </p>
            </div>
          )}

          {/* Editor (text/poll posts) */}
          {kind === 'text' && (
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
              onFocus={() => setShowEmoji(false)}
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
          )}

          {/* Tagged users chips */}
          {kind === 'text' && taggedUsers.length > 0 && (
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
          {kind === 'text' && mediaFiles.length > 0 && (
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
          {kind === 'text' && showLocation && (
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
          {kind === 'text' && showPoll && (
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
                <input type="checkbox" checked={pollAllowMultiple} onChange={e => setPollAllowMultiple(e.target.checked)} className="accent-buddy-green" />
                Allow multiple selections
              </label>
            </div>
          )}

          {/* Emoji picker */}
          {kind === 'text' && showEmoji && (
            <div ref={emojiPickerRef} className="mt-3 relative z-20">
              <EmojiPicker
                theme={Theme.DARK}
                emojiStyle={EmojiStyle.APPLE}
                lazyLoadEmojis
                searchDisabled
                skinTonesDisabled
                height={350}
                width="100%"
                onEmojiClick={(emojiData) => {
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
          {kind === 'text' && (
            <>
          {/* Media */}
          <input
            ref={fileInputRef}
            type="file"
            multiple
            accept={acceptForKind[mediaKind]}
            className="hidden"
            onChange={e => { handleFiles(e.target.files, mediaKind); e.target.value = ''; }}
          />
          <button onClick={() => fileInputRef.current?.click()} disabled={mediaFiles.length >= MAX_MEDIA}
            className="p-2 rounded-full text-buddy-text-secondary hover:text-buddy-green hover:bg-buddy-green/10 transition-colors disabled:opacity-40"
            title="Attach media">
            <Image size={18} />
          </button>

          {/* File type selector */}
          <div className="flex items-center gap-0.5 bg-buddy-surface-raised rounded-full p-0.5 ml-1">
            {([
              { key: 'image' as const, icon: Image, label: 'Photo' },
              { key: 'video' as const, icon: Video, label: 'Video' },
              { key: 'file' as const, icon: FileIcon, label: 'File' },
              { key: 'document' as const, icon: FileText, label: 'Doc' },
            ]).map(({ key, icon: KIcon, label }) => (
              <button key={key} onClick={() => setMediaKind(key)}
                className={`flex items-center gap-1 px-2 py-1 rounded-full text-[11px] font-medium transition-colors ${mediaKind === key ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary hover:text-buddy-text-primary'}`}
                title={`Attach ${label.toLowerCase()}`}>
                <KIcon size={12} />
                <span className="hidden sm:inline">{label}</span>
              </button>
            ))}
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
            </>
          )}

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
              {isSubmitting ? 'Posting...' : kind === 'meal' ? 'Log Meal' : kind === 'progress' ? 'Share' : 'Post'}
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
