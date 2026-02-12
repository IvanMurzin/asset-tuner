import 'package:decimal/decimal.dart';
import 'package:json_annotation/json_annotation.dart';

class DecimalJsonConverter implements JsonConverter<Decimal, Object> {
  const DecimalJsonConverter();

  @override
  Decimal fromJson(Object json) {
    if (json is String) {
      return Decimal.parse(json);
    }
    if (json is num) {
      return Decimal.parse(json.toString());
    }
    throw FormatException('Expected decimal string');
  }

  @override
  Object toJson(Decimal object) {
    return object.toString();
  }
}

class NullableDecimalJsonConverter implements JsonConverter<Decimal?, Object?> {
  const NullableDecimalJsonConverter();

  @override
  Decimal? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    if (json is String) {
      return Decimal.parse(json);
    }
    if (json is num) {
      return Decimal.parse(json.toString());
    }
    throw FormatException('Expected decimal string');
  }

  @override
  Object? toJson(Decimal? object) {
    if (object == null) {
      return null;
    }
    return object.toString();
  }
}
