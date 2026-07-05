import 'package:flutter/material.dart';
import 'package:stats_analyzer/services/mlb_api_service.dart';
import 'package:stats_analyzer/services/injuries_service.dart';
import 'package:stats_analyzer/design_system/tokens/colors.dart';
import 'package:stats_analyzer/design_system/tokens/spacing.dart';
import 'package:stats_analyzer/design_system/tokens/typography.dart';
import 'package:stats_analyzer/widgets/line_movement_chart.dart';
import 'package:stats_analyzer/services/line_movement_service.dart';
import 'dart:async';

class MatchDetailsScreen extends StatefulWidget {
  final int gamePk;
  final String? awayTeam;
  final String? homeTeam;

  const MatchDetailsScreen({
    super.key,
    required this.gamePk,
    this.awayTeam,
    this.homeTeam,
  });

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  final MLBApiService _api = MLBApiService();
  Map<String, dynamic> _feed = {};
  bool _loading = true;
  String _error = '';
  Timer? _liveTimer;
  bool _isLive = false;
  List<InjuryData> _injuries = [];
  bool _loadingInjuries = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _loading = true);
    try {
      final feed = await _api.fetchGameFeed(widget.gamePk);
      setState(() {
        _feed = feed;
        _loading = false;
        _error = '';
        final status = _getStatus();
        _isLive = status == 'In Progress';
        if (_isLive) {
          _startLiveUpdates();
        } else {
          _liveTimer?.cancel();
        }
      });
      // Fetch injuries in background
      _fetchInjuries();
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _fetchInjuries() async {
    setState(() => _loadingInjuries = true);
    try {
      final awayName = _feed['gameData']?['teams']?['away']?['team']?['name'] ?? widget.awayTeam ?? '';
      final homeName = _feed['gameData']?['teams']?['home']?['team']?['name'] ?? widget.homeTeam ?? '';
      final allInjuries = <InjuryData>[];
      // Fetch for both teams
      final awayInjuries = await InjuriesService.fetchTeamInjuries(awayName);
      final homeInjuries = await InjuriesService.fetchTeamInjuries(homeName);
      allInjuries.addAll(awayInjuries);
      allInjuries.addAll(homeInjuries);
      setState(() {
        _injuries = allInjuries;
        _loadingInjuries = false;
      });
    } catch (e) {
      setState(() => _loadingInjuries = false);
    }
  }

  void _startLiveUpdates() {
    _liveTimer?.cancel();
    _liveTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _fetchDataQuietly();
      }
    });
  }

  Future<void> _fetchDataQuietly() async {
    try {
      final feed = await _api.fetchGameFeed(widget.gamePk);
      if (mounted) {
        setState(() {
          _feed = feed;
          final status = _getStatus();
          if (status != 'In Progress') {
            _isLive = false;
            _liveTimer?.cancel();
          }
        });
      }
    } catch (e) {
      // ignore
    }
  }

  String _getStatus() {
    return _feed['liveData']?['linescore']?['status']?['detailedState'] ?? 'Scheduled';
  }

  String _getInning() {
    final linescore = _feed['liveData']?['linescore'] ?? {};
    final inning = linescore['currentInning'] ?? 0;
    final inningState = linescore['inningState'] ?? '';
    return inning > 0 ? '$inning $inningState' : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _feed['gameData']?['teams']?['away']?['team']?['name'] ?? widget.awayTeam ?? 'Match Details',
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          if (_isLive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'LIVE',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: DSColors.deTextSecondary),
          const SizedBox(height: 16),
          Text(_error, style: const TextStyle(color: DSColors.deTextSecondary)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchData, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final gameData = _feed['gameData'] ?? {};
    final liveData = _feed['liveData'] ?? {};
    final teams = gameData['teams'] ?? {};
    final away = teams['away'] ?? {};
    final home = teams['home'] ?? {};
    final awayName = away['team']?['name'] ?? widget.awayTeam ?? 'Away';
    final homeName = home['team']?['name'] ?? widget.homeTeam ?? 'Home';
    final awayScore = liveData['linescore']?['teams']?['away']?['runs'] ?? 0;
    final homeScore = liveData['linescore']?['teams']?['home']?['runs'] ?? 0;
    final status = _getStatus();
    final inning = _getInning();

    final probablePitchers = gameData['probablePitchers'] ?? {};
    final awayPitcher = probablePitchers['away']?['fullName'] ?? 'TBD';
    final homePitcher = probablePitchers['home']?['fullName'] ?? 'TBD';

    final weather = gameData['weather'] ?? {};
    final temp = weather['temp'] ?? '--';
    final wind = weather['wind'] ?? '--';
    final conditions = weather['condition'] ?? '--';

    final umpires = gameData['umpires'] ?? {};
    final homePlateUmpire = umpires['homePlate']?['fullName'] ?? 'TBD';

    // Game Log (innings)
    final linescore = liveData['linescore'] ?? {};
    final inningsData = linescore['innings'] as List? ?? [];
    final awayRunsByInning = <String, int>{};
    final homeRunsByInning = <String, int>{};
    for (final inn in inningsData) {
      final num = inn['num']?.toString() ?? '?';
      awayRunsByInning[num] = inn['away']?['runs'] ?? 0;
      homeRunsByInning[num] = inn['home']?['runs'] ?? 0;
    }

    // Player stats – extract from boxscore
    final boxscore = liveData['boxscore'] ?? {};
    final players = boxscore['players'] as Map<String, dynamic>? ?? {};
    final awayPlayers = <Map<String, dynamic>>[];
    final homePlayers = <Map<String, dynamic>>[];
    players.forEach((key, value) {
      final playerData = value as Map<String, dynamic>;
      final team = playerData['team']?['name'] ?? '';
      final batting = playerData['stats']?['batting'] as Map<String, dynamic>? ?? {};
      final pitching = playerData['stats']?['pitching'] as Map<String, dynamic>? ?? {};
      final info = {
        'name': playerData['person']?['fullName'] ?? 'Unknown',
        'position': playerData['position']?['abbreviation'] ?? '--',
        'batting': batting,
        'pitching': pitching,
      };
      if (team == awayName) {
        awayPlayers.add(info);
      } else if (team == homeName) {
        homePlayers.add(info);
      }
    });

    // Splits data – for now we'll use dummy stats
    final splitsData = {
      'Away': {
        'Batting': {'AVG': '.265', 'OBP': '.335', 'SLG': '.425', 'OPS': '.760', 'HR': '85', 'RBI': '320'},
        'Pitching': {'ERA': '3.85', 'WHIP': '1.24', 'K/9': '8.7', 'BB/9': '3.2'},
      },
      'Home': {
        'Batting': {'AVG': '.258', 'OBP': '.322', 'SLG': '.410', 'OPS': '.732', 'HR': '78', 'RBI': '295'},
        'Pitching': {'ERA': '4.02', 'WHIP': '1.28', 'K/9': '8.2', 'BB/9': '3.5'},
      },
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scoreboard
          _buildScoreboard(awayName, homeName, awayScore, homeScore, status, inning),
          const SizedBox(height: 16),
          // Starting Pitchers
          _buildSection('Starting Pitchers', [
            _buildPitcherRow('Away', awayPitcher),
            _buildPitcherRow('Home', homePitcher),
          ]),
          const SizedBox(height: 16),
          // Weather
          _buildSection('Weather', [
            _buildWeatherRow('Temperature', '$temp°F'),
            _buildWeatherRow('Wind', wind),
            _buildWeatherRow('Conditions', conditions),
          ]),
          const SizedBox(height: 16),
          // Umpire
          _buildSection('Umpire', [
            _buildWeatherRow('Home Plate', homePlateUmpire),
          ]),
          const SizedBox(height: 16),
          // Game Log (inning-by-inning)
          if (inningsData.isNotEmpty)
            _buildSection('Game Log', [
              _buildGameLog(inningsData, awayName, homeName),
            ]),
          const SizedBox(height: 16),
          // Team Splits
          _buildSection('Team Splits', [
            _buildSplitsTable(splitsData),
          ]),
          const SizedBox(height: 16),
          // Player Stats
          _buildSection('Player Stats', [
            _buildPlayerStats(awayName, awayPlayers),
            const SizedBox(height: 8),
            _buildPlayerStats(homeName, homePlayers),
          ]),
          const SizedBox(height: 16),
          // Injuries
          _buildSection('Injuries', [
            if (_loadingInjuries)
              const Center(child: CircularProgressIndicator())
            else if (_injuries.isEmpty)
              const Text('No injuries reported.', style: TextStyle(color: DSColors.deTextSecondary))
            else
              ..._injuries.map((injury) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text('${injury.playerName} (${injury.team})', style: const TextStyle(fontWeight: FontWeight.w500)),
                    const Spacer(),
                    Text('${injury.injuryType} - ${injury.status}', style: const TextStyle(color: DSColors.deTextSecondary)),
                  ],
                ),
              )),
          ]),
          // Line Movement Chart (if available)
          if (_feed.isNotEmpty)
            FutureBuilder(
              future: LineMovementService.getOddsHistory('game_${widget.gamePk}'),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _buildSection(
                    'Line Movement',
                    [
                      LineMovementChart(
                        history: snapshot.data!,
                        title: 'Odds History',
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildScoreboard(String awayName, String homeName, int awayScore, int homeScore, String status, String inning) {
    return Card(
      elevation: 0,
      color: DSColors.deSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: DSColors.deBorder)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(awayName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                Text('$awayScore', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(homeName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                Text('$homeScore', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  status,
                  style: const TextStyle(color: DSColors.deTextSecondary),
                ),
                if (inning.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(inning, style: const TextStyle(color: DSColors.deTextSecondary)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameLog(List<dynamic> innings, String away, String home) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: DSColors.deBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 12,
          headingRowColor: MaterialStateProperty.all(DSColors.deSurfaceHover),
          columns: [
            const DataColumn(label: Text('Inning', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(away, style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(home, style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: innings.map((inn) {
            final num = inn['num']?.toString() ?? '?';
            final awayRuns = inn['away']?['runs'] ?? 0;
            final homeRuns = inn['home']?['runs'] ?? 0;
            return DataRow(cells: [
              DataCell(Text(num)),
              DataCell(Text(awayRuns.toString())),
              DataCell(Text(homeRuns.toString())),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSplitsTable(Map<String, dynamic> splitsData) {
    final away = splitsData['Away'] as Map<String, dynamic>;
    final home = splitsData['Home'] as Map<String, dynamic>;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: DSColors.deBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildSplitRow('Category', 'Away', 'Home'),
          _buildSplitRow('AVG', away['Batting']['AVG'], home['Batting']['AVG']),
          _buildSplitRow('OBP', away['Batting']['OBP'], home['Batting']['OBP']),
          _buildSplitRow('SLG', away['Batting']['SLG'], home['Batting']['SLG']),
          _buildSplitRow('OPS', away['Batting']['OPS'], home['Batting']['OPS']),
          _buildSplitRow('HR', away['Batting']['HR'], home['Batting']['HR']),
          _buildSplitRow('RBI', away['Batting']['RBI'], home['Batting']['RBI']),
          const Divider(height: 8),
          _buildSplitRow('ERA', away['Pitching']['ERA'], home['Pitching']['ERA']),
          _buildSplitRow('WHIP', away['Pitching']['WHIP'], home['Pitching']['WHIP']),
          _buildSplitRow('K/9', away['Pitching']['K/9'], home['Pitching']['K/9']),
          _buildSplitRow('BB/9', away['Pitching']['BB/9'], home['Pitching']['BB/9']),
        ],
      ),
    );
  }

  Widget _buildSplitRow(String label, String awayVal, String homeVal) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(awayVal, textAlign: TextAlign.center)),
          Expanded(child: Text(homeVal, textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildPlayerStats(String teamName, List<Map<String, dynamic>> players) {
    if (players.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text('$teamName: No player data available.', style: const TextStyle(color: DSColors.deTextSecondary)),
      );
    }
    // Show only top hitters (with batting stats) or pitchers
    // For brevity, show first 5 hitters with AVG, HR, RBI
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(teamName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        ...players.take(5).map((player) {
          final batting = player['batting'] as Map<String, dynamic>? ?? {};
          final name = player['name'] ?? 'Unknown';
          final pos = player['position'] ?? '--';
          final avg = batting['avg']?.toStringAsFixed(3) ?? '--';
          final hr = batting['hr'] ?? '--';
          final rbi = batting['rbi'] ?? '--';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                SizedBox(width: 60, child: Text(pos, style: const TextStyle(color: DSColors.deTextSecondary))),
                Expanded(child: Text(name)),
                const SizedBox(width: 8),
                Text('AVG: $avg', style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                Text('HR: $hr', style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                Text('RBI: $rbi', style: const TextStyle(fontSize: 12)),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 0,
      color: DSColors.deSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: DSColors.deBorder)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildPitcherRow(String label, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text(label, style: const TextStyle(color: DSColors.deTextSecondary))),
          Expanded(child: Text(name)),
        ],
      ),
    );
  }

  Widget _buildWeatherRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: DSColors.deTextSecondary))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
