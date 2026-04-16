part of 'asset_currency_badge.dart';

class _AssetCurrencyAssetRow extends StatelessWidget {
  const _AssetCurrencyAssetRow({
    required this.row,
    required this.isSelected,
    required this.onSelect,
  });

  final _AssetPickerRowModel row;
  final bool isSelected;
  final ValueChanged<_AssetSelectionResult> onSelect;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final colors = context.dsColors;
    final typography = context.dsTypography;
    final asset = row.asset;
    final locked = asset.isLocked ?? false;
    final slug = asset.code.toUpperCase();

    return Opacity(
      opacity: locked ? 0.65 : 1,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(context.dsRadius.r12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(context.dsRadius.r12),
          onTap: () => onSelect(_AssetSelectionResult(asset: asset, locked: locked)),
          child: Padding(
            padding: EdgeInsets.all(spacing.s8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: asset.kind == AssetKind.fiat ? colors.primary : colors.warning,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        slug,
                        style: typography.caption.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: spacing.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.titleText,
                        style: typography.body.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: spacing.s4),
                      Text(
                        '${asset.name} • ${row.rateCaption}',
                        style: typography.caption.copyWith(
                          color: row.hasRate ? colors.textSecondary : colors.textTertiary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: spacing.s8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (row.hasRate)
                      Text(
                        '≈',
                        style: typography.caption.copyWith(
                          color: colors.textTertiary,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    else
                      SizedBox(height: typography.caption.fontSize ?? 12),
                    SizedBox(height: spacing.s8),
                    if (locked)
                      Icon(Icons.lock_outline, color: colors.textTertiary, size: 20)
                    else if (isSelected)
                      Icon(Icons.check_rounded, color: colors.primary, size: 20)
                    else
                      const SizedBox(width: 20, height: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
