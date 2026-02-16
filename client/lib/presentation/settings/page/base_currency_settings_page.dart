import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_currency_picker.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';
import 'package:asset_tuner/core_ui/components/ds_base_currency_value_card.dart';
import 'package:asset_tuner/core_ui/components/ds_unlock_currencies_card.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_loader.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/paywall/entity/paywall_args.dart';
import 'package:asset_tuner/presentation/settings/bloc/base_currency_settings_cubit.dart';
import 'package:asset_tuner/presentation/utils/supabase_error_message.dart';
import 'package:supabase_error_translator_flutter/supabase_error_translator_flutter.dart';
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
                  context.read<BaseCurrencySettingsCubit>().selectCurrency(
                    requested,
                  );
                }
              }
              break;
          }
        },
        builder: (context, state) {
          final spacing = context.dsSpacing;

          if (state.status == BaseCurrencySettingsStatus.loading) {
            return const Scaffold(body: Center(child: DSLoader()));
          }

          if (state.status == BaseCurrencySettingsStatus.error &&
              state.currencies.isEmpty) {
            return Scaffold(
              appBar: DSAppBar(title: l10n.baseCurrencySettingsTitle),
              body: DSInlineError(
                title: l10n.baseCurrencySettingsLoadErrorTitle,
                message: resolveFailureMessage(
                    context,
                    code: state.loadFailureCode,
                    rawMessage: state.loadFailureMessage,
                    service: ErrorService.database,
                  ),
                actionLabel: l10n.splashRetry,
                onAction: () =>
                    context.read<BaseCurrencySettingsCubit>().load(),
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
                    DSSectionTitle(
                      title: l10n.baseCurrencySettingsCurrentTitle,
                    ),
                    SizedBox(height: spacing.s12),
                    DSBaseCurrencyValueCard(
                      title: l10n.baseCurrencySettingsCurrentTitle,
                      caption: l10n.baseCurrencyConversionCaption,
                      currencyCode: state.currentCode ?? state.selectedCode,
                      codeFallback: l10n.notAvailable,
                    ),
                    SizedBox(height: spacing.s24),
                    DSSectionTitle(title: l10n.baseCurrencySettingsPickerTitle),
                    SizedBox(height: spacing.s12),
                    if (state.bannerType ==
                            BaseCurrencySettingsBannerType.saveFailure &&
                        state.bannerFailureCode != null) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: spacing.s24),
                        child: DSInlineBanner(
                          title: l10n.baseCurrencySettingsTitle,
                          message: state.bannerFailureCode != null
                              ? resolveFailureMessage(
                                  context,
                                  code: state.bannerFailureCode,
                                  rawMessage: state.bannerFailureMessage,
                                  service: ErrorService.database,
                                )
                              : l10n.errorGeneric,
                          variant: DSInlineBannerVariant.danger,
                        ),
                      ),
                      SizedBox(height: spacing.s16),
                    ],
                    if (!(state.entitlements?.anyBaseCurrency ?? false)) ...[
                      DSUnlockCurrenciesCard(
                        title: l10n.baseCurrencySettingsPaywallHint,
                        onTap: () async {
                          final upgraded = await context.push<bool>(
                            AppRoutes.paywall,
                            extra: const PaywallArgs(
                              reason: PaywallReason.baseCurrency,
                            ),
                          );
                          if (context.mounted && upgraded == true) {
                            await context.read<BaseCurrencySettingsCubit>().load();
                          }
                        },
                      ),
                      SizedBox(height: spacing.s16),
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
                      onSelect: (code) => context
                          .read<BaseCurrencySettingsCubit>()
                          .selectCurrency(code),
                    ),
                    Spacer(),
                    DSButton(
                      label: l10n.baseCurrencySettingsSave,
                      fullWidth: true,
                      isLoading: state.isSaving,
                      onPressed: state.isSaving
                          ? null
                          : () => context
                                .read<BaseCurrencySettingsCubit>()
                                .save(),
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
    return state.currencies.map((item) {
      final code = item.code.toUpperCase();
      return DSCurrencyPickerOption(
        id: code,
        primaryText: code,
        secondaryText: item.name,
        tertiaryText: code,
        searchTerms: [item.name, code],
        locked: !item.isUnlocked,
      );
    }).toList();
  }

}
