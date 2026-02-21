import 'package:decimal/decimal.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';

class OverviewAccountItem {
  const OverviewAccountItem({
    required this.accountId,
    required this.accountName,
    required this.accountType,
    required this.total,
    required this.subaccountsCount,
    required this.hasUnpricedHoldings,
  });

  final String accountId;
  final String accountName;
  final AccountType accountType;
  final Decimal total;
  final int subaccountsCount;
  final bool hasUnpricedHoldings;
}
