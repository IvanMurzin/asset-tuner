import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/account/usecase/get_accounts_usecase.dart';
import 'package:asset_tuner/domain/asset/usecase/get_assets_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/account/bloc/accounts_cubit.dart';
import 'package:asset_tuner/presentation/analytics/bloc/analytics_cubit.dart';
import 'package:asset_tuner/presentation/asset/bloc/assets_cubit.dart';
import 'package:asset_tuner/presentation/rate/bloc/usd_rates_cubit.dart';

class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MultiBlocProvider(
      providers: [
        BlocProvider<AccountsCubit>(
          create: (_) => AccountsCubit(
            getIt<GetCachedSessionUseCase>(),
            getIt<GetAccountsUseCase>(),
          )..load(),
        ),
        BlocProvider<UsdRatesCubit>(
          create: (_) => getIt<UsdRatesCubit>()..start(),
        ),
        BlocProvider<AssetsCubit>(
          create: (_) => AssetsCubit(
            getIt<GetCachedSessionUseCase>(),
            getIt<GetAssetsUseCase>(),
          )..load(),
        ),
        BlocProvider<AnalyticsCubit>(create: (_) => getIt<AnalyticsCubit>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AccountsCubit, AccountsState>(
            listenWhen: (prev, curr) =>
                prev.status != curr.status || prev.accounts != curr.accounts,
            listener: (context, state) async {
              if (state.status != AccountsStatus.ready) {
                return;
              }
              await context.read<AnalyticsCubit>().onAccountsChanged(
                state.accounts,
              );
            },
          ),
        ],
        child: Scaffold(
          body: navigationShell,
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
              if (index == 1) {
                final analyticsCubit = context.read<AnalyticsCubit>();
                if (analyticsCubit.state.status == AnalyticsStatus.ready) {
                  analyticsCubit.refresh();
                } else {
                  analyticsCubit.load();
                }
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
    );
  }
}
