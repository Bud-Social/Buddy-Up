import { useState } from 'react';
import { Footprints, Timer, Share2, X, ChevronRight } from 'lucide-react';

const WALKTHROUGH_KEY = 'buddyup-walkthrough-seen';

const STEPS = [
  {
    icon: Footprints,
    title: 'Find your buddy',
    body: 'See nearby people looking for the same activity you are. Match, chat, and move together.',
    color: 'bg-buddy-green/10 text-buddy-green',
  },
  {
    icon: Timer,
    title: 'Track your streak',
    body: 'Create a countdown for sobriety, gym days, or walking. Check in daily or let BuddyUp auto-track.',
    color: 'bg-buddy-gold/10 text-buddy-gold',
  },
  {
    icon: Share2,
    title: 'Share your progress',
    body: 'Post your workouts, countdowns, and wins to the feed. Your community is waiting.',
    color: 'bg-buddy-electric/10 text-buddy-electric',
  },
];

export function WalkthroughOverlay({ onClose }: { onClose: () => void }) {
  const [currentStep, setCurrentStep] = useState(0);
  const isLast = currentStep === STEPS.length - 1;
  const step = STEPS[currentStep];

  const dismiss = () => {
    localStorage.setItem(WALKTHROUGH_KEY, '1');
    onClose();
  };

  return (
    <div className="fixed inset-0 z-[70] flex items-center justify-center px-4">
      <div className="fixed inset-0 bg-black/80 backdrop-blur-md" />
      <div className="relative bg-buddy-surface rounded-2xl border border-buddy-border p-8 w-full max-w-md z-10 shadow-2xl">
        <div className="flex items-center justify-between mb-6">
          <h2 className="font-display text-xl font-bold text-buddy-text-primary">Welcome to BuddyUp</h2>
          <button
            onClick={dismiss}
            className="text-buddy-text-secondary hover:text-buddy-text-primary transition-colors"
            aria-label="Close walkthrough"
          >
            <X size={20} />
          </button>
        </div>

        <div className="flex justify-center mb-6">
          <div className={`w-16 h-16 rounded-2xl flex items-center justify-center ${step.color}`}>
            <step.icon size={32} />
          </div>
        </div>

        <div className="text-center mb-8">
          <h3 className="font-display text-lg font-bold text-buddy-text-primary mb-2">{step.title}</h3>
          <p className="text-buddy-text-secondary leading-relaxed">{step.body}</p>
        </div>

        <div className="flex items-center justify-center gap-2 mb-8">
          {STEPS.map((_, i) => (
            <div
              key={i}
              className={`w-2 h-2 rounded-full transition-colors ${
                i <= currentStep ? 'bg-buddy-green' : 'bg-buddy-border'
              }`}
            />
          ))}
          <span className="ml-2 text-xs text-buddy-text-secondary">{currentStep + 1} of {STEPS.length}</span>
        </div>

        <div className="flex gap-3">
          <button
            onClick={dismiss}
            className="flex-1 py-3 rounded-xl border border-buddy-border text-buddy-text-secondary hover:bg-buddy-surface/50 transition-colors text-sm font-medium"
          >
            Skip for now
          </button>
          <button
            onClick={() => {
              if (isLast) {
                dismiss();
              } else {
                setCurrentStep(currentStep + 1);
              }
            }}
            className="flex-1 py-3 rounded-xl bg-buddy-green hover:bg-buddy-green/90 text-white text-sm font-medium transition-colors flex items-center justify-center gap-2"
          >
            {isLast ? "Let's go" : 'Next'} <ChevronRight size={16} />
          </button>
        </div>
      </div>
    </div>
  );
}

export function shouldShowWalkthrough(): boolean {
  if (typeof localStorage === 'undefined') return false;
  return localStorage.getItem(WALKTHROUGH_KEY) !== '1';
}
