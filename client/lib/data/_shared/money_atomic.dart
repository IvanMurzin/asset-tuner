import 'package:decimal/decimal.dart';

abstract final class MoneyAtomic {
  static Decimal fromAtomic(String atomic, int decimals) {
    if (decimals <= 0) {
      return Decimal.parse(atomic);
    }

    final negative = atomic.startsWith('-');
    final digits = negative ? atomic.substring(1) : atomic;
    final padded = digits.padLeft(decimals + 1, '0');
    final splitAt = padded.length - decimals;
    final whole = padded.substring(0, splitAt);
    final fraction = padded.substring(splitAt);
    final sign = negative ? '-' : '';

    return Decimal.parse('$sign$whole.$fraction');
  }

  static String toAtomic(Decimal value, int decimals) {
    final factor = Decimal.parse(_pow10(decimals));
    final scaled = value * factor;
    return _roundHalfAwayFromZeroToIntString(scaled);
  }

  static String _pow10(int decimals) {
    if (decimals <= 0) {
      return '1';
    }
    return '1${'0' * decimals}';
  }

  static String _roundHalfAwayFromZeroToIntString(Decimal scaled) {
    final raw = scaled.toString();
    if (!raw.contains('.')) {
      return raw;
    }

    final negative = raw.startsWith('-');
    final abs = negative ? raw.substring(1) : raw;
    final parts = abs.split('.');
    final intPart = parts.first;
    final fracPart = parts.length > 1 ? parts[1] : '';

    if (fracPart.isEmpty || RegExp(r'^0+$').hasMatch(fracPart)) {
      return negative ? '-$intPart' : intPart;
    }

    final firstFracDigit = int.parse(fracPart[0]);
    final shouldRound = firstFracDigit >= 5;

    var integer = BigInt.parse(intPart);
    if (shouldRound) {
      integer += BigInt.one;
    }

    if (negative) {
      if (integer == BigInt.zero) {
        return '0';
      }
      return '-$integer';
    }

    return integer.toString();
  }
}
