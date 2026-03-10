import 'package:asset_tuner/data/auth/data_source/supabase_auth_data_source.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('SupabaseAuthDataSource.mapOAuthProvider', () {
    test('maps Google provider', () {
      expect(
        SupabaseAuthDataSource.mapOAuthProvider(AuthProvider.google),
        OAuthProvider.google,
      );
    });

    test('maps Apple provider', () {
      expect(
        SupabaseAuthDataSource.mapOAuthProvider(AuthProvider.apple),
        OAuthProvider.apple,
      );
    });

    test('throws for email provider', () {
      expect(
        () => SupabaseAuthDataSource.mapOAuthProvider(AuthProvider.email),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('SupabaseAuthDataSource.oauthQueryParams', () {
    test('uses select_account prompt for Google provider', () {
      expect(
        SupabaseAuthDataSource.oauthQueryParams(AuthProvider.google),
        const {'prompt': 'select_account'},
      );
    });

    test('returns null for Apple provider', () {
      expect(
        SupabaseAuthDataSource.oauthQueryParams(AuthProvider.apple),
        isNull,
      );
    });
  });
}
