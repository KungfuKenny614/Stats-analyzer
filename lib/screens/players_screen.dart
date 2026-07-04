import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stats_analyzer/design_system/tokens/colors.dart';
import 'package:stats_analyzer/design_system/tokens/spacing.dart';
import 'package:stats_analyzer/design_system/tokens/typography.dart';
import 'package:stats_analyzer/providers/app_state.dart';
import 'package:stats_analyzer/models/mlb_outlier_models.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  // Filter state
  String _selectedMarket = 'Hits';
  String _selectedLine = '0.5';
  String _selectedGame = 'All Games (13)';
  String _probabilityTier = 'All Tiers';
  String _sortBy = 'Best Hit Rate';

  // Sample data – we'll generate from markets
  List<PropHitRate> _props = [];

  @override
  void initState() {
    super.initState();
    _loadProps();
  }

  void _loadProps() {
    // In a real app, we'd compute hit rates from actual game logs.
    // For now, we'll generate synthetic data.
    _props = generateSampleProps();
    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort() {
    // Apply filters and sorting, then call setState
    setState(() {
      // We'll re-filter each build for simplicity
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final filtered = _getFilteredProps(appState);

    return Scaffold(
      backgroundColor: DSColors.background,
      appBar: AppBar(
        title: const Text('Player Props'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: _buildFilters(),
        ),
      ),
      body: _buildPropList(filtered),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.lg, vertical: DSSpacing.sm),
      color: DSColors.surface,
      child: Wrap(
        spacing: DSSpacing.md,
        runSpacing: DSSpacing.sm,
        children: [
          _buildDropdown('Market', ['Hits', 'Total Bases', 'Home Runs', 'RBI'], _selectedMarket, (v) => _selectedMarket = v!),
          _buildDropdown('Line', ['0.5', '1.5', '2.5'], _selectedLine, (v) => _selectedLine = v!),
          _buildDropdown('Game', ['All Games (13)', 'LAD vs NYY', 'ATL vs PHI'], _selectedGame, (v) => _selectedGame = v!),
          _buildDropdown('Probability Tier', ['All Tiers', 'High', 'Mid', 'Low'], _probabilityTier, (v) => _probabilityTier = v!),
          _buildDropdown('Sort By', ['Best Hit Rate', 'Player Name', 'Team'], _sortBy, (v) => _sortBy = v!),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String selected, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: DSColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: selected,
        underline: const SizedBox(),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildPropList(List<PropHitRate> props) {
    if (props.isEmpty) {
      return const Center(child: Text('No props match the filters.'));
    }

    // Group by game? We'll just show a flat list.
    return ListView.builder(
      padding: const EdgeInsets.all(DSSpacing.lg),
      itemCount: props.length,
      itemBuilder: (context, index) {
        final p = props[index];
        return _buildPropRow(p);
      },
    );
  }

  Widget _buildPropRow(PropHitRate p) {
    final tier = _getTier(p.hitRate);
    final tierColor = tier == 'High' ? DSColors.positive : tier == 'Mid' ? DSColors.warning : DSColors.negative;
    return Container(
      margin: const EdgeInsets.only(bottom: DSSpacing.sm),
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: DSColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DSColors.border.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Player & team
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DSColors.infoSurface,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    p.playerName.split(' ').map((e) => e[0]).join(''),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: DSColors.info),
                  ),
                ),
              ),
              const SizedBox(width: DSSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.playerName, style: DSTypography.bodyMD.copyWith(fontWeight: FontWeight.w600)),
                    Text('${p.team} @ ${p.opponent}', style: DSTypography.caption),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: tierColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: tierColor.withOpacity(0.3)),
                ),
                child: Text(
                  tier,
                  style: TextStyle(color: tierColor, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          // Market & Line
          Text(
            '${p.market} O${p.line.toStringAsFixed(1)}',
            style: DSTypography.labelStrong,
          ),
          const SizedBox(height: DSSpacing.sm),
          // Hit rate columns
          Row(
            children: [
              _buildHitRateChip('L5', p.l5Rate, p.l5Count),
              _buildHitRateChip('L10', p.l10Rate, p.l10Count),
              _buildHitRateChip('L20', p.l20Rate, p.l20Count),
              _buildHitRateChip('H2H', p.h2hRate, p.h2hCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHitRateChip(String label, double rate, int count) {
    final color = rate >= 0.7 ? DSColors.positive : rate >= 0.5 ? DSColors.warning : DSColors.negative;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withOpacity(0.2), width: 0.5),
        ),
        child: Column(
          children: [
            Text(
              '${(rate * 100).toInt()}%',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
            ),
            Text(
              '$count/5',
              style: DSTypography.caption.copyWith(fontSize: 10, color: DSColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  String _getTier(double hitRate) {
    if (hitRate >= 0.7) return 'High';
    if (hitRate >= 0.5) return 'Mid';
    return 'Low';
  }

  List<PropHitRate> _getFilteredProps(AppState appState) {
    // In a real app, we'd use the actual markets and compute hit rates from stats.
    // We'll just return the generated sample props and apply filters.
    var list = _props;
    // Apply market filter
    if (_selectedMarket != 'All') {
      list = list.where((p) => p.market == _selectedMarket).toList();
    }
    // Line filter
    if (_selectedLine != 'All') {
      final lineVal = double.tryParse(_selectedLine);
      if (lineVal != null) {
        list = list.where((p) => (p.line - lineVal).abs() < 0.01).toList();
      }
    }
    // Game filter
    if (_selectedGame != 'All Games (13)') {
      list = list.where((p) => p.gameLabel == _selectedGame).toList();
    }
    // Probability tier
    if (_probabilityTier != 'All Tiers') {
      list = list.where((p) {
        final tier = _getTier(p.hitRate);
        return tier == _probabilityTier;
      }).toList();
    }
    // Sorting
    if (_sortBy == 'Best Hit Rate') {
      list.sort((a, b) => b.hitRate.compareTo(a.hitRate));
    } else if (_sortBy == 'Player Name') {
      list.sort((a, b) => a.playerName.compareTo(b.playerName));
    } else if (_sortBy == 'Team') {
      list.sort((a, b) => a.team.compareTo(b.team));
    }
    return list;
  }

  // ============================================================================
  // Sample Data Generation
  // ============================================================================

  List<PropHitRate> generateSampleProps() {
    final players = [
      'Alex Babin', 'Moisés Betts', 'Téocarr Hernández', 'Jo Adell',
      'Andrew McCutchen', 'Jordan Alvarado', 'Christian Villanueva',
      'Darnell Nurse', 'Francisco Lindor'
    ];
    final teams = ['MIA', 'LAC', 'LAC', 'LAA', 'PIT', 'HOU', 'KC', 'CHC', 'OAK'];
    final opponents = ['PHI', 'MIL', 'MIL', 'TOR', 'SD', 'TB', 'MIN', 'CLE', 'NYM'];
    final gameLabels = [
      'MIA @ PHI', 'LAC @ MIL', 'LAC @ MIL', 'TOR @ LAA',
      'PIT @ SD', 'HOU @ TB', 'KC @ MIN', 'CHC @ CLE', 'OAK @ NYM'
    ];
    final markets = ['Hits', 'Hits', 'Hits', 'Hits', 'Hits', 'Hits', 'Hits', 'Hits', 'Hits'];
    final lines = [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5];
    final random = Random(42);

    return List.generate(players.length, (i) {
      // Generate some random hit rates with a bias toward high values
      double base = 0.5 + random.nextDouble() * 0.3;
      double l5 = (base + random.nextDouble() * 0.2).clamp(0.0, 1.0);
      double l10 = (base + random.nextDouble() * 0.15).clamp(0.0, 1.0);
      double l20 = (base + random.nextDouble() * 0.1).clamp(0.0, 1.0);
      double h2h = (base + random.nextDouble() * 0.25).clamp(0.0, 1.0);

      // Counts: 5/5, 8/10, etc.
      int l5Count = (l5 * 5).round();
      int l10Count = (l10 * 10).round();
      int l20Count = (l20 * 20).round();
      int h2hCount = (h2h * 5).round();

      return PropHitRate(
        playerName: players[i],
        team: teams[i],
        opponent: opponents[i],
        gameLabel: gameLabels[i],
        market: markets[i],
        line: lines[i],
        hitRate: (l5 + l10 + l20 + h2h) / 4, // overall for tier
        l5Rate: l5,
        l5Count: l5Count,
        l10Rate: l10,
        l10Count: l10Count,
        l20Rate: l20,
        l20Count: l20Count,
        h2hRate: h2h,
        h2hCount: h2hCount,
      );
    });
  }
}

class PropHitRate {
  final String playerName;
  final String team;
  final String opponent;
  final String gameLabel;
  final String market;
  final double line;
  final double hitRate; // overall
  final double l5Rate;
  final int l5Count;
  final double l10Rate;
  final int l10Count;
  final double l20Rate;
  final int l20Count;
  final double h2hRate;
  final int h2hCount;

  PropHitRate({
    required this.playerName,
    required this.team,
    required this.opponent,
    required this.gameLabel,
    required this.market,
    required this.line,
    required this.hitRate,
    required this.l5Rate,
    required this.l5Count,
    required this.l10Rate,
    required this.l10Count,
    required this.l20Rate,
    required this.l20Count,
    required this.h2hRate,
    required this.h2hCount,
  });
}
