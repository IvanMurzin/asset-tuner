import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:asset_tuner/core/supabase/supabase_constants.dart';
import 'package:asset_tuner/core/supabase/supabase_edge_functions.dart';
import 'package:asset_tuner/data/profile/dto/profile_bootstrap_response_dto.dart';
import 'package:asset_tuner/data/profile/dto/profile_dto.dart';

@lazySingleton
class SupabaseProfileDataSource {
  SupabaseProfileDataSource(this._edgeFunctions);

  final SupabaseEdgeFunctions _edgeFunctions;

  Future<ProfileBootstrapResponseDto> bootstrapProfile() async {
    final payload = await _edgeFunctions.invokeDataObject(
      SupabaseApiRoutes.me,
      method: HttpMethod.get,
    );
    final profile = ProfileDto.fromMeJson(payload);
    return ProfileBootstrapResponseDto(profile: profile);
  }

  Future<ProfileDto> fetchProfile() async {
    final payload = await _edgeFunctions.invokeDataObject(
      SupabaseApiRoutes.me,
      method: HttpMethod.get,
    );
    return ProfileDto.fromMeJson(payload);
  }

  Future<ProfileDto> updateBaseCurrency(String baseCurrencyOrAssetId) async {
    final assetId = await _resolveAssetId(baseCurrencyOrAssetId);
    await _edgeFunctions.invokeVoid(
      SupabaseApiRoutes.profileUpdate,
      body: {'baseAssetId': assetId},
      method: HttpMethod.post,
    );
    return fetchProfile();
  }

  Future<ProfileDto> updatePlan(String _) async {
    await _edgeFunctions.invokeVoid(SupabaseApiRoutes.revenuecatRefresh, method: HttpMethod.post);
    return fetchProfile();
  }

  static final _uuidRegExp = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-8][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );

  Future<String> _resolveAssetId(String baseCurrencyOrAssetId) async {
    final normalized = baseCurrencyOrAssetId.trim();
    if (_uuidRegExp.hasMatch(normalized)) {
      return normalized;
    }

    final upperCode = normalized.toUpperCase();
    final rows = await _edgeFunctions.invokeDataList(
      SupabaseApiRoutes.assetsList,
      query: {'kind': 'fiat', 'limit': 100},
      method: HttpMethod.get,
    );

    for (final row in rows) {
      final code = (row['code'] as String?)?.toUpperCase();
      if (code == upperCode) {
        final id = row['id'] as String?;
        if (id != null && id.isNotEmpty) {
          return id;
        }
      }
    }

    throw const EdgeFunctionException(
      code: 'VALIDATION_ERROR',
      message: 'Requested base asset is not available',
    );
  }
}
