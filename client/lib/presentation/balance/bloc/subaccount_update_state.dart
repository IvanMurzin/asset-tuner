part of 'subaccount_update_cubit.dart';

enum SubaccountUpdateStatus { idle, loading, success, error }

@freezed
abstract class SubaccountUpdateState with _$SubaccountUpdateState {
  const factory SubaccountUpdateState({
    @Default(SubaccountUpdateStatus.idle) SubaccountUpdateStatus status,
    SubaccountEntity? subaccount,
    String? failureCode,
    String? failureMessage,
  }) = _SubaccountUpdateState;
}
