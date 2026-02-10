import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class BaseCurrencySettingsCurrencyRow extends StatelessWidget {
  const BaseCurrencySettingsCurrencyRow({
    super.key,
    required this.code,
    required this.name,
    required this.symbol,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  final String code;
  final String name;
  final String? symbol;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;

    final background = selected
        ? colors.primary.withValues(alpha: 0.08)
        : colors.surface;

    return Material(
      color: background,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.s12,
            vertical: spacing.s12,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.s12,
                  vertical: spacing.s4,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceAlt,
                  borderRadius: BorderRadius.circular(context.dsRadius.r12),
                  border: Border.all(color: colors.border),
                ),
                child: Text(
                  code,
                  style: typography.caption.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: spacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: typography.body.copyWith(
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (symbol != null && symbol!.trim().isNotEmpty) ...[
                      SizedBox(height: spacing.s4),
                      Text(
                        symbol!,
                        style: typography.caption.copyWith(
                          color: colors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: spacing.s12),
              if (locked)
                Icon(Icons.lock_outline, color: colors.textTertiary)
              else if (selected)
                Icon(Icons.check_circle, color: colors.primary)
              else
                Icon(Icons.radio_button_unchecked, color: colors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
