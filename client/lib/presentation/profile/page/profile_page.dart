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
import 'package:asset_tuner/presentation/profile/widget/profile_language_selector.dart';
import 'package:asset_tuner/presentation/profile/widget/profile_theme_selector.dart';
import 'package:asset_tuner/presentation/settings/widget/settings_row_trailing.dart';

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
                      child: RefreshIndicator(
                        onRefresh: () =>
                            context.read<ProfileCubit>().refresh(),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            child: switch (state.status) {
                              ProfileStatus.loading => Column(
                                    key: const ValueKey('profile_loading'),
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      DSCard(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            DSSkeleton(height: 26),
                                            SizedBox(height: spacing.s12),
                                            DSSkeleton(height: 18),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: spacing.s24),
                                      DSSkeleton(height: 20),
                                      SizedBox(height: spacing.s12),
                                      DSSkeleton(height: 80),
                                      SizedBox(height: spacing.s12),
                                      DSSkeleton(height: 80),
                                    ],
                                  ),
                              ProfileStatus.error => Column(
                                    key: const ValueKey('profile_error'),
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      DSInlineError(
                                        title: l10n.splashErrorTitle,
                                        message: l10n.errorGeneric,
                                        actionLabel: l10n.splashRetry,
                                        onAction: () => context
                                            .read<ProfileCubit>()
                                            .load(),
                                      ),
                                    ],
                                  ),
                              ProfileStatus.ready => _ProfileReadyContent(
                                    key: const ValueKey('profile_ready'),
                                    state: state,
                                    l10n: l10n,
                                    onManageSubscriptionTap: () async {
                                      final result = await context.push<
                                          String>(
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
                                            .refresh();
                                      }
                                    },
                                    onBaseCurrencyTap: () async {
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
                                              .refresh();
                                        }
                                      },
                                    onArchivedTap: () => context
                                        .push(AppRoutes.archivedAccounts),
                                    onAccountActionsTap: () => context
                                        .push(AppRoutes.accountActions),
                                  ),
                            },
                          ),
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

}

class _ProfileReadyContent extends StatelessWidget {
  const _ProfileReadyContent({
    super.key,
    required this.state,
    required this.l10n,
    this.onManageSubscriptionTap,
    required this.onBaseCurrencyTap,
    required this.onArchivedTap,
    required this.onAccountActionsTap,
  });

  final ProfileState state;
  final AppLocalizations l10n;
  final VoidCallback? onManageSubscriptionTap;
  final VoidCallback onBaseCurrencyTap;
  final VoidCallback onArchivedTap;
  final VoidCallback onAccountActionsTap;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileHeaderCard(
          email: state.email ?? l10n.notAvailable,
          planLabel: (state.plan ?? 'free') == 'paid'
              ? l10n.settingsPlanPaid
              : l10n.settingsPlanFree,
          baseCurrency: state.baseCurrency ?? l10n.notAvailable,
          isPaid: (state.plan ?? 'free') == 'paid',
          onManageSubscriptionTap: onManageSubscriptionTap,
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
                trailing: SettingsRowTrailing(
                  value: state.baseCurrency ?? l10n.notAvailable,
                ),
                showDivider: true,
                onTap: onBaseCurrencyTap,
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
            onTap: onArchivedTap,
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
            trailing: Icon(
              Icons.chevron_right,
              color: context.dsColors.textTertiary,
            ),
            onTap: onAccountActionsTap,
          ),
        ),
      ],
    );
  }
}
