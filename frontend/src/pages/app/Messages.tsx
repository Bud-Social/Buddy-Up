import { MessageCircle } from 'lucide-react';

export default function Messages() {
  return (
    <div className="max-w-lg mx-auto p-4">
      <h1 className="font-display text-2xl font-extrabold mb-6">Messages</h1>
      <div className="bg-buddy-surface rounded-2xl p-6 text-center">
        <MessageCircle size={48} className="mx-auto text-buddy-text-secondary/30 mb-4" />
        <p className="text-buddy-text-secondary">No messages yet</p>
        <p className="text-buddy-text-secondary/50 text-sm mt-1">
          Buddy up with someone to start a conversation.
        </p>
      </div>
    </div>
  );
}
