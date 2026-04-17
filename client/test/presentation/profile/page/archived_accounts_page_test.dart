import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core/routing/route_extra_args.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/theme/app_theme.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/account/bloc/accounts_cubit.dart';
import 'package:asset_tuner/presentation/profile/page/archived_accounts_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('ArchivedAccountsPage navigation', () {
    late _TestAccountsCubit accountsCubit;

    setUp(() {
      accountsCubit = _TestAccountsCubit(
        AccountsState(
          status: AccountsStatus.ready,
          accounts: [
            _account(id: 'account-1', name: 'Archived Wallet', archived: true),
            _account(id: 'account-2', name: 'Active Bank', archived: false),
          ],
        ),
      );
    });

    tearDown(() async {
      await accountsCubit.close();
    });

    testWidgets('opens detail with push and returns to archived list on back', (tester) async {
      AccountDetailExtra? detailExtra;

      final router = GoRouter(
        initialLocation: AppRoutes.archivedAccounts,
        routes: [
          GoRoute(
            path: AppRoutes.archivedAccounts,
            builder: (context, state) => BlocProvider<AccountsCubit>.value(
              value: accountsCubit,
              child: const ArchivedAccountsPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.accountDetail,
            builder: (context, state) {
              detailExtra = state.extra as AccountDetailExtra?;
              return Scaffold(
                appBar: DSAppBar(title: 'Account ${state.pathParameters['accountId']!}'),
                body: const SizedBox.shrink(),
              );
            },
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

      final context = tester.element(find.byType(ArchivedAccountsPage));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.settingsArchivedAccounts), findsOneWidget);
      expect(find.text('Archived Wallet'), findsOneWidget);
      expect(find.text('Active Bank'), findsNothing);

      await tester.tap(find.text('Archived Wallet'));
      await tester.pumpAndSettle();

      expect(find.text('Account account-1'), findsOneWidget);
      expect(detailExtra?.initialTitle, 'Archived Wallet');
      expect(detailExtra?.initialAccountType, AccountType.wallet);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(ArchivedAccountsPage), findsOneWidget);
      expect(find.text(l10n.settingsArchivedAccounts), findsOneWidget);
      expect(find.text('Archived Wallet'), findsOneWidget);
    });
  });
}

class _TestAccountsCubit extends Cubit<AccountsState> implements AccountsCubit {
  _TestAccountsCubit(super.initialState);

  @override
  Future<void> load() async {}

  @override
  Future<void> refresh({bool silent = false}) async {}

  @override
  Future<void> create(AccountEntity account) async {}

  @override
  Future<void> update(AccountEntity account) async {}

  @override
  Future<void> archive(AccountEntity account) async {}

  @override
  Future<void> delete(String accountId) async {}

  @override
  void applyCreated(AccountEntity account) {}

  @override
  void applyUpdated(AccountEntity account) {}

  @override
  void applyArchived(AccountEntity account) {}

  @override
  void applyDeleted(String accountId) {}

  @override
  AccountEntity? findById(String id) {
    for (final account in state.accounts) {
      if (account.id == id) {
        return account;
      }
    }
    return null;
  }
}

AccountEntity _account({required String id, required String name, required bool archived}) {
  return AccountEntity(
    id: id,
    name: name,
    type: id == 'account-1' ? AccountType.wallet : AccountType.bank,
    archived: archived,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}
