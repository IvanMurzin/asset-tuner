import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class PaywallHeader extends StatelessWidget {
  const PaywallHeader({
    super.key,
    required this.restoreLabel,
    this.onClose,
    this.onRestore,
    this.isBusy = false,
  });

  final String restoreLabel;
  final VoidCallback? onClose;
  final VoidCallback? onRestore;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final colors = context.dsColors;
    final typography = context.dsTypography;

    return Row(
      children: [
        _CloseAction(isBusy: isBusy, onTap: onClose),
        const Spacer(),
        TextButton(
          onPressed: isBusy ? null : onRestore,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: spacing.s8, vertical: spacing.s8),
            minimumSize: const Size(44, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            restoreLabel,
            style: typography.caption.copyWith(
              color: isBusy ? colors.textTertiary : colors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _CloseAction extends StatelessWidget {
  const _CloseAction({required this.isBusy, required this.onTap});

  final bool isBusy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = context.dsRadius;
    final colors = context.dsColors;

    final isEnabled = !isBusy && onTap != null;

    return InkResponse(
      radius: 20,
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(radius.r12),
          border: Border.all(color: colors.border),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.close_rounded,
          color: isEnabled ? colors.textSecondary : colors.textTertiary,
        ),
      ),
    );
  }
}
