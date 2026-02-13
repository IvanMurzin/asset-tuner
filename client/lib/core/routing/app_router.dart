import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_page_transitions.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core/routing/route_extra_args.dart';
import 'package:asset_tuner/core_ui/preview/ds_preview_page.dart';
import 'package:asset_tuner/presentation/account/page/account_detail_page.dart';
import 'package:asset_tuner/presentation/balance/bloc/asset_position_detail_cubit.dart';
import 'package:asset_tuner/presentation/account/page/account_form_page.dart';
import 'package:asset_tuner/presentation/account/page/add_asset_page.dart';
import 'package:asset_tuner/presentation/analytics/page/analytics_page.dart';
import 'package:asset_tuner/presentation/auth/page/otp_page.dart';
import 'package:asset_tuner/presentation/auth/page/sign_in_page.dart';
import 'package:asset_tuner/presentation/auth/page/sign_up_page.dart';
import 'package:asset_tuner/presentation/auth/page/splash_page.dart';
import 'package:asset_tuner/presentation/balance/page/add_balance_page.dart';
import 'package:asset_tuner/presentation/balance/page/asset_position_detail_page.dart';
import 'package:asset_tuner/presentation/home/page/main_shell_page.dart';
import 'package:asset_tuner/presentation/onboarding/page/base_currency_page.dart';
import 'package:asset_tuner/presentation/overview/page/overview_page.dart';
import 'package:asset_tuner/presentation/paywall/entity/paywall_args.dart';
import 'package:asset_tuner/presentation/paywall/page/paywall_page.dart';
import 'package:asset_tuner/presentation/profile/page/account_actions_page.dart';
import 'package:asset_tuner/presentation/profile/page/profile_page.dart';
import 'package:asset_tuner/presentation/profile/page/archived_accounts_page.dart';
import 'package:asset_tuner/presentation/settings/page/base_currency_settings_page.dart';
import 'package:asset_tuner/presentation/settings/page/manage_subscription_page.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.designSystem,
      builder: (context, state) => const DSPreviewPage(),
    ),
    GoRoute(
      path: AppRoutes.signIn,
      builder: (context, state) => const SignInPage(),
    ),
    GoRoute(
      path: AppRoutes.signUp,
      builder: (context, state) => const SignUpPage(),
    ),
    GoRoute(path: AppRoutes.otp, builder: (context, state) => const OtpPage()),
    GoRoute(
      path: AppRoutes.onboardingBaseCurrency,
      builder: (context, state) => const BaseCurrencyPage(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShellPage(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.main,
              builder: (context, state) => const OverviewPage(),
              routes: [
                GoRoute(
                  path: 'accounts/new',
                  pageBuilder: (context, state) => slideTransition(
                    context,
                    state,
                    const AccountFormPage(),
                  ),
                ),
                GoRoute(
                  path: 'accounts/:id',
                  pageBuilder: (context, state) {
                    final id = state.pathParameters['id']!;
                    final extra = state.extra is AccountDetailExtra
                        ? state.extra as AccountDetailExtra
                        : null;
                    return slideTransition(
                      context,
                      state,
                      AccountDetailPage(
                        accountId: id,
                        initialTitle: extra?.initialTitle,
                        initialAccountType: extra?.initialAccountType,
                      ),
                    );
                  },
                  routes: [
                    GoRoute(
                      path: 'edit',
                      pageBuilder: (context, state) => slideTransition(
                        context,
                        state,
                        AccountFormPage(
                          accountId: state.pathParameters['id'],
                        ),
                      ),
                    ),
                    GoRoute(
                      path: 'subaccounts/new',
                      pageBuilder: (context, state) => slideTransition(
                        context,
                        state,
                        AddAssetPage(
                          accountId: state.pathParameters['id']!,
                        ),
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'subaccounts/:id',
                  pageBuilder: (context, state) {
                    final id = state.pathParameters['id']!;
                    final extra = state.extra is SubaccountDetailExtra
                        ? state.extra as SubaccountDetailExtra
                        : null;
                    return slideTransition(
                      context,
                      state,
                      BlocProvider(
                        create: (_) =>
                            getIt<AssetPositionDetailCubit>()..load(subaccountId: id),
                        child: AssetPositionDetailPage(
                          subaccountId: id,
                          initialTitle: extra?.initialTitle,
                        ),
                      ),
                    );
                  },
                  routes: [
                    GoRoute(
                      path: 'update-balance',
                      pageBuilder: (context, state) => slideTransition(
                        context,
                        state,
                        AddBalancePage(
                          subaccountId: state.pathParameters['id']!,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.analytics,
              builder: (context, state) => const AnalyticsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.paywall,
      pageBuilder: (context, state) {
        final args = state.extra is PaywallArgs
            ? state.extra as PaywallArgs
            : const PaywallArgs(reason: PaywallReason.baseCurrency);
        return slideTransition(context, state, PaywallPage(args: args));
      },
    ),
    GoRoute(
      path: AppRoutes.accountActions,
      pageBuilder: (context, state) =>
          slideTransition(context, state, const AccountActionsPage()),
    ),
    GoRoute(
      path: AppRoutes.archivedAccounts,
      pageBuilder: (context, state) =>
          slideTransition(context, state, const ArchivedAccountsPage()),
    ),
    GoRoute(
      path: AppRoutes.baseCurrencySettings,
      pageBuilder: (context, state) => slideTransition(
        context,
        state,
        const BaseCurrencySettingsPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.manageSubscription,
      pageBuilder: (context, state) => slideTransition(
        context,
        state,
        const ManageSubscriptionPage(),
      ),
    ),
  ],
);
