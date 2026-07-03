// MLB API Data Models

class MLBGame {
  final int gamePk;
  final String status;
  final String awayTeam;
  final String homeTeam;
  final int awayScore;
  final int homeScore;
  final String inning;
  final String inningState;
  final String gameTime;
  final String? awayTeamLogo;
  final String? homeTeamLogo;

  MLBGame({
    required this.gamePk,
    required this.status,
    required this.awayTeam,
    required this.homeTeam,
    required this.awayScore,
    required this.homeScore,
    required this.inning,
    required this.inningState,
    required this.gameTime,
    this.awayTeamLogo,
    this.homeTeamLogo,
  });

  factory MLBGame.fromJson(Map<String, dynamic> json) {
    final teams = json['teams'] as Map<String, dynamic>? ?? {};
    final away = teams['away'] as Map<String, dynamic>? ?? {};
    final home = teams['home'] as Map<String, dynamic>? ?? {};
    final linescore = json['linescore'] as Map<String, dynamic>? ?? {};
    
    return MLBGame(
      gamePk: json['gamePk'] ?? 0,
      status: json['status']?['detailedState'] ?? 'Scheduled',
      awayTeam: away['team']?['name'] ?? 'Unknown',
      homeTeam: home['team']?['name'] ?? 'Unknown',
      awayScore: away['score'] ?? 0,
      homeScore: home['score'] ?? 0,
      inning: linescore['inningState'] ?? '',
      inningState: linescore['currentInningState'] ?? '',
      gameTime: json['gameDate'] ?? '',
      awayTeamLogo: away['team']?['logo'] ?? '',
      homeTeamLogo: home['team']?['logo'] ?? '',
    );
  }

  String get displayScore => '$awayTeam $awayScore - $homeTeam $homeScore';
  bool get isLive => status == 'In Progress';
  bool get isFinal => status == 'Final';
}

class MLBPlayer {
  final int id;
  final String fullName;
  final String team;
  final String position;
  final double avg;
  final double ops;
  final int hr;
  final int rbi;
  final int hits;
  final int games;

  MLBPlayer({
    required this.id,
    required this.fullName,
    required this.team,
    required this.position,
    required this.avg,
    required this.ops,
    required this.hr,
    required this.rbi,
    required this.hits,
    required this.games,
  });

  factory MLBPlayer.fromJson(Map<String, dynamic> json) {
    final stats = json['stats']?['hitting'] as Map<String, dynamic>? ?? {};
    final stat = json['stat'] as Map<String, dynamic>? ?? {};
    
    return MLBPlayer(
      id: json['person']?['id'] ?? 0,
      fullName: json['person']?['fullName'] ?? 'Unknown',
      team: json['team']?['name'] ?? '',
      position: json['position']?['abbreviation'] ?? '',
      avg: (stat['avg'] as num?)?.toDouble() ?? 0.0,
      ops: (stat['ops'] as num?)?.toDouble() ?? 0.0,
      hr: stat['hr'] ?? 0,
      rbi: stat['rbi'] ?? 0,
      hits: stat['hits'] ?? 0,
      games: stat['games'] ?? 0,
    );
  }

  String get avgDisplay => avg.toStringAsFixed(3);
  String get opsDisplay => ops.toStringAsFixed(3);
}
