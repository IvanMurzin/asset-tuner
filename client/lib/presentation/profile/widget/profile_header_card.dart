import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.email,
    required this.planLabel,
    required this.baseCurrency,
  });

  final String email;
  final String planLabel;
  final String baseCurrency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;
    final colors = context.dsColors;
    final typography = context.dsTypography;
    final radius = context.dsRadius;

    final initials = _initials(email);

    return DSCard(
      bordered: false,
      elevation: DSElevationLevel.level2,
      padding: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.all(spacing.s16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primary.withValues(alpha: 0.92),
              colors.info.withValues(alpha: 0.86),
            ],
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.onPrimary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(radius.r16),
                border: Border.all(
                  color: colors.onPrimary.withValues(alpha: 0.22),
                ),
              ),
              child: Text(
                initials,
                style: typography.h3.copyWith(color: colors.onPrimary),
              ),
            ),
            SizedBox(width: spacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.h3.copyWith(color: colors.onPrimary),
                  ),
                  SizedBox(height: spacing.s4),
                  Text(
                    l10n.profileHeaderSubtitle(planLabel, baseCurrency),
                    style: typography.body.copyWith(
                      color: colors.onPrimary.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String email) {
    final cleaned = email.trim();
    if (cleaned.isEmpty) {
      return '?';
    }
    final at = cleaned.indexOf('@');
    final name = (at > 0 ? cleaned.substring(0, at) : cleaned).trim();
    if (name.isEmpty) {
      return '?';
    }
    final parts = name
        .split(RegExp(r'[._\\-\\s]+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return _firstCharUpper(name);
    }
    final first = _firstCharUpper(parts.first);
    final second = parts.length > 1 ? _firstCharUpper(parts[1]) : '';
    return (first + second).trim();
  }

  String _firstCharUpper(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    return String.fromCharCode(trimmed.runes.first).toUpperCase();
  }
}
