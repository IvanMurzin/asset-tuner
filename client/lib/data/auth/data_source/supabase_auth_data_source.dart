import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:asset_tuner/core/config/app_config.dart';
import 'package:asset_tuner/core/supabase/supabase_constants.dart';
import 'package:asset_tuner/core/supabase/supabase_edge_functions.dart';
import 'package:asset_tuner/data/auth/data_source/i_auth_data_source.dart';
import 'package:asset_tuner/data/auth/dto/auth_session_dto.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';

@LazySingleton(as: IAuthDataSource)
class SupabaseAuthDataSource implements IAuthDataSource {
  SupabaseAuthDataSource(this._client, this._edgeFunctions);

  final SupabaseClient _client;
  final SupabaseEdgeFunctions _edgeFunctions;

  @override
  AuthSessionDto? currentSession() {
    final user = _client.auth.currentSession?.user;
    if (user == null) {
      return null;
    }
    return AuthSessionDto(userId: user.id, email: user.email ?? '');
  }

  @override
  Stream<AuthState> onAuthStateChange() {
    return _client.auth.onAuthStateChange;
  }

  @override
  Future<void> resendSignUpOtp(String email) {
    return _client.auth.resend(
      email: email,
      type: OtpType.signup,
      emailRedirectTo: AppConfig.instance.oauthRedirectUri,
    );
  }

  @override
  Future<void> signInWithPassword(String email, String password) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signInWithOAuth(AuthProvider provider) {
    final supaProvider = mapOAuthProvider(provider);
    return _client.auth.signInWithOAuth(
      supaProvider,
      redirectTo: AppConfig.instance.oauthRedirectUri,
      // A Custom Tab returns to the app on back, so cancelling is detected on resume (QA-008).
      authScreenLaunchMode: LaunchMode.inAppBrowserView,
      queryParams: oauthQueryParams(provider),
    );
  }

  @visibleForTesting
  static OAuthProvider mapOAuthProvider(AuthProvider provider) {
    return switch (provider) {
      AuthProvider.google => OAuthProvider.google,
      AuthProvider.apple => OAuthProvider.apple,
      AuthProvider.email => throw StateError('OAuth is not supported for $provider'),
    };
  }

  @visibleForTesting
  static Map<String, String>? oauthQueryParams(AuthProvider provider) {
    return switch (provider) {
      AuthProvider.google => const {'prompt': 'select_account'},
      AuthProvider.apple => null,
      AuthProvider.email => null,
    };
  }

  @override
  Future<void> signUpWithPassword(String email, String password) {
    return _client.auth.signUp(email: email, password: password);
  }

  @override
  Future<AuthSessionDto?> verifySignUpOtp({required String email, required String token}) async {
    final response = await _client.auth.verifyOTP(email: email, token: token, type: OtpType.signup);
    final user = response.session?.user;
    if (user == null) {
      return null;
    }
    return AuthSessionDto(userId: user.id, email: user.email ?? '');
  }

  /// Sends the recovery email; its template shows a 6-digit `{{ .Token }}` code.
  @override
  Future<void> requestPasswordReset(String email) {
    return _client.auth.resetPasswordForEmail(email);
  }

  /// Verifying the recovery code signs the user in; the new password is then set on that session.
  /// When an earlier attempt already verified the code (the code is single-use) and only the
  /// password update failed, the existing session for [email] is reused.
  @override
  Future<void> resetPasswordWithCode({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    final currentEmail = _client.auth.currentUser?.email?.toLowerCase();
    if (currentEmail != email.toLowerCase()) {
      await _client.auth.verifyOTP(email: email, token: token, type: OtpType.recovery);
    }
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  @override
  Future<void> signOut() {
    return _client.auth.signOut();
  }

  @override
  Future<void> deleteMyAccount() async {
    await _edgeFunctions.invokeVoid(
      SupabaseApiRoutes.deleteMyAccount,
      method: HttpMethod.post,
      body: {'confirm': true},
    );
  }
}
