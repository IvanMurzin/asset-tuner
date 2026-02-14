import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class DSUnlockCurrenciesCard extends StatefulWidget {
  const DSUnlockCurrenciesCard({super.key, required this.title, this.onTap});

  final String title;
  final VoidCallback? onTap;

  @override
  State<DSUnlockCurrenciesCard> createState() => _DSUnlockCurrenciesCardState();
}

class _DSUnlockCurrenciesCardState extends State<DSUnlockCurrenciesCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final radius = context.dsRadius;

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius.r16),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.15 * _pulse.value),
                blurRadius: 12 + (4 * _pulse.value),
                spreadRadius: 0.5 * _pulse.value,
              ),
            ],
          ),
          child: Material(
            color: colors.surface,
            borderRadius: BorderRadius.circular(radius.r16),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(radius.r16),
              child: Container(
                padding: EdgeInsets.all(spacing.s12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius.r16),
                  border: Border.all(color: colors.primary.withValues(alpha: 0.35), width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(radius.r12),
                      ),
                      child: Icon(Icons.lock_open_rounded, color: colors.primary, size: 20),
                    ),
                    SizedBox(width: spacing.s12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: typography.body.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 14, color: colors.primary),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
