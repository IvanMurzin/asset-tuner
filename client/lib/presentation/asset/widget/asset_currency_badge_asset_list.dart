part of 'asset_currency_badge.dart';

class _AssetCurrencyAssetList extends StatelessWidget {
  const _AssetCurrencyAssetList({
    required this.source,
    required this.status,
    required this.selectedSlug,
    required this.query,
    required this.emptyResultsTitle,
    required this.emptyResultsMessage,
    required this.onSelect,
  });

  final List<AssetEntity> source;
  final AssetsStatus status;
  final String? selectedSlug;
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
        return _AssetCurrencyAssetRow(
          asset: asset,
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
}
