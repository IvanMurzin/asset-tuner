import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/onboarding/widget/onboarding_carousel_page_indicator.dart';

class OnboardingCarouselFooter extends StatelessWidget {
  const OnboardingCarouselFooter({
    super.key,
    required this.pageCount,
    required this.currentPage,
    required this.primaryLabel,
    required this.onBack,
    required this.onPrimary,
  });

  final int pageCount;
  final int currentPage;
  final String primaryLabel;
  final VoidCallback? onBack;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;
    final colors = context.dsColors;
    final typography = context.dsTypography;

    return Padding(
      padding: EdgeInsets.fromLTRB(spacing.s24, spacing.s8, spacing.s24, spacing.s24),
      child: Column(
        children: [
          OnboardingCarouselPageIndicator(
            count: pageCount,
            currentIndex: currentPage,
            activeColor: colors.primary,
            inactiveColor: colors.border,
          ),
          SizedBox(height: spacing.s16),
          Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: currentPage == 0
                    ? const SizedBox(width: 1)
                    : TextButton(
                        key: const ValueKey('back'),
                        onPressed: onBack,
                        style: TextButton.styleFrom(
                          foregroundColor: colors.textSecondary,
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing.s8,
                            vertical: spacing.s8,
                          ),
                        ),
                        child: Text(
                          l10n.onboardingCarouselBack,
                          style: typography.body.copyWith(color: colors.textSecondary),
                        ),
                      ),
              ),
              const Spacer(),
              Expanded(
                flex: 2,
                child: DSButton(label: primaryLabel, fullWidth: true, onPressed: onPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
