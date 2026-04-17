import 'package:asset_tuner/core/supabase/supabase_edge_functions.dart';
import 'package:asset_tuner/core/supabase/supabase_error_translator.dart';
import 'package:asset_tuner/core/supabase/supabase_failure_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

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
  });
}
