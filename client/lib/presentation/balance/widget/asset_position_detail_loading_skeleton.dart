import 'package:asset_tuner/core_ui/components/ds_skeleton.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:flutter/material.dart';

class AssetPositionDetailLoadingSkeleton extends StatelessWidget {
  const AssetPositionDetailLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final colors = context.dsColors;

    return ListView(
      children: [
        SizedBox(height: spacing.s24),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(spacing.s16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.info.withValues(alpha: 0.16),
                colors.success.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(context.dsRadius.r16),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const DSSkeleton(height: 36, width: 36),
                  SizedBox(width: spacing.s8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DSSkeleton(height: 18, width: 140),
                        SizedBox(height: spacing.s4),
                        const DSSkeleton(height: 14, width: 120),
                      ],
                    ),
                  ),
                  const DSSkeleton(height: 14, width: 42),
                ],
              ),
              SizedBox(height: spacing.s12),
              const DSSkeleton(height: 30, width: 220),
              SizedBox(height: spacing.s4),
              const DSSkeleton(height: 18, width: 170),
              SizedBox(height: spacing.s8),
              const DSSkeleton(height: 14, width: 220),
            ],
          ),
        ),
        SizedBox(height: spacing.s16),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const DSSkeleton(height: 52, width: 52),
                  SizedBox(height: spacing.s8),
                  const DSSkeleton(height: 12, width: 64),
                ],
              ),
            ),
            SizedBox(width: spacing.s8),
            Expanded(
              child: Column(
                children: [
                  const DSSkeleton(height: 52, width: 52),
                  SizedBox(height: spacing.s8),
                  const DSSkeleton(height: 12, width: 64),
                ],
              ),
            ),
            SizedBox(width: spacing.s8),
            Expanded(
              child: Column(
                children: [
                  const DSSkeleton(height: 52, width: 52),
                  SizedBox(height: spacing.s8),
                  const DSSkeleton(height: 12, width: 64),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.s24),
        const DSSkeleton(height: 16, width: 130),
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
                    const DSSkeleton(height: 20, width: 130),
                    const SizedBox(height: 2),
                    const DSSkeleton(height: 16, width: 120),
                  ],
                ),
              ],
            ),
          ),
          if (i != 3) SizedBox(height: spacing.s8),
        ],
            ],
          ),
        ),
        SizedBox(height: spacing.s24),
      ],
    );
  }
}
