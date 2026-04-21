import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core/routing/route_extra_args.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_balance_input.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_snackbar.dart';
import 'package:asset_tuner/core_ui/components/ds_text_field.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/account/bloc/account_info_cubit.dart';
import 'package:asset_tuner/presentation/account/bloc/accounts_cubit.dart';
import 'package:asset_tuner/presentation/account/page/add_subaccount_context.dart';
import 'package:asset_tuner/presentation/analytics/bloc/analytics_cubit.dart';
import 'package:asset_tuner/presentation/asset/bloc/assets_cubit.dart';
import 'package:asset_tuner/presentation/asset/widget/asset_currency_badge.dart';
import 'package:asset_tuner/presentation/balance/bloc/subaccount_create_cubit.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_args.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AddSubaccountPage extends StatefulWidget {
  const AddSubaccountPage({super.key, required this.accountId});

  final String accountId;

  @override
  State<AddSubaccountPage> createState() => _AddSubaccountPageState();
}

class _AddSubaccountPageState extends State<AddSubaccountPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;

  AssetEntity? _selectedAsset;
  String? _currencyErrorText;
  String? _balanceErrorText;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _balanceController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _applyDefaultCurrencySelection(context);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accountType = context.select<AccountInfoCubit, AccountType?>(
      (cubit) => cubit.state.account?.type,
    );
    final formContext = AddSubaccountContext.fromAccountType(accountType);

    return BlocProvider(
      create: (_) => getIt<SubaccountCreateCubit>(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<AccountInfoCubit, AccountInfoState>(
            listenWhen: (prev, curr) => prev.account?.type != curr.account?.type,
            listener: (context, _) => _applyDefaultCurrencySelection(context),
          ),
          BlocListener<AssetsCubit, AssetsState>(
            listenWhen: (prev, curr) => prev.status != curr.status || prev.assets != curr.assets,
            listener: (context, _) => _applyDefaultCurrencySelection(context),
          ),
          BlocListener<SubaccountCreateCubit, SubaccountCreateState>(
            listenWhen: (prev, curr) => prev.status != curr.status,
            listener: (context, state) async {
              if (state.status == SubaccountCreateStatus.error &&
                  state.failureCode == 'limit_subaccounts_reached') {
                if (!context.mounted) return;
                await context.push(
                  AppRoutes.paywall,
                  extra: const PaywallArgs(reason: PaywallReason.subaccountsLimit),
                );
                return;
              }
              if (state.status != SubaccountCreateStatus.success || state.subaccount == null) {
                return;
              }

              final accountInfoCubit = context.read<AccountInfoCubit>();
              final accountsCubit = context.read<AccountsCubit>();
              final created = state.subaccount!;
              accountInfoCubit.applyCreatedSubaccount(created);
              context.read<AnalyticsCubit>().invalidateCache();
              accountsCubit.refresh(silent: true);

              if (!context.mounted) {
                return;
              }
              context.replace(
                AppRoutes.accountSubaccountDetail
                    .replaceFirst(':accountId', widget.accountId)
                    .replaceFirst(':subaccountId', created.id),
                extra: SubaccountDetailExtra(
                  account: accountInfoCubit.state.account,
                  subaccount: created,
                ),
              );
            },
          ),
          BlocListener<SubaccountCreateCubit, SubaccountCreateState>(
            listenWhen: (prev, curr) =>
                prev.failureMessage != curr.failureMessage && curr.failureMessage != null,
            listener: (context, state) {
              logger.e('Subaccount create failed: ${state.failureCode}');
              showDSSnackBar(
                context,
                variant: DSSnackBarVariant.error,
                message: state.failureMessage ?? l10n.errorGeneric,
              );
            },
          ),
        ],
        child: BlocBuilder<SubaccountCreateCubit, SubaccountCreateState>(
          builder: (context, createState) {
            final spacing = context.dsSpacing;
            final canSubmit = createState.status != SubaccountCreateStatus.loading;
            final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

            return Scaffold(
              appBar: DSAppBar(title: l10n.subaccountCreateTitle),
              body: SafeArea(
                child: ListView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    spacing.s24,
                    spacing.s24,
                    spacing.s24,
                    spacing.s16 + bottomInset,
                  ),
                  children: [
                    DSTextField(
                      label: l10n.accountsNameLabel,
                      hintText: _nameHint(l10n, formContext.copyProfile),
                      controller: _nameController,
                      errorText: createState.nameError == SubaccountCreateFieldError.required
                          ? l10n.accountsNameRequired
                          : null,
                      enabled: createState.status != SubaccountCreateStatus.loading,
                      onChanged: (_) => context.read<SubaccountCreateCubit>().clearNameError(),
                    ),
                    SizedBox(height: spacing.s12),
                    DSBalanceInput(
                      label: l10n.addBalanceAmountLabel,
                      controller: _balanceController,
                      amountErrorText: _balanceErrorText,
                      currencyErrorText: _currencyErrorText,
                      enabled: createState.status != SubaccountCreateStatus.loading,
                      currencyBadge: AssetCurrencyBadge(
                        currencyType: CurrencyType.all,
                        selectedSlug: _selectedAsset?.code,
                        sheetTitleText: l10n.baseCurrencySettingsPickerTitle,
                        placeholderText: l10n.subaccountCurrencyLabel,
                        searchHintText: l10n.assetSearchHint,
                        fiatTabText: l10n.assetKindFiat,
                        cryptoTabText: l10n.assetKindCrypto,
                        emptyResultsTitle: l10n.assetNoMatchesTitle,
                        emptyResultsMessage: l10n.assetNoMatchesBody,
                        enabled: createState.status != SubaccountCreateStatus.loading,
                        onSelected: (asset) {
                          setState(() {
                            _selectedAsset = asset;
                            _currencyErrorText = null;
                          });
                        },
                        onLocked: (_) {
                          context.push(AppRoutes.paywall);
                        },
                      ),
                      onChanged: (_) {
                        if (_balanceErrorText != null) {
                          setState(() => _balanceErrorText = null);
                        }
                      },
                    ),
                    SizedBox(height: spacing.s4),
                    Text(
                      _amountHelper(l10n, formContext.copyProfile),
                      style: context.dsTypography.caption.copyWith(
                        color: context.dsColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: spacing.s24),
                    DSButton(
                      label: l10n.subaccountCreateCta,
                      fullWidth: true,
                      isLoading: createState.status == SubaccountCreateStatus.loading,
                      onPressed: canSubmit
                          ? () async {
                              final asset = _selectedAsset;
                              final amount = _tryParse(_balanceController.text);
                              setState(() {
                                _currencyErrorText = asset == null
                                    ? l10n.subaccountCurrencyRequired
                                    : null;
                                _balanceErrorText = amount == null
                                    ? l10n.addBalanceValidationAmount
                                    : null;
                              });
                              if (asset == null || amount == null) {
                                return;
                              }
                              await context.read<SubaccountCreateCubit>().submit(
                                accountId: widget.accountId,
                                name: _nameController.text,
                                asset: asset,
                                snapshotAmount: amount,
                              );
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Decimal? _tryParse(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }
    try {
      return Decimal.parse(normalized);
    } catch (_) {
      return null;
    }
  }

  void _applyDefaultCurrencySelection(BuildContext context) {
    if (_selectedAsset != null) {
      return;
    }

    final assetsState = context.read<AssetsCubit>().state;
    final accountType = context.read<AccountInfoCubit>().state.account?.type;
    final formContext = AddSubaccountContext.fromAccountType(accountType);
    final defaultAsset = formContext.resolveDefaultAsset(
      fiatAssets: assetsState.fiatAssets,
      cryptoAssets: assetsState.cryptoAssets,
    );
    if (defaultAsset == null) {
      return;
    }

    setState(() {
      _selectedAsset = defaultAsset;
      _currencyErrorText = null;
    });
  }

  String _nameHint(AppLocalizations l10n, AddSubaccountCopyProfile profile) {
    return switch (profile) {
      AddSubaccountCopyProfile.bank => l10n.subaccountNameHintBank,
      AddSubaccountCopyProfile.walletExchange => l10n.subaccountNameHintWalletExchange,
      AddSubaccountCopyProfile.cash => l10n.subaccountNameHintCash,
      AddSubaccountCopyProfile.other => l10n.subaccountNameHintOther,
    };
  }

  String _amountHelper(AppLocalizations l10n, AddSubaccountCopyProfile profile) {
    return switch (profile) {
      AddSubaccountCopyProfile.bank => l10n.subaccountAmountHelperBank,
      AddSubaccountCopyProfile.walletExchange => l10n.subaccountAmountHelperWalletExchange,
      AddSubaccountCopyProfile.cash => l10n.subaccountAmountHelperCash,
      AddSubaccountCopyProfile.other => l10n.subaccountAmountHelperOther,
    };
  }
}
