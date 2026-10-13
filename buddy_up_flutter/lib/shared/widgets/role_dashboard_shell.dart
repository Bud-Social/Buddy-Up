import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// The frame every role dashboard shares: a titled scaffold, a consistent
/// section label, a card surface, and one inline notice style.
///
/// The four dashboards (courier, organiser, stations, gym) are the same screen
/// four times — a title, some stat cards, some lists and a set of actions — so
/// they share a frame rather than each re-deriving one. Mirrors the web's
/// `pages/app/roles/RoleShell`.
class RoleDashboardShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget body;

  const RoleDashboardShell({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title),
            if (subtitle != null)
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: BuddyColors.textSecondary,
                ),
              ),
          ],
        ),
        actions: actions.isEmpty ? null : actions,
      ),
      body: body,
    );
  }
}

/// Small uppercase label above a group of cards.
class RoleSectionTitle extends StatelessWidget {
  final String label;
  final Widget? trailing;

  const RoleSectionTitle(this.label, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    final trailingWidget = trailing;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: BuddyColors.textSecondary,
              ),
            ),
          ),
          ?trailingWidget,
        ],
      ),
    );
  }
}

/// The standard raised surface for a dashboard block.
class RoleCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const RoleCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: cs.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// A single figure with its caption — the dashboard's stat tile.
class RoleStat extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const RoleStat({
    super.key,
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: valueColor ?? BuddyColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 2,
          style: const TextStyle(
            fontSize: 11,
            color: BuddyColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// A row of [RoleStat] tiles, wrapping to two columns on a phone.
class RoleStatRow extends StatelessWidget {
  final List<Widget> children;

  const RoleStatRow(this.children, {super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Two-up on a narrow screen, four-up once there is room for it.
        final columns = constraints.maxWidth >= 560 ? 4 : 2;
        const spacing = 12.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

/// Inline error / notice banner.
///
/// The server's own sentence is always what gets shown (see `apiErrorMessage`),
/// because the detail is the payload — a 400 naming an illegal status move, or
/// a 409 naming who checked a ticket in and when.
class RoleNotice extends StatelessWidget {
  final String message;
  final bool isError;

  const RoleNotice({
    super.key,
    required this.message,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isError ? BuddyColors.red : BuddyColors.green;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: color,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A horizontal row of mutually-exclusive filter chips.
///
/// Selection is expressed by a filled surface, not by a gradient or a glow, to
/// match the rest of the app.
class RoleFilterChips<T> extends StatelessWidget {
  final List<T> options;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onSelected;

  const RoleFilterChips({
    super.key,
    required this.options,
    required this.selected,
    required this.label,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = option == selected;
          return InkWell(
            onTap: () => onSelected(option),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? BuddyColors.green
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                label(option),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? BuddyColors.black
                      : BuddyColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}