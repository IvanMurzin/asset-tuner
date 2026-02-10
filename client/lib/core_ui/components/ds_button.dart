import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/components/ds_loader.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

enum DSButtonVariant { primary, secondary, danger }

class DSButton extends StatelessWidget {
  const DSButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = DSButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = false,
    this.leadingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final DSButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final radius = context.dsRadius;
    final typography = context.dsTypography;
    final elevation = context.dsElevation;
    final isInteractive = onPressed != null && !isLoading;
    final isEnabledStyle = onPressed != null;

    final isPrimary = variant == DSButtonVariant.primary;
    final isSecondary = variant == DSButtonVariant.secondary;
    final textStyle = typography.button;
    final baseForeground = isEnabledStyle
        ? (isSecondary ? colors.textPrimary : colors.onPrimary)
        : colors.textTertiary;
    final labelStyle = textStyle.copyWith(color: baseForeground);

    Widget content;
    if (isLoading) {
      content = DSLoader(
        size: spacing.s16,
        strokeWidth: 2,
        color: baseForeground,
      );
    } else if (leadingIcon != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(leadingIcon, size: spacing.s16, color: baseForeground),
          SizedBox(width: spacing.s8),
          Text(label, style: labelStyle),
        ],
      );
    } else {
      content = Text(label, style: labelStyle);
    }

    final decoration = BoxDecoration(
      color: isEnabledStyle
          ? (isPrimary ? null : (isSecondary ? colors.surface : colors.danger))
          : colors.surfaceAlt,
      gradient: isEnabledStyle && isPrimary
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.primary, colors.primaryHover],
              stops: const [0.0, 1.0],
            )
          : null,
      borderRadius: BorderRadius.circular(radius.r12),
      border: isSecondary ? Border.all(color: colors.border) : null,
      boxShadow: isEnabledStyle && !isSecondary ? elevation.e1 : const [],
    );

    final overlayColor = isEnabledStyle
        ? (isSecondary
              ? colors.textPrimary.withValues(alpha: 0.06)
              : colors.onPrimary.withValues(alpha: 0.12))
        : Colors.transparent;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius.r12),
        child: Ink(
          decoration: decoration,
          child: InkWell(
            onTap: isInteractive ? onPressed : null,
            borderRadius: BorderRadius.circular(radius.r12),
            overlayColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.pressed)
                  ? overlayColor
                  : Colors.transparent,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.s16,
                vertical: spacing.s12,
              ),
              child: Row(
                mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [content],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
