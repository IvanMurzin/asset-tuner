import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/components/ds_skeleton.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class PaywallLoadingSkeleton extends StatelessWidget {
  const PaywallLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final radius = context.dsRadius;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.s12,
              vertical: spacing.s12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius.r12),
              border: Border.all(color: context.dsColors.border),
            ),
            child: Row(
              children: [
                const DSSkeleton(height: 18, width: 18, borderRadius: BorderRadius.all(Radius.circular(9))),
                SizedBox(width: spacing.s12),
                Expanded(child: DSSkeleton(height: 18, width: 100)),
                SizedBox(width: spacing.s12),
                DSSkeleton(height: 18, width: 56),
              ],
            ),
          ),
          SizedBox(height: spacing.s8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.s12,
              vertical: spacing.s12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius.r12),
              border: Border.all(color: context.dsColors.border),
            ),
            child: Row(
              children: [
                const DSSkeleton(height: 18, width: 18, borderRadius: BorderRadius.all(Radius.circular(9))),
                SizedBox(width: spacing.s12),
                Expanded(child: DSSkeleton(height: 18, width: 100)),
                SizedBox(width: spacing.s12),
                DSSkeleton(height: 18, width: 56),
              ],
            ),
          ),
          SizedBox(height: spacing.s8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: spacing.s12,
              vertical: spacing.s12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius.r12),
              border: Border.all(color: context.dsColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSSkeleton(height: 20, width: 80),
                SizedBox(height: spacing.s8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DSSkeleton(height: 14, width: 14),
                    SizedBox(width: spacing.s8),
                    Expanded(child: DSSkeleton(height: 14, width: 180)),
                  ],
                ),
                SizedBox(height: spacing.s8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DSSkeleton(height: 14, width: 14),
                    SizedBox(width: spacing.s8),
                    Expanded(child: DSSkeleton(height: 14, width: 140)),
                  ],
                ),
                SizedBox(height: spacing.s8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DSSkeleton(height: 14, width: 14),
                    SizedBox(width: spacing.s8),
                    Expanded(child: DSSkeleton(height: 14, width: 160)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.s8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: spacing.s12,
              vertical: spacing.s12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius.r12),
              border: Border.all(color: context.dsColors.primary, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    DSSkeleton(height: 20, width: 60),
                    SizedBox(width: spacing.s8),
                    DSSkeleton(height: 22, width: 100, borderRadius: BorderRadius.circular(999)),
                  ],
                ),
                SizedBox(height: spacing.s8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DSSkeleton(height: 14, width: 14),
                    SizedBox(width: spacing.s8),
                    Expanded(child: DSSkeleton(height: 14, width: 160)),
                  ],
                ),
                SizedBox(height: spacing.s8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DSSkeleton(height: 14, width: 14),
                    SizedBox(width: spacing.s8),
                    Expanded(child: DSSkeleton(height: 14, width: 180)),
                  ],
                ),
                SizedBox(height: spacing.s8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DSSkeleton(height: 14, width: 14),
                    SizedBox(width: spacing.s8),
                    Expanded(child: DSSkeleton(height: 14, width: 150)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.s8),
        ],
      ),
    );
  }
}
