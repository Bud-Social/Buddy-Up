import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeft, CheckCircle, Circle, Clock, Flame, ShieldAlert, Star, PlayCircle, Zap } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { useToast } from '@/components/ui/Toast';
import { marketplaceApi } from '@/api/marketplace';

export default function ProgrammeActivityFocus() {
  const { programmeId, weekKey, dayKey, activityIndex } = useParams();
  const navigate = useNavigate();
  const { toast } = useToast();
  
  const [programme, setProgramme] = useState<any>(null);
  const [activity, setActivity] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [isCompleted, setIsCompleted] = useState(false);
  const [completing, setCompleting] = useState(false);

  useEffect(() => {
    if (!programmeId || !weekKey || !dayKey || !activityIndex) return;
    
    setLoading(true);
    marketplaceApi.getProgramme(programmeId)
      .then(res => {
        const prog = res.data;
        setProgramme(prog);
        
        // Extract the specific activity
        if (prog.schedule && prog.schedule[weekKey] && prog.schedule[weekKey][dayKey]) {
          const acts = prog.schedule[weekKey][dayKey];
          const act = acts[parseInt(activityIndex, 10)];
          if (act) {
            setActivity(act);
            // Optionally fetch progress from backend here if implemented
            // For now, default to false
          } else {
            toast('error', 'Activity not found');
            navigate(-1);
          }
        }
      })
      .catch(() => navigate('/marketplace'))
      .finally(() => setLoading(false));
  }, [programmeId, weekKey, dayKey, activityIndex, navigate, toast]);

  const toggleCompletion = async () => {
    setCompleting(true);
    try {
      // If backend was fully implemented for progress:
      // await marketplaceApi.updateActivityProgress(programmeId, weekKey, dayKey, activityIndex, !isCompleted);
      
      // Simulate network request
      await new Promise(r => setTimeout(r, 500));
      
      setIsCompleted(!isCompleted);
      if (!isCompleted) {
        toast('success', 'Workout completed! Great job! 🎉');
      }
    } catch {
      toast('error', 'Failed to update progress');
    } finally {
      setCompleting(false);
    }
  };

  if (loading) {
    return (
      <div className="max-w-xl mx-auto p-4 animate-pulse">
        <div className="h-10 w-10 bg-buddy-surface rounded-xl mb-6" />
        <div className="h-8 w-3/4 bg-buddy-surface rounded mb-4" />
        <div className="h-64 bg-buddy-surface rounded-xl mb-6" />
        <div className="space-y-3">
          <div className="h-4 w-full bg-buddy-surface rounded" />
          <div className="h-4 w-full bg-buddy-surface rounded" />
          <div className="h-4 w-3/4 bg-buddy-surface rounded" />
        </div>
      </div>
    );
  }

  if (!activity || !programme) return null;

  return (
    <div className="max-w-xl mx-auto p-4 pb-24">
      <div className="flex items-center justify-between mb-6">
        <button onClick={() => navigate(-1)} className="p-2 rounded-xl bg-buddy-surface hover:bg-buddy-surface-raised transition-colors">
          <ArrowLeft size={20} />
        </button>
        <Badge variant="electric" label={`${weekKey?.replace('_', ' ')} • ${dayKey?.replace('_', ' ')}`} size="sm" className="capitalize shadow-[0_0_10px_rgba(23,154,248,0.3)]" />
      </div>

      <div className="mb-6">
        <h1 className="font-display text-3xl font-extrabold tracking-tight mb-2 leading-tight text-white">
          {activity.title || 'Workout Session'}
        </h1>
        <div className="flex flex-wrap gap-2">
          <Badge variant="blue" label={`${activity.duration_mins} min`} size="sm" />
          {activity.timing && <Badge variant="silver" label={activity.timing} size="sm" className="capitalize" />}
          <Badge variant="green" label={programme.title} size="sm" />
        </div>
      </div>

      {activity.video_url && (
        <Card className="p-0 overflow-hidden mb-6 border-buddy-electric/30 shadow-[0_0_15px_rgba(23,154,248,0.15)] group relative cursor-pointer" onClick={() => window.open(activity.video_url, '_blank', 'noopener,noreferrer')}>
          <div className="aspect-video bg-buddy-black relative flex items-center justify-center">
            {/* If it's a youtube link, we could embed iframe. For simplicity, we just provide a link with a play button overlay */}
            <div className="absolute inset-0 bg-gradient-to-t from-buddy-black/80 to-transparent z-10" />
            <img src={programme.cover_image_url} alt="Video Thumbnail" className="w-full h-full object-cover opacity-40 group-hover:scale-105 transition-transform duration-500" />
            <div className="absolute z-20 flex flex-col items-center">
              <PlayCircle size={64} className="text-buddy-electric drop-shadow-[0_0_15px_rgba(23,154,248,0.8)] group-hover:scale-110 transition-transform duration-300" />
              <p className="mt-3 font-bold text-sm tracking-widest uppercase text-white shadow-sm">Watch Video</p>
            </div>
          </div>
        </Card>
      )}

      <div className="space-y-6">
        <div>
          <h3 className="font-bold text-lg mb-3 flex items-center gap-2"><Zap size={20} className="text-buddy-electric" /> The Workout</h3>
          <Card className="p-5 border-none bg-buddy-surface/50 backdrop-blur-md">
            <p className="text-sm text-buddy-text-secondary whitespace-pre-wrap leading-relaxed">{activity.description || 'No description provided for this session.'}</p>
          </Card>
        </div>

        {(activity.tips || activity.warnings) && (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {activity.tips && (
              <Card className="p-4 border-buddy-gold/20 bg-buddy-gold/5">
                <div className="flex items-start gap-3">
                  <div className="w-8 h-8 rounded-full bg-buddy-gold/20 flex items-center justify-center shrink-0">
                    <Star size={16} className="text-buddy-gold fill-buddy-gold" />
                  </div>
                  <div>
                    <p className="font-bold text-sm text-buddy-gold mb-1">Pro Tips</p>
                    <p className="text-xs text-buddy-text-secondary leading-relaxed">{activity.tips}</p>
                  </div>
                </div>
              </Card>
            )}
            
            {activity.warnings && (
              <Card className="p-4 border-buddy-red/20 bg-buddy-red/5">
                <div className="flex items-start gap-3">
                  <div className="w-8 h-8 rounded-full bg-buddy-red/20 flex items-center justify-center shrink-0">
                    <ShieldAlert size={16} className="text-buddy-red" />
                  </div>
                  <div>
                    <p className="font-bold text-sm text-buddy-red mb-1">Caution</p>
                    <p className="text-xs text-buddy-text-secondary leading-relaxed">{activity.warnings}</p>
                  </div>
                </div>
              </Card>
            )}
          </div>
        )}
      </div>

      <div className="fixed bottom-0 left-0 right-0 p-4 bg-buddy-black/95 backdrop-blur-xl border-t border-buddy-surface flex justify-center z-50">
        <div className="w-full max-w-xl">
          <Button 
            className={`w-full h-14 text-lg font-bold shadow-lg transition-all ${isCompleted ? 'bg-buddy-surface border-2 border-buddy-green text-buddy-green shadow-[0_0_15px_rgba(23,248,154,0.3)]' : 'bg-buddy-electric text-buddy-black hover:bg-buddy-electric/90 shadow-[0_0_15px_rgba(23,154,248,0.3)]'}`}
            onClick={toggleCompletion}
            isLoading={completing}
          >
            {isCompleted ? (
              <><CheckCircle size={22} className="mr-2" /> Completed</>
            ) : (
              <><Circle size={22} className="mr-2" /> Mark as Complete</>
            )}
          </Button>
        </div>
      </div>
    </div>
  );
}
