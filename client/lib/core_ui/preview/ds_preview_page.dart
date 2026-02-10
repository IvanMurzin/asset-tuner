import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_button.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_decimal_field.dart';
import 'package:asset_tuner/core_ui/components/ds_dialog.dart';
import 'package:asset_tuner/core_ui/components/ds_empty_state.dart';
import 'package:asset_tuner/core_ui/components/ds_error_state.dart';
import 'package:asset_tuner/core_ui/components/ds_list_row.dart';
import 'package:asset_tuner/core_ui/components/ds_loader.dart';
import 'package:asset_tuner/core_ui/components/ds_skeleton.dart';
import 'package:asset_tuner/core_ui/components/ds_text_field.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/core_ui/theme/theme_mode_cubit.dart';

class DSPreviewPage extends StatelessWidget {
  const DSPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final colors = context.dsColors;
    final radius = context.dsRadius;

    return Scaffold(
      appBar: DSAppBar(
        title: 'Design System',
        actions: [
          Padding(
            padding: EdgeInsets.only(right: spacing.s12),
            child: const DSThemeSwitcher(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(spacing.s16, spacing.s16, spacing.s16, spacing.s32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DSPreviewHeroCard(),
            SizedBox(height: spacing.s24),
            Row(
              children: [
                Expanded(
                  child: DSPreviewStatCard(
                    icon: Icons.trending_up,
                    label: 'Monthly return',
                    value: '+4.2%',
                    accent: colors.success,
                  ),
                ),
                SizedBox(width: spacing.s12),
                Expanded(
                  child: DSPreviewStatCard(
                    icon: Icons.shield_outlined,
                    label: 'Risk score',
                    value: 'Low',
                    accent: colors.info,
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.s24),
            DSPreviewSection(
              title: 'Typography',
              child: DSCard(
                elevation: DSElevationLevel.level0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Heading 1', style: typography.h1),
                    SizedBox(height: spacing.s8),
                    Text('Heading 2', style: typography.h2),
                    SizedBox(height: spacing.s8),
                    Text('Heading 3', style: typography.h3),
                    SizedBox(height: spacing.s8),
                    Text('Body text example', style: typography.body),
                    SizedBox(height: spacing.s8),
                    Text('Caption text', style: typography.caption),
                    SizedBox(height: spacing.s8),
                    Text('123,456.78', style: typography.totalNumeric),
                  ],
                ),
              ),
            ),
            SizedBox(height: spacing.s24),
            DSPreviewSection(
              title: 'Buttons',
              child: Wrap(
                spacing: spacing.s12,
                runSpacing: spacing.s12,
                children: [
                  DSButton(label: 'Add asset', leadingIcon: Icons.add, onPressed: () {}),
                  DSButton(
                    label: 'Secondary',
                    variant: DSButtonVariant.secondary,
                    onPressed: () {},
                  ),
                  DSButton(
                    label: 'Delete',
                    variant: DSButtonVariant.danger,
                    leadingIcon: Icons.delete_outline,
                    onPressed: () {},
                  ),
                  const DSButton(label: 'Loading', isLoading: true),
                ],
              ),
            ),
            SizedBox(height: spacing.s24),
            DSPreviewSection(
              title: 'Inputs',
              child: DSCard(
                child: Column(
                  children: [
                    const DSTextField(label: 'Account name', hintText: 'e.g., Cash USD'),
                    SizedBox(height: spacing.s12),
                    const DSDecimalField(label: 'Amount', hintText: '0.00'),
                  ],
                ),
              ),
            ),
            SizedBox(height: spacing.s24),
            DSPreviewSection(
              title: 'Cards',
              child: DSCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Portfolio snapshot', style: typography.h3),
                    SizedBox(height: spacing.s8),
                    Text(
                      'Diversified across 6 accounts and 19 assets.',
                      style: typography.body.copyWith(color: colors.textSecondary),
                    ),
                    SizedBox(height: spacing.s12),
                    Row(
                      children: [
                        Expanded(
                          child: DSButton(
                            label: 'View report',
                            variant: DSButtonVariant.secondary,
                            onPressed: () {},
                          ),
                        ),
                        SizedBox(width: spacing.s12),
                        Expanded(
                          child: DSButton(label: 'Rebalance', onPressed: () {}),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: spacing.s24),
            DSPreviewSection(
              title: 'List Items',
              child: DSCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    DSListRow(
                      title: 'Checking Account',
                      subtitle: 'Bank',
                      trailing: Text('€2,450', style: typography.body),
                      showDivider: true,
                      onTap: () {},
                    ),
                    DSListRow(
                      title: 'Brokerage',
                      subtitle: 'Investment',
                      trailing: Text('€38,120', style: typography.body),
                      showDivider: true,
                      onTap: () {},
                    ),
                    DSListRow(
                      title: 'Cash Wallet',
                      subtitle: 'Cash',
                      trailing: Text('€120', style: typography.body),
                      selected: true,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: spacing.s24),
            DSPreviewSection(
              title: 'Dialogs',
              child: DSButton(
                label: 'Show dialog',
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) => DSDialog(
                      title: 'Delete account',
                      content: const Text('This action cannot be undone.'),
                      primaryLabel: 'Delete',
                      onPrimary: () => Navigator.of(context).pop(),
                      secondaryLabel: 'Cancel',
                      onSecondary: () => Navigator.of(context).pop(),
                      isDestructive: true,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: spacing.s24),
            DSPreviewSection(title: 'Loaders', child: const DSLoader()),
            SizedBox(height: spacing.s24),
            DSPreviewSection(
              title: 'Shimmers',
              child: DSCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DSSkeleton(height: 120, borderRadius: BorderRadius.circular(radius.r16)),
                    SizedBox(height: spacing.s16),
                    Row(
                      children: [
                        DSSkeleton(
                          width: 44,
                          height: 44,
                          borderRadius: BorderRadius.circular(radius.r16),
                        ),
                        SizedBox(width: spacing.s12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DSSkeleton(height: 14, width: 140),
                              SizedBox(height: spacing.s8),
                              DSSkeleton(height: 12, width: 220),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: spacing.s24),
            DSPreviewSection(
              title: 'States',
              child: DSCard(
                child: Column(
                  children: [
                    DSEmptyState(
                      title: 'No accounts',
                      message: 'Create your first account to get started.',
                      actionLabel: 'Create account',
                      onAction: () {},
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    SizedBox(height: spacing.s24),
                    DSErrorState(
                      title: 'Something went wrong',
                      message: 'We could not load your data. Try again.',
                      actionLabel: 'Try again',
                      onAction: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DSThemeSwitcher extends StatelessWidget {
  const DSThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;

    return BlocBuilder<ThemeModeCubit, ThemeMode>(
      builder: (context, mode) {
        final brightness = mode == ThemeMode.system
            ? Theme.of(context).brightness
            : (mode == ThemeMode.dark ? Brightness.dark : Brightness.light);
        final isDark = brightness == Brightness.dark;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.light_mode,
              size: spacing.s16,
              color: isDark ? colors.textTertiary : colors.primary,
            ),
            SizedBox(width: spacing.s4),
            Switch(
              value: isDark,
              onChanged: (value) {
                context.read<ThemeModeCubit>().set(value ? ThemeMode.dark : ThemeMode.light);
              },
              activeThumbColor: colors.onPrimary,
              activeTrackColor: colors.primary,
              inactiveThumbColor: colors.surface,
              inactiveTrackColor: colors.surfaceAlt,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            SizedBox(width: spacing.s4),
            Icon(
              Icons.dark_mode,
              size: spacing.s16,
              color: isDark ? colors.primary : colors.textTertiary,
            ),
          ],
        );
      },
    );
  }
}

class DSPreviewSection extends StatelessWidget {
  const DSPreviewSection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: typography.h2),
        SizedBox(height: spacing.s12),
        child,
      ],
    );
  }
}

class DSPreviewHeroCard extends StatelessWidget {
  const DSPreviewHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final radius = context.dsRadius;
    final typography = context.dsTypography;
    final elevation = context.dsElevation;

    return Container(
      padding: EdgeInsets.all(spacing.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.primaryHover],
        ),
        borderRadius: BorderRadius.circular(radius.r16),
        boxShadow: elevation.e2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total balance',
            style: typography.caption.copyWith(color: colors.onPrimary.withValues(alpha: 0.85)),
          ),
          SizedBox(height: spacing.s8),
          Text('€128,940.32', style: typography.totalNumeric.copyWith(color: colors.onPrimary)),
          SizedBox(height: spacing.s12),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: spacing.s8, vertical: spacing.s4),
                decoration: BoxDecoration(
                  color: colors.onPrimary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(radius.r8),
                ),
                child: Text(
                  '+4.2% this month',
                  style: typography.caption.copyWith(color: colors.onPrimary),
                ),
              ),
              SizedBox(width: spacing.s12),
              Text(
                'Updated 2m ago',
                style: typography.caption.copyWith(color: colors.onPrimary.withValues(alpha: 0.75)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DSPreviewStatCard extends StatelessWidget {
  const DSPreviewStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final radius = context.dsRadius;
    final colors = context.dsColors;

    return DSCard(
      elevation: DSElevationLevel.level1,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(spacing.s8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(radius.r12),
            ),
            child: Icon(icon, color: accent, size: spacing.s16),
          ),
          SizedBox(width: spacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: typography.caption.copyWith(color: colors.textSecondary)),
                SizedBox(height: spacing.s4),
                Text(value, style: typography.h3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
