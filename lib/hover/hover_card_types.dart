import 'package:flutter/material.dart';
import 'package:stats_analyzer/models/mlb_outlier_models.dart';
import 'package:stats_analyzer/design_system/tokens/colors.dart';

class PlayerHoverCardBuilder {
  static Widget build(MLBNormalizedMarket market, MLBAnalyticsResult? analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(market, analytics),
        const SizedBox(height: 12),
        _buildMetricStrip(market, analytics),
        const SizedBox(height: 12),
        _buildRecentPerformance(analytics),
        const SizedBox(height: 12),
        _buildSplitSummary(market, analytics),
      ],
    );
  }

  static Widget _buildHeader(MLBNormalizedMarket market, MLBAnalyticsResult? analytics) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: DSColors.deAccent.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              market.playerName.split(' ').map((e) => e[0]).join(''),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: DSColors.deAccent,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                market.playerName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '${market.team} vs ${market.opponent} · ${market.marketType}',
                style: TextStyle(
                  fontSize: 12,
                  color: DSColors.deTextSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: DSColors.deAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${market.line.toStringAsFixed(1)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: DSColors.deAccent,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildMetricStrip(MLBNormalizedMarket market, MLBAnalyticsResult? analytics) {
    final ev = analytics?.ev ?? 0;
    final hitRate = analytics?.hitRate ?? 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMetric('Projection', (market.line + ev / 10).toStringAsFixed(1), Colors.blue),
        _buildMetric('EV', ev.toStringAsFixed(1) + '%', ev > 3 ? DSColors.deWin : DSColors.deLoss),
        _buildMetric('Hit Rate', '${(hitRate * 100).toInt()}%', hitRate > 0.7 ? DSColors.deWin : DSColors.deLoss),
        _buildMetric('Confidence', '${(hitRate * 100).toInt()}%', Colors.blue),
      ],
    );
  }

  static Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: DSColors.deTextSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  static Widget _buildRecentPerformance(MLBAnalyticsResult? analytics) {
    final hitRate = analytics?.hitRate ?? 0.5;
    final windows = [
      ('L5', hitRate),
      ('L10', hitRate * 1.05),
      ('L20', hitRate * 0.95),
      ('Season', hitRate * 0.98),
      ('H2H', hitRate * 1.1),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Performance',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: DSColors.deTextSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: windows.map((w) {
            final rate = (w.$2 * 100).toInt();
            final color = rate >= 80 ? DSColors.deWin : rate >= 60 ? DSColors.mid : DSColors.deLoss;
            return Column(
              children: [
                Text(
                  w.$1,
                  style: TextStyle(
                    fontSize: 9,
                    color: DSColors.deTextSecondary,
                  ),
                ),
                Text(
                  '$rate%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  static Widget _buildSplitSummary(MLBNormalizedMarket market, MLBAnalyticsResult? analytics) {
    final home = analytics?.splits['Home'] ?? 0.5;
    final away = analytics?.splits['Away'] ?? 0.5;
    final splits = [
      ('Home', home),
      ('Away', away),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Splits',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: DSColors.deTextSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: splits.map((s) {
            final rate = (s.$2 * 100).toInt();
            final color = rate >= 70 ? DSColors.deWin : rate >= 50 ? DSColors.mid : DSColors.deLoss;
            return Row(
              children: [
                Text(
                  '${s.$1}: ',
                  style: TextStyle(
                    fontSize: 11,
                    color: DSColors.deTextSecondary,
                  ),
                ),
                Text(
                  '$rate%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
