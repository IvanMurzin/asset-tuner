import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/repository/i_profile_repository.dart';
import 'package:asset_tuner/domain/profile/usecase/send_contact_developer_message_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _RecordingProfileRepository repository;
  late SendContactDeveloperMessageUseCase useCase;

  setUp(() {
    repository = _RecordingProfileRepository();
    useCase = SendContactDeveloperMessageUseCase(repository);
  });

  test('sender name is the local part of the email', () async {
    await useCase(
      session: const AuthSessionEntity(userId: 'u-1', email: 'jane.doe@example.com'),
      message: 'Hello',
    );
    expect(repository.sent, [('jane.doe', 'jane.doe@example.com', 'Hello')]);
  });

  test('without an email the user id is the sender name', () async {
    await useCase(
      session: const AuthSessionEntity(userId: 'u-1', email: ''),
      message: 'Hi',
    );
    expect(repository.sent.single.$1, 'u-1');
  });
}

class _RecordingProfileRepository implements IProfileRepository {
  final sent = <(String, String, String)>[];

  @override
  Future<Result<void>> sendContactDeveloperMessage({
    required String name,
    required String email,
    required String description,
  }) async {
    sent.add((name, email, description));
    return const Success(null);
  }

  @override
  Future<Result<ProfileEntity>> getProfile() => throw UnimplementedError();

  @override
  Future<Result<ProfileEntity>> updateBaseCurrency(String baseCurrency) =>
      throw UnimplementedError();

  @override
  Future<Result<ProfileEntity>> refreshSubscription() => throw UnimplementedError();
}
