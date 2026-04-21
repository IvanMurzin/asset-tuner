import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/analytics/entity/analytics_summary_entity.dart';
import 'package:asset_tuner/domain/analytics/repository/i_analytics_repository.dart';
import 'package:asset_tuner/domain/analytics/usecase/get_analytics_summary_usecase.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/profile/entity/entitlements_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/rate/entity/rates_snapshot_entity.dart';
import 'package:asset_tuner/presentation/analytics/bloc/analytics_cubit.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalyticsCubit', () {
    test('invalidateCache forces re-fetch even when fingerprint is unchanged', () async {
      var callCount = 0;
      final repository = _CountingAnalyticsRepository(
        summary: AnalyticsSummaryEntity(
          baseCurrency: 'USD',
          asOf: DateTime.utc(2026, 4, 21),
          breakdown: [],
          updates: [],
        ),
        onFetch: () => callCount++,
      );

      final cubit = AnalyticsCubit(GetAnalyticsSummaryUseCase(repository));
      final profile = ProfileEntity(
        plan: 'free',
        entitlements: const EntitlementsEntity(plan: 'free'),
      );
      final rates = RatesSnapshotEntity(usdPriceByAssetId: {}, asOf: DateTime.utc(2026, 4, 21));
      final accounts = [
        AccountEntity(
          id: 'acc-1',
          name: 'Wallet',
          type: AccountType.wallet,
          archived: false,
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      ];

      await cubit.onSourceDataReady(profile, rates, const [], accounts);
      expect(callCount, 1);

      await cubit.onSourceDataReady(profile, rates, const [], accounts);
      expect(callCount, 1, reason: 'same fingerprint: no extra fetch');

      cubit.invalidateCache();
      await cubit.onSourceDataReady(profile, rates, const [], accounts);
      expect(callCount, 2, reason: 'after invalidateCache: re-fetched');

      await cubit.close();
    });

    test('excludes zero-delta updates from analytics feed', () async {
      final repository = _FakeAnalyticsRepository(
        summary: AnalyticsSummaryEntity(
          baseCurrency: 'USD',
          asOf: DateTime.utc(2026, 4, 21),
          breakdown: [
            AnalyticsBreakdownEntity(
              assetCode: 'BTC',
              value: Decimal.fromInt(100),
              originalAmount: Decimal.fromInt(100),
            ),
          ],
          updates: [
            AnalyticsUpdateEntity(
              accountName: 'Wallet',
              subaccountName: 'BTC wallet',
              assetCode: 'BTC',
              diffAmount: Decimal.zero,
              diffBaseAmount: Decimal.zero,
              entryDate: DateTime.utc(2026, 4, 21),
            ),
            AnalyticsUpdateEntity(
              accountName: 'Wallet',
              subaccountName: 'BTC wallet',
              assetCode: 'BTC',
              diffAmount: Decimal.fromInt(5),
              diffBaseAmount: Decimal.fromInt(5),
              entryDate: DateTime.utc(2026, 4, 20),
            ),
          ],
        ),
      );

      final cubit = AnalyticsCubit(GetAnalyticsSummaryUseCase(repository));

      await cubit.onSourceDataReady(
        ProfileEntity(
          plan: 'free',
          entitlements: const EntitlementsEntity(plan: 'free'),
        ),
        RatesSnapshotEntity(
          usdPriceByAssetId: {'asset-1': Decimal.one},
          asOf: DateTime.utc(2026, 4, 21),
        ),
        const [
          AssetEntity(
            id: 'asset-1',
            kind: AssetKind.crypto,
            code: 'BTC',
            name: 'Bitcoin',
            decimals: 8,
            isActive: true,
            isLocked: false,
          ),
        ],
        [
          AccountEntity(
            id: 'acc-1',
            name: 'Wallet',
            type: AccountType.wallet,
            archived: false,
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        ],
      );

      expect(cubit.state.status, AnalyticsStatus.ready);
      expect(cubit.state.updates, hasLength(1));
      expect(cubit.state.updates.first.diffAmount, Decimal.fromInt(5));

      await cubit.close();
    });
  });
}

class _FakeAnalyticsRepository implements IAnalyticsRepository {
  _FakeAnalyticsRepository({required this.summary});

  final AnalyticsSummaryEntity summary;

  @override
  Future<Result<AnalyticsSummaryEntity>> fetchSummary({int updatesLimit = 200}) async {
    return Success(summary);
  }
}

class _CountingAnalyticsRepository implements IAnalyticsRepository {
  _CountingAnalyticsRepository({required this.summary, required this.onFetch});

  final AnalyticsSummaryEntity summary;
  final void Function() onFetch;

  @override
  Future<Result<AnalyticsSummaryEntity>> fetchSummary({int updatesLimit = 200}) async {
    onFetch();
    return Success(summary);
  }
}
