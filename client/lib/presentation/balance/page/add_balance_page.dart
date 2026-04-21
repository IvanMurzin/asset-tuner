import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_balance_input.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_date_picker_field.dart';
import 'package:asset_tuner/core_ui/components/ds_snackbar.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/account/bloc/account_info_cubit.dart';
import 'package:asset_tuner/presentation/account/bloc/accounts_cubit.dart';
import 'package:asset_tuner/presentation/analytics/bloc/analytics_cubit.dart';
import 'package:asset_tuner/presentation/asset/widget/asset_currency_badge.dart';
import 'package:asset_tuner/presentation/balance/bloc/subaccount_balance_cubit.dart';
import 'package:asset_tuner/presentation/balance/bloc/subaccount_info_cubit.dart';

class AddBalancePage extends StatefulWidget {
  const AddBalancePage({
    super.key,
    required this.accountId,
    required this.subaccountId,
    this.initialDate,
  });

  final String accountId;
  final String subaccountId;
  final DateTime? initialDate;

  @override
  State<AddBalancePage> createState() => _AddBalancePageState();
}

class _AddBalancePageState extends State<AddBalancePage> {
  late final TextEditingController _amountController;
  late DateTime _date;
  String? _amountErrorText;

  @override
  void initState() {
    super.initState();
    final subaccountState = context.read<SubaccountInfoCubit>().state;
    _amountController = TextEditingController(text: _initialAmountText(subaccountState));
    _date = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedAssetCode = context.select<SubaccountInfoCubit, String?>(
      (cubit) => cubit.state.subaccount?.asset?.code,
    );

    return BlocProvider(
      create: (_) => getIt<SubaccountBalanceCubit>(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<SubaccountBalanceCubit, SubaccountBalanceState>(
            listenWhen: (prev, curr) => prev.status != curr.status,
            listener: (context, state) async {
              if (state.status != SubaccountBalanceStatus.success || state.entry == null) {
                return;
              }

              final accountInfoCubit = context.read<AccountInfoCubit>();
              final accountsCubit = context.read<AccountsCubit>();
              final subaccountInfoCubit = context.read<SubaccountInfoCubit>();
              final entry = state.entry!;
              accountInfoCubit.applyUpdatedSubaccountBalance(
                subaccountId: widget.subaccountId,
                amountAtomic: entry.amountAtomic,
                amountDecimals: entry.amountDecimals,
              );
              context.read<AnalyticsCubit>().invalidateCache();
              accountsCubit.refresh(silent: true);
              subaccountInfoCubit.refreshHistory(showLoading: true);

              if (!context.mounted) {
                return;
              }
              context.pop(true);
            },
          ),
          BlocListener<SubaccountBalanceCubit, SubaccountBalanceState>(
            listenWhen: (prev, curr) =>
                prev.failureMessage != curr.failureMessage && curr.failureMessage != null,
            listener: (context, state) {
              logger.e('Set balance failed: ${state.failureCode}');
              showDSSnackBar(
                context,
                variant: DSSnackBarVariant.error,
                message: state.failureMessage ?? l10n.errorGeneric,
              );
            },
          ),
        ],
        child: BlocBuilder<SubaccountBalanceCubit, SubaccountBalanceState>(
          builder: (context, state) {
            final spacing = context.dsSpacing;
            final isLoading = state.status == SubaccountBalanceStatus.loading;

            return Scaffold(
              appBar: DSAppBar(title: l10n.subaccountUpdateBalanceCta),
              body: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(spacing.s24, spacing.s24, spacing.s24, spacing.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: DSCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.addBalanceHelperSnapshot,
                                  style: context.dsTypography.body.copyWith(
                                    color: context.dsColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: spacing.s16),
                                DSDatePickerField(
                                  label: l10n.addBalanceDateLabel,
                                  value: _date,
                                  enabled: !isLoading,
                                  onChanged: (value) => setState(() => _date = value),
                                ),
                                SizedBox(height: spacing.s16),
                                DSBalanceInput(
                                  label: l10n.addBalanceAmountLabel,
                                  controller: _amountController,
                                  amountErrorText: _amountErrorText,
                                  enabled: !isLoading,
                                  currencyBadge: AssetCurrencyBadge(
                                    currencyType: CurrencyType.all,
                                    selectedSlug: selectedAssetCode,
                                    sheetTitleText: l10n.baseCurrencySettingsPickerTitle,
                                    placeholderText: l10n.subaccountCurrencyLabel,
                                    searchHintText: l10n.assetSearchHint,
                                    fiatTabText: l10n.assetKindFiat,
                                    cryptoTabText: l10n.assetKindCrypto,
                                    emptyResultsTitle: l10n.assetNoMatchesTitle,
                                    emptyResultsMessage: l10n.assetNoMatchesBody,
                                    enabled: false,
                                    onSelected: (_) {},
                                    onLocked: (_) {},
                                  ),
                                  onChanged: (_) {
                                    if (_amountErrorText != null) {
                                      setState(() => _amountErrorText = null);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: spacing.s16),
                      DSButton(
                        label: l10n.save,
                        fullWidth: true,
                        isLoading: isLoading,
                        onPressed: isLoading
                            ? null
                            : () async {
                                final amount = _parseDecimal(_amountController.text);
                                if (amount == null) {
                                  setState(
                                    () => _amountErrorText = l10n.addBalanceValidationAmount,
                                  );
                                  return;
                                }
                                await context.read<SubaccountBalanceCubit>().submit(
                                  subaccountId: widget.subaccountId,
                                  entryDate: _date,
                                  snapshotAmount: amount,
                                );
                              },
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

  Decimal? _parseDecimal(String input) {
    final normalized = input.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }
    try {
      return Decimal.parse(normalized);
    } catch (_) {
      return null;
    }
  }

  String _initialAmountText(SubaccountInfoState state) {
    Decimal? initialAmount;
    if (state.entries.isNotEmpty) {
      initialAmount = state.entries.first.snapshotAmount;
    }
    initialAmount ??= state.subaccount?.currentAmount;
    return initialAmount?.toString() ?? '';
  }
}
