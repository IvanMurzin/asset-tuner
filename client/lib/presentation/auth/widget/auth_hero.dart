import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';

class AuthHero extends StatelessWidget {
  const AuthHero({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final radius = context.dsRadius;
    final elevation = context.dsElevation;

    return Center(
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius.r16),
          boxShadow: elevation.e2,
          color: colors.surface,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius.r16),
          child: Image.asset('assets/icon/icon.png', fit: BoxFit.cover),
        ),
      ),
    );
  }
}
