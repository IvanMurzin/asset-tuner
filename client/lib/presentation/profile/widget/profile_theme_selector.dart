import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/core_ui/theme/theme_mode_cubit.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';

class ProfileThemeSelector extends StatelessWidget {
  const ProfileThemeSelector({super.key});

  static const List<ThemeMode> _modes = [
    ThemeMode.system,
    ThemeMode.light,
    ThemeMode.dark,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final colors = context.dsColors;
    final mode = context.watch<ThemeModeCubit>().state;
    final labels = [
      l10n.profileThemeSystem,
      l10n.profileThemeLight,
      l10n.profileThemeDark,
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s16,
        vertical: spacing.s12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.profileTheme,
            style: typography.body.copyWith(color: colors.textPrimary),
          ),
          SizedBox(height: spacing.s12),
          Row(
            children: [
              for (var i = 0; i < _modes.length; i++) ...[
                if (i > 0) SizedBox(width: spacing.s8),
                Expanded(
                  child: _ThemeChip(
                    icon: _iconFor(_modes[i]),
                    label: labels[i],
                    selected: mode == _modes[i],
                    onTap: () =>
                        context.read<ThemeModeCubit>().set(_modes[i]),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconFor(ThemeMode m) {
    return switch (m) {
      ThemeMode.system => Icons.brightness_auto_rounded,
      ThemeMode.light => Icons.light_mode_rounded,
      ThemeMode.dark => Icons.dark_mode_rounded,
    };
  }
}

class _ThemeChip extends StatelessWidget {
  const _ThemeChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final typography = context.dsTypography;
    final radius = context.dsRadius;
    final spacing = context.dsSpacing;

    return Material(
      color: selected
          ? colors.primary.withValues(alpha: 0.12)
          : colors.surfaceAlt,
      borderRadius: BorderRadius.circular(radius.r12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius.r12),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: spacing.s12,
            horizontal: spacing.s8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius.r12),
            border: Border.all(
              color: selected
                  ? colors.primary.withValues(alpha: 0.6)
                  : colors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? colors.primary : colors.textTertiary,
              ),
              SizedBox(height: spacing.s4),
              Text(
                label,
                style: typography.caption.copyWith(
                  color: selected ? colors.primary : colors.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
