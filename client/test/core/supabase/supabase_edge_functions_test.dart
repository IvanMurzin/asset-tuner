import 'dart:async';

import 'package:asset_tuner/core/supabase/supabase_edge_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  testWidgets('a stalled call times out (QA-013)', (tester) async {
    final neverAnswers = MockClient((_) => Completer<http.Response>().future);
    final client = SupabaseClient(
      'https://example.supabase.co',
      'publishable-key',
      httpClient: neverAnswers,
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    // Not disposed: dispose() awaits real I/O that never completes under the test's fake clock.

    Object? caught;
    unawaited(
      SupabaseEdgeFunctions(client)
          .invokeApi('api/me')
          .then<void>(
            (_) {},
            onError: (Object e) {
              caught = e;
            },
          ),
    );

    await tester.pump(SupabaseEdgeFunctions.requestTimeout - const Duration(seconds: 1));
    expect(caught, isNull);
    await tester.pump(const Duration(seconds: 2));

    // Mapped to `network` by SupabaseFailureMapper (see its tests).
    expect(caught, isA<TimeoutException>());
  });
}
