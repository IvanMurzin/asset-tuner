import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class DSOverflowMenuItem {
  const DSOverflowMenuItem({
    required this.label,
    required this.onTap,
    this.icon,
    this.isDestructive = false,
  });

  final String label;
  final IconData? icon;
  final bool isDestructive;
  final VoidCallback onTap;
}

class DSOverflowMenu extends StatelessWidget {
  const DSOverflowMenu({
    super.key,
    required this.items,
    this.enabled = true,
    this.tooltip,
  });

  final List<DSOverflowMenuItem> items;
  final bool enabled;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final typography = context.dsTypography;

    return PopupMenuButton<int>(
      enabled: enabled,
      tooltip: tooltip,
      icon: Icon(
        Icons.more_vert,
        color: enabled ? colors.textTertiary : colors.textTertiary,
      ),
      onSelected: (index) => items[index].onTap(),
      itemBuilder: (context) {
        return [
          for (var i = 0; i < items.length; i++)
            PopupMenuItem<int>(
              value: i,
              child: Row(
                children: [
                  if (items[i].icon != null) ...[
                    Icon(
                      items[i].icon,
                      size: 18,
                      color: items[i].isDestructive
                          ? colors.danger
                          : colors.textSecondary,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    items[i].label,
                    style: typography.body.copyWith(
                      color: items[i].isDestructive
                          ? colors.danger
                          : colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
        ];
      },
    );
  }
}
