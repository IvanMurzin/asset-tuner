import 'package:decimal/decimal.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/balance/entity/balance_entry_entity.dart';
import 'package:asset_tuner/domain/balance/repository/i_balance_repository.dart';

@injectable
class UpdateBalanceUseCase {
  UpdateBalanceUseCase(this._repository);

  final IBalanceRepository _repository;

  Future<Result<BalanceEntryEntity>> call({
    required String subaccountId,
    required DateTime entryDate,
    required Decimal snapshotAmount,
  }) {
    return _repository.updateBalance(
      subaccountId: subaccountId,
      entryDate: entryDate,
      snapshotAmount: snapshotAmount,
    );
  }
}
