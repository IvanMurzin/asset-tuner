import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class DSTextField extends StatelessWidget {
  const DSTextField({
    super.key,
    this.label,
    this.hintText,
    this.errorText,
    this.controller,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    this.readOnly = false,
    this.onChanged,
    this.maxLines = 1,
  });

  final String? label;
  final String? hintText;
  final String? errorText;
  final TextEditingController? controller;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final typography = context.dsTypography;
    final radius = context.dsRadius;
    final spacing = context.dsSpacing;

    final fillColor = enabled ? colors.surface : colors.surfaceAlt;

    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textAlign: textAlign,
      readOnly: readOnly,
      onChanged: onChanged,
      maxLines: maxLines,
      style: typography.body.copyWith(color: colors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        errorText: errorText,
        filled: true,
        fillColor: fillColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacing.s16,
          vertical: spacing.s12,
        ),
        labelStyle: typography.label.copyWith(color: colors.textSecondary),
        hintStyle: typography.body.copyWith(color: colors.textTertiary),
        errorStyle: typography.caption.copyWith(color: colors.danger),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.r12),
          borderSide: BorderSide(color: colors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.r12),
          borderSide: BorderSide(color: colors.danger, width: 1.5),
        ),
      ),
    );
  }
}
