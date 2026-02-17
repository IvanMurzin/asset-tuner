import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/asset/entity/asset_picker_item_entity.dart';
import 'package:asset_tuner/domain/asset/usecase/get_assets_for_subaccount_picker_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/entitlement/entity/entitlements_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/usecase/get_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/update_base_currency_usecase.dart';

part 'base_currency_state.dart';
part 'base_currency_cubit.freezed.dart';

@injectable
class BaseCurrencyCubit extends Cubit<BaseCurrencyState> {
  BaseCurrencyCubit(
    this._getCachedSessionUseCase,
    this._getAssetsForPickerUseCase,
    this._getProfileUseCase,
    this._updateBaseCurrencyUseCase,
  ) : super(const BaseCurrencyState()) {
    load();
  }

  final GetCachedSessionUseCase _getCachedSessionUseCase;
  final GetAssetsForSubaccountPickerUseCase _getAssetsForPickerUseCase;
  final GetProfileUseCase _getProfileUseCase;
  final UpdateBaseCurrencyUseCase _updateBaseCurrencyUseCase;

  Future<void> load() async {
    emit(state.copyWith(status: BaseCurrencyStatus.loading));
    final session = await _getCachedSessionUseCase();
    if (isClosed) return;
    if (session == null) {
      emit(
        state.copyWith(
          navigation: const BaseCurrencyNavigation(destination: BaseCurrencyDestination.signIn),
        ),
      );
      return;
    }

    final profileResult = await _getProfileUseCase();
    final currenciesResult = await _getAssetsForPickerUseCase.call(kind: AssetKind.fiat);
    if (isClosed) return;

    late final ProfileEntity profile;
    switch (profileResult) {
      case FailureResult(:final failure):
        emit(
          state.copyWith(
            status: BaseCurrencyStatus.error,
            loadFailureCode: failure.code,
            loadFailureMessage: failure.message,
          ),
        );
        return;
      case Success(:final value):
        profile = value;
    }

    late final List<AssetPickerItemEntity> currencies;
    switch (currenciesResult) {
      case FailureResult(:final failure):
        emit(
          state.copyWith(
            status: BaseCurrencyStatus.error,
            loadFailureCode: failure.code,
            loadFailureMessage: failure.message,
          ),
        );
        return;
      case Success(:final value):
        if (value.isEmpty) {
          emit(state.copyWith(status: BaseCurrencyStatus.error, loadFailureCode: 'unknown'));
          return;
        }
        currencies = value;
    }

    emit(
      state.copyWith(
        status: BaseCurrencyStatus.ready,
        currencies: currencies,
        selectedCode: profile.baseCurrency,
        plan: profile.plan,
        entitlements: profile.entitlements,
      ),
    );
  }

  void updateQuery(String query) {
    emit(state.copyWith(query: query));
  }

  void selectCurrency(String code) {
    emit(state.copyWith(selectedCode: code, bannerType: null));
  }

  Future<void> continueNext() async {
    final selected = state.selectedCode;
    if (selected == null || selected.isEmpty) {
      emit(state.copyWith(bannerType: BaseCurrencyBannerType.selectCurrency));
      return;
    }

    if (!_isAllowedForEntitlements(selected, state.entitlements, state.currencies)) {
      emit(
        state.copyWith(
          navigation: const BaseCurrencyNavigation(destination: BaseCurrencyDestination.paywall),
        ),
      );
      return;
    }

    await _saveSelection(selected);
  }

  Future<void> useUsdForNow() async {
    await _saveSelection('USD');
  }

  void consumeNavigation() {
    emit(state.copyWith(navigation: null));
  }

  Future<void> _saveSelection(String code) async {
    emit(state.copyWith(isSaving: true, bannerType: null));
    final session = await _getCachedSessionUseCase();
    if (isClosed) return;
    if (session == null) {
      emit(
        state.copyWith(
          isSaving: false,
          navigation: const BaseCurrencyNavigation(destination: BaseCurrencyDestination.signIn),
        ),
      );
      return;
    }

    final result = await _updateBaseCurrencyUseCase(code);
    if (isClosed) return;
    switch (result) {
      case FailureResult(:final failure):
        emit(
          state.copyWith(
            isSaving: false,
            bannerType: BaseCurrencyBannerType.saveFailure,
            bannerFailureCode: failure.code,
            bannerFailureMessage: failure.message,
          ),
        );
      case Success():
        emit(
          state.copyWith(
            isSaving: false,
            navigation: const BaseCurrencyNavigation(destination: BaseCurrencyDestination.main),
          ),
        );
    }
  }

  bool _isAllowedForEntitlements(
    String code,
    EntitlementsEntity? entitlements,
    List<AssetPickerItemEntity> currencies,
  ) {
    if (entitlements == null) {
      return false;
    }
    if (entitlements.anyBaseCurrency) {
      return true;
    }
    final match = currencies.where((e) => e.code.toUpperCase() == code.toUpperCase());
    return match.isNotEmpty && match.first.isUnlocked;
  }
}
