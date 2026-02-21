import 'package:asset_tuner/core/supabase/supabase_constants.dart';
import 'package:asset_tuner/core/supabase/supabase_edge_functions.dart';
import 'package:asset_tuner/data/asset/dto/asset_dto.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@lazySingleton
class SupabaseAssetDataSource {
  SupabaseAssetDataSource(this._edgeFunctions);

  final SupabaseEdgeFunctions _edgeFunctions;

  Future<List<AssetDto>> fetchAssets() async {
    final fiatFuture = _edgeFunctions.invokeDataList(
      SupabaseApiRoutes.assetsList,
      query: {'kind': 'fiat', 'limit': 100},
      method: HttpMethod.get,
    );
    final cryptoFuture = _edgeFunctions.invokeDataList(
      SupabaseApiRoutes.assetsList,
      query: {'kind': 'crypto', 'limit': 100},
      method: HttpMethod.get,
    );
    final fiat = await fiatFuture;
    final crypto = await cryptoFuture;

    return [...fiat, ...crypto].map(AssetDto.fromJson).toList(growable: false);
  }
}
