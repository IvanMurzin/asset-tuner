part of 'subaccount_create_cubit.dart';

enum SubaccountCreateStatus { idle, loading, success, error }

@freezed
abstract class SubaccountCreateState with _$SubaccountCreateState {
  const factory SubaccountCreateState({
    @Default(SubaccountCreateStatus.idle) SubaccountCreateStatus status,
    SubaccountEntity? subaccount,
    String? failureCode,
    String? failureMessage,
  }) = _SubaccountCreateState;
}
