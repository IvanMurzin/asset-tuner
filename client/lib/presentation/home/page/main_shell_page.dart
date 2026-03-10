import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/account/bloc/accounts_cubit.dart';
import 'package:asset_tuner/presentation/analytics/bloc/analytics_cubit.dart';
import 'package:asset_tuner/presentation/asset/bloc/assets_cubit.dart';
import 'package:asset_tuner/presentation/profile/bloc/profile_cubit.dart';
import 'package:asset_tuner/presentation/session/bloc/session_cubit.dart';

class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _maybeFeedAnalytics(
    BuildContext context, {
    bool forceForAnalyticsTab = false,
  }) {
    if (!forceForAnalyticsTab && navigationShell.currentIndex != 1) {
      return;
    }
    final sessionState = context.read<SessionCubit>().state;
    final profileState = context.read<ProfileCubit>().state;
    final accountsState = context.read<AccountsCubit>().state;
    final assetsState = context.read<AssetsCubit>().state;

    if (!sessionState.isAuthenticated || !profileState.isReady) {
      return;
    }

    final accounts = accountsState.status == AccountsStatus.ready
        ? accountsState.accounts
        : <AccountEntity>[];
    final assets = assetsState.status == AssetsStatus.ready
        ? assetsState.assets
        : <AssetEntity>[];
    final snapshot = assetsState.snapshot;

    context.read<AnalyticsCubit>().onSourceDataReady(
      profileState.profile!,
      snapshot,
      assets,
      accounts,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MultiBlocProvider(
      providers: [
        BlocProvider<AccountsCubit>(
          create: (_) => getIt<AccountsCubit>()..load(),
        ),
        BlocProvider<AssetsCubit>(create: (_) => getIt<AssetsCubit>()..load()),
        BlocProvider<AnalyticsCubit>(create: (_) => getIt<AnalyticsCubit>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<SessionCubit, SessionState>(
            listenWhen: (prev, curr) => prev.status != curr.status,
            listener: (context, state) {
              if (state.status == SessionStatus.unauthenticated) {
                context.go(AppRoutes.signIn);
                return;
              }
              _maybeFeedAnalytics(context);
            },
          ),
          BlocListener<ProfileCubit, ProfileState>(
            listenWhen: (prev, curr) =>
                prev.profile != curr.profile || prev.status != curr.status,
            listener: (context, state) => _maybeFeedAnalytics(context),
          ),
          BlocListener<AccountsCubit, AccountsState>(
            listenWhen: (prev, curr) =>
                prev.status != curr.status || prev.accounts != curr.accounts,
            listener: (context, state) => _maybeFeedAnalytics(context),
          ),
          BlocListener<AssetsCubit, AssetsState>(
            listenWhen: (prev, curr) =>
                prev.status != curr.status ||
                prev.assets != curr.assets ||
                prev.snapshot != curr.snapshot,
            listener: (context, state) => _maybeFeedAnalytics(context),
          ),
        ],
        child: Builder(
          builder: (context) => Scaffold(
            body: navigationShell,
            bottomNavigationBar: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
                if (index == 1) {
                  _maybeFeedAnalytics(context, forceForAnalyticsTab: true);
                }
              },
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home),
                  label: l10n.mainTitle,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.pie_chart_outline),
                  selectedIcon: const Icon(Icons.pie_chart),
                  label: l10n.analyticsTitle,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: const Icon(Icons.person),
                  label: l10n.profileTitle,
                ),
              ],
            ),
            backgroundColor: context.dsColors.background,
          ),
        ),
      ),
    );
  }
}
