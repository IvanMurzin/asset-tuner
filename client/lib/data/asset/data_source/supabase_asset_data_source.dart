import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:asset_tuner/core/supabase/supabase_constants.dart';
import 'package:asset_tuner/core/supabase/supabase_edge_functions.dart';
import 'package:asset_tuner/data/asset/dto/asset_dto.dart';
import 'package:asset_tuner/data/asset/dto/asset_picker_item_dto.dart';

@lazySingleton
class SupabaseAssetDataSource {
  SupabaseAssetDataSource(this._client, this._edgeFunctions);

  final SupabaseClient _client;
  final SupabaseEdgeFunctions _edgeFunctions;

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

  Future<List<AssetPickerItemDto>> fetchAssetsForPicker({
    required String kind,
  }) async {
    final data = await _edgeFunctions.invokeJson(
      SupabaseFunctions.getAssetsForPicker,
      body: {'kind': kind},
    );
    final items = data['items'];
    if (items is! List) {
      return [];
    }
    return items
        .whereType<Map<String, dynamic>>()
        .map(AssetPickerItemDto.fromJson)
        .toList();
  }
}
