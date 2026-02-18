import 'package:asset_tuner/data/profile/dto/profile_dto.dart';

class ProfileBootstrapResponseDto {
  const ProfileBootstrapResponseDto({
    required this.profile,
    required this.isNew,
    required this.wasBaseCurrencyDefaulted,
  });

  final ProfileDto profile;
  final bool isNew;
  final bool wasBaseCurrencyDefaulted;
}
