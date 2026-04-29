import 'package:asset_tuner/core/localization/locale_cubit.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/theme/app_theme.dart';
import 'package:asset_tuner/core_ui/theme/theme_mode_cubit.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/profile/entity/entitlements_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/asset/bloc/assets_cubit.dart';
import 'package:asset_tuner/presentation/profile/bloc/profile_cubit.dart';
import 'package:asset_tuner/presentation/profile/page/profile_page.dart';
import 'package:asset_tuner/presentation/auth/bloc/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('ProfilePage account actions', () {
    late _TestAuthCubit sessionCubit;
    late _TestProfileCubit profileCubit;
    late _TestAssetsCubit assetsCubit;
    late _TestLocaleCubit localeCubit;
    late _TestThemeModeCubit themeModeCubit;

    setUp(() {
      sessionCubit = _TestAuthCubit(
        AuthState(
          status: AuthStatus.authenticated,
          session: const AuthSessionEntity(userId: 'user-1', email: 'user@example.com'),
        ),
      );
      profileCubit = _TestProfileCubit(
        ProfileState(
          status: ProfileStatus.ready,
          profile: ProfileEntity(
            userId: 'user-1',
            plan: 'free',
            entitlements: const EntitlementsEntity(fiatLimit: 5),
            baseAsset: _asset(id: 'asset-usd', code: 'USD', name: 'US Dollar'),
          ),
        ),
      );
      assetsCubit = _TestAssetsCubit(const AssetsState(status: AssetsStatus.ready));
      localeCubit = _TestLocaleCubit(const LocaleState(localeTag: null));
      themeModeCubit = _TestThemeModeCubit(ThemeMode.system);
    });

    tearDown(() async {
      await sessionCubit.close();
      await profileCubit.close();
      await assetsCubit.close();
      await localeCubit.close();
      await themeModeCubit.close();
    });

    testWidgets('shows sign out and delete actions at the bottom of profile', (tester) async {
      await _pumpPage(
        tester,
        sessionCubit: sessionCubit,
        profileCubit: profileCubit,
        assetsCubit: assetsCubit,
        localeCubit: localeCubit,
        themeModeCubit: themeModeCubit,
      );

      await tester.scrollUntilVisible(
        find.text('Delete account'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Sign out'), findsOneWidget);
      expect(find.text('Delete account'), findsOneWidget);
    });

    testWidgets('sign out action asks confirmation before signing out', (tester) async {
      await _pumpPage(
        tester,
        sessionCubit: sessionCubit,
        profileCubit: profileCubit,
        assetsCubit: assetsCubit,
        localeCubit: localeCubit,
        themeModeCubit: themeModeCubit,
      );

      await tester.scrollUntilVisible(
        find.text('Sign out'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      expect(find.text('Sign out?'), findsOneWidget);
      expect(find.text("You'll need to sign in again to access your account."), findsOneWidget);
      expect(sessionCubit.signOutCalls, 0);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(sessionCubit.signOutCalls, 0);

      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign out').last);
      await tester.pumpAndSettle();

      expect(sessionCubit.signOutCalls, 1);
    });

    testWidgets('delete action keeps confirmation dialog and runs delete flow', (tester) async {
      await _pumpPage(
        tester,
        sessionCubit: sessionCubit,
        profileCubit: profileCubit,
        assetsCubit: assetsCubit,
        localeCubit: localeCubit,
        themeModeCubit: themeModeCubit,
      );

      await tester.scrollUntilVisible(
        find.text('Delete account'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();

      expect(find.text('Delete account?'), findsOneWidget);
      expect(find.text('This action cannot be undone.'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(sessionCubit.deleteAccountCalls, 1);
    });

    testWidgets('opens contact developer screen from support section', (tester) async {
      await _pumpPage(
        tester,
        sessionCubit: sessionCubit,
        profileCubit: profileCubit,
        assetsCubit: assetsCubit,
        localeCubit: localeCubit,
        themeModeCubit: themeModeCubit,
      );

      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Contact developer'));
      await tester.tap(find.text('Contact developer'));
      await tester.pumpAndSettle();

      expect(find.text('Contact developer Stub'), findsOneWidget);
    });

    testWidgets('shows legal section with terms and privacy rows', (tester) async {
      await _pumpPage(
        tester,
        sessionCubit: sessionCubit,
        profileCubit: profileCubit,
        assetsCubit: assetsCubit,
        localeCubit: localeCubit,
        themeModeCubit: themeModeCubit,
      );

      await tester.drag(find.byType(ListView), const Offset(0, -900));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Legal'));

      expect(find.text('Legal'), findsOneWidget);
      expect(find.text('Terms of use'), findsOneWidget);
      expect(find.text('Privacy policy'), findsOneWidget);
    });
  });
}

Future<void> _pumpPage(
  WidgetTester tester, {
  required AuthCubit sessionCubit,
  required ProfileCubit profileCubit,
  required AssetsCubit assetsCubit,
  required LocaleCubit localeCubit,
  required ThemeModeCubit themeModeCubit,
}) async {
  final router = GoRouter(
    initialLocation: AppRoutes.profile,
    routes: [
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: sessionCubit),
            BlocProvider<ProfileCubit>.value(value: profileCubit),
            BlocProvider<AssetsCubit>.value(value: assetsCubit),
            BlocProvider<LocaleCubit>.value(value: localeCubit),
            BlocProvider<ThemeModeCubit>.value(value: themeModeCubit),
          ],
          child: const ProfilePage(),
        ),
      ),
      GoRoute(path: AppRoutes.signIn, builder: (context, state) => const Text('Sign In Stub')),
      GoRoute(path: AppRoutes.paywall, builder: (context, state) => const SizedBox.shrink()),
      GoRoute(
        path: AppRoutes.manageSubscription,
        builder: (context, state) => const SizedBox.shrink(),
      ),
      GoRoute(
        path: AppRoutes.baseCurrencySettings,
        builder: (context, state) => const SizedBox.shrink(),
      ),
      GoRoute(
        path: AppRoutes.archivedAccounts,
        builder: (context, state) => const SizedBox.shrink(),
      ),
      GoRoute(
        path: AppRoutes.contactDeveloper,
        builder: (context, state) => const Text('Contact developer Stub'),
      ),
    ],
  );

  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      theme: lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
  await tester.pumpAndSettle();
}

class _TestAuthCubit extends Cubit<AuthState> implements AuthCubit {
  _TestAuthCubit(super.initialState);

  int signOutCalls = 0;
  int deleteAccountCalls = 0;

  @override
  Future<void> bootstrap() async {}

  @override
  Future<void> signOut() async {
    signOutCalls += 1;
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  @override
  Future<void> deleteAccount() async {
    deleteAccountCalls += 1;
  }

  @override
  Future<void> syncRevenueCat() async {}
}

class _TestProfileCubit extends Cubit<ProfileState> implements ProfileCubit {
  _TestProfileCubit(super.initialState);

  @override
  Future<void> bootstrap() async {}

  @override
  Future<void> refresh({bool silent = false, bool forceRefresh = false}) async {}

  @override
  Future<void> updateBaseCurrency(String code) async {}

  @override
  Future<void> syncSubscription({
    bool silent = true,
    bool force = false,
    String placement = 'auto',
  }) async {}
}

class _TestAssetsCubit extends Cubit<AssetsState> implements AssetsCubit {
  _TestAssetsCubit(super.initialState);

  @override
  Future<void> load() async {}

  @override
  Future<void> refresh({bool silent = false, bool forceRefresh = false}) async {}
}

class _TestLocaleCubit extends Cubit<LocaleState> implements LocaleCubit {
  _TestLocaleCubit(super.initialState);

  @override
  Future<void> load() async {}

  @override
  Future<void> setLocale(Locale? locale) async {
    emit(LocaleState(localeTag: locale?.languageCode));
  }

  @override
  Locale? get locale {
    final tag = state.localeTag;
    return tag == null ? null : Locale(tag);
  }
}

class _TestThemeModeCubit extends Cubit<ThemeMode> implements ThemeModeCubit {
  _TestThemeModeCubit(super.initialState);

  @override
  void toggle() {}

  @override
  void set(ThemeMode mode) {
    emit(mode);
  }
}

AssetEntity _asset({required String id, required String code, required String name}) {
  return AssetEntity(
    id: id,
    kind: AssetKind.fiat,
    code: code,
    name: name,
    provider: 'manual',
    providerRef: '',
    rank: 1,
    decimals: 2,
    isActive: true,
    isLocked: false,
  );
}
