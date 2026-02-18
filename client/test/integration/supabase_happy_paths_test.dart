import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show HttpMethod, SupabaseClient;

void main() {
  final supabaseUrl = Platform.environment['SUPABASE_URL'];
  final supabaseAnonKey = Platform.environment['SUPABASE_ANON_KEY'];
  final email = Platform.environment['SUPABASE_TEST_EMAIL'];
  final password = Platform.environment['SUPABASE_TEST_PASSWORD'];

  final hasProject =
      (supabaseUrl?.isNotEmpty ?? false) &&
      (supabaseAnonKey?.isNotEmpty ?? false);
  final hasUser =
      hasProject &&
      (email?.isNotEmpty ?? false) &&
      (password?.isNotEmpty ?? false);

  test('assets read via Edge API', () async {
    if (!hasUser) {
      return;
    }
    final client = SupabaseClient(supabaseUrl!, supabaseAnonKey!);
    await client.auth.signInWithPassword(email: email!, password: password!);
    final response = await client.functions.invoke(
      'api/assets/list',
      method: HttpMethod.get,
      queryParameters: {'kind': 'fiat', 'limit': '1'},
    );
    expect(response.data, isA<Map<String, dynamic>>());
    final payload = response.data as Map<String, dynamic>;
    expect(payload['ok'], true);
    expect(payload['data'], isA<List<dynamic>>());
    await client.auth.signOut();
  });

  test('authenticated happy path (me → create/delete account)', () async {
    if (!hasUser) {
      return;
    }

    final client = SupabaseClient(supabaseUrl!, supabaseAnonKey!);
    await client.auth.signInWithPassword(email: email!, password: password!);

    final me = await client.functions.invoke('api/me', method: HttpMethod.get);
    expect(me.data, isA<Map<String, dynamic>>());
    final mePayload = me.data as Map<String, dynamic>;
    expect(mePayload['ok'], true);

    final created = await client.functions.invoke(
      'api/accounts/create',
      body: {'name': 'Integration test', 'type': 'cash'},
    );
    expect(created.data, isA<Map<String, dynamic>>());
    final createdPayload = created.data as Map<String, dynamic>;
    expect(createdPayload['ok'], true);
    final createdMap = createdPayload['data'] as Map<String, dynamic>;
    final accountId = createdMap['id'] as String?;
    expect(accountId, isNotNull);

    final deleted = await client.functions.invoke(
      'api/accounts/delete',
      method: HttpMethod.post,
      body: {'accountId': accountId},
    );
    expect(deleted.data, isA<Map<String, dynamic>>());

    await client.auth.signOut();
  });
}
