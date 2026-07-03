import 'package:flutter/material.dart';

// ===================== PROP EXPLORER MODEL =====================

class PropExplorer {
  final String id;
  final String playerId;
  final String playerName;
  final String team;
  final String position;
  final String statType;
  final double line;
  final double hitRate;
  final double ev;
  final double impliedOdds;
  final double modelOdds;
  final List<PropHistory> history;
  final SplitsData splits;
  final MatchupData matchup;
  final InjuryContext injury;
  final UsageTrend usageTrend;
  final List<BookOdds> odds;
  final DateTime timestamp;

  PropExplorer({
    required this.id,
    required this.playerId,
    required this.playerName,
    required this.team,
    required this.position,
    required this.statType,
    required this.line,
    required this.hitRate,
    required this.ev,
    required this.impliedOdds,
    required this.modelOdds,
    required this.history,
    required this.splits,
    required this.matchup,
    required this.injury,
    required this.usageTrend,
    required this.odds,
    required this.timestamp,
  });

  // Getters
  String get hitRateDisplay => '${(hitRate * 100).toInt()}%';
  String get evDisplay => ev > 0 ? '+${ev.toStringAsFixed(1)}%' : '${ev.toStringAsFixed(1)}%';
  Color get evColor => ev > 3 ? Colors.green : ev > 1 ? Colors.orange : Colors.red;
  bool get isHot => hitRate > 0.7;
  bool get isValue => ev > 3;

  // JSON serialization
  Map<String, dynamic> toJson() => {
    'id': id,
    'playerId': playerId,
    'playerName': playerName,
    'team': team,
    'position': position,
    'statType': statType,
    'line': line,
    'hitRate': hitRate,
    'ev': ev,
    'impliedOdds': impliedOdds,
    'modelOdds': modelOdds,
    'history': history.map((h) => h.toJson()).toList(),
    'splits': splits.toJson(),
    'matchup': matchup.toJson(),
    'injury': injury.toJson(),
    'usageTrend': usageTrend.toJson(),
    'odds': odds.map((o) => o.toJson()).toList(),
    'timestamp': timestamp.toIso8601String(),
  };

  factory PropExplorer.fromJson(Map<String, dynamic> json) {
    return PropExplorer(
      id: json['id'],
      playerId: json['playerId'],
      playerName: json['playerName'],
      team: json['team'],
      position: json['position'],
      statType: json['statType'],
      line: json['line'],
      hitRate: json['hitRate'],
      ev: json['ev'],
      impliedOdds: json['impliedOdds'],
      modelOdds: json['modelOdds'],
      history: (json['history'] as List).map((h) => PropHistory.fromJson(h)).toList(),
      splits: SplitsData.fromJson(json['splits']),
      matchup: MatchupData.fromJson(json['matchup']),
      injury: InjuryContext.fromJson(json['injury']),
      usageTrend: UsageTrend.fromJson(json['usageTrend']),
      odds: (json['odds'] as List).map((o) => BookOdds.fromJson(o)).toList(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

// ===================== PROP HISTORY =====================

class PropHistory {
  final DateTime date;
  final double value;
  final bool hit;
  final String opponent;
  final bool isHome;

  PropHistory({
    required this.date,
    required this.value,
    required this.hit,
    required this.opponent,
    required this.isHome,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'value': value,
    'hit': hit,
    'opponent': opponent,
    'isHome': isHome,
  };

  factory PropHistory.fromJson(Map<String, dynamic> json) {
    return PropHistory(
      date: DateTime.parse(json['date']),
      value: json['value'],
      hit: json['hit'],
      opponent: json['opponent'],
      isHome: json['isHome'],
    );
  }
}

// ===================== SPLITS DATA =====================

class SplitsData {
  final Map<String, double> homeAway;
  final Map<String, double> dayNight;
  final Map<String, double> vsLeftRight;
  final Map<String, double> monthByMonth;

  SplitsData({
    required this.homeAway,
    required this.dayNight,
    required this.vsLeftRight,
    required this.monthByMonth,
  });

  Map<String, dynamic> toJson() => {
    'homeAway': homeAway,
    'dayNight': dayNight,
    'vsLeftRight': vsLeftRight,
    'monthByMonth': monthByMonth,
  };

  factory SplitsData.fromJson(Map<String, dynamic> json) {
    return SplitsData(
      homeAway: (json['homeAway'] as Map).cast<String, double>(),
      dayNight: (json['dayNight'] as Map).cast<String, double>(),
      vsLeftRight: (json['vsLeftRight'] as Map).cast<String, double>(),
      monthByMonth: (json['monthByMonth'] as Map).cast<String, double>(),
    );
  }

  // Get split advantage
  String getSplitAdvantage() {
    final homeDiff = (homeAway['home'] ?? 0) - (homeAway['away'] ?? 0);
    final dayNightDiff = (dayNight['day'] ?? 0) - (dayNight['night'] ?? 0);
    
    if (homeDiff > 0.05 && dayNightDiff > 0.05) {
      return '🔥 Strong home/day performer';
    } else if (homeDiff > 0.05) {
      return '🏠 Home performer';
    } else if (dayNightDiff > 0.05) {
      return '☀️ Day performer';
    }
    return '📊 Consistent performer';
  }
}

// ===================== MATCHUP DATA =====================

class MatchupData {
  final String opponent;
  final int plateAppearances;
  final double avg;
  final double ops;
  final int extraBaseHits;
  final double opponentEra;
  final String? pitcher;

  MatchupData({
    required this.opponent,
    required this.plateAppearances,
    required this.avg,
    required this.ops,
    required this.extraBaseHits,
    required this.opponentEra,
    this.pitcher,
  });

  Map<String, dynamic> toJson() => {
    'opponent': opponent,
    'plateAppearances': plateAppearances,
    'avg': avg,
    'ops': ops,
    'extraBaseHits': extraBaseHits,
    'opponentEra': opponentEra,
    'pitcher': pitcher,
  };

  factory MatchupData.fromJson(Map<String, dynamic> json) {
    return MatchupData(
      opponent: json['opponent'],
      plateAppearances: json['plateAppearances'],
      avg: json['avg'],
      ops: json['ops'],
      extraBaseHits: json['extraBaseHits'],
      opponentEra: json['opponentEra'],
      pitcher: json['pitcher'],
    );
  }

  String get matchupRating {
    if (avg > 0.300 && ops > 0.800) return '🔥 Elite matchup';
    if (avg > 0.280 && ops > 0.750) return '✅ Good matchup';
    if (avg > 0.250 && ops > 0.700) return '📊 Average';
    return '⚠️ Tough matchup';
  }
}

// ===================== INJURY CONTEXT =====================

class InjuryContext {
  final String playerStatus;
  final String injuryType;
  final DateTime? expectedReturn;
  final String opponentInjury;
  final String notes;

  InjuryContext({
    required this.playerStatus,
    required this.injuryType,
    this.expectedReturn,
    required this.opponentInjury,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
    'playerStatus': playerStatus,
    'injuryType': injuryType,
    'expectedReturn': expectedReturn?.toIso8601String(),
    'opponentInjury': opponentInjury,
    'notes': notes,
  };

  factory InjuryContext.fromJson(Map<String, dynamic> json) {
    return InjuryContext(
      playerStatus: json['playerStatus'],
      injuryType: json['injuryType'],
      expectedReturn: json['expectedReturn'] != null 
          ? DateTime.parse(json['expectedReturn']) 
          : null,
      opponentInjury: json['opponentInjury'],
      notes: json['notes'],
    );
  }

  bool get isHealthy => playerStatus == 'Healthy';
  bool get isQuestionable => playerStatus == 'Questionable';
  bool get isInjured => playerStatus == 'Injured';
}

// ===================== USAGE TREND =====================

class UsageTrend {
  final String direction;
  final double percentChange;
  final int gamesTracked;
  final List<double> usageHistory;

  UsageTrend({
    required this.direction,
    required this.percentChange,
    required this.gamesTracked,
    required this.usageHistory,
  });

  Map<String, dynamic> toJson() => {
    'direction': direction,
    'percentChange': percentChange,
    'gamesTracked': gamesTracked,
    'usageHistory': usageHistory,
  };

  factory UsageTrend.fromJson(Map<String, dynamic> json) {
    return UsageTrend(
      direction: json['direction'],
      percentChange: json['percentChange'],
      gamesTracked: json['gamesTracked'],
      usageHistory: (json['usageHistory'] as List).cast<double>(),
    );
  }

  String get trendEmoji {
    if (direction == 'up') return '📈';
    if (direction == 'down') return '📉';
    return '➡️';
  }

  String get trendDisplay {
    if (percentChange.abs() < 5) return 'Stable';
    if (direction == 'up') return 'Increasing 🔥';
    return 'Decreasing ❄️';
  }
}

// ===================== BOOK ODDS =====================

class BookOdds {
  final String bookName;
  final double odds;
  final double impliedProbability;
  final DateTime timestamp;

  BookOdds({
    required this.bookName,
    required this.odds,
    required this.impliedProbability,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'bookName': bookName,
    'odds': odds,
    'impliedProbability': impliedProbability,
    'timestamp': timestamp.toIso8601String(),
  };

  factory BookOdds.fromJson(Map<String, dynamic> json) {
    return BookOdds(
      bookName: json['bookName'],
      odds: json['odds'],
      impliedProbability: json['impliedProbability'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  String get oddsDisplay {
    if (odds > 0) return '+${odds.toInt()}';
    return odds.toInt().toString();
  }

  Color get oddsColor {
    if (odds > 0) return Colors.green;
    return Colors.red;
  }
}
