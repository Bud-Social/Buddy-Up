import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../buddies/buddy_nearby_provider.dart';

/// "Looking for a buddy" card for profile pages. Without [username] it shows
/// my own card (or a setup CTA); with it, the visibility-aware public card.
class BuddySearchCard extends ConsumerStatefulWidget {
  final String? username;

  const BuddySearchCard({super.key, this.username});

  @override
  ConsumerState<BuddySearchCard> createState() => _BuddySearchCardState();
}

class _BuddySearchCardState extends ConsumerState<BuddySearchCard> {
  Map<String, dynamic>? _data;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final repo = ref.read(profileRepositoryProvider);
      final raw = widget.username == null
          ? await repo.getSearchProfile()
          : await repo.getUserSearchProfile(widget.username!);
      final data = raw['data'];
      if (mounted) {
        setState(() {
          _data = data is Map<String, dynamic> ? data : null;
          _loaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    final d = _data;
    if (d == null) return const SizedBox.shrink();
    final intents = ((d['intents'] as List?) ?? []).map((e) => e.toString()).toList();
    final available = d['available_now'] as bool? ?? false;
    if (intents.isEmpty && !available) {
      if (widget.username != null) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(style: BorderStyle.solid, color: BuddyColors.surfaceRaised),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Text('Let buddies find you for walks, runs, gym sessions…',
                style: TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => context.push('/buddies/nearby'),
              child: const Text('Set up buddy search'),
            ),
          ],
        ),
      );
    }
    final custom = d['custom_intent'] as String? ?? '';
    final searchName = d['display_name'] as String? ?? '';
    final modes = ((d['modes'] as List?) ?? []).map((e) => e.toString()).toList();
    final bio = d['bio'] as String? ?? '';
    final ageBand = d['age_band'] as String? ?? '';
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_search, size: 14, color: BuddyColors.green),
              const SizedBox(width: 6),
              Text(
                  searchName.isNotEmpty ? 'LOOKING FOR A BUDDY · ${searchName.toUpperCase()}' : 'LOOKING FOR A BUDDY',
                  style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
              const Spacer(),
              if (widget.username == null)
                GestureDetector(
                  onTap: () => context.push('/buddies/nearby'),
                  child: const Text('Manage', style: TextStyle(color: BuddyColors.green, fontSize: 12)),
                ),
            ],
          ),
          if (bio.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(bio, style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 13)),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final i in intents)
                _chip(i.replaceAll('_', ' ')),
              if (custom.isNotEmpty) _chip(custom),
              if (available) _chip('Available now'),
              if (ageBand.isNotEmpty) _chip(ageBand),
            ],
          ),
          if (modes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(modes.join(' · ').replaceAll('_', ' '),
                style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _chip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: BuddyColors.green.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label, style: const TextStyle(color: BuddyColors.green, fontSize: 11)),
      );
}
