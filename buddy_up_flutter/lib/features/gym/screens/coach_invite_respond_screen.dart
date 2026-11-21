import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/error_view.dart';
import '../providers/gym_provider.dart';

/// Screen a coach lands on when they tap the "you have been invited as an
/// online coach" notification — one decision, nothing else.
///
/// Sending a coach to the full manage console would show them a
/// "not permitted" notice for the roster and nothing else; this keeps the
/// single meaningful action in front of them instead.
class CoachInviteRespondScreen extends ConsumerStatefulWidget {
  final String slug;
  final String coachId;

  const CoachInviteRespondScreen({
    super.key,
    required this.slug,
    required this.coachId,
  });

  @override
  ConsumerState<CoachInviteRespondScreen> createState() =>
      _CoachInviteRespondScreenState();
}

class _CoachInviteRespondScreenState
    extends ConsumerState<CoachInviteRespondScreen> {
  bool _submitting = false;
  bool _done = false;
  String? _error;
  String _gymName = '';
  String? _loadedFromArgs;

  @override
  void initState() {
    super.initState();
    _loadGym();
  }

  Future<void> _loadGym() async {
    if (_loadedFromArgs != null) return;
    try {
      final raw = await ref.read(gymRepositoryProvider).getGym(widget.slug);
      final data = raw is Map<String, dynamic> ? raw['data'] : raw;
      if (mounted) {
        setState(() {
          _gymName = (data as Map)['name'] as String? ?? widget.slug;
          _loadedFromArgs = 'done';
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadedFromArgs = 'done');
    }
  }

  Future<void> _respond(String action) async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(gymRepositoryProvider).respondCoachInvite(
            widget.slug,
            widget.coachId,
            {'action': action},
          );
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _done = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.toString().contains('403')
            ? 'Only the invited coach can respond to this invite.'
            : 'Could not send your response. Check your connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadedFromArgs == null) return const PageLoader();

    return Scaffold(
      appBar: AppBar(title: const Text('Coach invitation')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _done
            ? _buildDone()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: BuddyColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.fitness_center,
                                color: BuddyColors.green, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _gymName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'asked you to be listed as an online coach.',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Accepting makes your membership a trainer role and '
                          'lists you in the gym’s online roster with the coach '
                          'badge on the member list.',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.55),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Accept invite'),
                    style: FilledButton.styleFrom(
                      backgroundColor: BuddyColors.green,
                      foregroundColor: Theme.of(context).colorScheme.surface,
                      minimumSize: const Size.fromHeight(52),
                    ),
                    onPressed:
                        _submitting ? null : () => _respond('accept'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Decline'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      foregroundColor: BuddyColors.red,
                    ),
                    onPressed:
                        _submitting ? null : () => _respond('decline'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    ErrorView(message: _error!, onRetry: () => setState(() => _error = null)),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildDone() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_outline,
            color: BuddyColors.green, size: 64),
        const SizedBox(height: 16),
        Text(
          _gymName.isNotEmpty
              ? 'Done. $_gymName has been notified.'
              : 'Your response was sent.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Text(
          'Thank you.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface
                .withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: () => context.go('/gyms'),
          child: const Text('Back to gyms'),
        ),
      ],
    );
  }
}
