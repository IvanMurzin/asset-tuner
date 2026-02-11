import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:asset_tuner/core/logger/logger.dart';

@lazySingleton
class SupabaseEdgeFunctions {
  SupabaseEdgeFunctions(this._client);

  final SupabaseClient _client;

  Future<T> invoke<T>(
    String functionName, {
    Map<String, dynamic>? body,
    HttpMethod method = HttpMethod.post,
    required T Function(Map<String, dynamic> json) decode,
  }) async {
    final json = await invokeJson(functionName, body: body, method: method);
    return decode(json);
  }

  Future<Map<String, dynamic>> invokeJson(
    String functionName, {
    Map<String, dynamic>? body,
    HttpMethod method = HttpMethod.post,
  }) async {
    logger.i('edge_fn_request fn=$functionName method=${method.name}');
    try {
      final response = await _client.functions.invoke(
        functionName,
        body: body,
        method: method,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final error = data['error'];
        if (error is Map<String, dynamic>) {
          final code = (error['code'] as String?) ?? 'unknown';
          final message = (error['message'] as String?) ?? 'Request failed';
          logger.w('edge_fn_failure fn=$functionName code=$code');
          throw EdgeFunctionException(
            code: code,
            message: message,
            details: error['details'],
          );
        }
        logger.i('edge_fn_success fn=$functionName');
        return data;
      }

      logger.w('edge_fn_failure fn=$functionName code=unknown');
      throw StateError('Unexpected edge function response');
    } catch (error) {
      logger.e('edge_fn_exception fn=$functionName', error: error);
      rethrow;
    }
  }

  Future<void> invokeVoid(
    String functionName, {
    Map<String, dynamic>? body,
    HttpMethod method = HttpMethod.post,
  }) async {
    await invokeJson(functionName, body: body, method: method);
  }
}

final class EdgeFunctionException implements Exception {
  const EdgeFunctionException({
    required this.code,
    required this.message,
    this.details,
  });

  final String code;
  final String message;
  final Object? details;

  @override
  String toString() {
    return 'EdgeFunctionException(code: $code, message: $message, details: $details)';
  }
}
