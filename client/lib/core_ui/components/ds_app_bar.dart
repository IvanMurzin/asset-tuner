import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class DSAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DSAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final typography = context.dsTypography;

    return AppBar(
      title: Text(
        title,
        style: typography.h2.copyWith(color: colors.textPrimary),
      ),
      backgroundColor: colors.background,
      foregroundColor: colors.textPrimary,
      centerTitle: centerTitle,
      actions: actions,
      leading: leading,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
