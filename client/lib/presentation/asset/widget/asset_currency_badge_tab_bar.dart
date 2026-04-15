part of 'asset_currency_badge.dart';

class _AssetCurrencyTabBar extends StatelessWidget {
  const _AssetCurrencyTabBar({
    required this.activeType,
    required this.fiatTabText,
    required this.cryptoTabText,
    required this.onSelectFiat,
    required this.onSelectCrypto,
  });

  final CurrencyType activeType;
  final String fiatTabText;
  final String cryptoTabText;
  final VoidCallback onSelectFiat;
  final VoidCallback onSelectCrypto;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final colors = context.dsColors;
    final typography = context.dsTypography;
    final radius = context.dsRadius;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(radius.r12),
                onTap: onSelectFiat,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: spacing.s8),
                  child: Center(
                    child: Text(
                      fiatTabText,
                      style: typography.body.copyWith(
                        color: activeType == CurrencyType.fiat
                            ? colors.textPrimary
                            : colors.textSecondary,
                        fontWeight: activeType == CurrencyType.fiat
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(radius.r12),
                onTap: onSelectCrypto,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: spacing.s8),
                  child: Center(
                    child: Text(
                      cryptoTabText,
                      style: typography.body.copyWith(
                        color: activeType == CurrencyType.crypto
                            ? colors.textPrimary
                            : colors.textSecondary,
                        fontWeight: activeType == CurrencyType.crypto
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.s4),
        LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / 2;
            return SizedBox(
              height: 3,
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    left: activeType == CurrencyType.fiat ? 0 : tabWidth,
                    width: tabWidth,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing.s8),
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(radius.r8),
                          gradient: LinearGradient(
                            colors: [colors.primary, colors.info],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
