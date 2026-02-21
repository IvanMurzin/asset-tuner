import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/balance/entity/balance_history_page_entity.dart';
import 'package:asset_tuner/domain/balance/repository/i_balance_repository.dart';

@injectable
class GetBalanceHistoryUseCase {
  GetBalanceHistoryUseCase(this._repository);

  final IBalanceRepository _repository;

  Future<Result<BalanceHistoryPageEntity>> call({
    required String subaccountId,
    int limit = 50,
    String? cursor,
  }) {
    return _repository.fetchHistory(subaccountId: subaccountId, limit: limit, cursor: cursor);
  }
}
