import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core/routing/route_extra_args.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_loader.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/presentation/account/widget/account_type_card.dart';
import 'package:asset_tuner/core_ui/components/ds_text_field.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/account/bloc/account_form_cubit.dart';
import 'package:asset_tuner/presentation/overview/bloc/overview_cubit.dart';
import 'package:asset_tuner/presentation/paywall/entity/paywall_args.dart';
import 'package:asset_tuner/presentation/utils/supabase_error_message.dart';
import 'package:supabase_error_translator_flutter/supabase_error_translator_flutter.dart';

class AccountFormPage extends StatefulWidget {
  const AccountFormPage({super.key, this.accountId});

  final String? accountId;

  @override
  State<AccountFormPage> createState() => _AccountFormPageState();
}

class _AccountFormPageState extends State<AccountFormPage> {
  late final TextEditingController _nameController;
  bool _didSeedInitialName = false;

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
      create: (_) =>
          getIt<AccountFormCubit>()..load(accountId: widget.accountId),
      child: BlocConsumer<AccountFormCubit, AccountFormState>(
        listener: (context, state) async {
          final navigation = state.navigation;
          if (navigation == null) {
            return;
          }
          context.read<AccountFormCubit>().consumeNavigation();
          switch (navigation.destination) {
            case AccountFormDestination.signIn:
              context.go(AppRoutes.signIn);
              break;
            case AccountFormDestination.paywall:
              final upgraded = await context.push<bool>(
                AppRoutes.paywall,
                extra: const PaywallArgs(reason: PaywallReason.accountsLimit),
              );
              if (context.mounted && upgraded == true) {
                await context.read<AccountFormCubit>().load(
                  accountId: widget.accountId,
                );
              }
              break;
            case AccountFormDestination.backSaved:
              context.read<OverviewCubit>().refresh();
              if (widget.accountId == null) {
                final id = navigation.accountId;
                if (id != null && id.isNotEmpty) {
                  context.go(
                    AppRoutes.accountDetail.replaceFirst(':id', id),
                    extra: AccountDetailExtra(
                      initialTitle: state.name,
                      initialAccountType: state.type,
                    ),
                  );
                }
              } else {
                context.pop(navigation.accountId);
              }
              break;
          }
        },
        builder: (context, state) {
          final spacing = context.dsSpacing;

          if (state.status == AccountFormStatus.loading) {
            return const Scaffold(body: Center(child: DSLoader()));
          }

          if (state.status == AccountFormStatus.error) {
            return Scaffold(
              appBar: DSAppBar(title: l10n.accountsTitle),
              body: DSInlineError(
                title: l10n.splashErrorTitle,
                message: resolveFailureMessage(
                  context,
                  code: state.failureCode,
                  rawMessage: state.failureMessage,
                  service: ErrorService.database,
                ),
                actionLabel: l10n.splashRetry,
                onAction: () => context.read<AccountFormCubit>().load(
                  accountId: widget.accountId,
                ),
              ),
            );
          }

          final isEdit = widget.accountId != null;

          if (!_didSeedInitialName && state.initialName != null) {
            _nameController.text = state.initialName!;
            _didSeedInitialName = true;
          }

          return Scaffold(
            appBar: DSAppBar(
              title: isEdit ? l10n.accountsEditTitle : l10n.accountsNewTitle,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  spacing.s24,
                  spacing.s24,
                  spacing.s24,
                  spacing.s16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.failureCode != null) ...[
                      DSInlineBanner(
                        title: l10n.accountsTitle,
                        message: resolveFailureMessage(
                          context,
                          code: state.failureCode,
                          rawMessage: state.failureMessage,
                          service: ErrorService.database,
                        ),
                        variant: DSInlineBannerVariant.danger,
                      ),
                      SizedBox(height: spacing.s16),
                    ],
                    if (!isEdit) ...[
                      Text(
                        l10n.accountsNewBody,
                        style: context.dsTypography.body.copyWith(
                          color: context.dsColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: spacing.s16),
                    ],
                    DSTextField(
                      label: l10n.accountsNameLabel,
                      hintText: l10n.accountsNameHint,
                      controller: _nameController,
                      enabled: !state.isSaving,
                      errorText: _nameErrorText(l10n, state.nameError),
                      onChanged: context
                          .read<AccountFormCubit>()
                          .updateName,
                    ),
                    SizedBox(height: spacing.s24),
                    DSSectionTitle(title: l10n.accountsTypeLabel),
                    SizedBox(height: spacing.s12),
                    AccountTypeCard(
                      type: AccountType.bank,
                      title: l10n.accountsTypeBank,
                      description: l10n.accountsTypeBankDescription,
                      selected: state.type == AccountType.bank,
                      onTap: state.isSaving
                          ? null
                          : () => context
                                .read<AccountFormCubit>()
                                .selectType(AccountType.bank),
                    ),
                    SizedBox(height: spacing.s8),
                    AccountTypeCard(
                      type: AccountType.wallet,
                      title: l10n.accountsTypeCryptoWallet,
                      description:
                          l10n.accountsTypeCryptoWalletDescription,
                      selected: state.type == AccountType.wallet,
                      onTap: state.isSaving
                          ? null
                          : () => context
                                .read<AccountFormCubit>()
                                .selectType(AccountType.wallet),
                    ),
                    SizedBox(height: spacing.s8),
                    AccountTypeCard(
                      type: AccountType.exchange,
                      title: l10n.accountsTypeExchange,
                      description: l10n.accountsTypeExchangeDescription,
                      selected: state.type == AccountType.exchange,
                      onTap: state.isSaving
                          ? null
                          : () => context
                                .read<AccountFormCubit>()
                                .selectType(AccountType.exchange),
                    ),
                    SizedBox(height: spacing.s8),
                    AccountTypeCard(
                      type: AccountType.cash,
                      title: l10n.accountsTypeCash,
                      description: l10n.accountsTypeCashDescription,
                      selected: state.type == AccountType.cash,
                      onTap: state.isSaving
                          ? null
                          : () => context
                                .read<AccountFormCubit>()
                                .selectType(AccountType.cash),
                    ),
                    SizedBox(height: spacing.s8),
                    AccountTypeCard(
                      type: AccountType.other,
                      title: l10n.accountsTypeOther,
                      description: l10n.accountsTypeOtherDescription,
                      selected: state.type == AccountType.other,
                      onTap: state.isSaving
                          ? null
                          : () => context
                                .read<AccountFormCubit>()
                                .selectType(AccountType.other),
                    ),
                    SizedBox(height: spacing.s16),
                    DSButton(
                      label: l10n.save,
                      fullWidth: true,
                      isLoading: state.isSaving,
                      onPressed: state.isSaving
                          ? null
                          : context.read<AccountFormCubit>().save,
                    ),
                    SizedBox(height: spacing.s12),
                    DSButton(
                      label: l10n.cancel,
                      fullWidth: true,
                      variant: DSButtonVariant.secondary,
                      onPressed: state.isSaving ? null : () => context.pop(),
                    ),
                    SizedBox(height: spacing.s12),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String? _nameErrorText(AppLocalizations l10n, String? code) {
    return switch (code) {
      'required' => l10n.accountsNameRequired,
      _ => null,
    };
  }

}
