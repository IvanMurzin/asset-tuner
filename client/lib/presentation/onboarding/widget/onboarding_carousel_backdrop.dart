import 'dart:ui';

import 'package:flutter/material.dart';

class OnboardingCarouselBackdrop extends StatelessWidget {
  const OnboardingCarouselBackdrop({
    super.key,
    required this.page,
    required this.primary,
    required this.surface,
  });

  final int page;
  final Color primary;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    final p = page.clamp(0, 2);
    final a = (p == 0)
        ? 0.10
        : (p == 1)
        ? 0.14
        : 0.18;
    final b = (p == 0)
        ? 0.08
        : (p == 1)
        ? 0.12
        : 0.10;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withValues(alpha: 0.18 + a),
            surface,
            primary.withValues(alpha: 0.10 + b),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          _OnboardingBlob(
            alignment: const Alignment(-0.9, -0.85),
            color: primary.withValues(alpha: 0.18),
            size: 260,
            blur: 22,
            dx: p == 0 ? -10 : (p == 1 ? 14 : 28),
            dy: p == 0 ? -8 : (p == 1 ? 10 : 22),
          ),
          _OnboardingBlob(
            alignment: const Alignment(0.9, -0.35),
            color: primary.withValues(alpha: 0.14),
            size: 220,
            blur: 24,
            dx: p == 0 ? 20 : (p == 1 ? 0 : -16),
            dy: p == 0 ? -6 : (p == 1 ? 12 : 26),
          ),
          _OnboardingBlob(
            alignment: const Alignment(0.0, 0.95),
            color: primary.withValues(alpha: 0.12),
            size: 320,
            blur: 26,
            dx: p == 0 ? 0 : (p == 1 ? -18 : -34),
            dy: p == 0 ? 20 : (p == 1 ? 10 : 0),
          ),
        ],
      ),
    );
  }
}

class _OnboardingBlob extends StatelessWidget {
  const _OnboardingBlob({
    required this.alignment,
    required this.color,
    required this.size,
    required this.blur,
    required this.dx,
    required this.dy,
  });

  final Alignment alignment;
  final Color color;
  final double size;
  final double blur;
  final double dx;
  final double dy;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: Offset(dx, dy),
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ),
      ),
    );
  }
}
