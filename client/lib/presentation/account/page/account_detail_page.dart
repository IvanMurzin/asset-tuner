import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core/routing/route_extra_args.dart';
import 'package:asset_tuner/core/utils/decimal_math.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_dialog.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/account/bloc/account_archive_cubit.dart';
import 'package:asset_tuner/presentation/account/bloc/account_delete_cubit.dart';
import 'package:asset_tuner/presentation/account/bloc/account_info_cubit.dart';
import 'package:asset_tuner/presentation/account/bloc/accounts_cubit.dart';
import 'package:asset_tuner/presentation/account/widget/subaccount_view_item.dart';
import 'package:asset_tuner/presentation/account/widget/account_detail_actions_row.dart';
import 'package:asset_tuner/presentation/account/widget/account_detail_header_card.dart';
import 'package:asset_tuner/presentation/account/widget/account_detail_loading_skeleton.dart';
import 'package:asset_tuner/presentation/account/widget/account_detail_positions_loading_skeleton.dart';
import 'package:asset_tuner/presentation/account/widget/account_detail_positions_section.dart';
import 'package:asset_tuner/domain/rate/entity/rates_snapshot_entity.dart';
import 'package:asset_tuner/presentation/asset/bloc/assets_cubit.dart';
import 'package:asset_tuner/presentation/profile/bloc/profile_cubit.dart';

class AccountDetailPage extends StatelessWidget {
  const AccountDetailPage({
    super.key,
    required this.accountId,
    this.initialTitle,
    this.initialAccountType,
  });

  final String accountId;
  final String? initialTitle;
  final AccountType? initialAccountType;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MultiBlocListener(
      listeners: [
        BlocListener<AccountInfoCubit, AccountInfoState>(
          listenWhen: (prev, curr) => curr.navigation != null,
          listener: (context, state) {
            final navigation = state.navigation;
            if (navigation == null) {
              return;
            }
            context.read<AccountInfoCubit>().consumeNavigation();
            if (navigation.destination == AccountInfoDestination.signIn) {
              context.go(AppRoutes.signIn);
            }
          },
        ),
        BlocListener<AccountsCubit, AccountsState>(
          listenWhen: (prev, curr) =>
              prev.accounts.length != curr.accounts.length || prev.accounts != curr.accounts,
          listener: (context, state) {
            context.read<AccountInfoCubit>().setAccount(
              context.read<AccountsCubit>().findById(accountId),
            );
          },
        ),
        BlocListener<AccountArchiveCubit, AccountArchiveState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) async {
            if (state.status != AccountArchiveStatus.success || state.account == null) {
              return;
            }
            final accountsCubit = context.read<AccountsCubit>();
            final archiveCubit = context.read<AccountArchiveCubit>();
            accountsCubit.archive(state.account!);
            if (!context.mounted) {
              return;
            }
            archiveCubit.reset();
          },
        ),
        BlocListener<AccountDeleteCubit, AccountDeleteState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) async {
            if (state.status != AccountDeleteStatus.success || state.deletedAccountId == null) {
              return;
            }
            final accountsCubit = context.read<AccountsCubit>();
            final deleteCubit = context.read<AccountDeleteCubit>();
            if (context.mounted) {
              context.pop(true);
            }
            accountsCubit.delete(state.deletedAccountId!);
            deleteCubit.reset();
          },
        ),
      ],
      child: BlocBuilder<AccountInfoCubit, AccountInfoState>(
        builder: (context, infoState) {
          final spacing = context.dsSpacing;

          final account = infoState.account;
          if (account == null && infoState.status == AccountInfoStatus.loading) {
            return Scaffold(
              appBar: DSAppBar(title: initialTitle ?? l10n.accountsTitle),
              body: SafeArea(child: AccountDetailLoadingSkeleton(accountType: initialAccountType)),
            );
          }

          if (account == null) {
            return Scaffold(
              appBar: DSAppBar(title: initialTitle ?? l10n.accountsTitle),
              body: DSInlineError(
                title: l10n.splashErrorTitle,
                message: infoState.failureMessage ?? l10n.errorGeneric,
                actionLabel: l10n.splashRetry,
                onAction: () => context.read<AccountsCubit>().refresh(),
              ),
            );
          }

          final profileState = context.watch<ProfileCubit>().state;
          final assetsState = context.watch<AssetsCubit>().state;
          final rates = assetsState.snapshot;
          final baseCurrency = profileState.profile?.baseCurrency ?? 'USD';
          final baseUsdPrice = _baseUsdPrice(profileState, assetsState.snapshot);
          final total = _toBase(account.totals?.totalUsd, baseCurrency, baseUsdPrice);

          final items = infoState.subaccounts.map((subaccount) {
            final asset = subaccount.asset;
            final original = subaccount.currentAmount ?? Decimal.zero;
            final assetUsd = subaccount.usdRate?.usdPrice;
            Decimal? converted;
            if (original == Decimal.zero) {
              converted = Decimal.zero;
            } else if (baseUsdPrice != null && assetUsd != null && baseUsdPrice != Decimal.zero) {
              converted = divideToDecimal(original * assetUsd, baseUsdPrice);
            }

            return SubaccountViewItem(
              subaccountId: subaccount.id,
              assetId: subaccount.assetId,
              name: subaccount.name,
              assetCode: asset?.code ?? 'N/A',
              assetName: asset?.name ?? 'Unknown',
              assetKind: asset?.kind ?? AssetKind.fiat,
              originalAmount: original,
              convertedAmount: converted,
            );
          }).toList();

          final archiveState = context.watch<AccountArchiveCubit>().state;
          final deleteState = context.watch<AccountDeleteCubit>().state;
          final isBusy =
              archiveState.status == AccountArchiveStatus.loading ||
              deleteState.status == AccountDeleteStatus.loading;

          return Scaffold(
            appBar: DSAppBar(title: account.name),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  final accountInfoCubit = context.read<AccountInfoCubit>();
                  final accountsCubit = context.read<AccountsCubit>();
                  await accountInfoCubit.refreshSubaccounts(silent: false);
                  await accountsCubit.refresh(silent: true);
                },
                child: ListView(
                  children: [
                    SizedBox(height: spacing.s24),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing.s24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (infoState.failureCode != null) ...[
                            DSInlineBanner(
                              title: account.name,
                              message: infoState.failureMessage ?? l10n.errorGeneric,
                              variant: DSInlineBannerVariant.danger,
                            ),
                            SizedBox(height: spacing.s12),
                          ],
                          if (archiveState.status == AccountArchiveStatus.error) ...[
                            DSInlineBanner(
                              title: account.name,
                              message: archiveState.failureMessage ?? l10n.errorGeneric,
                              variant: DSInlineBannerVariant.danger,
                            ),
                            SizedBox(height: spacing.s12),
                          ],
                          if (deleteState.status == AccountDeleteStatus.error) ...[
                            DSInlineBanner(
                              title: account.name,
                              message: deleteState.failureMessage ?? l10n.errorGeneric,
                              variant: DSInlineBannerVariant.danger,
                            ),
                            SizedBox(height: spacing.s12),
                          ],
                          if (account.archived) ...[
                            DSInlineBanner(
                              title: account.name,
                              message: l10n.accountDetailArchivedHint,
                              variant: DSInlineBannerVariant.info,
                            ),
                            SizedBox(height: spacing.s12),
                          ],
                          AccountDetailHeaderCard(
                            account: account,
                            baseCurrency: baseCurrency,
                            total: total,
                            pricedTotal: null,
                            ratesAsOf: rates?.asOf,
                          ),
                          SizedBox(height: spacing.s16),
                          AccountDetailActionsRow(
                            isEnabled: !isBusy,
                            isArchived: account.archived,
                            editLabel: l10n.accountsEdit,
                            archiveLabel: l10n.accountsArchive,
                            unarchiveLabel: l10n.accountsUnarchive,
                            deleteLabel: l10n.accountsDelete,
                            onEdit: () async {
                              await context.push<String>(
                                AppRoutes.accountEdit.replaceFirst(':accountId', account.id),
                              );
                            },
                            onArchiveToggle: () async {
                              final confirmed = await _confirmArchive(
                                context,
                                l10n,
                                archive: !account.archived,
                              );
                              if (!confirmed || !context.mounted) {
                                return;
                              }
                              await context.read<AccountArchiveCubit>().submit(
                                accountId: account.id,
                                archived: !account.archived,
                              );
                            },
                            onDelete: () async {
                              final confirmed = await _confirmDelete(context, l10n);
                              if (!confirmed || !context.mounted) {
                                return;
                              }
                              await context.read<AccountDeleteCubit>().submit(account.id);
                            },
                          ),
                          SizedBox(height: spacing.s24),
                          if (infoState.isSubaccountsLoading)
                            const AccountDetailPositionsLoadingSkeleton()
                          else
                            AccountDetailPositionsSection(
                              items: items,
                              baseCurrency: baseCurrency,
                              onAddSubaccount: () async {
                                await context.push<bool>(
                                  AppRoutes.accountAddSubaccount.replaceFirst(
                                    ':accountId',
                                    account.id,
                                  ),
                                );
                              },
                              onOpenSubaccount: (item) async {
                                final subaccount = infoState.subaccounts.firstWhere(
                                  (s) => s.id == item.subaccountId,
                                );
                                await context.push<bool>(
                                  AppRoutes.accountSubaccountDetail
                                      .replaceFirst(':accountId', account.id)
                                      .replaceFirst(':subaccountId', item.subaccountId),
                                  extra: SubaccountDetailExtra(
                                    initialTitle: item.name,
                                    account: account,
                                    subaccount: subaccount,
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: spacing.s24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Decimal? _baseUsdPrice(ProfileState profileState, RatesSnapshotEntity? snapshot) {
    final baseCurrency = profileState.profile?.baseCurrency ?? 'USD';
    if (baseCurrency == 'USD') {
      return Decimal.one;
    }
    final baseAssetId = profileState.profile?.baseAssetId;
    if (baseAssetId == null) {
      return null;
    }
    return snapshot?.usdPriceByAssetId[baseAssetId];
  }

  Decimal? _toBase(Decimal? totalUsd, String baseCurrency, Decimal? baseUsdPrice) {
    final usd = totalUsd ?? Decimal.zero;
    if (baseCurrency == 'USD') {
      return usd;
    }
    if (baseUsdPrice == null || baseUsdPrice == Decimal.zero) {
      return null;
    }
    return divideToDecimal(usd, baseUsdPrice);
  }

  Future<bool> _confirmArchive(
    BuildContext context,
    AppLocalizations l10n, {
    required bool archive,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => DSDialog(
        title: archive ? l10n.accountsArchiveConfirmTitle : l10n.accountsUnarchiveConfirmTitle,
        content: archive ? Text(l10n.accountsArchiveConfirmBody) : null,
        primaryLabel: archive ? l10n.accountsArchive : l10n.accountsUnarchive,
        secondaryLabel: l10n.cancel,
        onSecondary: () => Navigator.of(dialogContext).pop(false),
        onPrimary: () => Navigator.of(dialogContext).pop(true),
      ),
    );
    return result ?? false;
  }

  Future<bool> _confirmDelete(BuildContext context, AppLocalizations l10n) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => DSDialog(
        title: l10n.accountsDeleteConfirmTitle,
        content: Text(l10n.accountsDeleteConfirmBody),
        primaryLabel: l10n.accountsDelete,
        secondaryLabel: l10n.cancel,
        isDestructive: true,
        onSecondary: () => Navigator.of(dialogContext).pop(false),
        onPrimary: () => Navigator.of(dialogContext).pop(true),
      ),
    );
    return result ?? false;
  }
}
