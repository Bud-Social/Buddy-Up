/**
 * AttachmentMenu – rich attachment picker sheet (WhatsApp/iMessage style).
 * Supports: Photos, Camera, Video, Document, Location, Poll, Events.
 */
import { useRef, useState } from 'react';
import {
  Image as ImageIcon,
  Camera,
  Video,
  FileText,
  MapPin,
  BarChart2,
  Calendar,
  X,
  Mic,
} from 'lucide-react';

interface LocationResult {
  lat: number;
  lng: number;
  label: string;
  mapUrl: string;
}

interface PollData {
  question: string;
  options: string[];
}

interface AttachmentMenuProps {
  onFile: (file: File) => void;
  onLocation: (loc: LocationResult) => void;
  onPoll: (poll: PollData) => void;
  onEvent: () => void;
  onVoiceNote: () => void;
  onClose: () => void;
}

const ITEMS = [
  { id: 'photo', label: 'Photo', icon: ImageIcon, color: '#7C3AED', accept: 'image/*' },
  { id: 'camera', label: 'Camera', icon: Camera, color: '#2563EB', accept: 'image/*;capture=camera' },
  { id: 'video', label: 'Video', icon: Video, color: '#DC2626', accept: 'video/*' },
  { id: 'audio', label: 'Audio', icon: Mic, color: '#10B981', accept: 'audio/*' },
  { id: 'document', label: 'Document', icon: FileText, color: '#D97706', accept: '.pdf,.doc,.docx,.xls,.xlsx,.txt,.csv,.zip' },
  { id: 'voice', label: 'Voice Note', icon: Mic, color: '#059669', accept: null },
  { id: 'location', label: 'Location', icon: MapPin, color: '#0891B2', accept: null },
  { id: 'poll', label: 'Poll', icon: BarChart2, color: '#7C3AED', accept: null },
  { id: 'event', label: 'Event', icon: Calendar, color: '#DB2777', accept: null },
] as const;

export function AttachmentMenu({ onFile, onLocation, onPoll, onEvent, onVoiceNote, onClose }: AttachmentMenuProps) {
  const fileRef = useRef<HTMLInputElement>(null);
  const [accept, setAccept] = useState('*/*');
  const [showPollModal, setShowPollModal] = useState(false);
  const [pollQuestion, setPollQuestion] = useState('');
  const [pollOptions, setPollOptions] = useState(['', '']);
  const [locLoading, setLocLoading] = useState(false);

  const handleItemClick = async (id: string, itemAccept: string | null) => {
    if (id === 'location') {
      setLocLoading(true);
      try {
        const pos = await new Promise<GeolocationPosition>((res, rej) =>
          navigator.geolocation.getCurrentPosition(res, rej, { timeout: 10000 }),
        );
        const { latitude: lat, longitude: lng } = pos.coords;
        const label = `${lat.toFixed(5)}, ${lng.toFixed(5)}`;
        // Use OpenStreetMap static map preview
        const mapUrl = `https://static-maps.yandex.ru/1.x/?lang=en_US&ll=${lng},${lat}&z=15&l=map&size=450,200&pt=${lng},${lat},pm2rdm`;
        onLocation({ lat, lng, label, mapUrl });
        onClose();
      } catch {
        alert('Could not get your location. Please allow location access.');
      } finally {
        setLocLoading(false);
      }
      return;
    }
    if (id === 'poll') {
      setShowPollModal(true);
      return;
    }
    if (id === 'event') {
      onEvent();
      onClose();
      return;
    }
    if (id === 'voice') {
      onVoiceNote();
      onClose();
      return;
    }
    if (itemAccept) {
      setAccept(itemAccept);
      setTimeout(() => fileRef.current?.click(), 50);
    }
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      onFile(file);
      onClose();
    }
    e.target.value = '';
  };

  const submitPoll = () => {
    const validOpts = pollOptions.filter((o) => o.trim());
    if (!pollQuestion.trim() || validOpts.length < 2) {
      alert('Please add a question and at least 2 options.');
      return;
    }
    onPoll({ question: pollQuestion.trim(), options: validOpts });
    setShowPollModal(false);
    onClose();
  };

  return (
    <>
      {/* Backdrop */}
      <div className="fixed inset-0 z-30" onClick={onClose} />

      {/* Menu Sheet */}
      <div className="absolute bottom-full left-0 w-[340px] mb-2 z-40 bg-buddy-black border border-buddy-surface rounded-3xl shadow-2xl overflow-hidden animate-in slide-in-from-bottom-4 duration-200">
        <div className="flex items-center justify-between px-5 pt-4 pb-2">
          <h3 className="font-semibold text-sm text-buddy-text-secondary">Share</h3>
          <button onClick={onClose} className="p-1 text-buddy-text-secondary hover:text-white rounded-full">
            <X size={18} />
          </button>
        </div>

        <div className="grid grid-cols-4 gap-0 px-2 pb-4">
          {ITEMS.map((item) => {
            const Icon = item.icon;
            return (
              <button
                key={item.id}
                onClick={() => handleItemClick(item.id, item.accept)}
                disabled={item.id === 'location' && locLoading}
                className="flex flex-col items-center gap-2 p-4 rounded-2xl hover:bg-buddy-surface transition-colors"
              >
                <div
                  className="w-12 h-12 rounded-2xl flex items-center justify-center shadow-md"
                  style={{ backgroundColor: item.color + '22', border: `1.5px solid ${item.color}44` }}
                >
                  {item.id === 'location' && locLoading ? (
                    <div className="w-5 h-5 border-2 border-cyan-400 border-t-transparent rounded-full animate-spin" />
                  ) : (
                    <Icon size={22} style={{ color: item.color }} />
                  )}
                </div>
                <span className="text-[11px] text-buddy-text-secondary font-medium">{item.label}</span>
              </button>
            );
          })}
        </div>

        <input
          ref={fileRef}
          type="file"
          accept={accept}
          className="hidden"
          onChange={handleFileChange}
        />
      </div>

      {/* Poll Modal */}
      {showPollModal && (
        <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/60 backdrop-blur-sm p-4" onClick={(e) => e.target === e.currentTarget && setShowPollModal(false)}>
          <div className="w-full max-w-md bg-buddy-surface-raised rounded-3xl p-6 space-y-4 shadow-2xl">
            <div className="flex items-center justify-between">
              <h3 className="text-lg font-bold font-heading">Create Poll</h3>
              <button onClick={() => setShowPollModal(false)} className="p-1 text-buddy-text-secondary hover:text-white rounded-full">
                <X size={20} />
              </button>
            </div>

            <div>
              <label className="text-xs text-buddy-text-secondary mb-1 block font-medium">Question</label>
              <input
                autoFocus
                value={pollQuestion}
                onChange={(e) => setPollQuestion(e.target.value)}
                placeholder="Ask something..."
                className="w-full bg-buddy-surface border border-buddy-surface rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/50"
              />
            </div>

            <div className="space-y-2">
              <label className="text-xs text-buddy-text-secondary mb-1 block font-medium">Options</label>
              {pollOptions.map((opt, i) => (
                <div key={i} className="flex gap-2">
                  <input
                    value={opt}
                    onChange={(e) => {
                      const next = [...pollOptions];
                      next[i] = e.target.value;
                      setPollOptions(next);
                    }}
                    placeholder={`Option ${i + 1}`}
                    className="flex-1 bg-buddy-surface border border-buddy-surface rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-buddy-green/50"
                  />
                  {pollOptions.length > 2 && (
                    <button
                      onClick={() => setPollOptions(pollOptions.filter((_, j) => j !== i))}
                      className="p-2 text-buddy-text-secondary hover:text-buddy-red"
                    >
                      <X size={16} />
                    </button>
                  )}
                </div>
              ))}
              {pollOptions.length < 6 && (
                <button
                  onClick={() => setPollOptions([...pollOptions, ''])}
                  className="w-full text-sm text-buddy-green hover:text-buddy-green-deep py-2 font-medium"
                >
                  + Add option
                </button>
              )}
            </div>

            <button
              onClick={submitPoll}
              className="w-full bg-buddy-green text-buddy-black font-bold py-3 rounded-2xl hover:bg-buddy-green-deep transition-colors"
            >
              Send Poll
            </button>
          </div>
        </div>
      )}
    </>
  );
}
