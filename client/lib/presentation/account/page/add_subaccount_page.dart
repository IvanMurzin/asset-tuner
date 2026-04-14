import 'package:decimal/decimal.dart';
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
import 'package:asset_tuner/core_ui/components/ds_currency_picker.dart';
import 'package:asset_tuner/core_ui/components/ds_decimal_field.dart';
import 'package:asset_tuner/core_ui/components/ds_radio_row.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/components/ds_snackbar.dart';
import 'package:asset_tuner/core_ui/components/ds_text_field.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/account/bloc/account_info_cubit.dart';
import 'package:asset_tuner/presentation/account/bloc/accounts_cubit.dart';
import 'package:asset_tuner/presentation/asset/bloc/assets_cubit.dart';
import 'package:asset_tuner/presentation/balance/bloc/subaccount_create_cubit.dart';

class AddSubaccountPage extends StatefulWidget {
  const AddSubaccountPage({super.key, required this.accountId});

  final String accountId;

  @override
  State<AddSubaccountPage> createState() => _AddSubaccountPageState();
}

class _AddSubaccountPageState extends State<AddSubaccountPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;

  AssetKind? _kind;
  AssetEntity? _selectedAsset;
  String? _currencyErrorText;
  String? _balanceErrorText;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _balanceController = TextEditingController();
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

    return BlocProvider(
      create: (_) => getIt<SubaccountCreateCubit>(),
      child: MultiBlocListener(
        listeners: [
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
            final assetsState = context.watch<AssetsCubit>().state;
            final allAssets = _kind == null
                ? const <AssetEntity>[]
                : assetsState.assets.where((item) => item.kind == _kind).toList();
            final canSubmit = createState.status != SubaccountCreateStatus.loading;

            return Scaffold(
              appBar: DSAppBar(title: l10n.subaccountCreateTitle),
              body: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(spacing.s24, spacing.s24, spacing.s24, spacing.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DSTextField(
                        label: l10n.accountsNameLabel,
                        hintText: l10n.subaccountNameHint,
                        controller: _nameController,
                        errorText: createState.nameError == SubaccountCreateFieldError.required
                            ? l10n.accountsNameRequired
                            : null,
                        enabled: createState.status != SubaccountCreateStatus.loading,
                        onChanged: (_) => context.read<SubaccountCreateCubit>().clearNameError(),
                      ),
                      SizedBox(height: spacing.s12),
                      DSDecimalField(
                        label: l10n.addBalanceAmountLabel,
                        controller: _balanceController,
                        errorText: _balanceErrorText,
                        enabled: createState.status != SubaccountCreateStatus.loading,
                        onChanged: (_) {
                          if (_balanceErrorText != null) {
                            setState(() => _balanceErrorText = null);
                          }
                        },
                      ),
                      SizedBox(height: spacing.s24),
                      DSSectionTitle(title: l10n.accountsTypeLabel),
                      SizedBox(height: spacing.s8),
                      DSRadioRow(
                        title: l10n.assetKindFiat,
                        selected: _kind == AssetKind.fiat,
                        onTap: () => setState(() {
                          _kind = AssetKind.fiat;
                          _selectedAsset = null;
                        }),
                      ),
                      DSRadioRow(
                        title: l10n.assetKindCrypto,
                        selected: _kind == AssetKind.crypto,
                        onTap: () => setState(() {
                          _kind = AssetKind.crypto;
                          _selectedAsset = null;
                        }),
                      ),
                      SizedBox(height: spacing.s12),
                      DSCurrencyPicker(
                        options: [
                          for (final asset in allAssets)
                            DSCurrencyPickerOption(
                              id: asset.id,
                              primaryText: asset.code,
                              secondaryText: asset.name,
                              tertiaryText: asset.code,
                              searchTerms: [asset.code, asset.name],
                              locked: asset.isLocked ?? false,
                            ),
                        ],
                        selectedId: _selectedAsset?.id,
                        searchHintText: _kind == null
                            ? '${l10n.assetKindFiat} / ${l10n.assetKindCrypto}'
                            : l10n.assetSearchHint,
                        recentTitleText: l10n.currencyPickerRecentTitle,
                        selectedTitleText: l10n.subaccountCurrencyLabel,
                        changeSelectionText: l10n.currencyPickerChangeAction,
                        emptyResultsTitle: l10n.assetNoMatchesTitle,
                        emptyResultsMessage: l10n.assetNoMatchesBody,
                        enabled: _kind != null,
                        errorText: _currencyErrorText,
                        onSelect: (id) {
                          final asset = allAssets.where((item) => item.id == id).firstOrNull;
                          if (asset?.isLocked ?? false) {
                            context.push(AppRoutes.paywall);
                            return;
                          }
                          setState(() {
                            _selectedAsset = asset;
                            _currencyErrorText = null;
                          });
                        },
                      ),
                      const Spacer(),
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
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    for (final item in this) {
      return item;
    }
    return null;
  }
}
