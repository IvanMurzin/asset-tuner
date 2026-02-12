import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_chip.dart';
import 'package:asset_tuner/core_ui/formatting/ds_formatters.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/overview/bloc/overview_cubit.dart';
import 'package:asset_tuner/presentation/overview/widget/overview_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
              title: l10n.mainTitle,
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
              ],
            ),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () => context.read<OverviewCubit>().load(),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(spacing.s24, 0, spacing.s24, 0),
                  child: OverviewBody(
                    state: state,
                    baseCurrency: baseCurrency,
                    ratesText: _ratesText(context, l10n, state.ratesAsOf),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
