import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/core_ui/theme/theme_mode_cubit.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';

class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;

    return Scaffold(
      appBar: DSAppBar(title: l10n.profileTheme),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(spacing.s24),
          child: BlocBuilder<ThemeModeCubit, ThemeMode>(
            builder: (context, mode) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DSSectionTitle(title: l10n.profileTheme),
                  SizedBox(height: spacing.s12),
                  _ThemeModeCard(
                    title: l10n.profileThemeSystem,
                    icon: Icons.brightness_auto_outlined,
                    preview: _ThemePreview.system,
                    selected: mode == ThemeMode.system,
                    onTap: () =>
                        context.read<ThemeModeCubit>().set(ThemeMode.system),
                  ),
                  SizedBox(height: spacing.s12),
                  _ThemeModeCard(
                    title: l10n.profileThemeLight,
                    icon: Icons.light_mode_outlined,
                    preview: _ThemePreview.light,
                    selected: mode == ThemeMode.light,
                    onTap: () =>
                        context.read<ThemeModeCubit>().set(ThemeMode.light),
                  ),
                  SizedBox(height: spacing.s12),
                  _ThemeModeCard(
                    title: l10n.profileThemeDark,
                    icon: Icons.dark_mode_outlined,
                    preview: _ThemePreview.dark,
                    selected: mode == ThemeMode.dark,
                    onTap: () =>
                        context.read<ThemeModeCubit>().set(ThemeMode.dark),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

enum _ThemePreview { system, light, dark }

class _ThemeModeCard extends StatelessWidget {
  const _ThemeModeCard({
    required this.title,
    required this.icon,
    required this.preview,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final _ThemePreview preview;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final radius = context.dsRadius;

    final borderColor = selected
        ? colors.primary.withValues(alpha: 0.8)
        : colors.border;

    return DSCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius.r12),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(spacing.s16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius.r12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: spacing.s32 + spacing.s8,
                  height: spacing.s32 + spacing.s8,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(radius.r12),
                  ),
                  child: Icon(icon, color: colors.primary),
                ),
                SizedBox(width: spacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: typography.h3),
                      SizedBox(height: spacing.s12),
                      _ThemeSwatches(preview: preview),
                    ],
                  ),
                ),
                SizedBox(width: spacing.s12),
                Icon(
                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: selected ? colors.primary : colors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeSwatches extends StatelessWidget {
  const _ThemeSwatches({required this.preview});

  final _ThemePreview preview;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final radius = context.dsRadius;
    final spacing = context.dsSpacing;

    List<Color> swatches;
    switch (preview) {
      case _ThemePreview.system:
        swatches = [
          colors.textPrimary.withValues(alpha: 0.85),
          colors.surface,
          colors.primary,
        ];
        break;
      case _ThemePreview.light:
        swatches = [Colors.white, const Color(0xFFF3F4F6), colors.primary];
        break;
      case _ThemePreview.dark:
        swatches = [
          const Color(0xFF0B1220),
          const Color(0xFF111827),
          colors.primary,
        ];
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final color in swatches) ...[
          Container(
            width: spacing.s12,
            height: spacing.s12,
            margin: EdgeInsets.only(right: spacing.s4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(radius.r12),
              border: Border.all(color: colors.border.withValues(alpha: 0.8)),
            ),
          ),
        ],
      ],
    );
  }
}
