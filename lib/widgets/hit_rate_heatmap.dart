import 'package:flutter/material.dart';
import 'package:stats_analyzer/design_system/tokens/colors.dart';
import 'package:stats_analyzer/design_system/tokens/spacing.dart';
import 'package:stats_analyzer/design_system/tokens/typography.dart';

class HitRateHeatmap extends StatelessWidget {
  final Map<String, double> data;
  final String title;

  const HitRateHeatmap({
    super.key,
    required this.data,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
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
          Wrap(
            spacing: DSSpacing.md,
            runSpacing: DSSpacing.md,
            children: data.entries.map((entry) {
              final value = entry.value.clamp(0.0, 1.0);
              final color = _getColor(value);
              return Container(
                width: 80,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      entry.key,
                      style: DSTypography.caption.copyWith(
                        color: DSColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${(value * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _getColor(double value) {
    if (value >= 0.7) return DSColors.positive;
    if (value >= 0.5) return DSColors.warning;
    return DSColors.negative;
  }
}
