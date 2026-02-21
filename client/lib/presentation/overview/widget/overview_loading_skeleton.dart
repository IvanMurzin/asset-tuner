import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/components/ds_skeleton.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/presentation/account/widget/account_type_theme.dart';

class OverviewLoadingSkeleton extends StatelessWidget {
  const OverviewLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;

    return ListView(
      children: [
        SizedBox(height: spacing.s24),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.s24),
          child: const _SummarySkeleton(),
        ),
        SizedBox(height: spacing.s24),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.s24),
          child: const _AccountsSkeleton(),
        ),
        SizedBox(height: spacing.s24),
      ],
    );
  }
}

class _SummarySkeleton extends StatelessWidget {
  const _SummarySkeleton();

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final colors = context.dsColors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing.s24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary.withValues(alpha: 0.16), colors.info.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(context.dsRadius.r16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DSSkeleton(height: 16, width: 120),
          SizedBox(height: spacing.s12),
          const DSSkeleton(height: 42, width: double.infinity),
          const SizedBox(height: 10),
          const DSSkeleton(height: 14, width: 220),
          const SizedBox(height: 10),
          const DSSkeleton(height: 14, width: 180),
        ],
      ),
    );
  }
}

class _AccountsSkeleton extends StatelessWidget {
  const _AccountsSkeleton();

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;

    final types = [AccountType.bank, AccountType.wallet, AccountType.exchange];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var section = 0; section < 3; section++) ...[
          const DSSkeleton(height: 16, width: 96),
          SizedBox(height: spacing.s12),
          _AccountCardSkeleton(type: types[section]),
          const SizedBox(height: 10),
          if (section == 0) _AccountCardSkeleton(type: types[section]),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}

class _AccountCardSkeleton extends StatelessWidget {
  const _AccountCardSkeleton({required this.type});

  final AccountType type;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final colors = context.dsColors;
    final gradient = accountTypeGradientColors(colors, type);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: spacing.s12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(context.dsRadius.r16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          const DSSkeleton(height: 40, width: 40),
          SizedBox(width: spacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DSSkeleton(height: 18, width: 140),
                SizedBox(height: spacing.s8),
                const DSSkeleton(height: 12, width: 100),
              ],
            ),
          ),
          SizedBox(width: spacing.s12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const DSSkeleton(height: 16, width: 86),
              SizedBox(height: spacing.s8),
              const DSSkeleton(height: 14, width: 18),
            ],
          ),
        ],
      ),
    );
  }
}
