import 'package:flutter/material.dart';
import 'package:template/core_ui/tokens/ds_spacing.dart';

class DSCard extends StatelessWidget {
  const DSCard({super.key, required this.child, this.header, this.padding});

  final Widget child;
  final Widget? header;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(DSSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (header != null) ...[
              header!,
              const SizedBox(height: DSSpacing.s12),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
