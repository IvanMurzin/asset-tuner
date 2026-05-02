import 'package:asset_tuner/core/analytics/app_analytics.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_page_transitions.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core/routing/guards/route_guard.dart';
import 'package:asset_tuner/core/routing/route_extra_args.dart';
import 'package:asset_tuner/core_ui/preview/ds_preview_page.dart';
import 'package:asset_tuner/domain/subaccount/entity/subaccount_entity.dart';
import 'package:asset_tuner/presentation/account/bloc/account_archive_cubit.dart';
import 'package:asset_tuner/presentation/account/bloc/account_delete_cubit.dart';
import 'package:asset_tuner/presentation/account/bloc/account_info_cubit.dart';
import 'package:asset_tuner/presentation/account/bloc/accounts_cubit.dart';
import 'package:asset_tuner/presentation/account/page/account_create_page.dart';
import 'package:asset_tuner/presentation/account/page/account_detail_page.dart';
import 'package:asset_tuner/presentation/account/page/account_update_page.dart';
import 'package:asset_tuner/presentation/account/page/add_subaccount_page.dart';
import 'package:asset_tuner/presentation/analytics/page/analytics_page.dart';
import 'package:asset_tuner/presentation/auth/page/otp_page.dart';
import 'package:asset_tuner/presentation/auth/page/sign_in_page.dart';
import 'package:asset_tuner/presentation/auth/page/sign_up_page.dart';
import 'package:asset_tuner/presentation/balance/bloc/subaccount_delete_cubit.dart';
import 'package:asset_tuner/presentation/balance/bloc/subaccount_info_cubit.dart';
import 'package:asset_tuner/presentation/balance/bloc/subaccount_update_cubit.dart';
import 'package:asset_tuner/presentation/balance/page/add_balance_page.dart';
import 'package:asset_tuner/presentation/balance/page/subaccount_detail_page.dart';
import 'package:asset_tuner/presentation/home/page/main_shell_page.dart';
import 'package:asset_tuner/presentation/onboarding/page/onboarding_carousel_page.dart';
import 'package:asset_tuner/presentation/overview/page/overview_page.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_args.dart';
import 'package:asset_tuner/presentation/paywall/page/paywall_page.dart';
import 'package:asset_tuner/presentation/profile/page/archived_accounts_page.dart';
import 'package:asset_tuner/presentation/profile/page/contact_developer_page.dart';
import 'package:asset_tuner/presentation/profile/page/profile_page.dart';
import 'package:asset_tuner/presentation/settings/page/base_currency_settings_page.dart';
import 'package:asset_tuner/presentation/settings/page/manage_subscription_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Builds a [GoRouter] from a list of atomic [RouteGuard]-s.
///
/// Each guard is an independent slice of navigation logic (auth, onboarding,
/// later — paywall, etc.). Guards are evaluated in order; the first non-null
/// path wins. go_router then re-runs the whole chain after the redirect, so
/// guards compose without needing to know about each other.
GoRouter buildAppRouter({
  required String initialLocation,
  required List<RouteGuard> guards,
  List<NavigatorObserver>? observers,
}) {
  final listenables = guards
      .map((g) => g.listenable)
      .whereType<Listenable>()
      .toList(growable: false);

  return GoRouter(
    initialLocation: initialLocation,
    observers: observers ?? [AnalyticsRouteObserver(getIt<AppAnalytics>())],
    refreshListenable: listenables.isEmpty ? null : Listenable.merge(listenables),
    redirect: (context, state) {
      final loc = state.matchedLocation;
      for (final guard in guards) {
        final next = guard.redirect(loc);
        if (next != null && next != loc) {
          return next;
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.designSystem,
        pageBuilder: (context, state) => slideTransition(context, state, const DSPreviewPage()),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        pageBuilder: (context, state) => slideTransition(context, state, const SignInPage()),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        pageBuilder: (context, state) => slideTransition(context, state, const SignUpPage()),
      ),
      GoRoute(
        path: AppRoutes.otp,
        pageBuilder: (context, state) => slideTransition(context, state, const OtpPage()),
      ),
      GoRoute(
        path: AppRoutes.onboardingCarousel,
        pageBuilder: (context, state) =>
            slideTransition(context, state, const OnboardingCarouselPage()),
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
                pageBuilder: (context, state) =>
                    slideTransition(context, state, const OverviewPage()),
                routes: [
                  GoRoute(
                    path: AppRoutes.accountsNewPath,
                    pageBuilder: (context, state) =>
                        slideTransition(context, state, const AccountCreatePage()),
                  ),
                  ShellRoute(
                    builder: (context, state, child) {
                      final accountId = state.pathParameters['accountId'];
                      if (accountId == null) {
                        return child;
                      }
                      final account = context.read<AccountsCubit>().findById(accountId);
                      return BlocProvider(
                        create: (_) =>
                            getIt<AccountInfoCubit>()..load(accountId: accountId, account: account),
                        child: child,
                      );
                    },
                    routes: [
                      GoRoute(
                        path: AppRoutes.accountIdPath,
                        pageBuilder: (context, state) {
                          final accountId = state.pathParameters['accountId']!;
                          final extra = state.extra is AccountDetailExtra
                              ? state.extra as AccountDetailExtra
                              : null;
                          return slideTransition(
                            context,
                            state,
                            MultiBlocProvider(
                              providers: [
                                BlocProvider(create: (_) => getIt<AccountArchiveCubit>()),
                                BlocProvider(create: (_) => getIt<AccountDeleteCubit>()),
                              ],
                              child: AccountDetailPage(
                                accountId: accountId,
                                initialTitle: extra?.initialTitle,
                                initialAccountType: extra?.initialAccountType,
                              ),
                            ),
                          );
                        },
                        routes: [
                          GoRoute(
                            path: AppRoutes.editPath,
                            pageBuilder: (context, state) => slideTransition(
                              context,
                              state,
                              AccountUpdatePage(accountId: state.pathParameters['accountId']!),
                            ),
                          ),
                          GoRoute(
                            path: AppRoutes.subaccountsNewPath,
                            pageBuilder: (context, state) => slideTransition(
                              context,
                              state,
                              AddSubaccountPage(accountId: state.pathParameters['accountId']!),
                            ),
                          ),
                          ShellRoute(
                            builder: (context, state, child) {
                              final subaccountId = state.pathParameters['subaccountId'];
                              if (subaccountId == null) {
                                return child;
                              }
                              final extra = state.extra is SubaccountDetailExtra
                                  ? state.extra as SubaccountDetailExtra
                                  : null;
                              final account =
                                  extra?.account ?? context.read<AccountInfoCubit>().state.account;
                              SubaccountEntity? subaccount = extra?.subaccount;
                              if (subaccount == null) {
                                for (final s
                                    in context.read<AccountInfoCubit>().state.subaccounts) {
                                  if (s.id == subaccountId) {
                                    subaccount = s;
                                    break;
                                  }
                                }
                              }
                              if (account == null || subaccount == null) {
                                return child;
                              }
                              return BlocProvider(
                                create: (_) =>
                                    getIt<SubaccountInfoCubit>()
                                      ..load(account: account, subaccount: subaccount!),
                                child: child,
                              );
                            },
                            routes: [
                              GoRoute(
                                path: AppRoutes.subaccountIdPath,
                                pageBuilder: (context, state) {
                                  final accountId = state.pathParameters['accountId']!;
                                  final subaccountId = state.pathParameters['subaccountId']!;
                                  final extra = state.extra is SubaccountDetailExtra
                                      ? state.extra as SubaccountDetailExtra
                                      : null;
                                  final account =
                                      extra?.account ??
                                      context.read<AccountInfoCubit>().state.account;
                                  SubaccountEntity? subaccount = extra?.subaccount;
                                  if (subaccount == null) {
                                    for (final s
                                        in context.read<AccountInfoCubit>().state.subaccounts) {
                                      if (s.id == subaccountId) {
                                        subaccount = s;
                                        break;
                                      }
                                    }
                                  }
                                  if (account == null || subaccount == null) {
                                    return slideTransition(
                                      context,
                                      state,
                                      const Scaffold(body: SizedBox.shrink()),
                                    );
                                  }
                                  return slideTransition(
                                    context,
                                    state,
                                    MultiBlocProvider(
                                      providers: [
                                        BlocProvider(create: (_) => getIt<SubaccountUpdateCubit>()),
                                        BlocProvider(create: (_) => getIt<SubaccountDeleteCubit>()),
                                      ],
                                      child: SubaccountDetailPage(
                                        accountId: accountId,
                                        subaccountId: subaccountId,
                                        initialTitle: extra?.initialTitle,
                                      ),
                                    ),
                                  );
                                },
                                routes: [
                                  GoRoute(
                                    path: AppRoutes.updateBalancePath,
                                    pageBuilder: (context, state) => slideTransition(
                                      context,
                                      state,
                                      AddBalancePage(
                                        accountId: state.pathParameters['accountId']!,
                                        subaccountId: state.pathParameters['subaccountId']!,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
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
                pageBuilder: (context, state) =>
                    slideTransition(context, state, const AnalyticsPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                pageBuilder: (context, state) =>
                    slideTransition(context, state, const ProfilePage()),
                routes: [
                  GoRoute(
                    path: 'base-currency',
                    pageBuilder: (context, state) =>
                        slideTransition(context, state, const BaseCurrencySettingsPage()),
                  ),
                  GoRoute(
                    path: 'subscription',
                    pageBuilder: (context, state) =>
                        slideTransition(context, state, const ManageSubscriptionPage()),
                  ),
                  GoRoute(
                    path: 'archived-accounts',
                    pageBuilder: (context, state) =>
                        slideTransition(context, state, const ArchivedAccountsPage()),
                  ),
                  GoRoute(
                    path: 'archived-accounts/:accountId',
                    pageBuilder: (context, state) {
                      final accountId = state.pathParameters['accountId']!;
                      final account = context.read<AccountsCubit>().findById(accountId);
                      final extra = state.extra is AccountDetailExtra
                          ? state.extra as AccountDetailExtra
                          : null;
                      return slideTransition(
                        context,
                        state,
                        MultiBlocProvider(
                          providers: [
                            BlocProvider(
                              create: (_) =>
                                  getIt<AccountInfoCubit>()
                                    ..load(accountId: accountId, account: account),
                            ),
                            BlocProvider(create: (_) => getIt<AccountArchiveCubit>()),
                            BlocProvider(create: (_) => getIt<AccountDeleteCubit>()),
                          ],
                          child: AccountDetailPage(
                            accountId: accountId,
                            initialTitle: extra?.initialTitle,
                            initialAccountType: extra?.initialAccountType,
                          ),
                        ),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'contact-developer',
                    pageBuilder: (context, state) =>
                        slideTransition(context, state, const ContactDeveloperPage()),
                  ),
                ],
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
    ],
  );
}
