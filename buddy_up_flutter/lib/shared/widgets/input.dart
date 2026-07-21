import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class BuddyInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? error;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool enabled;
  final int maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const BuddyInput({
    super.key,
    this.label,
    this.hint,
    this.error,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
  });

  @override
  State<BuddyInput> createState() => _BuddyInputState();
}

class _BuddyInputState extends State<BuddyInput> {
  bool _obscured = false;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              color: BuddyColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: widget.controller,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          validator: widget.validator,
          onChanged: widget.onChanged,
          style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.error,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: 18, color: BuddyColors.textSecondary)
                : null,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscured ? Icons.visibility_off : Icons.visibility,
                      size: 18,
                      color: BuddyColors.textSecondary,
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : widget.suffixIcon != null
                    ? IconButton(
                        icon: Icon(widget.suffixIcon, size: 18),
                        color: BuddyColors.textSecondary,
                        onPressed: widget.onSuffixTap,
                      )
                    : null,
          ),
        ),
      ],
    );
  }
}
