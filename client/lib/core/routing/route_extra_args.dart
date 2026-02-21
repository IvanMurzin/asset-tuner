import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/subaccount/entity/subaccount_entity.dart';

final class AccountDetailExtra {
  const AccountDetailExtra({this.initialTitle, this.initialAccountType});
  final String? initialTitle;
  final AccountType? initialAccountType;
}

final class SubaccountDetailExtra {
  const SubaccountDetailExtra({
    this.initialTitle,
    this.account,
    this.subaccount,
  });
  final String? initialTitle;
  final AccountEntity? account;
  final SubaccountEntity? subaccount;
}
