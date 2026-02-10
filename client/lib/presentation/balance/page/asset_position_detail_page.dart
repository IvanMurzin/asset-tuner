import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_empty_state.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_list_row.dart';
import 'package:asset_tuner/core_ui/components/ds_loader.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/formatting/ds_formatters.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/balance/entity/balance_entry_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/balance/bloc/asset_position_detail_cubit.dart';

class AssetPositionDetailPage extends StatelessWidget {
  const AssetPositionDetailPage({
    super.key,
    required this.accountId,
    required this.assetId,
  });

  final String accountId;
  final String assetId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) =>
          getIt<AssetPositionDetailCubit>()
            ..load(accountId: accountId, assetId: assetId),
      child: BlocConsumer<AssetPositionDetailCubit, AssetPositionDetailState>(
        listener: (context, state) {
          final navigation = state.navigation;
          if (navigation == null) {
            return;
          }
          context.read<AssetPositionDetailCubit>().consumeNavigation();
          switch (navigation.destination) {
            case AssetPositionDetailDestination.signIn:
              context.go(AppRoutes.signIn);
              break;
          }
        },
        builder: (context, state) {
          final spacing = context.dsSpacing;
          final typography = context.dsTypography;
          final colors = context.dsColors;

          if (state.status == AssetPositionDetailStatus.loading) {
            return const Scaffold(body: Center(child: DSLoader()));
          }

          final title = state.assetCode ?? l10n.notAvailable;

          if (state.status == AssetPositionDetailStatus.error &&
              state.accountAssetId == null) {
            return Scaffold(
              appBar: DSAppBar(title: title),
              body: DSInlineError(
                title: l10n.splashErrorTitle,
                message: _failureMessage(l10n, state.failureCode),
                actionLabel: l10n.splashRetry,
                onAction: () => context.read<AssetPositionDetailCubit>().load(
                  accountId: accountId,
                  assetId: assetId,
                ),
              ),
            );
          }

          final current = state.currentBalance ?? Decimal.zero;
          final currentText = context.dsFormatters.formatDecimalFromDecimal(
            current,
            maximumFractionDigits: 8,
          );

          final canLoadMore = state.nextOffset != null && !state.isLoadingMore;

          return Scaffold(
            appBar: DSAppBar(title: title),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.s24,
                  spacing.s24,
                  spacing.s24,
                  spacing.s16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.bannerFailureCode != null) ...[
                      DSInlineBanner(
                        title: title,
                        message: _failureMessage(l10n, state.bannerFailureCode),
                        variant: DSInlineBannerVariant.danger,
                      ),
                      SizedBox(height: spacing.s16),
                    ],
                    DSCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.positionCurrentBalanceLabel,
                            style: typography.caption,
                          ),
                          SizedBox(height: spacing.s8),
                          Text(
                            '$currentText ${state.assetCode ?? ''}',
                            style: typography.h2.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                          if (state.accountName != null) ...[
                            SizedBox(height: spacing.s8),
                            Text(
                              state.accountName!,
                              style: typography.caption.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: spacing.s24),
                    Row(
                      children: [
                        Expanded(
                          child: DSButton(
                            label: l10n.positionAddBalance,
                            onPressed: () async {
                              await context.push<bool>(
                                AppRoutes.addBalance
                                    .replaceFirst(':accountId', accountId)
                                    .replaceFirst(':assetId', assetId),
                              );
                              if (context.mounted) {
                                await context
                                    .read<AssetPositionDetailCubit>()
                                    .load(
                                      accountId: accountId,
                                      assetId: assetId,
                                    );
                              }
                            },
                          ),
                        ),
                        SizedBox(width: spacing.s12),
                        DSButton(
                          label: l10n.positionUpdateThisMonth,
                          variant: DSButtonVariant.secondary,
                          onPressed: () async {
                            final now = DateTime.now();
                            final date = DateTime(now.year, now.month, 1);
                            await context.push<bool>(
                              AppRoutes.addBalance
                                  .replaceFirst(':accountId', accountId)
                                  .replaceFirst(':assetId', assetId),
                              extra: date,
                            );
                            if (context.mounted) {
                              await context
                                  .read<AssetPositionDetailCubit>()
                                  .load(accountId: accountId, assetId: assetId);
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.s24),
                    DSSectionTitle(title: l10n.positionHistoryTitle),
                    SizedBox(height: spacing.s12),
                    Expanded(
                      child: state.entries.isEmpty
                          ? Center(
                              child: DSEmptyState(
                                title: l10n.positionHistoryEmptyTitle,
                                message: l10n.positionHistoryEmptyBody,
                                actionLabel: l10n.positionHistoryEmptyCta,
                                onAction: () => context.push<bool>(
                                  AppRoutes.addBalance
                                      .replaceFirst(':accountId', accountId)
                                      .replaceFirst(':assetId', assetId),
                                ),
                                icon: Icons.history_toggle_off_outlined,
                              ),
                            )
                          : Column(
                              children: [
                                Expanded(
                                  child: DSCard(
                                    padding: EdgeInsets.zero,
                                    child: ListView.separated(
                                      itemCount: state.entries.length,
                                      separatorBuilder: (context, index) =>
                                          const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final entry = state.entries[index];
                                        return _HistoryRow(entry: entry);
                                      },
                                    ),
                                  ),
                                ),
                                if (state.isLoadingMore) ...[
                                  SizedBox(height: spacing.s12),
                                  const DSLoader(),
                                ],
                                if (canLoadMore) ...[
                                  SizedBox(height: spacing.s12),
                                  DSButton(
                                    label: l10n.positionLoadMore,
                                    variant: DSButtonVariant.secondary,
                                    onPressed: () => context
                                        .read<AssetPositionDetailCubit>()
                                        .loadMore(),
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _failureMessage(AppLocalizations l10n, String? code) {
    return switch (code) {
      'network' => l10n.errorNetwork,
      'unauthorized' => l10n.errorUnauthorized,
      'forbidden' => l10n.errorForbidden,
      'not_found' => l10n.errorNotFound,
      'validation' => l10n.errorValidation,
      'conflict' => l10n.errorConflict,
      'rate_limited' => l10n.errorRateLimited,
      _ => l10n.errorGeneric,
    };
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry});

  final BalanceEntryEntity entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.dsTypography;
    final colors = context.dsColors;
    final dateText = context.dsFormatters.formatDate(entry.entryDate);

    final title = switch (entry.entryType) {
      BalanceEntryType.snapshot => l10n.balanceEntrySnapshot,
      BalanceEntryType.delta => l10n.balanceEntryDelta,
    };

    final amount = entry.entryType == BalanceEntryType.snapshot
        ? entry.snapshotAmount
        : entry.deltaAmount;
    final implied = entry.impliedDeltaAmount;

    final amountText = amount == null ? l10n.notAvailable : amount.toString();
    final impliedText = implied?.toString();

    final subtitleParts = <String>[dateText];
    if (entry.entryType == BalanceEntryType.snapshot && impliedText != null) {
      subtitleParts.add('${l10n.balanceEntryImpliedDeltaLabel}: $impliedText');
    }

    return DSListRow(
      title: title,
      subtitle: subtitleParts.join(' · '),
      trailing: Text(
        amountText,
        style: typography.body.copyWith(color: colors.textPrimary),
      ),
    );
  }
}
