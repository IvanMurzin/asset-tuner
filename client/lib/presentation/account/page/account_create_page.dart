import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_args.dart';
import 'package:asset_tuner/core/routing/route_extra_args.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/components/ds_snackbar.dart';
import 'package:asset_tuner/core_ui/components/ds_text_field.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/account/bloc/account_create_cubit.dart';
import 'package:asset_tuner/presentation/account/bloc/accounts_cubit.dart';
import 'package:asset_tuner/presentation/account/widget/account_type_card.dart';

class AccountCreatePage extends StatefulWidget {
  const AccountCreatePage({super.key});

  @override
  State<AccountCreatePage> createState() => _AccountCreatePageState();
}

class _AccountCreatePageState extends State<AccountCreatePage> {
  late final TextEditingController _nameController;
  AccountType _type = AccountType.bank;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<AccountCreateCubit>(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<AccountCreateCubit, AccountCreateState>(
            listenWhen: (prev, curr) => prev.status != curr.status,
            listener: (context, state) async {
              if (state.status == AccountCreateStatus.error &&
                  state.failureCode == 'limit_accounts_reached') {
                if (!context.mounted) return;
                await context.push(
                  AppRoutes.paywall,
                  extra: const PaywallArgs(reason: PaywallReason.accountsLimit),
                );
                return;
              }
              if (state.status != AccountCreateStatus.success || state.account == null) {
                return;
              }
              final account = state.account!;
              context.read<AccountsCubit>().create(account);

              if (!context.mounted) {
                return;
              }
              context.replace(
                AppRoutes.accountDetail.replaceFirst(':accountId', account.id),
                extra: AccountDetailExtra(
                  initialTitle: account.name,
                  initialAccountType: account.type,
                ),
              );
            },
          ),
          BlocListener<AccountCreateCubit, AccountCreateState>(
            listenWhen: (prev, curr) =>
                prev.failureMessage != curr.failureMessage && curr.failureMessage != null,
            listener: (context, state) {
              logger.e('Account create failed: ${state.failureCode}');
              showDSSnackBar(
                context,
                variant: DSSnackBarVariant.error,
                message: state.failureMessage ?? l10n.errorGeneric,
              );
            },
          ),
        ],
        child: BlocBuilder<AccountCreateCubit, AccountCreateState>(
          builder: (context, state) {
            final spacing = context.dsSpacing;
            final isSaving = state.status == AccountCreateStatus.loading;

            return Scaffold(
              appBar: DSAppBar(title: l10n.accountsNewTitle),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(spacing.s24, spacing.s24, spacing.s24, spacing.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DSTextField(
                        label: l10n.accountsNameLabel,
                        hintText: l10n.accountsNameHint,
                        controller: _nameController,
                        errorText: state.nameError == AccountCreateFieldError.required
                            ? l10n.accountsNameRequired
                            : null,
                        enabled: !isSaving,
                        onChanged: (_) => context.read<AccountCreateCubit>().clearNameError(),
                      ),
                      SizedBox(height: spacing.s24),
                      DSSectionTitle(title: l10n.accountsTypeLabel),
                      SizedBox(height: spacing.s12),
                      for (final type in const [
                        AccountType.bank,
                        AccountType.wallet,
                        AccountType.exchange,
                        AccountType.cash,
                        AccountType.other,
                      ]) ...[
                        AccountTypeCard(
                          type: type,
                          title: _typeTitle(l10n, type),
                          description: _typeDescription(l10n, type),
                          selected: _type == type,
                          onTap: isSaving ? null : () => setState(() => _type = type),
                        ),
                        SizedBox(height: spacing.s8),
                      ],
                      SizedBox(height: spacing.s16),
                      DSButton(
                        label: l10n.save,
                        fullWidth: true,
                        isLoading: isSaving,
                        onPressed: isSaving
                            ? null
                            : () async {
                                await context.read<AccountCreateCubit>().submit(
                                  name: _nameController.text,
                                  type: _type,
                                );
                              },
                      ),
                      SizedBox(height: spacing.s12),
                      DSButton(
                        label: l10n.cancel,
                        fullWidth: true,
                        variant: DSButtonVariant.secondary,
                        onPressed: isSaving ? null : () => context.pop(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _typeTitle(AppLocalizations l10n, AccountType type) {
    return switch (type) {
      AccountType.bank => l10n.accountsTypeBank,
      AccountType.wallet => l10n.accountsTypeCryptoWallet,
      AccountType.exchange => l10n.accountsTypeExchange,
      AccountType.cash => l10n.accountsTypeCash,
      AccountType.other => l10n.accountsTypeOther,
    };
  }

  String _typeDescription(AppLocalizations l10n, AccountType type) {
    return switch (type) {
      AccountType.bank => l10n.accountsTypeBankDescription,
      AccountType.wallet => l10n.accountsTypeCryptoWalletDescription,
      AccountType.exchange => l10n.accountsTypeExchangeDescription,
      AccountType.cash => l10n.accountsTypeCashDescription,
      AccountType.other => l10n.accountsTypeOtherDescription,
    };
  }
}
