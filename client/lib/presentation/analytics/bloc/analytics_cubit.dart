import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/core/utils/decimal_math.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/analytics/entity/analytics_summary_entity.dart';
import 'package:asset_tuner/domain/analytics/usecase/get_analytics_summary_usecase.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/rate/entity/rates_snapshot_entity.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'analytics_cubit.freezed.dart';
part 'analytics_state.dart';

@injectable
class AnalyticsCubit extends Cubit<AnalyticsState> {
  AnalyticsCubit(this._getAnalyticsSummary) : super(const AnalyticsState());

  final GetAnalyticsSummaryUseCase _getAnalyticsSummary;

  bool _isFetching = false;
  bool _queuedFetch = false;
  bool _queuedSilent = true;
  ProfileEntity? _queuedProfile;
  RatesSnapshotEntity? _queuedRates;
  List<AssetEntity> _queuedAssets = const [];
  List<AccountEntity> _queuedAccounts = const [];
  String? _queuedFingerprint;
  String? _lastSourceFingerprint;

  Future<void> onSourceDataReady(
    ProfileEntity profile,
    RatesSnapshotEntity? rates,
    List<AssetEntity> assets,
    List<AccountEntity> accounts, {
    bool forceRefresh = false,
  }) async {
    final activeAccounts = accounts.where((a) => !a.archived).toList(growable: false);
    final fingerprint = _sourceFingerprint(
      profile: profile,
      rates: rates,
      accounts: activeAccounts,
      assets: assets,
    );
    if (!forceRefresh &&
        fingerprint == _lastSourceFingerprint &&
        state.status == AnalyticsStatus.ready) {
      return;
    }
    await _fetchFromSource(
      profile: profile,
      rates: rates,
      assets: assets,
      accounts: activeAccounts,
      silent: state.status == AnalyticsStatus.ready,
      fingerprint: fingerprint,
    );
  }

  void invalidateCache() {
    _lastSourceFingerprint = null;
  }

  String _sourceFingerprint({
    required ProfileEntity profile,
    required RatesSnapshotEntity? rates,
    required List<AccountEntity> accounts,
    required List<AssetEntity> assets,
  }) {
    final accountIds = accounts.map((a) => a.id).toList()..sort();
    final assetIds = assets.map((a) => a.id).toList()..sort();
    return '${profile.baseCurrency}|${profile.baseAssetId ?? ""}|'
        '${accountIds.join(",")}|${assetIds.join(",")}|'
        '${rates?.asOf.toIso8601String() ?? ""}';
  }

  Future<void> _fetchFromSource({
    required ProfileEntity profile,
    required RatesSnapshotEntity? rates,
    required List<AssetEntity> assets,
    required List<AccountEntity> accounts,
    required bool silent,
    required String fingerprint,
  }) async {
    if (_isFetching) {
      _queuedFetch = true;
      _queuedSilent = _queuedSilent && silent;
      _queuedProfile = profile;
      _queuedRates = rates;
      _queuedAssets = assets;
      _queuedAccounts = accounts;
      _queuedFingerprint = fingerprint;
      return;
    }

    _isFetching = true;
    try {
      if (!silent) {
        emit(
          state.copyWith(status: AnalyticsStatus.loading, failureCode: null, failureMessage: null),
        );
      }

      if (accounts.isEmpty) {
        _lastSourceFingerprint = fingerprint;
        emit(
          state.copyWith(
            status: AnalyticsStatus.ready,
            baseCurrency: profile.baseCurrency,
            breakdown: const [],
            updates: const [],
          ),
        );
        return;
      }

      final summaryResult = await _getAnalyticsSummary(updatesLimit: 240);
      if (isClosed) {
        return;
      }

      switch (summaryResult) {
        case Success<AnalyticsSummaryEntity>(value: final summary):
          final breakdown = _toBreakdown(summary.breakdown);
          final updates = _toUpdates(summary.updates);
          _lastSourceFingerprint = fingerprint;
          emit(
            state.copyWith(
              status: AnalyticsStatus.ready,
              baseCurrency: summary.baseCurrency,
              ratesAsOf: summary.asOf,
              breakdown: breakdown,
              updates: updates,
              failureCode: null,
              failureMessage: null,
            ),
          );
        case FailureResult<AnalyticsSummaryEntity>(failure: final failure):
          emit(
            state.copyWith(
              status: AnalyticsStatus.error,
              failureCode: failure.code,
              failureMessage: failure.message,
            ),
          );
      }
    } finally {
      _isFetching = false;
      if (_queuedFetch) {
        final nextSilent = _queuedSilent;
        final nextProfile = _queuedProfile;
        final nextRates = _queuedRates;
        final nextAssets = _queuedAssets;
        final nextAccounts = _queuedAccounts;
        final nextFingerprint = _queuedFingerprint ?? '';
        _queuedFetch = false;
        _queuedSilent = true;
        _queuedProfile = null;
        _queuedRates = null;
        _queuedAssets = const [];
        _queuedAccounts = const [];
        _queuedFingerprint = null;
        if (nextProfile != null) {
          await _fetchFromSource(
            profile: nextProfile,
            rates: nextRates,
            assets: nextAssets,
            accounts: nextAccounts,
            silent: nextSilent,
            fingerprint: nextFingerprint,
          );
        }
      }
    }
  }

  List<AnalyticsBreakdownItem> _toBreakdown(List<AnalyticsBreakdownEntity> items) {
    final filtered = items.where((item) => item.value != Decimal.zero).toList(growable: false);
    final total = filtered.fold<Decimal>(Decimal.zero, (sum, item) => sum + item.value);

    final breakdown =
        filtered
            .map(
              (item) => AnalyticsBreakdownItem(
                assetCode: item.assetCode,
                value: item.value,
                percent: total == Decimal.zero
                    ? Decimal.zero
                    : divideToDecimal(item.value * Decimal.fromInt(100), total),
                originalAmount: item.originalAmount,
              ),
            )
            .toList(growable: false)
          ..sort((a, b) => b.value.compareTo(a.value));

    return breakdown;
  }

  List<AnalyticsUpdateItem> _toUpdates(List<AnalyticsUpdateEntity> items) {
    final updates =
        items
            .where((item) => item.diffAmount != Decimal.zero)
            .map(
              (item) => AnalyticsUpdateItem(
                accountName: item.accountName,
                subaccountName: item.subaccountName,
                assetCode: item.assetCode,
                diffAmount: item.diffAmount,
                diffBaseAmount: item.diffBaseAmount,
                entryDate: item.entryDate,
              ),
            )
            .toList(growable: false)
          ..sort((a, b) => b.entryDate.compareTo(a.entryDate));

    return updates;
  }
}
