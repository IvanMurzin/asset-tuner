import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_dialog.dart';
import 'package:asset_tuner/core_ui/components/ds_empty_state.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_list_row.dart';
import 'package:asset_tuner/core_ui/components/ds_loader.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/components/ds_text_field.dart';
import 'package:asset_tuner/core_ui/formatting/ds_formatters.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/balance/entity/balance_entry_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/balance/bloc/asset_position_detail_cubit.dart';

class AssetPositionDetailPage extends StatelessWidget {
  const AssetPositionDetailPage({super.key, required this.subaccountId});

  final String subaccountId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) =>
          getIt<AssetPositionDetailCubit>()..load(subaccountId: subaccountId),
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
            case AssetPositionDetailDestination.backDeleted:
              context.pop(true);
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

          final title =
              state.subaccountName ?? state.assetCode ?? l10n.notAvailable;

          if (state.status == AssetPositionDetailStatus.error &&
              state.subaccountId == null) {
            return Scaffold(
              appBar: DSAppBar(title: title),
              body: DSInlineError(
                title: l10n.splashErrorTitle,
                message: _failureMessage(l10n, state.failureCode),
                actionLabel: l10n.splashRetry,
                onAction: () => context.read<AssetPositionDetailCubit>().load(
                  subaccountId: subaccountId,
                ),
              ),
            );
          }

          final current = state.currentBalance ?? Decimal.zero;
          final currentText = context.dsFormatters.formatDecimalFromDecimal(
            current,
            maximumFractionDigits: 8,
          );
          final baseCurrency = state.baseCurrency ?? 'USD';
          final convertedValue = state.convertedValue;
          final convertedText = convertedValue == null
              ? l10n.unpriced
              : '$baseCurrency ${context.dsFormatters.formatDecimalFromDecimal(convertedValue, maximumFractionDigits: 2)}';

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
                          SizedBox(height: spacing.s12),
                          Text(
                            l10n.positionConvertedValueLabel,
                            style: typography.caption.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          SizedBox(height: spacing.s4),
                          Text(
                            convertedText,
                            style: typography.h3.copyWith(
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
                    if (state.isUnpriced) ...[
                      SizedBox(height: spacing.s16),
                      DSInlineBanner(
                        title: l10n.unpriced,
                        message: l10n.positionUnpricedHint,
                        variant: DSInlineBannerVariant.warning,
                      ),
                    ],
                    SizedBox(height: spacing.s16),
                    DSSectionTitle(title: l10n.actionsTitle),
                    SizedBox(height: spacing.s12),
                    Row(
                      children: [
                        Expanded(
                          child: DSButton(
                            label: l10n.subaccountUpdateBalanceCta,
                            onPressed: () async {
                              await context.push<bool>(
                                AppRoutes.addBalance.replaceFirst(
                                  ':id',
                                  subaccountId,
                                ),
                              );
                              if (context.mounted) {
                                await context
                                    .read<AssetPositionDetailCubit>()
                                    .load(subaccountId: subaccountId);
                              }
                            },
                          ),
                        ),
                        SizedBox(width: spacing.s8),
                        DSButton(
                          label: l10n.subaccountRenameCta,
                          variant: DSButtonVariant.secondary,
                          onPressed: state.isMutating
                              ? null
                              : () async {
                                  final name = await _showRenameDialog(
                                    context,
                                    initial: state.subaccountName ?? '',
                                  );
                                  if (name == null || !context.mounted) {
                                    return;
                                  }
                                  await context
                                      .read<AssetPositionDetailCubit>()
                                      .rename(name);
                                },
                        ),
                        SizedBox(width: spacing.s8),
                        DSButton(
                          label: l10n.subaccountDeleteCta,
                          variant: DSButtonVariant.danger,
                          onPressed: state.isMutating
                              ? null
                              : () async {
                                  final confirmed = await _confirmDelete(
                                    context,
                                    l10n,
                                  );
                                  if (!confirmed || !context.mounted) {
                                    return;
                                  }
                                  await context
                                      .read<AssetPositionDetailCubit>()
                                      .deleteSubaccount();
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
                                  AppRoutes.addBalance.replaceFirst(
                                    ':id',
                                    subaccountId,
                                  ),
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

  Future<bool> _confirmDelete(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => DSDialog(
        title: l10n.subaccountDeleteConfirmTitle,
        content: Text(l10n.subaccountDeleteConfirmBody),
        primaryLabel: l10n.subaccountDeleteCta,
        secondaryLabel: l10n.cancel,
        isDestructive: true,
        onSecondary: () => Navigator.of(context).pop(false),
        onPrimary: () => Navigator.of(context).pop(true),
      ),
    );
    return result ?? false;
  }

  Future<String?> _showRenameDialog(
    BuildContext context, {
    required String initial,
  }) async {
    final controller = TextEditingController(text: initial);
    final l10n = AppLocalizations.of(context)!;
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => DSDialog(
        title: l10n.subaccountRenameTitle,
        content: DSTextField(
          label: l10n.accountsNameLabel,
          controller: controller,
        ),
        primaryLabel: l10n.save,
        secondaryLabel: l10n.cancel,
        onSecondary: () => Navigator.of(dialogContext).pop(),
        onPrimary: () =>
            Navigator.of(dialogContext).pop(controller.text.trim()),
      ),
    );
    controller.dispose();
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value.trim();
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

    final amountText = entry.snapshotAmount.toString();
    final diffText = entry.diffAmount?.toString();

    final subtitleParts = <String>[dateText];
    if (diffText != null) {
      subtitleParts.add('${l10n.balanceEntryImpliedDeltaLabel}: $diffText');
    }

    return DSListRow(
      title: l10n.balanceEntrySnapshot,
      subtitle: subtitleParts.join(' · '),
      trailing: Text(
        amountText,
        style: typography.body.copyWith(color: colors.textPrimary),
      ),
    );
  }
}
