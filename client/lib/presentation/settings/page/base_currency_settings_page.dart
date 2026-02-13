import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_currency_picker.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_loader.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/entitlement/entity/entitlements_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/paywall/entity/paywall_args.dart';
import 'package:asset_tuner/presentation/settings/bloc/base_currency_settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class BaseCurrencySettingsPage extends StatelessWidget {
  const BaseCurrencySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<BaseCurrencySettingsCubit>()..load(),
      child: BlocConsumer<BaseCurrencySettingsCubit, BaseCurrencySettingsState>(
        listener: (context, state) async {
          final navigation = state.navigation;
          if (navigation == null) {
            return;
          }
          context.read<BaseCurrencySettingsCubit>().consumeNavigation();
          switch (navigation.destination) {
            case BaseCurrencySettingsDestination.back:
              context.pop(state.currentCode);
              break;
            case BaseCurrencySettingsDestination.signIn:
              context.go(AppRoutes.signIn);
              break;
            case BaseCurrencySettingsDestination.paywall:
              final upgraded = await context.push<bool>(
                AppRoutes.paywall,
                extra: PaywallArgs(
                  reason: PaywallReason.baseCurrency,
                  requestedBaseCurrencyCode: navigation.requestedCode,
                ),
              );
              if (context.mounted && upgraded == true) {
                await context.read<BaseCurrencySettingsCubit>().load();
                final requested = navigation.requestedCode;
                if (requested != null && context.mounted) {
                  context.read<BaseCurrencySettingsCubit>().selectCurrency(requested);
                }
              }
              break;
          }
        },
        builder: (context, state) {
          final spacing = context.dsSpacing;
          final typography = context.dsTypography;
          final colors = context.dsColors;

          if (state.status == BaseCurrencySettingsStatus.loading) {
            return const Scaffold(body: Center(child: DSLoader()));
          }

          if (state.status == BaseCurrencySettingsStatus.error && state.currencies.isEmpty) {
            return Scaffold(
              appBar: DSAppBar(title: l10n.baseCurrencySettingsTitle),
              body: DSInlineError(
                title: l10n.baseCurrencySettingsLoadErrorTitle,
                message: _failureMessage(l10n, state.loadFailureCode),
                actionLabel: l10n.splashRetry,
                onAction: () => context.read<BaseCurrencySettingsCubit>().load(),
              ),
            );
          }

          final options = _buildOptions(state);

          return Scaffold(
            appBar: DSAppBar(title: l10n.baseCurrencySettingsTitle),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  top: spacing.s24,
                  bottom: spacing.s16,
                  left: spacing.s24,
                  right: spacing.s24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DSSectionTitle(title: l10n.baseCurrencySettingsCurrentTitle),
                    SizedBox(height: spacing.s12),
                    DSCard(
                      padding: EdgeInsets.symmetric(horizontal: spacing.s8, vertical: spacing.s16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.attach_money_rounded, size: 28, color: colors.primary),
                              SizedBox(width: spacing.s12),
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        l10n.baseCurrencySettingsCurrentBody,
                                        style: typography.body.copyWith(
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: spacing.s4),
                                    Text(
                                      state.currentCode ?? l10n.notAvailable,
                                      style: typography.h2.copyWith(fontWeight: FontWeight.w700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(width: spacing.s16),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: spacing.s24),
                    DSSectionTitle(title: l10n.baseCurrencySettingsPickerTitle),
                    SizedBox(height: spacing.s12),
                    if (state.bannerType == BaseCurrencySettingsBannerType.saveFailure &&
                        state.bannerFailureCode != null) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: spacing.s24),
                        child: DSInlineBanner(
                          title: l10n.baseCurrencySettingsTitle,
                          message: _failureMessage(l10n, state.bannerFailureCode),
                          variant: DSInlineBannerVariant.danger,
                        ),
                      ),
                      SizedBox(height: spacing.s16),
                    ],
                    if (!(state.entitlements?.anyBaseCurrency ?? false)) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: spacing.s24),
                        child: DSInlineBanner(
                          title: l10n.baseCurrencySettingsTitle,
                          message: l10n.baseCurrencySettingsPaywallHint,
                          variant: DSInlineBannerVariant.info,
                        ),
                      ),
                      SizedBox(height: spacing.s12),
                    ],
                    DSCurrencyPicker(
                      options: options,
                      selectedId: state.selectedCode?.toUpperCase(),
                      searchHintText: l10n.baseCurrencySettingsSearchHint,
                      recentTitleText: l10n.currencyPickerRecentTitle,
                      selectedTitleText: l10n.currencyPickerSelectedTitle,
                      changeSelectionText: l10n.currencyPickerChangeAction,
                      emptyResultsTitle: l10n.currencyPickerNoResultsTitle,
                      emptyResultsMessage: l10n.currencyPickerNoResultsBody,
                      enabled: !state.isSaving,
                      onSelect: (code) =>
                          context.read<BaseCurrencySettingsCubit>().selectCurrency(code),
                    ),
                    Spacer(),
                    DSButton(
                      label: l10n.baseCurrencySettingsSave,
                      fullWidth: true,
                      isLoading: state.isSaving,
                      onPressed: state.isSaving
                          ? null
                          : () => context.read<BaseCurrencySettingsCubit>().save(),
                    ),
                    SizedBox(height: spacing.s16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<DSCurrencyPickerOption> _buildOptions(BaseCurrencySettingsState state) {
    final popularSet = BaseCurrencySettingsCubit.popularCodes
        .map((item) => item.toUpperCase())
        .toSet();
    final sorted = [...state.currencies]
      ..sort((a, b) {
        final aCode = a.code.toUpperCase();
        final bCode = b.code.toUpperCase();
        final aWeight = popularSet.contains(aCode) ? 0 : 1;
        final bWeight = popularSet.contains(bCode) ? 0 : 1;
        if (aWeight != bWeight) {
          return aWeight.compareTo(bWeight);
        }
        return aCode.compareTo(bCode);
      });

    return sorted.map((currency) {
      final code = currency.code.toUpperCase();
      return DSCurrencyPickerOption(
        id: code,
        primaryText: code,
        secondaryText: currency.name,
        tertiaryText: currency.symbol,
        searchTerms: [currency.name, currency.symbol],
        locked: !_isAllowed(state.entitlements, code),
      );
    }).toList();
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

  bool _isAllowed(EntitlementsEntity? entitlements, String code) {
    if (entitlements == null) {
      return false;
    }
    if (entitlements.anyBaseCurrency) {
      return true;
    }
    return entitlements.freeBaseCurrencyCodes.contains(code.toUpperCase());
  }
}
