import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_loader.dart';
import 'package:asset_tuner/core_ui/components/ds_radio_row.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/components/ds_text_field.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/account/bloc/account_form_cubit.dart';
import 'package:asset_tuner/presentation/paywall/entity/paywall_args.dart';

class AccountFormPage extends StatefulWidget {
  const AccountFormPage({super.key, this.accountId});

  final String? accountId;

  @override
  State<AccountFormPage> createState() => _AccountFormPageState();
}

class _AccountFormPageState extends State<AccountFormPage> {
  late final TextEditingController _nameController;

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
              context.pop(navigation.accountId);
              break;
          }
        },
        builder: (context, state) {
          final spacing = context.dsSpacing;

          if (state.status == AccountFormStatus.loading) {
            return const Scaffold(body: Center(child: DSLoader()));
          }

          if (state.status == AccountFormStatus.error && state.userId == null) {
            return Scaffold(
              appBar: DSAppBar(title: l10n.accountsTitle),
              body: DSInlineError(
                title: l10n.splashErrorTitle,
                message: _failureMessage(l10n, state.failureCode),
                actionLabel: l10n.splashRetry,
                onAction: () => context.read<AccountFormCubit>().load(
                  accountId: widget.accountId,
                ),
              ),
            );
          }

          final isEdit = widget.accountId != null;

          if (state.initialName != null && _nameController.text.isEmpty) {
            _nameController.text = state.initialName!;
          }

          return Scaffold(
            appBar: DSAppBar(
              title: isEdit ? l10n.accountsEditTitle : l10n.accountsNewTitle,
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
                    if (state.failureCode != null) ...[
                      DSInlineBanner(
                        title: l10n.accountsTitle,
                        message: _failureMessage(l10n, state.failureCode),
                        variant: DSInlineBannerVariant.danger,
                      ),
                      SizedBox(height: spacing.s16),
                    ],
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                            DSCard(
                              padding: EdgeInsets.all(spacing.s8),
                              child: Column(
                                children: [
                                  DSRadioRow(
                                    title: l10n.accountsTypeBank,
                                    selected: state.type == AccountType.bank,
                                    onTap: state.isSaving
                                        ? null
                                        : () => context
                                              .read<AccountFormCubit>()
                                              .selectType(AccountType.bank),
                                  ),
                                  DSRadioRow(
                                    title: l10n.accountsTypeCryptoWallet,
                                    selected:
                                        state.type == AccountType.cryptoWallet,
                                    onTap: state.isSaving
                                        ? null
                                        : () => context
                                              .read<AccountFormCubit>()
                                              .selectType(
                                                AccountType.cryptoWallet,
                                              ),
                                  ),
                                  DSRadioRow(
                                    title: l10n.accountsTypeCash,
                                    selected: state.type == AccountType.cash,
                                    onTap: state.isSaving
                                        ? null
                                        : () => context
                                              .read<AccountFormCubit>()
                                              .selectType(AccountType.cash),
                                  ),
                                  DSRadioRow(
                                    title: l10n.accountsTypeOther,
                                    selected: state.type == AccountType.other,
                                    onTap: state.isSaving
                                        ? null
                                        : () => context
                                              .read<AccountFormCubit>()
                                              .selectType(AccountType.other),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
}
