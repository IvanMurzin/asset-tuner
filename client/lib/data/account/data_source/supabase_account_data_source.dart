import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:asset_tuner/core/supabase/supabase_constants.dart';
import 'package:asset_tuner/core/supabase/supabase_edge_functions.dart';
import 'package:asset_tuner/data/account/dto/account_dto.dart';

@lazySingleton
class SupabaseAccountDataSource {
  SupabaseAccountDataSource(this._client, this._edgeFunctions);

  final SupabaseClient _client;
  final SupabaseEdgeFunctions _edgeFunctions;

  Future<List<AccountDto>> fetchAccounts() async {
    final rows = await _client
        .from(SupabaseTables.accounts)
        .select()
        .order('updated_at', ascending: false);
    return (rows as List).whereType<Map<String, dynamic>>().map(AccountDto.fromJson).toList();
  }

  Future<AccountDto> createAccount({required String name, required String type}) {
    return _edgeFunctions.invoke(
      SupabaseFunctions.createAccount,
      body: {'name': name, 'type': type},
      decode: AccountDto.fromJson,
    );
  }

  Future<AccountDto> updateAccount({
    required String accountId,
    required String name,
    required String type,
  }) async {
    final updated = await _client
        .from(SupabaseTables.accounts)
        .update({'name': name, 'type': type})
        .eq('id', accountId)
        .select()
        .single();
    return AccountDto.fromJson(updated);
  }

  Future<AccountDto> setArchived({required String accountId, required bool archived}) async {
    final updated = await _client
        .from(SupabaseTables.accounts)
        .update({'archived': archived})
        .eq('id', accountId)
        .select()
        .single();
    return AccountDto.fromJson(updated);
  }

  Future<void> deleteAccountCascade({required String accountId}) async {
    await _edgeFunctions.invokeVoid(
      SupabaseFunctions.deleteAccount,
      method: HttpMethod.delete,
      body: {'account_id': accountId},
    );
  }
}
