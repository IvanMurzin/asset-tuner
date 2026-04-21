import 'package:asset_tuner/core/supabase/supabase_constants.dart';
import 'package:asset_tuner/core/supabase/supabase_edge_functions.dart';
import 'package:asset_tuner/data/profile/data_source/supabase_profile_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('SupabaseProfileDataSource.sendContactDeveloperMessage', () {
    late _FakeSupabaseEdgeFunctions edgeFunctions;
    late SupabaseProfileDataSource dataSource;

    setUp(() {
      edgeFunctions = _FakeSupabaseEdgeFunctions();
      dataSource = SupabaseProfileDataSource(edgeFunctions);
    });

    test('sends normalized payload to contact developer endpoint', () async {
      await dataSource.sendContactDeveloperMessage(
        name: '  Ivan  ',
        email: '  user@example.com  ',
        description: '  Need help with sync  ',
      );

      expect(edgeFunctions.invocationsCount, 1);
      expect(edgeFunctions.lastPath, SupabaseApiRoutes.contactDeveloper);
      expect(edgeFunctions.lastMethod, HttpMethod.post);
      expect(edgeFunctions.lastBody, {
        'name': 'Ivan',
        'email': 'user@example.com',
        'description': 'Need help with sync',
      });
    });

    test('omits empty email in payload', () async {
      await dataSource.sendContactDeveloperMessage(
        name: 'Ivan',
        email: '   ',
        description: 'Message',
      );

      expect(edgeFunctions.lastBody, {'name': 'Ivan', 'description': 'Message'});
    });
  });
}

class _FakeSupabaseEdgeFunctions extends SupabaseEdgeFunctions {
  _FakeSupabaseEdgeFunctions()
    : super(SupabaseClient('https://example.supabase.co', 'test-anon-key'));

  int invocationsCount = 0;
  String? lastPath;
  HttpMethod? lastMethod;
  Map<String, dynamic>? lastBody;

  @override
  Future<void> invokeVoid(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    HttpMethod method = HttpMethod.post,
  }) async {
    invocationsCount += 1;
    lastPath = path;
    lastMethod = method;
    lastBody = body;
  }
}
