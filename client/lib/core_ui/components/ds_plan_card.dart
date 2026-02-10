import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class DSPlanCard extends StatelessWidget {
  const DSPlanCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    this.badgeText,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final String? badgeText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final radius = context.dsRadius;

    final borderColor = selected
        ? colors.primary.withValues(alpha: 0.65)
        : colors.border.withValues(alpha: 0.9);

    final background = selected
        ? colors.primary.withValues(alpha: 0.08)
        : colors.surface;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(radius.r16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius.r16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(spacing.s16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius.r16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? colors.primary : colors.textTertiary,
                size: spacing.s16,
              ),
              SizedBox(width: spacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: typography.body.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (badgeText != null) ...[
                          SizedBox(width: spacing.s8),
                          _Badge(text: badgeText!),
                        ],
                      ],
                    ),
                    SizedBox(height: spacing.s4),
                    Text(
                      subtitle,
                      style: typography.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final radius = context.dsRadius;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s8,
        vertical: spacing.s4,
      ),
      decoration: BoxDecoration(
        color: colors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(radius.r16),
        border: Border.all(color: colors.success.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: typography.caption.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
