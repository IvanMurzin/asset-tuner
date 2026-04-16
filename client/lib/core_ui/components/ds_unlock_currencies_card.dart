import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class DSUnlockCurrenciesCard extends StatelessWidget {
  const DSUnlockCurrenciesCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final radius = context.dsRadius;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.r16),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.16),
            blurRadius: 14,
            spreadRadius: 0.4,
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(radius.r16),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.primary.withValues(alpha: 0.12),
                colors.warning.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(radius.r16),
            border: Border.all(color: colors.primary.withValues(alpha: 0.4), width: 1.4),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(spacing.s12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(radius.r12),
                        ),
                        child: Icon(Icons.lock_open_rounded, color: colors.primary, size: 20),
                      ),
                      SizedBox(width: spacing.s12),
                      Expanded(
                        child: Text(
                          title,
                          style: typography.body.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing.s8),
                  Text(subtitle, style: typography.caption.copyWith(color: colors.textSecondary)),
                  SizedBox(height: spacing.s12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: spacing.s12, vertical: spacing.s8),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(radius.r12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            actionLabel,
                            style: typography.caption.copyWith(
                              color: colors.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: spacing.s8),
                          Icon(Icons.arrow_forward_rounded, size: 16, color: colors.onPrimary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
