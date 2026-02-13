import 'package:asset_tuner/domain/account/entity/account_entity.dart';

final class AccountDetailExtra {
  const AccountDetailExtra({this.initialTitle, this.initialAccountType});
  final String? initialTitle;
  final AccountType? initialAccountType;
}

final class SubaccountDetailExtra {
  const SubaccountDetailExtra({this.initialTitle});
  final String? initialTitle;
}
