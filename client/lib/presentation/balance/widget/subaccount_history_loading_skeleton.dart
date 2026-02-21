import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/components/ds_skeleton.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class SubaccountHistoryLoadingSkeleton extends StatelessWidget {
  const SubaccountHistoryLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;
    final colors = context.dsColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSSectionTitle(title: l10n.positionHistoryTitle),
        SizedBox(height: spacing.s12),
        Expanded(
          child: ListView(
            children: [
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
      ],
    );
  }
}
