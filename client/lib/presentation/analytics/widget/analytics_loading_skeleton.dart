import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_skeleton.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class AnalyticsLoadingSkeleton extends StatelessWidget {
  const AnalyticsLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final colors = context.dsColors;

    return ListView(
      children: [
        const DSSkeleton(height: 16, width: 120),
        SizedBox(height: spacing.s12),
        DSCard(
          child: SizedBox(
            height: 220,
            child: Center(
              child: DSSkeleton(
                height: 180,
                width: 180,
              ),
            ),
          ),
        ),
        SizedBox(height: spacing.s24),
        const DSSkeleton(height: 16, width: 100),
        SizedBox(height: spacing.s12),
        DSCard(
          child: Column(
            children: [
              for (var i = 0; i < 4; i++) ...[
                const DSSkeleton(height: 18, width: 80),
                SizedBox(height: spacing.s8),
                const DSSkeleton(height: 8),
                if (i != 3) SizedBox(height: spacing.s12),
              ],
            ],
          ),
        ),
        SizedBox(height: spacing.s24),
        const DSSkeleton(height: 16, width: 100),
        SizedBox(height: spacing.s12),
        for (var i = 0; i < 4; i++) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(spacing.s12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(context.dsRadius.r12),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const DSSkeleton(height: 14, width: 120),
                      SizedBox(height: spacing.s8),
                      const DSSkeleton(height: 14, width: 90),
                      SizedBox(height: spacing.s4),
                      const DSSkeleton(height: 16, width: 140),
                      const SizedBox(height: 2),
                      const DSSkeleton(height: 14, width: 110),
                    ],
                  ),
                ),
                SizedBox(width: spacing.s12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const DSSkeleton(height: 14, width: 70),
                    SizedBox(height: spacing.s4),
                    const DSSkeleton(height: 20, width: 80),
                  ],
                ),
              ],
            ),
          ),
          if (i != 3) SizedBox(height: spacing.s8),
        ],
      ],
    );
  }
}
