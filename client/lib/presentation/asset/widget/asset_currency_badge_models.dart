part of 'asset_currency_badge.dart';

class _AssetSelectionResult {
  const _AssetSelectionResult({required this.asset, required this.locked});

  final AssetEntity asset;
  final bool locked;
}

class _AssetPickerRowModel {
  const _AssetPickerRowModel({
    required this.asset,
    required this.titleText,
    required this.rateCaption,
    required this.hasRate,
  });

  final AssetEntity asset;
  final String titleText;
  final String rateCaption;
  final bool hasRate;
}
