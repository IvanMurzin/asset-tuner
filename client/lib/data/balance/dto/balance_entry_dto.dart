import 'package:decimal/decimal.dart';
import 'package:asset_tuner/data/_shared/money_atomic.dart';

class BalanceEntryDto {
  const BalanceEntryDto({
    required this.id,
    required this.subaccountId,
    required this.entryDateIso,
    required this.snapshotAmount,
    required this.amountDecimals,
    this.diffAmount,
    required this.createdAtIso,
  });

  final String id;
  final String subaccountId;
  final String entryDateIso;
  final Decimal snapshotAmount;
  final int amountDecimals;
  final Decimal? diffAmount;
  final String createdAtIso;

  factory BalanceEntryDto.fromJson(Map<String, dynamic> json) {
    final entryDateIso =
        (json['entry_date'] as String?) ??
        (json['created_at'] as String?) ??
        '';
    final createdAtIso = (json['created_at'] as String?) ?? entryDateIso;

    final decimalsRaw = json['amount_decimals'];
    final amountDecimals = decimalsRaw is num
        ? decimalsRaw.toInt()
        : _inferDecimals(json);
    final snapshot = _parseSnapshot(json, amountDecimals);
    final diff = _parseNullableDecimal(json['diff_amount']);

    return BalanceEntryDto(
      id: (json['id'] as String?) ?? '',
      subaccountId: (json['subaccount_id'] as String?) ?? '',
      entryDateIso: entryDateIso,
      snapshotAmount: snapshot,
      amountDecimals: amountDecimals,
      diffAmount: diff,
      createdAtIso: createdAtIso,
    );
  }

  static int _inferDecimals(Map<String, dynamic> json) {
    if (json['snapshot_amount'] != null) {
      final text = json['snapshot_amount'].toString();
      final point = text.indexOf('.');
      return point >= 0 ? text.length - point - 1 : 0;
    }
    return 0;
  }

  static Decimal _parseSnapshot(Map<String, dynamic> json, int amountDecimals) {
    if (json['snapshot_amount'] != null) {
      return Decimal.parse(json['snapshot_amount'].toString());
    }

    final atomic = json['amount_atomic']?.toString();
    if (atomic == null) {
      return Decimal.zero;
    }
    return MoneyAtomic.fromAtomic(atomic, amountDecimals);
  }

  static Decimal? _parseNullableDecimal(Object? value) {
    if (value == null) {
      return null;
    }
    return Decimal.parse(value.toString());
  }
}
