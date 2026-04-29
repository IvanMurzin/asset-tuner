import 'package:asset_tuner/core/analytics/app_analytics.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_base_currency_value_card.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_snackbar.dart';
import 'package:asset_tuner/core_ui/components/ds_unlock_currencies_card.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/asset/bloc/assets_cubit.dart';
import 'package:asset_tuner/presentation/asset/widget/asset_currency_badge.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_args.dart';
import 'package:asset_tuner/presentation/profile/bloc/profile_cubit.dart';
import 'package:asset_tuner/presentation/settings/widget/base_currency_how_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class BaseCurrencySettingsPage extends StatefulWidget {
  const BaseCurrencySettingsPage({super.key});

  @override
  State<BaseCurrencySettingsPage> createState() => _BaseCurrencySettingsPageState();
}

class _BaseCurrencySettingsPageState extends State<BaseCurrencySettingsPage> {
  String? _selectedCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<ProfileCubit, ProfileState>(
      listenWhen: (prev, curr) =>
          prev.failureMessage != curr.failureMessage && curr.failureMessage != null,
      listener: (context, state) {
        logger.e('Base currency update failed: ${state.failureCode}');
        showDSSnackBar(
          context,
          variant: DSSnackBarVariant.error,
          message: state.failureMessage ?? l10n.errorGeneric,
        );
      },
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profileState) {
          if (!profileState.isReady) {
            return Scaffold(
              appBar: DSAppBar(title: l10n.baseCurrencySettingsTitle),
              body: DSInlineError(
                title: l10n.splashErrorTitle,
                message: profileState.failureMessage ?? l10n.errorGeneric,
                actionLabel: l10n.splashRetry,
                onAction: () => context.read<ProfileCubit>().refresh(),
              ),
            );
          }

          final profile = profileState.profile!;
          _selectedCode ??= profile.baseCurrency;

          return BlocBuilder<AssetsCubit, AssetsState>(
            builder: (context, assetsState) {
              final spacing = context.dsSpacing;

              if (assetsState.status == AssetsStatus.loading && assetsState.assets.isEmpty) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              if (assetsState.status == AssetsStatus.error && assetsState.assets.isEmpty) {
                return Scaffold(
                  appBar: DSAppBar(title: l10n.baseCurrencySettingsTitle),
                  body: DSInlineError(
                    title: l10n.splashErrorTitle,
                    message: assetsState.failureMessage ?? l10n.errorGeneric,
                    actionLabel: l10n.splashRetry,
                    onAction: () => context.read<AssetsCubit>().load(),
                  ),
                );
              }

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
                    child: ListView(
                      children: [
                        DSBaseCurrencyValueCard(
                          title: l10n.baseCurrencySettingsCurrentTitle,
                          caption: l10n.baseCurrencySettingsCurrentBody,
                          trailing: AssetCurrencyBadge(
                            currencyType: CurrencyType.fiat,
                            selectedSlug: (_selectedCode ?? profile.baseCurrency).toUpperCase(),
                            sheetTitleText: l10n.baseCurrencySettingsPickerTitle,
                            placeholderText: l10n.subaccountCurrencyLabel,
                            searchHintText: l10n.baseCurrencySettingsSearchHint,
                            fiatTabText: l10n.assetKindFiat,
                            cryptoTabText: l10n.assetKindCrypto,
                            emptyResultsTitle: l10n.currencyPickerNoResultsTitle,
                            emptyResultsMessage: l10n.currencyPickerNoResultsBody,
                            enabled: !profileState.isUpdatingBaseCurrency,
                            onSelected: (asset) {
                              setState(() => _selectedCode = asset.code.toUpperCase());
                            },
                            onLocked: (asset) {
                              if (profile.entitlements.anyBaseCurrency) {
                                setState(() => _selectedCode = asset.code.toUpperCase());
                                return;
                              }
                              _openBaseCurrencyPaywall(context, asset.code);
                            },
                          ),
                        ),
                        SizedBox(height: spacing.s24),
                        const BaseCurrencyHowSection(),
                        SizedBox(height: spacing.s24),
                        if (!(profile.entitlements.anyBaseCurrency) && profile.plan != 'pro') ...[
                          DSUnlockCurrenciesCard(
                            title: l10n.paywallFeatureCurrencies,
                            subtitle: l10n.baseCurrencySettingsPaywallHint,
                            actionLabel: l10n.paywallUpgrade,
                            onTap: () {
                              getIt<AppAnalytics>().log(
                                AnalyticsEventName.lockedFeatureTapped,
                                parameters: {
                                  AnalyticsParams.feature: 'base_currency',
                                  AnalyticsParams.placement: 'base_currency_settings',
                                },
                              );
                              context.push(
                                AppRoutes.paywall,
                                extra: const PaywallArgs(reason: PaywallReason.baseCurrency),
                              );
                            },
                          ),
                          SizedBox(height: spacing.s16),
                        ],
                        DSButton(
                          label: l10n.baseCurrencySettingsSave,
                          fullWidth: true,
                          isLoading: profileState.isUpdatingBaseCurrency,
                          onPressed: profileState.isUpdatingBaseCurrency
                              ? null
                              : () async {
                                  final selected = _selectedCode;
                                  if (selected == null || selected == profile.baseCurrency) {
                                    context.pop(profile.baseCurrency);
                                    return;
                                  }
                                  await context.read<ProfileCubit>().updateBaseCurrency(selected);
                                  if (context.mounted &&
                                      context.read<ProfileCubit>().state.failureCode == null) {
                                    context.pop(selected);
                                  }
                                },
                        ),
                        SizedBox(height: spacing.s16),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openBaseCurrencyPaywall(BuildContext context, String code) {
    getIt<AppAnalytics>().log(
      AnalyticsEventName.lockedFeatureTapped,
      parameters: {
        AnalyticsParams.feature: 'base_currency',
        AnalyticsParams.placement: 'currency_picker',
        AnalyticsParams.currency: code,
      },
    );
    context.push(
      AppRoutes.paywall,
      extra: PaywallArgs(reason: PaywallReason.baseCurrency, requestedBaseCurrencyCode: code),
    );
  }
}
