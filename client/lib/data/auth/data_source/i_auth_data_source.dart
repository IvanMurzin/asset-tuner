import 'package:asset_tuner/data/auth/dto/auth_session_dto.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class IAuthDataSource {
  AuthSessionDto? currentSession();
  Stream<AuthState> onAuthStateChange();
  Future<void> resendSignUpOtp(String email);
  Future<void> signInWithPassword(String email, String password);
  Future<void> signInWithOAuth(AuthProvider provider);
  Future<void> signUpWithPassword(String email, String password);
  Future<AuthSessionDto?> verifySignUpOtp({required String email, required String token});
  Future<void> signOut();
  Future<void> deleteMyAccount();
}
