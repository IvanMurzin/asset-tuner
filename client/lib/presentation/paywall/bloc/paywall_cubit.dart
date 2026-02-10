import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/usecase/bootstrap_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/get_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/update_plan_usecase.dart';

part 'paywall_cubit.freezed.dart';
part 'paywall_state.dart';

@injectable
class PaywallCubit extends Cubit<PaywallState> {
  PaywallCubit(
    this._getCachedSession,
    this._getProfile,
    this._bootstrapProfile,
    this._updatePlan,
  ) : super(const PaywallState());

  final GetCachedSessionUseCase _getCachedSession;
  final GetProfileUseCase _getProfile;
  final BootstrapProfileUseCase _bootstrapProfile;
  final UpdatePlanUseCase _updatePlan;

  Future<void> load() async {
    emit(state.copyWith(status: PaywallStatus.loading, failureCode: null));

    final session = await _getCachedSession();
    if (session == null) {
      emit(
        state.copyWith(
          status: PaywallStatus.error,
          failureCode: 'unauthorized',
        ),
      );
      return;
    }

    final profile = await _loadProfile(session.userId);
    if (profile == null) {
      emit(state.copyWith(status: PaywallStatus.error, failureCode: 'unknown'));
      return;
    }

    emit(
      state.copyWith(
        status: PaywallStatus.ready,
        userId: session.userId,
        plan: profile.plan,
      ),
    );
  }

  Future<void> upgrade() async {
    final userId = state.userId;
    if (userId == null) {
      return;
    }
    emit(state.copyWith(isUpdating: true));
    final result = await _updatePlan(userId, 'paid');
    switch (result) {
      case Success<ProfileEntity>(value: final profile):
        emit(
          state.copyWith(
            isUpdating: false,
            plan: profile.plan,
            navigation: const PaywallNavigation(
              PaywallDestination.closeUpgraded,
            ),
          ),
        );
      case FailureResult<ProfileEntity>(failure: final failure):
        emit(state.copyWith(isUpdating: false, failureCode: failure.code));
    }
  }

  void consumeNavigation() {
    emit(state.copyWith(navigation: null));
  }

  Future<ProfileEntity?> _loadProfile(String userId) async {
    final result = await _getProfile(userId);
    switch (result) {
      case Success<ProfileEntity>(value: final profile):
        return profile;
      case FailureResult<ProfileEntity>():
        final bootstrap = await _bootstrapProfile(userId);
        switch (bootstrap) {
          case Success(value: final data):
            return data.profile;
          case FailureResult():
            return null;
        }
    }
  }
}
