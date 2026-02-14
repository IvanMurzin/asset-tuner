import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class OnboardingCarouselPageIndicator extends StatelessWidget {
  const OnboardingCarouselPageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    required this.activeColor,
    required this.inactiveColor,
  });

  final int count;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final selected = i == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.symmetric(horizontal: spacing.s4),
          width: selected ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: selected ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
