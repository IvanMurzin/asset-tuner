import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_header.dart';
import 'package:flutter/material.dart';

/// The single paywall layout: the header (close is always available) above the current body.
class PaywallScaffold extends StatelessWidget {
  const PaywallScaffold({
    super.key,
    required this.closeLabel,
    required this.restoreLabel,
    required this.isBusy,
    required this.onClose,
    required this.onRestore,
    required this.body,
  });

  final String closeLabel;
  final String restoreLabel;
  final bool isBusy;
  final VoidCallback onClose;

  /// Null hides restore (it needs a ready RevenueCat identity and profile).
  final VoidCallback? onRestore;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(spacing.s16, spacing.s4, spacing.s16, spacing.s8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PaywallHeader(
                closeLabel: closeLabel,
                restoreLabel: restoreLabel,
                isBusy: isBusy,
                onClose: onClose,
                onRestore: onRestore,
              ),
              SizedBox(height: spacing.s8),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}
