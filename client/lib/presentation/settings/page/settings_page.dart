import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_list_row.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/components/ds_skeleton.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/settings/bloc/settings_cubit.dart';
import 'package:asset_tuner/presentation/settings/widget/settings_row_trailing.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<SettingsCubit>()..load(),
      child: BlocConsumer<SettingsCubit, SettingsState>(
        listener: (context, state) {
          final navigation = state.navigation;
          if (navigation == null) {
            return;
          }
          context.read<SettingsCubit>().consumeNavigation();
          switch (navigation.destination) {
            case SettingsDestination.signIn:
              context.go(AppRoutes.signIn);
          }
        },
        builder: (context, state) {
          final spacing = context.dsSpacing;
          final typography = context.dsTypography;
          final colors = context.dsColors;

          final bannerText = _bannerText(l10n, state.failureCode, state.failureMessage);

          return Scaffold(
            appBar: DSAppBar(title: l10n.settingsTitle),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(spacing.s24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (bannerText != null) ...[
                      DSInlineBanner(
                        title: l10n.settingsTitle,
                        message: bannerText,
                        variant: DSInlineBannerVariant.danger,
                      ),
                      SizedBox(height: spacing.s16),
                    ],
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DSSectionTitle(
                              title: l10n.settingsSectionPreferences,
                            ),
                            SizedBox(height: spacing.s12),
                            DSCard(
                              padding: EdgeInsets.zero,
                              child: switch (state.status) {
                                SettingsStatus.loading => Padding(
                                  padding: EdgeInsets.all(spacing.s16),
                                  child: Column(
                                    children: [
                                      DSSkeleton(height: 20),
                                      SizedBox(height: spacing.s12),
                                      DSSkeleton(height: 20),
                                    ],
                                  ),
                                ),
                                SettingsStatus.error => DSInlineError(
                                  title: l10n.splashErrorTitle,
                                  message: l10n.errorGeneric,
                                  actionLabel: l10n.splashRetry,
                                  onAction: () =>
                                      context.read<SettingsCubit>().load(),
                                ),
                                SettingsStatus.ready => Column(
                                  children: [
                                    DSListRow(
                                      title: l10n.settingsBaseCurrency,
                                      trailing: SettingsRowTrailing(
                                        value:
                                            state.baseCurrency ??
                                            l10n.notAvailable,
                                      ),
                                      onTap: () => context.push(
                                        AppRoutes.baseCurrencySettings,
                                      ),
                                    ),
                                  ],
                                ),
                              },
                            ),
                            SizedBox(height: spacing.s24),
                            DSSectionTitle(
                              title: l10n.settingsSectionSubscription,
                            ),
                            SizedBox(height: spacing.s12),
                            DSCard(
                              padding: EdgeInsets.zero,
                              child: switch (state.status) {
                                SettingsStatus.loading => Padding(
                                  padding: EdgeInsets.all(spacing.s16),
                                  child: Column(
                                    children: [
                                      DSSkeleton(height: 20),
                                      SizedBox(height: spacing.s12),
                                      DSSkeleton(height: 20),
                                    ],
                                  ),
                                ),
                                SettingsStatus.error => DSInlineError(
                                  title: l10n.splashErrorTitle,
                                  message: l10n.errorGeneric,
                                  actionLabel: l10n.splashRetry,
                                  onAction: () =>
                                      context.read<SettingsCubit>().load(),
                                ),
                                SettingsStatus.ready => Column(
                                  children: [
                                    DSListRow(
                                      title: l10n.settingsPlanStatus,
                                      trailing: Text(
                                        (state.plan ?? 'free') == 'paid'
                                            ? l10n.settingsPlanPaid
                                            : l10n.settingsPlanFree,
                                        style: typography.body.copyWith(
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                      showDivider: true,
                                    ),
                                    DSListRow(
                                      title: l10n.settingsManageSubscription,
                                      trailing: Icon(
                                        Icons.chevron_right,
                                        color: colors.textTertiary,
                                      ),
                                      onTap: () => context.push(
                                        AppRoutes.manageSubscription,
                                      ),
                                    ),
                                  ],
                                ),
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: spacing.s16),
                    DSButton(
                      label: l10n.settingsSignOut,
                      variant: DSButtonVariant.secondary,
                      fullWidth: true,
                      isLoading: state.isSigningOut,
                      onPressed: state.isSigningOut
                          ? null
                          : () => context.read<SettingsCubit>().signOut(),
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

  String? _bannerText(AppLocalizations l10n, String? code, String? message) {
    if (code == null) return null;
    if (message != null && message.trim().isNotEmpty) return message.trim();
    return switch (code) {
      'entitlements' => l10n.settingsEntitlementsError,
      _ => null,
    };
  }
}
