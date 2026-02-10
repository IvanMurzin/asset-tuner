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
import 'package:asset_tuner/core_ui/components/ds_overflow_menu.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/account/bloc/account_detail_cubit.dart';

class AccountDetailPage extends StatelessWidget {
  const AccountDetailPage({super.key, required this.accountId});

  final String accountId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<AccountDetailCubit>()..load(accountId),
      child: BlocConsumer<AccountDetailCubit, AccountDetailState>(
        listener: (context, state) {
          final navigation = state.navigation;
          if (navigation == null) {
            return;
          }
          context.read<AccountDetailCubit>().consumeNavigation();
          switch (navigation.destination) {
            case AccountDetailDestination.signIn:
              context.go(AppRoutes.signIn);
              break;
            case AccountDetailDestination.backDeleted:
              context.pop(true);
              break;
          }
        },
        builder: (context, state) {
          final spacing = context.dsSpacing;

          if (state.status == AccountDetailStatus.loading) {
            return const Scaffold(body: Center(child: DSLoader()));
          }

          if (state.status == AccountDetailStatus.error &&
              state.account == null) {
            return Scaffold(
              appBar: DSAppBar(title: l10n.accountsTitle),
              body: DSInlineError(
                title: l10n.splashErrorTitle,
                message: _failureMessage(l10n, state.failureCode),
                actionLabel: l10n.splashRetry,
                onAction: () =>
                    context.read<AccountDetailCubit>().load(accountId),
              ),
            );
          }

          final account = state.account!;
          final actionsEnabled = !state.isAccountActionBusy;

          return Scaffold(
            appBar: DSAppBar(
              title: account.name,
              actions: [
                DSOverflowMenu(
                  enabled: actionsEnabled,
                  items: [
                    DSOverflowMenuItem(
                      label: l10n.accountsEdit,
                      icon: Icons.edit_outlined,
                      onTap: () async {
                        await context.push<String>(
                          AppRoutes.accountEdit.replaceFirst(':id', account.id),
                        );
                        if (context.mounted) {
                          await context.read<AccountDetailCubit>().load(
                            accountId,
                          );
                        }
                      },
                    ),
                    DSOverflowMenuItem(
                      label: state.isAccountArchived
                          ? l10n.accountsUnarchive
                          : l10n.accountsArchive,
                      icon: state.isAccountArchived
                          ? Icons.unarchive_outlined
                          : Icons.archive_outlined,
                      onTap: () async {
                        final confirmed = await _confirmArchive(
                          context,
                          l10n,
                          archive: !state.isAccountArchived,
                        );
                        if (!confirmed || !context.mounted) {
                          return;
                        }
                        await context.read<AccountDetailCubit>().setArchived(
                          accountId: account.id,
                          archived: !state.isAccountArchived,
                        );
                      },
                    ),
                    DSOverflowMenuItem(
                      label: l10n.accountsDelete,
                      icon: Icons.delete_outline,
                      isDestructive: true,
                      onTap: () async {
                        final confirmed = await _confirmDelete(context, l10n);
                        if (!confirmed || !context.mounted) {
                          return;
                        }
                        await context.read<AccountDetailCubit>().deleteAccount(
                          account.id,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
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
                        title: account.name,
                        message: _failureMessage(l10n, state.bannerFailureCode),
                        variant: DSInlineBannerVariant.danger,
                      ),
                      SizedBox(height: spacing.s16),
                    ],
                    if (state.isAccountArchived) ...[
                      DSInlineBanner(
                        title: account.name,
                        message: l10n.accountDetailArchivedHint,
                        variant: DSInlineBannerVariant.info,
                      ),
                      SizedBox(height: spacing.s16),
                    ],
                    Expanded(
                      child: switch (state.status) {
                        AccountDetailStatus.error => DSInlineError(
                          title: l10n.splashErrorTitle,
                          message: _failureMessage(l10n, state.failureCode),
                          actionLabel: l10n.splashRetry,
                          onAction: () => context
                              .read<AccountDetailCubit>()
                              .load(accountId),
                        ),
                        _ => _PositionsContent(
                          accountId: account.id,
                          items: state.items,
                          isBusy: (assetId) =>
                              state.busyAssetIds.contains(assetId),
                          onAddAsset: () async {
                            await context.push<String>(
                              AppRoutes.accountAddAsset.replaceFirst(
                                ':id',
                                account.id,
                              ),
                            );
                            if (context.mounted) {
                              await context.read<AccountDetailCubit>().load(
                                accountId,
                              );
                            }
                          },
                          onRemove: (item) async {
                            final confirmed = await _confirmRemove(
                              context,
                              l10n,
                            );
                            if (!confirmed || !context.mounted) {
                              return;
                            }
                            await context
                                .read<AccountDetailCubit>()
                                .removeAsset(
                                  accountId: account.id,
                                  assetId: item.assetId,
                                );
                          },
                        ),
                      },
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

  Future<bool> _confirmRemove(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => DSDialog(
        title: l10n.assetRemoveConfirmTitle,
        content: Text(l10n.assetRemoveConfirmBody),
        primaryLabel: l10n.assetRemove,
        secondaryLabel: l10n.cancel,
        isDestructive: true,
        onSecondary: () => Navigator.of(context).pop(false),
        onPrimary: () => Navigator.of(context).pop(true),
      ),
    );
    return result ?? false;
  }

  Future<bool> _confirmArchive(
    BuildContext context,
    AppLocalizations l10n, {
    required bool archive,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => DSDialog(
        title: archive
            ? l10n.accountsArchiveConfirmTitle
            : l10n.accountsUnarchiveConfirmTitle,
        content: archive ? Text(l10n.accountsArchiveConfirmBody) : null,
        primaryLabel: archive ? l10n.accountsArchive : l10n.accountsUnarchive,
        secondaryLabel: l10n.cancel,
        onSecondary: () => Navigator.of(context).pop(false),
        onPrimary: () => Navigator.of(context).pop(true),
      ),
    );
    return result ?? false;
  }

  Future<bool> _confirmDelete(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => DSDialog(
        title: l10n.accountsDeleteConfirmTitle,
        content: Text(l10n.accountsDeleteConfirmBody),
        primaryLabel: l10n.accountsDelete,
        secondaryLabel: l10n.cancel,
        isDestructive: true,
        onSecondary: () => Navigator.of(context).pop(false),
        onPrimary: () => Navigator.of(context).pop(true),
      ),
    );
    return result ?? false;
  }
}

class _PositionsContent extends StatelessWidget {
  const _PositionsContent({
    required this.accountId,
    required this.items,
    required this.isBusy,
    required this.onAddAsset,
    required this.onRemove,
  });

  final String accountId;
  final List<AccountAssetViewItem> items;
  final bool Function(String assetId) isBusy;
  final VoidCallback onAddAsset;
  final Future<void> Function(AccountAssetViewItem item) onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;

    if (items.isEmpty) {
      return Center(
        child: DSEmptyState(
          title: l10n.accountDetailEmptyTitle,
          message: l10n.accountDetailEmptyBody,
          actionLabel: l10n.assetAddCta,
          onAction: onAddAsset,
          icon: Icons.add_circle_outline,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSSectionTitle(title: l10n.accountDetailAssetsTitle),
        SizedBox(height: spacing.s12),
        Expanded(
          child: DSCard(
            padding: EdgeInsets.zero,
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                final busy = isBusy(item.assetId);
                return DSListRow(
                  title: item.assetCode,
                  subtitle:
                      '${item.assetName} · ${_kindLabel(l10n, item.assetKind)}',
                  trailing: DSOverflowMenu(
                    enabled: !busy,
                    items: [
                      DSOverflowMenuItem(
                        label: l10n.assetRemove,
                        icon: Icons.remove_circle_outline,
                        isDestructive: true,
                        onTap: () => onRemove(item),
                      ),
                    ],
                  ),
                  onTap: () => context.push(
                    AppRoutes.assetPositionDetail
                        .replaceFirst(':accountId', accountId)
                        .replaceFirst(':assetId', item.assetId),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: spacing.s16),
        DSButton(
          label: l10n.assetAddCta,
          fullWidth: true,
          onPressed: onAddAsset,
        ),
      ],
    );
  }

  String _kindLabel(AppLocalizations l10n, AssetKind kind) {
    return switch (kind) {
      AssetKind.fiat => l10n.assetKindFiat,
      AssetKind.crypto => l10n.assetKindCrypto,
    };
  }
}
