import 'package:flutter_test/flutter_test.dart';

import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/session/unauthorized_notifier.dart';
import 'package:asset_tuner/core/supabase/supabase_edge_functions.dart';
import 'package:asset_tuner/core/supabase/supabase_error_translator.dart';
import 'package:asset_tuner/core/supabase/supabase_failure_mapper.dart';

void main() {
  group('SupabaseFailureMapper', () {
    setUp(() {
      SupabaseErrorTranslator.setLanguage(SupportedLanguage.en);
    });

    test('maps validation amount_unchanged reason to dedicated localized code', () {
      final failure = SupabaseFailureMapper.toFailure(
        const EdgeFunctionException(code: 'VALIDATION_ERROR', message: 'amount_unchanged'),
      );

      expect(failure.code, 'amount_unchanged');
      expect(failure.message, 'Balance is unchanged. Enter a different amount.');
    });

    group('unauthorized -> notifier', () {
      late UnauthorizedNotifier notifier;
      late int ticks;

      setUp(() async {
        if (getIt.isRegistered<UnauthorizedNotifier>()) {
          await getIt.unregister<UnauthorizedNotifier>();
        }
        notifier = UnauthorizedNotifier();
        getIt.registerSingleton<UnauthorizedNotifier>(notifier);
        ticks = 0;
        notifier.stream.listen((_) => ticks += 1);
      });

      tearDown(() async {
        await notifier.dispose();
        if (getIt.isRegistered<UnauthorizedNotifier>()) {
          await getIt.unregister<UnauthorizedNotifier>();
        }
      });

      test('UNAUTHORIZED edge code triggers notifier', () async {
        final failure = SupabaseFailureMapper.toFailure(
          const EdgeFunctionException(code: 'UNAUTHORIZED', message: 'token expired'),
        );
        await Future<void>.delayed(Duration.zero);

        expect(failure.code, 'unauthorized');
        expect(ticks, 1);
      });

      test('non-401 errors do not trigger notifier', () async {
        SupabaseFailureMapper.toFailure(
          const EdgeFunctionException(code: 'VALIDATION_ERROR', message: 'bad input'),
        );
        SupabaseFailureMapper.toFailure(
          const EdgeFunctionException(code: 'NOT_FOUND', message: 'gone'),
        );
        await Future<void>.delayed(Duration.zero);

        expect(ticks, 0);
      });
    });

    test('mapper does not throw when notifier is not registered in DI', () {
      // sanity-check: tests/init scenarios must not crash if DI is not wired up.
      expect(getIt.isRegistered<UnauthorizedNotifier>(), isFalse);
      final failure = SupabaseFailureMapper.toFailure(
        const EdgeFunctionException(code: 'UNAUTHORIZED', message: 'no auth'),
      );
      expect(failure.code, 'unauthorized');
    });
  });
}
