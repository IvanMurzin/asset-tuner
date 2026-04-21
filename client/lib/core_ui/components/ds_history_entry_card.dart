import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class DSHistoryEntryCard extends StatelessWidget {
  const DSHistoryEntryCard({
    super.key,
    required this.dateText,
    this.subtitleText,
    required this.deltaText,
    required this.deltaColor,
    required this.baseLineText,
    this.trailingTitle,
    this.trailingPrimaryText,
    this.trailingSecondaryText,
    this.showDeltaOnTrailing = false,
  });

  final String dateText;
  final String? subtitleText;
  final String deltaText;
  final Color deltaColor;
  final String baseLineText;
  final String? trailingTitle;
  final String? trailingPrimaryText;
  final String? trailingSecondaryText;
  final bool showDeltaOnTrailing;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final colors = context.dsColors;
    final typography = context.dsTypography;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: spacing.s12, vertical: spacing.s8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(context.dsRadius.r12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateText,
                  style: typography.caption.copyWith(color: colors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitleText != null && subtitleText!.isNotEmpty) ...[
                  SizedBox(height: spacing.s4),
                  Text(
                    subtitleText!,
                    style: typography.caption.copyWith(color: colors.textSecondary),
                  ),
                ],
                if (!showDeltaOnTrailing) ...[
                  SizedBox(height: spacing.s4),
                  Text(
                    deltaText,
                    style: typography.body.copyWith(color: deltaColor, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    baseLineText,
                    style: typography.caption.copyWith(color: deltaColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (showDeltaOnTrailing || trailingTitle != null || trailingPrimaryText != null) ...[
            SizedBox(width: spacing.s12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (showDeltaOnTrailing) ...[
                  Text(
                    deltaText,
                    textAlign: TextAlign.right,
                    style: typography.body.copyWith(color: deltaColor, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    baseLineText,
                    textAlign: TextAlign.right,
                    style: typography.caption.copyWith(color: deltaColor),
                  ),
                ] else if (trailingTitle != null) ...[
                  Text(
                    trailingTitle!,
                    style: typography.caption.copyWith(color: colors.textSecondary),
                  ),
                  SizedBox(height: spacing.s4),
                ],
                if (trailingPrimaryText != null)
                  Text(
                    trailingPrimaryText!,
                    textAlign: TextAlign.right,
                    style: typography.h3.copyWith(fontWeight: FontWeight.w700),
                  ),
                if (trailingSecondaryText != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    trailingSecondaryText!,
                    textAlign: TextAlign.right,
                    style: typography.body.copyWith(color: colors.textSecondary),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
