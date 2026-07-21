import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum BuddyButtonVariant { primary, secondary, outline, ghost, destructive }

enum BuddyButtonSize { sm, md, lg }

class BuddyButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final BuddyButtonVariant variant;
  final BuddyButtonSize size;
  final bool isLoading;
  final bool fullWidth;
  final IconData? icon;
  final Color? color;

  const BuddyButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = BuddyButtonVariant.primary,
    this.size = BuddyButtonSize.md,
    this.isLoading = false,
    this.fullWidth = false,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    final width = fullWidth ? double.infinity : null;

    switch (variant) {
      case BuddyButtonVariant.primary:
        return _buildElevated(isDisabled, width);
      case BuddyButtonVariant.secondary:
        return _buildSecondary(isDisabled, width);
      case BuddyButtonVariant.outline:
        return _buildOutlined(isDisabled, width);
      case BuddyButtonVariant.ghost:
        return _buildText(isDisabled, width);
      case BuddyButtonVariant.destructive:
        return _buildDestructive(isDisabled, width);
    }
  }

  Widget _buildElevated(bool isDisabled, double? width) {
    return SizedBox(
      width: width,
      height: _height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? BuddyColors.green,
          foregroundColor: BuddyColors.black,
          disabledBackgroundColor: BuddyColors.green.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _content,
      ),
    );
  }

  Widget _buildSecondary(bool isDisabled, double? width) {
    return SizedBox(
      width: width,
      height: _height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: BuddyColors.surfaceRaised,
          foregroundColor: BuddyColors.textPrimary,
          disabledBackgroundColor: BuddyColors.surfaceRaised.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _content,
      ),
    );
  }

  Widget _buildOutlined(bool isDisabled, double? width) {
    return SizedBox(
      width: width,
      height: _height,
      child: OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color ?? BuddyColors.green,
          side: BorderSide(color: color ?? BuddyColors.green),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _content,
      ),
    );
  }

  Widget _buildText(bool isDisabled, double? width) {
    return SizedBox(
      width: width,
      height: _height,
      child: TextButton(
        onPressed: isDisabled ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: color ?? BuddyColors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _content,
      ),
    );
  }

  Widget _buildDestructive(bool isDisabled, double? width) {
    return SizedBox(
      width: width,
      height: _height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: BuddyColors.red,
          foregroundColor: BuddyColors.textPrimary,
          disabledBackgroundColor: BuddyColors.red.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _content,
      ),
    );
  }

  double get _height {
    switch (size) {
      case BuddyButtonSize.sm:
        return 36;
      case BuddyButtonSize.md:
        return 48;
      case BuddyButtonSize.lg:
        return 56;
    }
  }

  Widget get _content {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: variant == BuddyButtonVariant.primary
              ? BuddyColors.black
              : BuddyColors.green,
        ),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label, style: _textStyle),
        ],
      );
    }
    return Text(label, style: _textStyle);
  }

  TextStyle get _textStyle {
    return TextStyle(
      fontSize: size == BuddyButtonSize.sm ? 13 : 15,
      fontWeight: FontWeight.w600,
    );
  }
}
