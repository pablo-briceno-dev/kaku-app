import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kaku/core/currency_formatter.dart';
import 'package:kaku/core/models/currency_type.dart';
import 'package:kaku/core/models/stats_models.dart';

class CategoryDonutChart extends StatefulWidget {
  final List<CategorySlice> slices;
  final double totalAmount;
  final CurrencyType currency;

  const CategoryDonutChart({
    super.key,
    required this.slices,
    required this.totalAmount,
    this.currency = CurrencyType.cop,
  });

  @override
  State<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends State<CategoryDonutChart> {
  int _touched = -1; // indice del segmento tocado, -1 = ninguno

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 202,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2, // espacio entre segmentos
                  centerSpaceRadius: 60, // radio del hueco central
                  pieTouchData: PieTouchData(
                    touchCallback:
                        (FlTouchEvent event, PieTouchResponse? resp) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                resp == null ||
                                resp.touchedSection == null) {
                              _touched = -1;
                              return;
                            }
                            _touched = resp.touchedSection!.touchedSectionIndex;
                          });
                        },
                  ),
                  sections: widget.slices.asMap().entries.map((entry) {
                    final i = entry.key;
                    final slice = entry.value;
                    final isTouched = i == _touched;

                    return PieChartSectionData(
                      value: slice.percentage,
                      color: slice.color,
                      radius: isTouched ? 68 : 56, // crece al tocar
                      showTitle: isTouched,
                      title: '${slice.percentage.toStringAsFixed(0)}%',
                      titleStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Centro de la dona: muestra total o detalle del segmento tocado
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _touched >= 0 ? widget.slices[_touched].emoji : '💸',
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _touched >= 0
                        ? CurrencyFormatter.compact(
                            widget.slices[_touched].amount,
                            widget.currency,
                          )
                        : CurrencyFormatter.compact(widget.totalAmount),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    _touched >= 0 ? widget.slices[_touched].name : 'Total',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: widget.slices
              .map((slice) => _LegendItem(slice: slice))
              .toList(),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final CategorySlice slice;

  const _LegendItem({required this.slice});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: slice.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          '${slice.emoji} ${slice.name}',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${slice.percentage.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: slice.color,
          ),
        ),
      ],
    );
  }
}
