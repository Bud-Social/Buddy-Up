import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/admin_provider.dart';

/// Shared building blocks for the admin console.
///
/// Styling vocabulary is borrowed from the app's own Card / Badge / Button
/// primitives and the `buddy-*` colour tokens only — flat surfaces, no gradients,
/// no glow — so every admin page reads as one surface and as part of the app.
class AdminPageHeader extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onRefresh;
  final bool refreshing;

  const AdminPageHeader({
    super.key,
    required this.title,
    required this.description,
    this.onRefresh,
    this.refreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        if (onRefresh != null)
          IconButton(
            tooltip: 'Refresh',
            onPressed: refreshing ? null : onRefresh,
            icon: refreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh, size: 20),
          ),
      ],
    );
  }
}

class AdminStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;

  const AdminStatCard({
    super.key,
    required this.label,
    required this.value,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          if (sub != null)
            Text(
              sub!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}

/// Inline non-blocking error. The server's `message` is shown verbatim.
class AdminErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AdminErrorBanner({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: BuddyColors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BuddyColors.red.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, color: BuddyColors.red, height: 1.35),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: BuddyColors.red),
              child: const Text('Retry', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

class AdminNoticeBanner extends StatelessWidget {
  final String message;

  const AdminNoticeBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: BuddyColors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BuddyColors.green.withValues(alpha: 0.25)),
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 12, color: BuddyColors.green, height: 1.35),
      ),
    );
  }
}

class AdminEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? hint;

  const AdminEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: BuddyColors.green.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
          if (hint != null) ...[
            const SizedBox(height: 4),
            Text(
              hint!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

/// Status pill for any backend enum, humanised. A value the console has never
/// seen still renders rather than crashing.
class AdminStatusBadge extends StatelessWidget {
  final String? status;
  final bool upper;

  const AdminStatusBadge({super.key, required this.status, this.upper = true});

  @override
  Widget build(BuildContext context) {
    final raw = status ?? '';
    final label = raw.replaceAll('_', ' ');
    final tint = adminStatusColor(raw);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        upper ? label.toUpperCase() : label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: tint,
        ),
      ),
    );
  }
}

Color adminStatusColor(String status) {
  switch (status) {
    case 'approved':
    case 'verified':
    case 'paid':
    case 'delivered':
    case 'completed':
    case 'active':
      return BuddyColors.green;
    case 'submitted':
    case 'under_review':
    case 'pending':
    case 'processing':
    case 'awaiting_confirmation':
      return BuddyColors.gold;
    case 'rejected':
    case 'failed':
    case 'cancelled':
    case 'deleted':
      return BuddyColors.red;
    case 'shipped':
    case 'out_for_delivery':
    case 'ready_for_pickup':
      return const Color(0xFF60A5FA);
    default:
      return BuddyColors.textSecondary;
  }
}

/// Simple key/value row for a detail panel.
class AdminDataRow extends StatelessWidget {
  final String label;
  final String value;

  const AdminDataRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12, color: cs.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip row for a single-select filter. `all` is the sentinel the console
/// filters use to mean "no filter".
class AdminFilterChips extends StatelessWidget {
  final List<({String value, String label})> options;
  final String value;
  final ValueChanged<String> onChanged;

  const AdminFilterChips({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final option in options)
          InkWell(
            onTap: () => onChanged(option.value),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: value == option.value
                    ? BuddyColors.green.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                option.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: value == option.value
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: value == option.value
                      ? BuddyColors.green
                      : cs.onSurfaceVariant,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Page-size-agnostic pager. Uses the envelope's `count` so it stays correct
/// even if the server's page size differs from ours.
class AdminPager<T> extends StatelessWidget {
  final PortalPage<T> page;
  final int currentPage;
  final bool busy;
  final ValueChanged<int> onPage;

  const AdminPager({
    super.key,
    required this.page,
    required this.currentPage,
    required this.busy,
    required this.onPage,
  });

  @override
  Widget build(BuildContext context) {
    if (page.count == 0) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Page $currentPage of ${page.pageCount} · ${page.count} total',
          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
        ),
        Row(
          children: [
            TextButton(
              onPressed: busy || currentPage <= 1 ? null : () => onPage(currentPage - 1),
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              child: const Text('Previous', style: TextStyle(fontSize: 12)),
            ),
            TextButton(
              onPressed:
                  busy || currentPage >= page.pageCount ? null : () => onPage(currentPage + 1),
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              child: const Text('Next', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }
}

/// Shared console row: title, subtitle, status pills and trailing actions.
class AdminRowCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? meta;
  final List<Widget> badges;
  final List<Widget> actions;
  final Widget? expanded;

  const AdminRowCard({
    super.key,
    required this.title,
    required this.badges,
    this.subtitle,
    this.meta,
    this.actions = const [],
    this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        ...badges,
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                      ),
                    ],
                    if (meta != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        meta!,
                        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
              if (actions.isNotEmpty)
                Row(mainAxisSize: MainAxisSize.min, children: actions),
            ],
          ),
          if (expanded != null) ...[
            const SizedBox(height: 10),
            Divider(height: 1, color: cs.outline.withValues(alpha: 0.15)),
            const SizedBox(height: 10),
            expanded!,
          ],
        ],
      ),
    );
  }
}

/// Compact action button used inside console rows.
class AdminActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool destructive;

  const AdminActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? BuddyColors.red : BuddyColors.green;
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        foregroundColor: color,
      ),
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}

/// Approve / reject / request-more-info prompt shared by every review queue.
///
/// A rejection reason is mandatory — the server refuses one without it — so the
/// button stays disabled until one is typed.
class AdminReviewPrompt extends StatefulWidget {
  final String title;
  final bool open;
  final bool busy;
  final ValueChanged<({String status, String reason})> onSubmit;
  final VoidCallback onCancel;

  const AdminReviewPrompt({
    super.key,
    required this.title,
    required this.open,
    required this.busy,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<AdminReviewPrompt> createState() => _AdminReviewPromptState();
}

class _AdminReviewPromptState extends State<AdminReviewPrompt> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (!widget.open) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _reasonController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Reason (required to reject, optional otherwise)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final status in const [
              'approved',
              'rejected',
              'more_info_needed',
              'under_review',
            ])
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: TextButton(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: status == 'approved'
                        ? BuddyColors.green
                        : status == 'rejected'
                            ? BuddyColors.red
                            : BuddyColors.gold,
                  ),
                  onPressed: widget.busy ||
                          (status == 'rejected' &&
                              _reasonController.text.trim().isEmpty)
                      ? null
                      : () => widget.onSubmit((
                            status: status,
                            reason: _reasonController.text.trim(),
                          )),
                  child: Text(
                    status.replaceAll('_', ' '),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            TextButton(
              onPressed: widget.onCancel,
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              child: const Text('Cancel', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }
}