import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/asset/entity/asset_picker_item_entity.dart';
import 'package:asset_tuner/domain/asset/repository/i_asset_repository.dart';

@injectable
class GetAssetsForSubaccountPickerUseCase {
  GetAssetsForSubaccountPickerUseCase(this._repository);

  final IAssetRepository _repository;

  Future<Result<List<AssetPickerItemEntity>>> call({required AssetKind kind}) {
    return _repository.fetchAssetsForSubaccountPicker(kind: kind);
  }
}
