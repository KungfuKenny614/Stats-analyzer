import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stats_analyzer/design_system/tokens/colors.dart';
import 'package:stats_analyzer/design_system/tokens/spacing.dart';
import 'package:stats_analyzer/design_system/tokens/typography.dart';

class PerformanceChart extends StatelessWidget {
  final List<double> data;
  final String title;
  final Color lineColor;
  final double? threshold;

  const PerformanceChart({
    super.key,
    required this.data,
    required this.title,
    this.lineColor = DSColors.info,
    this.threshold,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text('No data available'),
        ),
      );
    }

    final maxY = data.reduce((a, b) => a > b ? a : b) + 1;
    final minY = data.reduce((a, b) => a < b ? a : b) - 1;
    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: DSColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DSColors.border.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: DSTypography.headingSM,
          ),
          const SizedBox(height: DSSpacing.md),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: data.length - 1,
                minY: minY.clamp(0, double.infinity),
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: DSColors.border.withOpacity(0.3),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value >= 0 && value < data.length) {
                          return Text(
                            (value + 1).toString(),
                            style: const TextStyle(fontSize: 8),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 20,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 8),
                        );
                      },
                      reservedSize: 24,
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: lineColor,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: lineColor,
                          strokeWidth: 1,
                          strokeColor: DSColors.surface,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: lineColor.withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: DSColors.textPrimary,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toStringAsFixed(1)}',
                          const TextStyle(
                            color: DSColors.textInverse,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          if (threshold != null)
            Padding(
              padding: const EdgeInsets.only(top: DSSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Threshold: ${threshold!.toStringAsFixed(1)}',
                    style: DSTypography.caption,
                  ),
                  Text(
                    'Hit Rate: ${data.where((d) => d > threshold!).length / data.length * 100}%',
                    style: DSTypography.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: DSColors.info,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
