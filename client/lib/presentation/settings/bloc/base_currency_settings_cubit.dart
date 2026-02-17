import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/asset/entity/asset_picker_item_entity.dart';
import 'package:asset_tuner/domain/asset/usecase/get_assets_for_subaccount_picker_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/entitlement/entity/entitlements_entity.dart';
import 'package:asset_tuner/domain/profile/usecase/bootstrap_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/update_base_currency_usecase.dart';

part 'base_currency_settings_cubit.freezed.dart';
part 'base_currency_settings_state.dart';

@injectable
class BaseCurrencySettingsCubit extends Cubit<BaseCurrencySettingsState> {
  BaseCurrencySettingsCubit(
    this._getCachedSession,
    this._bootstrapProfile,
    this._getAssetsForPicker,
    this._updateBaseCurrency,
  ) : super(const BaseCurrencySettingsState());

  final GetCachedSessionUseCase _getCachedSession;
  final BootstrapProfileUseCase _bootstrapProfile;
  final GetAssetsForSubaccountPickerUseCase _getAssetsForPicker;
  final UpdateBaseCurrencyUseCase _updateBaseCurrency;

  static const _minQueryLength = 2;
  static const _maxResults = 50;

  Future<void> load() async {
    emit(
      state.copyWith(
        status: BaseCurrencySettingsStatus.loading,
        loadFailureCode: null,
        bannerType: null,
        bannerFailureCode: null,
      ),
    );

    final session = await _getCachedSession();
    if (isClosed) return;
    if (session == null) {
      emit(
        state.copyWith(
          status: BaseCurrencySettingsStatus.error,
          loadFailureCode: 'unauthorized',
          navigation: const BaseCurrencySettingsNavigation(
            destination: BaseCurrencySettingsDestination.signIn,
          ),
        ),
      );
      return;
    }

    final bootstrap = await _bootstrapProfile();
    final profile = switch (bootstrap) {
      Success(value: final data) => data.profile,
      FailureResult() => null,
    };
    if (isClosed) return;
    if (profile == null) {
      emit(state.copyWith(status: BaseCurrencySettingsStatus.error, loadFailureCode: 'unknown'));
      return;
    }

    final catalog = await _getAssetsForPicker.call(kind: AssetKind.fiat);
    if (isClosed) return;
    switch (catalog) {
      case Success<List<AssetPickerItemEntity>>(value: final currencies):
        if (currencies.isEmpty) {
          emit(
            state.copyWith(
              status: BaseCurrencySettingsStatus.error,
              currentCode: profile.baseCurrency,
              selectedCode: profile.baseCurrency,
              plan: profile.plan,
              entitlements: profile.entitlements,
              loadFailureCode: 'unknown',
            ),
          );
          return;
        }
        final next = state.copyWith(
          status: BaseCurrencySettingsStatus.ready,
          currentCode: profile.baseCurrency,
          selectedCode: profile.baseCurrency,
          plan: profile.plan,
          entitlements: profile.entitlements,
          currencies: currencies,
        );
        emit(_recomputeVisible(next));
      case FailureResult<List<AssetPickerItemEntity>>(failure: final failure):
        emit(
          state.copyWith(
            status: BaseCurrencySettingsStatus.error,
            currentCode: profile.baseCurrency,
            selectedCode: profile.baseCurrency,
            plan: profile.plan,
            entitlements: profile.entitlements,
            loadFailureCode: failure.code,
            loadFailureMessage: failure.message,
          ),
        );
    }
  }

  void updateQuery(String query) {
    emit(_recomputeVisible(state.copyWith(query: query, showAll: false)));
  }

  void showAll() {
    emit(_recomputeVisible(state.copyWith(showAll: true)));
  }

  void selectCurrency(String code) {
    if (_isAllowed(code)) {
      emit(state.copyWith(selectedCode: code, bannerType: null, bannerFailureCode: null));
      return;
    }

    emit(
      state.copyWith(
        navigation: BaseCurrencySettingsNavigation(
          destination: BaseCurrencySettingsDestination.paywall,
          requestedCode: code,
        ),
      ),
    );
  }

  void consumeNavigation() {
    emit(state.copyWith(navigation: null));
  }

  Future<void> save() async {
    final selected = state.selectedCode;
    final current = state.currentCode;

    if (state.status != BaseCurrencySettingsStatus.ready || selected == null || current == null) {
      return;
    }

    if (selected == current) {
      emit(
        state.copyWith(
          navigation: const BaseCurrencySettingsNavigation(
            destination: BaseCurrencySettingsDestination.back,
          ),
        ),
      );
      return;
    }

    if (!_isAllowed(selected)) {
      emit(
        state.copyWith(
          navigation: BaseCurrencySettingsNavigation(
            destination: BaseCurrencySettingsDestination.paywall,
            requestedCode: selected,
          ),
        ),
      );
      return;
    }

    emit(state.copyWith(isSaving: true, bannerType: null, bannerFailureCode: null));

    final result = await _updateBaseCurrency(selected);
    if (isClosed) return;
    switch (result) {
      case Success(value: final profile):
        emit(
          state.copyWith(
            isSaving: false,
            currentCode: profile.baseCurrency,
            selectedCode: profile.baseCurrency,
            navigation: const BaseCurrencySettingsNavigation(
              destination: BaseCurrencySettingsDestination.back,
            ),
          ),
        );
      case FailureResult(failure: final failure):
        emit(
          state.copyWith(
            isSaving: false,
            bannerType: BaseCurrencySettingsBannerType.saveFailure,
            bannerFailureCode: failure.code,
            bannerFailureMessage: failure.message,
          ),
        );
    }
  }

  bool _isAllowed(String code) {
    final entitlements = state.entitlements;
    if (entitlements == null) {
      return true;
    }
    if (entitlements.anyBaseCurrency) {
      return true;
    }
    final match = state.currencies.where((e) => e.code.toUpperCase() == code.toUpperCase());
    return match.isNotEmpty && match.first.isUnlocked;
  }

  BaseCurrencySettingsState _recomputeVisible(BaseCurrencySettingsState input) {
    final query = input.query.trim().toLowerCase();
    final currencies = input.currencies;

    if (currencies.isEmpty) {
      return input.copyWith(visibleCurrencies: const [], hasMoreResults: false);
    }

    if (input.showAll) {
      final visible = currencies.take(_maxResults).toList();
      return input.copyWith(
        visibleCurrencies: visible,
        hasMoreResults: currencies.length > visible.length,
      );
    }

    if (query.length < _minQueryLength) {
      final visible = currencies.take(_maxResults).toList();
      return input.copyWith(
        visibleCurrencies: visible,
        hasMoreResults: currencies.length > visible.length,
      );
    }

    final matched = currencies.where((item) {
      return item.code.toLowerCase().contains(query) || item.name.toLowerCase().contains(query);
    }).toList();
    final limited = matched.take(_maxResults).toList();
    return input.copyWith(
      visibleCurrencies: limited,
      hasMoreResults: matched.length > limited.length,
    );
  }
}
