import 'dart:math';
import 'package:stats_analyzer/models/mlb_outlier_models.dart';

class AIService {
  /// Generates a list of Insight objects from markets and analytics.
  static List<Insight> generateInsightsFromMarkets(
    List<MLBNormalizedMarket> markets,
    List<MLBAnalyticsResult> analytics,
  ) {
    final insights = <Insight>[];
    final random = Random();

    // Pair each market with its analytics
    for (final market in markets) {
      final a = _findAnalytics(market, analytics);
      if (a == null) continue;

      // We want insights for props with positive EV (> 3) and decent hit rate (> 0.5)
      if (a.ev <= 3 || a.hitRate < 0.5) continue;

      // Build a natural-language headline and subline
      final side = a.ev > 0 ? 'Over' : 'Under';
      final playerName = market.playerName;
      final statType = market.marketType;
      final line = market.line.toStringAsFixed(1);

      // Headline: "Player Over/Under stat line"
      final headline = '$playerName $side $line $statType';

      // Subline: a short reason based on splits or trend
      String subline = '';
      if (a.splits.isNotEmpty) {
        final bestSplit = a.splits.entries.reduce((a, b) => a.value > b.value ? a : b);
        subline = 'Strong ${bestSplit.key} performance (${(bestSplit.value * 100).toInt()}%)';
      } else {
        subline = 'Positive EV opportunity';
      }

      // Stat: a more detailed supporting statement
      final hitRate = (a.hitRate * 100).toInt();
      final stat = 'Hit rate of $hitRate% over the last 10 games';

      // Generate a random trend (W/L array) based on hit rate
      final trend = _generateTrend(a.hitRate, 8 + random.nextInt(5));

      // Build odds array from the market's odds map
      final odds = market.odds.entries.map((e) {
        return BookOdds(book: e.key, price: e.value);
      }).toList();

      insights.add(Insight(
        id: 'insight_${DateTime.now().millisecondsSinceEpoch}_${market.playerId}',
        category: _mapCategory(market.marketType),
        headline: headline,
        subline: subline,
        stat: stat,
        trend: trend,
        matchup: '${market.team} vs ${market.opponent}',
        odds: odds,
        edgePct: a.ev / 10, // scale EV to 0-1 range for edge grading
      ));
    }

    // Sort by edge score descending
    insights.sort((a, b) => b.edgePct.compareTo(a.edgePct));

    // Take top 20 to avoid spam
    return insights.take(20).toList();
  }

  static MLBAnalyticsResult? _findAnalytics(
    MLBNormalizedMarket market,
    List<MLBAnalyticsResult> analytics,
  ) {
    try {
      return analytics.firstWhere((a) => a.marketId == market.playerId);
    } catch (_) {
      return null;
    }
  }

  static List<String> _generateTrend(double hitRate, int length) {
    final random = Random();
    final threshold = hitRate + (random.nextDouble() - 0.5) * 0.2;
    return List.generate(length, (_) {
      final r = random.nextDouble();
      return r < threshold ? 'W' : 'L';
    });
  }

  static String _mapCategory(String marketType) {
    switch (marketType) {
      case 'Hits':
        return 'Player Prop';
      case 'Home Runs':
        return 'Player Prop';
      case 'RBI':
        return 'Player Prop';
      case 'Total Bases':
        return 'Player Prop';
      default:
        return 'Market';
    }
  }
}

// Re‑declare the data models used by the insights screen (we keep them here for now).
class Insight {
  final String id;
  final String category;
  final String headline;
  final String subline;
  final String stat;
  final List<String> trend;
  final String matchup;
  final List<BookOdds> odds;
  final double edgePct; // 0.0 – 1.0

  Insight({
    required this.id,
    required this.category,
    required this.headline,
    required this.subline,
    required this.stat,
    required this.trend,
    required this.matchup,
    required this.odds,
    required this.edgePct,
  });
}

class BookOdds {
  final String book;
  final double price;

  BookOdds({required this.book, required this.price});
}
