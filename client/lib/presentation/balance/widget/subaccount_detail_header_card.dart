import 'package:asset_tuner/core_ui/formatting/ds_formatters.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

class SubaccountDetailHeaderCard extends StatelessWidget {
  const SubaccountDetailHeaderCard({
    super.key,
    required this.subaccountName,
    required this.accountName,
    required this.assetCode,
    required this.baseCurrency,
    required this.currentBalance,
    required this.convertedValue,
    required this.ratesAsOf,
  });

  final String? subaccountName;
  final String? accountName;
  final String? assetCode;
  final String baseCurrency;
  final Decimal currentBalance;
  final Decimal? convertedValue;
  final DateTime? ratesAsOf;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final colors = context.dsColors;

    final assetText = (assetCode ?? '').isEmpty
        ? context.dsFormatters.formatDecimalFromDecimal(currentBalance, maximumFractionDigits: 8)
        : context.dsFormatters.formatMoney(currentBalance, assetCode!, maximumFractionDigits: 8);
    final convertedText = convertedValue == null
        ? l10n.unpriced
        : context.dsFormatters.formatMoney(convertedValue!, baseCurrency);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.info.withValues(alpha: 0.2), colors.success.withValues(alpha: 0.08)],
        ),
        borderRadius: BorderRadius.circular(context.dsRadius.r16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.info.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(context.dsRadius.r12),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.show_chart, color: colors.info, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subaccountName ?? l10n.notAvailable,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.h3,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      accountName ?? l10n.notAvailable,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.caption.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              if ((assetCode ?? '').isNotEmpty)
                Text(
                  assetCode!,
                  style: typography.caption.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(assetText, style: typography.h2.copyWith(fontWeight: FontWeight.w700)),
          SizedBox(height: spacing.s4),
          Text(convertedText, style: typography.body.copyWith(color: colors.textSecondary)),
          SizedBox(height: spacing.s8),
          Text(
            ratesAsOf == null
                ? l10n.overviewRatesUnavailable
                : l10n.overviewRatesUpdatedAt(context.dsFormatters.formatDateTime(ratesAsOf!)),
            style: typography.caption.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
