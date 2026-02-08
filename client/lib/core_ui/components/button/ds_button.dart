import 'package:flutter/material.dart';

enum DSButtonVariant { primary, secondary, text }

class DSButton extends StatelessWidget {
  const DSButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = DSButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final DSButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;
    final callback = isEnabled ? onPressed : null;
    final scheme = Theme.of(context).colorScheme;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == DSButtonVariant.primary
                  ? scheme.onPrimary
                  : scheme.primary,
            ),
          ),
          const SizedBox(width: 10),
        ] else if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
        ],
        Text(label),
      ],
    );

    final button = switch (variant) {
      DSButtonVariant.primary => FilledButton(
        onPressed: callback,
        child: content,
      ),
      DSButtonVariant.secondary => OutlinedButton(
        onPressed: callback,
        child: content,
      ),
      DSButtonVariant.text => TextButton(onPressed: callback, child: content),
    };

    if (!fullWidth) {
      return button;
    }

    return SizedBox(width: double.infinity, child: button);
  }
}
