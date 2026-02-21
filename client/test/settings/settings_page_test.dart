import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asset_tuner/core/local_storage/locale_storage.dart';
import 'package:asset_tuner/core/localization/locale_cubit.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core/local_storage/theme_mode_storage.dart';
import 'package:asset_tuner/core_ui/theme/app_theme.dart';
import 'package:asset_tuner/core_ui/theme/theme_mode_cubit.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/entity/otp_verification_entity.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';
import 'package:asset_tuner/domain/auth/usecase/delete_account_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/sign_out_usecase.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/profile/entity/profile_bootstrap_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/profile/repository/i_profile_repository.dart';
import 'package:asset_tuner/domain/profile/usecase/bootstrap_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/update_base_currency_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/update_plan_usecase.dart';
import 'package:asset_tuner/presentation/profile/page/account_actions_page.dart';
import 'package:asset_tuner/presentation/profile/page/profile_page.dart';
import 'package:asset_tuner/presentation/settings/page/base_currency_settings_page.dart';
import 'package:asset_tuner/presentation/settings/page/manage_subscription_page.dart';
import 'package:asset_tuner/presentation/user/bloc/user_cubit.dart';
import '../test_fixtures.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Profile shows base currency, language, and subscription rows', (
    tester,
  ) async {
    final authRepository = _FakeAuthRepository(
      cachedSession: const AuthSessionEntity(
        userId: 'u1',
        email: 'u1@example.com',
      ),
    );
    final profileRepository = _FakeProfileRepository(freeProfile());
    final userCubit = UserCubit(
      GetCachedSessionUseCase(authRepository),
      BootstrapProfileUseCase(profileRepository),
      UpdateBaseCurrencyUseCase(profileRepository),
      UpdatePlanUseCase(profileRepository),
      DeleteAccountUseCase(authRepository),
      SignOutUseCase(authRepository),
    );
    await userCubit.bootstrap();

    final router = GoRouter(
      initialLocation: AppRoutes.profile,
      routes: [
        GoRoute(
          path: AppRoutes.profile,
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
          BlocProvider.value(value: LocaleCubit(LocaleStorage())..load()),
          BlocProvider.value(value: ThemeModeCubit(ThemeModeStorage())),
          BlocProvider.value(value: userCubit),
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
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Free plan'), findsOneWidget);
    expect(find.text('Manage subscription'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Account actions'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Account actions'), findsOneWidget);
  });
}

class _FakeAuthRepository implements IAuthRepository {
  _FakeAuthRepository({this.cachedSession});

  final AuthSessionEntity? cachedSession;

  @override
  Future<Result<AuthSessionEntity?>> restoreSession() async {
    return Success(cachedSession);
  }

  @override
  Future<AuthSessionEntity?> getCachedSession() async {
    return cachedSession;
  }

  @override
  Future<Result<void>> requestEmailOtp(String email) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<AuthSessionEntity>> confirmEmailOtp(String email) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<void>> signInWithPassword(String email, String password) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<OtpVerificationEntity>> signUpWithPassword(
    String email,
    String password,
  ) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<AuthSessionEntity>> verifySignUpOtp(
    String email,
    String code,
  ) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<AuthSessionEntity>> signInWithOAuth(
    AuthProvider provider,
  ) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<List<AuthProvider>> getAvailableProviders() async {
    return const [];
  }

  @override
  Future<Result<void>> signOut() async {
    return const Success(null);
  }

  @override
  Future<Result<void>> deleteAccount() async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }
}

class _FakeProfileRepository implements IProfileRepository {
  _FakeProfileRepository(this.profile);

  final ProfileEntity profile;

  @override
  Future<Result<ProfileBootstrapEntity>> ensureProfile() async {
    return Success(ProfileBootstrapEntity(profile: profile));
  }

  @override
  Future<Result<ProfileEntity>> getProfile() async {
    return Success(profile);
  }

  @override
  Future<Result<ProfileEntity>> updateBaseCurrency(String baseCurrency) async {
    return Success(
      profile.copyWith(
        baseAsset: AssetEntity(
          id: '${baseCurrency.toLowerCase()}-asset',
          kind: AssetKind.fiat,
          code: baseCurrency,
          name: baseCurrency,
        ),
      ),
    );
  }

  @override
  Future<Result<ProfileEntity>> updatePlan(String plan) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }
}
