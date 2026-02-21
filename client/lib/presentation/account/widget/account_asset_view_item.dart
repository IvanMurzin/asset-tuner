import 'package:decimal/decimal.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';

class AccountAssetViewItem {
  const AccountAssetViewItem({
    required this.subaccountId,
    required this.assetId,
    required this.name,
    required this.assetCode,
    required this.assetName,
    required this.assetKind,
    required this.originalAmount,
    required this.convertedAmount,
  });

  final String subaccountId;
  final String assetId;
  final String name;
  final String assetCode;
  final String assetName;
  final AssetKind assetKind;
  final Decimal originalAmount;
  final Decimal? convertedAmount;

  bool get isPriced => convertedAmount != null;
}
