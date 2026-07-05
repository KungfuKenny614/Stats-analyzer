import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stats_analyzer/models/mlb_models.dart';
import 'package:stats_analyzer/models/mlb_outlier_models.dart';

class MLBApiService {
  static const String baseUrl = 'https://statsapi.mlb.com/api/v1';
  static const String teamBaseUrl = 'https://statsapi.mlb.com/api/v1/teams';

  // Fetch today's games
  Future<List<MLBGame>> fetchTodayGames() async {
    try {
      final now = DateTime.now();
      final date = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      
      final response = await http.get(
        Uri.parse('$baseUrl/schedule?sportId=1&date=$date'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'DiamondEdge/2.4.1',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final dates = data['dates'] as List? ?? [];
        if (dates.isEmpty) return [];
        final games = dates[0]['games'] as List? ?? [];
        return games.map((game) => MLBGame.fromJson(game)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching games: $e');
      return [];
    }
  }

  // Fetch players for a specific game (with error handling)
  Future<List<MLBPlayer>> fetchGamePlayers(int gamePk) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/game/$gamePk/feed/live'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'DiamondEdge/2.4.1',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final players = <MLBPlayer>[];
        final gameData = data['gameData'] as Map<String, dynamic>? ?? {};
        final playersData = gameData['players'] as Map<String, dynamic>? ?? {};

        // Get stats from the live feed
        final liveData = data['liveData'] as Map<String, dynamic>? ?? {};
        final boxscore = liveData['boxscore'] as Map<String, dynamic>? ?? {};
        final boxscorePlayers = boxscore['players'] as Map<String, dynamic>? ?? {};

        playersData.forEach((key, value) {
          final playerId = int.tryParse(key) ?? 0;
          if (playerId > 0) {
            final stats = value['stats']?['hitting'] as Map<String, dynamic>? ?? {};
            final boxscoreStat = boxscorePlayers[key]?['stats']?['batting'] as Map<String, dynamic>? ?? {};
            
            final avg = (stats['avg'] ?? boxscoreStat['avg'] ?? 0.0).toDouble();
            final ops = (stats['ops'] ?? boxscoreStat['ops'] ?? 0.0).toDouble();
            final hr = stats['hr'] ?? boxscoreStat['homeRuns'] ?? 0;
            final rbi = stats['rbi'] ?? boxscoreStat['rbi'] ?? 0;
            final hits = stats['hits'] ?? boxscoreStat['hits'] ?? 0;
            final games = stats['games'] ?? boxscoreStat['games'] ?? 0;

            players.add(MLBPlayer(
              id: playerId,
              fullName: value['fullName'] ?? 'Unknown',
              team: value['team']?['name'] ?? '',
              position: value['position']?['abbreviation'] ?? '',
              avg: avg,
              ops: ops,
              hr: hr,
              rbi: rbi,
              hits: hits,
              games: games,
            ));
          }
        });
        return players;
      }
      return [];
    } catch (e) {
      print('Error fetching game players for game $gamePk: $e');
      return [];
    }
  }

  // Fetch advanced stats for a player (from season stats endpoint)
  Future<MLBPlayer?> fetchPlayerStats(int playerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/people/$playerId/stats?stats=season&groups=hitting,pitching'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'DiamondEdge/2.4.1',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final stats = data['stats'] as List? ?? [];
        if (stats.isEmpty) return null;

        final seasonStats = stats.firstWhere(
          (s) => s['type']?['displayName'] == 'Season',
          orElse: () => stats[0],
        );
        final splits = seasonStats['splits'] as List? ?? [];
        if (splits.isEmpty) return null;

        final person = data['people'] as List? ?? [];
        if (person.isEmpty) return null;

        return MLBPlayer.fromJson({
          'person': person[0],
          'stat': splits[0]['stat'],
        });
      }
      return null;
    } catch (e) {
      print('Error fetching player stats: $e');
      return null;
    }
  }

  // Generate prop markets from real players
  Future<List<MLBNormalizedMarket>> generateMarketsFromGames(List<MLBGame> games) async {
    final markets = <MLBNormalizedMarket>[];
    final sportsbooks = ['FanDuel', 'DraftKings', 'BetMGM', 'Caesars'];

    for (final game in games) {
      try {
        final players = await fetchGamePlayers(game.gamePk);
        if (players.isEmpty) continue;
        final selectedPlayers = players.take(5).toList();
        
        for (final player in selectedPlayers) {
          final fullPlayer = await fetchPlayerStats(player.id) ?? player;
          final marketTypes = ['Hits', 'Total Bases', 'Home Runs', 'RBI'];
          for (final marketType in marketTypes) {
            double line;
            double baseValue;
            switch (marketType) {
              case 'Hits':
                baseValue = fullPlayer.avg * 3.5;
                line = (baseValue * 0.9 + 0.5).roundToDouble();
                break;
              case 'Total Bases':
                baseValue = fullPlayer.ops * 1.5;
                line = (baseValue * 0.9 + 0.5).roundToDouble();
                break;
              case 'Home Runs':
                baseValue = fullPlayer.hr / 162.0 * 0.5;
                line = (baseValue * 0.8 + 0.5).roundToDouble();
                break;
              case 'RBI':
                baseValue = fullPlayer.rbi / 162.0 * 1.5;
                line = (baseValue * 0.9 + 0.5).roundToDouble();
                break;
              default:
                line = 1.5;
            }
            if (line < 0.5) line = 0.5;
            
            final odds = <String, double>{};
            for (final book in sportsbooks) {
              final spread = (DateTime.now().millisecondsSinceEpoch % 40 - 20) / 1.0;
              odds[book] = -110 + spread;
            }

            markets.add(MLBNormalizedMarket(
              playerId: fullPlayer.id.toString(),
              playerName: fullPlayer.fullName,
              team: fullPlayer.team,
              marketType: marketType,
              line: line,
              odds: odds,
              gameId: game.gamePk.toString(),
              opponent: game.awayTeam == fullPlayer.team ? game.homeTeam : game.awayTeam,
              isHome: game.homeTeam == fullPlayer.team,
              timestamp: DateTime.now(),
            ));
          }
        }
      } catch (e) {
        print('Skipping game ${game.gamePk} due to error: $e');
        continue;
      }
    }
    return markets;
  }

  // Fetch live game feed (used for match details and live updates)
  Future<Map<String, dynamic>> fetchGameFeed(int gamePk) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/game/$gamePk/feed/live'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'DiamondEdge/2.4.1',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      print('Error fetching game feed: $e');
      return {};
    }
  }

  // Get team logo URL
  static const Map<String, String> teamLogos = {
    'LAD': 'https://www.mlbstatic.com/team-logos/dodgers.svg',
    'NYY': 'https://www.mlbstatic.com/team-logos/yankees.svg',
    'NYM': 'https://www.mlbstatic.com/team-logos/mets.svg',
    'BOS': 'https://www.mlbstatic.com/team-logos/redsox.svg',
    'CHC': 'https://www.mlbstatic.com/team-logos/cubs.svg',
    'CHW': 'https://www.mlbstatic.com/team-logos/whitesox.svg',
    'ATL': 'https://www.mlbstatic.com/team-logos/braves.svg',
    'PHI': 'https://www.mlbstatic.com/team-logos/phillies.svg',
    'HOU': 'https://www.mlbstatic.com/team-logos/astros.svg',
    'TEX': 'https://www.mlbstatic.com/team-logos/rangers.svg',
    'SF': 'https://www.mlbstatic.com/team-logos/giants.svg',
    'STL': 'https://www.mlbstatic.com/team-logos/cardinals.svg',
    'ARI': 'https://www.mlbstatic.com/team-logos/diamondbacks.svg',
    'BAL': 'https://www.mlbstatic.com/team-logos/orioles.svg',
    'CLE': 'https://www.mlbstatic.com/team-logos/guardians.svg',
    'KC': 'https://www.mlbstatic.com/team-logos/royals.svg',
    'LAA': 'https://www.mlbstatic.com/team-logos/angels.svg',
    'MIN': 'https://www.mlbstatic.com/team-logos/twins.svg',
    'OAK': 'https://www.mlbstatic.com/team-logos/athletics.svg',
    'SEA': 'https://www.mlbstatic.com/team-logos/mariners.svg',
    'TB': 'https://www.mlbstatic.com/team-logos/rays.svg',
    'TOR': 'https://www.mlbstatic.com/team-logos/bluejays.svg',
    'WAS': 'https://www.mlbstatic.com/team-logos/nationals.svg',
    'MIL': 'https://www.mlbstatic.com/team-logos/brewers.svg',
    'PIT': 'https://www.mlbstatic.com/team-logos/pirates.svg',
    'CIN': 'https://www.mlbstatic.com/team-logos/reds.svg',
    'MIA': 'https://www.mlbstatic.com/team-logos/marlins.svg',
    'COL': 'https://www.mlbstatic.com/team-logos/rockies.svg',
    'SD': 'https://www.mlbstatic.com/team-logos/padres.svg',
    'DET': 'https://www.mlbstatic.com/team-logos/tigers.svg',
  };

  static String getLogoForAbbreviation(String abbr) {
    return teamLogos[abbr] ?? 'https://www.mlbstatic.com/team-logos/mlb.svg';
  }
}
