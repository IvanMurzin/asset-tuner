import 'package:asset_tuner/core_ui/components/ds_decimal_field.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:flutter/material.dart';

class DSBalanceInput extends StatelessWidget {
  const DSBalanceInput({
    super.key,
    this.label,
    this.hintText,
    this.amountErrorText,
    this.currencyErrorText,
    this.controller,
    this.enabled = true,
    this.readOnly = false,
    this.textAlign = TextAlign.start,
    this.onChanged,
    this.currencyBadge,
  });

  final String? label;
  final String? hintText;
  final String? amountErrorText;
  final String? currencyErrorText;
  final TextEditingController? controller;
  final bool enabled;
  final bool readOnly;
  final TextAlign textAlign;
  final ValueChanged<String>? onChanged;
  final Widget? currencyBadge;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final hasCurrencyError = currencyErrorText != null && currencyErrorText!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSDecimalField(
          label: label,
          hintText: hintText,
          errorText: amountErrorText,
          controller: controller,
          enabled: enabled,
          readOnly: readOnly,
          textAlign: textAlign,
          onChanged: onChanged,
          suffix: currencyBadge,
        ),
        if (hasCurrencyError) ...[
          SizedBox(height: spacing.s4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              currencyErrorText!,
              textAlign: TextAlign.right,
              style: typography.caption.copyWith(color: colors.danger),
            ),
          ),
        ],
      ],
    );
  }
}
