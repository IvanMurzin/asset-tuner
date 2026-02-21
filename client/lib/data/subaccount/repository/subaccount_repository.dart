import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/supabase/supabase_failure_mapper.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/data/subaccount/data_source/supabase_subaccount_data_source.dart';
import 'package:asset_tuner/data/subaccount/mapper/subaccount_mapper.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/subaccount/entity/subaccount_entity.dart';
import 'package:asset_tuner/domain/subaccount/repository/i_subaccount_repository.dart';
import 'package:decimal/decimal.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ISubaccountRepository)
class SubaccountRepository implements ISubaccountRepository {
  SubaccountRepository(this._dataSource);

  final SupabaseSubaccountDataSource _dataSource;

  @override
  Future<Result<List<SubaccountEntity>>> fetchSubaccounts({required String accountId}) async {
    try {
      final dtos = await _dataSource.fetchSubaccounts(accountId: accountId);
      logger.i('SubaccountRepository.fetchSubaccounts success');
      return Success(dtos.map(SubaccountMapper.toEntity).toList());
    } catch (error) {
      logger.e('SubaccountRepository.fetchSubaccounts failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(error, fallbackMessage: 'Unable to load subaccounts'),
      );
    }
  }

  @override
  Future<Result<SubaccountEntity>> createSubaccount({
    required String accountId,
    required String name,
    required AssetEntity asset,
    required Decimal snapshotAmount,
    required DateTime entryDate,
  }) async {
    try {
      final dto = await _dataSource.createSubaccount(
        accountId: accountId,
        name: name,
        asset: asset,
        snapshotAmount: snapshotAmount,
        entryDate: entryDate,
      );
      logger.i('SubaccountRepository.createSubaccount success');
      return Success(SubaccountMapper.toEntity(dto));
    } catch (error) {
      logger.e('SubaccountRepository.createSubaccount failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(error, fallbackMessage: 'Unable to create subaccount'),
      );
    }
  }

  @override
  Future<Result<SubaccountEntity>> renameSubaccount({
    required String subaccountId,
    required String name,
  }) async {
    try {
      final dto = await _dataSource.renameSubaccount(subaccountId: subaccountId, name: name);
      logger.i('SubaccountRepository.renameSubaccount success');
      return Success(SubaccountMapper.toEntity(dto));
    } catch (error) {
      logger.e('SubaccountRepository.renameSubaccount failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(error, fallbackMessage: 'Unable to rename subaccount'),
      );
    }
  }

  @override
  Future<Result<void>> deleteSubaccount({required String subaccountId}) async {
    try {
      await _dataSource.deleteSubaccount(subaccountId: subaccountId);
      logger.i('SubaccountRepository.deleteSubaccount success');
      return const Success(null);
    } catch (error) {
      logger.e('SubaccountRepository.deleteSubaccount failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(error, fallbackMessage: 'Unable to delete subaccount'),
      );
    }
  }
}
