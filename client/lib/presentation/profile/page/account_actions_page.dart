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
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/profile/bloc/profile_cubit.dart';

class AccountActionsPage extends StatelessWidget {
  const AccountActionsPage({super.key});

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
          final typography = context.dsTypography;
          final colors = context.dsColors;
          final radius = context.dsRadius;

          final bannerText = _bannerText(l10n, state.failureCode, state.failureMessage);

          return Scaffold(
            appBar: DSAppBar(title: l10n.profileSectionAccount),
            body: SafeArea(
              child: state.status == ProfileStatus.error
                  ? Padding(
                      padding: EdgeInsets.all(spacing.s24),
                      child: DSInlineError(
                        title: l10n.splashErrorTitle,
                        message: l10n.errorGeneric,
                        actionLabel: l10n.splashRetry,
                        onAction: () => context.read<ProfileCubit>().load(),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => context.read<ProfileCubit>().refresh(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.all(spacing.s24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (bannerText != null) ...[
                              DSInlineBanner(
                                title: l10n.profileSectionAccount,
                                message: bannerText,
                                variant: DSInlineBannerVariant.danger,
                              ),
                              SizedBox(height: spacing.s16),
                            ],
                            DSSectionTitle(title: l10n.settingsSignOut),
                            SizedBox(height: spacing.s12),
                            DSCard(
                              child: DSButton(
                                    label: l10n.settingsSignOut,
                                    variant: DSButtonVariant.secondary,
                                    fullWidth: true,
                                    isLoading: state.isSigningOut,
                                    onPressed: state.isSigningOut
                                        ? null
                                        : () => context
                                            .read<ProfileCubit>()
                                            .signOut(),
                                  ),
                            ),
                            SizedBox(height: spacing.s24),
                            DSSectionTitle(
                              title: l10n.profileDeleteAccountTitle,
                            ),
                            SizedBox(height: spacing.s12),
                            DSCard(
                              padding: EdgeInsets.zero,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(radius.r12),
                                  border: Border.all(
                                    color: colors.danger.withValues(alpha: 0.45),
                                  ),
                                ),
                                padding: EdgeInsets.all(spacing.s16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.profileDeleteAccountBody,
                                      style: typography.body.copyWith(
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                    SizedBox(height: spacing.s16),
                                    DSButton(
                                      label: l10n.profileDeleteAccountCta,
                                      variant: DSButtonVariant.danger,
                                      fullWidth: true,
                                      isLoading: state.isDeletingAccount,
                                      onPressed: state.isDeletingAccount
                                          ? null
                                          : () => context
                                              .read<ProfileCubit>()
                                              .confirmDelete(context),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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
      _ => l10n.errorGeneric,
    };
  }
}
