import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ManageSubscriptionActionsCard extends StatelessWidget {
  const ManageSubscriptionActionsCard({
    super.key,
    required this.isPaid,
    required this.isSyncing,
    required this.onManagePressed,
    required this.onUpgradePressed,
    required this.onRestorePressed,
  });

  final bool isPaid;
  final bool isSyncing;
  final Future<void> Function() onManagePressed;
  final Future<void> Function() onUpgradePressed;
  final Future<void> Function() onRestorePressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DSCard(
      child: Column(
        children: [
          if (isPaid)
            DSButton(
              label: l10n.subscriptionManage,
              variant: DSButtonVariant.secondary,
              fullWidth: true,
              isLoading: isSyncing,
              onPressed: isSyncing ? null : () => onManagePressed(),
            )
          else
            DSButton(
              label: l10n.subscriptionUpgrade,
              fullWidth: true,
              leadingIcon: Icons.workspace_premium_rounded,
              isLoading: isSyncing,
              onPressed: isSyncing ? null : () => onUpgradePressed(),
            ),
          SizedBox(height: context.dsSpacing.s12),
          DSButton(
            label: l10n.subscriptionRestore,
            variant: DSButtonVariant.secondary,
            fullWidth: true,
            isLoading: isSyncing,
            onPressed: isSyncing ? null : () => onRestorePressed(),
          ),
        ],
      ),
    );
  }
}
