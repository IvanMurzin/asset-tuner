import 'package:asset_tuner/core/supabase/supabase_edge_functions.dart';
import 'package:asset_tuner/core/supabase/supabase_error_translator.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/data/profile/data_source/supabase_profile_data_source.dart';
import 'package:asset_tuner/data/profile/repository/profile_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('ProfileRepository.sendContactDeveloperMessage', () {
    late _FakeSupabaseProfileDataSource dataSource;
    late ProfileRepository repository;

    setUp(() {
      SupabaseErrorTranslator.setLanguage(SupportedLanguage.en);
      dataSource = _FakeSupabaseProfileDataSource();
      repository = ProfileRepository(dataSource);
    });

    test('returns success when data source accepts message', () async {
      final result = await repository.sendContactDeveloperMessage(
        name: 'Ivan',
        email: 'user@example.com',
        description: 'Need help',
      );

      expect(result, const Success<void>(null));
      expect(dataSource.submitCalls, 1);
      expect(dataSource.lastName, 'Ivan');
      expect(dataSource.lastEmail, 'user@example.com');
      expect(dataSource.lastDescription, 'Need help');
    });

    test('maps edge function validation error to failure result', () async {
      dataSource.throwOnSubmit = const EdgeFunctionException(
        code: 'VALIDATION_ERROR',
        message: 'Validation failed',
      );

      final result = await repository.sendContactDeveloperMessage(
        name: '',
        email: 'user@example.com',
        description: '',
      );

      expect(result, isA<FailureResult<void>>());
      final failure = (result as FailureResult<void>).failure;
      expect(failure.code, 'validation');
      expect(failure.message.isNotEmpty, isTrue);
    });
  });
}

class _FakeSupabaseProfileDataSource extends SupabaseProfileDataSource {
  _FakeSupabaseProfileDataSource() : super(_NoopSupabaseEdgeFunctions());

  Object? throwOnSubmit;
  int submitCalls = 0;
  String? lastName;
  String? lastEmail;
  String? lastDescription;

  @override
  Future<void> sendContactDeveloperMessage({
    required String name,
    required String email,
    required String description,
  }) async {
    submitCalls += 1;
    lastName = name;
    lastEmail = email;
    lastDescription = description;
    final error = throwOnSubmit;
    if (error != null) {
      throw error;
    }
  }
}

class _NoopSupabaseEdgeFunctions extends SupabaseEdgeFunctions {
  _NoopSupabaseEdgeFunctions()
    : super(SupabaseClient('https://example.supabase.co', 'test-anon-key'));
}
