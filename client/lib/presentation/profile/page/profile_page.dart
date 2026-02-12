import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_list_row.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/components/ds_skeleton.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/profile/bloc/profile_cubit.dart';
import 'package:asset_tuner/presentation/profile/widget/profile_header_card.dart';
import 'package:asset_tuner/presentation/settings/widget/settings_row_trailing.dart';
import 'package:asset_tuner/core/localization/locale_cubit.dart';
import 'package:asset_tuner/core_ui/theme/theme_mode_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..load(),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          final navigation = state.navigation;
          if (navigation == null) {
            return;
          }
          context.read<ProfileCubit>().consumeNavigation();
          switch (navigation.destination) {
            case ProfileDestination.signIn:
              context.go(AppRoutes.signIn);
              break;
          }
        },
        builder: (context, state) {
          final spacing = context.dsSpacing;

          final bannerText = _bannerText(l10n, state.failureCode);

          return Scaffold(
            appBar: DSAppBar(title: l10n.profileTitle),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(spacing.s24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (bannerText != null) ...[
                      DSInlineBanner(
                        title: l10n.profileTitle,
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
                            switch (state.status) {
                              ProfileStatus.loading => DSCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    DSSkeleton(height: 26),
                                    SizedBox(height: spacing.s12),
                                    DSSkeleton(height: 18),
                                  ],
                                ),
                              ),
                              ProfileStatus.error => DSInlineError(
                                title: l10n.splashErrorTitle,
                                message: l10n.errorGeneric,
                                actionLabel: l10n.splashRetry,
                                onAction: () =>
                                    context.read<ProfileCubit>().load(),
                              ),
                              ProfileStatus.ready => ProfileHeaderCard(
                                email: state.email ?? l10n.notAvailable,
                                planLabel: (state.plan ?? 'free') == 'paid'
                                    ? l10n.settingsPlanPaid
                                    : l10n.settingsPlanFree,
                                baseCurrency:
                                    state.baseCurrency ?? l10n.notAvailable,
                              ),
                            },
                            SizedBox(height: spacing.s24),
                            DSSectionTitle(
                              title: l10n.profileSectionPreferences,
                            ),
                            SizedBox(height: spacing.s12),
                            DSCard(
                              padding: EdgeInsets.zero,
                              child: switch (state.status) {
                                ProfileStatus.loading => Padding(
                                  padding: EdgeInsets.all(spacing.s16),
                                  child: Column(
                                    children: [
                                      DSSkeleton(height: 20),
                                      SizedBox(height: spacing.s12),
                                      DSSkeleton(height: 20),
                                    ],
                                  ),
                                ),
                                ProfileStatus.error => DSInlineError(
                                  title: l10n.splashErrorTitle,
                                  message: l10n.errorGeneric,
                                  actionLabel: l10n.splashRetry,
                                  onAction: () =>
                                      context.read<ProfileCubit>().load(),
                                ),
                                ProfileStatus.ready => Column(
                                  children: [
                                    DSListRow(
                                      title: l10n.settingsBaseCurrency,
                                      trailing: SettingsRowTrailing(
                                        value:
                                            state.baseCurrency ??
                                            l10n.notAvailable,
                                      ),
                                      showDivider: true,
                                      onTap: () async {
                                        final result = await context
                                            .push<String>(
                                              AppRoutes.baseCurrencySettings,
                                            );
                                        if (context.mounted) {
                                          if (result != null) {
                                            context
                                                .read<ProfileCubit>()
                                                .setBaseCurrency(result);
                                          }
                                          await context
                                              .read<ProfileCubit>()
                                              .load();
                                        }
                                      },
                                    ),
                                    DSListRow(
                                      title: l10n.profileLanguage,
                                      leading: Icon(
                                        Icons.language,
                                        color: context.dsColors.textTertiary,
                                      ),
                                      trailing: SettingsRowTrailing(
                                        value: _languageLabel(
                                          l10n,
                                          context
                                              .watch<LocaleCubit>()
                                              .state
                                              .localeTag,
                                        ),
                                      ),
                                      showDivider: true,
                                      onTap: () async {
                                        await context.push(AppRoutes.language);
                                        if (context.mounted) {
                                          await context
                                              .read<ProfileCubit>()
                                              .load();
                                        }
                                      },
                                    ),
                                    DSListRow(
                                      title: l10n.profileTheme,
                                      leading: Icon(
                                        Icons.palette_outlined,
                                        color: context.dsColors.textTertiary,
                                      ),
                                      trailing: SettingsRowTrailing(
                                        value: _themeLabel(
                                          l10n,
                                          context.watch<ThemeModeCubit>().state,
                                        ),
                                      ),
                                      onTap: () async {
                                        await context.push(AppRoutes.theme);
                                        if (context.mounted) {
                                          await context
                                              .read<ProfileCubit>()
                                              .load();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              },
                            ),
                            SizedBox(height: spacing.s24),
                            DSSectionTitle(title: l10n.profileSectionPortfolio),
                            SizedBox(height: spacing.s12),
                            DSCard(
                              padding: EdgeInsets.zero,
                              child: DSListRow(
                                title: l10n.profileAccounts,
                                leading: Icon(
                                  Icons.account_balance_outlined,
                                  color: context.dsColors.textTertiary,
                                ),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: context.dsColors.textTertiary,
                                ),
                                onTap: () => context.push(AppRoutes.main),
                              ),
                            ),
                            SizedBox(height: spacing.s24),
                            DSSectionTitle(
                              title: l10n.settingsSectionSubscription,
                            ),
                            SizedBox(height: spacing.s12),
                            DSCard(
                              padding: EdgeInsets.zero,
                              child: switch (state.status) {
                                ProfileStatus.loading => Padding(
                                  padding: EdgeInsets.all(spacing.s16),
                                  child: Column(
                                    children: [
                                      DSSkeleton(height: 20),
                                      SizedBox(height: spacing.s12),
                                      DSSkeleton(height: 20),
                                    ],
                                  ),
                                ),
                                ProfileStatus.error => DSInlineError(
                                  title: l10n.splashErrorTitle,
                                  message: l10n.errorGeneric,
                                  actionLabel: l10n.splashRetry,
                                  onAction: () =>
                                      context.read<ProfileCubit>().load(),
                                ),
                                ProfileStatus.ready => Column(
                                  children: [
                                    DSListRow(
                                      title: l10n.settingsPlanStatus,
                                      trailing: Text(
                                        (state.plan ?? 'free') == 'paid'
                                            ? l10n.settingsPlanPaid
                                            : l10n.settingsPlanFree,
                                      ),
                                      showDivider: true,
                                    ),
                                    DSListRow(
                                      title: l10n.settingsManageSubscription,
                                      trailing: Icon(
                                        Icons.chevron_right,
                                        color: context.dsColors.textTertiary,
                                      ),
                                      onTap: () async {
                                        final result = await context
                                            .push<String>(
                                              AppRoutes.manageSubscription,
                                            );
                                        if (context.mounted) {
                                          if (result != null) {
                                            context
                                                .read<ProfileCubit>()
                                                .setPlan(result);
                                          }
                                          await context
                                              .read<ProfileCubit>()
                                              .load();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              },
                            ),
                            SizedBox(height: spacing.s24),
                            DSSectionTitle(title: l10n.profileSectionAccount),
                            SizedBox(height: spacing.s12),
                            DSCard(
                              padding: EdgeInsets.zero,
                              child: DSListRow(
                                title: l10n.profileAccountActionsTitle,
                                subtitle: l10n.profileAccountActionsSubtitle,
                                leading: Icon(
                                  Icons.security_outlined,
                                  color: context.dsColors.textTertiary,
                                ),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: context.dsColors.textTertiary,
                                ),
                                onTap: () =>
                                    context.push(AppRoutes.accountActions),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  String? _bannerText(AppLocalizations l10n, String? code) {
    if (code == null) {
      return null;
    }
    return switch (code) {
      'entitlements' => l10n.settingsEntitlementsError,
      _ => null,
    };
  }

  String _languageLabel(AppLocalizations l10n, String? localeTag) {
    return switch (localeTag) {
      null => l10n.profileLanguageSystem,
      'en' => l10n.profileLanguageEnglish,
      'ru' => l10n.profileLanguageRussian,
      _ => l10n.profileLanguageSystem,
    };
  }

  String _themeLabel(AppLocalizations l10n, ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => l10n.profileThemeSystem,
      ThemeMode.light => l10n.profileThemeLight,
      ThemeMode.dark => l10n.profileThemeDark,
    };
  }
}
