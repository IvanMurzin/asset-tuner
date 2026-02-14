import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/account/usecase/get_accounts_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';

part 'archived_accounts_state.dart';

@injectable
class ArchivedAccountsCubit extends Cubit<ArchivedAccountsState> {
  ArchivedAccountsCubit(
    this._getCachedSession,
    this._getAccounts,
  ) : super(const ArchivedAccountsState());

  final GetCachedSessionUseCase _getCachedSession;
  final GetAccountsUseCase _getAccounts;

  Future<void> load() async {
    emit(state.copyWith(status: ArchivedAccountsStatus.loading, clearFailure: true));

    final session = await _getCachedSession();
    if (isClosed) return;
    if (session == null) {
      emit(
        state.copyWith(
          status: ArchivedAccountsStatus.error,
          failureCode: 'unauthorized',
        ),
      );
      return;
    }

    final result = await _getAccounts();
    if (isClosed) return;
    switch (result) {
      case Success<List<AccountEntity>>(value: final list):
        final archived = list.where((a) => a.archived).toList();
        emit(ArchivedAccountsState(
          status: ArchivedAccountsStatus.ready,
          accounts: archived,
          failureCode: null,
        ));
      case FailureResult<List<AccountEntity>>(failure: final failure):
        emit(
          state.copyWith(
            status: ArchivedAccountsStatus.error,
            failureCode: failure.code,
            failureMessage: failure.message,
          ),
        );
    }
  }
}
