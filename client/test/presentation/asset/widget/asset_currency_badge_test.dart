import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/rate/entity/rates_snapshot_entity.dart';
import 'package:asset_tuner/core_ui/theme/app_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/asset/bloc/assets_cubit.dart';
import 'package:decimal/decimal.dart';
import 'package:asset_tuner/presentation/asset/widget/asset_currency_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AssetCurrencyBadge', () {
    late _TestAssetsCubit assetsCubit;

    tearDown(() async {
      await assetsCubit.close();
    });

    testWidgets('shows only fiat assets without tabs in fiat mode', (tester) async {
      assetsCubit = _TestAssetsCubit(
        AssetsState(
          status: AssetsStatus.ready,
          assets: [
            _asset(id: 'fiat-usd', kind: AssetKind.fiat, code: 'USD', name: 'US Dollar'),
            _asset(id: 'crypto-btc', kind: AssetKind.crypto, code: 'BTC', name: 'Bitcoin'),
          ],
        ),
      );

      await tester.pumpWidget(
        _TestHarness(
          assetsCubit: assetsCubit,
          child: AssetCurrencyBadge(
            currencyType: CurrencyType.fiat,
            selectedSlug: 'USD',
            sheetTitleText: 'Choose currency',
            placeholderText: 'Currency',
            searchHintText: 'Search',
            fiatTabText: 'Fiat',
            cryptoTabText: 'Crypto',
            emptyResultsTitle: 'No results',
            emptyResultsMessage: 'Try another query',
            onSelected: (_) {},
            onLocked: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(AssetCurrencyBadge));
      await tester.pumpAndSettle();

      expect(find.text('US Dollar'), findsOneWidget);
      expect(find.text('1 USD ≈ 1 USD'), findsOneWidget);
      expect(find.text('Bitcoin'), findsNothing);
      expect(find.text('Crypto'), findsNothing);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('shows tabs and switches to crypto list in all mode', (tester) async {
      assetsCubit = _TestAssetsCubit(
        AssetsState(
          status: AssetsStatus.ready,
          assets: [
            _asset(id: 'fiat-usd', kind: AssetKind.fiat, code: 'USD', name: 'US Dollar'),
            _asset(id: 'crypto-btc', kind: AssetKind.crypto, code: 'BTC', name: 'Bitcoin'),
          ],
        ),
      );

      await tester.pumpWidget(
        _TestHarness(
          assetsCubit: assetsCubit,
          child: AssetCurrencyBadge(
            currencyType: CurrencyType.all,
            selectedSlug: null,
            sheetTitleText: 'Choose currency',
            placeholderText: 'Currency',
            searchHintText: 'Search',
            fiatTabText: 'Fiat',
            cryptoTabText: 'Crypto',
            emptyResultsTitle: 'No results',
            emptyResultsMessage: 'Try another query',
            onSelected: (_) {},
            onLocked: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(AssetCurrencyBadge));
      await tester.pumpAndSettle();

      expect(find.text('US Dollar'), findsOneWidget);
      expect(find.text('1 USD ≈ 1 USD'), findsOneWidget);
      expect(find.text('Bitcoin'), findsNothing);

      await tester.tap(find.text('Crypto'));
      await tester.pumpAndSettle();

      expect(find.text('Bitcoin'), findsOneWidget);
      expect(find.text('Rates unavailable'), findsOneWidget);
      expect(find.text('US Dollar'), findsNothing);
    });

    testWidgets('shows rate caption when rate is available', (tester) async {
      assetsCubit = _TestAssetsCubit(
        AssetsState(
          status: AssetsStatus.ready,
          assets: [_asset(id: 'crypto-btc', kind: AssetKind.crypto, code: 'BTC', name: 'Bitcoin')],
          snapshot: RatesSnapshotEntity(
            usdPriceByAssetId: {'crypto-btc': Decimal.fromInt(2)},
            asOf: DateTime.utc(2026, 3, 1),
          ),
        ),
      );

      await tester.pumpWidget(
        _TestHarness(
          assetsCubit: assetsCubit,
          child: AssetCurrencyBadge(
            currencyType: CurrencyType.crypto,
            selectedSlug: null,
            sheetTitleText: 'Choose currency',
            placeholderText: 'Currency',
            searchHintText: 'Search',
            fiatTabText: 'Fiat',
            cryptoTabText: 'Crypto',
            emptyResultsTitle: 'No results',
            emptyResultsMessage: 'Try another query',
            baseCurrencyCode: 'USD',
            onSelected: (_) {},
            onLocked: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(AssetCurrencyBadge));
      await tester.pumpAndSettle();

      expect(find.text('Bitcoin'), findsOneWidget);
      expect(find.text('1 BTC ≈ 2 USD'), findsOneWidget);
    });

    testWidgets('shows fallback caption when rate is unavailable', (tester) async {
      assetsCubit = _TestAssetsCubit(
        AssetsState(
          status: AssetsStatus.ready,
          assets: [_asset(id: 'crypto-btc', kind: AssetKind.crypto, code: 'BTC', name: 'Bitcoin')],
        ),
      );

      await tester.pumpWidget(
        _TestHarness(
          assetsCubit: assetsCubit,
          child: AssetCurrencyBadge(
            currencyType: CurrencyType.crypto,
            selectedSlug: null,
            sheetTitleText: 'Choose currency',
            placeholderText: 'Currency',
            searchHintText: 'Search',
            fiatTabText: 'Fiat',
            cryptoTabText: 'Crypto',
            emptyResultsTitle: 'No results',
            emptyResultsMessage: 'Try another query',
            baseCurrencyCode: 'EUR',
            onSelected: (_) {},
            onLocked: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(AssetCurrencyBadge));
      await tester.pumpAndSettle();

      expect(find.text('Bitcoin'), findsOneWidget);
      expect(find.text('Rates unavailable'), findsOneWidget);
    });

    testWidgets('calculates non-usd base caption using full assets list', (tester) async {
      assetsCubit = _TestAssetsCubit(
        AssetsState(
          status: AssetsStatus.ready,
          assets: [
            _asset(id: 'fiat-eur', kind: AssetKind.fiat, code: 'EUR', name: 'Euro'),
            _asset(id: 'crypto-btc', kind: AssetKind.crypto, code: 'BTC', name: 'Bitcoin'),
          ],
          snapshot: RatesSnapshotEntity(
            usdPriceByAssetId: {'fiat-eur': Decimal.parse('0.5'), 'crypto-btc': Decimal.one},
            asOf: DateTime.utc(2026, 3, 1),
          ),
        ),
      );

      await tester.pumpWidget(
        _TestHarness(
          assetsCubit: assetsCubit,
          child: AssetCurrencyBadge(
            currencyType: CurrencyType.crypto,
            selectedSlug: null,
            sheetTitleText: 'Choose currency',
            placeholderText: 'Currency',
            searchHintText: 'Search',
            fiatTabText: 'Fiat',
            cryptoTabText: 'Crypto',
            emptyResultsTitle: 'No results',
            emptyResultsMessage: 'Try another query',
            baseCurrencyCode: 'EUR',
            onSelected: (_) {},
            onLocked: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(AssetCurrencyBadge));
      await tester.pumpAndSettle();

      expect(find.text('Bitcoin'), findsOneWidget);
      expect(find.text('1 BTC ≈ 2 EUR'), findsOneWidget);
    });

    testWidgets('invokes onLocked and does not invoke onSelected for locked asset', (tester) async {
      assetsCubit = _TestAssetsCubit(
        AssetsState(
          status: AssetsStatus.ready,
          assets: [
            _asset(id: 'fiat-eur', kind: AssetKind.fiat, code: 'EUR', name: 'Euro', isLocked: true),
          ],
        ),
      );
      AssetEntity? selectedAsset;
      AssetEntity? lockedAsset;

      await tester.pumpWidget(
        _TestHarness(
          assetsCubit: assetsCubit,
          child: AssetCurrencyBadge(
            currencyType: CurrencyType.fiat,
            selectedSlug: null,
            sheetTitleText: 'Choose currency',
            placeholderText: 'Currency',
            searchHintText: 'Search',
            fiatTabText: 'Fiat',
            cryptoTabText: 'Crypto',
            emptyResultsTitle: 'No results',
            emptyResultsMessage: 'Try another query',
            onSelected: (asset) => selectedAsset = asset,
            onLocked: (asset) => lockedAsset = asset,
          ),
        ),
      );

      await tester.tap(find.byType(AssetCurrencyBadge));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Euro'));
      await tester.pumpAndSettle();

      expect(selectedAsset, isNull);
      expect(lockedAsset?.id, 'fiat-eur');
    });

    testWidgets('hides dropdown icon when disabled', (tester) async {
      assetsCubit = _TestAssetsCubit(
        AssetsState(
          status: AssetsStatus.ready,
          assets: [_asset(id: 'fiat-usd', kind: AssetKind.fiat, code: 'USD', name: 'US Dollar')],
        ),
      );

      await tester.pumpWidget(
        _TestHarness(
          assetsCubit: assetsCubit,
          child: AssetCurrencyBadge(
            currencyType: CurrencyType.fiat,
            selectedSlug: 'USD',
            sheetTitleText: 'Choose currency',
            placeholderText: 'Currency',
            searchHintText: 'Search',
            fiatTabText: 'Fiat',
            cryptoTabText: 'Crypto',
            emptyResultsTitle: 'No results',
            emptyResultsMessage: 'Try another query',
            enabled: false,
            onSelected: (_) {},
            onLocked: (_) {},
          ),
        ),
      );

      expect(find.text('USD'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNothing);
    });
  });
}

class _TestHarness extends StatelessWidget {
  const _TestHarness({required this.assetsCubit, required this.child});

  final AssetsCubit assetsCubit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: BlocProvider<AssetsCubit>.value(value: assetsCubit, child: child),
        ),
      ),
    );
  }
}

class _TestAssetsCubit extends Cubit<AssetsState> implements AssetsCubit {
  _TestAssetsCubit(super.initialState);

  @override
  Future<void> load() async {}

  @override
  Future<void> refresh({bool silent = false}) async {}
}

AssetEntity _asset({
  required String id,
  required AssetKind kind,
  required String code,
  required String name,
  bool isLocked = false,
}) {
  return AssetEntity(
    id: id,
    kind: kind,
    code: code,
    name: name,
    provider: '',
    providerRef: '',
    rank: 1,
    decimals: 2,
    isActive: true,
    isLocked: isLocked,
  );
}
