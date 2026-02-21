part of 'subaccount_update_cubit.dart';

enum SubaccountUpdateStatus { idle, loading, success, error }

@freezed
abstract class SubaccountUpdateState with _$SubaccountUpdateState {
  const factory SubaccountUpdateState({
    @Default(SubaccountUpdateStatus.idle) SubaccountUpdateStatus status,
    AccountAssetEntity? subaccount,
    String? failureCode,
    String? failureMessage,
  }) = _SubaccountUpdateState;
}
