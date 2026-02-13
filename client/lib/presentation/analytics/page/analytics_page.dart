import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:decimal/decimal.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_empty_state.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_list_row.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/components/ds_skeleton.dart';
import 'package:asset_tuner/core_ui/formatting/ds_formatters.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/analytics/bloc/analytics_cubit.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<AnalyticsCubit>()..load(),
      child: BlocConsumer<AnalyticsCubit, AnalyticsState>(
        listener: (context, state) {
          final navigation = state.navigation;
          if (navigation == null) {
            return;
          }
          context.read<AnalyticsCubit>().consumeNavigation();
          if (navigation.destination == AnalyticsDestination.signIn) {
            context.go(AppRoutes.signIn);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: DSAppBar(title: l10n.analyticsTitle),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () => context.read<AnalyticsCubit>().load(),
                child: Padding(
                  padding: EdgeInsets.all(context.dsSpacing.s24),
                  child: _Body(state: state),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final AnalyticsState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;

    if (state.status == AnalyticsStatus.loading) {
      return ListView(
        children: [
          const _ChartSkeleton(),
          SizedBox(height: spacing.s24),
          const _FeedSkeleton(),
        ],
      );
    }

    if (state.status == AnalyticsStatus.error) {
      return DSInlineError(
        title: l10n.splashErrorTitle,
        message: _failureMessage(l10n, state.failureCode),
        actionLabel: l10n.splashRetry,
        onAction: () => context.read<AnalyticsCubit>().load(),
      );
    }

    if (state.breakdown.isEmpty && state.updates.isEmpty) {
      return Center(
        child: DSEmptyState(
          title: l10n.analyticsEmptyTitle,
          message: l10n.analyticsEmptyBody,
          actionLabel: l10n.mainAddAccount,
          onAction: () => context.push(AppRoutes.accountNew),
          icon: Icons.pie_chart_outline,
        ),
      );
    }

    final currency = state.baseCurrency ?? 'USD';

    return ListView(
      children: [
        DSSectionTitle(title: l10n.analyticsBreakdownTitle),
        SizedBox(height: spacing.s12),
        DSCard(
          child: Column(
            children: state.breakdown
                .map(
                  (item) => Padding(
                    padding: EdgeInsets.only(bottom: spacing.s12),
                    child: _BreakdownRow(item: item, currency: currency),
                  ),
                )
                .toList(),
          ),
        ),
        SizedBox(height: spacing.s24),
        DSSectionTitle(title: l10n.analyticsUpdatesTitle),
        SizedBox(height: spacing.s12),
        DSCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: state.updates.take(40).map((item) {
              final diff = context.dsFormatters.formatDecimalFromDecimal(
                item.diffAmount,
                maximumFractionDigits: 8,
              );
              final sign = item.diffAmount.compareTo(Decimal.zero) < 0
                  ? ''
                  : '+';

              return DSListRow(
                title: '${item.accountName} · ${item.subaccountName}',
                subtitle:
                    '$sign$diff ${item.assetCode} · ${context.dsFormatters.formatDate(item.entryDate)}',
                trailing: Text(
                  context.dsFormatters.formatMoney(item.diffBaseAmount, currency),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _failureMessage(AppLocalizations l10n, String? code) {
    return switch (code) {
      'network' => l10n.errorNetwork,
      'unauthorized' => l10n.errorUnauthorized,
      'forbidden' => l10n.errorForbidden,
      'not_found' => l10n.errorNotFound,
      'validation' => l10n.errorValidation,
      'conflict' => l10n.errorConflict,
      'rate_limited' => l10n.errorRateLimited,
      _ => l10n.errorGeneric,
    };
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.item, required this.currency});

  final AnalyticsBreakdownItem item;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final percent = double.parse(item.percent.toString()).clamp(0, 100) / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(item.assetCode)),
            Text(
              context.dsFormatters.formatMoney(item.value, currency),
            ),
          ],
        ),
        SizedBox(height: spacing.s8),
        ClipRRect(
          borderRadius: BorderRadius.circular(context.dsRadius.r12),
          child: LinearProgressIndicator(value: percent, minHeight: spacing.s8),
        ),
      ],
    );
  }
}

class _ChartSkeleton extends StatelessWidget {
  const _ChartSkeleton();

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    return DSCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DSSkeleton(height: 20, width: 120),
          SizedBox(height: spacing.s12),
          DSSkeleton(height: 14),
          SizedBox(height: spacing.s8),
          DSSkeleton(height: 14),
          SizedBox(height: spacing.s8),
          DSSkeleton(height: 14),
        ],
      ),
    );
  }
}

class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton();

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    return DSCard(
      child: Column(
        children: [
          for (var i = 0; i < 5; i++) ...[
            DSSkeleton(height: 18),
            SizedBox(height: spacing.s8),
            DSSkeleton(height: 14),
            if (i != 4) SizedBox(height: spacing.s12),
          ],
        ],
      ),
    );
  }
}
