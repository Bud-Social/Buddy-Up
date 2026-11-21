import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';

/// Shared shell for the public information pages that mirror the web's
/// Help / About / Services / Contact / Careers screens.
class InfoScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final List<Widget> children;
  final Widget? footer;

  const InfoScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    required this.children,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BuddyColors.black,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: BuddyColors.black,
        foregroundColor: BuddyColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 38, color: BuddyColors.green),
              const SizedBox(height: 14),
            ],
            Text(
              title,
              style: const TextStyle(
                color: BuddyColors.textPrimary,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 10),
              Text(
                subtitle!,
                style: const TextStyle(
                  color: BuddyColors.textSecondary,
                  fontSize: 15,
                  height: 1.55,
                ),
              ),
            ],
            const SizedBox(height: 24),
            ...children,
            if (footer != null) ...[const SizedBox(height: 24), footer!],
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color;

  const InfoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? BuddyColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BuddyColors.border.withValues(alpha: 0.6)),
      ),
      child: child,
    );
  }
}

class InfoSectionTitle extends StatelessWidget {
  final String text;

  const InfoSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: BuddyColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class InfoBullet extends StatelessWidget {
  final String text;
  final Color color;

  const InfoBullet(this.text, {super.key, this.color = BuddyColors.green});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: BuddyColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoGlyph extends StatelessWidget {
  final IconData icon;
  final Color? color;

  const InfoGlyph(this.icon, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: (color ?? BuddyColors.green).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, size: 22, color: color ?? BuddyColors.green),
    );
  }
}

/// Consistent text input for the public info forms.
class InfoTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;
  final bool enabled;

  const InfoTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.autofillHints,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        autofillHints: autofillHints,
        enabled: enabled,
        style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          alignLabelWithHint: maxLines > 1,
          filled: true,
          fillColor: BuddyColors.surfaceRaised,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: BuddyColors.border, width: 0.6),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: BuddyColors.green, width: 1.4),
          ),
        ),
      ),
    );
  }
}

class InfoDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<(String, String)> options;
  final ValueChanged<String> onChanged;

  const InfoDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        onChanged: (next) {
          if (next != null) onChanged(next);
        },
        dropdownColor: BuddyColors.surfaceRaised,
        style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: BuddyColors.surfaceRaised,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: BuddyColors.border, width: 0.6),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: BuddyColors.green, width: 1.4),
          ),
        ),
        items: [
          for (final option in options)
            DropdownMenuItem(value: option.$1, child: Text(option.$2)),
        ],
      ),
    );
  }
}

/// Small inline link used on info pages.
class InfoLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData icon;

  const InfoLink(
    this.label, {
    super.key,
    required this.onTap,
    this.icon = LucideIcons.arrowRight,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: BuddyColors.green,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Icon(icon, size: 14, color: BuddyColors.green),
          ],
        ),
      ),
    );
  }
}
