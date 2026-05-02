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
import 'package:asset_tuner/core_ui/formatting/ds_formatters.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/core_ui/theme/theme_mode_cubit.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';

class DSPreviewPage extends StatelessWidget {
  const DSPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final colors = context.dsColors;
    final radius = context.dsRadius;
    final formatters = context.dsFormatters;

    final updatedAt = DateTime(2026, 2, 10, 9, 30);
    final total = formatters.formatDecimal(
      128940.32,
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    );
    final percent =
        '+${formatters.formatDecimal(4.2, minimumFractionDigits: 1, maximumFractionDigits: 1)}%';
    final smallAmount = formatters.formatDecimal(2450, maximumFractionDigits: 0);
    final mediumAmount = formatters.formatDecimal(38120, maximumFractionDigits: 0);
    final tinyAmount = formatters.formatDecimal(120, maximumFractionDigits: 0);

    return Scaffold(
      appBar: DSAppBar(
        title: l10n.designSystemPreview,
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
            DSPreviewHeroCard(
              title: l10n.dsPreviewTotalBalanceLabel,
              amountText: '€$total',
              badgeText: l10n.dsPreviewPercentThisMonth(percent),
              updatedText: l10n.dsPreviewUpdatedAt(formatters.formatDateTime(updatedAt)),
            ),
            SizedBox(height: spacing.s24),
            Row(
              children: [
                Expanded(
                  child: DSPreviewStatCard(
                    icon: Icons.trending_up,
                    label: l10n.dsPreviewMonthlyReturnLabel,
                    value: percent,
                    accent: colors.success,
                  ),
                ),
                SizedBox(width: spacing.s12),
                Expanded(
                  child: DSPreviewStatCard(
                    icon: Icons.shield_outlined,
                    label: l10n.dsPreviewRiskScoreLabel,
                    value: l10n.dsPreviewRiskLow,
                    accent: colors.info,
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.s24),
            DSPreviewSection(
              title: l10n.dsPreviewSectionTypography,
              child: DSCard(
                elevation: DSElevationLevel.level0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.dsPreviewTypographyH1, style: typography.h1),
                    SizedBox(height: spacing.s8),
                    Text(l10n.dsPreviewTypographyH2, style: typography.h2),
                    SizedBox(height: spacing.s8),
                    Text(l10n.dsPreviewTypographyH3, style: typography.h3),
                    SizedBox(height: spacing.s8),
                    Text(l10n.dsPreviewTypographyBody, style: typography.body),
                    SizedBox(height: spacing.s8),
                    Text(l10n.dsPreviewTypographyCaption, style: typography.caption),
                    SizedBox(height: spacing.s8),
                    Text(
                      formatters.formatDecimal(
                        123456.78,
                        minimumFractionDigits: 2,
                        maximumFractionDigits: 2,
                      ),
                      style: typography.totalNumeric,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: spacing.s24),
            DSPreviewSection(
              title: l10n.dsPreviewSectionButtons,
              child: Wrap(
                spacing: spacing.s12,
                runSpacing: spacing.s12,
                children: [
                  DSButton(
                    label: l10n.dsPreviewButtonAddAsset,
                    leadingIcon: Icons.add,
                    onPressed: () {},
                  ),
                  DSButton(
                    label: l10n.dsPreviewButtonSecondary,
                    variant: DSButtonVariant.secondary,
                    onPressed: () {},
                  ),
                  DSButton(
                    label: l10n.dsPreviewButtonDelete,
                    variant: DSButtonVariant.danger,
                    leadingIcon: Icons.delete_outline,
                    onPressed: () {},
                  ),
                  DSButton(label: l10n.dsPreviewButtonLoading, isLoading: true),
                ],
              ),
            ),
            SizedBox(height: spacing.s24),
            DSPreviewSection(
              title: l10n.dsPreviewSectionInputs,
              child: DSCard(
                child: Column(
                  children: [
                    DSTextField(
                      label: l10n.dsPreviewInputAccountNameLabel,
                      hintText: l10n.dsPreviewInputAccountNameHint,
                    ),
                    SizedBox(height: spacing.s12),
                    DSDecimalField(
                      label: l10n.dsPreviewInputAmountLabel,
                      hintText: formatters.formatDecimal(
                        0,
                        minimumFractionDigits: 2,
                        maximumFractionDigits: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: spacing.s24),
            DSPreviewSection(
              title: l10n.dsPreviewSectionCards,
              child: DSCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.dsPreviewCardPortfolioTitle, style: typography.h3),
                    SizedBox(height: spacing.s8),
                    Text(
                      l10n.dsPreviewCardPortfolioBody,
                      style: typography.body.copyWith(color: colors.textSecondary),
                    ),
                    SizedBox(height: spacing.s12),
                    Row(
                      children: [
                        Expanded(
                          child: DSButton(
                            label: l10n.dsPreviewCardViewReport,
                            variant: DSButtonVariant.secondary,
                            onPressed: () {},
                          ),
                        ),
                        SizedBox(width: spacing.s12),
                        Expanded(
                          child: DSButton(label: l10n.dsPreviewCardRebalance, onPressed: () {}),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: spacing.s24),
            DSPreviewSection(
              title: l10n.dsPreviewSectionListItems,
              child: DSCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    DSListRow(
                      title: l10n.dsPreviewListCheckingTitle,
                      subtitle: l10n.dsPreviewListBankSubtitle,
                      trailing: Text('€$smallAmount', style: typography.body),
                      showDivider: true,
                      onTap: () {},
                    ),
                    DSListRow(
                      title: l10n.dsPreviewListBrokerageTitle,
                      subtitle: l10n.dsPreviewListInvestmentSubtitle,
                      trailing: Text('€$mediumAmount', style: typography.body),
                      showDivider: true,
                      onTap: () {},
                    ),
                    DSListRow(
                      title: l10n.dsPreviewListCashWalletTitle,
                      subtitle: l10n.dsPreviewListCashSubtitle,
                      trailing: Text('€$tinyAmount', style: typography.body),
                      selected: true,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: spacing.s24),
            DSPreviewSection(
              title: l10n.dsPreviewSectionDialogs,
              child: DSButton(
                label: l10n.dsPreviewDialogShowButton,
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) => DSDialog(
                      title: l10n.dsPreviewDialogDeleteAccountTitle,
                      content: Text(l10n.dsPreviewDialogDeleteAccountBody),
                      primaryLabel: l10n.dsPreviewButtonDelete,
                      onPrimary: () => Navigator.of(context).pop(),
                      secondaryLabel: l10n.dsPreviewDialogCancel,
                      onSecondary: () => Navigator.of(context).pop(),
                      isDestructive: true,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: spacing.s24),
            DSPreviewSection(title: l10n.dsPreviewSectionLoaders, child: const DSLoader()),
            SizedBox(height: spacing.s24),
            DSPreviewSection(
              title: l10n.dsPreviewSectionShimmers,
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
              title: l10n.dsPreviewSectionStates,
              child: DSCard(
                child: Column(
                  children: [
                    DSEmptyState(
                      title: l10n.dsPreviewStateEmptyTitle,
                      message: l10n.dsPreviewStateEmptyBody,
                      actionLabel: l10n.dsPreviewStateEmptyAction,
                      onAction: () {},
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    SizedBox(height: spacing.s24),
                    DSErrorState(
                      title: l10n.dsPreviewStateErrorTitle,
                      message: l10n.dsPreviewStateErrorBody,
                      actionLabel: l10n.retryAction,
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
  const DSPreviewHeroCard({
    super.key,
    required this.title,
    required this.amountText,
    required this.badgeText,
    required this.updatedText,
  });

  final String title;
  final String amountText;
  final String badgeText;
  final String updatedText;

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
            title,
            style: typography.caption.copyWith(color: colors.onPrimary.withValues(alpha: 0.85)),
          ),
          SizedBox(height: spacing.s8),
          Text(amountText, style: typography.totalNumeric.copyWith(color: colors.onPrimary)),
          SizedBox(height: spacing.s12),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: spacing.s8, vertical: spacing.s4),
                decoration: BoxDecoration(
                  color: colors.onPrimary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(radius.r8),
                ),
                child: Text(badgeText, style: typography.caption.copyWith(color: colors.onPrimary)),
              ),
              SizedBox(width: spacing.s12),
              Text(
                updatedText,
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
