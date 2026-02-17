import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.email,
    required this.planLabel,
    required this.baseCurrency,
    this.isPaid = false,
    this.onManageSubscriptionTap,
  });

  final String email;
  final String planLabel;
  final String baseCurrency;
  final bool isPaid;
  final VoidCallback? onManageSubscriptionTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;
    final colors = context.dsColors;
    final typography = context.dsTypography;
    final radius = context.dsRadius;

    final initials = _initials(email);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.r16),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius.r16),
        child: Container(
          padding: EdgeInsets.all(spacing.s24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius.r16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.primary,
                colors.primary.withValues(alpha: 0.88),
                colors.info.withValues(alpha: 0.82),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.onPrimary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(radius.r12),
                      border: Border.all(
                        color: colors.onPrimary.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      initials,
                      style: typography.h2.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: spacing.s16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: typography.body.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: spacing.s8),
                        Text(
                          l10n.profileHeaderCurrencyLabel(baseCurrency),
                          style: typography.caption.copyWith(
                            color: colors.onPrimary.withValues(alpha: 0.9),
                          ),
                        ),
                        SizedBox(height: spacing.s12),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing.s12,
                            vertical: spacing.s8,
                          ),
                          decoration: BoxDecoration(
                            color: isPaid
                                ? colors.success.withValues(alpha: 0.28)
                                : colors.onPrimary.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(radius.r16),
                            border: Border.all(
                              color: isPaid
                                  ? colors.success.withValues(alpha: 0.6)
                                  : colors.onPrimary.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPaid
                                    ? Icons.workspace_premium_rounded
                                    : Icons.person_outline_rounded,
                                size: 14,
                                color: colors.onPrimary,
                              ),
                              SizedBox(width: spacing.s8),
                              Text(
                                planLabel,
                                style: typography.caption.copyWith(
                                  color: colors.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (onManageSubscriptionTap != null) ...[
                SizedBox(height: spacing.s16),
                Divider(height: 1, color: colors.onPrimary.withValues(alpha: 0.25)),
                SizedBox(height: spacing.s12),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onManageSubscriptionTap,
                    borderRadius: BorderRadius.circular(radius.r8),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: spacing.s8, horizontal: spacing.s4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.card_membership_rounded,
                            size: 18,
                            color: colors.onPrimary.withValues(alpha: 0.95),
                          ),
                          SizedBox(width: spacing.s4),
                          Text(
                            l10n.settingsManageSubscription,
                            style: typography.body.copyWith(
                              color: colors.onPrimary.withValues(alpha: 0.95),
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          SizedBox(width: spacing.s4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: colors.onPrimary.withValues(alpha: 0.8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
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
    final parts = name.split(RegExp(r'[._\\-\\s]+')).where((p) => p.isNotEmpty).toList();
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
