import 'dart:math';
import 'package:stats_analyzer/models/mlb_outlier_models.dart';

class MLBOutlierEngine {
  final Random random = Random(); // made public

  // Generate sample MLB markets
  List<MLBNormalizedMarket> generateSampleMLBMarkets() {
    final markets = <MLBNormalizedMarket>[];
    final players = [
      ('Shohei Ohtani', 'LAD'),
      ('Aaron Judge', 'NYY'),
      ('Mookie Betts', 'LAD'),
      ('Bryce Harper', 'PHI'),
      ('Freddie Freeman', 'LAD'),
      ('Corey Seager', 'TEX'),
      ('Juan Soto', 'NYY'),
      ('Ronald Acuña Jr.', 'ATL'),
      ('Mike Trout', 'LAA'),
      ('Vladimir Guerrero Jr.', 'TOR'),
    ];

    final marketTypes = ['Hits', 'Total Bases', 'Home Runs', 'RBI', 'Strikeouts'];
    final sportsbooks = ['FanDuel', 'DraftKings', 'BetMGM', 'Caesars'];
    final opponents = ['LAD', 'NYY', 'ATL', 'PHI', 'HOU', 'TEX', 'SFG', 'CHC', 'BOS', 'TOR'];

    for (int i = 0; i < players.length; i++) {
      final player = players[i];
      final marketType = marketTypes[i % marketTypes.length];
      final baseLine = marketType == 'Hits' ? 0.5 + random.nextDouble() * 1.5 :
                       marketType == 'Total Bases' ? 1.5 + random.nextDouble() * 2.0 :
                       marketType == 'Home Runs' ? 0.5 : 
                       marketType == 'RBI' ? 0.5 + random.nextDouble() * 1.0 :
                       4.5 + random.nextDouble() * 3.0;
      
      final line = double.parse(baseLine.toStringAsFixed(1));
      final odds = <String, double>{};
      
      for (final book in sportsbooks) {
        final spread = (random.nextDouble() - 0.5) * 20;
        odds[book] = -110 + spread;
      }

      markets.add(MLBNormalizedMarket(
        playerId: 'player_$i',
        playerName: player.$1,
        team: player.$2,
        marketType: marketType,
        line: line,
        odds: odds,
        gameId: 'game_$i',
        opponent: opponents[i % opponents.length],
        isHome: random.nextBool(),
        timestamp: DateTime.now(),
      ));
    }

    return markets;
  }

  // Generate sample MLB stats for a player
  List<MLBPlayerStatsFeed> generateSampleMLBStats(String playerId, String playerName, String team) {
    final stats = <MLBPlayerStatsFeed>[];
    final now = DateTime.now();
    final opponents = ['LAD', 'NYY', 'ATL', 'PHI', 'HOU', 'TEX', 'SFG', 'CHC', 'BOS', 'TOR'];

    for (int i = 0; i < 20; i++) {
      stats.add(MLBPlayerStatsFeed(
        playerId: playerId,
        playerName: playerName,
        team: team,
        date: now.subtract(Duration(days: 20 - i)),
        games: 1,
        avg: 0.200 + random.nextDouble() * 0.250,
        obp: 0.280 + random.nextDouble() * 0.150,
        slg: 0.350 + random.nextDouble() * 0.250,
        ops: 0.630 + random.nextDouble() * 0.400,
        hits: random.nextInt(4),
        homeRuns: random.nextInt(2),
        rbi: random.nextInt(4),
        runs: random.nextInt(3),
        strikeouts: random.nextInt(3),
        walks: random.nextInt(2),
        atBats: 3 + random.nextInt(3),
        hardHitRate: 0.3 + random.nextDouble() * 0.4,
        barrelRate: 0.05 + random.nextDouble() * 0.15,
        avgExitVelocity: 85 + random.nextDouble() * 10,
        opponent: opponents[i % opponents.length],
        isHome: random.nextBool(),
      ));
    }

    return stats;
  }

  // Analyze MLB market
  MLBAnalyticsResult analyzeMLBMarket({
    required String marketId,
    required MLBNormalizedMarket market,
    required List<MLBPlayerStatsFeed> stats,
    required double modelProjection,
    required double sharpPercentage,
    required double publicPercentage,
    required double previousLine,
    required double previousOdds,
  }) {
    // EV Calculation
    final impliedProbability = market.impliedOver;
    final modelProbability = modelProjection / market.line;
    final ev = (modelProbability - impliedProbability) * 100;

    // Arbitrage detection
    final implied1 = _calculateImplied(market.bestOverOdds);
    final implied2 = _calculateImplied(market.bestUnderOdds);
    final combined = implied1 + implied2;
    final arbitrageProfit = (1 - combined) * 100;

    // Hit Rate
    final hitRate = stats.isNotEmpty 
        ? stats.where((s) => s.hits > market.line).length / stats.length
        : 0.5;

    // Splits (simplified)
    final splits = {
      'Home': stats.where((s) => s.isHome).isNotEmpty 
          ? stats.where((s) => s.isHome).where((s) => s.hits > market.line).length / stats.where((s) => s.isHome).length
          : 0.5,
      'Away': stats.where((s) => !s.isHome).isNotEmpty 
          ? stats.where((s) => !s.isHome).where((s) => s.hits > market.line).length / stats.where((s) => !s.isHome).length
          : 0.5,
    };

    // Advanced metrics
    final hardHitRate = stats.isNotEmpty 
        ? stats.map((s) => s.hardHitRate).reduce((a, b) => a + b) / stats.length
        : 0.3;
    final barrelRate = stats.isNotEmpty 
        ? stats.map((s) => s.barrelRate).reduce((a, b) => a + b) / stats.length
        : 0.1;
    final avgExitVelocity = stats.isNotEmpty 
        ? stats.map((s) => s.avgExitVelocity).reduce((a, b) => a + b) / stats.length
        : 85.0;

    // Recommendation
    String recommendation;
    if (ev > 5 && hitRate > 0.7) {
      recommendation = '🔥 STRONG BUY - Elite EV with hot streak';
    } else if (ev > 3 && hitRate > 0.6) {
      recommendation = '✅ BUY - Positive EV with good form';
    } else if (ev > 1) {
      recommendation = '📊 CONSIDER - Marginal EV opportunity';
    } else if (ev > -1) {
      recommendation = '⚖️ NEUTRAL - Monitor for changes';
    } else if (ev > -3) {
      recommendation = '⚠️ AVOID - Negative EV';
    } else {
      recommendation = '❌ STRONG AVOID - Poor value';
    }

    return MLBAnalyticsResult(
      marketId: marketId,
      playerName: market.playerName,
      marketType: market.marketType,
      line: market.line,
      ev: ev,
      arbitrageProfit: arbitrageProfit,
      hitRate: hitRate,
      splits: splits,
      hardHitRate: hardHitRate,
      barrelRate: barrelRate,
      avgExitVelocity: avgExitVelocity,
      recommendation: recommendation,
    );
  }

  double _calculateImplied(double odds) {
    if (odds > 0) return 100 / (odds + 100);
    return -odds / (-odds + 100);
  }
}
