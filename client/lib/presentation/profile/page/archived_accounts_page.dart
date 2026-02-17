import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core/routing/route_extra_args.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_empty_state.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/overview/bloc/overview_cubit.dart';
import 'package:asset_tuner/presentation/overview/widget/overview_account_card.dart';
import 'package:asset_tuner/presentation/profile/bloc/archived_accounts_cubit.dart';

class ArchivedAccountsPage extends StatelessWidget {
  const ArchivedAccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<ArchivedAccountsCubit>()..load(),
      child: BlocBuilder<ArchivedAccountsCubit, ArchivedAccountsState>(
        builder: (context, state) {
          if (state.status == ArchivedAccountsStatus.loading) {
            return Scaffold(
              appBar: DSAppBar(title: l10n.settingsArchivedAccounts),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state.status == ArchivedAccountsStatus.error) {
            return Scaffold(
              appBar: DSAppBar(title: l10n.settingsArchivedAccounts),
              body: DSInlineError(
                title: l10n.splashErrorTitle,
                message: state.failureMessage ?? l10n.errorGeneric,
                actionLabel: l10n.splashRetry,
                onAction: () => context.read<ArchivedAccountsCubit>().load(),
              ),
            );
          }

          if (state.accounts.isEmpty) {
            return Scaffold(
              appBar: DSAppBar(title: l10n.settingsArchivedAccounts),
              body: Center(
                child: DSEmptyState(
                  title: l10n.archivedAccountsEmptyTitle,
                  message: l10n.archivedAccountsEmptyBody,
                  icon: Icons.archive_outlined,
                ),
              ),
            );
          }

          final spacing = context.dsSpacing;
          return Scaffold(
            appBar: DSAppBar(title: l10n.settingsArchivedAccounts),
            body: ListView.builder(
              padding: EdgeInsets.all(spacing.s24),
              itemCount: state.accounts.length,
              itemBuilder: (context, index) {
                final account = state.accounts[index];
                final item = OverviewAccountItem(
                  accountId: account.id,
                  accountName: account.name,
                  accountType: account.type,
                  total: Decimal.zero,
                  subaccountsCount: 0,
                  hasUnpricedHoldings: false,
                );
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < state.accounts.length - 1 ? spacing.s12 : 0,
                  ),
                  child: OverviewAccountCard(
                    item: item,
                    baseCurrency: 'USD',
                    onTap: () => _openAccountDetail(context, account),
                    showBalance: false,
                    subtitleOverride: l10n.accountsArchivedSection,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _openAccountDetail(BuildContext context, AccountEntity account) {
    context.go(
      AppRoutes.accountDetail.replaceFirst(':id', account.id),
      extra: AccountDetailExtra(initialTitle: account.name, initialAccountType: account.type),
    );
  }
}
