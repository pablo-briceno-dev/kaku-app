import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/models/currency_type.dart';
import 'package:kaku/core/models/stats_models.dart';

class SpendingLineChart extends StatelessWidget {
  final List<MonthPoint> points;
  final CurrencyType currency;

  const SpendingLineChart({
    super.key,
    required this.points,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final accent = Theme.of(context).colorScheme.primary;
    final maxVal = points
        .map((p) => p.totalExpenses)
        .reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 160,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxVal * 1.25,
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= points.length)
                    return const SizedBox.shrink();
                  return Text(
                    points[i].label,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((spot) {
                final point = points[spot.x.toInt()];
                return LineTooltipItem(
                  '${point.label} ${point.year}\n${CurrencyFormatter.compact(point.totalExpenses, currency)}',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: points
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.totalExpenses))
                  .toList(),
              isCurved: true,
              curveSmoothness: 0.3,
              color: accent,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) {
                  final isLast = index == points.length - 1;
                  return FlDotCirclePainter(
                    radius: isLast ? 5 : 3.5,
                    color: accent,
                    strokeWidth: isLast ? 2 : 0,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    accent.withValues(alpha: 0.25),
                    accent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
