import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:asset_tuner/core/supabase/supabase_constants.dart';
import 'package:asset_tuner/core/supabase/supabase_edge_functions.dart';
import 'package:asset_tuner/data/profile/dto/profile_bootstrap_response_dto.dart';
import 'package:asset_tuner/data/profile/dto/profile_dto.dart';

@lazySingleton
class SupabaseProfileDataSource {
  SupabaseProfileDataSource(this._client, this._edgeFunctions);

  final SupabaseClient _client;
  final SupabaseEdgeFunctions _edgeFunctions;

  Future<ProfileBootstrapResponseDto> bootstrapProfile() {
    return _edgeFunctions.invoke(
      SupabaseFunctions.bootstrapProfile,
      decode: ProfileBootstrapResponseDto.fromJson,
    );
  }

  Future<ProfileDto?> fetchProfile() async {
    final row = await _client
        .from(SupabaseTables.profiles)
        .select()
        .maybeSingle();
    if (row == null) {
      return null;
    }
    return ProfileDto.fromJson(row);
  }

  Future<ProfileDto> updateBaseCurrency(String baseCurrency) {
    return _edgeFunctions.invoke(
      SupabaseFunctions.updateBaseCurrency,
      body: {'base_currency': baseCurrency},
      decode: ProfileDto.fromJson,
    );
  }

  Future<ProfileDto> updatePlan(String plan) {
    return _edgeFunctions.invoke(
      SupabaseFunctions.updatePlan,
      body: {'plan': plan},
      decode: ProfileDto.fromJson,
    );
  }
}
