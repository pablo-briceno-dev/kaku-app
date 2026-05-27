import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kaku/core/budget_calculator.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/models/currency_type.dart';

class DailyBarChart extends StatefulWidget {
  final Map<int, double> dailyData;
  final int daysInMonth;
  final CurrencyType currency;

  const DailyBarChart({
    super.key,
    required this.dailyData,
    required this.daysInMonth,
    required this.currency,
  });

  @override
  State<DailyBarChart> createState() => _DailyBarChartState();
}

class _DailyBarChartState extends State<DailyBarChart> {
  int _touched = -1;

  double get _total => widget.dailyData.values.fold(0, (a, b) => a + b);
  double get _avg => BudgetCalculator.dailyAverage(_total, widget.daysInMonth);
  double get _maxVal =>
      widget.dailyData.values.fold(0.0, (a, b) => a > b ? a : b);

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Promedio: ${CurrencyFormatter.compact(_avg, widget.currency)}/dá',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: BarChart(
            BarChartData(
              maxY: _maxVal * 1.2, // 20% de margen superior
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final day = group.x + 1;
                    final amount = widget.dailyData[day] ?? 0;
                    if (amount == 0) return null;
                    return BarTooltipItem(
                      'Día $day\n${CurrencyFormatter.compact(amount, widget.currency)}',
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  },
                ),
                touchCallback: (FlTouchEvent event, BarTouchResponse? resp) {
                  setState(() {
                    _touched =
                        (!event.isInterestedForInteractions ||
                            resp == null ||
                            resp.spot == null)
                        ? -1
                        : resp.spot!.touchedBarGroupIndex;
                  });
                },
              ),
              titlesData: FlTitlesData(
                // Solo mostramos etiquetas en los ejes X cada 5 días
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 18,
                    getTitlesWidget: (value, meta) {
                      final day = value.toInt() + 1;
                      if (day != 1 &&
                          day % 5 != 0 &&
                          day != widget.daysInMonth) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: _avg,
                    color: Colors.white.withValues(alpha: 0.2),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.centerRight,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                      labelResolver: (_) => 'Promedio',
                    ),
                  ),
                ],
              ),
              barGroups: List.generate(widget.daysInMonth, (i) {
                final day = i + 1;
                final amount = widget.dailyData[day] ?? 0.0;
                final isHigh = amount > _avg * 1.5;
                final isTouched = i == _touched;

                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: amount == 0 ? 0.5 : amount,
                      width: isTouched ? 8 : 6,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(3),
                      ),
                      color: amount == 0
                          ? Colors.white.withValues(alpha: 0.06)
                          : isHigh
                          ? const Color(0xFFFF7C7C)
                          : accent.withValues(alpha: isTouched ? 1 : 0.7),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
