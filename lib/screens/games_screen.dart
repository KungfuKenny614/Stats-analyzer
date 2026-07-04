import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stats_analyzer/providers/app_state.dart';
import 'package:stats_analyzer/design_system/tokens/colors.dart';
import 'package:stats_analyzer/design_system/tokens/spacing.dart';
import 'package:stats_analyzer/design_system/tokens/typography.dart';

class TeamFormRecord {
  final List<String> moneyline;
  final List<String> spread;
  final List<String> totalOver;
  final List<String> totalUnder;

  TeamFormRecord({
    required this.moneyline,
    required this.spread,
    required this.totalOver,
    required this.totalUnder,
  });

  factory TeamFormRecord.mock({required int games}) {
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    final bool isWinning = random > 30;
    return TeamFormRecord(
      moneyline: List.generate(games, (_) => isWinning && random % 2 == 0 ? 'W' : 'L'),
      spread: List.generate(games, (_) => !isWinning && random % 2 == 1 ? 'W' : 'L'),
      totalOver: List.generate(games, (_) => random % 3 == 0 ? 'W' : 'L'),
      totalUnder: List.generate(games, (_) => random % 3 == 1 ? 'W' : 'L'),
    );
  }
}

class TeamInfo {
  final String name;
  final String record;
  final String color;
  final TeamFormRecord form;

  TeamInfo({
    required this.name,
    required this.record,
    required this.color,
    required this.form,
  });
}

class GameOdds {
  final Map<String, String> moneyline;
  final Map<String, String> spread;
  final Map<String, String> totalOver;
  final Map<String, String> totalUnder;

  GameOdds({
    required this.moneyline,
    required this.spread,
    required this.totalOver,
    required this.totalUnder,
  });

  factory GameOdds.mock({required String away, required String home}) {
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    final awayOdds = random > 50 ? -110 + random % 50 : 100 + random % 50;
    final homeOdds = random > 50 ? -105 - random % 50 : 110 + random % 50;
    return GameOdds(
      moneyline: {
        'awayLabel': '${away}${awayOdds > 0 ? "+" : ""}$awayOdds',
        'homeLabel': '${home}${homeOdds > 0 ? "+" : ""}$homeOdds',
      },
      spread: {
        'awayLabel': '$away +1.5',
        'homeLabel': '$home -1.5',
        'awayPrice': awayOdds > 0 ? '+${awayOdds + 10}' : '${awayOdds - 10}',
        'homePrice': homeOdds > 0 ? '+${homeOdds - 10}' : '${homeOdds + 10}',
      },
      totalOver: {
        'label': 'Over 8.5',
        'price': '-110',
      },
      totalUnder: {
        'label': 'Under 8.5',
        'price': '-110',
      },
    );
  }
}

class GameCardData {
  final String id;
  final String startTime;
  final TeamInfo away;
  final TeamInfo home;
  final GameOdds odds;

  GameCardData({
    required this.id,
    required this.startTime,
    required this.away,
    required this.home,
    required this.odds,
  });
}

class FormBar extends StatelessWidget {
  final List<String> results;

  const FormBar({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    final wins = results.where((r) => r == 'W').length;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: results.map((r) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 0.5),
              decoration: BoxDecoration(
                color: r == 'W' ? DSColors.deWin : DSColors.deLoss,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class OddsCell extends StatelessWidget {
  final List<String> form;
  final String topLabel;
  final String? price;
  final String? sublabel;
  final VoidCallback? onTap;

  const OddsCell({
    super.key,
    required this.form,
    required this.topLabel,
    this.price,
    this.sublabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: DSColors.deSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: DSColors.deBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormBar(results: form),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  topLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: DSColors.deTextPrimary,
                  ),
                ),
                if (price != null)
                  Text(
                    price!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: DSColors.deTextSecondary,
                    ),
                  ),
              ],
            ),
            if (sublabel != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  sublabel!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: DSColors.deTextSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TeamRow extends StatelessWidget {
  final TeamInfo team;

  const TeamRow({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Color(int.parse(team.color.replaceFirst('#', ''), radix: 16) + 0xFF000000),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              team.name.substring(0, 2).toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              team.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: DSColors.deTextPrimary,
              ),
            ),
            Text(
              team.record,
              style: const TextStyle(
                fontSize: 11,
                color: DSColors.deTextSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class GameCard extends StatefulWidget {
  final GameCardData game;

  const GameCard({super.key, required this.game});

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
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: DSColors.deTextSecondary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TeamRow(team: g.away),
                          const SizedBox(height: 12),
                          TeamRow(team: g.home),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: OddsCell(
                                  form: g.away.form.moneyline,
                                  topLabel: g.odds.moneyline['awayLabel']!,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OddsCell(
                                  form: g.home.form.moneyline,
                                  topLabel: g.odds.moneyline['homeLabel']!,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OddsCell(
                                  form: g.away.form.spread,
                                  topLabel: g.odds.spread['awayLabel']!,
                                  price: g.odds.spread['awayPrice'],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OddsCell(
                                  form: g.home.form.spread,
                                  topLabel: g.odds.spread['homeLabel']!,
                                  price: g.odds.spread['homePrice'],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OddsCell(
                                  form: g.away.form.totalOver,
                                  topLabel: g.odds.totalOver['label']!,
                                  price: g.odds.totalOver['price'],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OddsCell(
                                  form: g.home.form.totalOver,
                                  topLabel: g.odds.totalOver['label']!,
                                  price: g.odds.totalOver['price'],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OddsCell(
                                  form: g.away.form.totalUnder,
                                  topLabel: g.odds.totalUnder['label']!,
                                  price: g.odds.totalUnder['price'],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OddsCell(
                                  form: g.home.form.totalUnder,
                                  topLabel: g.odds.totalUnder['label']!,
                                  price: g.odds.totalUnder['price'],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: DSColors.deBorder),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                  child: Row(
                    children: [
                      const Text(
                        'PUBLIC BETTING',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: DSColors.deTextSecondary,
                        ),
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
                  onTap: () {},
                  child: Row(
                    children: [
                      const Text(
                        'MATCH DETAILS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: DSColors.deTextSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: DSColors.deTextSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_expanded)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: DSColors.deBorder),
                ),
              ),
              child: const Text(
                'Public betting % breakdown goes here — wire to your betting-splits endpoint.',
                style: TextStyle(
                  fontSize: 12,
                  color: DSColors.deTextSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  String _activeSport = 'MLB';
  String _searchQuery = '';

  final List<String> _sportTabs = ['MLB', 'NBA', 'NCAAMB', 'Soccer', 'NHL'];

  List<GameCardData> _generateMockGames() {
    final teams = [
      ('Yankees', '#0C2340'),
      ('Red Sox', '#BD3039'),
      ('Dodgers', '#005A9C'),
      ('Padres', '#2F241D'),
      ('Astros', '#EB6E1F'),
      ('Rangers', '#003278'),
      ('Mets', '#002B5C'),
      ('Phillies', '#E8182A'),
      ('Cubs', '#0E3386'),
      ('Cardinals', '#C41E3A'),
    ];
    final records = ['48-32', '41-39', '55-26', '46-34', '44-36', '39-41', '43-38', '42-40', '50-30', '38-43'];
    final startTimes = ['6:30 PM', '7:05 PM', '8:10 PM', '9:15 PM', '4:05 PM'];

    final games = <GameCardData>[];
    final random = DateTime.now().millisecondsSinceEpoch % 1000;
    for (int i = 0; i < 8; i++) {
      final awayIdx = i % teams.length;
      final homeIdx = (i + 3) % teams.length;
      final away = teams[awayIdx];
      final home = teams[homeIdx];
      final awayRecord = records[awayIdx % records.length];
      final homeRecord = records[homeIdx % records.length];
      final formAway = TeamFormRecord.mock(games: 10);
      final formHome = TeamFormRecord.mock(games: 10);
      final odds = GameOdds.mock(away: away.$1, home: home.$1);

      games.add(GameCardData(
        id: 'g$i',
        startTime: startTimes[i % startTimes.length],
        away: TeamInfo(
          name: away.$1,
          record: awayRecord,
          color: away.$2,
          form: formAway,
        ),
        home: TeamInfo(
          name: home.$1,
          record: homeRecord,
          color: home.$2,
          form: formHome,
        ),
        odds: odds,
      ));
    }
    return games;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final mockGames = _generateMockGames();

    final filtered = mockGames.where((g) {
      final query = _searchQuery.toLowerCase();
      if (query.isEmpty) return true;
      return g.away.name.toLowerCase().contains(query) ||
          g.home.name.toLowerCase().contains(query);
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
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Games',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: DSColors.deTextPrimary,
                      ),
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
                            onTap: () {
                              setState(() {
                                _activeSport = tab;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: isActive
                                        ? DSColors.deAccent
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                tab,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? DSColors.deTextPrimary
                                      : DSColors.deTextSecondary,
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
                          const Text(
                            'Today',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: DSColors.deTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateTime.now().toLocal().toString().substring(0, 10),
                            style: const TextStyle(
                              fontSize: 11,
                              color: DSColors.deTextSecondary,
                            ),
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
                            hintStyle: const TextStyle(
                              color: DSColors.deTextSecondary,
                              fontSize: 13,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...filtered.map((game) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GameCard(game: game),
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
