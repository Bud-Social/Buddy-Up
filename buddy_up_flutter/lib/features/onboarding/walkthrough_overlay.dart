import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';

const String walkthroughSeenKey = 'buddyup-walkthrough-seen';

/// True until the user has completed or skipped the first-run walkthrough.
Future<bool> shouldShowWalkthrough() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(walkthroughSeenKey) != '1';
}

Future<void> markWalkthroughSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(walkthroughSeenKey, '1');
}

class _WalkthroughStep {
  final IconData icon;
  final String title;
  final String body;
  final Color color;

  const _WalkthroughStep(this.icon, this.title, this.body, this.color);
}

/// Web-parity first-run walkthrough (`WalkthroughOverlay.tsx`), shown once
/// after onboarding when the feed is opened with `?walkthrough=1`.
class WalkthroughOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const WalkthroughOverlay({super.key, required this.onClose});

  @override
  State<WalkthroughOverlay> createState() => _WalkthroughOverlayState();
}

class _WalkthroughOverlayState extends State<WalkthroughOverlay> {
  static const _steps = <_WalkthroughStep>[
    _WalkthroughStep(
      LucideIcons.footprints,
      'Find your buddy',
      'See nearby people looking for the same activity you are. Match, chat, and move together.',
      BuddyColors.green,
    ),
    _WalkthroughStep(
      LucideIcons.timer,
      'Track your streak',
      'Create a countdown for sobriety, gym days, or walking. Check in daily or let BuddyUp auto-track.',
      BuddyColors.gold,
    ),
    _WalkthroughStep(
      LucideIcons.share2,
      'Share your progress',
      'Post your workouts, countdowns, and wins to the feed. Your community is waiting.',
      BuddyColors.electric,
    ),
  ];

  int _step = 0;
  bool _dismissing = false;

  Future<void> _dismiss() async {
    if (_dismissing) return;
    _dismissing = true;
    await markWalkthroughSeen();
    if (mounted) widget.onClose();
  }

  void _next() {
    if (_step == _steps.length - 1) {
      _dismiss();
    } else {
      setState(() => _step++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_step];
    final isLast = _step == _steps.length - 1;

    return Material(
      color: Colors.black.withValues(alpha: 0.8),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: BuddyColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: BuddyColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 40,
                      offset: Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Welcome to BuddyUp',
                            style: TextStyle(
                              color: BuddyColors.textPrimary,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close walkthrough',
                          onPressed: _dismiss,
                          icon: const Icon(
                            LucideIcons.x,
                            size: 20,
                            color: BuddyColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: step.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(step.icon, size: 32, color: step.color),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      step.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: BuddyColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step.body,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: BuddyColors.textSecondary,
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < _steps.length; i++)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i <= _step
                                  ? BuddyColors.green
                                  : BuddyColors.border,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          '${_step + 1} of ${_steps.length}',
                          style: const TextStyle(
                            color: BuddyColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _dismiss,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: BuddyColors.textSecondary,
                              side: const BorderSide(color: BuddyColors.border),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Skip for now',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _next,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: BuddyColors.green,
                              foregroundColor: BuddyColors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isLast ? "Let's go" : 'Next',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(LucideIcons.chevronRight, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
