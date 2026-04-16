part of 'asset_currency_badge.dart';

class _AssetCurrencyAssetList extends StatefulWidget {
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
  State<_AssetCurrencyAssetList> createState() => _AssetCurrencyAssetListState();
}

class _AssetCurrencyAssetListState extends State<_AssetCurrencyAssetList> {
  late AssetCurrencySearchIndex _searchIndex;
  late int _sourceSignature;
  late int _allAssetsSignature;
  late Map<String, AssetEntity> _allAssetsByCode;
  final Map<String, _AssetPickerRowModel> _rowCache = <String, _AssetPickerRowModel>{};

  @override
  void initState() {
    super.initState();
    _sourceSignature = _computeAssetsSignature(widget.source);
    _allAssetsSignature = _computeAssetsSignature(widget.allAssets);
    _searchIndex = AssetCurrencySearchIndex(widget.source);
    _allAssetsByCode = _buildAllAssetsByCode(widget.allAssets);
  }

  @override
  void didUpdateWidget(covariant _AssetCurrencyAssetList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.source, oldWidget.source)) {
      final nextSourceSignature = _computeAssetsSignature(widget.source);
      if (nextSourceSignature != _sourceSignature) {
        _sourceSignature = nextSourceSignature;
        _searchIndex = AssetCurrencySearchIndex(widget.source);
        _rowCache.clear();
      }
    }
    if (!identical(widget.allAssets, oldWidget.allAssets)) {
      final nextAllAssetsSignature = _computeAssetsSignature(widget.allAssets);
      if (nextAllAssetsSignature != _allAssetsSignature) {
        _allAssetsSignature = nextAllAssetsSignature;
        _allAssetsByCode = _buildAllAssetsByCode(widget.allAssets);
        _rowCache.clear();
      }
    }
    if (widget.baseCurrencyCode != oldWidget.baseCurrencyCode ||
        !identical(widget.usdPriceByAssetId, oldWidget.usdPriceByAssetId) ||
        widget.ratesUnavailableText != oldWidget.ratesUnavailableText) {
      _rowCache.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final filtered = _searchIndex.filter(widget.query);

    if (widget.status == AssetsStatus.loading && widget.source.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.s16),
          child: DSEmptyState(
            title: widget.emptyResultsTitle,
            message: widget.emptyResultsMessage,
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
        final row = _rowCache.putIfAbsent(asset.id, () => _buildRow(context, asset));
        return _AssetCurrencyAssetRow(
          row: row,
          isSelected:
              widget.selectedSlug != null && asset.code.toUpperCase() == widget.selectedSlug,
          onSelect: widget.onSelect,
        );
      },
    );
  }

  int _computeAssetsSignature(List<AssetEntity> assets) {
    return Object.hashAll(
      assets.map(
        (asset) => Object.hash(
          asset.id,
          asset.kind,
          asset.code,
          asset.name,
          asset.isLocked,
          asset.usdRate?.usdPriceAtomic,
          asset.usdRate?.usdPriceDecimals,
          asset.usdRate?.asOf.millisecondsSinceEpoch,
        ),
      ),
    );
  }

  Map<String, AssetEntity> _buildAllAssetsByCode(List<AssetEntity> assets) {
    final result = <String, AssetEntity>{};
    for (final asset in assets) {
      result[asset.code.toUpperCase()] = asset;
    }
    return result;
  }

  _AssetPickerRowModel _buildRow(BuildContext context, AssetEntity asset) {
    final code = asset.code.toUpperCase();
    final rateCaption = _buildRateCaption(context, asset, code);
    return _AssetPickerRowModel(
      asset: asset,
      titleText: code,
      rateCaption: rateCaption,
      hasRate: rateCaption != widget.ratesUnavailableText,
    );
  }

  String _buildRateCaption(BuildContext context, AssetEntity asset, String code) {
    final baseCode = widget.baseCurrencyCode.trim().toUpperCase();
    final rate = _resolveRate(asset: asset, code: code, baseCode: baseCode);
    if (rate == null) {
      return widget.ratesUnavailableText;
    }
    final formatted = context.dsFormatters.formatDecimalFromDecimal(rate, maximumFractionDigits: 8);
    return '1 $code ≈ $formatted $baseCode';
  }

  Decimal? _resolveRate({
    required AssetEntity asset,
    required String code,
    required String baseCode,
  }) {
    if (code == baseCode) {
      return Decimal.one;
    }
    final assetUsd = widget.usdPriceByAssetId[asset.id] ?? asset.usdRate?.usdPrice;
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
    final baseAsset = _allAssetsByCode[baseCode];
    if (baseAsset == null) {
      return null;
    }
    return widget.usdPriceByAssetId[baseAsset.id] ?? baseAsset.usdRate?.usdPrice;
  }
}
