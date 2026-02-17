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
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/balance/bloc/add_balance_cubit.dart';

class AddBalancePage extends StatefulWidget {
  const AddBalancePage({super.key, required this.subaccountId, this.initialDate});

  final String subaccountId;
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
      create: (_) =>
          getIt<AddBalanceCubit>()
            ..load(subaccountId: widget.subaccountId, initialDate: widget.initialDate),
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

          if (state.status == AddBalanceStatus.error && state.subaccountId == null) {
            return Scaffold(
              appBar: DSAppBar(title: l10n.subaccountUpdateBalanceCta),
              body: DSInlineError(
                title: l10n.splashErrorTitle,
                message: state.failureMessage ?? l10n.errorGeneric,
                actionLabel: l10n.splashRetry,
                onAction: () => context.read<AddBalanceCubit>().load(
                  subaccountId: widget.subaccountId,
                  initialDate: widget.initialDate,
                ),
              ),
            );
          }

          if (_amountController.text.isEmpty && state.amountText.isNotEmpty) {
            _amountController.text = state.amountText;
          }

          return Scaffold(
            appBar: DSAppBar(title: l10n.subaccountUpdateBalanceCta),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(spacing.s24, spacing.s24, spacing.s24, spacing.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.failureCode != null && state.failureCode != 'validation') ...[
                      DSInlineBanner(
                        title: l10n.subaccountUpdateBalanceCta,
                        message: state.failureMessage ?? l10n.errorGeneric,
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
                                l10n.addBalanceHelperSnapshot,
                                style: typography.caption.copyWith(
                                  color: context.dsColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: spacing.s24),
                              DSDatePickerField(
                                label: l10n.addBalanceDateLabel,
                                value: state.entryDate,
                                enabled: !state.isSaving,
                                errorText: _dateErrorText(l10n, state.dateError),
                                onChanged: context.read<AddBalanceCubit>().selectDate,
                              ),
                              SizedBox(height: spacing.s16),
                              DSDecimalField(
                                label: l10n.addBalanceAmountLabel,
                                controller: _amountController,
                                enabled: !state.isSaving,
                                errorText: _amountErrorText(l10n, state.amountError),
                                onChanged: context.read<AddBalanceCubit>().updateAmount,
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
                      onPressed: state.isSaving ? null : context.read<AddBalanceCubit>().save,
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
