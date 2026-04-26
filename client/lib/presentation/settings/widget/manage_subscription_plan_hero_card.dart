import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ManageSubscriptionPlanHeroCard extends StatelessWidget {
  const ManageSubscriptionPlanHeroCard({super.key, required this.isPaid});

  final bool isPaid;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;
    final colors = context.dsColors;
    final typography = context.dsTypography;
    final radius = context.dsRadius;

    if (isPaid) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius.r16),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius.r16),
          child: Container(
            padding: EdgeInsets.all(spacing.s24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius.r16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.primary,
                  colors.primary.withValues(alpha: 0.88),
                  colors.info.withValues(alpha: 0.82),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.onPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(radius.r12),
                    border: Border.all(color: colors.onPrimary.withValues(alpha: 0.35), width: 1.5),
                  ),
                  child: Icon(Icons.workspace_premium_rounded, size: 32, color: colors.onPrimary),
                ),
                SizedBox(width: spacing.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.settingsPlanPaid,
                        style: typography.h2.copyWith(color: colors.onPrimary),
                      ),
                      SizedBox(height: spacing.s8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.s12,
                          vertical: spacing.s8,
                        ),
                        decoration: BoxDecoration(
                          color: colors.success.withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(radius.r16),
                          border: Border.all(color: colors.success.withValues(alpha: 0.6)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 14, color: colors.onPrimary),
                            SizedBox(width: spacing.s8),
                            Text(
                              l10n.subscriptionStatusActive,
                              style: typography.caption.copyWith(
                                color: colors.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: spacing.s8),
                      Text(
                        l10n.subscriptionPaidBody,
                        style: typography.caption.copyWith(
                          color: colors.onPrimary.withValues(alpha: 0.8),
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

    return DSCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.surfaceAlt,
              borderRadius: BorderRadius.circular(radius.r12),
              border: Border.all(color: colors.border),
            ),
            child: Icon(Icons.person_outline_rounded, size: 28, color: colors.textSecondary),
          ),
          SizedBox(width: spacing.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.subscriptionFreeHeroTitle, style: typography.h2),
                SizedBox(height: spacing.s8),
                Text(
                  l10n.subscriptionFreeHeroBody,
                  style: typography.caption.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
