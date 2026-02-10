import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/components/ds_error_state.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class DSInlineError extends StatelessWidget {
  const DSInlineError({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;

    return Padding(
      padding: EdgeInsets.all(spacing.s16),
      child: Center(
        child: DSErrorState(
          title: title,
          message: message,
          actionLabel: actionLabel,
          onAction: onAction,
        ),
      ),
    );
  }
}
