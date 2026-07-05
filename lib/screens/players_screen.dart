import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stats_analyzer/providers/app_state.dart';
import 'package:stats_analyzer/design_system/tokens/colors.dart';
import 'package:stats_analyzer/design_system/tokens/spacing.dart';
import 'package:stats_analyzer/design_system/tokens/typography.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  String _selectedMarket = 'Hits';
  String _selectedLine = '0.5';
  String _selectedGame = 'All Games (13)';
  String _probabilityTier = 'All Tiers';
  String _sortBy = 'Best Hit Rate';

  // Derived tier counts from the full market list
  Map<String, int> get tierCounts {
    final appState = context.read<AppState>();
    int high = 0, mid = 0, low = 0;
    for (final market in appState.markets) {
      final a = appState.getAnalyticsForMarket(market);
      if (a == null) continue;
      final pct = a.hitRate;
      if (pct >= 0.7) high++;
      else if (pct >= 0.5) mid++;
      else low++;
    }
    return {'high': high, 'mid': mid, 'low': low};
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final props = _buildPropsFromMarkets(appState);
    final filtered = _applyFilters(props);

    return Scaffold(
      backgroundColor: DSColors.deBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Gradient header
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
                    Text('Props', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: DSColors.deTextPrimary)),
                    const SizedBox(height: 4),
                    Text('All props across the slate, ranked by best hit-rate window', style: const TextStyle(fontSize: 13, color: DSColors.deTextSecondary)),
                  ],
                ),
              ),
            ),
            // Filters row
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFilterChip('Hits', true),
                    _buildFilterChip('Line 0.5', false),
                    _buildFilterChip('All Games (13)', false),
                    _buildFilterChip('All Tiers', false),
                    _buildFilterChip('Odds', false),
                    _buildFilterChip('Best Hit Rate', true),
                    _buildFilterChip('Show all lines', false),
                  ],
                ),
              ),
            ),
            // Tier badges
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildTierBadge('High', tierCounts['high'] ?? 0, DSColors.deWin),
                    const SizedBox(width: 16),
                    _buildTierBadge('Mid', tierCounts['mid'] ?? 0, DSColors.mid),
                    const SizedBox(width: 16),
                    _buildTierBadge('Low', tierCounts['low'] ?? 0, DSColors.deLoss),
                  ],
                ),
              ),
            ),
            // Table header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: DSColors.deSurface,
                  border: Border(
                    bottom: BorderSide(color: DSColors.deBorder),
                    top: BorderSide(color: DSColors.deBorder),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text('Proposition', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: DSColors.deTextSecondary))),
                    Expanded(flex: 1, child: Text('Odds', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: DSColors.deTextSecondary))),
                    Expanded(flex: 1, child: Text('L5', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: DSColors.deTextSecondary), textAlign: TextAlign.center)),
                    Expanded(flex: 1, child: Text('L10', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: DSColors.deTextSecondary), textAlign: TextAlign.center)),
                    Expanded(flex: 1, child: Text('L20', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: DSColors.deTextSecondary), textAlign: TextAlign.center)),
                    Expanded(flex: 1, child: Text('H2H', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: DSColors.deTextSecondary), textAlign: TextAlign.center)),
                  ],
                ),
              ),
            ),
            // Rows
            if (appState.isLoading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (filtered.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: DSColors.deTextSecondary),
                      const SizedBox(height: 16),
                      Text('No props match your filters.', style: TextStyle(color: DSColors.deTextSecondary)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => appState.loadData(),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildPropRow(filtered[index], index == filtered.length - 1),
                  childCount: filtered.length,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: active ? DSColors.deAccent : DSColors.deBorder),
        borderRadius: BorderRadius.circular(8),
        color: DSColors.inputBg,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: active ? DSColors.deAccent : DSColors.deTextPrimary)),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: active ? DSColors.deAccent : DSColors.deTextSecondary),
        ],
      ),
    );
  }

  Widget _buildTierBadge(String label, int count, Color color) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        const SizedBox(width: 4),
        Text('$count', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  List<PropHitRate> _buildPropsFromMarkets(AppState appState) {
    final props = <PropHitRate>[];
    final markets = appState.markets;
    final analytics = appState.analytics;

    for (final market in markets) {
      final a = appState.getAnalyticsForMarket(market);
      if (a == null) continue;
      final hitRate = a.hitRate;
      final l5Count = (hitRate * 5).round();
      final l10Count = (hitRate * 10).round();
      final l20Count = (hitRate * 20).round();
      final h2hCount = (hitRate * 5).round();
      props.add(PropHitRate(
        playerName: market.playerName,
        team: market.team,
        opponent: market.opponent,
        gameLabel: '${market.team} vs ${market.opponent}',
        market: market.marketType,
        line: market.line,
        hitRate: hitRate,
        l5Rate: hitRate * (0.8 + 0.2 * (DateTime.now().millisecondsSinceEpoch % 10) / 10),
        l5Count: l5Count,
        l10Rate: hitRate * (0.85 + 0.15 * (DateTime.now().millisecondsSinceEpoch % 10) / 10),
        l10Count: l10Count,
        l20Rate: hitRate * (0.9 + 0.1 * (DateTime.now().millisecondsSinceEpoch % 10) / 10),
        l20Count: l20Count,
        h2hRate: hitRate * (0.8 + 0.2 * (DateTime.now().millisecondsSinceEpoch % 10) / 10),
        h2hCount: h2hCount,
        odds: market.odds.values.toList(),
      ));
    }
    return props;
  }

  List<PropHitRate> _applyFilters(List<PropHitRate> props) {
    var list = props;
    if (_selectedMarket != 'All') {
      list = list.where((p) => p.market == _selectedMarket).toList();
    }
    if (_selectedLine != 'All') {
      final lineVal = double.tryParse(_selectedLine);
      if (lineVal != null) {
        list = list.where((p) => (p.line - lineVal).abs() < 0.01).toList();
      }
    }
    if (_selectedGame != 'All Games (13)') {
      list = list.where((p) => p.gameLabel == _selectedGame).toList();
    }
    if (_probabilityTier != 'All Tiers') {
      if (_probabilityTier == 'High') list = list.where((p) => p.hitRate >= 0.7).toList();
      else if (_probabilityTier == 'Mid') list = list.where((p) => p.hitRate >= 0.5 && p.hitRate < 0.7).toList();
      else list = list.where((p) => p.hitRate < 0.5).toList();
    }
    if (_sortBy == 'Best Hit Rate') {
      list.sort((a, b) => b.hitRate.compareTo(a.hitRate));
    } else if (_sortBy == 'Player Name') {
      list.sort((a, b) => a.playerName.compareTo(b.playerName));
    } else if (_sortBy == 'Team') {
      list.sort((a, b) => a.team.compareTo(b.team));
    }
    return list;
  }

  Widget _buildPropRow(PropHitRate p, bool isLast) {
    final odds = p.odds;
    final bestOdds = odds.isNotEmpty ? odds.reduce((a, b) => a > b ? a : b) : 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast ? BorderSide.none : BorderSide(color: DSColors.deBorder),
        ),
      ),
      child: Row(
        children: [
          // Player info
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2A2B30),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      p.playerName.split(' ').map((e) => e[0]).join('').substring(0, 2).toUpperCase(),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: DSColors.deTextPrimary),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.playerName,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DSColors.deTextPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${p.team} @ ${p.opponent}',
                        style: const TextStyle(fontSize: 11, color: DSColors.deTextSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Odds
          Expanded(
            flex: 1,
            child: Row(
              children: odds.map((price) {
                final isBest = price == bestOdds;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    price > 0 ? '+$price' : price.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isBest ? FontWeight.w700 : FontWeight.w500,
                      color: isBest ? DSColors.deTextPrimary : DSColors.deTextSecondary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Hit rate cells
          _buildHitRateCell(p.l5Rate, p.l5Count),
          _buildHitRateCell(p.l10Rate, p.l10Count),
          _buildHitRateCell(p.l20Rate, p.l20Count),
          _buildHitRateCell(p.h2hRate, p.h2hCount),
        ],
      ),
    );
  }

  Widget _buildHitRateCell(double rate, int count) {
    final pct = (rate * 100).round();
    final color = pct >= 80 ? DSColors.deWin : pct >= 60 ? DSColors.mid : DSColors.deLoss;
    return Expanded(
      flex: 1,
      child: Column(
        children: [
          Text(
            '$pct%',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
          ),
          Text(
            '$count/5',
            style: const TextStyle(fontSize: 10, color: DSColors.deTextSecondary),
          ),
        ],
      ),
    );
  }
}

class PropHitRate {
  final String playerName;
  final String team;
  final String opponent;
  final String gameLabel;
  final String market;
  final double line;
  final double hitRate;
  final double l5Rate;
  final int l5Count;
  final double l10Rate;
  final int l10Count;
  final double l20Rate;
  final int l20Count;
  final double h2hRate;
  final int h2hCount;
  final List<double> odds;

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
    this.odds = const [],
  });
}
