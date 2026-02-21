import 'package:decimal/decimal.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/subaccount/entity/subaccount_entity.dart';

abstract interface class ISubaccountRepository {
  Future<Result<List<SubaccountEntity>>> fetchSubaccounts({required String accountId});

  Future<Result<SubaccountEntity>> createSubaccount({
    required String accountId,
    required String name,
    required AssetEntity asset,
    required Decimal snapshotAmount,
    required DateTime entryDate,
  });

  Future<Result<SubaccountEntity>> renameSubaccount({
    required String subaccountId,
    required String name,
  });

  Future<Result<void>> deleteSubaccount({required String subaccountId});
}
