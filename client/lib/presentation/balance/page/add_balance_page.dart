import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_date_picker_field.dart';
import 'package:asset_tuner/core_ui/components/ds_decimal_field.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_loader.dart';
import 'package:asset_tuner/core_ui/components/ds_segmented_control.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/balance/entity/balance_entry_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/balance/bloc/add_balance_cubit.dart';

class AddBalancePage extends StatefulWidget {
  const AddBalancePage({
    super.key,
    required this.accountId,
    required this.assetId,
    this.initialDate,
  });

  final String accountId;
  final String assetId;
  final DateTime? initialDate;

  @override
  State<AddBalancePage> createState() => _AddBalancePageState();
}

class _AddBalancePageState extends State<AddBalancePage> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<AddBalanceCubit>()
        ..load(
          accountId: widget.accountId,
          assetId: widget.assetId,
          initialDate: widget.initialDate,
        ),
      child: BlocConsumer<AddBalanceCubit, AddBalanceState>(
        listener: (context, state) {
          final navigation = state.navigation;
          if (navigation == null) {
            return;
          }
          context.read<AddBalanceCubit>().consumeNavigation();
          switch (navigation.destination) {
            case AddBalanceDestination.signIn:
              context.go(AppRoutes.signIn);
              break;
            case AddBalanceDestination.backSaved:
              context.pop(true);
              break;
          }
        },
        builder: (context, state) {
          final spacing = context.dsSpacing;
          final typography = context.dsTypography;

          if (state.status == AddBalanceStatus.loading) {
            return const Scaffold(body: Center(child: DSLoader()));
          }

          if (state.status == AddBalanceStatus.error &&
              state.accountAssetId == null) {
            return Scaffold(
              appBar: DSAppBar(title: l10n.addBalanceTitle),
              body: DSInlineError(
                title: l10n.splashErrorTitle,
                message: _failureMessage(l10n, state.failureCode),
                actionLabel: l10n.splashRetry,
                onAction: () => context.read<AddBalanceCubit>().load(
                  accountId: widget.accountId,
                  assetId: widget.assetId,
                  initialDate: widget.initialDate,
                ),
              ),
            );
          }

          final selectedIndex = state.entryType == BalanceEntryType.delta
              ? 1
              : 0;
          final helper = state.entryType == BalanceEntryType.delta
              ? l10n.addBalanceHelperDelta
              : l10n.addBalanceHelperSnapshot;

          if (_amountController.text.isEmpty && state.amountText.isNotEmpty) {
            _amountController.text = state.amountText;
          }

          return Scaffold(
            appBar: DSAppBar(title: l10n.addBalanceTitle),
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
                    if (state.failureCode != null &&
                        state.failureCode != 'validation') ...[
                      DSInlineBanner(
                        title: l10n.addBalanceTitle,
                        message: _failureMessage(l10n, state.failureCode),
                        variant: DSInlineBannerVariant.danger,
                      ),
                      SizedBox(height: spacing.s16),
                    ],
                    Expanded(
                      child: SingleChildScrollView(
                        child: DSCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.addBalanceEntryTypeLabel,
                                style: typography.caption,
                              ),
                              SizedBox(height: spacing.s8),
                              DSSegmentedControl(
                                labels: [
                                  l10n.addBalanceTypeSnapshot,
                                  l10n.addBalanceTypeDelta,
                                ],
                                selectedIndex: selectedIndex,
                                enabled: !state.isSaving,
                                onChanged: (index) =>
                                    context.read<AddBalanceCubit>().selectType(
                                      index == 1
                                          ? BalanceEntryType.delta
                                          : BalanceEntryType.snapshot,
                                    ),
                              ),
                              SizedBox(height: spacing.s12),
                              Text(
                                helper,
                                style: typography.caption.copyWith(
                                  color: context.dsColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: spacing.s24),
                              DSDatePickerField(
                                label: l10n.addBalanceDateLabel,
                                value: state.entryDate,
                                enabled: !state.isSaving,
                                errorText: _dateErrorText(
                                  l10n,
                                  state.dateError,
                                ),
                                onChanged: context
                                    .read<AddBalanceCubit>()
                                    .selectDate,
                              ),
                              SizedBox(height: spacing.s16),
                              DSDecimalField(
                                label: l10n.addBalanceAmountLabel,
                                controller: _amountController,
                                enabled: !state.isSaving,
                                errorText: _amountErrorText(
                                  l10n,
                                  state.amountError,
                                ),
                                onChanged: context
                                    .read<AddBalanceCubit>()
                                    .updateAmount,
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
                      isLoading: state.isSaving,
                      onPressed: state.isSaving
                          ? null
                          : context.read<AddBalanceCubit>().save,
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

  String? _amountErrorText(AppLocalizations l10n, String? code) {
    return switch (code) {
      'required' => l10n.addBalanceValidationAmount,
      'invalid' => l10n.errorValidation,
      _ => null,
    };
  }

  String? _dateErrorText(AppLocalizations l10n, String? code) {
    return switch (code) {
      'invalid' => l10n.addBalanceValidationDate,
      _ => null,
    };
  }
}
