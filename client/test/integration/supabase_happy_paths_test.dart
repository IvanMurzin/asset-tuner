import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show HttpMethod, SupabaseClient;

void main() {
  final supabaseUrl = Platform.environment['SUPABASE_URL'];
  final supabaseAnonKey = Platform.environment['SUPABASE_ANON_KEY'];
  final email = Platform.environment['SUPABASE_TEST_EMAIL'];
  final password = Platform.environment['SUPABASE_TEST_PASSWORD'];

  final hasProject = (supabaseUrl?.isNotEmpty ?? false) && (supabaseAnonKey?.isNotEmpty ?? false);
  final hasUser = hasProject && (email?.isNotEmpty ?? false) && (password?.isNotEmpty ?? false);

  test('public catalog read (assets)', () async {
    if (!hasProject) {
      return;
    }
    final client = SupabaseClient(supabaseUrl!, supabaseAnonKey!);
    final rows = await client.from('assets').select('id,code,kind,name').limit(1);
    expect(rows, isA<List<dynamic>>());
  });

  test('authenticated happy path (bootstrap → create/delete account)', () async {
    if (!hasUser) {
      return;
    }

    final client = SupabaseClient(supabaseUrl!, supabaseAnonKey!);
    await client.auth.signInWithPassword(email: email!, password: password!);

    final bootstrap = await client.functions.invoke('bootstrap_profile');
    expect(bootstrap.data, isA<Map<String, dynamic>>());

    final created = await client.functions.invoke(
      'create_account',
      body: {'name': 'Integration test', 'type': 'cash'},
    );
    expect(created.data, isA<Map<String, dynamic>>());
    final createdMap = created.data as Map<String, dynamic>;
    final accountId = createdMap['id'] as String?;
    expect(accountId, isNotNull);

    final deleted = await client.functions.invoke(
      'account',
      method: HttpMethod.delete,
      body: {'account_id': accountId},
    );
    expect(deleted.data, isA<Map<String, dynamic>>());

    await client.auth.signOut();
  });
}
