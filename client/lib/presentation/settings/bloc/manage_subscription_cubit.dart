import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/usecase/update_plan_usecase.dart';
import 'package:asset_tuner/domain/subscription/entity/subscription_info_entity.dart';
import 'package:asset_tuner/domain/subscription/usecase/get_customer_info_usecase.dart';
import 'package:asset_tuner/domain/subscription/usecase/restore_purchases_usecase.dart';

part 'manage_subscription_cubit.freezed.dart';
part 'manage_subscription_state.dart';

@injectable
class ManageSubscriptionCubit extends Cubit<ManageSubscriptionState> {
  ManageSubscriptionCubit(
    this._getCachedSession,
    this._getCustomerInfo,
    this._restorePurchases,
    this._updatePlan,
  ) : super(const ManageSubscriptionState());

  final GetCachedSessionUseCase _getCachedSession;
  final GetCustomerInfoUseCase _getCustomerInfo;
  final RestorePurchasesUseCase _restorePurchases;
  final UpdatePlanUseCase _updatePlan;

  Future<void> load() async {
    emit(state.copyWith(status: ManageSubscriptionStatus.loading, failureCode: null, banner: null));

    final session = await _getCachedSession();
    if (isClosed) return;
    if (session == null) {
      emit(state.copyWith(status: ManageSubscriptionStatus.error, failureCode: 'unauthorized'));
      return;
    }

    final result = await _getCustomerInfo();
    if (isClosed) return;
    switch (result) {
      case Success<SubscriptionInfoEntity>(value: final info):
        emit(
          state.copyWith(
            status: ManageSubscriptionStatus.ready,
            plan: info.isPro ? 'paid' : 'free',
          ),
        );
      case FailureResult<SubscriptionInfoEntity>(failure: final failure):
        emit(
          state.copyWith(
            status: ManageSubscriptionStatus.error,
            failureCode: failure.code,
            failureMessage: failure.message,
          ),
        );
    }
  }

  void onCustomerCenterClosed() async {
    if (state.status != ManageSubscriptionStatus.ready) return;
    final result = await _getCustomerInfo();
    if (isClosed) return;
    switch (result) {
      case Success<SubscriptionInfoEntity>(value: final info):
        emit(state.copyWith(plan: info.isPro ? 'paid' : 'free'));
      case FailureResult<SubscriptionInfoEntity>():
        break;
    }
  }

  Future<void> restore() async {
    if (state.status != ManageSubscriptionStatus.ready) return;
    emit(state.copyWith(isUpdating: true, banner: null));
    final result = await _restorePurchases();
    if (isClosed) return;
    switch (result) {
      case Success<SubscriptionInfoEntity>(value: final info):
        final plan = info.isPro ? 'paid' : 'free';
        if (info.isPro) {
          final syncResult = await _updatePlan('paid');
          if (isClosed) return;
          switch (syncResult) {
            case Success<ProfileEntity>(value: final profile):
              emit(
                state.copyWith(
                  isUpdating: false,
                  plan: profile.plan,
                  banner: ManageSubscriptionBanner.restoreSuccess,
                ),
              );
            case FailureResult<ProfileEntity>():
              emit(
                state.copyWith(
                  isUpdating: false,
                  plan: plan,
                  banner: ManageSubscriptionBanner.restoreSuccess,
                ),
              );
          }
        } else {
          emit(
            state.copyWith(
              isUpdating: false,
              plan: plan,
              banner: ManageSubscriptionBanner.restoreSuccess,
            ),
          );
        }
      case FailureResult<SubscriptionInfoEntity>(failure: final failure):
        emit(
          state.copyWith(
            isUpdating: false,
            failureCode: failure.code,
            failureMessage: failure.message,
            banner: ManageSubscriptionBanner.updateFailure,
          ),
        );
    }
  }

  void dismissBanner() {
    emit(state.copyWith(banner: null));
  }
}
