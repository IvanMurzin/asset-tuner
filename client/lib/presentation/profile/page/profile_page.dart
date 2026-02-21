import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_list_row.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/components/ds_skeleton.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/asset/bloc/assets_cubit.dart';
import 'package:asset_tuner/presentation/profile/widget/profile_header_card.dart';
import 'package:asset_tuner/presentation/profile/widget/profile_language_selector.dart';
import 'package:asset_tuner/presentation/profile/widget/profile_theme_selector.dart';
import 'package:asset_tuner/presentation/settings/widget/settings_row_trailing.dart';
import 'package:asset_tuner/presentation/user/bloc/user_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        final spacing = context.dsSpacing;

        if (state.status == UserStatus.loading || state.status == UserStatus.initial) {
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

        if (state.status == UserStatus.error) {
          return Scaffold(
            appBar: DSAppBar(title: l10n.profileTitle),
            body: DSInlineError(
              title: l10n.splashErrorTitle,
              message: state.failureMessage ?? l10n.errorGeneric,
              actionLabel: l10n.splashRetry,
              onAction: context.read<UserCubit>().bootstrap,
            ),
          );
        }

        if (!state.isAuthenticated) {
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

        final profile = state.profile!;
        final session = state.session!;

        return Scaffold(
          appBar: DSAppBar(title: l10n.profileTitle),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(spacing.s24),
              child: RefreshIndicator(
                onRefresh: () async {
                  await context.read<UserCubit>().refresh(silent: true);
                  if (!context.mounted) {
                    return;
                  }
                  await context.read<AssetsCubit>().refresh(silent: true);
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
                          await context.push(AppRoutes.manageSubscription);
                        } else {
                          await context.push(AppRoutes.paywall);
                        }
                        if (context.mounted) {
                          await context.read<UserCubit>().refresh(silent: true);
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
                        leading: Icon(Icons.archive_outlined, color: context.dsColors.textTertiary),
                        trailing: Icon(Icons.chevron_right, color: context.dsColors.textTertiary),
                        onTap: () => context.push(AppRoutes.archivedAccounts),
                      ),
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
                        trailing: Icon(Icons.chevron_right, color: context.dsColors.textTertiary),
                        onTap: () => context.push(AppRoutes.accountActions),
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
  }
}
