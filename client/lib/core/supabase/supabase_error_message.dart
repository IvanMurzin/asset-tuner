import 'package:asset_tuner/core/supabase/supabase_error_translator.dart';

String resolveFailureMessage({String? code, String? rawMessage}) {
  if (code == null || code.isEmpty) {
    if (rawMessage != null && rawMessage.trim().isNotEmpty) {
      return rawMessage.trim();
    }
    return SupabaseErrorTranslator.translate('unknown_error');
  }

  final translated = SupabaseErrorTranslator.translate(code);

  final isGeneric = _isGenericMessage(translated);
  if (isGeneric && rawMessage != null && rawMessage.trim().isNotEmpty) {
    return rawMessage.trim();
  }
  return translated;
}

bool _isGenericMessage(String message) {
  final lower = message.toLowerCase();
  return lower.contains('unknown') ||
      lower.contains('something went wrong') ||
      lower.contains('an error occurred') ||
      lower.contains('произошла ошибка') ||
      lower.contains('неизвестн');
}
