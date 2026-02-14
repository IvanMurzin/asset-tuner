import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';

class OnboardingCarouselHeader extends StatelessWidget {
  const OnboardingCarouselHeader({
    super.key,
    required this.isLastPage,
    required this.onSkip,
  });

  final bool isLastPage;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;
    final colors = context.dsColors;
    final typography = context.dsTypography;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        spacing.s16,
        spacing.s12,
        spacing.s16,
        spacing.s8,
      ),
      child: Row(
        children: [
          const Spacer(),
          AnimatedOpacity(
            opacity: isLastPage ? 0 : 1,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: isLastPage,
              child: TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: colors.textSecondary,
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.s12,
                    vertical: spacing.s8,
                  ),
                ),
                child: Text(
                  l10n.onboardingCarouselSkip,
                  style: typography.body.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
