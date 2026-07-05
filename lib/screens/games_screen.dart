import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stats_analyzer/providers/app_state.dart';
import 'package:stats_analyzer/models/mlb_models.dart';
import 'package:stats_analyzer/design_system/tokens/colors.dart';
import 'package:stats_analyzer/design_system/tokens/spacing.dart';
import 'package:stats_analyzer/design_system/tokens/typography.dart';
import 'package:stats_analyzer/services/odds_service.dart';
import 'package:stats_analyzer/screens/match_details_screen.dart';
import 'dart:async';

// ============================================================================
// DATA MODELS
// ============================================================================

class TeamFormRecord {
  final List<String> moneyline;
  final List<String> spread;

  TeamFormRecord({required this.moneyline, required this.spread});

  factory TeamFormRecord.mock({required int games}) {
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    final bool isWinning = random > 30;
    return TeamFormRecord(
      moneyline: List.generate(games, (_) => isWinning && random % 2 == 0 ? 'W' : 'L'),
      spread: List.generate(games, (_) => !isWinning && random % 2 == 1 ? 'W' : 'L'),
    );
  }
}

class GameCardData {
  final String id;
  final String startTime;
  final String awayName;
  final String homeName;
  final String awayRecord;
  final String homeRecord;
  final String awayColor;
  final String homeColor;
  final TeamFormRecord awayForm;
  final TeamFormRecord homeForm;
  final List<String> totalOverForm;
  final List<String> totalUnderForm;
  final Map<String, String> odds;

  GameCardData({
    required this.id,
    required this.startTime,
    required this.awayName,
    required this.homeName,
    required this.awayRecord,
    required this.homeRecord,
    required this.awayColor,
    required this.homeColor,
    required this.awayForm,
    required this.homeForm,
    required this.totalOverForm,
    required this.totalUnderForm,
    required this.odds,
  });

  factory GameCardData.fromMLBGame(MLBGame game, {Map<String, String>? odds}) {
    final awayWin = game.awayScore > game.homeScore;
    final homeWin = game.homeScore > game.awayScore;
    final isFinal = game.status == 'Final' || game.status == 'In Progress';
    final awayForm = TeamFormRecord(
      moneyline: isFinal ? List.filled(5, awayWin ? 'W' : 'L') : ['-', '-', '-', '-', '-'],
      spread: isFinal ? List.filled(5, awayWin ? 'W' : 'L') : ['-', '-', '-', '-', '-'],
    );
    final homeForm = TeamFormRecord(
      moneyline: isFinal ? List.filled(5, homeWin ? 'W' : 'L') : ['-', '-', '-', '-', '-'],
      spread: isFinal ? List.filled(5, homeWin ? 'W' : 'L') : ['-', '-', '-', '-', '-'],
    );
    final total = game.awayScore + game.homeScore;
    final overHit = total > 8;
    final underHit = total < 8;
    final totalOverForm = isFinal ? List.filled(5, overHit ? 'W' : 'L') : ['-', '-', '-', '-', '-'];
    final totalUnderForm = isFinal ? List.filled(5, underHit ? 'W' : 'L') : ['-', '-', '-', '-', '-'];

    final colors = {
      'Los Angeles Dodgers': '#005A9C',
      'New York Yankees': '#0C2340',
      'Boston Red Sox': '#BD3039',
      'New York Mets': '#002B5C',
      'Philadelphia Phillies': '#E8182A',
      'Chicago Cubs': '#0E3386',
      'St. Louis Cardinals': '#C41E3A',
      'Houston Astros': '#EB6E1F',
      'Texas Rangers': '#003278',
      'Atlanta Braves': '#0C1A3C',
      'San Francisco Giants': '#FD5A1E',
      'San Diego Padres': '#2F241D',
    };
    return GameCardData(
      id: game.gamePk.toString(),
      startTime: game.gameTime.isNotEmpty ? game.gameTime.substring(11, 16) : 'TBD',
      awayName: game.awayTeam,
      homeName: game.homeTeam,
      awayRecord: '--',
      homeRecord: '--',
      awayColor: colors[game.awayTeam] ?? '#1A73E8',
      homeColor: colors[game.homeTeam] ?? '#FF5252',
      awayForm: awayForm,
      homeForm: homeForm,
      totalOverForm: totalOverForm,
      totalUnderForm: totalUnderForm,
      odds: odds ?? {},
    );
  }
}

// ============================================================================
// UI COMPONENTS
// ============================================================================

class FormBar extends StatelessWidget {
  final List<String> results;

  const FormBar({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: results.map((r) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 0.5),
              decoration: BoxDecoration(
                color: r == 'W' ? DSColors.deWin : r == 'L' ? DSColors.deLoss : Colors.grey.shade700,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class OddsRow extends StatefulWidget {
  final List<String> form;
  final String topLabel;
  final String? price;

  const OddsRow({super.key, required this.form, required this.topLabel, this.price});

  @override
  State<OddsRow> createState() => _OddsRowState();
}

class _OddsRowState extends State<OddsRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        width: double.infinity,
        color: _hover ? DSColors.deSurfaceHover : DSColors.deSurface,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormBar(results: widget.form),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.topLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: DSColors.deTextPrimary,
                  ),
                ),
                if (widget.price != null)
                  Text(
                    widget.price!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: DSColors.deTextSecondary,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MarketBox extends StatelessWidget {
  final List<Widget> children;

  const MarketBox({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 110),
      decoration: BoxDecoration(
        color: DSColors.deSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DSColors.deBorder),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          return Column(
            children: [
              child,
              if (index < children.length - 1)
                Divider(height: 0, color: DSColors.deBorder),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class TeamRow extends StatelessWidget {
  final String name;
  final String record;
  final String color;

  const TeamRow({super.key, required this.name, required this.record, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Color(int.parse(color.replaceFirst('#', ''), radix: 16) + 0xFF000000),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              name.substring(0, 2).toUpperCase(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DSColors.deTextPrimary),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                record,
                style: const TextStyle(fontSize: 11, color: DSColors.deTextSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class GameCard extends StatefulWidget {
  final GameCardData game;
  final VoidCallback? onMatchDetails;

  const GameCard({super.key, required this.game, this.onMatchDetails});

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final g = widget.game;
    return Container(
      decoration: BoxDecoration(
        color: DSColors.deSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DSColors.deBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'TODAY  ${g.startTime}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: DSColors.deTextSecondary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 12,
              runSpacing: 12,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TeamRow(name: g.awayName, record: g.awayRecord, color: g.awayColor),
                    const SizedBox(height: 12),
                    TeamRow(name: g.homeName, record: g.homeRecord, color: g.homeColor),
                  ],
                ),
                MarketBox(
                  children: [
                    OddsRow(form: g.awayForm.moneyline, topLabel: g.odds['away_ml'] ?? '--'),
                    OddsRow(form: g.homeForm.moneyline, topLabel: g.odds['home_ml'] ?? '--'),
                  ],
                ),
                MarketBox(
                  children: [
                    OddsRow(
                      form: g.awayForm.spread,
                      topLabel: g.odds['away_spread'] ?? '--',
                      price: g.odds['away_spread'] != '--' ? g.odds['away_spread'] : null,
                    ),
                    OddsRow(
                      form: g.homeForm.spread,
                      topLabel: g.odds['home_spread'] ?? '--',
                      price: g.odds['home_spread'] != '--' ? g.odds['home_spread'] : null,
                    ),
                  ],
                ),
                MarketBox(
                  children: [
                    OddsRow(
                      form: g.totalOverForm,
                      topLabel: g.odds['over_odds'] != '' ? 'Over ${g.odds['total_line'] ?? 8.5}' : '--',
                      price: g.odds['over_odds'] != '' ? g.odds['over_odds'] : null,
                    ),
                  ],
                ),
                MarketBox(
                  children: [
                    OddsRow(
                      form: g.totalUnderForm,
                      topLabel: g.odds['under_odds'] != '' ? 'Under ${g.odds['total_line'] ?? 8.5}' : '--',
                      price: g.odds['under_odds'] != '' ? g.odds['under_odds'] : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: DSColors.deBorder)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Row(
                    children: [
                      const Text(
                        'PUBLIC BETTING',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: DSColors.deTextSecondary),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                        size: 16,
                        color: DSColors.deTextSecondary,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: widget.onMatchDetails ?? () {},
                  child: Row(
                    children: [
                      const Text(
                        'MATCH DETAILS',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: DSColors.deTextSecondary),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded, size: 16, color: DSColors.deTextSecondary),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_expanded)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: DSColors.deBorder))),
              child: const Text(
                'Public betting % breakdown goes here — wire to your betting-splits endpoint.',
                style: TextStyle(fontSize: 12, color: DSColors.deTextSecondary),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// MAIN GAMES SCREEN
// ============================================================================

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  String _activeSport = 'MLB';
  String _searchQuery = '';
  Map<String, Map<String, String>> _oddsMap = {};
  bool _loadingOdds = true;
  final List<String> _sportTabs = ['MLB', 'NBA', 'NCAAMB', 'Soccer', 'NHL'];

  @override
  void initState() {
    super.initState();
    _fetchOdds();
  }

  Future<void> _fetchOdds() async {
    if (mounted) setState(() => _loadingOdds = true);
    try {
      final odds = await OddsService.fetchMLBOdds();
      if (mounted) {
        setState(() {
          _oddsMap = odds;
          _loadingOdds = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingOdds = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final games = appState.games;

    final gameCards = games.map((g) {
      final odds = _oddsMap[g.gamePk.toString()] ?? {};
      return GameCardData.fromMLBGame(g, odds: odds);
    }).toList();

    final filtered = gameCards.where((g) {
      final query = _searchQuery.toLowerCase();
      if (query.isEmpty) return true;
      return g.awayName.toLowerCase().contains(query) ||
          g.homeName.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: DSColors.deBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      DSColors.deAccent.withOpacity(0.18),
                      DSColors.deBg,
                      DSColors.deClay.withOpacity(0.22),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Games (${filtered.length})',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: DSColors.deTextPrimary),
                        ),
                        const Spacer(),
                        if (_loadingOdds)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: DSColors.deAccent),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded, color: DSColors.deTextSecondary),
                            onPressed: _fetchOdds,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _sportTabs.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final tab = _sportTabs[index];
                          final isActive = _activeSport == tab;
                          return GestureDetector(
                            onTap: () => setState(() => _activeSport = tab),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: isActive ? DSColors.deAccent : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                tab,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isActive ? DSColors.deTextPrimary : DSColors.deTextSecondary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Today', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DSColors.deTextSecondary)),
                          const SizedBox(height: 2),
                          Text(
                            DateTime.now().toLocal().toString().substring(0, 10),
                            style: const TextStyle(fontSize: 11, color: DSColors.deTextSecondary),
                          ),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 200,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            prefixIcon: const Icon(Icons.search_rounded, size: 16),
                            filled: true,
                            fillColor: DSColors.deSurface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            hintStyle: const TextStyle(color: DSColors.deTextSecondary, fontSize: 13),
                          ),
                          onChanged: (value) => setState(() => _searchQuery = value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (filtered.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No games today. Check back later!', style: TextStyle(color: DSColors.deTextSecondary)),
                      ),
                    )
                  else
                    ...filtered.map((game) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GameCard(
                        key: ValueKey(game.id),
                        game: game,
                        onMatchDetails: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MatchDetailsScreen(
                                gamePk: int.parse(game.id),
                                awayTeam: game.awayName,
                                homeTeam: game.homeName,
                              ),
                            ),
                          );
                        },
                      ),
                    )),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
