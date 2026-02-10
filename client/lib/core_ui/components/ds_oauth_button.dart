import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';

enum DSOAuthProvider { google, apple }

class DSOAuthButton extends StatelessWidget {
  const DSOAuthButton({
    super.key,
    required this.provider,
    required this.label,
    required this.onPressed,
  });

  final DSOAuthProvider provider;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final icon = switch (provider) {
      DSOAuthProvider.google => Icons.g_mobiledata,
      DSOAuthProvider.apple => Icons.apple,
    };

    return DSButton(
      label: label,
      leadingIcon: icon,
      variant: DSButtonVariant.secondary,
      onPressed: onPressed,
      fullWidth: true,
    );
  }
}
