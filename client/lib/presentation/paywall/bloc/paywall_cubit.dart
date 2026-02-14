import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/usecase/bootstrap_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/get_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/update_plan_usecase.dart';
import 'package:asset_tuner/presentation/paywall/entity/paywall_args.dart';

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

  Future<void> load({PaywallReason? reason}) async {
    emit(
      state.copyWith(
        status: PaywallStatus.loading,
        loadFailureCode: null,
        upgradeFailureCode: null,
      ),
    );

    final session = await _getCachedSession();
    if (isClosed) return;
    if (session == null) {
      emit(
        state.copyWith(
          status: PaywallStatus.error,
          loadFailureCode: 'unauthorized',
        ),
      );
      return;
    }

    final profileResult = await _getProfile();
    if (isClosed) return;
    switch (profileResult) {
      case Success<ProfileEntity>(value: final profile):
        logger.i(
          'paywall_viewed reason=${reason?.name ?? 'unknown'} entitlements=verified',
        );
        emit(
          state.copyWith(
            status: PaywallStatus.ready,
            plan: profile.plan,
            entitlementsUnverified: false,
            loadFailureCode: null,
          ),
        );
      case FailureResult<ProfileEntity>(failure: final failure):
        final bootstrap = await _bootstrapProfile();
        if (isClosed) return;
        final bootProfile = switch (bootstrap) {
          Success(value: final data) => data.profile,
          FailureResult() => null,
        };
        logger.i(
          'paywall_viewed reason=${reason?.name ?? 'unknown'} entitlements=unverified',
        );
        emit(
          state.copyWith(
            status: PaywallStatus.ready,
            plan: bootProfile?.plan ?? 'free',
            entitlementsUnverified: true,
            loadFailureCode: failure.code,
            loadFailureMessage: failure.message,
          ),
        );
    }
  }

  void selectPlan(PaywallPlanOption plan) {
    emit(state.copyWith(selectedPlan: plan));
  }

  Future<void> upgrade() async {
    if (state.status != PaywallStatus.ready) {
      return;
    }
    emit(state.copyWith(isUpdating: true, upgradeFailureCode: null));
    logger.i('purchase_started plan=${state.selectedPlan.name}');
    final result = await _updatePlan('paid');
    if (isClosed) return;
    switch (result) {
      case Success<ProfileEntity>(value: final profile):
        logger.i('purchase_succeeded plan=${state.selectedPlan.name}');
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
        logger.i(
          'purchase_failed plan=${state.selectedPlan.name} code=${failure.code}',
        );
        emit(
          state.copyWith(
            isUpdating: false,
            upgradeFailureCode: failure.code,
            upgradeFailureMessage: failure.message,
          ),
        );
    }
  }

  void consumeNavigation() {
    emit(state.copyWith(navigation: null));
  }
}
