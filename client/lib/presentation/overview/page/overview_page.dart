import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_chip.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/core_ui/formatting/ds_formatters.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/presentation/overview/bloc/overview_cubit.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  String _ratesText(
    BuildContext context,
    AppLocalizations l10n,
    DateTime? asOf,
  ) {
    if (asOf == null) {
      return l10n.overviewRatesUnavailable;
    }
    return l10n.overviewRatesUpdatedAt(
      context.dsFormatters.formatDateTime(asOf),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final colors = context.dsColors;
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<OverviewCubit>()..load(),
      child: BlocConsumer<OverviewCubit, OverviewState>(
        listener: (context, state) {
          final navigation = state.navigation;
          if (navigation == null) {
            return;
          }
          context.read<OverviewCubit>().consumeNavigation();
          switch (navigation.destination) {
            case OverviewDestination.signIn:
              context.go(AppRoutes.signIn);
          }
        },
        builder: (context, state) {
          final baseCurrency = state.baseCurrency ?? 'USD';

          return Scaffold(
            appBar: DSAppBar(
              title: l10n.overviewTitle,
              actions: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: spacing.s12),
                    child: DSChip(
                      label: baseCurrency,
                      icon: Icons.currency_exchange,
                      onTap: () async {
                        await context.push<String>(
                          AppRoutes.baseCurrencySettings,
                        );
                        if (context.mounted) {
                          await context.read<OverviewCubit>().load();
                        }
                      },
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => context.push(AppRoutes.settings),
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
            body: Padding(
              padding: EdgeInsets.all(spacing.s24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(spacing.s24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colors.primary.withValues(alpha: 0.18),
                          colors.info.withValues(alpha: 0.16),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(context.dsRadius.r16),
                      border: Border.all(
                        color: colors.border.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.overviewTotalLabel, style: typography.h3),
                        SizedBox(height: spacing.s8),
                        Text(
                          l10n.notAvailable,
                          style: typography.totalNumeric.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        SizedBox(height: spacing.s12),
                        Text(
                          _ratesText(context, l10n, state.ratesAsOf),
                          style: typography.caption.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: spacing.s24),
                  DSCard(
                    child: Text(
                      l10n.overviewEmptyBody,
                      style: typography.body.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
