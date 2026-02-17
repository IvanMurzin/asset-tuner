import 'package:asset_tuner/core/utils/decimal_math.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_empty_state.dart';
import 'package:asset_tuner/core_ui/components/ds_history_entry_card.dart';
import 'package:asset_tuner/core_ui/components/ds_loader.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/formatting/ds_formatters.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/balance/entity/balance_entry_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

class AssetPositionHistorySection extends StatelessWidget {
  const AssetPositionHistorySection({
    super.key,
    required this.entries,
    required this.assetCode,
    required this.baseCurrency,
    required this.currentBalance,
    required this.convertedValue,
    required this.isLoadingMore,
    required this.canLoadMore,
    required this.onLoadMore,
    required this.onAddBalance,
  });

  final List<BalanceEntryEntity> entries;
  final String? assetCode;
  final String baseCurrency;
  final Decimal currentBalance;
  final Decimal? convertedValue;
  final bool isLoadingMore;
  final bool canLoadMore;
  final VoidCallback onLoadMore;
  final VoidCallback onAddBalance;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSSectionTitle(title: l10n.positionHistoryTitle),
        SizedBox(height: spacing.s12),
        if (entries.isEmpty)
          Expanded(
            child: Center(
              child: DSEmptyState(
                title: l10n.positionHistoryEmptyTitle,
                message: l10n.positionHistoryEmptyBody,
                actionLabel: l10n.positionHistoryEmptyCta,
                onAction: onAddBalance,
                icon: Icons.history_toggle_off_outlined,
              ),
            ),
          )
        else
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: entries.length,
                    separatorBuilder: (context, index) => SizedBox(height: spacing.s8),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final factor = _conversionFactor(currentBalance, convertedValue);
                      final convertedSnapshot = factor == null
                          ? null
                          : entry.snapshotAmount * factor;
                      final diff = entry.diffAmount;
                      final convertedDiff = factor == null || diff == null ? null : diff * factor;
                      final deltaColor = diff == null
                          ? context.dsColors.textTertiary
                          : (diff.compareTo(Decimal.zero) >= 0
                                ? context.dsColors.success
                                : context.dsColors.danger);
                      final code = (assetCode ?? '').isEmpty ? l10n.notAvailable : assetCode!;
                      final snapshotAsset = code == l10n.notAvailable
                          ? context.dsFormatters.formatDecimalFromDecimal(
                              entry.snapshotAmount,
                              maximumFractionDigits: 8,
                            )
                          : context.dsFormatters.formatMoney(
                              entry.snapshotAmount,
                              code,
                              maximumFractionDigits: 8,
                            );
                      final snapshotBase = convertedSnapshot == null
                          ? l10n.unpriced
                          : context.dsFormatters.formatMoney(convertedSnapshot, baseCurrency);
                      return DSHistoryEntryCard(
                        dateText: context.dsFormatters.formatDateTime(entry.entryDate),
                        subtitleText: l10n.balanceEntryImpliedDeltaLabel,
                        deltaText: _assetDeltaText(context, diff, code, l10n),
                        deltaColor: deltaColor,
                        baseLineText: _baseDeltaText(context, convertedDiff, baseCurrency),
                        trailingTitle: l10n.balanceEntrySnapshot,
                        trailingPrimaryText: snapshotAsset,
                        trailingSecondaryText: snapshotBase,
                      );
                    },
                  ),
                ),
                if (isLoadingMore) ...[SizedBox(height: spacing.s12), const DSLoader()],
                if (canLoadMore) ...[
                  SizedBox(height: spacing.s12),
                  DSButton(
                    label: l10n.positionLoadMore,
                    variant: DSButtonVariant.secondary,
                    onPressed: onLoadMore,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Decimal? _conversionFactor(Decimal current, Decimal? converted) {
    if (converted == null) {
      return null;
    }
    if (current == Decimal.zero) {
      return null;
    }
    return divideToDecimal(converted, current);
  }

  String _assetDeltaText(BuildContext context, Decimal? diff, String code, AppLocalizations l10n) {
    if (diff == null) {
      return '-';
    }
    final trimmed = (assetCode ?? '').trim();
    return trimmed.isEmpty
        ? _signed(context, diff, digits: 8)
        : '${_signed(context, diff, digits: 8)} $code';
  }

  String _baseDeltaText(BuildContext context, Decimal? diff, String baseCurrency) {
    if (diff == null) {
      return '-';
    }
    return '${_signed(context, diff, digits: 2)} $baseCurrency';
  }

  String _signed(BuildContext context, Decimal value, {required int digits}) {
    final formatted = context.dsFormatters.formatDecimalFromDecimal(
      value,
      maximumFractionDigits: digits,
    );
    if (value.compareTo(Decimal.zero) > 0) {
      return '+$formatted';
    }
    return formatted;
  }
}
