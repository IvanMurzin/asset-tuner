import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class DSListRow extends StatelessWidget {
  const DSListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.selected = false,
    this.showDivider = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool selected;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;

    final background = selected ? colors.primary.withValues(alpha: 0.08) : colors.surface;

    return Material(
      color: background,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: spacing.s16, vertical: spacing.s12),
          decoration: BoxDecoration(
            border: showDivider ? Border(bottom: BorderSide(color: colors.border)) : null,
          ),
          child: Row(
            children: [
              if (leading != null) ...[leading!, SizedBox(width: spacing.s12)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: typography.body.copyWith(color: colors.textPrimary)),
                    if (subtitle != null) ...[
                      SizedBox(height: spacing.s4),
                      Text(
                        subtitle!,
                        style: typography.caption.copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[SizedBox(width: spacing.s12), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}
