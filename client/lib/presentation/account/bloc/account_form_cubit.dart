import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/account/usecase/create_account_usecase.dart';
import 'package:asset_tuner/domain/account/usecase/get_accounts_usecase.dart';
import 'package:asset_tuner/domain/account/usecase/update_account_usecase.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/entitlement/usecase/get_entitlements_for_plan_usecase.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/usecase/bootstrap_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/get_profile_usecase.dart';

part 'account_form_cubit.freezed.dart';
part 'account_form_state.dart';

@injectable
class AccountFormCubit extends Cubit<AccountFormState> {
  AccountFormCubit(
    this._getCachedSession,
    this._getProfile,
    this._bootstrapProfile,
    this._getEntitlementsForPlan,
    this._getAccounts,
    this._createAccount,
    this._updateAccount,
  ) : super(const AccountFormState());

  final GetCachedSessionUseCase _getCachedSession;
  final GetProfileUseCase _getProfile;
  final BootstrapProfileUseCase _bootstrapProfile;
  final GetEntitlementsForPlanUseCase _getEntitlementsForPlan;
  final GetAccountsUseCase _getAccounts;
  final CreateAccountUseCase _createAccount;
  final UpdateAccountUseCase _updateAccount;

  Future<void> load({String? accountId}) async {
    emit(
      state.copyWith(
        status: AccountFormStatus.loading,
        failureCode: null,
        nameError: null,
        navigation: null,
      ),
    );

    final session = await _getCachedSession();
    if (session == null) {
      emit(
        state.copyWith(
          status: AccountFormStatus.error,
          failureCode: 'unauthorized',
          navigation: const AccountFormNavigation(
            destination: AccountFormDestination.signIn,
          ),
        ),
      );
      return;
    }

    final profile = await _loadProfile(session);
    if (profile == null) {
      emit(
        state.copyWith(status: AccountFormStatus.error, failureCode: 'unknown'),
      );
      return;
    }

    final accounts = await _getAccounts(session.userId);
    final activeCount = switch (accounts) {
      Success<List<AccountEntity>>(value: final list) =>
        list.where((a) => !a.archived).length,
      FailureResult<List<AccountEntity>>() => 0,
    };

    AccountEntity? existing;
    if (accountId != null) {
      existing = switch (accounts) {
        Success<List<AccountEntity>>(value: final list) =>
          list.where((a) => a.id == accountId).firstOrNull,
        FailureResult<List<AccountEntity>>() => null,
      };
    }

    emit(
      state.copyWith(
        status: AccountFormStatus.ready,
        userId: session.userId,
        plan: profile.plan,
        activeAccountCount: activeCount,
        accountId: existing?.id ?? accountId,
        initialName: existing?.name,
        name: existing?.name ?? '',
        type: existing?.type ?? AccountType.bank,
      ),
    );
  }

  void consumeNavigation() {
    emit(state.copyWith(navigation: null));
  }

  void updateName(String name) {
    emit(state.copyWith(name: name, nameError: null));
  }

  void selectType(AccountType type) {
    emit(state.copyWith(type: type));
  }

  Future<void> save() async {
    final userId = state.userId;
    final type = state.type;
    if (userId == null || type == null) {
      return;
    }

    final normalized = state.name.trim();
    if (normalized.isEmpty) {
      emit(state.copyWith(nameError: 'required'));
      return;
    }

    final isCreating = state.accountId == null;
    final entitlements = _getEntitlementsForPlan(state.plan);
    if (isCreating && state.activeAccountCount >= entitlements.maxAccounts) {
      emit(
        state.copyWith(
          navigation: const AccountFormNavigation(
            destination: AccountFormDestination.paywall,
          ),
        ),
      );
      return;
    }

    emit(state.copyWith(isSaving: true, failureCode: null));

    final result = isCreating
        ? await _createAccount(userId: userId, name: normalized, type: type)
        : await _updateAccount(
            userId: userId,
            accountId: state.accountId!,
            name: normalized,
            type: type,
          );

    switch (result) {
      case Success<AccountEntity>(value: final account):
        emit(
          state.copyWith(
            isSaving: false,
            navigation: AccountFormNavigation(
              destination: AccountFormDestination.backSaved,
              accountId: account.id,
            ),
          ),
        );
      case FailureResult<AccountEntity>(failure: final failure):
        emit(state.copyWith(isSaving: false, failureCode: failure.code));
    }
  }

  Future<ProfileEntity?> _loadProfile(AuthSessionEntity session) async {
    final result = await _getProfile(session.userId);
    switch (result) {
      case Success<ProfileEntity>(value: final profile):
        return profile;
      case FailureResult<ProfileEntity>():
        final bootstrap = await _bootstrapProfile(session.userId);
        switch (bootstrap) {
          case Success(value: final data):
            return data.profile;
          case FailureResult():
            return null;
        }
    }
  }
}

extension on Iterable<AccountEntity> {
  AccountEntity? get firstOrNull {
    for (final item in this) {
      return item;
    }
    return null;
  }
}
