import 'dart:math';
import 'package:stats_analyzer/models/props_explorer_db.dart';

class PropsResearchService {
  static final PropsResearchService _instance = PropsResearchService._internal();
  factory PropsResearchService() => _instance;
  PropsResearchService._internal();

  final Random _random = Random();

  // ============================================================================
  // API ENDPOINTS
  // ============================================================================

  // GET /players
  List<Player> getPlayers({String? search}) {
    final allPlayers = _generatePlayers();
    if (search == null || search.isEmpty) return allPlayers;
    return allPlayers.where((p) =>
      p.name.toLowerCase().contains(search.toLowerCase()) ||
      p.team.toLowerCase().contains(search.toLowerCase())
    ).toList();
  }

  // GET /player/{id}
  Player getPlayer(String id) {
    return _generatePlayers().firstWhere((p) => p.id == id);
  }

  // GET /player/{id}/props
  List<PropMarket> getPlayerProps(String playerId, {String? sportsbookId}) {
    final allProps = _generatePropMarkets(playerId);
    if (sportsbookId != null) {
      return allProps.where((p) => p.sportsbookId == sportsbookId).toList();
    }
    return allProps;
  }

  // GET /player/{id}/stats
  List<PlayerStat> getPlayerStats(String playerId, {int limit = 20}) {
    return _generatePlayerStats(playerId, limit);
  }

  // GET /player/{id}/splits
  Map<String, double> getPlayerSplits(String playerId) {
    return _generateSplits(playerId);
  }

  // GET /player/{id}/projection
  Projection getPlayerProjection(String playerId, String market) {
    return _generateProjection(playerId, market);
  }

  // GET /player/{id}/odds
  List<PropMarket> getPlayerOdds(String playerId, String market) {
    return _generateOddsComparison(playerId, market);
  }

  // GET /player/{id}/history
  List<OddsHistory> getOddsHistory(String marketId) {
    return _generateOddsHistory(marketId);
  }

  // GET /games/today
  List<Game> getTodayGames() {
    return _generateGames();
  }

  // GET /market/movement
  Map<String, dynamic> getMarketMovement(String marketId) {
    return _generateMarketMovement(marketId);
  }

  // ============================================================================
  // COMPLETE RESEARCH DATA
  // ============================================================================

  PropResearch getPropResearch(String playerId, String marketType) {
    final player = getPlayer(playerId);
    final game = _generateGames().first;
    final projection = getPlayerProjection(playerId, marketType);
    final stats = getPlayerStats(playerId);
    final odds = getPlayerOdds(playerId, marketType);
    final market = odds.first;
    final history = getOddsHistory(market.id);
    final splits = getPlayerSplits(playerId);
    final hitRate = _calculateHitRate(stats, market.line);
    final edge = projection.projection - market.line;

    // Generate insight
    final insight = _generateInsight(
      player: player,
      projection: projection,
      market: market,
      stats: stats,
      splits: splits,
      hitRate: hitRate,
    );

    return PropResearch(
      player: player,
      game: game,
      market: market,
      projection: projection,
      stats: stats,
      oddsHistory: history,
      competingOdds: odds,
      edge: (edge / market.line) * 100,
      hitRate: hitRate,
      splits: splits,
      recommendation: _generateRecommendation(edge, hitRate),
      insight: insight,
    );
  }

  // ============================================================================
  // DATA GENERATION (SIMULATED - REPLACE WITH REAL API)
  // ============================================================================

  List<Player> _generatePlayers() {
    final names = [
      'LeBron James', 'Anthony Davis', 'Luka Doncic', 'Jayson Tatum',
      'Nikola Jokic', 'Giannis Antetokounmpo', 'Stephen Curry',
      'Kevin Durant', 'Joel Embiid', 'Shai Gilgeous-Alexander',
      'Ja Morant', 'Tyrese Haliburton', 'Anthony Edwards', 'Devin Booker',
      'Jalen Brunson', 'Trae Young', 'James Harden', 'Kyrie Irving',
      'Zion Williamson', 'Paolo Banchero'
    ];
    final teams = ['LAL', 'NYK', 'BOS', 'DEN', 'MIL', 'GSW', 'PHX', 'PHI', 'OKC'];
    final positions = ['SF', 'PF', 'PG', 'SG', 'C'];
    
    return List.generate(20, (i) {
      final age = 22 + _random.nextInt(15);
      return Player(
        id: 'player_$i',
        name: names[i % names.length],
        team: teams[i % teams.length],
        position: positions[i % positions.length],
        height: 72 + _random.nextInt(12),
        weight: 180 + _random.nextInt(60),
        age: age,
        headshot: null,
        status: _random.nextDouble() > 0.15 ? 'Active' : 'Questionable',
      );
    });
  }

  List<Game> _generateGames() {
    final teams = ['LAL', 'NYK', 'BOS', 'DEN', 'MIL', 'GSW', 'PHX', 'PHI', 'OKC'];
    final arenas = ['Staples Center', 'Madison Square Garden', 'TD Garden', 'Ball Arena'];
    
    return List.generate(10, (i) {
      final home = teams[i % teams.length];
      final away = teams[(i + 3) % teams.length];
      final now = DateTime.now();
      return Game(
        id: 'game_$i',
        date: now.add(Duration(days: i)),
        homeTeam: home,
        awayTeam: away,
        arena: arenas[i % arenas.length],
        startTime: now.add(Duration(days: i, hours: 19 + i % 3)),
      );
    });
  }

  List<PropMarket> _generatePropMarkets(String playerId) {
    final markets = ['Points', 'Rebounds', 'Assists', 'PRA', '3PM'];
    final sportsbooks = ['FanDuel', 'DraftKings', 'BetMGM', 'Caesars', 'ESPN BET'];
    
    return List.generate(5, (i) {
      final line = 15 + _random.nextDouble() * 15;
      return PropMarket(
        id: 'market_${playerId}_$i',
        playerId: playerId,
        gameId: 'game_${_random.nextInt(10)}',
        marketType: markets[i % markets.length],
        line: double.parse(line.toStringAsFixed(1)),
        sportsbookId: 'sb_${i % sportsbooks.length}',
        overOdds: -120 + _random.nextInt(60),
        underOdds: -120 + _random.nextInt(60),
        lastUpdated: DateTime.now().subtract(Duration(minutes: _random.nextInt(30))),
      );
    });
  }

  List<PlayerStat> _generatePlayerStats(String playerId, int limit) {
    final now = DateTime.now();
    final stats = <PlayerStat>[];
    final teams = ['LAL', 'NYK', 'BOS', 'DEN', 'MIL', 'GSW', 'PHX'];

    for (int i = 0; i < limit; i++) {
      stats.add(PlayerStat(
        playerId: playerId,
        date: now.subtract(Duration(days: limit - i)),
        points: 20 + _random.nextInt(20),
        rebounds: 5 + _random.nextInt(8),
        assists: 4 + _random.nextInt(7),
        minutes: 30 + _random.nextInt(10),
        usage: 20 + _random.nextDouble() * 15,
        fgAttempts: 15 + _random.nextInt(12),
        threePa: 4 + _random.nextInt(8),
        freeThrows: 4 + _random.nextInt(6),
        pace: 95 + _random.nextDouble() * 10,
        opponent: teams[i % teams.length],
        isHome: _random.nextBool(),
      ));
    }
    return stats;
  }

  List<OddsHistory> _generateOddsHistory(String marketId) {
    final now = DateTime.now();
    final history = <OddsHistory>[];
    const int points = 24;
    
    for (int i = 0; i < 24; i++) {
      final hour = now.subtract(Duration(hours: i));
      // Simulate line movement
      final baseLine = 24.5;
      final movement = (_random.nextDouble() - 0.5) * 2.0;
      final line = double.parse((baseLine + movement).toStringAsFixed(1));
      final spread = 8 + _random.nextInt(12);
      
      history.add(OddsHistory(
        marketId: marketId,
        line: line,
        over: -110 + _random.nextInt(30),
        under: -110 + _random.nextInt(30),
        timestamp: hour,
      ));
    }
    
    return history.reversed.toList();
  }

  Map<String, double> _generateSplits(String playerId) {
    return {
      'Home': 25 + _random.nextDouble() * 6,
      'Away': 22 + _random.nextDouble() * 6,
      'vs Winning': 23 + _random.nextDouble() * 5,
      'vs Losing': 26 + _random.nextDouble() * 6,
      'Back-to-Back': 20 + _random.nextDouble() * 5,
      '1 Day Rest': 26 + _random.nextDouble() * 5,
      'Last 5': 27 + _random.nextDouble() * 4,
      'Last 10': 25 + _random.nextDouble() * 5,
    };
  }

  Projection _generateProjection(String playerId, String market) {
    final baseProjection = 22.0 + _random.nextDouble() * 8.0;
    return Projection(
      playerId: playerId,
      market: market,
      projection: double.parse(baseProjection.toStringAsFixed(1)),
      confidence: 0.75 + _random.nextDouble() * 0.2,
      modelVersion: 'v2.1.0',
    );
  }

  List<PropMarket> _generateOddsComparison(String playerId, String market) {
    final sportsbooks = ['FanDuel', 'DraftKings', 'BetMGM', 'Caesars', 'ESPN BET'];
    final baseLine = 24.5;
    
    return List.generate(sportsbooks.length, (i) {
      final line = baseLine + (_random.nextDouble() - 0.5) * 1.0;
      return PropMarket(
        id: 'market_${playerId}_${sportsbooks[i]}',
        playerId: playerId,
        gameId: 'game_${_random.nextInt(10)}',
        marketType: market,
        line: double.parse(line.toStringAsFixed(1)),
        sportsbookId: 'sb_$i',
        overOdds: -120 + _random.nextInt(60),
        underOdds: -120 + _random.nextInt(60),
        lastUpdated: DateTime.now().subtract(Duration(minutes: _random.nextInt(15))),
      );
    });
  }

  Map<String, dynamic> _generateMarketMovement(String marketId) {
    return {
      'open': 23.5,
      'current': 24.5,
      'movement': '+1.0',
      'direction': 'up',
      'volume': 'High',
      'steam': true,
    };
  }

  // ============================================================================
  // ANALYTICS ENGINE
  // ============================================================================

  double _calculateHitRate(List<PlayerStat> stats, double line) {
    final hits = stats.where((s) => s.points > line).length;
    return stats.isEmpty ? 0.5 : hits / stats.length;
  }

  String _generateRecommendation(double edge, double hitRate) {
    if (edge > 5 && hitRate > 0.7) return '🔥 STRONG POSITIVE EV - High confidence';
    if (edge > 3) return '✅ POSITIVE EV - Good value';
    if (edge > 1 && hitRate > 0.6) return '📊 MODERATE EV - Consider';
    if (edge > -1) return '⚖️ NEUTRAL - Monitor';
    if (edge > -3) return '⚠️ NEGATIVE EV - Avoid';
    return '❌ STRONG NEGATIVE EV - Stay away';
  }

  String _generateInsight({
    required Player player,
    required Projection projection,
    required PropMarket market,
    required List<PlayerStat> stats,
    required Map<String, double> splits,
    required double hitRate,
  }) {
    final insights = <String>[];
    
    // Projection insight
    final diff = projection.projection - market.line;
    insights.add('Projection: ${projection.projection} vs market line of ${market.line} (${diff > 0 ? "+" : ""}${diff.toStringAsFixed(1)})');
    
    // Recent form
    final recentHits = stats.take(5).where((s) => s.points > market.line).length;
    insights.add('Recent form: Cleared this line in $recentHits of the last 5 games');
    
    // Matchup insight
    final matchup = splits['vs Winning'] ?? 0;
    final vsWinning = matchup > splits['vs Losing'] ?? 0;
    insights.add('Matchup: ${vsWinning ? "Performs well" : "Struggles"} against winning teams');
    
    // Home/Away insight
    final home = splits['Home'] ?? 0;
    final away = splits['Away'] ?? 0;
    if (home > away + 3) {
      insights.add('Context: Strong home performer (+${(home - away).toStringAsFixed(1)} points)');
    } else if (away > home + 3) {
      insights.add('Context: Strong away performer (+${(away - home).toStringAsFixed(1)} points)');
    }
    
    // Usage trend
    final recentUsage = stats.take(5).map((s) => s.usage).toList();
    if (recentUsage.length >= 5) {
      final avgRecent = recentUsage.reduce((a, b) => a + b) / recentUsage.length;
      final avgAll = stats.map((s) => s.usage).reduce((a, b) => a + b) / stats.length;
      if (avgRecent > avgAll + 3) {
        insights.add('Market: Increased usage in recent games (+${(avgRecent - avgAll).toStringAsFixed(1)}%)');
      }
    }
    
    // Line movement insight
    insights.add('Market: Line has moved from ${(market.line - 0.5).toStringAsFixed(1)} to ${market.line.toStringAsFixed(1)} since opening');
    
    return insights.join(' | ');
  }
}
