import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/components/ds_text_field.dart';

class DSDecimalField extends StatelessWidget {
  const DSDecimalField({
    super.key,
    this.label,
    this.hintText,
    this.errorText,
    this.controller,
    this.enabled = true,
    this.readOnly = false,
    this.textAlign = TextAlign.start,
    this.onChanged,
    this.suffix,
  });

  final String? label;
  final String? hintText;
  final String? errorText;
  final TextEditingController? controller;
  final bool enabled;
  final bool readOnly;
  final TextAlign textAlign;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return DSTextField(
      label: label,
      hintText: hintText,
      errorText: errorText,
      controller: controller,
      enabled: enabled,
      readOnly: readOnly,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,+-]'))],
      textAlign: textAlign,
      onChanged: onChanged,
      suffix: suffix,
    );
  }
}
