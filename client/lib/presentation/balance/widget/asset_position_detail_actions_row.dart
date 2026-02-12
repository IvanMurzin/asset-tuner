import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:flutter/material.dart';

class AssetPositionDetailActionsRow extends StatelessWidget {
  const AssetPositionDetailActionsRow({
    super.key,
    required this.isEnabled,
    required this.updateLabel,
    required this.renameLabel,
    required this.deleteLabel,
    required this.onUpdate,
    required this.onRename,
    required this.onDelete,
  });

  final bool isEnabled;
  final String updateLabel;
  final String renameLabel;
  final String deleteLabel;
  final VoidCallback onUpdate;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;

    return Row(
      children: [
        Expanded(
          child: _ActionCircle(
            icon: Icons.sync_alt,
            label: updateLabel,
            onTap: isEnabled ? onUpdate : null,
            accentResolver: (colors) => colors.info,
          ),
        ),
        SizedBox(width: spacing.s8),
        Expanded(
          child: _ActionCircle(
            icon: Icons.edit_outlined,
            label: renameLabel,
            onTap: isEnabled ? onRename : null,
            accentResolver: (colors) => colors.primary,
          ),
        ),
        SizedBox(width: spacing.s8),
        Expanded(
          child: _ActionCircle(
            icon: Icons.delete_outline,
            label: deleteLabel,
            onTap: isEnabled ? onDelete : null,
            accentResolver: (colors) => colors.danger,
          ),
        ),
      ],
    );
  }
}

class _ActionCircle extends StatelessWidget {
  const _ActionCircle({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.accentResolver,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color Function(DSColors colors) accentResolver;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final typography = context.dsTypography;
    final spacing = context.dsSpacing;
    final accent = accentResolver(colors);

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
                color: onTap == null
                    ? colors.surfaceAlt
                    : accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: onTap == null
                      ? colors.border
                      : accent.withValues(alpha: 0.25),
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
