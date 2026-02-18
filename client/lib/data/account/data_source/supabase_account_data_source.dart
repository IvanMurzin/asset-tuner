import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:asset_tuner/core/supabase/supabase_constants.dart';
import 'package:asset_tuner/core/supabase/supabase_edge_functions.dart';
import 'package:asset_tuner/data/account/dto/account_dto.dart';

@lazySingleton
class SupabaseAccountDataSource {
  SupabaseAccountDataSource(this._edgeFunctions);

  final SupabaseEdgeFunctions _edgeFunctions;

  Future<List<AccountDto>> fetchAccounts() async {
    final rows = await _edgeFunctions.invokeDataList(
      SupabaseApiRoutes.accountsList,
      method: HttpMethod.get,
    );
    return rows.map(AccountDto.fromJson).toList(growable: false);
  }

  Future<AccountDto> createAccount({
    required String name,
    required String type,
  }) async {
    final row = await _edgeFunctions.invokeDataObject(
      SupabaseApiRoutes.accountsCreate,
      body: {'name': name, 'type': type},
      method: HttpMethod.post,
    );
    return AccountDto.fromJson(row);
  }

  Future<AccountDto> updateAccount({
    required String accountId,
    required String name,
    required String type,
  }) async {
    final row = await _edgeFunctions.invokeDataObject(
      SupabaseApiRoutes.accountsUpdate,
      body: {'accountId': accountId, 'name': name, 'type': type},
      method: HttpMethod.post,
    );
    return AccountDto.fromJson(row);
  }

  Future<AccountDto> setArchived({
    required String accountId,
    required bool archived,
  }) async {
    final row = await _edgeFunctions.invokeDataObject(
      SupabaseApiRoutes.accountsUpdate,
      body: {'accountId': accountId, 'archived': archived},
      method: HttpMethod.post,
    );
    return AccountDto.fromJson(row);
  }

  Future<void> deleteAccountCascade({required String accountId}) async {
    await _edgeFunctions.invokeVoid(
      SupabaseApiRoutes.accountsDelete,
      body: {'accountId': accountId},
      method: HttpMethod.post,
    );
  }
}
