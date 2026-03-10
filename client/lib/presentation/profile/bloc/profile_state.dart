part of 'profile_cubit.dart';

enum ProfileStatus { initial, loading, ready, error }

@freezed
abstract class ProfileState with _$ProfileState {
  const ProfileState._();

  const factory ProfileState({
    @Default(ProfileStatus.initial) ProfileStatus status,
    ProfileEntity? profile,
    String? failureCode,
    String? failureMessage,
    @Default(false) bool isUpdatingBaseCurrency,
    @Default(false) bool isSyncingSubscription,
  }) = _ProfileState;

  bool get isReady => status == ProfileStatus.ready && profile != null;
}
