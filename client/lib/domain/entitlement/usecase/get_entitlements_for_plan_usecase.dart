import 'package:injectable/injectable.dart';
import 'package:asset_tuner/domain/entitlement/entity/entitlements_entity.dart';

@injectable
class GetEntitlementsForPlanUseCase {
  EntitlementsEntity call(String? plan) {
    final normalized = (plan ?? 'free').toLowerCase();
    if (normalized == 'paid') {
      return const EntitlementsEntity(
        maxAccounts: 999,
        maxPositions: 9999,
        anyBaseCurrency: true,
        freeBaseCurrencyCodes: <String>{},
      );
    }

    return const EntitlementsEntity(
      maxAccounts: 5,
      maxPositions: 20,
      anyBaseCurrency: false,
      freeBaseCurrencyCodes: {'USD', 'EUR', 'RUB'},
    );
  }
}
