import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/components/ds_text_field.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/account/bloc/account_update_cubit.dart';
import 'package:asset_tuner/presentation/account/bloc/accounts_cubit.dart';
import 'package:asset_tuner/presentation/account/widget/account_type_card.dart';

class AccountUpdatePage extends StatefulWidget {
  const AccountUpdatePage({super.key, required this.accountId});

  final String accountId;

  @override
  State<AccountUpdatePage> createState() => _AccountUpdatePageState();
}

class _AccountUpdatePageState extends State<AccountUpdatePage> {
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
    final existing = context.read<AccountsCubit>().findById(widget.accountId);

    if (existing != null && _nameController.text.isEmpty) {
      _nameController.text = existing.name;
      _type = existing.type;
    }

    if (existing == null) {
      return Scaffold(
        appBar: DSAppBar(title: l10n.accountsEditTitle),
        body: DSInlineError(
          title: l10n.splashErrorTitle,
          message: l10n.errorGeneric,
          actionLabel: l10n.cancel,
          onAction: () => context.pop(),
        ),
      );
    }

    return BlocProvider(
      create: (_) => getIt<AccountUpdateCubit>(),
      child: BlocListener<AccountUpdateCubit, AccountUpdateState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) async {
          if (state.status != AccountUpdateStatus.success || state.account == null) {
            return;
          }

          final account = state.account!;
          context.read<AccountsCubit>().update(account);

          if (context.mounted) {
            context.pop(account.id);
          }
        },
        child: BlocBuilder<AccountUpdateCubit, AccountUpdateState>(
          builder: (context, state) {
            final spacing = context.dsSpacing;
            final isSaving = state.status == AccountUpdateStatus.loading;

            return Scaffold(
              appBar: DSAppBar(title: l10n.accountsEditTitle),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(spacing.s24, spacing.s24, spacing.s24, spacing.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.status == AccountUpdateStatus.error) ...[
                        DSInlineBanner(
                          title: l10n.accountsTitle,
                          message: state.failureMessage ?? l10n.errorGeneric,
                          variant: DSInlineBannerVariant.danger,
                        ),
                        SizedBox(height: spacing.s16),
                      ],
                      DSTextField(
                        label: l10n.accountsNameLabel,
                        hintText: l10n.accountsNameHint,
                        controller: _nameController,
                        enabled: !isSaving,
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
                                await context.read<AccountUpdateCubit>().submit(
                                  accountId: widget.accountId,
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
