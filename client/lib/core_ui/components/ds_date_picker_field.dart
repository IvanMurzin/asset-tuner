import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/components/ds_text_field.dart';
import 'package:asset_tuner/core_ui/formatting/ds_formatters.dart';

class DSDatePickerField extends StatefulWidget {
  const DSDatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.errorText,
    this.firstDate,
    this.lastDate,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final bool enabled;
  final String? errorText;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  State<DSDatePickerField> createState() => _DSDatePickerFieldState();
}

class _DSDatePickerFieldState extends State<DSDatePickerField> {
  late final TextEditingController _controller;
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_locale == locale) {
      return;
    }
    _locale = locale;
    _syncText();
  }

  @override
  void didUpdateWidget(covariant DSDatePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _syncText();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DSTextField(
      label: widget.label,
      controller: _controller,
      enabled: widget.enabled,
      readOnly: true,
      errorText: widget.errorText,
      keyboardType: TextInputType.none,
      onTap: widget.enabled ? () => _pickDate(context) : null,
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.value ?? now,
      firstDate: widget.firstDate ?? DateTime(now.year - 10),
      lastDate: widget.lastDate ?? DateTime(now.year + 10),
    );
    if (picked != null) {
      widget.onChanged(picked);
    }
  }

  void _syncText() {
    final nextText = _text(context, widget.value);
    if (_controller.text == nextText) {
      return;
    }
    _controller.value = _controller.value.copyWith(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextText.length),
      composing: TextRange.empty,
    );
  }

  String _text(BuildContext context, DateTime? value) {
    if (value == null) {
      return '';
    }
    return context.dsFormatters.formatDate(value);
  }
}
