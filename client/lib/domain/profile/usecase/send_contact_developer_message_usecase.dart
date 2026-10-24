import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/profile/repository/i_profile_repository.dart';

@injectable
class SendContactDeveloperMessageUseCase {
  SendContactDeveloperMessageUseCase(this._repository);

  final IProfileRepository _repository;

  Future<Result<void>> call({required AuthSessionEntity session, required String message}) {
    return _repository.sendContactDeveloperMessage(
      name: _senderName(session),
      email: session.email,
      description: message,
    );
  }

  /// The local part of the email, or the user id when there is no usable email.
  String _senderName(AuthSessionEntity session) {
    final email = session.email.trim();
    if (email.isEmpty) {
      return session.userId;
    }
    final at = email.indexOf('@');
    return at <= 0 ? email : email.substring(0, at);
  }
}
