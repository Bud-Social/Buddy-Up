import { useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { useCallStore } from '@/store/callStore';
import { Phone, Video, PhoneOff } from 'lucide-react';
import { Avatar } from '@/components/ui/Avatar';
import { playRingtone } from '@/lib/ringtone';

export function IncomingCallOverlay() {
  const { pendingCall, setPendingCall } = useCallStore();
  const navigate = useNavigate();
  const stopRingtoneRef = useRef<(() => void) | null>(null);

  useEffect(() => {
    if (pendingCall) {
      // Start Web Audio ringtone
      try {
        stopRingtoneRef.current = playRingtone();
      } catch {
        // Audio context may be blocked until user interaction
      }

      // Auto dismiss after 30 seconds if unanswered
      const timer = setTimeout(() => {
        setPendingCall(null);
      }, 30000);

      return () => {
        clearTimeout(timer);
        stopRingtoneRef.current?.();
        stopRingtoneRef.current = null;
      };
    }
  }, [pendingCall, setPendingCall]);

  if (!pendingCall) return null;

  const stopRing = () => {
    stopRingtoneRef.current?.();
    stopRingtoneRef.current = null;
  };

  const handleAccept = () => {
    stopRing();
    // Store the incoming offer so Messages.tsx WebRTC can pick it up
    (window as any).__buddyup_pending_offer = pendingCall.data?.sdp;
    (window as any).__buddyup_call_type = pendingCall.call_type;
    setPendingCall(null);
    navigate(`/messages?c=${pendingCall.conversation_id}`);
  };

  const handleDecline = () => {
    stopRing();
    setPendingCall(null);
  };

  return (
    <div className="fixed top-6 left-1/2 -translate-x-1/2 z-[200] w-full max-w-sm px-4 pointer-events-none">
      <div className="bg-gray-950 border border-gray-800 shadow-2xl shadow-black/60 rounded-3xl p-4 pointer-events-auto">
        {/* Pulse ring animation */}
        <div className="relative flex items-center gap-3.5">
          <div className="relative shrink-0">
            <div className="absolute inset-0 rounded-full bg-buddy-green/20 animate-ping" />
            <Avatar
              src={pendingCall.from_avatar_url}
              alt={pendingCall.from_display_name}
              size="md"
              className="relative ring-2 ring-buddy-green/40"
            />
          </div>

          <div className="flex-1 min-w-0">
            <p className="font-bold text-white text-sm truncate">{pendingCall.from_display_name}</p>
            <p className="text-xs text-buddy-green font-medium animate-pulse">
              Incoming {pendingCall.call_type === 'video' ? 'video' : 'voice'} call
            </p>
          </div>

          {/* Action buttons */}
          <div className="flex items-center gap-2.5 shrink-0">
            <button
              onClick={handleDecline}
              className="w-11 h-11 rounded-full bg-red-500/20 border border-red-500/30 text-red-400 flex items-center justify-center hover:bg-red-500/30 transition-all hover:scale-105 active:scale-95"
              title="Decline"
            >
              <PhoneOff size={18} />
            </button>
            <button
              onClick={handleAccept}
              className="w-11 h-11 rounded-full bg-buddy-green/20 border border-buddy-green/40 text-buddy-green flex items-center justify-center hover:bg-buddy-green/30 transition-all hover:scale-105 active:scale-95"
              title="Accept"
            >
              {pendingCall.call_type === 'video' ? <Video size={18} /> : <Phone size={18} />}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
