import 'package:asset_tuner/core/config/app_config.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@lazySingleton
class SupabaseEdgeFunctions {
  SupabaseEdgeFunctions(this._client);

  final SupabaseClient _client;

  Future<Map<String, dynamic>> invokeApi(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    HttpMethod method = HttpMethod.post,
  }) async {
    query = _normalizeQuery(query);
    logger.i({'function': '${method.name} $path', 'body': body, 'query': query});

    try {
      final response = await _client.functions.invoke(
        path,
        body: body,
        method: method,
        queryParameters: query,
      );

      final payload = response.data;
      if (AppConfig.instance.logApiResponses) {
        logger.i({
          'function': 'response: ${method.name} $path',
          'payload': payload,
          'status': response.status,
        });
      }
      if (payload is! Map<String, dynamic>) {
        throw StateError('Unexpected edge function response payload');
      }

      // New API envelope: { ok: bool, data?: ..., meta?: ..., error?: ... }
      if (payload['ok'] == false) {
        final error = payload['error'];
        if (error is Map<String, dynamic>) {
          throw EdgeFunctionException(
            code: (error['code'] as String?) ?? 'unknown',
            message: (error['message'] as String?) ?? 'Request failed',
            details: error['details'],
          );
        }
        throw const EdgeFunctionException(code: 'unknown', message: 'Request failed');
      }

      // Backward compatibility for older function shape with top-level error.
      final legacyError = payload['error'];
      if (legacyError is Map<String, dynamic>) {
        throw EdgeFunctionException(
          code: (legacyError['code'] as String?) ?? 'unknown',
          message: (legacyError['message'] as String?) ?? 'Request failed',
          details: legacyError['details'],
        );
      }

      return payload;
    } catch (error) {
      logger.e({'function': '${method.name} $path', 'error': error}, error: error);
      rethrow;
    }
  }

  Future<EdgeApiEnvelope> invokeApiEnvelope(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    HttpMethod method = HttpMethod.post,
  }) async {
    final payload = await invokeApi(path, body: body, query: query, method: method);
    return EdgeApiEnvelope.fromPayload(payload);
  }

  Future<T> invokeDataMap<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    HttpMethod method = HttpMethod.post,
    required T Function(Map<String, dynamic> json) decode,
  }) async {
    final envelope = await invokeApiEnvelope(path, body: body, query: query, method: method);
    final data = envelope.data;
    if (data is! Map<String, dynamic>) {
      throw StateError('Expected map data from $path');
    }
    return decode(data);
  }

  Future<List<Map<String, dynamic>>> invokeDataList(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    HttpMethod method = HttpMethod.post,
  }) async {
    final envelope = await invokeApiEnvelope(path, body: body, query: query, method: method);
    final data = envelope.data;
    if (data is! List) {
      throw StateError('Expected list data from $path');
    }
    return data.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  Future<Map<String, dynamic>> invokeDataObject(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    HttpMethod method = HttpMethod.post,
  }) async {
    final envelope = await invokeApiEnvelope(path, body: body, query: query, method: method);
    final data = envelope.data;
    if (data is! Map<String, dynamic>) {
      throw StateError('Expected map data from $path');
    }
    return data;
  }

  Future<void> invokeVoid(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    HttpMethod method = HttpMethod.post,
  }) async {
    await invokeApi(path, body: body, query: query, method: method);
  }

  Map<String, String>? _normalizeQuery(Map<String, dynamic>? query) {
    if (query == null) return null;

    final out = <String, String>{};
    for (final entry in query.entries) {
      final v = entry.value;
      if (v == null) continue;

      if (v is String) {
        out[entry.key] = v;
      } else if (v is num || v is bool) {
        out[entry.key] = v.toString();
      } else if (v is Iterable) {
        out[entry.key] = v.map((e) => e.toString()).join(',');
      } else {
        out[entry.key] = v.toString();
      }
    }
    return out;
  }
}

final class EdgeApiEnvelope {
  const EdgeApiEnvelope({required this.data, required this.meta});

  final Object? data;
  final Map<String, dynamic>? meta;

  factory EdgeApiEnvelope.fromPayload(Map<String, dynamic> payload) {
    final metaRaw = payload['meta'];
    return EdgeApiEnvelope(
      data: payload['data'],
      meta: metaRaw is Map<String, dynamic> ? metaRaw : null,
    );
  }
}

final class EdgeFunctionException implements Exception {
  const EdgeFunctionException({required this.code, required this.message, this.details});

  final String code;
  final String message;
  final Object? details;

  @override
  String toString() {
    return 'EdgeFunctionException(code: $code, message: $message, details: $details)';
  }
}
