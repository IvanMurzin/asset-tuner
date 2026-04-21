import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class BaseCurrencyHowSection extends StatelessWidget {
  const BaseCurrencyHowSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;
    final colors = context.dsColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DSSectionTitle(title: l10n.baseCurrencyHowTitle),
        SizedBox(height: spacing.s12),
        DSCard(
          child: Column(
            children: [
              _HowRow(
                icon: Icons.update_rounded,
                title: l10n.baseCurrencyHowRatesTitle,
                body: l10n.baseCurrencyHowRatesBody,
              ),
              Divider(height: spacing.s24, color: colors.border),
              _HowRow(
                icon: Icons.swap_horiz_rounded,
                title: l10n.baseCurrencyHowConvertTitle,
                body: l10n.baseCurrencyHowConvertBody,
              ),
              Divider(height: spacing.s24, color: colors.border),
              _HowRow(
                icon: Icons.functions_rounded,
                title: l10n.baseCurrencyHowSumTitle,
                body: l10n.baseCurrencyHowSumBody,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HowRow extends StatelessWidget {
  const _HowRow({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final typography = context.dsTypography;
    final colors = context.dsColors;
    final spacing = context.dsSpacing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colors.primary, size: 20),
        SizedBox(width: spacing.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: typography.body.copyWith(color: colors.textPrimary)),
              SizedBox(height: spacing.s4),
              Text(body, style: typography.caption),
            ],
          ),
        ),
      ],
    );
  }
}
