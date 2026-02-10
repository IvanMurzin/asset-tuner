import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/local_storage/account_asset_storage.dart';
import 'package:asset_tuner/core/local_storage/balance_entry_storage.dart';
import 'package:asset_tuner/data/account/data_source/account_mock_data_source.dart';
import 'package:asset_tuner/data/account/service/i_account_edge_function_service.dart';

@LazySingleton(as: IAccountEdgeFunctionService)
class MockAccountEdgeFunctionService implements IAccountEdgeFunctionService {
  MockAccountEdgeFunctionService(
    this._dataSource,
    this._accountAssetStorage,
    this._balanceEntryStorage,
  );

  final AccountMockDataSource _dataSource;
  final AccountAssetStorage _accountAssetStorage;
  final BalanceEntryStorage _balanceEntryStorage;

  @override
  Future<void> deleteAccountCascade({
    required String userId,
    required String accountId,
  }) {
    return _deleteCascade(userId: userId, accountId: accountId);
  }

  Future<void> _deleteCascade({
    required String userId,
    required String accountId,
  }) async {
    await _dataSource.deleteAccountCascade(
      userId: userId,
      accountId: accountId,
    );

    final positions = await _accountAssetStorage.readAccountAssets(userId);
    final removedPositionIds = positions
        .where((p) => p.accountId == accountId)
        .map((p) => p.id)
        .toSet();
    final remaining = positions.where((p) => p.accountId != accountId).toList();
    await _accountAssetStorage.writeAccountAssets(userId, remaining);

    if (removedPositionIds.isEmpty) {
      return;
    }
    final entries = await _balanceEntryStorage.readEntries(userId);
    final filtered = entries
        .where((e) => !removedPositionIds.contains(e.accountAssetId))
        .toList();
    await _balanceEntryStorage.writeEntries(userId, filtered);
  }
}
