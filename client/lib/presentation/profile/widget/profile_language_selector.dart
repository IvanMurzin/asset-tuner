import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:asset_tuner/core/localization/locale_cubit.dart';
import 'package:asset_tuner/core_ui/components/ds_list_row.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/settings/widget/settings_row_trailing.dart';

class ProfileLanguageSelector extends StatelessWidget {
  const ProfileLanguageSelector({super.key});

  static const String _assetLangEn = 'assets/icon/lang-en.svg';
  static const String _assetLangRu = 'assets/icon/lang-ru.svg';

  String _currentLabel(AppLocalizations l10n, String? localeTag) {
    return switch (localeTag) {
      null => l10n.profileLanguageSystem,
      'ru' => l10n.profileLanguageRussian,
      _ => l10n.profileLanguageEnglish,
    };
  }

  String _currentIconPath(String? localeTag) {
    return switch (localeTag) {
      'ru' => _assetLangRu,
      _ => _assetLangEn,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeTag = context.watch<LocaleCubit>().state.localeTag;
    final spacing = context.dsSpacing;

    return PopupMenuButton<int>(
      position: PopupMenuPosition.under,
      offset: Offset(0, spacing.s4),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.dsRadius.r12)),
      child: DSListRow(
        title: l10n.profileLanguage,
        leading: _LangIcon(assetPath: _currentIconPath(localeTag), size: 24),
        trailing: SettingsRowTrailing(value: _currentLabel(l10n, localeTag)),
        showDivider: true,
      ),
      itemBuilder: (context) => [
        PopupMenuItem<int>(
          value: 0,
          child: _LanguageMenuItem(iconPath: _assetLangEn, label: l10n.profileLanguageSystem),
        ),
        PopupMenuItem<int>(
          value: 1,
          child: _LanguageMenuItem(iconPath: _assetLangEn, label: l10n.profileLanguageEnglish),
        ),
        PopupMenuItem<int>(
          value: 2,
          child: _LanguageMenuItem(iconPath: _assetLangRu, label: l10n.profileLanguageRussian),
        ),
      ],
      onSelected: (value) {
        final cubit = context.read<LocaleCubit>();
        switch (value) {
          case 0:
            cubit.setLocale(null);
            break;
          case 1:
            cubit.setLocale(const Locale('en'));
            break;
          case 2:
            cubit.setLocale(const Locale('ru'));
            break;
        }
      },
    );
  }
}

class _LangIcon extends StatelessWidget {
  const _LangIcon({required this.assetPath, this.size = 24});

  final String assetPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        clipBehavior: Clip.antiAlias,
        placeholderBuilder: (context) =>
            Icon(Icons.language_rounded, size: size, color: context.dsColors.textTertiary),
      ),
    );
  }
}

class _LanguageMenuItem extends StatelessWidget {
  const _LanguageMenuItem({required this.iconPath, required this.label});

  final String iconPath;
  final String label;

  @override
  Widget build(BuildContext context) {
    final typography = context.dsTypography;
    final colors = context.dsColors;
    const size = 20.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LangIcon(assetPath: iconPath, size: size),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            label,
            style: typography.body.copyWith(color: colors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
