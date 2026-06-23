import { useState } from 'react';

type FeedTab = 'for_you' | 'following' | 'nearby';

const tabs: { key: FeedTab; label: string }[] = [
  { key: 'for_you', label: 'For You' },
  { key: 'following', label: 'Following' },
  { key: 'nearby', label: 'Nearby' },
];

export default function Feed() {
  const [activeTab, setActiveTab] = useState<FeedTab>('for_you');

  return (
    <div className="max-w-lg mx-auto">
      <div className="sticky top-0 z-10 bg-buddy-black/95 backdrop-blur-lg border-b border-buddy-surface px-4 py-3">
        <div className="flex gap-1 bg-buddy-surface rounded-xl p-1">
          {tabs.map(({ key, label }) => (
            <button
              key={key}
              onClick={() => setActiveTab(key)}
              className={`flex-1 py-2 text-sm font-medium rounded-lg transition-colors ${
                activeTab === key
                  ? 'bg-buddy-green text-buddy-black'
                  : 'text-buddy-text-secondary hover:text-buddy-text-primary'
              }`}
            >
              {label}
            </button>
          ))}
        </div>
      </div>

      <div className="p-4 space-y-6">
        <div className="text-center py-20">
          <p className="text-buddy-text-secondary text-lg">No posts yet</p>
          <p className="text-buddy-text-secondary/50 text-sm mt-1">
            Posts from your buddies and followed trainers will appear here.
          </p>
        </div>
      </div>
    </div>
  );
}
