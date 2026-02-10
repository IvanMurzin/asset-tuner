import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

enum DSInlineBannerVariant { info, success, warning, danger }

class DSInlineBanner extends StatelessWidget {
  const DSInlineBanner({
    super.key,
    required this.title,
    required this.message,
    this.variant = DSInlineBannerVariant.info,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final DSInlineBannerVariant variant;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final radius = context.dsRadius;

    final accent = switch (variant) {
      DSInlineBannerVariant.info => colors.info,
      DSInlineBannerVariant.success => colors.success,
      DSInlineBannerVariant.warning => colors.warning,
      DSInlineBannerVariant.danger => colors.danger,
    };

    return Container(
      padding: EdgeInsets.all(spacing.s12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(radius.r12),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: typography.h3.copyWith(color: colors.textPrimary)),
          SizedBox(height: spacing.s4),
          Text(
            message,
            style: typography.body.copyWith(color: colors.textSecondary),
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: spacing.s12),
            DSButton(
              label: actionLabel!,
              variant: DSButtonVariant.secondary,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}
