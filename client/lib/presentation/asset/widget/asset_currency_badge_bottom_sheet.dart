part of 'asset_currency_badge.dart';

class _AssetCurrencyBottomSheet extends StatefulWidget {
  const _AssetCurrencyBottomSheet({
    required this.currencyType,
    required this.selectedSlug,
    required this.baseCurrencyCode,
    required this.sheetTitleText,
    required this.searchHintText,
    required this.fiatTabText,
    required this.cryptoTabText,
    required this.emptyResultsTitle,
    required this.emptyResultsMessage,
  });

  final CurrencyType currencyType;
  final String? selectedSlug;
  final String baseCurrencyCode;
  final String sheetTitleText;
  final String searchHintText;
  final String fiatTabText;
  final String cryptoTabText;
  final String emptyResultsTitle;
  final String emptyResultsMessage;

  @override
  State<_AssetCurrencyBottomSheet> createState() => _AssetCurrencyBottomSheetState();
}

class _AssetCurrencyBottomSheetState extends State<_AssetCurrencyBottomSheet> {
  static const Duration _searchDebounceDuration = Duration(milliseconds: 120);

  late final TextEditingController _queryController;
  late final PageController _pageController;
  Timer? _searchDebounceTimer;
  List<AssetEntity>? _lastAssetsRef;
  List<AssetEntity> _fiatAssets = const <AssetEntity>[];
  List<AssetEntity> _cryptoAssets = const <AssetEntity>[];
  String _query = '';
  CurrencyType _activeType = CurrencyType.fiat;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController();
    _activeType = widget.currencyType == CurrencyType.all ? CurrencyType.fiat : widget.currencyType;
    _pageController = PageController(initialPage: _activeType == CurrencyType.fiat ? 0 : 1);
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _queryController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final l10n = AppLocalizations.of(context)!;
    final assetsState = context.watch<AssetsCubit>().state;
    _syncAssetBuckets(assetsState.assets);
    final selectedSlug = widget.selectedSlug?.trim().toUpperCase();
    final snapshot = assetsState.snapshot;

    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(context.dsRadius.r16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: spacing.s8),
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: spacing.s12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.s16),
              child: Row(
                children: [
                  Expanded(child: Text(widget.sheetTitleText, style: typography.h3)),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(spacing.s16, spacing.s8, spacing.s16, spacing.s12),
              child: DSSearchField(
                controller: _queryController,
                hintText: widget.searchHintText,
                onChanged: _onQueryChanged,
              ),
            ),
            if (widget.currencyType == CurrencyType.all)
              Padding(
                padding: EdgeInsets.fromLTRB(spacing.s16, 0, spacing.s16, spacing.s12),
                child: _AssetCurrencyTabBar(
                  activeType: _activeType,
                  fiatTabText: widget.fiatTabText,
                  cryptoTabText: widget.cryptoTabText,
                  onSelectFiat: () => _goToPage(0),
                  onSelectCrypto: () => _goToPage(1),
                ),
              ),
            Expanded(
              child: widget.currencyType == CurrencyType.all
                  ? PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _activeType = index == 0 ? CurrencyType.fiat : CurrencyType.crypto;
                        });
                      },
                      children: [
                        _AssetCurrencyAssetList(
                          source: _fiatAssets,
                          allAssets: assetsState.assets,
                          status: assetsState.status,
                          selectedSlug: selectedSlug,
                          baseCurrencyCode: widget.baseCurrencyCode,
                          usdPriceByAssetId: snapshot?.usdPriceByAssetId ?? const {},
                          ratesUnavailableText: l10n.overviewRatesUnavailable,
                          query: _query,
                          emptyResultsTitle: widget.emptyResultsTitle,
                          emptyResultsMessage: widget.emptyResultsMessage,
                          onSelect: _onSelect,
                        ),
                        _AssetCurrencyAssetList(
                          source: _cryptoAssets,
                          allAssets: assetsState.assets,
                          status: assetsState.status,
                          selectedSlug: selectedSlug,
                          baseCurrencyCode: widget.baseCurrencyCode,
                          usdPriceByAssetId: snapshot?.usdPriceByAssetId ?? const {},
                          ratesUnavailableText: l10n.overviewRatesUnavailable,
                          query: _query,
                          emptyResultsTitle: widget.emptyResultsTitle,
                          emptyResultsMessage: widget.emptyResultsMessage,
                          onSelect: _onSelect,
                        ),
                      ],
                    )
                  : _AssetCurrencyAssetList(
                      source: switch (widget.currencyType) {
                        CurrencyType.fiat => _fiatAssets,
                        CurrencyType.crypto => _cryptoAssets,
                        CurrencyType.all => assetsState.assets,
                      },
                      allAssets: assetsState.assets,
                      status: assetsState.status,
                      selectedSlug: selectedSlug,
                      baseCurrencyCode: widget.baseCurrencyCode,
                      usdPriceByAssetId: snapshot?.usdPriceByAssetId ?? const {},
                      ratesUnavailableText: l10n.overviewRatesUnavailable,
                      query: _query,
                      emptyResultsTitle: widget.emptyResultsTitle,
                      emptyResultsMessage: widget.emptyResultsMessage,
                      onSelect: _onSelect,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToPage(int index) {
    setState(() {
      _activeType = index == 0 ? CurrencyType.fiat : CurrencyType.crypto;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  void _onSelect(_AssetSelectionResult result) {
    Navigator.of(context).pop(result);
  }

  void _onQueryChanged(String value) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(_searchDebounceDuration, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _query = value;
      });
    });
  }

  void _syncAssetBuckets(List<AssetEntity> assets) {
    if (identical(_lastAssetsRef, assets)) {
      return;
    }
    _lastAssetsRef = assets;
    _fiatAssets = assets.where((asset) => asset.kind == AssetKind.fiat).toList(growable: false);
    _cryptoAssets = assets.where((asset) => asset.kind == AssetKind.crypto).toList(growable: false);
  }
}
