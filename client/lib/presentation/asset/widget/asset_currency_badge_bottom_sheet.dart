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
  late final TextEditingController _queryController;
  late final PageController _pageController;
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
    final query = _queryController.text;
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
                onChanged: (_) => setState(() {}),
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
                          source: _assetsForType(assetsState.assets, CurrencyType.fiat),
                          allAssets: assetsState.assets,
                          status: assetsState.status,
                          selectedSlug: selectedSlug,
                          baseCurrencyCode: widget.baseCurrencyCode,
                          usdPriceByAssetId: snapshot?.usdPriceByAssetId ?? const {},
                          ratesUnavailableText: l10n.overviewRatesUnavailable,
                          query: query,
                          emptyResultsTitle: widget.emptyResultsTitle,
                          emptyResultsMessage: widget.emptyResultsMessage,
                          onSelect: _onSelect,
                        ),
                        _AssetCurrencyAssetList(
                          source: _assetsForType(assetsState.assets, CurrencyType.crypto),
                          allAssets: assetsState.assets,
                          status: assetsState.status,
                          selectedSlug: selectedSlug,
                          baseCurrencyCode: widget.baseCurrencyCode,
                          usdPriceByAssetId: snapshot?.usdPriceByAssetId ?? const {},
                          ratesUnavailableText: l10n.overviewRatesUnavailable,
                          query: query,
                          emptyResultsTitle: widget.emptyResultsTitle,
                          emptyResultsMessage: widget.emptyResultsMessage,
                          onSelect: _onSelect,
                        ),
                      ],
                    )
                  : _AssetCurrencyAssetList(
                      source: _assetsForType(assetsState.assets, widget.currencyType),
                      allAssets: assetsState.assets,
                      status: assetsState.status,
                      selectedSlug: selectedSlug,
                      baseCurrencyCode: widget.baseCurrencyCode,
                      usdPriceByAssetId: snapshot?.usdPriceByAssetId ?? const {},
                      ratesUnavailableText: l10n.overviewRatesUnavailable,
                      query: query,
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

  List<AssetEntity> _assetsForType(List<AssetEntity> assets, CurrencyType currencyType) {
    return assets
        .where((asset) {
          return switch (currencyType) {
            CurrencyType.fiat => asset.kind == AssetKind.fiat,
            CurrencyType.crypto => asset.kind == AssetKind.crypto,
            CurrencyType.all => true,
          };
        })
        .toList(growable: false);
  }
}
