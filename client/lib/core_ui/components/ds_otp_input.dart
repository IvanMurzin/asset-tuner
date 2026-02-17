import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class DSOtpInput extends StatelessWidget {
  const DSOtpInput({
    super.key,
    required this.controller,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool enabled;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final typography = context.dsTypography;
    final radius = context.dsRadius;

    final defaultPinTheme = PinTheme(
      width: 44,
      height: 52,
      textStyle: typography.h3.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: enabled ? colors.surface : colors.surfaceAlt,
        borderRadius: BorderRadius.circular(radius.r12),
        border: Border.all(color: colors.border),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: colors.primary, width: 2),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(border: Border.all(color: colors.danger)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Pinput(
          length: 6,
          controller: controller,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: focusedPinTheme,
          disabledPinTheme: defaultPinTheme.copyWith(
            decoration: defaultPinTheme.decoration!.copyWith(color: colors.surfaceAlt),
          ),
          errorPinTheme: errorPinTheme,
          onChanged: onChanged,
          enabled: enabled,
          autofocus: autofocus,
          forceErrorState: errorText != null && errorText!.isNotEmpty,
          errorText: errorText,
          errorTextStyle: typography.caption.copyWith(color: colors.danger),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofillHints: const [AutofillHints.oneTimeCode],
        ),
      ],
    );
  }
}
