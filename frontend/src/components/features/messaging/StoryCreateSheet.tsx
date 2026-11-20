import { useCallback, useEffect, useRef, useState } from 'react';
import { X, ImagePlus, Video, Globe, Users, Lock, Dumbbell } from 'lucide-react';

import { Button } from '@/components/ui/Button';
import { messagingApi } from '@/api/messaging';
import { feedApi } from '@/api/feed';
import { useToast } from '@/components/ui/Toast';
import { useAuthStore } from '@/store/authStore';

type Visibility = 'public' | 'buddies' | 'gym_members' | 'private';

const VIS_OPTIONS: { id: Visibility; label: string; icon: typeof Globe }[] = [
  { id: 'public', label: 'Public', icon: Globe },
  { id: 'buddies', label: 'Buddies', icon: Users },
  { id: 'gym_members', label: 'Gym', icon: Dumbbell },
  { id: 'private', label: 'Only me', icon: Lock },
];

interface StoryCreateSheetProps {
  isOpen: boolean;
  onClose: () => void;
  /** Called with the freshly posted moment id so the caller can refetch. */
  onStoryPosted?: (momentId: string) => void;
  /** Render as an Instagram-style fullscreen takeover instead of a sheet. */
  fullscreen?: boolean;
}

/**
 * Instagram-style story creator: attach media (image or video), write an
 * optional caption, pick an audience, and post it as a moment (story).
 */
export function StoryCreateSheet({ isOpen, onClose, onStoryPosted }: StoryCreateSheetProps) {
  const { toast } = useToast();
  const userId = useAuthStore((s) => s.user?.id);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [file, setFile] = useState<File | null>(null);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [caption, setCaption] = useState('');
  const [visibility, setVisibility] = useState<Visibility>('public');
  const [isPosting, setIsPosting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    return () => {
      if (previewUrl) URL.revokeObjectURL(previewUrl);
    };
  }, [previewUrl]);

  useEffect(() => {
    if (!isOpen) return;
    setFile(null);
    setCaption('');
    setVisibility('public');
    setError(null);
  }, [isOpen]);

  const handleFileChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    const picked = e.target.files?.[0];
    if (!picked) return;
    if (!picked.type.startsWith('image/') && !picked.type.startsWith('video/')) {
      setError('Pick a photo or a video.');
      return;
    }
    if (picked.size > 200 * 1024 * 1024) {
      setError('That file is too large (max 200 MB).');
      return;
    }
    setError(null);
    setFile(picked);
    setPreviewUrl(URL.createObjectURL(picked));
  }, []);

  const handlePost = async () => {
    if (!file || isPosting) return;
    setIsPosting(true);
    setError(null);
    try {
      const upload = await messagingApi.uploadAttachment(file);
      const mediaUrl = upload.data?.url ?? (upload as unknown as { url?: string }).url ?? '';
      if (!mediaUrl) throw new Error('Upload returned no URL.');
      const form = new FormData();
      form.append('post_type', 'moment');
      form.append('body', caption.trim());
      form.append('media_urls', JSON.stringify([mediaUrl]));
      form.append('visibility', visibility);
      const created = await feedApi.createPost(form);
      onStoryPosted?.(created?.data?.id ?? '');
      onClose();
      toast('success', 'Story posted!');
    } catch (e: unknown) {
      const msg = (e as { response?: { data?: { message?: string } } })?.response?.data?.message;
      setError(typeof msg === 'string' ? msg : 'Could not post your story. Please try again.');
    } finally {
      setIsPosting(false);
    }
  };

  if (!isOpen) return null;

  const isVideo = file?.type.startsWith('video/');

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70" role="dialog" aria-modal="true" aria-label="Add story">
      <div className="relative w-full h-full bg-buddy-black flex flex-col">
        <div className="absolute top-3 left-3 z-10 flex items-center gap-2 px-3 py-1.5 rounded-full bg-black/50 text-white text-xs">
          Adding to your story
        </div>
        <button
          onClick={onClose}
          className="absolute top-3 right-3 z-10 p-2 rounded-full bg-black/50 text-white hover:bg-black/70 transition-colors"
          aria-label="Close"
        >
          <X size={20} />
        </button>

        {!file ? (
          <div className="flex-1 flex flex-col items-center justify-center gap-5 px-6">
            <div className="w-20 h-20 rounded-2xl bg-buddy-green/20 flex items-center justify-center">
              <ImagePlus size={34} className="text-buddy-green" />
            </div>
            <div className="text-center">
              <h2 className="text-lg font-semibold text-white">Share a moment</h2>
              <p className="text-sm text-buddy-text-secondary mt-1">Photos and short videos, visible for 24 hours.</p>
            </div>
            <Button onClick={() => fileInputRef.current?.click()} className="gap-2">
              <ImagePlus size={18} /> Choose photo or video
            </Button>
            <input
              ref={fileInputRef}
              type="file"
              accept="image/*,video/*"
              className="hidden"
              onChange={handleFileChange}
              aria-label="Upload story media"
            />
            {error && <p className="text-buddy-red text-xs" role="alert">{error}</p>}
          </div>
        ) : (
          <>
            <div className="relative flex-1 min-h-0">
              {isVideo ? (
                <video src={previewUrl ?? ''} className="absolute inset-0 w-full h-full object-contain bg-black" controls autoPlay muted />
              ) : (
                previewUrl && <img src={previewUrl} alt="Preview" className="absolute inset-0 w-full h-full object-cover" />
              )}
            </div>
            <div className="p-3 space-y-2 border-t border-white/10 bg-black/60 backdrop-blur">
              <input
                type="text"
                value={caption}
                onChange={(e) => setCaption(e.target.value)}
                placeholder="Add a caption…"
                className="w-full bg-white/10 text-white placeholder:text-white/40 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-1 focus:ring-buddy-green"
                maxLength={200}
                aria-label="Caption"
              />
              <div className="flex items-center justify-between gap-2">
                <div className="flex gap-1.5">
                  {VIS_OPTIONS.map((opt) => {
                    const Icon = opt.icon;
                    const active = visibility === opt.id;
                    return (
                      <button
                        key={opt.id}
                        onClick={() => setVisibility(opt.id)}
                        aria-pressed={active}
                        className={`flex items-center gap-1.5 px-2.5 py-1.5 rounded-full text-[10px] font-medium transition-colors ${
                          active ? 'bg-buddy-green text-buddy-black' : 'bg-white/10 text-white/80'
                        }`}
                      >
                        <Icon size={12} /> {opt.label}
                      </button>
                    );
                  })}
                </div>
                <Button size="sm" onClick={handlePost} isLoading={isPosting} disabled={!userId}>
                  <Video size={14} className="mr-1" /> Post
                </Button>
              </div>
              {error && <p className="text-buddy-red text-[11px]" role="alert">{error}</p>}
            </div>
          </>
        )}
      </div>
    </div>
  );
}
