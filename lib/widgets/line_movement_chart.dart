import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stats_analyzer/design_system/tokens/colors.dart';
import 'package:stats_analyzer/design_system/tokens/spacing.dart';
import 'package:stats_analyzer/design_system/tokens/typography.dart';

class LineMovementChart extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  final String title;

  const LineMovementChart({
    super.key,
    required this.history,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Container(
        height: 120,
        padding: const EdgeInsets.all(DSSpacing.md),
        child: Center(
          child: Text(
            'No line movement data yet',
            style: DSTypography.caption,
          ),
        ),
      );
    }

    final sorted = List<Map<String, dynamic>>.from(history)
      ..sort((a, b) => DateTime.parse(a['timestamp']).compareTo(DateTime.parse(b['timestamp'])));

    final spots = sorted.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return FlSpot(index.toDouble(), data['line'] as double);
    }).toList();

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 0.5;
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 0.5;

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
          Text(title, style: DSTypography.headingSM),
          const SizedBox(height: DSSpacing.md),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: spots.length - 1,
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
                        if (value >= 0 && value < sorted.length) {
                          final data = sorted[value.toInt()];
                          final dt = DateTime.parse(data['timestamp']);
                          return Text(
                            '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}',
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
                          value.toStringAsFixed(1),
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
                    color: DSColors.info,
                    barWidth: 2,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: DSColors.info,
                          strokeWidth: 1,
                          strokeColor: DSColors.surface,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: DSColors.info.withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: DSColors.textPrimary,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.spotIndex.toInt();
                        final data = sorted[index];
                        return LineTooltipItem(
                          '${data['line'].toStringAsFixed(1)}',
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
          const SizedBox(height: DSSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Open: ${sorted.first['line'].toStringAsFixed(1)}',
                style: DSTypography.caption,
              ),
              Text(
                'Current: ${sorted.last['line'].toStringAsFixed(1)}',
                style: DSTypography.caption,
              ),
              if (sorted.length > 1)
                Text(
                  'Change: ${(sorted.last['line'] - sorted.first['line']).toStringAsFixed(1)}',
                  style: DSTypography.caption.copyWith(
                    color: (sorted.last['line'] - sorted.first['line']) > 0
                        ? DSColors.positive
                        : DSColors.negative,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
