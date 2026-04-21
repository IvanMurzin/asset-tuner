import 'package:asset_tuner/core_ui/theme/app_theme.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/rate/entity/rates_snapshot_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/analytics/bloc/analytics_cubit.dart';
import 'package:asset_tuner/presentation/analytics/page/analytics_page.dart';
import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('AnalyticsPage captions', () {
    late _TestAnalyticsCubit analyticsCubit;

    setUp(() {
      analyticsCubit = _TestAnalyticsCubit(
        AnalyticsState(
          status: AnalyticsStatus.ready,
          baseCurrency: 'USD',
          breakdown: [
            AnalyticsBreakdownItem(
              assetCode: 'BTC',
              value: Decimal.parse('4200'),
              percent: Decimal.parse('80'),
              originalAmount: Decimal.parse('0.125'),
            ),
          ],
          updates: [
            AnalyticsUpdateItem(
              accountName: 'Main wallet',
              subaccountName: 'BTC',
              assetCode: 'BTC',
              diffAmount: Decimal.parse('0.01'),
              diffBaseAmount: Decimal.fromInt(350),
              entryDate: DateTime(2026, 4, 20, 12, 0),
            ),
            AnalyticsUpdateItem(
              accountName: 'Main wallet',
              subaccountName: 'BTC',
              assetCode: 'BTC',
              diffAmount: Decimal.parse('-0.005'),
              diffBaseAmount: Decimal.parse('-120'),
              entryDate: DateTime(2026, 4, 18, 9, 0),
            ),
          ],
        ),
      );
    });

    tearDown(() async {
      await analyticsCubit.close();
    });

    testWidgets('shows explanatory captions for complex sections in english', (tester) async {
      await _pumpPage(tester, analyticsCubit: analyticsCubit);

      expect(find.text('Balance snapshots'), findsOneWidget);
      expect(
        find.text('Shares are calculated in your base currency using the latest available rates.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Track your total balance trend from recent snapshots. Rows below show each snapshot change.',
        ),
        findsOneWidget,
      );
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('shows explanatory captions for complex sections in russian', (tester) async {
      await _pumpPage(tester, analyticsCubit: analyticsCubit, locale: const Locale('ru'));

      expect(find.text('Снимки баланса'), findsOneWidget);
      expect(
        find.text('Доли считаются в базовой валюте по последним доступным курсам.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Отслеживайте тренд общего баланса по последним снимкам. Ниже показаны изменения каждого снимка.',
        ),
        findsOneWidget,
      );
    });
  });
}

Future<void> _pumpPage(
  WidgetTester tester, {
  required AnalyticsCubit analyticsCubit,
  Locale? locale,
}) async {
  final router = GoRouter(
    initialLocation: '/analytics',
    routes: [
      GoRoute(
        path: '/analytics',
        builder: (context, state) =>
            BlocProvider<AnalyticsCubit>.value(value: analyticsCubit, child: const AnalyticsPage()),
      ),
    ],
  );

  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      locale: locale,
      theme: lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
  await tester.pumpAndSettle();
}

class _TestAnalyticsCubit extends Cubit<AnalyticsState> implements AnalyticsCubit {
  _TestAnalyticsCubit(super.initialState);

  @override
  void consumeNavigation() {}

  @override
  void invalidateCache() {}

  @override
  Future<void> onSourceDataReady(
    ProfileEntity profile,
    RatesSnapshotEntity? rates,
    List<AssetEntity> assets,
    List<AccountEntity> accounts,
  ) async {}
}
