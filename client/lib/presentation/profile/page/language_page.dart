import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asset_tuner/core/localization/locale_cubit.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_radio_row.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;

    return Scaffold(
      appBar: DSAppBar(title: l10n.profileLanguage),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(spacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DSSectionTitle(title: l10n.profileLanguage),
              SizedBox(height: spacing.s12),
              DSCard(
                padding: EdgeInsets.zero,
                child: BlocBuilder<LocaleCubit, LocaleState>(
                  builder: (context, state) {
                    final selected = state.localeTag;
                    return Column(
                      children: [
                        DSRadioRow(
                          title: l10n.profileLanguageSystem,
                          selected: selected == null,
                          onTap: () => context.read<LocaleCubit>().setSystem(),
                        ),
                        Divider(height: 1, color: context.dsColors.border),
                        DSRadioRow(
                          title: l10n.profileLanguageEnglish,
                          selected:
                              selected == const Locale('en').toLanguageTag(),
                          onTap: () => context.read<LocaleCubit>().setLocale(
                            const Locale('en'),
                          ),
                        ),
                        Divider(height: 1, color: context.dsColors.border),
                        DSRadioRow(
                          title: l10n.profileLanguageRussian,
                          selected:
                              selected == const Locale('ru').toLanguageTag(),
                          onTap: () => context.read<LocaleCubit>().setLocale(
                            const Locale('ru'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
