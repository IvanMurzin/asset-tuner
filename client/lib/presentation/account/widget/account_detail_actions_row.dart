import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:flutter/material.dart';

class AccountDetailActionsRow extends StatelessWidget {
  const AccountDetailActionsRow({
    super.key,
    required this.isEnabled,
    required this.onEdit,
    required this.onArchiveToggle,
    required this.onDelete,
    required this.isArchived,
    required this.editLabel,
    required this.archiveLabel,
    required this.unarchiveLabel,
    required this.deleteLabel,
  });

  final bool isEnabled;
  final VoidCallback onEdit;
  final VoidCallback onArchiveToggle;
  final VoidCallback onDelete;
  final bool isArchived;
  final String editLabel;
  final String archiveLabel;
  final String unarchiveLabel;
  final String deleteLabel;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _ActionItem(
            icon: Icons.edit_outlined,
            label: editLabel,
            onTap: isEnabled ? onEdit : null,
          ),
        ),
        SizedBox(width: spacing.s8),
        Expanded(
          child: _ActionItem(
            icon: isArchived
                ? Icons.unarchive_outlined
                : Icons.archive_outlined,
            label: isArchived ? unarchiveLabel : archiveLabel,
            onTap: isEnabled ? onArchiveToggle : null,
          ),
        ),
        SizedBox(width: spacing.s8),
        Expanded(
          child: _ActionItem(
            icon: Icons.delete_outline,
            label: deleteLabel,
            onTap: isEnabled ? onDelete : null,
            isDestructive: true,
          ),
        ),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;

    final accent = isDestructive ? colors.danger : colors.primary;
    final background = onTap == null
        ? colors.surfaceAlt
        : accent.withValues(alpha: 0.12);

    return InkWell(
      borderRadius: BorderRadius.circular(context.dsRadius.r16),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: spacing.s4),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: onTap == null
                      ? colors.border
                      : accent.withValues(alpha: 0.22),
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: onTap == null ? colors.textTertiary : accent,
                size: 22,
              ),
            ),
            SizedBox(height: spacing.s8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: typography.caption.copyWith(
                color: onTap == null
                    ? colors.textTertiary
                    : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
