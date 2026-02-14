import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core/routing/route_extra_args.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_dialog.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/account/bloc/account_detail_cubit.dart';
import 'package:asset_tuner/presentation/account/widget/account_detail_actions_row.dart';
import 'package:asset_tuner/presentation/overview/bloc/overview_cubit.dart';
import 'package:asset_tuner/presentation/account/widget/account_detail_header_card.dart';
import 'package:asset_tuner/presentation/account/widget/account_detail_loading_skeleton.dart';
import 'package:asset_tuner/presentation/account/widget/account_detail_positions_section.dart';
import 'package:asset_tuner/presentation/utils/supabase_error_message.dart';
import 'package:supabase_error_translator_flutter/supabase_error_translator_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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

    return BlocProvider(
      create: (_) => getIt<AccountDetailCubit>()..load(accountId),
      child: BlocConsumer<AccountDetailCubit, AccountDetailState>(
        listenWhen: (prev, curr) =>
            curr.navigation != null ||
            (prev.account != null && curr.account != null && prev.account != curr.account),
        listener: (context, state) {
          final navigation = state.navigation;
          if (navigation != null) {
            context.read<AccountDetailCubit>().consumeNavigation();
            switch (navigation.destination) {
              case AccountDetailDestination.signIn:
                context.go(AppRoutes.signIn);
                break;
              case AccountDetailDestination.backDeleted:
                context.read<OverviewCubit>().refresh();
                context.pop(true);
                break;
            }
            return;
          }
          if (state.account != null) {
            context.read<OverviewCubit>().refresh();
          }
        },
        builder: (context, state) {
          final spacing = context.dsSpacing;

          if (state.status == AccountDetailStatus.loading) {
            return Scaffold(
              appBar: DSAppBar(title: initialTitle ?? l10n.accountsTitle),
              body: SafeArea(child: AccountDetailLoadingSkeleton(accountType: initialAccountType)),
            );
          }

          if (state.status == AccountDetailStatus.error && state.account == null) {
            return Scaffold(
              appBar: DSAppBar(title: initialTitle ?? l10n.accountsTitle),
              body: DSInlineError(
                title: l10n.splashErrorTitle,
                message: resolveFailureMessage(
                context,
                code: state.failureCode,
                rawMessage: state.failureMessage,
                service: ErrorService.database,
              ),
                actionLabel: l10n.splashRetry,
                onAction: () => context.read<AccountDetailCubit>().load(accountId),
              ),
            );
          }

          final account = state.account!;
          final baseCurrency = state.baseCurrency ?? 'USD';
          final actionsEnabled = !state.isAccountActionBusy;

          return Scaffold(
            appBar: DSAppBar(title: account.name),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () => context.read<AccountDetailCubit>().refresh(),
                child: ListView(
                  children: [
                    SizedBox(height: spacing.s24),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing.s24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (state.bannerFailureCode != null) ...[
                            DSInlineBanner(
                              title: account.name,
                              message: state.bannerFailureCode != null
                              ? resolveFailureMessage(
                                  context,
                                  code: state.bannerFailureCode,
                                  rawMessage: state.bannerFailureMessage,
                                  service: ErrorService.database,
                                )
                              : l10n.errorGeneric,
                              variant: DSInlineBannerVariant.danger,
                            ),
                            SizedBox(height: spacing.s12),
                          ],
                          if (state.isAccountArchived) ...[
                            DSInlineBanner(
                              title: account.name,
                              message: l10n.accountDetailArchivedHint,
                              variant: DSInlineBannerVariant.info,
                            ),
                            SizedBox(height: spacing.s12),
                          ],
                          if (state.hasUnpricedHoldings) ...[
                            DSInlineBanner(
                              title: l10n.accountDetailMissingRatesTitle,
                              message: l10n.accountDetailMissingRatesBody,
                              variant: DSInlineBannerVariant.warning,
                            ),
                            SizedBox(height: spacing.s12),
                          ],
                          AccountDetailHeaderCard(
                            account: account,
                            baseCurrency: baseCurrency,
                            total: state.total,
                            pricedTotal: state.pricedTotal,
                            ratesAsOf: state.ratesAsOf,
                          ),
                          SizedBox(height: spacing.s16),
                          AccountDetailActionsRow(
                            isEnabled: actionsEnabled,
                            isArchived: state.isAccountArchived,
                            editLabel: l10n.accountsEdit,
                            archiveLabel: l10n.accountsArchive,
                            unarchiveLabel: l10n.accountsUnarchive,
                            deleteLabel: l10n.accountsDelete,
                            onEdit: () async {
                              final saved = await context.push<String>(
                                AppRoutes.accountEdit.replaceFirst(':id', account.id),
                              );
                              if (context.mounted && saved != null) {
                                await context.read<AccountDetailCubit>().refresh();
                              }
                            },
                            onArchiveToggle: () async {
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
                              if (context.mounted) {
                                context.read<OverviewCubit>().refresh();
                              }
                            },
                            onDelete: () async {
                              final confirmed = await _confirmDelete(context, l10n);
                              if (!confirmed || !context.mounted) {
                                return;
                              }
                              await context.read<AccountDetailCubit>().deleteAccount(account.id);
                            },
                          ),
                          SizedBox(height: spacing.s24),
                          if (state.status == AccountDetailStatus.error)
                            DSInlineError(
                              title: l10n.splashErrorTitle,
                              message: resolveFailureMessage(
                context,
                code: state.failureCode,
                rawMessage: state.failureMessage,
                service: ErrorService.database,
              ),
                              actionLabel: l10n.splashRetry,
                              onAction: () => context.read<AccountDetailCubit>().load(accountId),
                            )
                          else
                            AccountDetailPositionsSection(
                              items: state.items,
                              baseCurrency: baseCurrency,
                              onAddAsset: () async {
                                final added = await context.push<bool>(
                                  AppRoutes.accountAddAsset.replaceFirst(':id', account.id),
                                );
                                if (context.mounted && added == true) {
                                  await context.read<AccountDetailCubit>().refresh();
                                }
                              },
                              onOpenSubaccount: (item) async {
                                final changed = await context.push<bool>(
                                  AppRoutes.subaccountDetail.replaceFirst(':id', item.subaccountId),
                                  extra: SubaccountDetailExtra(initialTitle: item.name),
                                );
                                if (context.mounted && changed == true) {
                                  await context.read<AccountDetailCubit>().refresh();
                                }
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
