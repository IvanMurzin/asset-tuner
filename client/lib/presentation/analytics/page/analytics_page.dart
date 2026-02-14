import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_app_bar.dart';
import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/components/ds_empty_card.dart';
import 'package:asset_tuner/core_ui/components/ds_history_entry_card.dart';
import 'package:asset_tuner/core_ui/components/ds_inline_error.dart';
import 'package:asset_tuner/core_ui/components/ds_section_title.dart';
import 'package:asset_tuner/core_ui/formatting/ds_formatters.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/analytics/bloc/analytics_cubit.dart';
import 'package:asset_tuner/presentation/utils/supabase_error_message.dart';
import 'package:supabase_error_translator_flutter/supabase_error_translator_flutter.dart';
import 'package:asset_tuner/presentation/analytics/widget/analytics_loading_skeleton.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<AnalyticsCubit, AnalyticsState>(
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
              onRefresh: () async {
                final cubit = context.read<AnalyticsCubit>();
                if (cubit.state.status == AnalyticsStatus.ready) {
                  await cubit.refresh();
                } else {
                  await cubit.load();
                }
              },
              child: Padding(
                padding: EdgeInsets.all(context.dsSpacing.s24),
                child: _Body(state: state),
              ),
            ),
          ),
        );
      },
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
      return const AnalyticsLoadingSkeleton();
    }

    if (state.status == AnalyticsStatus.error) {
      return DSInlineError(
        title: l10n.splashErrorTitle,
        message: resolveFailureMessage(
        context,
        code: state.failureCode,
        rawMessage: state.failureMessage,
        service: ErrorService.database,
      ),
        actionLabel: l10n.splashRetry,
        onAction: () => context.read<AnalyticsCubit>().load(),
      );
    }

    if (state.breakdown.isEmpty && state.updates.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: 1,
                    color: context.dsColors.neutral400,
                    radius: 48,
                    showTitle: false,
                  ),
                ],
                centerSpaceRadius: 32,
                sectionsSpace: 2,
              ),
            ),
          ),
          SizedBox(height: spacing.s24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.s24),
            child: DSEmptyCard(
              icon: Icons.pie_chart_outline,
              title: l10n.analyticsEmptyTitle,
              message: l10n.analyticsEmptyBody,
              actionLabel: l10n.mainAddAccount,
              actionLeadingIcon: Icons.add,
              onAction: () => context.push(AppRoutes.accountNew),
            ),
          ),
          SizedBox(height: spacing.s24),
        ],
      );
    }

    final currency = state.baseCurrency ?? 'USD';

    return ListView(
      children: [
        if (state.breakdown.isNotEmpty) ...[
          _AnalyticsPieChart(
            breakdown: state.breakdown,
            colors: context.dsColors,
          ),
          SizedBox(height: spacing.s24),
        ],
        DSSectionTitle(title: l10n.analyticsBreakdownTitle),
        SizedBox(height: spacing.s12),
        ...state.breakdown.toList().asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(bottom: spacing.s12),
            child: DSCard(
              child: _BreakdownCard(
                item: entry.value,
                index: entry.key,
                currency: currency,
                colors: context.dsColors,
              ),
            ),
          );
        }),
        SizedBox(height: spacing.s24),
        DSSectionTitle(title: l10n.analyticsUpdatesTitle),
        SizedBox(height: spacing.s12),
        ...state.updates.take(40).map((item) {
          final diffStr = context.dsFormatters.formatDecimalFromDecimal(
            item.diffAmount,
            maximumFractionDigits: 8,
          );
          final sign = item.diffAmount.compareTo(Decimal.zero) < 0 ? '' : '+';
          final deltaColor = item.diffAmount.compareTo(Decimal.zero) >= 0
              ? context.dsColors.success
              : context.dsColors.danger;
          return Padding(
            padding: EdgeInsets.only(bottom: spacing.s8),
            child: DSHistoryEntryCard(
              dateText: context.dsFormatters.formatDateTime(item.entryDate),
              subtitleText: '${item.accountName} · ${item.subaccountName}',
              deltaText: '$sign$diffStr ${item.assetCode}',
              deltaColor: deltaColor,
              baseLineText: context.dsFormatters.formatMoney(
                item.diffBaseAmount,
                currency,
              ),
              trailingPrimaryText: context.dsFormatters.formatMoney(
                item.diffBaseAmount,
                currency,
              ),
            ),
          );
        }),
      ],
    );
  }

}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({
    required this.item,
    required this.index,
    required this.currency,
    required this.colors,
  });

  final AnalyticsBreakdownItem item;
  final int index;
  final String currency;
  final DSColors colors;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final percent = double.parse(item.percent.toString()).clamp(0, 100) / 100;
    final barColor = _breakdownBarColorAt(index, colors);
    final originalText = context.dsFormatters.formatDecimalFromDecimal(
      item.originalAmount,
      maximumFractionDigits: 8,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.assetCode,
          style: typography.h3,
        ),
        SizedBox(height: spacing.s8),
        Text(
          '$originalText ${item.assetCode}',
          style: typography.body.copyWith(color: colors.textSecondary),
        ),
        SizedBox(height: spacing.s4),
        Text(
          context.dsFormatters.formatMoney(item.value, currency),
          style: typography.body.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: spacing.s12),
        ClipRRect(
          borderRadius: BorderRadius.circular(context.dsRadius.r12),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: spacing.s8,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}

Color _breakdownBarColorAt(int index, DSColors colors) {
  const sectionColors = [
    _ChartColor.primary,
    _ChartColor.success,
    _ChartColor.info,
    _ChartColor.warning,
    _ChartColor.neutral,
  ];
  final c = sectionColors[index % sectionColors.length];
  return switch (c) {
    _ChartColor.primary => colors.primary,
    _ChartColor.success => colors.success,
    _ChartColor.info => colors.info,
    _ChartColor.warning => colors.warning,
    _ChartColor.neutral => colors.neutral400,
  };
}

class _AnalyticsPieChart extends StatelessWidget {
  const _AnalyticsPieChart({
    required this.breakdown,
    required this.colors,
  });

  final List<AnalyticsBreakdownItem> breakdown;
  final DSColors colors;

  static const _sectionColors = [
    _ChartColor.primary,
    _ChartColor.success,
    _ChartColor.info,
    _ChartColor.warning,
    _ChartColor.neutral,
  ];

  @override
  Widget build(BuildContext context) {
    if (breakdown.isEmpty) {
      return const SizedBox.shrink();
    }
    final total = breakdown.fold<double>(
      0,
      (sum, item) => sum + double.parse(item.value.toString()),
    );
    if (total <= 0) {
      return const SizedBox.shrink();
    }
    final sections = breakdown.asMap().entries.map((entry) {
      final i = entry.key;
      final item = entry.value;
      final value = double.parse(item.value.toString());
      final color = _colorAt(i);
      return PieChartSectionData(
        value: value,
        color: color,
        title: item.assetCode,
        showTitle: true,
        radius: 48,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
      );
    }).toList();

    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sections: sections,
          sectionsSpace: 2,
          centerSpaceRadius: 32,
        ),
      ),
    );
  }

  Color _colorAt(int index) {
    final c = _sectionColors[index % _sectionColors.length];
    return switch (c) {
      _ChartColor.primary => colors.primary,
      _ChartColor.success => colors.success,
      _ChartColor.info => colors.info,
      _ChartColor.warning => colors.warning,
      _ChartColor.neutral => colors.neutral400,
    };
  }
}

enum _ChartColor { primary, success, info, warning, neutral }
