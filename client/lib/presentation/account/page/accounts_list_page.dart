import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_dialog.dart';
import 'package:asset_tuner/core_ui/components/ds_empty_state.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_list_row.dart';
import 'package:asset_tuner/core_ui/components/ds_overflow_menu.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/components/ds_skeleton.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/account/bloc/accounts_cubit.dart';

class AccountsListPage extends StatelessWidget {
  const AccountsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<AccountsCubit>()..load(),
      child: BlocConsumer<AccountsCubit, AccountsState>(
        listener: (context, state) {
          final navigation = state.navigation;
          if (navigation == null) {
            return;
          }
          context.read<AccountsCubit>().consumeNavigation();
          switch (navigation.destination) {
            case AccountsDestination.signIn:
              context.go(AppRoutes.signIn);
          }
        },
        builder: (context, state) {
          final spacing = context.dsSpacing;

          return Scaffold(
            appBar: DSAppBar(
              title: l10n.accountsTitle,
              actions: [
                IconButton(
                  tooltip: l10n.accountsAddAccount,
                  onPressed: state.status == AccountsStatus.loading
                      ? null
                      : () async {
                          await context.push<String>(AppRoutes.accountNew);
                          if (context.mounted) {
                            await context.read<AccountsCubit>().load();
                          }
                        },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(spacing.s24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.actionFailureCode != null) ...[
                      DSInlineBanner(
                        title: l10n.accountsTitle,
                        message: _failureMessage(l10n, state.actionFailureCode),
                        variant: DSInlineBannerVariant.danger,
                      ),
                      SizedBox(height: spacing.s16),
                    ],
                    Expanded(
                      child: switch (state.status) {
                        AccountsStatus.loading => _LoadingView(),
                        AccountsStatus.error
                            when state.activeAccounts.isEmpty &&
                                state.archivedAccounts.isEmpty =>
                          DSInlineError(
                            title: l10n.splashErrorTitle,
                            message: _failureMessage(l10n, state.failureCode),
                            actionLabel: l10n.splashRetry,
                            onAction: () =>
                                context.read<AccountsCubit>().load(),
                          ),
                        _ => _AccountsContent(
                          active: state.activeAccounts,
                          archived: state.archivedAccounts,
                          isBusy: (id) => state.busyAccountIds.contains(id),
                          onOpen: (account) async {
                            await context.push<String>(
                              AppRoutes.accountDetail.replaceFirst(
                                ':id',
                                account.id,
                              ),
                            );
                            if (context.mounted) {
                              await context.read<AccountsCubit>().load();
                            }
                          },
                          onEdit: (account) async {
                            await context.push<String>(
                              AppRoutes.accountEdit.replaceFirst(
                                ':id',
                                account.id,
                              ),
                            );
                            if (context.mounted) {
                              await context.read<AccountsCubit>().load();
                            }
                          },
                          onArchive: (account) async {
                            final confirmed = await _confirmArchive(
                              context,
                              l10n,
                              archive: !account.archived,
                            );
                            if (!confirmed || !context.mounted) {
                              return;
                            }
                            await context.read<AccountsCubit>().setArchived(
                              accountId: account.id,
                              archived: !account.archived,
                            );
                          },
                          onDelete: (account) async {
                            final confirmed = await _confirmDelete(
                              context,
                              l10n,
                            );
                            if (!confirmed || !context.mounted) {
                              return;
                            }
                            await context.read<AccountsCubit>().deleteAccount(
                              account.id,
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

  Future<bool> _confirmArchive(
    BuildContext context,
    AppLocalizations l10n, {
    required bool archive,
  }) async {
    final spacing = context.dsSpacing;
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => DSDialog(
        title: archive
            ? l10n.accountsArchiveConfirmTitle
            : l10n.accountsUnarchiveConfirmTitle,
        content: archive
            ? Text(l10n.accountsArchiveConfirmBody)
            : const SizedBox.shrink(),
        primaryLabel: archive ? l10n.accountsArchive : l10n.accountsUnarchive,
        secondaryLabel: l10n.cancel,
        onSecondary: () => Navigator.of(context).pop(false),
        onPrimary: () => Navigator.of(context).pop(true),
      ),
    );
    await Future<void>.delayed(Duration(milliseconds: spacing.s4.toInt()));
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

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;

    return DSCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < 6; i++) ...[
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.s16,
                vertical: spacing.s12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DSSkeleton(height: 18),
                  SizedBox(height: spacing.s8),
                  DSSkeleton(height: 14, width: 120),
                ],
              ),
            ),
            if (i != 5) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _AccountsContent extends StatelessWidget {
  const _AccountsContent({
    required this.active,
    required this.archived,
    required this.isBusy,
    required this.onOpen,
    required this.onEdit,
    required this.onArchive,
    required this.onDelete,
  });

  final List<AccountEntity> active;
  final List<AccountEntity> archived;
  final bool Function(String id) isBusy;
  final Future<void> Function(AccountEntity account) onOpen;
  final Future<void> Function(AccountEntity account) onEdit;
  final Future<void> Function(AccountEntity account) onArchive;
  final Future<void> Function(AccountEntity account) onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;

    if (active.isEmpty && archived.isEmpty) {
      return Center(
        child: DSEmptyState(
          title: l10n.accountsEmptyTitle,
          message: l10n.accountsEmptyBody,
          actionLabel: l10n.accountsCreateAccount,
          onAction: () => context.push(AppRoutes.accountNew),
          icon: Icons.account_balance_wallet_outlined,
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DSSectionTitle(title: l10n.accountsActiveSection),
          SizedBox(height: spacing.s12),
          DSCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < active.length; i++)
                  _AccountRow(
                    account: active[i],
                    showDivider: i != active.length - 1,
                    busy: isBusy(active[i].id),
                    onOpen: () => onOpen(active[i]),
                    onEdit: () => onEdit(active[i]),
                    onArchive: () => onArchive(active[i]),
                    onDelete: () => onDelete(active[i]),
                  ),
              ],
            ),
          ),
          if (archived.isNotEmpty) ...[
            SizedBox(height: spacing.s24),
            DSSectionTitle(title: l10n.accountsArchivedSection),
            SizedBox(height: spacing.s12),
            DSCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < archived.length; i++)
                    _AccountRow(
                      account: archived[i],
                      showDivider: i != archived.length - 1,
                      busy: isBusy(archived[i].id),
                      onOpen: () => onOpen(archived[i]),
                      onEdit: () => onEdit(archived[i]),
                      onArchive: () => onArchive(archived[i]),
                      onDelete: () => onDelete(archived[i]),
                    ),
                ],
              ),
            ),
          ],
          if (active.isEmpty && archived.isNotEmpty) ...[
            SizedBox(height: spacing.s24),
            Text(l10n.accountsOnlyArchivedHint, style: typography.caption),
          ],
        ],
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.account,
    required this.busy,
    required this.onOpen,
    required this.onEdit,
    required this.onArchive,
    required this.onDelete,
    required this.showDivider,
  });

  final AccountEntity account;
  final bool busy;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback onDelete;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DSListRow(
      title: account.name,
      subtitle: _typeLabel(l10n, account.type),
      trailing: DSOverflowMenu(
        enabled: !busy,
        items: [
          DSOverflowMenuItem(
            label: l10n.accountsEdit,
            icon: Icons.edit_outlined,
            onTap: onEdit,
          ),
          DSOverflowMenuItem(
            label: account.archived
                ? l10n.accountsUnarchive
                : l10n.accountsArchive,
            icon: account.archived
                ? Icons.unarchive_outlined
                : Icons.archive_outlined,
            onTap: onArchive,
          ),
          DSOverflowMenuItem(
            label: l10n.accountsDelete,
            icon: Icons.delete_outline,
            isDestructive: true,
            onTap: onDelete,
          ),
        ],
      ),
      showDivider: showDivider,
      onTap: onOpen,
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
