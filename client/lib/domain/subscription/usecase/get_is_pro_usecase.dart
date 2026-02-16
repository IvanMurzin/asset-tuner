import 'package:injectable/injectable.dart';
import 'package:asset_tuner/domain/subscription/repository/i_subscription_repository.dart';

@injectable
class GetIsProUseCase {
  GetIsProUseCase(this._repository);

  final ISubscriptionRepository _repository;

  Future<bool> call() => _repository.hasProEntitlement();
}
