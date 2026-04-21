import 'dart:math' as math;

import 'package:asset_tuner/core_ui/components/ds_card.dart';
import 'package:asset_tuner/core_ui/formatting/ds_formatters.dart';
import 'package:asset_tuner/core_ui/theme/ds_theme.dart';
import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnalyticsTotalTrendPoint {
  const AnalyticsTotalTrendPoint({required this.date, required this.total});

  final DateTime date;
  final Decimal total;
}

class AnalyticsTotalTrendChart extends StatelessWidget {
  const AnalyticsTotalTrendChart({required this.points, required this.currency, super.key});

  final List<AnalyticsTotalTrendPoint> points;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final colors = context.dsColors;
    final values = points.map((item) => item.total.toDouble()).toList(growable: false);
    final spots = [for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i])];
    final chartBounds = _chartBounds(values);

    return DSCard(
      padding: EdgeInsets.fromLTRB(spacing.s12, spacing.s12, spacing.s12, spacing.s8),
      child: SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: (points.length - 1).toDouble(),
            minY: chartBounds.minY,
            maxY: chartBounds.maxY,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.22,
                color: colors.primary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 2.8,
                      color: colors.primary,
                      strokeColor: colors.surface,
                      strokeWidth: 1.2,
                    );
                  },
                ),
                belowBarData: BarAreaData(show: false),
              ),
            ],
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: chartBounds.gridInterval,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: colors.border.withValues(alpha: 0.8), strokeWidth: 1),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                top: BorderSide.none,
                right: BorderSide.none,
                left: BorderSide(color: colors.border.withValues(alpha: 0.8), width: 1),
                bottom: BorderSide(color: colors.border.withValues(alpha: 0.8), width: 1),
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: spacing.s32,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.round();
                    if (index < 0 || index >= points.length || !_shouldShowXLabel(index)) {
                      return const SizedBox.shrink();
                    }
                    final text = context.dsFormatters.formatDate(points[index].date);
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typography.label.copyWith(color: colors.textSecondary),
                      ),
                    );
                  },
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              enabled: true,
              handleBuiltInTouches: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => colors.surface,
                fitInsideVertically: true,
                fitInsideHorizontally: true,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final idx = spot.x.round();
                    if (idx < 0 || idx >= points.length) {
                      return null;
                    }
                    final point = points[idx];
                    final date = context.dsFormatters.formatDate(point.date);
                    final value = context.dsFormatters.formatMoney(point.total, currency);
                    return LineTooltipItem(
                      '$date\n$value',
                      typography.caption.copyWith(color: colors.textPrimary),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _shouldShowXLabel(int index) {
    if (points.length <= 3) {
      return true;
    }
    final mid = (points.length - 1) ~/ 2;
    return index == 0 || index == mid || index == points.length - 1;
  }
}

class _ChartBounds {
  const _ChartBounds({required this.minY, required this.maxY, required this.gridInterval});

  final double minY;
  final double maxY;
  final double gridInterval;
}

_ChartBounds _chartBounds(List<double> values) {
  var minY = values.reduce(math.min);
  var maxY = values.reduce(math.max);

  if (minY == maxY) {
    final pad = minY == 0 ? 1.0 : minY.abs() * 0.1;
    minY -= pad;
    maxY += pad;
  } else {
    final range = maxY - minY;
    final padding = math.max(range * 0.12, 0.5);
    minY -= padding;
    maxY += padding;
  }

  final interval = math.max((maxY - minY) / 4, 1.0);
  return _ChartBounds(minY: minY, maxY: maxY, gridInterval: interval);
}
