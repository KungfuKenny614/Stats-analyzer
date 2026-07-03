// ============================================================================
// DATABASE MODELS
// ============================================================================

class Player {
  final String id;
  final String name;
  final String team;
  final String position;
  final int height;
  final int weight;
  final int age;
  final String? headshot;
  final String status; // Active, Questionable, Out

  Player({
    required this.id,
    required this.name,
    required this.team,
    required this.position,
    required this.height,
    required this.weight,
    required this.age,
    this.headshot,
    this.status = 'Active',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'team': team,
    'position': position,
    'height': height,
    'weight': weight,
    'age': age,
    'headshot': headshot,
    'status': status,
  };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'],
    name: json['name'],
    team: json['team'],
    position: json['position'],
    height: json['height'],
    weight: json['weight'],
    age: json['age'],
    headshot: json['headshot'],
    status: json['status'] ?? 'Active',
  );
}

class Game {
  final String id;
  final DateTime date;
  final String homeTeam;
  final String awayTeam;
  final String arena;
  final DateTime startTime;

  Game({
    required this.id,
    required this.date,
    required this.homeTeam,
    required this.awayTeam,
    required this.arena,
    required this.startTime,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'homeTeam': homeTeam,
    'awayTeam': awayTeam,
    'arena': arena,
    'startTime': startTime.toIso8601String(),
  };

  factory Game.fromJson(Map<String, dynamic> json) => Game(
    id: json['id'],
    date: DateTime.parse(json['date']),
    homeTeam: json['homeTeam'],
    awayTeam: json['awayTeam'],
    arena: json['arena'],
    startTime: DateTime.parse(json['startTime']),
  );
}

class Sportsbook {
  final String id;
  final String name;
  final String? logo;
  final String state;

  Sportsbook({
    required this.id,
    required this.name,
    this.logo,
    required this.state,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'logo': logo,
    'state': state,
  };

  factory Sportsbook.fromJson(Map<String, dynamic> json) => Sportsbook(
    id: json['id'],
    name: json['name'],
    logo: json['logo'],
    state: json['state'],
  );
}

class PropMarket {
  final String id;
  final String playerId;
  final String gameId;
  final String marketType;
  final double line;
  final String sportsbookId;
  final int overOdds;
  final int underOdds;
  final DateTime lastUpdated;

  PropMarket({
    required this.id,
    required this.playerId,
    required this.gameId,
    required this.marketType,
    required this.line,
    required this.sportsbookId,
    required this.overOdds,
    required this.underOdds,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'playerId': playerId,
    'gameId': gameId,
    'marketType': marketType,
    'line': line,
    'sportsbookId': sportsbookId,
    'overOdds': overOdds,
    'underOdds': underOdds,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory PropMarket.fromJson(Map<String, dynamic> json) => PropMarket(
    id: json['id'],
    playerId: json['playerId'],
    gameId: json['gameId'],
    marketType: json['marketType'],
    line: json['line'],
    sportsbookId: json['sportsbookId'],
    overOdds: json['overOdds'],
    underOdds: json['underOdds'],
    lastUpdated: DateTime.parse(json['lastUpdated']),
  );
}

class OddsHistory {
  final String marketId;
  final double line;
  final int over;
  final int under;
  final DateTime timestamp;

  OddsHistory({
    required this.marketId,
    required this.line,
    required this.over,
    required this.under,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'marketId': marketId,
    'line': line,
    'over': over,
    'under': under,
    'timestamp': timestamp.toIso8601String(),
  };

  factory OddsHistory.fromJson(Map<String, dynamic> json) => OddsHistory(
    marketId: json['marketId'],
    line: json['line'],
    over: json['over'],
    under: json['under'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class PlayerStat {
  final String playerId;
  final DateTime date;
  final int points;
  final int rebounds;
  final int assists;
  final int minutes;
  final double usage;
  final int fgAttempts;
  final int threePa;
  final int freeThrows;
  final double pace;
  final String opponent;
  final bool isHome;

  PlayerStat({
    required this.playerId,
    required this.date,
    required this.points,
    required this.rebounds,
    required this.assists,
    required this.minutes,
    required this.usage,
    required this.fgAttempts,
    required this.threePa,
    required this.freeThrows,
    required this.pace,
    required this.opponent,
    required this.isHome,
  });

  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'date': date.toIso8601String(),
    'points': points,
    'rebounds': rebounds,
    'assists': assists,
    'minutes': minutes,
    'usage': usage,
    'fgAttempts': fgAttempts,
    'threePa': threePa,
    'freeThrows': freeThrows,
    'pace': pace,
    'opponent': opponent,
    'isHome': isHome,
  };

  factory PlayerStat.fromJson(Map<String, dynamic> json) => PlayerStat(
    playerId: json['playerId'],
    date: DateTime.parse(json['date']),
    points: json['points'],
    rebounds: json['rebounds'],
    assists: json['assists'],
    minutes: json['minutes'],
    usage: json['usage'],
    fgAttempts: json['fgAttempts'],
    threePa: json['threePa'],
    freeThrows: json['freeThrows'],
    pace: json['pace'],
    opponent: json['opponent'],
    isHome: json['isHome'],
  );
}

class Projection {
  final String playerId;
  final String market;
  final double projection;
  final double confidence;
  final String modelVersion;

  Projection({
    required this.playerId,
    required this.market,
    required this.projection,
    required this.confidence,
    required this.modelVersion,
  });

  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'market': market,
    'projection': projection,
    'confidence': confidence,
    'modelVersion': modelVersion,
  };

  factory Projection.fromJson(Map<String, dynamic> json) => Projection(
    playerId: json['playerId'],
    market: json['market'],
    projection: json['projection'],
    confidence: json['confidence'],
    modelVersion: json['modelVersion'],
  );
}

// ============================================================================
// RESEARCH MODELS
// ============================================================================

class PropResearch {
  final Player player;
  final Game game;
  final PropMarket market;
  final Projection projection;
  final List<PlayerStat> stats;
  final List<OddsHistory> oddsHistory;
  final List<PropMarket> competingOdds;
  final double edge;
  final double hitRate;
  final Map<String, double> splits;
  final String recommendation;
  final String insight;

  PropResearch({
    required this.player,
    required this.game,
    required this.market,
    required this.projection,
    required this.stats,
    required this.oddsHistory,
    required this.competingOdds,
    required this.edge,
    required this.hitRate,
    required this.splits,
    required this.recommendation,
    required this.insight,
  });

  double get projectedValue => projection.projection;
  double get marketLine => market.line;
  double get difference => projectedValue - marketLine;
  String get edgeDisplay => '${edge > 0 ? "+" : ""}${edge.toStringAsFixed(1)}%';
  Color get edgeColor => edge > 3 ? Colors.green : edge > 1 ? Colors.orange : Colors.red;
  
  String get recommendationDisplay {
    if (edge > 5) return '🚀 Strong Buy';
    if (edge > 3) return '✅ Buy';
    if (edge > 1) return '📊 Consider';
    if (edge > -1) return '⚖️ Neutral';
    if (edge > -3) return '⚠️ Avoid';
    return '❌ Strong Avoid';
  }

  Color get recommendationColor {
    if (edge > 5) return Colors.green;
    if (edge > 3) return Colors.green.shade300;
    if (edge > 1) return Colors.orange;
    if (edge > -1) return Colors.grey;
    if (edge > -3) return Colors.orange.shade700;
    return Colors.red;
  }
}
