import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_empty_state.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/formatting/ds_formatters.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/account/widget/subaccount_view_item.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

class AccountDetailPositionsSection extends StatelessWidget {
  const AccountDetailPositionsSection({
    super.key,
    required this.items,
    required this.baseCurrency,
    required this.onOpenSubaccount,
    required this.onAddSubaccount,
  });

  final List<SubaccountViewItem> items;
  final String baseCurrency;
  final Future<void> Function(SubaccountViewItem item) onOpenSubaccount;
  final VoidCallback onAddSubaccount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;
    final sortedItems = _sortByBalance(items);

    if (sortedItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DSEmptyState(
              title: l10n.subaccountEmptyTitle,
              message: l10n.subaccountEmptyBody,
              icon: Icons.add_circle_outline,
            ),
            SizedBox(height: spacing.s16),
            DSButton(label: l10n.subaccountCreateCta, fullWidth: true, onPressed: onAddSubaccount),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSSectionTitle(title: l10n.subaccountListTitle),
        SizedBox(height: spacing.s12),
        for (var i = 0; i < sortedItems.length; i++) ...[
          _PositionCard(
            item: sortedItems[i],
            baseCurrency: baseCurrency,
            onTap: () => onOpenSubaccount(sortedItems[i]),
          ),
          if (i != sortedItems.length - 1) const SizedBox(height: 10),
        ],
        SizedBox(height: spacing.s24),
        DSButton(label: l10n.subaccountCreateCta, fullWidth: true, onPressed: onAddSubaccount),
      ],
    );
  }

  List<SubaccountViewItem> _sortByBalance(List<SubaccountViewItem> source) {
    final sorted = [...source];
    sorted.sort((a, b) {
      final aConverted = a.convertedAmount ?? Decimal.zero;
      final bConverted = b.convertedAmount ?? Decimal.zero;
      final convertedCompare = bConverted.compareTo(aConverted);
      if (convertedCompare != 0) {
        return convertedCompare;
      }
      return b.originalAmount.compareTo(a.originalAmount);
    });
    return sorted;
  }
}

class _PositionCard extends StatelessWidget {
  const _PositionCard({required this.item, required this.baseCurrency, required this.onTap});

  final SubaccountViewItem item;
  final String baseCurrency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.dsColors;
    final typography = context.dsTypography;
    final spacing = context.dsSpacing;
    final gradient = _gradientByKind(colors, item.assetKind);

    final convertedText = item.isPriced
        ? context.dsFormatters.formatMoney(item.convertedAmount!, baseCurrency)
        : l10n.unpriced;
    final originalText = context.dsFormatters.formatMoney(
      item.originalAmount,
      item.assetCode,
      maximumFractionDigits: 8,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(context.dsRadius.r16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
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
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _accentByKind(colors, item.assetKind).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(context.dsRadius.r12),
              ),
              alignment: Alignment.center,
              child: Icon(
                _iconByKind(item.assetKind),
                color: _accentByKind(colors, item.assetKind),
                size: 20,
              ),
            ),
            SizedBox(width: spacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: typography.h3),
                  SizedBox(height: spacing.s4),
                  Text(
                    '${item.assetName} · ${_kindLabel(l10n, item.assetKind)}',
                    style: typography.caption.copyWith(color: colors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: spacing.s12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  convertedText,
                  textAlign: TextAlign.right,
                  style: typography.h3.copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: spacing.s4),
                Text(
                  originalText,
                  textAlign: TextAlign.right,
                  style: typography.body.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _gradientByKind(DSColors colors, AssetKind kind) {
    return switch (kind) {
      AssetKind.fiat => [
        colors.primary.withValues(alpha: 0.18),
        colors.primary.withValues(alpha: 0.06),
      ],
      AssetKind.crypto => [
        colors.success.withValues(alpha: 0.2),
        colors.success.withValues(alpha: 0.06),
      ],
    };
  }

  Color _accentByKind(DSColors colors, AssetKind kind) {
    return switch (kind) {
      AssetKind.fiat => colors.primary,
      AssetKind.crypto => colors.success,
    };
  }

  IconData _iconByKind(AssetKind kind) {
    return switch (kind) {
      AssetKind.fiat => Icons.attach_money,
      AssetKind.crypto => Icons.currency_bitcoin,
    };
  }

  String _kindLabel(AppLocalizations l10n, AssetKind kind) {
    return switch (kind) {
      AssetKind.fiat => l10n.assetKindFiat,
      AssetKind.crypto => l10n.assetKindCrypto,
    };
  }
}
