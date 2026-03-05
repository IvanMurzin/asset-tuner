import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:asset_tuner/core/supabase/supabase_constants.dart';
import 'package:asset_tuner/core/supabase/supabase_edge_functions.dart';
import 'package:asset_tuner/data/auth/dto/auth_session_dto.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';

@lazySingleton
class SupabaseAuthDataSource {
  SupabaseAuthDataSource(this._client, this._edgeFunctions);

  final SupabaseClient _client;
  final SupabaseEdgeFunctions _edgeFunctions;

  AuthSessionDto? currentSession() {
    final user = _client.auth.currentSession?.user;
    if (user == null) {
      return null;
    }
    return AuthSessionDto(userId: user.id, email: user.email ?? '');
  }

  Future<void> signInWithOtp(String email) {
    return _client.auth.signInWithOtp(email: email);
  }

  Future<void> signInWithPassword(String email, String password) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signInWithOAuth(AuthProvider provider) {
    final supaProvider = mapOAuthProvider(provider);
    return _client.auth.signInWithOAuth(supaProvider);
  }

  @visibleForTesting
  static OAuthProvider mapOAuthProvider(AuthProvider provider) {
    return switch (provider) {
      AuthProvider.google => OAuthProvider.google,
      AuthProvider.apple => OAuthProvider.apple,
      AuthProvider.email => throw StateError(
        'OAuth is not supported for $provider',
      ),
    };
  }

  Future<void> signUpWithPassword(String email, String password) {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<AuthSessionDto?> verifySignUpOtp({
    required String email,
    required String token,
  }) async {
    final response = await _client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.signup,
    );
    final user = response.session?.user;
    if (user == null) {
      return null;
    }
    return AuthSessionDto(userId: user.id, email: user.email ?? '');
  }

  Future<void> signOut() {
    return _client.auth.signOut();
  }

  Future<void> deleteMyAccount() async {
    await _edgeFunctions.invokeVoid(
      SupabaseApiRoutes.deleteMyAccount,
      method: HttpMethod.post,
      body: {'confirm': true},
    );
  }
}
