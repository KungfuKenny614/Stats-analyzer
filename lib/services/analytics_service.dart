import 'package:stats_analyzer/models/mlb_models.dart';
import 'package:stats_analyzer/models/advanced_stats.dart';

class AnalyticsService {
  // Generate advanced stats from MLB player data
  AdvancedStats generateAdvancedStats(MLBPlayer player) {
    // Simulate advanced stats based on player's basic stats
    final random = DateTime.now().millisecondsSinceEpoch % 100 / 100;
    
    return AdvancedStats(
      xBA: player.avg * (0.95 + random * 0.1),
      xSLG: player.ops * (0.9 + random * 0.2),
      xOBP: (player.avg + 0.050 + random * 0.05),
      xwOBA: (player.ops * 0.9 + random * 0.1),
      hardHitRate: 0.3 + random * 0.3 + (player.avg - 0.250) * 0.5,
      barrelRate: 0.05 + random * 0.15 + (player.hr / 50) * 0.1,
      avgExitVelocity: 85 + random * 10 + (player.hr / 10) * 0.5,
      avgLaunchAngle: 5 + random * 15,
      sweetSpotRate: 0.25 + random * 0.25,
      chaseRate: 0.2 + random * 0.15,
      whiffRate: 0.15 + random * 0.15,
      zoneContactRate: 0.75 + random * 0.15,
      firstPitchStrikeRate: 0.55 + random * 0.15,
      kRate: 0.15 + random * 0.15,
      bbRate: 0.05 + random * 0.08,
      gbRate: 0.35 + random * 0.2,
      fbRate: 0.30 + random * 0.2,
      ldRate: 0.15 + random * 0.1,
      hrPerFlyBall: 0.05 + random * 0.1 + (player.hr / 100) * 0.05,
      vsLeft: {
        'avg': player.avg * (0.9 + random * 0.2),
        'ops': player.ops * (0.85 + random * 0.3),
        'hr': player.hr * (0.8 + random * 0.4),
      },
      vsRight: {
        'avg': player.avg * (0.9 + random * 0.2),
        'ops': player.ops * (0.85 + random * 0.3),
        'hr': player.hr * (0.8 + random * 0.4),
      },
      homeAway: {
        'home': player.avg * (0.95 + random * 0.1),
        'away': player.avg * (0.95 + random * 0.1),
      },
      dayNight: {
        'day': player.avg * (0.9 + random * 0.2),
        'night': player.avg * (0.9 + random * 0.2),
      },
    );
  }

  // Compare two players
  ComparisonResult comparePlayers(MLBPlayer player1, MLBPlayer player2) {
    final stats1 = generateAdvancedStats(player1);
    final stats2 = generateAdvancedStats(player2);
    
    final advantages = <String, double>{};
    final categories = <String, String>{};
    
    // Compare metrics
    final metrics = {
      'AVG': (player1.avg, player2.avg),
      'OPS': (player1.ops, player2.ops),
      'HR': (player1.hr.toDouble(), player2.hr.toDouble()),
      'RBI': (player1.rbi.toDouble(), player2.rbi.toDouble()),
      'Hits': (player1.hits.toDouble(), player2.hits.toDouble()),
      'Barrel Rate': (stats1.barrelRate ?? 0, stats2.barrelRate ?? 0),
      'Hard Hit': (stats1.hardHitRate ?? 0, stats2.hardHitRate ?? 0),
      'Exit Velo': (stats1.avgExitVelocity ?? 0, stats2.avgExitVelocity ?? 0),
    };
    
    double totalAdvantage = 0;
    int count = 0;
    
    for (final entry in metrics.entries) {
      final diff = entry.value.$1 - entry.value.$2;
      advantages[entry.key] = diff;
      totalAdvantage += diff;
      count++;
      
      if (diff > 0.05) {
        categories[entry.key] = player1.name;
      } else if (diff < -0.05) {
        categories[entry.key] = player2.name;
      } else {
        categories[entry.key] = 'Even';
      }
    }
    
    final overallAdvantage = totalAdvantage / count;
    
    return ComparisonResult(
      player1Name: player1.name,
      player2Name: player2.name,
      advantages: advantages,
      categories: categories,
      overallAdvantage: overallAdvantage,
    );
  }

  // Get hot streak probability
  double getHotStreakProbability(MLBPlayer player) {
    // Based on recent performance and advanced stats
    final stats = generateAdvancedStats(player);
    double probability = 0.5;
    
    probability += (player.avg - 0.250) * 0.5;
    probability += (player.ops - 0.750) * 0.3;
    probability += (stats.barrelRate ?? 0) * 0.2;
    probability += (stats.hardHitRate ?? 0) * 0.15;
    probability += (player.hr / 40) * 0.1;
    
    return probability.clamp(0, 1);
  }
}
