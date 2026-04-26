import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/core_ui/components/ds_text_field.dart';
import 'package:asset_tuner/core_ui/theme/app_theme.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/profile/entity/entitlements_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/repository/i_profile_repository.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/profile/page/contact_developer_page.dart';
import 'package:asset_tuner/presentation/session/bloc/session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('ContactDeveloperPage', () {
    late _TestSessionCubit sessionCubit;
    late _FakeProfileRepository repository;

    setUp(() {
      sessionCubit = _TestSessionCubit(
        SessionState(
          status: SessionStatus.authenticated,
          session: const AuthSessionEntity(userId: 'user-1', email: 'user@example.com'),
        ),
      );
      repository = _FakeProfileRepository();
    });

    tearDown(() async {
      await sessionCubit.close();
    });

    testWidgets('prefills readonly email field', (tester) async {
      await _pumpPage(tester, sessionCubit: sessionCubit, repository: repository);
      await tester.pumpAndSettle();

      final emailField = tester.widget<DSTextField>(find.byType(DSTextField).first);
      expect(emailField.enabled, isFalse);
      expect(emailField.readOnly, isTrue);
      expect(emailField.controller?.text, 'user@example.com');
    });

    testWidgets('shows retryable error and allows resubmission', (tester) async {
      repository.queueResult(
        const FailureResult<void>(Failure(code: 'network', message: 'Temporary network issue')),
      );
      repository.queueResult(
        const FailureResult<void>(Failure(code: 'network', message: 'Temporary network issue')),
      );

      await _pumpPage(tester, sessionCubit: sessionCubit, repository: repository);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(EditableText).last, 'Need help with sync');
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();

      expect(repository.sendCalls, 1);
      expect(find.text('Temporary network issue'), findsOneWidget);

      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();

      expect(repository.sendCalls, 2);
    });
  });
}

Future<void> _pumpPage(
  WidgetTester tester, {
  required SessionCubit sessionCubit,
  required _FakeProfileRepository repository,
}) async {
  final router = GoRouter(
    initialLocation: AppRoutes.contactDeveloper,
    routes: [
      GoRoute(
        path: AppRoutes.contactDeveloper,
        builder: (context, state) => BlocProvider<SessionCubit>.value(
          value: sessionCubit,
          child: ContactDeveloperPage(repository: repository),
        ),
      ),
      GoRoute(path: AppRoutes.signIn, builder: (context, state) => const Text('Sign In Stub')),
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
}

class _TestSessionCubit extends Cubit<SessionState> implements SessionCubit {
  _TestSessionCubit(super.initialState);

  @override
  Future<void> bootstrap() async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<void> syncRevenueCat() async {}
}

class _FakeProfileRepository implements IProfileRepository {
  final List<Result<void>> _queuedResults = [];
  int sendCalls = 0;

  void queueResult(Result<void> result) {
    _queuedResults.add(result);
  }

  @override
  Future<Result<void>> sendContactDeveloperMessage({
    required String name,
    required String email,
    required String description,
  }) async {
    sendCalls += 1;
    if (_queuedResults.isEmpty) {
      return const Success(null);
    }
    return _queuedResults.removeAt(0);
  }

  @override
  Future<Result<ProfileEntity>> getProfile() async {
    return Success(
      ProfileEntity(
        userId: 'user-1',
        plan: 'free',
        entitlements: const EntitlementsEntity(fiatLimit: 5),
        baseAsset: null,
      ),
    );
  }

  @override
  Future<Result<ProfileEntity>> updateBaseCurrency(String baseCurrency) async {
    return await getProfile();
  }

  @override
  Future<Result<ProfileEntity>> updatePlan(String plan) async {
    return await getProfile();
  }
}
