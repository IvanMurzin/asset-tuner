import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';

List<Color> accountTypeGradientColors(DSColors colors, AccountType type) {
  return switch (type) {
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
}

Color accountTypeAccentColor(DSColors colors, AccountType type) {
  return switch (type) {
    AccountType.bank => colors.primary,
    AccountType.wallet => colors.info,
    AccountType.exchange => colors.success,
    AccountType.cash => colors.warning,
    AccountType.other => colors.textSecondary,
  };
}

IconData accountTypeIcon(AccountType type) {
  return switch (type) {
    AccountType.bank => Icons.account_balance_outlined,
    AccountType.wallet => Icons.account_balance_wallet_outlined,
    AccountType.exchange => Icons.candlestick_chart_outlined,
    AccountType.cash => Icons.payments_outlined,
    AccountType.other => Icons.layers_outlined,
  };
}
