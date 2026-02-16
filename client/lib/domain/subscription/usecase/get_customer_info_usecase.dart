import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/subscription/entity/subscription_info_entity.dart';
import 'package:asset_tuner/domain/subscription/repository/i_subscription_repository.dart';

@injectable
class GetCustomerInfoUseCase {
  GetCustomerInfoUseCase(this._repository);

  final ISubscriptionRepository _repository;

  Future<Result<SubscriptionInfoEntity>> call() =>
      _repository.getCustomerInfo();
}
