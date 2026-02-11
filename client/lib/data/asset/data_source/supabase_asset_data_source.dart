import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:asset_tuner/core/supabase/supabase_constants.dart';
import 'package:asset_tuner/data/asset/dto/asset_dto.dart';

@lazySingleton
class SupabaseAssetDataSource {
  SupabaseAssetDataSource(this._client);

  final SupabaseClient _client;

  Future<List<AssetDto>> fetchAssets() async {
    final rows = await _client
        .from(SupabaseTables.assets)
        .select()
        .order('kind', ascending: true)
        .order('code', ascending: true);
    return (rows as List)
        .whereType<Map<String, dynamic>>()
        .map(AssetDto.fromJson)
        .toList();
  }
}

