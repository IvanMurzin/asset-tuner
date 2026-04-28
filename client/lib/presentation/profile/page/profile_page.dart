import 'package:asset_tuner/core/analytics/app_analytics.dart';
import 'package:asset_tuner/core/config/app_config.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core/utils/external_url_launcher.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_dialog.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_list_row.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/components/ds_skeleton.dart';
import 'package:asset_tuner/core_ui/components/ds_snackbar.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/asset/bloc/assets_cubit.dart';
import 'package:asset_tuner/presentation/profile/bloc/profile_cubit.dart';
import 'package:asset_tuner/presentation/profile/widget/profile_header_card.dart';
import 'package:asset_tuner/presentation/profile/widget/profile_language_selector.dart';
import 'package:asset_tuner/presentation/profile/widget/profile_theme_selector.dart';
import 'package:asset_tuner/presentation/session/bloc/session_cubit.dart';
import 'package:asset_tuner/presentation/settings/widget/settings_row_trailing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<SessionCubit, SessionState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status ||
          (curr.failureCode != null && curr.failureCode != prev.failureCode),
      listener: (context, state) {
        if (state.status == SessionStatus.unauthenticated) {
          context.go(AppRoutes.signIn);
          return;
        }
        if (state.failureCode != null) {
          showDSSnackBar(
            context,
            variant: DSSnackBarVariant.error,
            message: state.failureMessage ?? l10n.errorGeneric,
          );
        }
      },
      child: BlocBuilder<SessionCubit, SessionState>(
        builder: (context, sessionState) {
          return BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
              final spacing = context.dsSpacing;

              if (!sessionState.isAuthenticated) {
                return Scaffold(
                  appBar: DSAppBar(title: l10n.profileTitle),
                  body: DSInlineError(
                    title: l10n.splashErrorTitle,
                    message: l10n.errorGeneric,
                    actionLabel: l10n.splashRetry,
                    onAction: () => context.go(AppRoutes.signIn),
                  ),
                );
              }

              if ((profileState.status == ProfileStatus.initial ||
                      profileState.status == ProfileStatus.loading) &&
                  profileState.profile == null) {
                return Scaffold(
                  appBar: DSAppBar(title: l10n.profileTitle),
                  body: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(spacing.s24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DSCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const DSSkeleton(height: 26),
                                SizedBox(height: spacing.s12),
                                const DSSkeleton(height: 18),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              if (profileState.status == ProfileStatus.error && profileState.profile == null) {
                return Scaffold(
                  appBar: DSAppBar(title: l10n.profileTitle),
                  body: DSInlineError(
                    title: l10n.splashErrorTitle,
                    message: profileState.failureMessage ?? l10n.errorGeneric,
                    actionLabel: l10n.splashRetry,
                    onAction: () => context.read<ProfileCubit>().refresh(),
                  ),
                );
              }

              final profile = profileState.profile!;
              final session = sessionState.session!;
              final isBusy = sessionState.isBusy;

              return Scaffold(
                appBar: DSAppBar(title: l10n.profileTitle),
                body: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(spacing.s24),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await context.read<ProfileCubit>().refresh(silent: true);
                        if (!context.mounted) {
                          return;
                        }
                        await context.read<ProfileCubit>().syncSubscription(
                          silent: true,
                          force: true,
                        );
                        if (!context.mounted) {
                          return;
                        }
                        await context.read<AssetsCubit>().refresh(silent: true, forceRefresh: true);
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          ProfileHeaderCard(
                            email: session.email,
                            planLabel: profile.plan == 'pro'
                                ? l10n.settingsPlanPaid
                                : l10n.settingsPlanFree,
                            baseCurrency: profile.baseCurrency,
                            isPaid: profile.plan == 'pro',
                            onPlanActionTap: () async {
                              if (profile.plan == 'pro') {
                                getIt<AppAnalytics>().log(
                                  AnalyticsEventName.manageSubscriptionOpened,
                                  parameters: {AnalyticsParams.placement: 'profile_header'},
                                );
                                await context.push(AppRoutes.manageSubscription);
                              } else {
                                getIt<AppAnalytics>().log(
                                  AnalyticsEventName.lockedFeatureTapped,
                                  parameters: {
                                    AnalyticsParams.feature: 'upgrade_plan',
                                    AnalyticsParams.placement: 'profile_header',
                                  },
                                );
                                await context.push(AppRoutes.paywall);
                              }
                              if (context.mounted) {
                                await context.read<ProfileCubit>().syncSubscription(
                                  silent: true,
                                  force: true,
                                  placement: 'profile_return',
                                );
                              }
                            },
                            planActionLabel: profile.plan == 'pro'
                                ? l10n.settingsManageSubscription
                                : l10n.profileUpgradePlan,
                          ),
                          SizedBox(height: spacing.s24),
                          DSSectionTitle(title: l10n.profileSectionPreferences),
                          SizedBox(height: spacing.s12),
                          DSCard(
                            padding: EdgeInsets.zero,
                            child: Column(
                              children: [
                                DSListRow(
                                  title: l10n.settingsBaseCurrency,
                                  trailing: SettingsRowTrailing(value: profile.baseCurrency),
                                  showDivider: true,
                                  onTap: () => context.push(AppRoutes.baseCurrencySettings),
                                ),
                                const ProfileLanguageSelector(),
                                const ProfileThemeSelector(),
                              ],
                            ),
                          ),
                          SizedBox(height: spacing.s24),
                          DSSectionTitle(title: l10n.settingsArchivedAccounts),
                          SizedBox(height: spacing.s12),
                          DSCard(
                            padding: EdgeInsets.zero,
                            child: DSListRow(
                              title: l10n.settingsArchivedAccounts,
                              leading: Icon(
                                Icons.archive_outlined,
                                color: context.dsColors.textTertiary,
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                color: context.dsColors.textTertiary,
                              ),
                              onTap: () => context.push(AppRoutes.archivedAccounts),
                            ),
                          ),
                          SizedBox(height: spacing.s24),
                          DSSectionTitle(title: l10n.profileSectionSupport),
                          SizedBox(height: spacing.s12),
                          DSCard(
                            padding: EdgeInsets.zero,
                            child: DSListRow(
                              title: l10n.profileContactDeveloperAction,
                              leading: Icon(
                                Icons.support_agent_outlined,
                                color: context.dsColors.textTertiary,
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                color: context.dsColors.textTertiary,
                              ),
                              onTap: () async {
                                final result = await context.push(AppRoutes.contactDeveloper);
                                if (!context.mounted || result != true) {
                                  return;
                                }
                                showDSSnackBar(
                                  context,
                                  variant: DSSnackBarVariant.success,
                                  message: l10n.profileContactDeveloperSuccess,
                                );
                              },
                            ),
                          ),
                          SizedBox(height: spacing.s24),
                          DSSectionTitle(title: l10n.profileSectionLegal),
                          SizedBox(height: spacing.s12),
                          DSCard(
                            padding: EdgeInsets.zero,
                            child: Column(
                              children: [
                                DSListRow(
                                  title: l10n.profileLegalTermsOfUse,
                                  leading: Icon(
                                    Icons.description_outlined,
                                    color: context.dsColors.textTertiary,
                                  ),
                                  trailing: Icon(
                                    Icons.chevron_right,
                                    color: context.dsColors.textTertiary,
                                  ),
                                  showDivider: true,
                                  onTap: () =>
                                      _openLegalUrl(context, AppConfig.instance.termsOfUseUrl),
                                ),
                                DSListRow(
                                  title: l10n.profileLegalPrivacyPolicy,
                                  leading: Icon(
                                    Icons.privacy_tip_outlined,
                                    color: context.dsColors.textTertiary,
                                  ),
                                  trailing: Icon(
                                    Icons.chevron_right,
                                    color: context.dsColors.textTertiary,
                                  ),
                                  onTap: () =>
                                      _openLegalUrl(context, AppConfig.instance.privacyPolicyUrl),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: spacing.s24),
                          DSSectionTitle(title: l10n.profileSectionAccount),
                          SizedBox(height: spacing.s16),
                          DSButton(
                            label: l10n.settingsSignOut,
                            variant: DSButtonVariant.secondary,
                            fullWidth: true,
                            isLoading: sessionState.isSigningOut,
                            onPressed: isBusy ? null : () => _confirmSignOut(context, l10n),
                          ),
                          SizedBox(height: spacing.s16),
                          DSButton(
                            label: l10n.profileDeleteAccountCta,
                            variant: DSButtonVariant.secondary,
                            fullWidth: true,
                            isLoading: sessionState.isDeletingAccount,
                            onPressed: isBusy ? null : () => _confirmDelete(context, l10n),
                          ),
                          SizedBox(height: spacing.s12),
                          Text(
                            l10n.profileDeleteAccountBody,
                            style: context.dsTypography.caption.copyWith(
                              color: context.dsColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
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

  Future<void> _confirmSignOut(BuildContext context, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => DSDialog(
        title: l10n.profileSignOutConfirmTitle,
        content: Text(l10n.profileSignOutConfirmBody),
        primaryLabel: l10n.profileSignOutConfirmCta,
        secondaryLabel: l10n.cancel,
        onSecondary: () => Navigator.of(dialogContext).pop(false),
        onPrimary: () => Navigator.of(dialogContext).pop(true),
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<SessionCubit>().signOut();
    }
  }

  Future<void> _confirmDelete(BuildContext context, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => DSDialog(
        title: l10n.profileDeleteConfirmTitle,
        content: Text(l10n.profileDeleteConfirmBody),
        primaryLabel: l10n.profileDeleteConfirmCta,
        secondaryLabel: l10n.profileDeleteConfirmCancel,
        isDestructive: true,
        onSecondary: () => Navigator.of(dialogContext).pop(false),
        onPrimary: () => Navigator.of(dialogContext).pop(true),
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<SessionCubit>().deleteAccount();
    }
  }

  Future<void> _openLegalUrl(BuildContext context, String url) async {
    final l10n = AppLocalizations.of(context)!;
    await launchExternalUrl(context, url: url, errorMessage: l10n.errorGeneric);
  }
}
