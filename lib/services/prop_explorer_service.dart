import 'dart:math';
import 'package:stats_analyzer/models/prop_explorer.dart';
import 'package:stats_analyzer/models/mlb_models.dart';

class PropExplorerService {
  static final PropExplorerService _instance = PropExplorerService._internal();
  factory PropExplorerService() => _instance;
  PropExplorerService._internal();

  final Random _random = Random();

  // Generate sample props for explorer
  List<PropExplorer> generateSampleProps() {
    final props = <PropExplorer>[];
    final players = [
      ('Shohei Ohtani', 'LAD', 'DH'),
      ('Aaron Judge', 'NYY', 'RF'),
      ('Mookie Betts', 'LAD', 'RF'),
      ('Freddie Freeman', 'LAD', '1B'),
      ('Bryce Harper', 'PHI', '1B'),
      ('Mike Trout', 'LAA', 'CF'),
      ('Corey Seager', 'TEX', 'SS'),
      ('Juan Soto', 'NYY', 'LF'),
      ('Ronald Acuña Jr.', 'ATL', 'RF'),
      ('Vladimir Guerrero Jr.', 'TOR', '1B'),
    ];

    final statTypes = ['Total Bases', 'Home Runs', 'RBI', 'Hits', 'Strikeouts'];
    final books = ['DraftKings', 'FanDuel', 'BetMGM', 'Caesars', 'PointsBet'];

    for (int i = 0; i < players.length; i++) {
      final player = players[i];
      final statType = statTypes[i % statTypes.length];
      final line = 0.5 + _random.nextDouble() * 2.0;
      final hitRate = 0.4 + _random.nextDouble() * 0.4;
      final ev = -5 + _random.nextDouble() * 15;
      
      props.add(PropExplorer(
        id: 'prop_${DateTime.now().millisecondsSinceEpoch}_$i',
        playerId: 'player_$i',
        playerName: player.$1,
        team: player.$2,
        position: player.$3,
        statType: statType,
        line: line,
        hitRate: hitRate,
        ev: ev,
        impliedOdds: 0.5 + _random.nextDouble() * 0.2,
        modelOdds: 0.5 + _random.nextDouble() * 0.2,
        history: _generateHistory(10),
        splits: _generateSplits(),
        matchup: _generateMatchup(),
        injury: _generateInjury(),
        usageTrend: _generateUsageTrend(),
        odds: _generateBookOdds(books),
        timestamp: DateTime.now(),
      ));
    }

    // Sort by EV
    props.sort((a, b) => b.ev.compareTo(a.ev));
    
    return props;
  }

  List<PropHistory> _generateHistory(int count) {
    final history = <PropHistory>[];
    final now = DateTime.now();
    final teams = ['LAD', 'NYY', 'ATL', 'PHI', 'HOU', 'TEX', 'SFG', 'CHC', 'STL', 'BOS'];

    for (int i = count - 1; i >= 0; i--) {
      history.add(PropHistory(
        date: now.subtract(Duration(days: count - i)),
        value: 0.5 + _random.nextDouble() * 2.5,
        hit: _random.nextDouble() > 0.3,
        opponent: teams[_random.nextInt(teams.length)],
        isHome: _random.nextDouble() > 0.5,
      ));
    }

    return history;
  }

  SplitsData _generateSplits() {
    return SplitsData(
      homeAway: {
        'home': 0.4 + _random.nextDouble() * 0.4,
        'away': 0.3 + _random.nextDouble() * 0.4,
      },
      dayNight: {
        'day': 0.4 + _random.nextDouble() * 0.4,
        'night': 0.3 + _random.nextDouble() * 0.4,
      },
      vsLeftRight: {
        'vsLeft': 0.3 + _random.nextDouble() * 0.4,
        'vsRight': 0.4 + _random.nextDouble() * 0.4,
      },
      monthByMonth: {
        'Apr': 0.3 + _random.nextDouble() * 0.4,
        'May': 0.3 + _random.nextDouble() * 0.4,
        'Jun': 0.3 + _random.nextDouble() * 0.4,
        'Jul': 0.3 + _random.nextDouble() * 0.4,
        'Aug': 0.3 + _random.nextDouble() * 0.4,
        'Sep': 0.3 + _random.nextDouble() * 0.4,
      },
    );
  }

  MatchupData _generateMatchup() {
    final teams = ['LAD', 'NYY', 'ATL', 'PHI', 'HOU', 'TEX', 'SFG', 'CHC'];
    final pitchers = ['Logan Webb', 'Zac Gallen', 'Gerrit Cole', 'Jacob deGrom'];
    
    return MatchupData(
      opponent: teams[_random.nextInt(teams.length)],
      plateAppearances: 10 + _random.nextInt(40),
      avg: 0.2 + _random.nextDouble() * 0.2,
      ops: 0.6 + _random.nextDouble() * 0.3,
      extraBaseHits: _random.nextInt(10),
      opponentEra: 2.5 + _random.nextDouble() * 2.0,
      pitcher: pitchers[_random.nextInt(pitchers.length)],
    );
  }

  InjuryContext _generateInjury() {
    final statuses = ['Healthy', 'Healthy', 'Healthy', 'Questionable', 'Injured'];
    final injuryTypes = ['None', 'None', 'None', 'Hamstring', 'Back', 'Shoulder'];
    final random = _random.nextDouble();
    
    return InjuryContext(
      playerStatus: statuses[_random.nextInt(statuses.length)],
      injuryType: injuryTypes[_random.nextInt(injuryTypes.length)],
      expectedReturn: random > 0.7 ? DateTime.now().add(Duration(days: 3 + _random.nextInt(10))) : null,
      opponentInjury: ['None', 'SP Questionable', 'Closer Out'][_random.nextInt(3)],
      notes: ['Full participant', 'Limited', 'Day-to-day'][_random.nextInt(3)],
    );
  }

  UsageTrend _generateUsageTrend() {
    final directions = ['up', 'down', 'stable'];
    final direction = directions[_random.nextInt(3)];
    
    return UsageTrend(
      direction: direction,
      percentChange: direction == 'up' 
          ? 5 + _random.nextDouble() * 20 
          : direction == 'down' 
              ? -(5 + _random.nextDouble() * 20)
              : 0 + _random.nextDouble() * 5,
      gamesTracked: 5 + _random.nextInt(10),
      usageHistory: List.generate(10, (_) => 0.3 + _random.nextDouble() * 0.5),
    );
  }

  List<BookOdds> _generateBookOdds(List<String> books) {
    return books.map((book) {
      final odds = -120 + _random.nextInt(100);
      return BookOdds(
        bookName: book,
        odds: odds.toDouble(),
        impliedProbability: 0.4 + _random.nextDouble() * 0.2,
        timestamp: DateTime.now(),
      );
    }).toList();
  }

  // Filter props
  List<PropExplorer> filterProps({
    required List<PropExplorer> props,
    String? searchQuery,
    String? statType,
    double? minEV,
    double? minHitRate,
    String? team,
    String? playerName,
  }) {
    return props.where((prop) {
      // Search query
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!prop.playerName.toLowerCase().contains(query) &&
            !prop.team.toLowerCase().contains(query) &&
            !prop.statType.toLowerCase().contains(query)) {
          return false;
        }
      }
      
      // Stat type filter
      if (statType != null && statType.isNotEmpty && prop.statType != statType) {
        return false;
      }
      
      // EV filter
      if (minEV != null && prop.ev < minEV) {
        return false;
      }
      
      // Hit rate filter
      if (minHitRate != null && prop.hitRate < minHitRate) {
        return false;
      }
      
      // Team filter
      if (team != null && team.isNotEmpty && prop.team != team) {
        return false;
      }
      
      // Player name filter
      if (playerName != null && playerName.isNotEmpty && 
          !prop.playerName.toLowerCase().contains(playerName.toLowerCase())) {
        return false;
      }
      
      return true;
    }).toList();
  }

  // Sort props
  List<PropExplorer> sortProps({
    required List<PropExplorer> props,
    required String sortBy,
    bool ascending = false,
  }) {
    final sorted = List<PropExplorer>.from(props);
    
    switch (sortBy) {
      case 'ev':
        sorted.sort((a, b) => a.ev.compareTo(b.ev));
        break;
      case 'hitRate':
        sorted.sort((a, b) => a.hitRate.compareTo(b.hitRate));
        break;
      case 'playerName':
        sorted.sort((a, b) => a.playerName.compareTo(b.playerName));
        break;
      case 'statType':
        sorted.sort((a, b) => a.statType.compareTo(b.statType));
        break;
      case 'line':
        sorted.sort((a, b) => a.line.compareTo(b.line));
        break;
      default:
        sorted.sort((a, b) => a.ev.compareTo(b.ev));
    }
    
    if (!ascending) {
      sorted.reversed;
    }
    
    return sorted;
  }
}
