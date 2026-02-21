import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core/utils/decimal_math.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_dialog.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_text_field.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/rate/entity/rates_snapshot_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/account/bloc/account_info_cubit.dart';
import 'package:asset_tuner/presentation/account/bloc/accounts_cubit.dart';
import 'package:asset_tuner/presentation/balance/bloc/subaccount_delete_cubit.dart';
import 'package:asset_tuner/presentation/balance/bloc/subaccount_info_cubit.dart';
import 'package:asset_tuner/presentation/balance/bloc/subaccount_update_cubit.dart';
import 'package:asset_tuner/presentation/balance/widget/subaccount_detail_actions_row.dart';
import 'package:asset_tuner/presentation/balance/widget/subaccount_detail_header_card.dart';
import 'package:asset_tuner/presentation/balance/widget/subaccount_detail_loading_skeleton.dart';
import 'package:asset_tuner/presentation/balance/widget/subaccount_history_loading_skeleton.dart';
import 'package:asset_tuner/presentation/balance/widget/subaccount_history_section.dart';
import 'package:asset_tuner/presentation/asset/bloc/assets_cubit.dart';
import 'package:asset_tuner/presentation/user/bloc/user_cubit.dart';

class SubaccountDetailPage extends StatelessWidget {
  const SubaccountDetailPage({
    super.key,
    required this.accountId,
    required this.subaccountId,
    this.initialTitle,
  });

  final String accountId;
  final String subaccountId;
  final String? initialTitle;

  @override
  Widget build(BuildContext context) {
    return _SubaccountDetailBody(
      accountId: accountId,
      subaccountId: subaccountId,
      initialTitle: initialTitle,
    );
  }
}

class _SubaccountDetailBody extends StatefulWidget {
  const _SubaccountDetailBody({
    required this.accountId,
    required this.subaccountId,
    this.initialTitle,
  });

  final String accountId;
  final String subaccountId;
  final String? initialTitle;

  @override
  State<_SubaccountDetailBody> createState() => _SubaccountDetailBodyState();
}

class _SubaccountDetailBodyState extends State<_SubaccountDetailBody> {
  bool _hasUnsyncedChange = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MultiBlocListener(
      listeners: [
        BlocListener<SubaccountInfoCubit, SubaccountInfoState>(
          listenWhen: (prev, curr) => curr.navigation != null,
          listener: (context, state) {
            final navigation = state.navigation;
            if (navigation == null) {
              return;
            }
            context.read<SubaccountInfoCubit>().consumeNavigation();
            if (navigation.destination == SubaccountInfoDestination.signIn) {
              context.go(AppRoutes.signIn);
            }
            if (navigation.destination == SubaccountInfoDestination.backDeleted) {
              context.pop(true);
            }
          },
        ),
        BlocListener<SubaccountUpdateCubit, SubaccountUpdateState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) async {
            if (state.status != SubaccountUpdateStatus.success || state.subaccount == null) {
              return;
            }
            final accountInfoCubit = context.read<AccountInfoCubit>();
            final subaccountInfoCubit = context.read<SubaccountInfoCubit>();
            final accountsCubit = context.read<AccountsCubit>();
            final updateCubit = context.read<SubaccountUpdateCubit>();
            final updated = state.subaccount!;
            accountInfoCubit.applyUpdatedSubaccount(updated);
            subaccountInfoCubit.updateSubaccount(updated);
            accountsCubit.refresh(silent: true);
            if (!mounted) {
              return;
            }
            setState(() => _hasUnsyncedChange = true);
            updateCubit.reset();
          },
        ),
        BlocListener<SubaccountDeleteCubit, SubaccountDeleteState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) async {
            if (state.status != SubaccountDeleteStatus.success ||
                state.deletedSubaccountId == null) {
              return;
            }
            final accountInfoCubit = context.read<AccountInfoCubit>();
            final accountsCubit = context.read<AccountsCubit>();
            final subaccountInfoCubit = context.read<SubaccountInfoCubit>();
            final deleteCubit = context.read<SubaccountDeleteCubit>();
            accountInfoCubit.applyDeletedSubaccount(state.deletedSubaccountId!);
            accountsCubit.refresh(silent: true);
            subaccountInfoCubit.onDeleted();
            deleteCubit.reset();
          },
        ),
      ],
      child: BlocBuilder<SubaccountInfoCubit, SubaccountInfoState>(
        builder: (context, state) {
          final spacing = context.dsSpacing;
          final subaccount = state.subaccount;
          final title = widget.initialTitle ?? subaccount?.name ?? l10n.notAvailable;

          if (subaccount == null && state.status == SubaccountInfoStatus.loading) {
            return Scaffold(
              appBar: DSAppBar(title: title),
              body: SafeArea(child: const SubaccountDetailLoadingSkeleton()),
            );
          }

          if (subaccount == null) {
            return Scaffold(
              appBar: DSAppBar(title: title),
              body: DSInlineError(
                title: l10n.splashErrorTitle,
                message: state.failureMessage ?? l10n.errorGeneric,
                actionLabel: l10n.splashRetry,
                onAction: () => context.pop(),
              ),
            );
          }

          final user = context.watch<UserCubit>().state;
          final rates = context.watch<AssetsCubit>().state.snapshot;
          final baseCurrency = user.profile?.baseCurrency ?? 'USD';
          final baseUsdPrice = _baseUsdPrice(user, rates);

          final current = state.entries.isEmpty
              ? (subaccount.currentAmount ?? Decimal.zero)
              : state.entries.first.snapshotAmount;
          final assetUsd = subaccount.usdRate?.usdPrice;
          Decimal? converted;
          if (current == Decimal.zero) {
            converted = Decimal.zero;
          } else if (baseUsdPrice != null && assetUsd != null && baseUsdPrice != Decimal.zero) {
            converted = divideToDecimal(current * assetUsd, baseUsdPrice);
          }
          final isUnpriced = current != Decimal.zero && converted == null;

          final updateState = context.watch<SubaccountUpdateCubit>().state;
          final deleteState = context.watch<SubaccountDeleteCubit>().state;
          final isMutating =
              updateState.status == SubaccountUpdateStatus.loading ||
              deleteState.status == SubaccountDeleteStatus.loading;

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) {
                context.pop(_hasUnsyncedChange);
              }
            },
            child: Scaffold(
              appBar: DSAppBar(title: title),
              body: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: spacing.s24),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing.s24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (state.failureCode != null) ...[
                            DSInlineBanner(
                              title: title,
                              message: state.failureMessage ?? l10n.errorGeneric,
                              variant: DSInlineBannerVariant.danger,
                            ),
                            SizedBox(height: spacing.s12),
                          ],
                          if (updateState.status == SubaccountUpdateStatus.error) ...[
                            DSInlineBanner(
                              title: title,
                              message: updateState.failureMessage ?? l10n.errorGeneric,
                              variant: DSInlineBannerVariant.danger,
                            ),
                            SizedBox(height: spacing.s12),
                          ],
                          if (deleteState.status == SubaccountDeleteStatus.error) ...[
                            DSInlineBanner(
                              title: title,
                              message: deleteState.failureMessage ?? l10n.errorGeneric,
                              variant: DSInlineBannerVariant.danger,
                            ),
                            SizedBox(height: spacing.s12),
                          ],
                          SubaccountDetailHeaderCard(
                            subaccountName: subaccount.name,
                            accountName: state.account?.name,
                            assetCode: subaccount.asset?.code,
                            baseCurrency: baseCurrency,
                            currentBalance: current,
                            convertedValue: converted,
                            ratesAsOf: rates?.asOf,
                          ),
                          if (isUnpriced) ...[
                            SizedBox(height: spacing.s12),
                            DSInlineBanner(
                              title: l10n.unpriced,
                              message: l10n.positionUnpricedHint,
                              variant: DSInlineBannerVariant.warning,
                            ),
                          ],
                          SizedBox(height: spacing.s16),
                          SubaccountDetailActionsRow(
                            isEnabled: !isMutating,
                            updateLabel: l10n.subaccountUpdateBalanceCta,
                            renameLabel: l10n.subaccountRenameCta,
                            deleteLabel: l10n.subaccountDeleteCta,
                            onUpdate: () async {
                              final saved = await context.push<bool>(
                                AppRoutes.accountSubaccountBalance
                                    .replaceFirst(':accountId', widget.accountId)
                                    .replaceFirst(':subaccountId', widget.subaccountId),
                              );
                              if (saved == true && context.mounted) {
                                setState(() => _hasUnsyncedChange = true);
                              }
                            },
                            onRename: () async {
                              final name = await _showRenameDialog(
                                context,
                                initial: subaccount.name,
                              );
                              if (name == null || !context.mounted) {
                                return;
                              }
                              await context.read<SubaccountUpdateCubit>().submit(
                                subaccountId: widget.subaccountId,
                                name: name,
                              );
                            },
                            onDelete: () async {
                              final confirmed = await _confirmDelete(context, l10n);
                              if (!confirmed || !context.mounted) {
                                return;
                              }
                              await context.read<SubaccountDeleteCubit>().submit(
                                widget.subaccountId,
                              );
                            },
                          ),
                          SizedBox(height: spacing.s24),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: spacing.s24),
                        child: state.isHistoryLoading
                            ? const SubaccountHistoryLoadingSkeleton()
                            : SubaccountHistorySection(
                                entries: state.entries,
                                assetCode: subaccount.asset?.code,
                                baseCurrency: baseCurrency,
                                currentBalance: current,
                                convertedValue: converted,
                                isLoadingMore: state.isLoadingMore,
                                canLoadMore: state.nextCursor != null && !state.isLoadingMore,
                                onLoadMore: () => context.read<SubaccountInfoCubit>().loadMore(),
                                onAddBalance: () async {
                                  final saved = await context.push<bool>(
                                    AppRoutes.accountSubaccountBalance
                                        .replaceFirst(':accountId', widget.accountId)
                                        .replaceFirst(':subaccountId', widget.subaccountId),
                                  );
                                  if (saved == true && context.mounted) {
                                    setState(() => _hasUnsyncedChange = true);
                                  }
                                },
                              ),
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

  Decimal? _baseUsdPrice(UserState user, RatesSnapshotEntity? snapshot) {
    final baseCurrency = user.profile?.baseCurrency ?? 'USD';
    if (baseCurrency == 'USD') {
      return Decimal.one;
    }
    final baseAssetId = user.profile?.baseAssetId;
    if (baseAssetId == null) {
      return null;
    }
    return snapshot?.usdPriceByAssetId[baseAssetId];
  }

  Future<bool> _confirmDelete(BuildContext context, AppLocalizations l10n) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => DSDialog(
        title: l10n.subaccountDeleteConfirmTitle,
        content: Text(l10n.subaccountDeleteConfirmBody),
        primaryLabel: l10n.subaccountDeleteCta,
        secondaryLabel: l10n.cancel,
        isDestructive: true,
        onSecondary: () => Navigator.of(dialogContext).pop(false),
        onPrimary: () => Navigator.of(dialogContext).pop(true),
      ),
    );
    return result ?? false;
  }

  Future<String?> _showRenameDialog(BuildContext context, {required String initial}) async {
    final l10n = AppLocalizations.of(context)!;
    final value = await showDialog<String?>(
      context: context,
      builder: (_) => _RenameSubaccountDialog(l10n: l10n, initial: initial),
    );
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value.trim();
  }
}

class _RenameSubaccountDialog extends StatefulWidget {
  const _RenameSubaccountDialog({required this.l10n, required this.initial});

  final AppLocalizations l10n;
  final String initial;

  @override
  State<_RenameSubaccountDialog> createState() => _RenameSubaccountDialogState();
}

class _RenameSubaccountDialogState extends State<_RenameSubaccountDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DSDialog(
      title: widget.l10n.subaccountRenameCta,
      content: DSTextField(label: widget.l10n.accountsNameLabel, controller: _controller),
      primaryLabel: widget.l10n.save,
      secondaryLabel: widget.l10n.cancel,
      onSecondary: () => Navigator.of(context).pop(),
      onPrimary: () => Navigator.of(context).pop(_controller.text.trim()),
    );
  }
}
