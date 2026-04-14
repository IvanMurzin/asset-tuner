part of 'subaccount_create_cubit.dart';

enum SubaccountCreateStatus { idle, loading, success, error }

enum SubaccountCreateFieldError { required }

@freezed
abstract class SubaccountCreateState with _$SubaccountCreateState {
  const factory SubaccountCreateState({
    @Default(SubaccountCreateStatus.idle) SubaccountCreateStatus status,
    SubaccountEntity? subaccount,
    SubaccountCreateFieldError? nameError,
    String? failureCode,
    String? failureMessage,
  }) = _SubaccountCreateState;
}
