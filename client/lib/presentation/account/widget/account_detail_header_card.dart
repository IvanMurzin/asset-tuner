import 'package:asset_tuner/core_ui/formatting/ds_formatters.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

class AccountDetailHeaderCard extends StatelessWidget {
  const AccountDetailHeaderCard({
    super.key,
    required this.account,
    required this.baseCurrency,
    required this.total,
    required this.pricedTotal,
    required this.ratesAsOf,
  });

  final AccountEntity account;
  final String baseCurrency;
  final Decimal? total;
  final Decimal? pricedTotal;
  final DateTime? ratesAsOf;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final colors = context.dsColors;
    final gradient = _gradientColors(colors, account.type);
    final iconColor = _accentColor(colors, account.type);

    final totalText = total == null
        ? l10n.notAvailable
        : '$baseCurrency ${context.dsFormatters.formatDecimalFromDecimal(total!, maximumFractionDigits: 2)}';
    final pricedText = pricedTotal == null
        ? null
        : '$baseCurrency ${context.dsFormatters.formatDecimalFromDecimal(pricedTotal!, maximumFractionDigits: 2)}';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing.s24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(context.dsRadius.r16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(context.dsRadius.r12),
                ),
                alignment: Alignment.center,
                child: Icon(_icon(account.type), color: iconColor, size: 20),
              ),
              SizedBox(width: spacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.h3,
                    ),
                    SizedBox(height: spacing.s4),
                    Text(
                      _typeLabel(l10n, account.type),
                      style: typography.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.s16),
          Text(
            l10n.accountDetailTotalLabel,
            style: typography.caption.copyWith(color: colors.textSecondary),
          ),
          SizedBox(height: spacing.s8),
          Text(totalText, style: typography.h1),
          if (pricedText != null) ...[
            SizedBox(height: spacing.s12),
            Text(
              '${l10n.overviewPricedTotalLabel}: $pricedText',
              style: typography.body.copyWith(color: colors.textSecondary),
            ),
          ],
          SizedBox(height: spacing.s12),
          Text(
            ratesAsOf == null
                ? l10n.overviewRatesUnavailable
                : l10n.overviewRatesUpdatedAt(
                    context.dsFormatters.formatDateTime(ratesAsOf!),
                  ),
            style: typography.caption.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  List<Color> _gradientColors(DSColors colors, AccountType type) {
    return switch (type) {
      AccountType.bank => [
        colors.primary.withValues(alpha: 0.22),
        colors.primary.withValues(alpha: 0.08),
      ],
      AccountType.wallet => [
        colors.info.withValues(alpha: 0.22),
        colors.info.withValues(alpha: 0.08),
      ],
      AccountType.exchange => [
        colors.success.withValues(alpha: 0.22),
        colors.success.withValues(alpha: 0.08),
      ],
      AccountType.cash => [
        colors.warning.withValues(alpha: 0.26),
        colors.warning.withValues(alpha: 0.1),
      ],
      AccountType.other => [
        colors.textTertiary.withValues(alpha: 0.22),
        colors.textTertiary.withValues(alpha: 0.08),
      ],
    };
  }

  Color _accentColor(DSColors colors, AccountType type) {
    return switch (type) {
      AccountType.bank => colors.primary,
      AccountType.wallet => colors.info,
      AccountType.exchange => colors.success,
      AccountType.cash => colors.warning,
      AccountType.other => colors.textSecondary,
    };
  }

  IconData _icon(AccountType type) {
    return switch (type) {
      AccountType.bank => Icons.account_balance_outlined,
      AccountType.wallet => Icons.account_balance_wallet_outlined,
      AccountType.exchange => Icons.candlestick_chart_outlined,
      AccountType.cash => Icons.payments_outlined,
      AccountType.other => Icons.layers_outlined,
    };
  }

  String _typeLabel(AppLocalizations l10n, AccountType type) {
    return switch (type) {
      AccountType.bank => l10n.accountsTypeBank,
      AccountType.wallet => l10n.accountsTypeCryptoWallet,
      AccountType.exchange => l10n.accountsTypeExchange,
      AccountType.cash => l10n.accountsTypeCash,
      AccountType.other => l10n.accountsTypeOther,
    };
  }
}
