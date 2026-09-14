import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/post.dart';
import '../../../shared/widgets/toast.dart';
import '../providers/feed_provider.dart';

/// Canonical deep link for a post. Video posts land in the fullscreen
/// player; everything else lands on the post detail route.
String canonicalPostUrl(Post post, {String origin = ''}) {
  final isVideo = post.media.any((m) => m.isVideo) ||
      post.mediaUrls.any((u) {
        final lower = u.toLowerCase();
        return lower.endsWith('.mp4') ||
            lower.endsWith('.mov') ||
            lower.endsWith('.webm');
      });
  if (isVideo) return '$origin/videos?start=${post.id}';
  return '$origin/feed/${post.id}';
}

/// Append the sharer's referral code so opens attribute back to them.
String trackedShareUrl(String base, String code) {
  final sep = base.contains('?') ? '&' : '?';
  return '$base${sep}ref=${Uri.encodeComponent(code)}';
}

class _SocialTarget {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final String Function(String url, String text) href;

  const _SocialTarget({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.href,
  });
}

const _socialTargets = [
  _SocialTarget(
    id: 'whatsapp',
    label: 'WhatsApp',
    icon: Icons.chat_bubble,
    color: Color(0xFF25D366),
    href: _waHref,
  ),
  _SocialTarget(
    id: 'x',
    label: 'X',
    icon: Icons.close,
    color: Colors.white,
    href: _xHref,
  ),
  _SocialTarget(
    id: 'facebook',
    label: 'Facebook',
    icon: Icons.facebook,
    color: Color(0xFF1877F2),
    href: _fbHref,
  ),
  _SocialTarget(
    id: 'telegram',
    label: 'Telegram',
    icon: Icons.send,
    color: Color(0xFF229ED9),
    href: _tgHref,
  ),
];

String _waHref(String url, String text) =>
    'https://wa.me/?text=${Uri.encodeComponent('$text $url')}';
String _xHref(String url, String text) =>
    'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(text)}&url=${Uri.encodeComponent(url)}';
String _fbHref(String url, String _) =>
    'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(url)}';
String _tgHref(String url, String text) =>
    'https://t.me/share/url?url=${Uri.encodeComponent(url)}&text=${Uri.encodeComponent(text)}';

class _Sharer {
  final String username;
  final String displayName;
  final String avatarUrl;
  final bool followed;

  _Sharer({
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.followed,
  });

  factory _Sharer.fromJson(Map<String, dynamic> json) => _Sharer(
        username: json['username'] as String? ?? '',
        displayName: json['display_name'] as String? ?? '',
        avatarUrl: json['avatar_url'] as String? ?? '',
        followed: json['followed_by_viewer'] == true,
      );
}

/// Bottom sheet: social targets, copy link, repost, save, creator profile,
/// plus "Shared by" attribution. Outbound shares record a tracked referral
/// code so opens attribute back to the sharer.
class ShareSheet extends ConsumerStatefulWidget {
  final Post post;

  const ShareSheet({super.key, required this.post});

  static Future<void> show(BuildContext context, Post post) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: BuddyColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ShareSheet(post: post),
    );
  }

  @override
  ConsumerState<ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends ConsumerState<ShareSheet> {
  bool _busy = false;
  bool _copied = false;
  String? _error;
  List<_Sharer> _sharers = const [];
  bool _sharersLoaded = false;

  Post get _post => widget.post;
  String get _shareText => _post.body.isNotEmpty
      ? (_post.body.length > 120 ? _post.body.substring(0, 120) : _post.body)
      : 'Check out this post by @${_post.authorData.username}';

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadSharers);
  }

  Future<void> _loadSharers() async {
    try {
      final raw =
          await ref.read(feedRepositoryProvider).getPostShares(_post.id);
      final data = raw['data'];
      if (!mounted || data is! List) return;
      setState(() {
        _sharers = [
          for (final r in data)
            if (r is Map<String, dynamic>) _Sharer.fromJson(r),
        ];
        _sharersLoaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _sharersLoaded = true);
    }
  }

  Future<String> _trackedLink(String channel) async {
    if (_busy) return canonicalPostUrl(_post);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final code = await ref
          .read(feedProvider.notifier)
          .shareWithCode(_post.id, channel);
      final base = canonicalPostUrl(_post);
      return code != null && code.isNotEmpty ? trackedShareUrl(base, code) : base;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copyLink() async {
    final url = await _trackedLink('copy');
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    setState(() => _copied = true);
    showToast(context, 'Link copied', type: ToastType.success);
  }

  Future<void> _openSocial(_SocialTarget target) async {
    final url = await _trackedLink(target.id);
    final ok = await launchUrl(
      Uri.parse(target.href(url, _shareText)),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && mounted) {
      setState(() => _error = 'Could not open ${target.label}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: SizedBox(
                width: 40,
                height: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: BuddyColors.textSecondary,
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Share post',
              style: TextStyle(
                color: BuddyColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _socialTargets.length,
                separatorBuilder: (_, _) => const SizedBox(width: 4),
                itemBuilder: (_, i) {
                  final target = _socialTargets[i];
                  return InkWell(
                    onTap: _busy ? null : () => _openSocial(target),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            backgroundColor: BuddyColors.surface,
                            child: Icon(target.icon, color: target.color, size: 22),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            target.label,
                            style: const TextStyle(
                              color: BuddyColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            _Row(
              icon: _copied ? Icons.check : Icons.link,
              iconColor: _copied ? BuddyColors.green : null,
              label: _copied ? 'Link copied!' : 'Copy link',
              onTap: _busy ? null : _copyLink,
            ),
            _Row(
              icon: Icons.repeat,
              label: _post.isRepostedByMe ? 'Undo repost' : 'Repost',
              trailing: '${_post.repostCount}',
              onTap: () {
                Navigator.of(context).pop();
                ref.read(feedProvider.notifier).toggleRepost(_post.id);
              },
            ),
            _Row(
              icon: _post.isSaved ? Icons.bookmark : Icons.bookmark_border,
              label: _post.isSaved ? 'Saved' : 'Save',
              onTap: () {
                Navigator.of(context).pop();
                ref.read(feedProvider.notifier).toggleSaveById(_post.id);
              },
            ),
            _Row(
              icon: Icons.person_outline,
              label: 'View creator profile',
              onTap: () {
                Navigator.of(context).pop();
                context.push('/${_post.authorData.username}');
              },
            ),
            if (_sharersLoaded && _sharers.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'SHARED BY',
                style: TextStyle(
                  color: BuddyColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _sharers.length.clamp(0, 8),
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final s = _sharers[i];
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/${s.username}');
                      },
                      child: SizedBox(
                        width: 56,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: BuddyColors.surface,
                              backgroundImage: s.avatarUrl.isNotEmpty
                                  ? NetworkImage(s.avatarUrl)
                                  : null,
                              child: s.avatarUrl.isEmpty
                                  ? Text(
                                      s.displayName.isNotEmpty
                                          ? s.displayName[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        color: BuddyColors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              s.followed ? '✓ ${s.displayName}' : s.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: BuddyColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: const TextStyle(color: BuddyColors.red, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String? trailing;
  final VoidCallback? onTap;

  const _Row({
    required this.icon,
    required this.label,
    this.iconColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(icon, color: iconColor ?? BuddyColors.green),
      title: Text(
        label,
        style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 14),
      ),
      trailing: trailing == null
          ? null
          : Text(
              trailing!,
              style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
            ),
      onTap: onTap,
    );
  }
}
