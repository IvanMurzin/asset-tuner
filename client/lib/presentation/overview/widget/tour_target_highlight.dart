import 'dart:ui';

import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:flutter/material.dart';

class TourTargetHighlight extends StatefulWidget {
  const TourTargetHighlight({super.key, required this.isActive, required this.child});

  final bool isActive;
  final Widget child;

  @override
  State<TourTargetHighlight> createState() => _TourTargetHighlightState();
}

class _TourTargetHighlightState extends State<TourTargetHighlight> with TickerProviderStateMixin {
  static const Duration _visibilityDuration = Duration(milliseconds: 180);
  static const Duration _pulseDuration = Duration(milliseconds: 1250);
  static const ValueKey<String> _overlayKey = ValueKey<String>('tour_target_highlight_overlay');

  late final AnimationController _visibilityController = AnimationController(
    vsync: this,
    duration: _visibilityDuration,
    value: widget.isActive ? 1 : 0,
  );
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: _pulseDuration,
  );
  late final Animation<double> _fadeAnimation = CurvedAnimation(
    parent: _visibilityController,
    curve: Curves.easeOut,
    reverseCurve: Curves.easeIn,
  );
  late final Animation<double> _scaleAnimation = Tween<double>(begin: 0.985, end: 1).animate(
    CurvedAnimation(
      parent: _visibilityController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ),
  );

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant TourTargetHighlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive == oldWidget.isActive) {
      return;
    }
    if (widget.isActive) {
      _visibilityController.forward();
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
      return;
    }
    _visibilityController.reverse();
    if (_pulseController.isAnimating) {
      _pulseController.stop(canceled: false);
    }
  }

  @override
  void dispose() {
    _visibilityController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = context.dsRadius;
    final colors = context.dsColors;

    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: Listenable.merge([_visibilityController, _pulseController]),
              builder: (context, _) {
                if (_visibilityController.value == 0 && !widget.isActive) {
                  return const SizedBox.shrink();
                }

                final pulseValue = _pulseController.value;
                final fade = _fadeAnimation.value;
                final scale =
                    (_scaleAnimation.value + (lerpDouble(0, 0.008, pulseValue) ?? 0)) *
                    (0.99 + 0.01 * fade);
                final borderAlpha = (lerpDouble(0.62, 0.92, pulseValue) ?? 0.8) * fade;

                return Transform.scale(
                  scale: scale,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: DecoratedBox(
                      key: _overlayKey,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(radius.r16 - 2),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: borderAlpha.clamp(0, 1)),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
