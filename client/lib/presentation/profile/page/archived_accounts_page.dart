import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core/routing/route_extra_args.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_empty_state.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/account/bloc/accounts_cubit.dart';
import 'package:asset_tuner/presentation/overview/widget/overview_account_card.dart';
import 'package:asset_tuner/presentation/overview/widget/overview_account_item.dart';

class ArchivedAccountsPage extends StatelessWidget {
  const ArchivedAccountsPage({super.key});

  static const double _archivedCardOpacity = 0.64;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AccountsCubit, AccountsState>(
      builder: (context, state) {
        final archived = state.accounts.where((item) => item.archived).toList();
        final spacing = context.dsSpacing;

        if (state.status == AccountsStatus.loading && state.accounts.isEmpty) {
          return Scaffold(
            appBar: DSAppBar(title: l10n.settingsArchivedAccounts),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == AccountsStatus.error && state.accounts.isEmpty) {
          return Scaffold(
            appBar: DSAppBar(title: l10n.settingsArchivedAccounts),
            body: DSInlineError(
              title: l10n.splashErrorTitle,
              message: state.failureMessage ?? l10n.errorGeneric,
              actionLabel: l10n.splashRetry,
              onAction: () => context.read<AccountsCubit>().refresh(),
            ),
          );
        }

        if (archived.isEmpty) {
          return Scaffold(
            appBar: DSAppBar(title: l10n.settingsArchivedAccounts),
            body: Padding(
              padding: EdgeInsets.all(spacing.s24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ArchivedAccountsCaption(text: l10n.archivedAccountsGlobalTotalHint),
                  SizedBox(height: spacing.s16),
                  Expanded(
                    child: Center(
                      child: DSEmptyState(
                        title: l10n.archivedAccountsEmptyTitle,
                        message: l10n.archivedAccountsEmptyBody,
                        icon: Icons.archive_outlined,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: DSAppBar(title: l10n.settingsArchivedAccounts),
          body: ListView.builder(
            padding: EdgeInsets.all(spacing.s24),
            itemCount: archived.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: EdgeInsets.only(bottom: spacing.s16),
                  child: _ArchivedAccountsCaption(text: l10n.archivedAccountsGlobalTotalHint),
                );
              }

              final account = archived[index - 1];
              final item = OverviewAccountItem(
                accountId: account.id,
                accountName: account.name,
                accountType: account.type,
                total: account.totals?.totalInBase ?? account.totals?.totalUsd ?? Decimal.zero,
                subaccountsCount: account.subaccountsCount ?? 0,
                hasUnpricedHoldings: false,
              );
              return Padding(
                padding: EdgeInsets.only(bottom: index < archived.length ? spacing.s12 : 0),
                child: Opacity(
                  opacity: _archivedCardOpacity,
                  child: OverviewAccountCard(
                    item: item,
                    baseCurrency: account.totals?.baseAssetCode ?? 'USD',
                    onTap: () => _openAccountDetail(context, account),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _openAccountDetail(BuildContext context, AccountEntity account) {
    context.go(
      AppRoutes.accountDetail.replaceFirst(':accountId', account.id),
      extra: AccountDetailExtra(initialTitle: account.name, initialAccountType: account.type),
    );
  }
}

class _ArchivedAccountsCaption extends StatelessWidget {
  const _ArchivedAccountsCaption({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final typography = context.dsTypography;
    return Text(text, style: typography.caption.copyWith(color: colors.textSecondary));
  }
}
