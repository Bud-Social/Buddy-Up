import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/admin_portal.dart';
import '../providers/admin_provider.dart';
import '../providers/governance_provider.dart';

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

/// Pager for a cursor-paginated list.
///
/// [AdminPager] cannot be used on these: DRF's `CursorPagination` has no page
/// number and no count, so a page-number pager would render a "Next" that
/// re-requests page one and returns the same rows. This follows the `next`
/// link the server actually handed back, and says how many rows are in hand
/// rather than inventing a total.
class AdminCursorPager extends StatelessWidget {
  final CursorStack stack;
  final PortalPage<Object> page;
  final bool busy;
  /// Called after the stack moves, so the page label rebuilds. The stack is
  /// mutated in place rather than replaced, so without this the label would
  /// keep reading "Page 1" after Next.
  final VoidCallback onChanged;

  const AdminCursorPager({
    super.key,
    required this.stack,
    required this.page,
    required this.busy,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (page.items.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final hasNext = page.pagination.next != null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Page ${stack.page} · ${page.items.length} rows in hand',
          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
        ),
        Row(
          children: [
            TextButton(
              onPressed: busy || !stack.canGoBack
                  ? null
                  : () {
                      stack.goBack();
                      onChanged();
                    },
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              child: const Text('Previous', style: TextStyle(fontSize: 12)),
            ),
            TextButton(
              onPressed: busy || !hasNext
                  ? null
                  : () {
                      stack.advance(page.pagination.next);
                      onChanged();
                    },
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

/// Severity pill for a content flag. Critical and high share a colour with
/// only weight distinguishing them, because the split that matters is
/// "must look now" versus "can wait for the queue", not a four-step scale.
class AdminSeverityBadge extends StatelessWidget {
  final String? severity;

  const AdminSeverityBadge({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    final raw = (severity ?? '').toLowerCase();
    final color = switch (raw) {
      'critical' || 'high' => BuddyColors.red,
      'medium' => BuddyColors.gold,
      'low' => BuddyColors.textSecondary,
      _ => BuddyColors.textSecondary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        raw.isEmpty ? 'unrated' : raw.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

/// SLA pill for a moderation report.
///
/// Reads the server's own `sla_due_at` / `sla_breached` and never recomputes a
/// deadline — see `slaStateFor`. A settled report shows no pill at all: a
/// closed ticket has no clock to be late against, and showing "ON TRACK" on a
/// resolved report would imply someone still owes it an answer.
class AdminSlaBadge extends StatelessWidget {
  final ModerationReport report;

  const AdminSlaBadge({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final state = slaStateFor(report);
    if (state == SlaState.settled) return const SizedBox.shrink();
    final (label, color) = switch (state) {
      SlaState.breached => ('SLA breached', BuddyColors.red),
      SlaState.dueSoon => ('SLA due soon', BuddyColors.gold),
      _ => ('On track', BuddyColors.green),
    };
    return AdminStatusBadge(status: label, upper: false);
  }
}

/// Horizontal tab switcher for a screen with several queues in it.
///
/// A plain segmented row rather than a `TabBarView`: the moderation
/// dashboard's tabs are peer queues with their own refresh state, and keeping
/// one `ListView` per tab means a scroll position survives a filter change
/// instead of resetting under the operator mid-triage.
class AdminSectionTabs extends StatelessWidget {
  final List<({String value, String label})> options;
  final String value;
  final ValueChanged<String> onChanged;

  const AdminSectionTabs({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(option.value),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: value == option.value
                        ? BuddyColors.green.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    option.label,
                    textAlign: TextAlign.center,
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
            ),
        ],
      ),
    );
  }
}

/// Mandatory-reason prompt.
///
/// The server refuses a reversal, a rejection, a cancellation and a
/// disciplinary action that arrive without one, and the reason is the record a
/// target reads in an appeal or a reviewer reads in an incident. So the field
/// is required in the widget too: the button stays disabled until something is
/// typed rather than letting the operator spend a round trip learning the rule.
class AdminReasonPrompt extends StatefulWidget {
  final String title;
  final String hint;
  final String confirmLabel;
  final bool destructive;
  final bool busy;
  final int minLength;
  final int maxLines;
  final ValueChanged<String> onSubmit;
  final VoidCallback onCancel;

  const AdminReasonPrompt({
    super.key,
    required this.title,
    required this.onSubmit,
    required this.onCancel,
    this.hint = 'Reason (required)',
    this.confirmLabel = 'Submit',
    this.destructive = false,
    this.busy = false,
    this.minLength = 1,
    this.maxLines = 3,
  });

  @override
  State<AdminReasonPrompt> createState() => _AdminReasonPromptState();
}

class _AdminReasonPromptState extends State<AdminReasonPrompt> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final length = _controller.text.trim().length;
    final ready = length >= widget.minLength;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          maxLines: widget.maxLines,
          minLines: 1,
          decoration: InputDecoration(
            hintText: widget.hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton.icon(
              onPressed: widget.busy || !ready
                  ? null
                  : () => widget.onSubmit(_controller.text.trim()),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor:
                    widget.destructive ? BuddyColors.red : BuddyColors.green,
              ),
              icon: widget.busy
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check, size: 14),
              label: Text(widget.confirmLabel, style: const TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 4),
            TextButton(
              onPressed: widget.busy ? null : widget.onCancel,
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              child: const Text('Cancel', style: TextStyle(fontSize: 12)),
            ),
            const Spacer(),
            Text(
              ready ? '$length characters' : 'Required',
              style: TextStyle(
                fontSize: 11,
                color: ready ? cs.onSurfaceVariant : BuddyColors.gold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Flat explanatory note — the gold-bordered block the console uses to state a
/// rule an operator cannot see from the data ("a grant needs a second
/// approver"). Deliberately not a dialog: it stays on screen while the row
/// underneath it is being acted on.
class AdminRuleNote extends StatelessWidget {
  final String text;
  final IconData icon;

  const AdminRuleNote({
    super.key,
    required this.text,
    this.icon = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BuddyColors.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BuddyColors.gold.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: BuddyColors.gold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// Grey-bordered variant of [AdminRuleNote] for neutral asides.
class AdminHintNote extends StatelessWidget {
  final String text;

  const AdminHintNote({super.key, required this.text});

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
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant, height: 1.4),
      ),
    );
  }
}

/// Busy spinner used in place of a list, matching the console's other pages.
class AdminLoadingBlock extends StatelessWidget {
  const AdminLoadingBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
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