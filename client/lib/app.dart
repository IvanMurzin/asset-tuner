import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/localization/locale_cubit.dart';
import 'package:asset_tuner/core/routing/app_router.dart';
import 'package:asset_tuner/core_ui/theme/app_theme.dart';
import 'package:asset_tuner/core_ui/theme/theme_mode_cubit.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/profile/bloc/profile_cubit.dart';
import 'package:asset_tuner/presentation/session/bloc/session_cubit.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ThemeModeCubit>()),
        BlocProvider(create: (_) => getIt<LocaleCubit>()..load()),
        BlocProvider(create: (_) => getIt<SessionCubit>()..bootstrap()),
        BlocProvider(create: (_) => getIt<ProfileCubit>()..bootstrap()),
      ],
      child: BlocBuilder<ThemeModeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, localeState) {
              return MaterialApp.router(
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: themeMode,
                routerConfig: appRouter,
                locale:
                    context.read<LocaleCubit>().locale ?? const Locale('en'),
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
                debugShowCheckedModeBanner: false,
              );
            },
          );
        },
      ),
    );
  }
}
