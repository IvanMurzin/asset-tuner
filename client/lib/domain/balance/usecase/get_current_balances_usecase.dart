import 'package:decimal/decimal.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/balance/repository/i_balance_repository.dart';

@injectable
class GetCurrentBalancesUseCase {
  GetCurrentBalancesUseCase(this._repository);

  final IBalanceRepository _repository;

  Future<Result<Map<String, Decimal>>> call({
    required Set<String> subaccountIds,
  }) {
    return _repository.fetchCurrentBalances(subaccountIds: subaccountIds);
  }
}
