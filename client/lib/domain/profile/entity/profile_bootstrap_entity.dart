import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';

class ProfileBootstrapEntity {
  const ProfileBootstrapEntity({
    required this.profile,
    required this.isNew,
    required this.wasBaseCurrencyDefaulted,
  });

  final ProfileEntity profile;
  final bool isNew;
  final bool wasBaseCurrencyDefaulted;
}
