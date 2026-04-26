import 'package:asset_tuner/core/supabase/supabase_constants.dart';
import 'package:asset_tuner/core/supabase/supabase_edge_functions.dart';
import 'package:asset_tuner/data/asset/dto/asset_dto.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@lazySingleton
class SupabaseAssetDataSource {
  SupabaseAssetDataSource(this._edgeFunctions);

  final SupabaseEdgeFunctions _edgeFunctions;

  static const _cacheTtl = Duration(seconds: 60);

  List<AssetDto>? _cached;
  DateTime? _cachedAt;
  Future<List<AssetDto>>? _inFlight;

  Future<List<AssetDto>> fetchAssets({bool forceRefresh = false}) async {
    final now = DateTime.now();
    if (!forceRefresh &&
        _cached != null &&
        _cachedAt != null &&
        now.difference(_cachedAt!) < _cacheTtl) {
      return _cached!;
    }

    _inFlight ??= _doFetch().whenComplete(() {
      _inFlight = null;
    });
    final result = await _inFlight!;
    _cached = result;
    _cachedAt = DateTime.now();
    return result;
  }

  Future<List<AssetDto>> _doFetch() async {
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
