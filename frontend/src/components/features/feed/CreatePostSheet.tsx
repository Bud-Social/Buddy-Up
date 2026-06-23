import { useState, useRef } from 'react';
import { X, Image, Camera, Dumbbell, Utensils, BarChart3, Send, MapPin } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Avatar } from '@/components/ui/Avatar';
import { Input } from '@/components/ui/Input';
import { feedApi } from '@/api';
import { useAuthStore } from '@/store/authStore';

type PostType = 'text' | 'photo' | 'workout_log' | 'meal' | 'progress';

interface CreatePostSheetProps {
  isOpen: boolean;
  onClose: () => void;
}

export function CreatePostSheet({ isOpen, onClose }: CreatePostSheetProps) {
  const profile = useAuthStore((s) => s.profile);
  const [postType, setPostType] = useState<PostType>('text');
  const [body, setBody] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [selectedFiles, setSelectedFiles] = useState<File[]>([]);
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Workout log state
  const [exercise, setExercise] = useState('');
  const [sets, setSets] = useState('');
  const [reps, setReps] = useState('');
  const [calories, setCalories] = useState('');

  // Meal state
  const [mealType, setMealType] = useState('Breakfast');
  const [protein, setProtein] = useState('');
  const [carbs, setCarbs] = useState('');
  const [fats, setFats] = useState('');

  const handleSubmit = async () => {
    setIsLoading(true);
    try {
      let workoutData = null;
      let mealData = null;
      let progressData = null;

      if (postType === 'workout_log') {
        workoutData = { exercise, sets, reps, calories: calories || '0' };
      } else if (postType === 'meal') {
        mealData = { meal_type: mealType, protein: parseInt(protein) || 0, carbs: parseInt(carbs) || 0, fats: parseInt(fats) || 0 };
      }

      const formData = new FormData();
      formData.append('post_type', postType);
      formData.append('body', body);
      if (workoutData) formData.append('workout_log_data', JSON.stringify(workoutData));
      if (mealData) formData.append('meal_data', JSON.stringify(mealData));
      selectedFiles.forEach((f) => formData.append('media', f));

      await feedApi.createPost(formData);
      onClose();
      resetForm();
    } catch {} finally { setIsLoading(false); }
  };

  const resetForm = () => {
    setBody(''); setPostType('text'); setSelectedFiles([]);
    setExercise(''); setSets(''); setReps(''); setCalories('');
    setMealType('Breakfast'); setProtein(''); setCarbs(''); setFats('');
  };

  if (!isOpen) return null;

  const types: { type: PostType; icon: typeof Image; label: string }[] = [
    { type: 'text', icon: Image, label: 'Text' },
    { type: 'photo', icon: Image, label: 'Photo' },
    { type: 'workout_log', icon: Dumbbell, label: 'Workout' },
    { type: 'meal', icon: Utensils, label: 'Meal' },
    { type: 'progress', icon: BarChart3, label: 'Progress' },
  ];

  return (
    <div className="fixed inset-0 z-50 flex flex-col bg-buddy-black">
      <div className="flex items-center justify-between p-4 border-b border-buddy-surface">
        <button onClick={onClose} className="p-1 rounded-lg hover:bg-buddy-surface text-buddy-text-secondary">
          <X size={22} />
        </button>
        <h2 className="font-heading font-semibold">New Post</h2>
        <Button size="sm" onClick={handleSubmit} isLoading={isLoading} disabled={!body.trim() && selectedFiles.length === 0}>
          Post
        </Button>
      </div>

      <div className="flex overflow-x-auto gap-2 px-4 py-3 border-b border-buddy-surface scrollbar-hide">
        {types.map(({ type, icon: Icon, label }) => (
          <button key={type} onClick={() => setPostType(type)}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium transition-colors whitespace-nowrap ${
              postType === type ? 'bg-buddy-green text-buddy-black' : 'text-buddy-text-secondary hover:text-buddy-text-primary border border-buddy-surface'
            }`}
          >
            <Icon size={14} /> {label}
          </button>
        ))}
      </div>

      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        <div className="flex gap-3">
          <Avatar src={profile?.avatar_url} alt={profile?.display_name || 'You'} size="md" />
          <textarea
            value={body}
            onChange={(e) => setBody(e.target.value)}
            placeholder={postType === 'workout_log' ? 'How was your workout?' : postType === 'meal' ? 'What did you eat?' : "What's on your mind?"}
            className="flex-1 bg-transparent text-sm text-buddy-text-primary placeholder:text-buddy-text-secondary/50 resize-none focus:outline-none min-h-[100px]"
            maxLength={500}
          />
        </div>

        {postType === 'photo' && (
          <div>
            <button onClick={() => fileInputRef.current?.click()}
              className="w-full border-2 border-dashed border-buddy-surface rounded-xl p-8 text-center text-buddy-text-secondary hover:border-buddy-green/30 transition-colors">
              <Image size={32} className="mx-auto mb-2" />
              <p className="text-sm">Add photos or videos</p>
            </button>
            <input ref={fileInputRef} type="file" accept="image/*,video/*" multiple className="hidden"
              onChange={(e) => setSelectedFiles(Array.from(e.target.files || []))} />
            {selectedFiles.length > 0 && (
              <div className="grid grid-cols-3 gap-2 mt-3">
                {selectedFiles.map((f, i) => (
                  <div key={i} className="aspect-square bg-buddy-surface rounded-lg overflow-hidden">
                    <img src={URL.createObjectURL(f)} alt="" className="w-full h-full object-cover" />
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {postType === 'workout_log' && (
          <div className="space-y-3 bg-buddy-surface rounded-xl p-4">
            <Input label="Exercise" value={exercise} onChange={(e) => setExercise(e.target.value)} placeholder="e.g., Deadlift" />
            <div className="grid grid-cols-3 gap-3">
              <Input label="Sets" type="number" value={sets} onChange={(e) => setSets(e.target.value)} placeholder="3" />
              <Input label="Reps" type="number" value={reps} onChange={(e) => setReps(e.target.value)} placeholder="10" />
              <Input label="Calories" type="number" value={calories} onChange={(e) => setCalories(e.target.value)} placeholder="200" />
            </div>
          </div>
        )}

        {postType === 'meal' && (
          <div className="space-y-3 bg-buddy-surface rounded-xl p-4">
            <div>
              <label className="block text-sm font-medium text-buddy-text-secondary mb-1.5">Meal Type</label>
              <div className="flex flex-wrap gap-2">
                {['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Pre-workout', 'Post-workout'].map((m) => (
                  <button key={m} onClick={() => setMealType(m)}
                    className={`px-3 py-1.5 rounded-full text-xs transition-colors ${
                      mealType === m ? 'bg-buddy-green text-buddy-black font-medium' : 'border border-buddy-surface text-buddy-text-secondary hover:text-buddy-text-primary'
                    }`}
                  >{m}</button>
                ))}
              </div>
            </div>
            <div className="grid grid-cols-3 gap-3">
              <Input label="Protein (g)" type="number" value={protein} onChange={(e) => setProtein(e.target.value)} placeholder="30" />
              <Input label="Carbs (g)" type="number" value={carbs} onChange={(e) => setCarbs(e.target.value)} placeholder="40" />
              <Input label="Fats (g)" type="number" value={fats} onChange={(e) => setFats(e.target.value)} placeholder="15" />
            </div>
          </div>
        )}

        {postType === 'progress' && (
          <div className="bg-buddy-surface rounded-xl p-4 text-center text-buddy-text-secondary text-sm">
            <BarChart3 size={32} className="mx-auto mb-2 text-buddy-electric" />
            <p>Upload before and after photos with stats</p>
          </div>
        )}
      </div>
    </div>
  );
}
