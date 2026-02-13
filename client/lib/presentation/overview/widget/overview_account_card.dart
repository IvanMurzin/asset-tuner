import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/formatting/ds_formatters.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/account/utils/account_type_theme.dart';
import 'package:asset_tuner/presentation/overview/bloc/overview_cubit.dart';

class OverviewAccountCard extends StatelessWidget {
  const OverviewAccountCard({
    super.key,
    required this.item,
    required this.baseCurrency,
    required this.onTap,
    this.showBalance = true,
    this.subtitleOverride,
  });

  final OverviewAccountItem item;
  final String baseCurrency;
  final VoidCallback onTap;
  final bool showBalance;
  final String? subtitleOverride;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final typography = context.dsTypography;
    final spacing = context.dsSpacing;
    final l10n = AppLocalizations.of(context)!;

    final gradient =
        accountTypeGradientColors(colors, item.accountType);
    final iconColor = accountTypeAccentColor(colors, item.accountType);
    final iconData = accountTypeIcon(item.accountType);

    final totalText = showBalance
        ? context.dsFormatters.formatMoney(item.total, baseCurrency)
        : '—';
    final subaccountsText = subtitleOverride ??
        '${item.subaccountsCount} ${l10n.subaccountsCountLabel}';

    return InkWell(
      borderRadius: BorderRadius.circular(context.dsRadius.r16),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: spacing.s12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(context.dsRadius.r16),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(context.dsRadius.r12),
              ),
              alignment: Alignment.center,
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            SizedBox(width: spacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.accountName, style: typography.h3),
                  SizedBox(height: spacing.s4),
                  Text(
                    subaccountsText,
                    style: typography.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              totalText,
              textAlign: TextAlign.right,
              style: typography.body.copyWith(
                fontWeight: FontWeight.w700,
                color: showBalance ? null : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
