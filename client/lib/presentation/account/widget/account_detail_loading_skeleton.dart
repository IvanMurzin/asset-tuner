import 'package:asset_tuner/core_ui/components/ds_skeleton.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/presentation/account/utils/account_type_theme.dart';
import 'package:flutter/material.dart';

class AccountDetailLoadingSkeleton extends StatelessWidget {
  const AccountDetailLoadingSkeleton({super.key, this.accountType});

  final AccountType? accountType;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final colors = context.dsColors;
    final type = accountType ?? AccountType.other;
    final gradient = accountTypeGradientColors(colors, type);

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
                padding: EdgeInsets.all(spacing.s24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                  borderRadius: BorderRadius.circular(context.dsRadius.r16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const DSSkeleton(height: 40, width: 40),
                        SizedBox(width: spacing.s12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const DSSkeleton(height: 18, width: 150),
                              SizedBox(height: spacing.s8),
                              const DSSkeleton(height: 14, width: 90),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.s16),
                    const DSSkeleton(height: 14, width: 70),
                    SizedBox(height: spacing.s8),
                    const DSSkeleton(height: 42, width: double.infinity),
                    SizedBox(height: spacing.s12),
                    const DSSkeleton(height: 14, width: 210),
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
                        const DSSkeleton(height: 12, width: 56),
                      ],
                    ),
                  ),
                  SizedBox(width: spacing.s8),
                  Expanded(
                    child: Column(
                      children: [
                        const DSSkeleton(height: 52, width: 52),
                        SizedBox(height: spacing.s8),
                        const DSSkeleton(height: 12, width: 56),
                      ],
                    ),
                  ),
                  SizedBox(width: spacing.s8),
                  Expanded(
                    child: Column(
                      children: [
                        const DSSkeleton(height: 52, width: 52),
                        SizedBox(height: spacing.s8),
                        const DSSkeleton(height: 12, width: 56),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.s24),
              const DSSkeleton(height: 16, width: 120),
              SizedBox(height: spacing.s12),
              for (var i = 0; i < 4; i++) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: spacing.s12),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(context.dsRadius.r16),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    children: [
                      const DSSkeleton(height: 38, width: 38),
                      SizedBox(width: spacing.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const DSSkeleton(height: 18, width: 130),
                            SizedBox(height: spacing.s8),
                            const DSSkeleton(height: 12, width: 110),
                          ],
                        ),
                      ),
                      SizedBox(width: spacing.s12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const DSSkeleton(height: 18, width: 96),
                          SizedBox(height: spacing.s8),
                          const DSSkeleton(height: 14, width: 86),
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
