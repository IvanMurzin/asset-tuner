import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/local_storage/profile_storage.dart';
import 'package:asset_tuner/data/profile/dto/profile_dto.dart';

@lazySingleton
class ProfileMockDataSource {
  ProfileMockDataSource(this._storage);

  final ProfileStorage _storage;

  Future<ProfileDto?> fetchProfile(String userId) async {
    final stored = await _storage.readProfile(userId);
    if (stored == null) {
      return null;
    }
    return ProfileDto(
      userId: stored.userId,
      baseCurrency: stored.baseCurrency,
      plan: stored.plan,
    );
  }

  Future<ProfileDto> upsertProfile(ProfileDto profile) async {
    await _storage.writeProfile(
      StoredProfile(
        userId: profile.userId,
        baseCurrency: profile.baseCurrency,
        plan: profile.plan,
      ),
    );
    return profile;
  }
}
