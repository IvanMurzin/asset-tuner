import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/core_ui/components/ds_dialog.dart';
import 'package:asset_tuner/domain/auth/usecase/delete_account_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/sign_out_usecase.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/usecase/bootstrap_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/get_profile_usecase.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';

part 'profile_cubit.freezed.dart';
part 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._getCachedSession,
    this._getProfile,
    this._bootstrapProfile,
    this._signOut,
    this._deleteAccount,
  ) : super(const ProfileState());

  final GetCachedSessionUseCase _getCachedSession;
  final GetProfileUseCase _getProfile;
  final BootstrapProfileUseCase _bootstrapProfile;
  final SignOutUseCase _signOut;
  final DeleteAccountUseCase _deleteAccount;

  Future<void> load() async {
    emit(state.copyWith(status: ProfileStatus.loading, failureCode: null));

    final session = await _getCachedSession();
    if (session == null) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          failureCode: 'unauthorized',
          navigation: const ProfileNavigation(
            destination: ProfileDestination.signIn,
          ),
        ),
      );
      return;
    }

    final profile = await _loadProfile();
    if (profile == null) {
      emit(state.copyWith(status: ProfileStatus.error, failureCode: 'unknown'));
      return;
    }

    emit(
      state.copyWith(
        status: ProfileStatus.ready,
        email: session.email,
        baseCurrency: profile.baseCurrency,
        plan: profile.plan,
      ),
    );
  }

  void setBaseCurrency(String baseCurrency) {
    if (state.status != ProfileStatus.ready) {
      return;
    }
    emit(state.copyWith(baseCurrency: baseCurrency));
  }

  void setPlan(String plan) {
    if (state.status != ProfileStatus.ready) {
      return;
    }
    emit(state.copyWith(plan: plan));
  }

  void consumeNavigation() {
    emit(state.copyWith(navigation: null));
  }

  Future<void> signOut() async {
    emit(state.copyWith(isSigningOut: true));
    final result = await _signOut();
    switch (result) {
      case Success<void>():
        emit(
          state.copyWith(
            isSigningOut: false,
            navigation: const ProfileNavigation(
              destination: ProfileDestination.signIn,
            ),
          ),
        );
      case FailureResult<void>(failure: final failure):
        emit(
          state.copyWith(
            isSigningOut: false,
            status: ProfileStatus.ready,
            failureCode: failure.code,
          ),
        );
    }
  }

  void confirmDelete(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (context) => DSDialog(
        title: l10n.profileDeleteConfirmTitle,
        content: Text(l10n.profileDeleteConfirmBody),
        primaryLabel: l10n.profileDeleteConfirmCta,
        onPrimary: () {
          Navigator.of(context).pop();
          deleteAccount();
        },
        secondaryLabel: l10n.profileDeleteConfirmCancel,
        onSecondary: () => Navigator.of(context).pop(),
        isDestructive: true,
      ),
    );
  }

  Future<void> deleteAccount() async {
    emit(state.copyWith(isDeletingAccount: true));
    final result = await _deleteAccount();
    switch (result) {
      case Success<void>():
        emit(
          state.copyWith(
            isDeletingAccount: false,
            navigation: const ProfileNavigation(
              destination: ProfileDestination.signIn,
            ),
          ),
        );
      case FailureResult<void>(failure: final failure):
        emit(
          state.copyWith(
            isDeletingAccount: false,
            status: ProfileStatus.ready,
            failureCode: failure.code,
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
