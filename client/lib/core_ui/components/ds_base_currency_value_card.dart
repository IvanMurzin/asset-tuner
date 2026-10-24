import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class DSBaseCurrencyValueCard extends StatelessWidget {
  const DSBaseCurrencyValueCard({
    super.key,
    required this.title,
    required this.caption,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String caption;
  final Widget? trailing;

  /// Makes the whole card tappable (e.g. opens the same picker as [trailing]).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;

    final card = DSCard(
      padding: EdgeInsets.all(spacing.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: typography.h3.copyWith(color: colors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing.s4),
                Text(caption, style: typography.caption.copyWith(color: colors.textSecondary)),
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: spacing.s12),
            Padding(
              padding: EdgeInsets.only(top: spacing.s4),
              child: trailing!,
            ),
          ],
        ],
      ),
    );
    if (onTap == null) {
      return card;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(context.dsRadius.r12),
        onTap: onTap,
        child: card,
      ),
    );
  }
}
