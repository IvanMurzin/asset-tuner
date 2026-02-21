import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/components/ds_skeleton.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class AccountDetailPositionsLoadingSkeleton extends StatelessWidget {
  const AccountDetailPositionsLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;
    final colors = context.dsColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSSectionTitle(title: l10n.subaccountListTitle),
        SizedBox(height: spacing.s12),
        for (var i = 0; i < 2; i++) ...[
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
          if (i != 3) const SizedBox(height: 10),
        ],

      ],
    );
  }
}
