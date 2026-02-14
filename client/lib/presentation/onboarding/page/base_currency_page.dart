import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_currency_picker.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_loader.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/onboarding/bloc/base_currency_cubit.dart';
import 'package:asset_tuner/presentation/paywall/entity/paywall_args.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class BaseCurrencyPage extends StatelessWidget {
  const BaseCurrencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<BaseCurrencyCubit>(),
      child: BlocConsumer<BaseCurrencyCubit, BaseCurrencyState>(
        listener: (context, state) async {
          final navigation = state.navigation;
          if (navigation == null) {
            return;
          }
          context.read<BaseCurrencyCubit>().consumeNavigation();
          switch (navigation.destination) {
            case BaseCurrencyDestination.signIn:
              context.go(AppRoutes.signIn);
              break;
            case BaseCurrencyDestination.main:
              context.go(AppRoutes.main);
              break;
            case BaseCurrencyDestination.paywall:
              final upgraded = await context.push<bool>(
                AppRoutes.paywall,
                extra: const PaywallArgs(reason: PaywallReason.baseCurrency),
              );
              if (context.mounted && upgraded == true) {
                await context.read<BaseCurrencyCubit>().load();
              }
              break;
          }
        },
        builder: (context, state) {
          final spacing = context.dsSpacing;
          final typography = context.dsTypography;

          if (state.status == BaseCurrencyStatus.loading) {
            return const Scaffold(body: Center(child: DSLoader()));
          }

          if (state.status == BaseCurrencyStatus.error) {
            return Scaffold(
              appBar: DSAppBar(title: l10n.onboardingBaseCurrencyTitle),
              body: DSInlineError(
                title: l10n.onboardingLoadError,
                message: _failureMessage(l10n, state.loadFailureCode, state.loadFailureMessage),
                actionLabel: l10n.splashRetry,
                onAction: () => context.read<BaseCurrencyCubit>().load(),
              ),
            );
          }

          final options = _buildOptions(state);
          final bannerMessage = _bannerMessage(l10n, state);

          return Scaffold(
            appBar: DSAppBar(title: l10n.onboardingBaseCurrencyTitle),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  spacing.s24,
                  spacing.s24,
                  spacing.s24,
                  spacing.s32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(spacing.s24),
                      decoration: BoxDecoration(
                        color: context.dsColors.surface,
                        borderRadius: BorderRadius.circular(
                          context.dsRadius.r16,
                        ),
                        border: Border.all(
                          color: context.dsColors.border.withValues(alpha: 0.7),
                        ),
                        boxShadow: context.dsElevation.e1,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.onboardingBaseCurrencyTitle,
                            style: typography.h2,
                          ),
                          SizedBox(height: spacing.s8),
                          Text(
                            l10n.onboardingBaseCurrencyBody,
                            style: typography.body.copyWith(
                              color: context.dsColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: spacing.s24),
                    if (bannerMessage != null)
                      DSInlineBanner(
                        title: l10n.onboardingBaseCurrencyTitle,
                        message: bannerMessage,
                        variant:
                            state.bannerType ==
                                BaseCurrencyBannerType.saveFailure
                            ? DSInlineBannerVariant.danger
                            : DSInlineBannerVariant.info,
                      ),
                    if (bannerMessage != null) SizedBox(height: spacing.s16),
                    DSCurrencyPicker(
                      options: options,
                      selectedId: state.selectedCode?.toUpperCase(),
                      searchHintText: l10n.onboardingSearchHint,
                      recentTitleText: l10n.currencyPickerRecentTitle,
                      selectedTitleText: l10n.currencyPickerSelectedTitle,
                      changeSelectionText: l10n.currencyPickerChangeAction,
                      emptyResultsTitle: l10n.currencyPickerNoResultsTitle,
                      emptyResultsMessage: l10n.currencyPickerNoResultsBody,
                      enabled: !state.isSaving,
                      onSelect: (code) => context
                          .read<BaseCurrencyCubit>()
                          .selectCurrency(code),
                    ),
                    SizedBox(height: spacing.s24),
                    DSButton(
                      label: l10n.onboardingContinue,
                      fullWidth: true,
                      isLoading: state.isSaving,
                      onPressed: state.isSaving
                          ? null
                          : context.read<BaseCurrencyCubit>().continueNext,
                    ),
                    SizedBox(height: spacing.s12),
                    DSButton(
                      label: l10n.onboardingUseUsd,
                      variant: DSButtonVariant.secondary,
                      fullWidth: true,
                      onPressed: state.isSaving
                          ? null
                          : context.read<BaseCurrencyCubit>().useUsdForNow,
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

  List<DSCurrencyPickerOption> _buildOptions(BaseCurrencyState state) {
    const freeUnlockedByRank = 5;
    return state.currencies.asMap().entries.map((entry) {
      final index = entry.key;
      final currency = entry.value;
      final code = currency.code.toUpperCase();
      final allowed =
          (state.entitlements?.anyBaseCurrency ?? false) ||
          index < freeUnlockedByRank;
      return DSCurrencyPickerOption(
        id: code,
        primaryText: code,
        secondaryText: currency.name,
        tertiaryText: currency.symbol,
        searchTerms: [currency.name, currency.symbol],
        locked: !allowed,
      );
    }).toList();
  }

  String _failureMessage(AppLocalizations l10n, String? code, String? message) {
    if (message != null && message.trim().isNotEmpty) return message.trim();
    return switch (code) {
      'rate_limited' => l10n.errorRateLimited,
      'network' => l10n.errorNetwork,
      'unauthorized' => l10n.errorUnauthorized,
      'conflict' => l10n.errorConflict,
      _ => l10n.errorGeneric,
    };
  }

  String? _bannerMessage(AppLocalizations l10n, BaseCurrencyState state) {
    return switch (state.bannerType) {
      BaseCurrencyBannerType.selectCurrency => l10n.onboardingSelectCurrency,
      BaseCurrencyBannerType.saveFailure => _failureMessage(
        l10n,
        state.bannerFailureCode,
        state.bannerFailureMessage,
      ),
      null => null,
    };
  }
}
