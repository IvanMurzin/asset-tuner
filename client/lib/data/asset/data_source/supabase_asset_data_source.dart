import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:asset_tuner/core/supabase/supabase_constants.dart';
import 'package:asset_tuner/core/supabase/supabase_edge_functions.dart';
import 'package:asset_tuner/data/asset/dto/asset_dto.dart';
import 'package:asset_tuner/data/asset/dto/asset_picker_item_dto.dart';

@lazySingleton
class SupabaseAssetDataSource {
  SupabaseAssetDataSource(this._edgeFunctions);

  final SupabaseEdgeFunctions _edgeFunctions;

  Future<List<AssetDto>> fetchAssets() async {
    final fiat = await _edgeFunctions.invokeDataList(
      SupabaseApiRoutes.assetsList,
      query: {'kind': 'fiat', 'limit': 100},
      method: HttpMethod.get,
    );
    final crypto = await _edgeFunctions.invokeDataList(
      SupabaseApiRoutes.assetsList,
      query: {'kind': 'crypto', 'limit': 100},
      method: HttpMethod.get,
    );

    return [...fiat, ...crypto].map(AssetDto.fromJson).toList(growable: false);
  }

  Future<List<AssetPickerItemDto>> fetchAssetsForPicker({
    required String kind,
  }) async {
    final rows = await _edgeFunctions.invokeDataList(
      SupabaseApiRoutes.assetsList,
      query: {'kind': kind, 'limit': 100},
      method: HttpMethod.get,
    );
    return rows.map(AssetPickerItemDto.fromJson).toList(growable: false);
  }
}
