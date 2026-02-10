import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class DSSearchField extends StatelessWidget {
  const DSSearchField({super.key, this.hintText, this.controller, this.onChanged});

  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final typography = context.dsTypography;
    final radius = context.dsRadius;
    final spacing = context.dsSpacing;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: typography.body.copyWith(color: colors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText ?? 'Search',
        prefixIcon: Icon(Icons.search, color: colors.textTertiary),
        filled: true,
        fillColor: colors.surface,
        contentPadding: EdgeInsets.symmetric(horizontal: spacing.s16, vertical: spacing.s12),
        hintStyle: typography.body.copyWith(color: colors.textTertiary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.r12),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.r12),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.r12),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
    );
  }
}
