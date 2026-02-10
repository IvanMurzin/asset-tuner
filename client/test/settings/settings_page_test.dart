import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/di/injectable.dart';
import 'package:asset_tuner/core/localization/locale_cubit.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/theme/app_theme.dart';
import 'package:asset_tuner/core_ui/theme/theme_mode_cubit.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/profile/page/language_page.dart';
import 'package:asset_tuner/presentation/profile/page/account_actions_page.dart';
import 'package:asset_tuner/presentation/profile/page/profile_page.dart';
import 'package:asset_tuner/presentation/profile/page/theme_page.dart';
import 'package:asset_tuner/presentation/settings/page/base_currency_settings_page.dart';
import 'package:asset_tuner/presentation/settings/page/manage_subscription_page.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'auth_session': jsonEncode({'userId': 'u1', 'email': 'u1@example.com'}),
      'profiles': jsonEncode({
        'u1': {'userId': 'u1', 'baseCurrency': 'USD', 'plan': 'free'},
      }),
    });
    await getIt.reset();
    initDependencies();
  });

  testWidgets('Profile shows base currency, language, and subscription rows', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: AppRoutes.settings,
      routes: [
        GoRoute(
          path: AppRoutes.settings,
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: AppRoutes.baseCurrencySettings,
          builder: (context, state) => const BaseCurrencySettingsPage(),
        ),
        GoRoute(
          path: AppRoutes.manageSubscription,
          builder: (context, state) => const ManageSubscriptionPage(),
        ),
        GoRoute(
          path: AppRoutes.language,
          builder: (context, state) => const LanguagePage(),
        ),
        GoRoute(
          path: AppRoutes.theme,
          builder: (context, state) => const ThemePage(),
        ),
        GoRoute(
          path: AppRoutes.accountActions,
          builder: (context, state) => const AccountActionsPage(),
        ),
        GoRoute(
          path: AppRoutes.signIn,
          builder: (context, state) => const Scaffold(body: Text('Sign in')),
        ),
        GoRoute(
          path: AppRoutes.paywall,
          builder: (context, state) => const Scaffold(body: Text('Paywall')),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: getIt<LocaleCubit>()..load()),
          BlocProvider.value(value: getIt<ThemeModeCubit>()),
        ],
        child: MaterialApp.router(
          theme: lightTheme,
          darkTheme: darkTheme,
          routerConfig: router,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Base currency'), findsOneWidget);
    expect(find.text('USD'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Plan status'), findsOneWidget);
    expect(find.text('Free plan'), findsOneWidget);
    expect(find.text('Manage subscription'), findsOneWidget);
    expect(find.text('Account actions'), findsOneWidget);
  });
}
