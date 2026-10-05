import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/distance.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/toast.dart';
// Only the report call is wanted from the feed layer — its own
// profileRepositoryProvider would shadow the buddies one.
import '../feed/providers/feed_provider.dart' show feedRepositoryProvider;
import '../messaging/providers/messaging_provider.dart';
import 'buddy_nearby_provider.dart';

/// Backend ModerationReport.REPORT_REASONS. Anything else is rejected.
const _reportReasons = <String>[
  'spam',
  'harassment',
  'hate_speech',
  'nudity',
  'adult_ungated',
  'violence',
  'misinformation',
  'impersonation',
  'other',
];

const _reportReasonLabels = <String, String>{
  'spam': 'Spam or scams',
  'harassment': 'Harassment or bullying',
  'hate_speech': 'Hate speech',
  'nudity': 'Nudity or sexual content',
  'adult_ungated': 'Adult content without an age gate',
  'violence': 'Violence or threats',
  'misinformation': 'Dangerous misinformation',
  'impersonation': 'Impersonation',
  'other': 'Something else',
};

/// Full Find-a-Buddy profile for one buddy-search card.
///
/// Everything on the discovery card, plus what the card had no room for: the
/// whole photo set, the bio in full, goals, pace, neighbourhood and when they
/// are free. The buddy-search card is the reason you are here; the main
/// profile lives one button away at the bottom rather than competing with it.
class BuddyFindProfileScreen extends ConsumerStatefulWidget {
  final String username;

  const BuddyFindProfileScreen({super.key, required this.username});

  @override
  ConsumerState<BuddyFindProfileScreen> createState() => _BuddyFindProfileScreenState();
}

class _BuddyFindProfileScreenState extends ConsumerState<BuddyFindProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  String? _error;
  bool _liking = false;
  bool _blocking = false;
  int _photoIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final coords = ref.read(buddyNearbyProvider);
      final raw = await ref.read(profileRepositoryProvider).getUserSearchProfile(
            widget.username,
            lat: coords.lat,
            lng: coords.lng,
          );
      final data = raw['data'];
      if (!mounted) return;
      if (data is! Map<String, dynamic>) {
        setState(() {
          _error = 'This profile isn\'t open to buddy searches right now.';
          _loading = false;
        });
        return;
      }
      setState(() {
        _profile = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _errorText(e, 'Could not load this buddy profile.');
        _loading = false;
      });
    }
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Like toggle, mirroring the card: flip first, roll back if the server
  /// says no (self-like, a block either way, or a hidden search profile).
  Future<void> _toggleLike() async {
    final p = _profile;
    if (p == null || _liking) return;
    final wasLiked = p['liked_by_me'] as bool? ?? false;
    setState(() => _liking = true);
    _patch(likedByMe: !wasLiked);
    try {
      final repo = ref.read(profileRepositoryProvider);
      final raw = wasLiked
          ? repo.unlikeInterest(widget.username)
          : repo.likeInterest(widget.username);
      final data = (await raw)['data'];
      if (!mounted) return;
      final likedMe = data is Map ? data['liked_me'] as bool? : null;
      _patch(likedByMe: !wasLiked, likedMe: likedMe);
      if (!wasLiked && likedMe == true) {
        showToast(context, 'You both liked each other 🎉', type: ToastType.success);
      }
    } catch (e) {
      if (!mounted) return;
      _patch(likedByMe: wasLiked);
      showToast(context, _errorText(e, 'Could not save that like.'), type: ToastType.error);
    } finally {
      if (mounted) setState(() => _liking = false);
    }
  }

  Future<void> _message() async {
    try {
      final raw = await ref.read(messagingRepositoryProvider).startConversation({
        'participants': [widget.username],
        // Tags the thread as discovery-born so Buddy messages lists it.
        'origin': 'discovery',
      });
      final data = raw['data'];
      final convoId = data is Map ? data['id'] as String? : null;
      if (!mounted) return;
      if (convoId != null && convoId.isNotEmpty) {
        context.push('/messages/$convoId');
      } else {
        showToast(context, 'Could not open chat.', type: ToastType.error);
      }
    } catch (e) {
      if (mounted) {
        showToast(
          context,
          _errorText(e, 'Could not open chat — like them first.'),
          type: ToastType.error,
        );
      }
    }
  }

  Future<void> _block() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BuddyColors.surface,
        title: Text('Block @${widget.username}?',
            style: const TextStyle(color: BuddyColors.textPrimary)),
        content: const Text(
          'They will not be able to message or like you, and you will stop '
          'seeing each other in Find a Buddy. They are not told that you '
          'blocked them.',
          style: TextStyle(color: BuddyColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Block', style: TextStyle(color: BuddyColors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _blocking = true);
    try {
      await ref.read(profileRepositoryProvider).blockUser(widget.username);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      showToast(context, _errorText(e, 'Could not block this profile.'), type: ToastType.error);
    } finally {
      if (mounted) setState(() => _blocking = false);
    }
  }

  Future<void> _report() async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: BuddyColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ReportSheet(username: widget.username),
    );
    if (reason == null || !mounted) return;
    try {
      await ref.read(feedRepositoryProvider).submitModerationReport({
        'target_user': widget.username,
        'reason': reason,
        'description': 'Reported from their Find a Buddy profile.',
        'content_url': '/buddies/find/${widget.username}',
      });
      if (mounted) {
        showToast(
          context,
          'Thanks — our moderators will take a look.',
          type: ToastType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        showToast(
          context,
          _errorText(e, 'Could not send that report.'),
          type: ToastType.error,
        );
      }
    }
  }

  // ── Data helpers ──────────────────────────────────────────────────────────

  /// Write the like flags back into the loaded profile, keeping the grid's
  /// copy in step so the heart matches when you navigate back.
  void _patch({bool? likedByMe, bool? likedMe}) {
    final current = _profile;
    if (current == null) return;
    final next = <String, dynamic>{...current};
    if (likedByMe != null) next['liked_by_me'] = likedByMe;
    if (likedMe != null) next['liked_me'] = likedMe;
    setState(() => _profile = next);
    ref.read(buddyNearbyProvider.notifier).applyLike(
          widget.username,
          likedByMe: likedByMe ?? current['liked_by_me'] as bool? ?? false,
          likedMe: likedMe ?? current['liked_me'] as bool? ?? false,
        );
  }

  List<String> get _photos {
    final p = _profile;
    if (p == null) return const [];
    final list = ((p['photos'] as List?) ?? []).map((e) => e.toString()).toList();
    if (list.isNotEmpty) return list;
    final avatar = p['avatar_url'] as String?;
    return avatar != null && avatar.isNotEmpty ? [avatar] : const [];
  }

  List<String> get _intents {
    final p = _profile!;
    final list = ((p['intents'] as List?) ?? []).map((e) => e.toString()).toList();
    final custom = p['custom_intent'] as String? ?? '';
    if (custom.isNotEmpty) list.add(custom);
    return list;
  }

  String _displayName(dynamic data) {
    if (data is Map) {
      final name = data['display_name'] as String? ?? '';
      if (name.isNotEmpty) return name;
    }
    return '@${widget.username}';
  }

  String _text(String key) => _profile?[key] as String? ?? '';

  /// The backend states its own refusals in the response envelope; prefer
  /// those over a generic fallback.
  static String _errorText(Object e, String fallback) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final direct = data['message'] ?? data['detail'];
        if (direct is String && direct.isNotEmpty) return direct;
        if (data['errors'] is Map) {
          final first = (data['errors'] as Map).values.firstOrNull;
          if (first is List && first.isNotEmpty && first.first is String) {
            return first.first as String;
          }
        }
      }
    }
    return fallback;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final p = _profile;
    return Scaffold(
      appBar: AppBar(
        title: Text(p == null ? 'Find a buddy' : _displayName(p)),
        actions: [
          if (p != null) ...[
            IconButton(
              key: const ValueKey('buddy-find-report'),
              icon: const Icon(Icons.flag_outlined),
              tooltip: 'Report profile',
              onPressed: _report,
            ),
            IconButton(
              key: const ValueKey('buddy-find-block'),
              icon: _blocking
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.block),
              tooltip: 'Block',
              onPressed: _blocking ? null : _block,
            ),
          ],
        ],
      ),
      body: _loading
          ? const PageLoader(fullScreen: false)
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : _body(p!),
    );
  }

  Widget _body(Map<String, dynamic> p) {
    final name = _displayName(p);
    final liked = p['liked_by_me'] as bool? ?? false;
    final likedMe = p['liked_me'] as bool? ?? false;
    final distance = formatDistanceBadge((p['distance_km'] as num?)?.toDouble());
    final goals = ((p['goals'] as List?) ?? []).map((e) => _humanise(e.toString())).toList();
    final modes = ((p['modes'] as List?) ?? []).map((e) => _humanise(e.toString())).toList();
    final pace = _humanise(_text('pace'));
    final neighbourhood = _text('neighbourhood');
    final until = _untilText(p['available_until'] as String?);
    final availableNow = p['available_now'] as bool? ?? false;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        _carousel(name),
        const SizedBox(height: 14),
        Text(
          name,
          style: const TextStyle(
            color: BuddyColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              '@${widget.username}',
              style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
            ),
            if (_text('age_band').isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                _text('age_band'),
                style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
              ),
            ],
            if (distance != null) ...[
              const SizedBox(width: 8),
              Icon(Icons.near_me, size: 12, color: BuddyColors.green.withValues(alpha: 0.8)),
              const SizedBox(width: 2),
              Text(
                distance,
                style: const TextStyle(color: BuddyColors.green, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
        if (likedMe && !liked) ...[
          const SizedBox(height: 8),
          const _Notice(
            icon: Icons.favorite,
            text: 'They liked you first — like them back to match.',
          ),
        ],
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: BuddyButton(
                label: 'Message',
                icon: Icons.message_outlined,
                variant: BuddyButtonVariant.outline,
                onPressed: _message,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: BuddyButton(
                label: liked ? 'Liked' : 'Like',
                icon: liked ? Icons.favorite : Icons.favorite_border,
                isLoading: _liking,
                variant: liked ? BuddyButtonVariant.primary : BuddyButtonVariant.outline,
                color: liked ? BuddyColors.green : BuddyColors.textSecondary,
                onPressed: _liking ? null : _toggleLike,
              ),
            ),
          ],
        ),
        if (_text('bio').isNotEmpty) ...[
          const SizedBox(height: 20),
          _Section(
            title: 'About',
            child: Text(
              _text('bio'),
              style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 14, height: 1.4),
            ),
          ),
        ],
        if (_intents.isNotEmpty) ...[
          const SizedBox(height: 16),
          _Section(title: 'Looking for', child: _Chips(items: _intents)),
        ],
        if (goals.isNotEmpty) ...[
          const SizedBox(height: 16),
          _Section(title: 'Goals', child: _Chips(items: goals)),
        ],
        if (modes.isNotEmpty || pace.isNotEmpty) ...[
          const SizedBox(height: 16),
          _Section(
            title: 'How they train',
            child: _Chips(items: [...modes, if (pace.isNotEmpty) 'Pace: $pace']),
          ),
        ],
        if (neighbourhood.isNotEmpty || availableNow || until != null) ...[
          const SizedBox(height: 16),
          _Section(
            title: 'Availability',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (neighbourhood.isNotEmpty)
                  _MetaRow(icon: Icons.place_outlined, text: neighbourhood),
                if (availableNow)
                  _MetaRow(
                    icon: Icons.bolt,
                    text: until == null ? 'Available now' : 'Available now · until $until',
                    highlight: true,
                  )
                else
                  const _MetaRow(icon: Icons.schedule, text: 'Not looking right now'),
              ],
            ),
          ),
        ],
        const SizedBox(height: 28),
        BuddyButton(
          label: 'View main profile',
          icon: Icons.person_outline,
          variant: BuddyButtonVariant.secondary,
          fullWidth: true,
          onPressed: () => context.push('/${widget.username}'),
        ),
      ],
    );
  }

  /// Photo carousel. Falls back to `avatar_url`, then to initials — the two
  /// views the backend guarantees exist for anyone with a search profile.
  Widget _carousel(String name) {
    final photos = _photos;
    if (photos.isEmpty) return _initials(name);
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 320,
            child: PageView.builder(
              itemCount: photos.length,
              onPageChanged: (i) => setState(() => _photoIndex = i),
              itemBuilder: (_, i) => CachedNetworkImage(
                imageUrl: photos[i],
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: BuddyColors.surfaceRaised),
                errorWidget: (_, _, _) => _initials(name),
              ),
            ),
          ),
        ),
        if (photos.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < photos.length; i++)
                Container(
                  width: i == _photoIndex ? 16 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == _photoIndex ? BuddyColors.green : BuddyColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _initials(String name) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: BuddyColors.surfaceRaised,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: BuddyColors.textSecondary,
            fontSize: 48,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static String _humanise(String raw) => raw.replaceAll('_', ' ');

  static String? _untilText(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    final d = DateTime.tryParse(iso);
    if (d == null) return null;
    final local = d.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: BuddyColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _Chips extends StatelessWidget {
  final List<String> items;

  const _Chips({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final item in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: BuddyColors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(item, style: const TextStyle(color: BuddyColors.green, fontSize: 12)),
          ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool highlight;

  const _MetaRow({required this.icon, required this.text, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final color = highlight ? BuddyColors.green : BuddyColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Notice({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: BuddyColors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BuddyColors.green.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: BuddyColors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reason picker. `POST /moderation/reports/` rejects anything outside the
/// backend's REPORT_REASONS, so the list is fixed rather than free text.
class _ReportSheet extends StatefulWidget {
  final String username;

  const _ReportSheet({required this.username});

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  String _reason = _reportReasons.first;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: BuddyColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Report @${widget.username}',
              style: const TextStyle(
                color: BuddyColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Why are you reporting this profile?',
              style: TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: RadioGroup<String>(
                  groupValue: _reason,
                  onChanged: (v) => setState(() => _reason = v ?? _reason),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final reason in _reportReasons)
                        RadioListTile<String>(
                          value: reason,
                          title: Text(
                            _reportReasonLabels[reason] ?? reason,
                            style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 14),
                          ),
                          activeColor: BuddyColors.green,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: BuddyButton(
                label: 'Send report',
                variant: BuddyButtonVariant.primary,
                fullWidth: true,
                onPressed: () => Navigator.of(context).pop(_reason),
              ),
            ),
          ],
        ),
      ),
    );
  }
}