import 'package:asset_tuner/data/balance/dto/balance_entry_dto.dart';

class BalanceHistoryResponseDto {
  const BalanceHistoryResponseDto({
    required this.items,
    required this.nextCursor,
  });

  final List<BalanceEntryDto> items;
  final String? nextCursor;
}
