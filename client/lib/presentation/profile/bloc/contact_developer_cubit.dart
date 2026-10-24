import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/profile/usecase/send_contact_developer_message_usecase.dart';

part 'contact_developer_cubit.freezed.dart';
part 'contact_developer_state.dart';

@injectable
class ContactDeveloperCubit extends Cubit<ContactDeveloperState> {
  ContactDeveloperCubit(this._sendMessage) : super(const ContactDeveloperState());

  final SendContactDeveloperMessageUseCase _sendMessage;

  void messageChanged() {
    if (state.messageMissing) {
      emit(state.copyWith(messageMissing: false));
    }
  }

  Future<void> submit({required AuthSessionEntity session, required String message}) async {
    if (state.status != ContactDeveloperStatus.idle) {
      return;
    }
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      emit(state.copyWith(messageMissing: true));
      return;
    }

    emit(
      state.copyWith(
        status: ContactDeveloperStatus.submitting,
        messageMissing: false,
        failureCode: null,
        failureMessage: null,
      ),
    );
    final result = await _sendMessage(session: session, message: trimmed);
    if (isClosed) {
      return;
    }
    switch (result) {
      case Success<void>():
        emit(state.copyWith(status: ContactDeveloperStatus.sent));
      case FailureResult<void>(failure: final failure):
        logger.e('Contact developer submit failed: ${failure.code}');
        emit(
          state.copyWith(
            status: ContactDeveloperStatus.idle,
            failureCode: failure.code,
            failureMessage: failure.message,
          ),
        );
    }
  }
}
