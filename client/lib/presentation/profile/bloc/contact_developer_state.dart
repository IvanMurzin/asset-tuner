part of 'contact_developer_cubit.dart';

enum ContactDeveloperStatus { idle, submitting, sent }

@freezed
abstract class ContactDeveloperState with _$ContactDeveloperState {
  const factory ContactDeveloperState({
    @Default(ContactDeveloperStatus.idle) ContactDeveloperStatus status,
    @Default(false) bool messageMissing,
    String? failureCode,
    String? failureMessage,
  }) = _ContactDeveloperState;
}
