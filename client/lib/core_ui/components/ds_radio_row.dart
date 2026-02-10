import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class DSRadioRow extends StatelessWidget {
  const DSRadioRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.selected,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final radius = context.dsRadius;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius.r12),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.s12,
          vertical: spacing.s12,
        ),
        child: Row(
          children: [
            Container(
              width: spacing.s16,
              height: spacing.s16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? colors.primary : colors.border,
                  width: selected ? 5 : 1.5,
                ),
              ),
            ),
            SizedBox(width: spacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: typography.body),
                  if (subtitle != null) ...[
                    SizedBox(height: spacing.s4),
                    Text(
                      subtitle!,
                      style: typography.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
