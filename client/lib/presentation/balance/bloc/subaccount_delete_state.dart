part of 'subaccount_delete_cubit.dart';

enum SubaccountDeleteStatus { idle, loading, success, error }

@freezed
abstract class SubaccountDeleteState with _$SubaccountDeleteState {
  const factory SubaccountDeleteState({
    @Default(SubaccountDeleteStatus.idle) SubaccountDeleteStatus status,
    String? deletedSubaccountId,
    String? failureCode,
    String? failureMessage,
  }) = _SubaccountDeleteState;
}
