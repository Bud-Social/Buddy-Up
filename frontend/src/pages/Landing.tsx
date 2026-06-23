export default function Landing() {
  return (
    <div className="min-h-screen bg-buddy-black">
      <header className="relative overflow-hidden">
        <div className="max-w-6xl mx-auto px-6 pt-20 pb-32 text-center">
          <h1 className="font-display text-5xl md:text-7xl font-extrabold text-white mb-6">
            Find your<br /><span className="text-buddy-green">fitness family.</span>
          </h1>
          <p className="text-lg text-buddy-text-secondary max-w-2xl mx-auto mb-10">
            Train with buddies, join live workouts, eat better, and stay accountable — all in one place.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <a
              href="/signup"
              className="inline-flex items-center justify-center bg-buddy-green text-buddy-black font-semibold px-8 py-4 rounded-xl text-lg hover:bg-buddy-green-deep transition-colors"
            >
              Get Started — It's Free
            </a>
            <a
              href="#how-it-works"
              className="inline-flex items-center justify-center border border-buddy-text-secondary/30 text-buddy-text-primary px-8 py-4 rounded-xl text-lg hover:bg-buddy-surface transition-colors"
            >
              Watch how it works
            </a>
          </div>
          <p className="mt-8 text-sm text-buddy-text-secondary">
            Join 500,000+ people already training together
          </p>
        </div>
      </header>

      <section className="max-w-6xl mx-auto px-6 py-20">
        <div className="grid md:grid-cols-3 gap-8">
          {[
            { emoji: '🤝', title: 'Find Your Buddy', desc: 'Connect with people who match your fitness level, goals, and schedule.' },
            { emoji: '📡', title: 'Live Workouts, Anytime', desc: 'Drop into a live HIIT class, run a yoga session, or join a random workout at any time.' },
            { emoji: '🏋️', title: 'Gyms Built Around You', desc: 'Create or join communities (gyms) that keep you accountable and motivated.' },
          ].map(({ emoji, title, desc }) => (
            <div key={title} className="bg-buddy-surface rounded-2xl p-8 text-center">
              <div className="text-4xl mb-4">{emoji}</div>
              <h3 className="font-heading text-xl font-semibold mb-2">{title}</h3>
              <p className="text-buddy-text-secondary">{desc}</p>
            </div>
          ))}
        </div>
      </section>

      <footer className="border-t border-buddy-surface py-12 text-center text-sm text-buddy-text-secondary">
        <div className="max-w-6xl mx-auto px-6 flex flex-wrap justify-center gap-6 mb-4">
          <a href="/terms" className="hover:text-buddy-text-primary">Terms</a>
          <a href="/privacy" className="hover:text-buddy-text-primary">Privacy</a>
          <a href="/community-guidelines" className="hover:text-buddy-text-primary">Community Guidelines</a>
          <a href="/cookie-policy" className="hover:text-buddy-text-primary">Cookies</a>
        </div>
        <p>&copy; 2025 BuddyUp. All rights reserved.</p>
      </footer>
    </div>
  );
}
