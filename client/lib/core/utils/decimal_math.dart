import 'package:decimal/decimal.dart';

Decimal divideToDecimal(
  Decimal numerator,
  Decimal denominator, {
  int scaleOnInfinitePrecision = 18,
}) {
  return (numerator / denominator).toDecimal(
    scaleOnInfinitePrecision: scaleOnInfinitePrecision,
    toBigInt: (value) => value.toBigInt(),
  );
}
