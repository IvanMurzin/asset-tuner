import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_error_translator_flutter/supabase_error_translator_flutter.dart';
import 'package:asset_tuner/core/localization/locale_cubit.dart';

String resolveFailureMessage(
  BuildContext context, {
  String? code,
  String? rawMessage,
  required ErrorService service,
}) {
  if (code == null || code.isEmpty) {
    if (rawMessage != null && rawMessage.trim().isNotEmpty) {
      return rawMessage.trim();
    }
    return _genericFallback(service);
  }

  final localeTag = context.read<LocaleCubit>().state.localeTag;
  final lang = SupportedLanguageExtension.fromCode(localeTag ?? 'en');
  SupabaseErrorTranslator.setLanguage(lang);

  final translated = SupabaseErrorTranslator.translate(code, service);

  final isGeneric = _isGenericMessage(translated);
  if (isGeneric && rawMessage != null && rawMessage.trim().isNotEmpty) {
    return rawMessage.trim();
  }
  return translated;
}

String resolveFailureMessageWithLocale(
  String? localeTag, {
  String? code,
  String? rawMessage,
  required ErrorService service,
}) {
  if (code == null || code.isEmpty) {
    if (rawMessage != null && rawMessage.trim().isNotEmpty) {
      return rawMessage.trim();
    }
    return _genericFallback(service);
  }

  final lang = SupportedLanguageExtension.fromCode(localeTag ?? 'en');
  SupabaseErrorTranslator.setLanguage(lang);

  final translated = SupabaseErrorTranslator.translate(code, service);

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

String _genericFallback(ErrorService service) {
  SupabaseErrorTranslator.setLanguage(SupportedLanguage.en);
  return SupabaseErrorTranslator.translate('unknown_error', service);
}
