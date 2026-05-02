import 'dart:io';

import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/session/unauthorized_notifier.dart';
import 'package:asset_tuner/core/supabase/supabase_edge_functions.dart';
import 'package:asset_tuner/core/supabase/supabase_error_message.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class SupabaseFailureMapper {
  static Failure toFailure(Object error, {String? fallbackMessage}) {
    if (error is SocketException) {
      return _createLocalizedFailure(
        code: 'network',
        rawMessage: fallbackMessage ?? 'Network error',
      );
    }

    if (error is EdgeFunctionException) {
      return _createLocalizedFailure(
        code: _normalizeCode(error.code, message: error.message),
        rawMessage: error.message,
      );
    }

    if (error is AuthException) {
      final message = error.message;
      final code = error.code;
      if (code != null && code.isNotEmpty) {
        return _createLocalizedFailure(code: code, rawMessage: message);
      }
      final normalized = message.toLowerCase();
      if (normalized.contains('invalid login') ||
          normalized.contains('invalid') && normalized.contains('credentials')) {
        return _createLocalizedFailure(code: 'unauthorized', rawMessage: message);
      }
      if (normalized.contains('rate limit') || normalized.contains('too many')) {
        return _createLocalizedFailure(code: 'rate_limited', rawMessage: message);
      }
      if (normalized.contains('already') && normalized.contains('registered')) {
        return _createLocalizedFailure(code: 'conflict', rawMessage: message);
      }
      return _createLocalizedFailure(code: 'unknown', rawMessage: message);
    }

    if (error is PostgrestException) {
      final message = error.message;
      final code = _mapPostgresCode(error.code);
      return _createLocalizedFailure(code: code, rawMessage: message);
    }

    if (error is FunctionException) {
      final details = error.details;
      if (details is Map<String, dynamic>) {
        final edgeError = details['error'];
        if (edgeError is Map<String, dynamic>) {
          final code = (edgeError['code'] as String?) ?? _mapHttpStatus(error.status);
          final message =
              (edgeError['message'] as String?) ?? (fallbackMessage ?? 'Request failed');
          return _createLocalizedFailure(
            code: _normalizeCode(code, message: message),
            rawMessage: message,
          );
        }
      }
      return _createLocalizedFailure(
        code: _normalizeCode(_mapHttpStatus(error.status)),
        rawMessage: fallbackMessage ?? 'Request failed',
      );
    }

    if (error is StorageException) {
      return _createLocalizedFailure(code: 'unknown', rawMessage: error.message);
    }

    return _createLocalizedFailure(code: 'unknown', rawMessage: fallbackMessage ?? 'Unknown error');
  }

  static Failure _createLocalizedFailure({required String code, required String rawMessage}) {
    if (code == 'unauthorized') {
      _notifyUnauthorized();
    }
    final localizedMessage = resolveFailureMessage(code: code, rawMessage: rawMessage);
    return Failure(code: code, message: localizedMessage);
  }

  /// Signals the global channel that the current token is no longer valid.
  /// The [getIt] lookup is guarded by `isRegistered` so tests that set up DI
  /// partially (or not at all) keep working.
  static void _notifyUnauthorized() {
    if (!getIt.isRegistered<UnauthorizedNotifier>()) return;
    getIt<UnauthorizedNotifier>().notifyUnauthorized();
  }

  static String _mapPostgresCode(String? postgresCode) {
    return switch (postgresCode) {
      '23505' => 'conflict',
      '23503' => 'validation',
      '22P02' => 'validation',
      '42501' => 'forbidden',
      _ => 'unknown',
    };
  }

  static String _normalizeCode(String code, {String? message}) {
    final normalized = code.trim().toUpperCase();
    final mapped = switch (normalized) {
      'UNAUTHORIZED' => 'unauthorized',
      'FORBIDDEN' => 'forbidden',
      'NOT_FOUND' => 'not_found',
      'VALIDATION_ERROR' => 'validation',
      'LIMIT_ACCOUNTS_REACHED' => 'limit_accounts_reached',
      'LIMIT_SUBACCOUNTS_REACHED' => 'limit_subaccounts_reached',
      'ASSET_NOT_ALLOWED_FOR_PLAN' => 'asset_not_allowed_for_plan',
      'RATE_LIMITED' => 'rate_limited',
      'EXTERNAL_API_ERROR' => 'external_api_error',
      'INTERNAL_ERROR' => 'internal_server_error',
      _ => code,
    };

    if (mapped == 'validation' && _isAmountUnchanged(message)) {
      return 'amount_unchanged';
    }
    return mapped;
  }

  static bool _isAmountUnchanged(String? message) {
    final normalized = message?.trim().toLowerCase();
    return normalized == 'amount_unchanged';
  }

  static String _mapHttpStatus(int status) {
    return switch (status) {
      401 => 'unauthorized',
      403 => 'forbidden',
      404 => 'not_found',
      409 => 'conflict',
      422 => 'validation',
      429 => 'rate_limited',
      _ => 'unknown',
    };
  }
}
