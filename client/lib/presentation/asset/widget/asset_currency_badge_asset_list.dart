part of 'asset_currency_badge.dart';

class _AssetCurrencyAssetList extends StatelessWidget {
  const _AssetCurrencyAssetList({
    required this.source,
    required this.allAssets,
    required this.status,
    required this.selectedSlug,
    required this.baseCurrencyCode,
    required this.usdPriceByAssetId,
    required this.ratesUnavailableText,
    required this.query,
    required this.emptyResultsTitle,
    required this.emptyResultsMessage,
    required this.onSelect,
  });

  final List<AssetEntity> source;
  final List<AssetEntity> allAssets;
  final AssetsStatus status;
  final String? selectedSlug;
  final String baseCurrencyCode;
  final Map<String, Decimal> usdPriceByAssetId;
  final String ratesUnavailableText;
  final String query;
  final String emptyResultsTitle;
  final String emptyResultsMessage;
  final ValueChanged<_AssetSelectionResult> onSelect;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final filtered = _applySearch(source, query);

    if (status == AssetsStatus.loading && source.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.s16),
          child: DSEmptyState(
            title: emptyResultsTitle,
            message: emptyResultsMessage,
            icon: Icons.search_off_outlined,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(spacing.s8),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => SizedBox(height: spacing.s12),
      itemBuilder: (context, index) {
        final asset = filtered[index];
        final row = _buildRow(context, asset);
        return _AssetCurrencyAssetRow(
          row: row,
          isSelected: selectedSlug != null && asset.code.toUpperCase() == selectedSlug,
          onSelect: onSelect,
        );
      },
    );
  }

  List<AssetEntity> _applySearch(List<AssetEntity> items, String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) {
      return items;
    }
    return items
        .where((asset) {
          return asset.code.toLowerCase().contains(normalized) ||
              asset.name.toLowerCase().contains(normalized);
        })
        .toList(growable: false);
  }

  _AssetPickerRowModel _buildRow(BuildContext context, AssetEntity asset) {
    final code = asset.code.toUpperCase();
    final rateCaption = _buildRateCaption(context, asset, code);
    return _AssetPickerRowModel(
      asset: asset,
      titleText: '$code • ${asset.name}',
      rateCaption: rateCaption,
      hasRate: rateCaption != ratesUnavailableText,
    );
  }

  String _buildRateCaption(BuildContext context, AssetEntity asset, String code) {
    final baseCode = baseCurrencyCode.trim().toUpperCase();
    final rate = _resolveRate(asset: asset, code: code, baseCode: baseCode);
    if (rate == null) {
      return ratesUnavailableText;
    }
    final formatted = context.dsFormatters.formatDecimalFromDecimal(rate, maximumFractionDigits: 8);
    return '1 $code = $formatted $baseCode';
  }

  Decimal? _resolveRate({
    required AssetEntity asset,
    required String code,
    required String baseCode,
  }) {
    if (code == baseCode) {
      return Decimal.one;
    }
    final assetUsd = usdPriceByAssetId[asset.id] ?? asset.usdRate?.usdPrice;
    if (assetUsd == null) {
      return null;
    }
    if (baseCode == 'USD') {
      return assetUsd;
    }
    final baseUsd = _resolveBaseUsdPrice(baseCode);
    if (baseUsd == null || baseUsd == Decimal.zero) {
      return null;
    }
    return divideToDecimal(assetUsd, baseUsd);
  }

  Decimal? _resolveBaseUsdPrice(String baseCode) {
    if (baseCode == 'USD') {
      return Decimal.one;
    }
    for (final asset in allAssets) {
      if (asset.code.toUpperCase() != baseCode) {
        continue;
      }
      return usdPriceByAssetId[asset.id] ?? asset.usdRate?.usdPrice;
    }
    return null;
  }
}
