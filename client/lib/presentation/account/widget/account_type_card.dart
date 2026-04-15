import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/presentation/account/widget/account_type_theme.dart';

class AccountTypeCard extends StatelessWidget {
  const AccountTypeCard({
    super.key,
    required this.type,
    required this.title,
    required this.description,
    required this.selected,
    this.onTap,
  });

  final AccountType type;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final radius = context.dsRadius;

    final accentColor = accountTypeAccentColor(colors, type);
    final gradientColors = accountTypeGradientColors(colors, type);
    final icon = accountTypeIcon(type);

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(radius.r12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius.r12),
        child: Container(
          padding: EdgeInsets.all(spacing.s12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius.r12),
            border: Border.all(color: selected ? accentColor : colors.border, width: 1),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [gradientColors[0], gradientColors[1]],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(radius.r12),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              SizedBox(width: spacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: typography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: spacing.s4),
                    Text(
                      description,
                      style: typography.caption.copyWith(color: colors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (selected) Icon(Icons.check_circle_rounded, color: accentColor, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
