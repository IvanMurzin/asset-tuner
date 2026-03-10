import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@module
abstract class SupabaseModule {
  SupabaseClient get supabaseClient => Supabase.instance.client;

  @Named('oauthSignInTimeout')
  Duration get oAuthSignInTimeout => const Duration(seconds: 90);
}
