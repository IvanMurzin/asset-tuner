import 'package:injectable/injectable.dart';
import 'package:asset_tuner/data/account/data_source/account_mock_data_source.dart';
import 'package:asset_tuner/data/account/service/i_account_edge_function_service.dart';

@LazySingleton(as: IAccountEdgeFunctionService)
class MockAccountEdgeFunctionService implements IAccountEdgeFunctionService {
  MockAccountEdgeFunctionService(this._dataSource);

  final AccountMockDataSource _dataSource;

  @override
  Future<void> deleteAccountCascade({
    required String userId,
    required String accountId,
  }) {
    return _dataSource.deleteAccountCascade(
      userId: userId,
      accountId: accountId,
    );
  }
}
