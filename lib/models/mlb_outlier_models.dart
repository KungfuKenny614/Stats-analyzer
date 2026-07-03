import 'dart:math';

class MLBNormalizedMarket {
  final String playerId;
  final String playerName;
  final String team;
  final String marketType;
  final double line;
  final Map<String, double> odds;
  final String gameId;
  final String opponent;
  final bool isHome;
  final DateTime timestamp;

  MLBNormalizedMarket({
    required this.playerId,
    required this.playerName,
    required this.team,
    required this.marketType,
    required this.line,
    required this.odds,
    required this.gameId,
    required this.opponent,
    required this.isHome,
    required this.timestamp,
  });

  double get bestOverOdds => odds.values.reduce((a, b) => a > b ? a : b);
  double get bestUnderOdds => odds.values.reduce((a, b) => a < b ? a : b);
  
  String get bestOverBook => odds.entries.firstWhere(
    (e) => e.value == bestOverOdds,
    orElse: () => odds.entries.first,
  ).key;
  
  String get bestUnderBook => odds.entries.firstWhere(
    (e) => e.value == bestUnderOdds,
    orElse: () => odds.entries.first,
  ).key;

  double get impliedOver {
    if (bestOverOdds > 0) return 100 / (bestOverOdds + 100);
    return -bestOverOdds / (-bestOverOdds + 100);
  }

  double get impliedUnder {
    if (bestUnderOdds > 0) return 100 / (bestUnderOdds + 100);
    return -bestUnderOdds / (-bestUnderOdds + 100);
  }

  double get totalImplied => impliedOver + impliedUnder;
}

class MLBAnalyticsResult {
  final String marketId;
  final String playerName;
  final String marketType;
  final double line;
  final double ev;
  final double arbitrageProfit;
  final double hitRate;
  final Map<String, double> splits;
  final double hardHitRate;
  final double barrelRate;
  final double avgExitVelocity;
  final String recommendation;

  MLBAnalyticsResult({
    required this.marketId,
    required this.playerName,
    required this.marketType,
    required this.line,
    required this.ev,
    required this.arbitrageProfit,
    required this.hitRate,
    required this.splits,
    required this.hardHitRate,
    required this.barrelRate,
    required this.avgExitVelocity,
    required this.recommendation,
  });

  bool get isEVPositive => ev > 0;
  bool get isArbitrage => arbitrageProfit > 0;
}

class MLBPlayerStatsFeed {
  final String playerId;
  final String playerName;
  final String team;
  final DateTime date;
  final int games;
  final double avg;
  final double obp;
  final double slg;
  final double ops;
  final int hits;
  final int homeRuns;
  final int rbi;
  final int runs;
  final int strikeouts;
  final int walks;
  final int atBats;
  final double hardHitRate;
  final double barrelRate;
  final double avgExitVelocity;
  final String opponent;
  final bool isHome;

  MLBPlayerStatsFeed({
    required this.playerId,
    required this.playerName,
    required this.team,
    required this.date,
    required this.games,
    required this.avg,
    required this.obp,
    required this.slg,
    required this.ops,
    required this.hits,
    required this.homeRuns,
    required this.rbi,
    required this.runs,
    required this.strikeouts,
    required this.walks,
    required this.atBats,
    required this.hardHitRate,
    required this.barrelRate,
    required this.avgExitVelocity,
    required this.opponent,
    required this.isHome,
  });
}
