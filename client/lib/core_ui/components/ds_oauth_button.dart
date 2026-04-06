import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

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
    final spacing = context.dsSpacing;
    final colors = context.dsColors;
    final isEnabled = onPressed != null;
    final appleColor = isEnabled ? colors.textPrimary : colors.textTertiary;
    final icon = switch (provider) {
      DSOAuthProvider.google => SvgPicture.asset(
        'assets/icon/google.svg',
        width: spacing.s16,
        height: spacing.s16,
      ),
      DSOAuthProvider.apple => SvgPicture.asset(
        'assets/icon/apple.svg',
        width: spacing.s16,
        height: spacing.s16,
        colorFilter: ColorFilter.mode(appleColor, BlendMode.srcIn),
      ),
    };

    return DSButton(
      label: label,
      leading: icon,
      variant: DSButtonVariant.secondary,
      onPressed: onPressed,
      fullWidth: true,
    );
  }
}
