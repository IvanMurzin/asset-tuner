library;

import 'dart:async';

import 'package:asset_tuner/core/utils/decimal_math.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/core_ui/formatting/ds_formatters.dart';
import 'package:asset_tuner/core_ui/components/ds_empty_state.dart';
import 'package:asset_tuner/core_ui/components/ds_search_field.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/asset/bloc/assets_cubit.dart';
import 'package:asset_tuner/presentation/asset/widget/asset_currency_search_index.dart';
import 'package:asset_tuner/presentation/profile/bloc/profile_cubit.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'asset_currency_badge_asset_list.dart';
part 'asset_currency_badge_asset_row.dart';
part 'asset_currency_badge_bottom_sheet.dart';
part 'asset_currency_badge_models.dart';
part 'asset_currency_badge_tab_bar.dart';

enum CurrencyType { fiat, crypto, all }

class AssetCurrencyBadge extends StatelessWidget {
  const AssetCurrencyBadge({
    super.key,
    required this.currencyType,
    required this.selectedSlug,
    required this.sheetTitleText,
    required this.placeholderText,
    required this.searchHintText,
    required this.fiatTabText,
    required this.cryptoTabText,
    required this.emptyResultsTitle,
    required this.emptyResultsMessage,
    required this.onSelected,
    required this.onLocked,
    this.enabled = true,
    this.errorText,
    this.baseCurrencyCode,
  });

  final CurrencyType currencyType;
  final String? selectedSlug;
  final String sheetTitleText;
  final String placeholderText;
  final String searchHintText;
  final String fiatTabText;
  final String cryptoTabText;
  final String emptyResultsTitle;
  final String emptyResultsMessage;
  final bool enabled;
  final String? errorText;
  final String? baseCurrencyCode;
  final ValueChanged<AssetEntity> onSelected;
  final ValueChanged<AssetEntity> onLocked;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final radius = context.dsRadius;
    final typography = context.dsTypography;
    final slug = selectedSlug?.trim().toUpperCase();
    final hasSlug = slug != null && slug.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(radius.r8),
            onTap: enabled ? () => _openSheet(context) : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 36),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.s8, vertical: spacing.s4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hasSlug ? slug : placeholderText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.copyWith(
                        color: hasSlug ? colors.textPrimary : colors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (enabled) ...[
                      SizedBox(width: spacing.s4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: colors.textSecondary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        if (errorText != null && errorText!.trim().isNotEmpty) ...[
          SizedBox(height: spacing.s4),
          SizedBox(
            width: 220,
            child: Text(
              errorText!,
              textAlign: TextAlign.right,
              style: typography.caption.copyWith(color: colors.danger),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _openSheet(BuildContext context) async {
    final assetsCubit = context.read<AssetsCubit>();
    final result = await showGeneralDialog<_AssetSelectionResult>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierLabel: 'close',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (dialogContext, animation, secondaryAnimation) =>
          BlocProvider<AssetsCubit>.value(
            value: assetsCubit,
            child: Material(
              color: Colors.transparent,
              child: SizedBox.expand(
                child: _AssetCurrencyBottomSheet(
                  currencyType: currencyType,
                  selectedSlug: selectedSlug,
                  baseCurrencyCode: _resolveBaseCurrencyCode(context),
                  sheetTitleText: sheetTitleText,
                  searchHintText: searchHintText,
                  fiatTabText: fiatTabText,
                  cryptoTabText: cryptoTabText,
                  emptyResultsTitle: emptyResultsTitle,
                  emptyResultsMessage: emptyResultsMessage,
                ),
              ),
            ),
          ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(curve),
          child: child,
        );
      },
    );

    if (result == null) {
      return;
    }
    if (result.locked) {
      onLocked(result.asset);
      return;
    }
    onSelected(result.asset);
  }

  String _resolveBaseCurrencyCode(BuildContext context) {
    final normalizedExplicit = baseCurrencyCode?.trim().toUpperCase();
    if (normalizedExplicit != null && normalizedExplicit.isNotEmpty) {
      return normalizedExplicit;
    }
    try {
      final profile = context.read<ProfileCubit>().state.profile;
      final normalizedProfile = profile?.baseCurrency.trim().toUpperCase();
      if (normalizedProfile != null && normalizedProfile.isNotEmpty) {
        return normalizedProfile;
      }
    } catch (_) {}
    return 'USD';
  }
}
