import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/usecase/bootstrap_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/get_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/update_plan_usecase.dart';

part 'manage_subscription_cubit.freezed.dart';
part 'manage_subscription_state.dart';

@injectable
class ManageSubscriptionCubit extends Cubit<ManageSubscriptionState> {
  ManageSubscriptionCubit(
    this._getCachedSession,
    this._getProfile,
    this._bootstrapProfile,
    this._updatePlan,
  ) : super(const ManageSubscriptionState());

  final GetCachedSessionUseCase _getCachedSession;
  final GetProfileUseCase _getProfile;
  final BootstrapProfileUseCase _bootstrapProfile;
  final UpdatePlanUseCase _updatePlan;

  Future<void> load() async {
    emit(
      state.copyWith(
        status: ManageSubscriptionStatus.loading,
        failureCode: null,
        banner: null,
      ),
    );

    final session = await _getCachedSession();
    if (isClosed) return;
    if (session == null) {
      emit(
        state.copyWith(
          status: ManageSubscriptionStatus.error,
          failureCode: 'unauthorized',
        ),
      );
      return;
    }

    final profile = await _loadProfile();
    if (isClosed) return;
    if (profile == null) {
      emit(
        state.copyWith(
          status: ManageSubscriptionStatus.error,
          failureCode: 'unknown',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: ManageSubscriptionStatus.ready,
        plan: profile.plan,
      ),
    );
  }

  Future<void> manage() async {
    await _setPlan('paid', banner: ManageSubscriptionBanner.manageSuccess);
  }

  Future<void> restore() async {
    await _setPlan('paid', banner: ManageSubscriptionBanner.restoreSuccess);
  }

  Future<void> cancel() async {
    await _setPlan('free', banner: ManageSubscriptionBanner.cancelSuccess);
  }

  void dismissBanner() {
    emit(state.copyWith(banner: null));
  }

  Future<void> _setPlan(
    String plan, {
    required ManageSubscriptionBanner banner,
  }) async {
    if (state.status != ManageSubscriptionStatus.ready) {
      return;
    }
    emit(state.copyWith(isUpdating: true, banner: null));
    final result = await _updatePlan(plan);
    if (isClosed) return;
    switch (result) {
      case Success<ProfileEntity>(value: final profile):
        emit(
          state.copyWith(
            isUpdating: false,
            status: ManageSubscriptionStatus.ready,
            plan: profile.plan,
            banner: banner,
          ),
        );
      case FailureResult<ProfileEntity>(failure: final failure):
        emit(
          state.copyWith(
            isUpdating: false,
            status: ManageSubscriptionStatus.ready,
            failureCode: failure.code,
            failureMessage: failure.message,
            banner: ManageSubscriptionBanner.updateFailure,
          ),
        );
    }
  }

  Future<ProfileEntity?> _loadProfile() async {
    final result = await _getProfile();
    switch (result) {
      case Success<ProfileEntity>(value: final profile):
        return profile;
      case FailureResult<ProfileEntity>():
        final bootstrap = await _bootstrapProfile();
        switch (bootstrap) {
          case Success(value: final data):
            return data.profile;
          case FailureResult():
            return null;
        }
    }
  }
}
