import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/formatting/ds_formatters.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/overview/bloc/overview_cubit.dart';

class OverviewAccountCard extends StatelessWidget {
  const OverviewAccountCard({
    super.key,
    required this.item,
    required this.baseCurrency,
    required this.onTap,
  });

  final OverviewAccountItem item;
  final String baseCurrency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final typography = context.dsTypography;
    final spacing = context.dsSpacing;
    final l10n = AppLocalizations.of(context)!;

    final gradient = switch (item.accountType) {
      AccountType.bank => [
        colors.primary.withValues(alpha: 0.22),
        colors.primary.withValues(alpha: 0.06),
      ],
      AccountType.wallet => [
        colors.info.withValues(alpha: 0.22),
        colors.info.withValues(alpha: 0.06),
      ],
      AccountType.exchange => [
        colors.success.withValues(alpha: 0.22),
        colors.success.withValues(alpha: 0.06),
      ],
      AccountType.cash => [
        colors.warning.withValues(alpha: 0.25),
        colors.warning.withValues(alpha: 0.08),
      ],
      AccountType.other => [
        colors.textTertiary.withValues(alpha: 0.2),
        colors.textTertiary.withValues(alpha: 0.06),
      ],
    };
    final iconColor = switch (item.accountType) {
      AccountType.bank => colors.primary,
      AccountType.wallet => colors.info,
      AccountType.exchange => colors.success,
      AccountType.cash => colors.warning,
      AccountType.other => colors.textSecondary,
    };
    final iconData = switch (item.accountType) {
      AccountType.bank => Icons.account_balance_outlined,
      AccountType.wallet => Icons.account_balance_wallet_outlined,
      AccountType.exchange => Icons.candlestick_chart_outlined,
      AccountType.cash => Icons.payments_outlined,
      AccountType.other => Icons.layers_outlined,
    };

    final totalText =
        '$baseCurrency ${context.dsFormatters.formatDecimalFromDecimal(item.total, maximumFractionDigits: 2)}';
    final subaccountsText =
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
              style: typography.body.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
