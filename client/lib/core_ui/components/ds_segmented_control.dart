import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class DSSegmentedControl extends StatelessWidget {
  const DSSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.enabled = true,
    this.disabledIndices = const {},
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool enabled;
  final Set<int> disabledIndices;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final radius = context.dsRadius;
    final typography = context.dsTypography;
    final spacing = context.dsSpacing;

    final isSelected = <bool>[
      for (var i = 0; i < labels.length; i++) i == selectedIndex,
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(radius.r12),
        border: Border.all(color: colors.border),
      ),
      padding: EdgeInsets.all(spacing.s4),
      child: ToggleButtons(
        isSelected: isSelected,
        onPressed: enabled
            ? (index) {
                if (disabledIndices.contains(index)) {
                  return;
                }
                onChanged(index);
              }
            : null,
        borderRadius: BorderRadius.circular(radius.r12),
        borderColor: Colors.transparent,
        selectedBorderColor: Colors.transparent,
        fillColor: colors.surface,
        disabledColor: colors.textTertiary,
        color: colors.textSecondary,
        selectedColor: colors.textPrimary,
        constraints: const BoxConstraints(minHeight: 40),
        children: [
          for (var i = 0; i < labels.length; i++)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.s12),
              child: Text(
                labels[i],
                style: typography.body.copyWith(
                  color: disabledIndices.contains(i)
                      ? colors.textTertiary
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
