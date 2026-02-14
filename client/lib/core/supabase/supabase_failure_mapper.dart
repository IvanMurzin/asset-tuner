import 'dart:io';

import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/supabase/supabase_edge_functions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class SupabaseFailureMapper {
  static Failure toFailure(Object error, {String? fallbackMessage}) {
    if (error is SocketException) {
      return Failure(
        code: 'network',
        message: fallbackMessage ?? 'Network error',
      );
    }

    if (error is EdgeFunctionException) {
      return Failure(code: error.code, message: error.message);
    }

    if (error is AuthException) {
      final message = error.message;
      final code = error.code;
      if (code != null && code.isNotEmpty) {
        return Failure(code: code, message: message);
      }
      final normalized = message.toLowerCase();
      if (normalized.contains('invalid login') ||
          normalized.contains('invalid') &&
              normalized.contains('credentials')) {
        return Failure(code: 'unauthorized', message: message);
      }
      if (normalized.contains('rate limit') ||
          normalized.contains('too many')) {
        return Failure(code: 'rate_limited', message: message);
      }
      if (normalized.contains('already') && normalized.contains('registered')) {
        return Failure(code: 'conflict', message: message);
      }
      return Failure(code: 'unknown', message: message);
    }

    if (error is PostgrestException) {
      final message = error.message;
      final code = _mapPostgresCode(error.code);
      return Failure(code: code, message: message);
    }

    if (error is FunctionException) {
      final details = error.details;
      if (details is Map<String, dynamic>) {
        final edgeError = details['error'];
        if (edgeError is Map<String, dynamic>) {
          final code =
              (edgeError['code'] as String?) ?? _mapHttpStatus(error.status);
          final message =
              (edgeError['message'] as String?) ??
              (fallbackMessage ?? 'Request failed');
          return Failure(code: code, message: message);
        }
      }
      return Failure(
        code: _mapHttpStatus(error.status),
        message: fallbackMessage ?? 'Request failed',
      );
    }

    if (error is StorageException) {
      return Failure(code: 'unknown', message: error.message);
    }

    return Failure(
      code: 'unknown',
      message: fallbackMessage ?? 'Unknown error',
    );
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
