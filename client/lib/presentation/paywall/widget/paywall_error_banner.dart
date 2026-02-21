import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_banner.dart';

class PaywallErrorBanner extends StatelessWidget {
  const PaywallErrorBanner({
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
    return DSInlineBanner(
      title: title,
      message: message,
      variant: DSInlineBannerVariant.danger,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}
