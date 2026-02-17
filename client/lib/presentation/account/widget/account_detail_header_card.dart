import 'package:asset_tuner/core_ui/formatting/ds_formatters.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/account/utils/account_type_theme.dart';
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
    final gradient = accountTypeGradientColors(colors, account.type);
    final iconColor = accountTypeAccentColor(colors, account.type);

    final totalText = total == null
        ? l10n.notAvailable
        : context.dsFormatters.formatMoney(total!, baseCurrency);
    final pricedText = pricedTotal == null
        ? null
        : context.dsFormatters.formatMoney(pricedTotal!, baseCurrency);

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
                child: Icon(accountTypeIcon(account.type), color: iconColor, size: 20),
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
                      style: typography.caption.copyWith(color: colors.textSecondary),
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
                : l10n.overviewRatesUpdatedAt(context.dsFormatters.formatDateTime(ratesAsOf!)),
            style: typography.caption.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
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
