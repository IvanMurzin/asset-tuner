import 'package:flutter/material.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_args.dart';

class PaywallPlanToggle extends StatelessWidget {
  const PaywallPlanToggle({
    super.key,
    required this.monthlyLabel,
    required this.yearlyLabel,
    this.annualBadgeText,
    required this.selectedOption,
    required this.monthlyEnabled,
    required this.yearlyEnabled,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.onChanged,
  });

  final String monthlyLabel;
  final String yearlyLabel;
  final String? annualBadgeText;
  final PaywallPlanOption selectedOption;
  final bool monthlyEnabled;
  final bool yearlyEnabled;
  final String monthlyPrice;
  final String yearlyPrice;
  final ValueChanged<PaywallPlanOption> onChanged;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    return Column(
      children: [
        _PlanItem(
          itemKey: const Key('paywall_plan_item_monthly'),
          label: monthlyLabel,
          price: monthlyPrice,
          selected: selectedOption == PaywallPlanOption.monthly,
          enabled: monthlyEnabled,
          onTap: () => onChanged(PaywallPlanOption.monthly),
        ),
        SizedBox(height: spacing.s8),
        _PlanItem(
          itemKey: const Key('paywall_plan_item_annual'),
          label: yearlyLabel,
          badgeText: annualBadgeText,
          price: yearlyPrice,
          selected: selectedOption == PaywallPlanOption.annual,
          enabled: yearlyEnabled,
          onTap: () => onChanged(PaywallPlanOption.annual),
        ),
      ],
    );
  }
}

class _SelectionDot extends StatelessWidget {
  const _SelectionDot({required this.selected, required this.enabled});

  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: enabled
              ? (selected ? colors.primary : colors.textTertiary)
              : colors.textTertiary.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: selected ? 8 : 0,
          height: selected ? 8 : 0,
          decoration: BoxDecoration(
            color: enabled ? colors.primary : colors.textTertiary.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _PlanItem extends StatelessWidget {
  const _PlanItem({
    this.itemKey,
    required this.label,
    this.badgeText,
    required this.price,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final Key? itemKey;
  final String label;
  final String? badgeText;
  final String price;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final radius = context.dsRadius;
    final colors = context.dsColors;
    final typography = context.dsTypography;
    final hasBadge = badgeText != null && badgeText!.isNotEmpty;

    final content = Stack(
      key: itemKey,
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(horizontal: spacing.s12, vertical: spacing.s12),
          decoration: BoxDecoration(
            color: selected ? colors.surface : colors.surfaceAlt.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(radius.r12),
            border: Border.all(
              color: selected ? colors.primary.withValues(alpha: 0.75) : colors.border,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: colors.neutral950.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            children: [
              _SelectionDot(selected: selected, enabled: enabled),
              SizedBox(width: spacing.s12),
              Expanded(
                child: Text(
                  label,
                  style: typography.body.copyWith(
                    color: enabled
                        ? (selected ? colors.textPrimary : colors.textSecondary)
                        : colors.textTertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: spacing.s12),
              Text(
                price,
                textAlign: TextAlign.right,
                style: typography.body.copyWith(
                  color: enabled ? colors.textPrimary : colors.textTertiary.withValues(alpha: 0.7),
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (hasBadge)
          Positioned(
            right: spacing.s12,
            bottom: -(spacing.s12),
            child: Container(
              key: const Key('paywall_plan_badge'),
              padding: EdgeInsets.symmetric(horizontal: spacing.s8, vertical: spacing.s4),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badgeText!,
                style: typography.caption.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );

    if (!enabled) {
      return Opacity(opacity: 0.55, child: content);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(borderRadius: BorderRadius.circular(radius.r12), onTap: onTap, child: content),
    );
  }
}
