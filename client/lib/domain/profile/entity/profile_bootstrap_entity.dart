import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';

part 'profile_bootstrap_entity.freezed.dart';

@freezed
abstract class ProfileBootstrapEntity with _$ProfileBootstrapEntity {
  const factory ProfileBootstrapEntity({required ProfileEntity profile}) =
      _ProfileBootstrapEntity;
}
