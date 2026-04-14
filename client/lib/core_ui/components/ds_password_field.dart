import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class DSPasswordField extends StatefulWidget {
  const DSPasswordField({
    super.key,
    this.label,
    this.hintText,
    this.errorText,
    this.controller,
    this.enabled = true,
    this.onChanged,
  });

  final String? label;
  final String? hintText;
  final String? errorText;
  final TextEditingController? controller;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  State<DSPasswordField> createState() => _DSPasswordFieldState();
}

class _DSPasswordFieldState extends State<DSPasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final typography = context.dsTypography;
    final radius = context.dsRadius;
    final spacing = context.dsSpacing;

    final fillColor = widget.enabled ? colors.surface : colors.surfaceAlt;

    return TextField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: _obscured,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      onChanged: widget.onChanged,
      style: typography.body.copyWith(color: colors.textPrimary),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        errorText: widget.errorText,
        filled: true,
        fillColor: fillColor,
        contentPadding: EdgeInsets.symmetric(horizontal: spacing.s16, vertical: spacing.s12),
        labelStyle: typography.body.copyWith(color: colors.textSecondary),
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
        suffixIcon: IconButton(
          onPressed: widget.enabled ? () => setState(() => _obscured = !_obscured) : null,
          icon: Icon(
            _obscured ? Icons.visibility_off : Icons.visibility,
            color: colors.textTertiary,
          ),
        ),
      ),
    );
  }
}
