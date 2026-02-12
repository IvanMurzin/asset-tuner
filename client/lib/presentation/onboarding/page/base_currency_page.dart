import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_loader.dart';
import 'package:asset_tuner/core_ui/components/ds_search_field.dart';
import 'package:asset_tuner/core_ui/components/ds_select_list.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/currency/entity/currency_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/onboarding/bloc/base_currency_cubit.dart';
import 'package:asset_tuner/presentation/paywall/entity/paywall_args.dart';

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
                message: _failureMessage(l10n, state.loadFailureCode),
                actionLabel: l10n.splashRetry,
                onAction: () => context.read<BaseCurrencyCubit>().load(),
              ),
            );
          }

          final filtered = _filterCurrencies(state);
          final options = filtered
              .map(
                (currency) => DSSelectOption(
                  id: currency.code,
                  title: '${currency.code} · ${currency.name}',
                  subtitle: currency.symbol,
                ),
              )
              .toList();
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
                    DSSearchField(
                      hintText: l10n.onboardingSearchHint,
                      onChanged: context.read<BaseCurrencyCubit>().updateQuery,
                    ),
                    SizedBox(height: spacing.s16),
                    Text(
                      l10n.baseCurrencySettingsSearchTip,
                      style: typography.caption.copyWith(
                        color: context.dsColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: spacing.s12),
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
                    DSSelectList(
                      options: options,
                      selectedId: state.selectedCode,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      onSelect: (option) => context
                          .read<BaseCurrencyCubit>()
                          .selectCurrency(option.id),
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

  List<CurrencyEntity> _filterCurrencies(BaseCurrencyState state) {
    final query = state.query.trim().toLowerCase();
    if (query.length < 2) {
      const popular = {'USD', 'EUR', 'RUB'};
      return state.currencies.where((c) => popular.contains(c.code)).toList();
    }
    return state.currencies
        .where(
          (currency) =>
              currency.code.toLowerCase().contains(query) ||
              currency.name.toLowerCase().contains(query),
        )
        .take(50)
        .toList();
  }

  String _failureMessage(AppLocalizations l10n, String? code) {
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
      ),
      null => null,
    };
  }
}
