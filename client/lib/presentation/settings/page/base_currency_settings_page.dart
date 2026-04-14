import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_base_currency_value_card.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_currency_picker.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/components/ds_unlock_currencies_card.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/asset/bloc/assets_cubit.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_args.dart';
import 'package:asset_tuner/presentation/profile/bloc/profile_cubit.dart';
import 'package:asset_tuner/presentation/session/bloc/session_cubit.dart';

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

    return BlocListener<SessionCubit, SessionState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == SessionStatus.unauthenticated) {
          context.go(AppRoutes.signIn);
        }
      },
      child: BlocBuilder<SessionCubit, SessionState>(
        builder: (context, sessionState) {
          return BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
              if (!sessionState.isAuthenticated) {
                return Scaffold(
                  appBar: DSAppBar(title: l10n.baseCurrencySettingsTitle),
                  body: DSInlineError(
                    title: l10n.splashErrorTitle,
                    message: l10n.errorGeneric,
                    actionLabel: l10n.splashRetry,
                    onAction: () => context.read<SessionCubit>().bootstrap(),
                  ),
                );
              }

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

                  final fiatAssets = assetsState.fiatAssets;
                  final options = [
                    for (final asset in fiatAssets)
                      DSCurrencyPickerOption(
                        id: asset.code.toUpperCase(),
                        primaryText: asset.code.toUpperCase(),
                        secondaryText: asset.name,
                        tertiaryText: asset.code.toUpperCase(),
                        searchTerms: [asset.code, asset.name],
                        locked: asset.isLocked ?? false,
                      ),
                  ];

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
                            DSBaseCurrencyValueCard(
                              title: l10n.baseCurrencySettingsCurrentTitle,
                              caption: l10n.baseCurrencyConversionCaption,
                              currencyCode: profile.baseCurrency,
                              codeFallback: l10n.notAvailable,
                            ),
                            SizedBox(height: spacing.s24),
                            DSSectionTitle(title: l10n.baseCurrencySettingsPickerTitle),
                            SizedBox(height: spacing.s12),
                            if (!(profile.entitlements.anyBaseCurrency) &&
                                profile.plan != 'pro') ...[
                              DSUnlockCurrenciesCard(
                                title: l10n.baseCurrencySettingsPaywallHint,
                                onTap: () => context.push(
                                  AppRoutes.paywall,
                                  extra: const PaywallArgs(reason: PaywallReason.baseCurrency),
                                ),
                              ),
                              SizedBox(height: spacing.s16),
                            ],
                            DSCurrencyPicker(
                              options: options,
                              selectedId: _selectedCode?.toUpperCase(),
                              searchHintText: l10n.baseCurrencySettingsSearchHint,
                              recentTitleText: l10n.currencyPickerRecentTitle,
                              selectedTitleText: l10n.currencyPickerSelectedTitle,
                              changeSelectionText: l10n.currencyPickerChangeAction,
                              emptyResultsTitle: l10n.currencyPickerNoResultsTitle,
                              emptyResultsMessage: l10n.currencyPickerNoResultsBody,
                              enabled: !profileState.isUpdatingBaseCurrency,
                              onSelect: (code) {
                                final matched = fiatAssets
                                    .where(
                                      (asset) => asset.code.toUpperCase() == code.toUpperCase(),
                                    )
                                    .firstOrNull;
                                if (matched == null) {
                                  return;
                                }
                                if ((matched.isLocked ?? false) &&
                                    !profile.entitlements.anyBaseCurrency) {
                                  context.push(
                                    AppRoutes.paywall,
                                    extra: PaywallArgs(
                                      reason: PaywallReason.baseCurrency,
                                      requestedBaseCurrencyCode: matched.code,
                                    ),
                                  );
                                  return;
                                }
                                setState(() => _selectedCode = matched.code.toUpperCase());
                              },
                            ),
                            if (profileState.failureCode != null) ...[
                              SizedBox(height: spacing.s16),
                              DSInlineBanner(
                                title: l10n.baseCurrencySettingsTitle,
                                message: profileState.failureMessage ?? l10n.errorGeneric,
                                variant: DSInlineBannerVariant.danger,
                              ),
                            ],
                            const Spacer(),
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
                                      await context.read<ProfileCubit>().updateBaseCurrency(
                                        selected,
                                      );
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
          );
        },
      ),
    );
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
