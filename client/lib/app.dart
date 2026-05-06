import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/local_storage/onboarding_carousel_gate.dart';
import 'package:asset_tuner/core/localization/locale_cubit.dart';
import 'package:asset_tuner/core/native_splash/native_splash_controller.dart';
import 'package:asset_tuner/core/revenuecat/revenuecat_service.dart';
import 'package:asset_tuner/core/routing/first_auth_paywall_coordinator.dart';
import 'package:asset_tuner/core/routing/app_router.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core/routing/guards/auth_route_guard.dart';
import 'package:asset_tuner/core/routing/guards/onboarding_route_guard.dart';
import 'package:asset_tuner/core/utils/app_lifecycle_observer.dart';
import 'package:asset_tuner/core_ui/theme/app_theme.dart';
import 'package:asset_tuner/core_ui/theme/theme_mode_cubit.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/auth/bloc/auth_cubit.dart';
import 'package:asset_tuner/presentation/profile/bloc/profile_cubit.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthCubit _authCubit;
  late final ProfileCubit _profileCubit;
  late final NativeSplashController _splashController;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authCubit = getIt<AuthCubit>()..bootstrap();
    _profileCubit = getIt<ProfileCubit>()..bootstrap();
    _splashController = NativeSplashController()..attach(_authCubit);

    final carouselGate = getIt<OnboardingCarouselGate>();
    final initialLocation = carouselGate.isCompleted
        ? AppRoutes.splash
        : AppRoutes.onboardingCarousel;

    _router = buildAppRouter(
      initialLocation: initialLocation,
      guards: [OnboardingRouteGuard(carouselGate), AuthRouteGuard(_authCubit)],
    );
  }

  @override
  void dispose() {
    _splashController.dispose();
    _authCubit.close();
    _profileCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ThemeModeCubit>()),
        BlocProvider(create: (_) => getIt<LocaleCubit>()..load()),
        BlocProvider<AuthCubit>.value(value: _authCubit),
        BlocProvider<ProfileCubit>.value(value: _profileCubit),
      ],
      child: BlocBuilder<ThemeModeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, localeState) {
              return AppLifecycleObserver(
                onResumed: () => context.read<ProfileCubit>().syncSubscription(silent: true),
                child: FirstAuthPaywallCoordinator(
                  authCubit: _authCubit,
                  profileCubit: _profileCubit,
                  router: _router,
                  revenueCatService: getIt<RevenueCatService>(),
                  child: MaterialApp.router(
                    theme: lightTheme,
                    darkTheme: darkTheme,
                    themeMode: themeMode,
                    routerConfig: _router,
                    locale: context.read<LocaleCubit>().locale,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: AppLocalizations.supportedLocales,
                    debugShowCheckedModeBanner: false,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
