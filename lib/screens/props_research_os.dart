import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stats_analyzer/models/props_explorer_db.dart';
import 'package:stats_analyzer/services/props_research_service.dart';
import 'package:stats_analyzer/config/theme.dart';

class PropsResearchOS extends StatefulWidget {
  const PropsResearchOS({super.key});

  @override
  State<PropsResearchOS> createState() => _PropsResearchOSState();
}

class _PropsResearchOSState extends State<PropsResearchOS> {
  final PropsResearchService _service = PropsResearchService();
  
  // State
  List<Player> _players = [];
  List<Player> _filteredPlayers = [];
  PropResearch? _selectedResearch;
  String _searchQuery = '';
  String _selectedMarket = 'Points';
  String _selectedSport = 'NBA';
  String _selectedBook = 'All';
  double _minEdge = 0;
  bool _showOnlyValue = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _players = _service.getPlayers();
    _filteredPlayers = _players;
    if (_players.isNotEmpty) {
      _selectPlayer(_players.first);
    }
  }

  void _selectPlayer(Player player) {
    setState(() {
      _selectedResearch = _service.getPropResearch(player.id, _selectedMarket);
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredPlayers = _players.where((p) {
        final matchSearch = _searchQuery.isEmpty ||
            p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.team.toLowerCase().contains(_searchQuery.toLowerCase());
        
        if (_showOnlyValue && _selectedResearch != null) {
          final edge = _selectedResearch!.edge;
          return matchSearch && edge > 3;
        }
        
        return matchSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 Props Research OS'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _buildSearchBar(),
        ),
      ),
      body: Row(
        children: [
          // LEFT SIDEBAR - Player List
          Container(
            width: 320,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                _buildFilters(),
                Expanded(
                  child: _buildPlayerList(),
                ),
              ],
            ),
          ),
          // MAIN CONTENT - Research Detail
          Expanded(
            flex: 3,
            child: _selectedResearch == null
                ? const Center(child: Text('Select a player'))
                : _buildResearchDetail(_selectedResearch!),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // SEARCH BAR
  // ============================================================================

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: '🔍 Search players, teams...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true,
                fillColor: Colors.grey.shade100,
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applyFilters();
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _selectedMarket,
              isDense: true,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'Points', child: Text('Points')),
                DropdownMenuItem(value: 'Rebounds', child: Text('Rebounds')),
                DropdownMenuItem(value: 'Assists', child: Text('Assists')),
                DropdownMenuItem(value: 'PRA', child: Text('PRA')),
                DropdownMenuItem(value: '3PM', child: Text('3PM')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedMarket = value;
                    if (_selectedResearch != null) {
                      _selectedResearch = _service.getPropResearch(
                        _selectedResearch!.player.id,
                        _selectedMarket,
                      );
                    }
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // FILTERS
  // ============================================================================

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('League: '),
              const SizedBox(width: 8),
              _buildFilterChip('NBA', true),
              const SizedBox(width: 4),
              _buildFilterChip('NFL', false),
              const SizedBox(width: 4),
              _buildFilterChip('MLB', false),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Edge: '),
              Expanded(
                child: Slider(
                  min: 0,
                  max: 10,
                  divisions: 20,
                  value: _minEdge,
                  onChanged: (value) {
                    setState(() {
                      _minEdge = value;
                    });
                  },
                ),
              ),
              Text('${_minEdge.toStringAsFixed(1)}%'),
            ],
          ),
          Row(
            children: [
              Checkbox(
                value: _showOnlyValue,
                onChanged: (value) {
                  setState(() {
                    _showOnlyValue = value ?? false;
                    _applyFilters();
                  });
                },
              ),
              const Text('Show only EV+'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      selected: selected,
      onSelected: (_) {},
      selectedColor: AppTheme.primary.withOpacity(0.1),
      checkmarkColor: AppTheme.primary,
    );
  }

  // ============================================================================
  // PLAYER LIST
  // ============================================================================

  Widget _buildPlayerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _filteredPlayers.length,
      itemBuilder: (context, index) {
        final player = _filteredPlayers[index];
        final isSelected = _selectedResearch?.player.id == player.id;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            dense: true,
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  player.name.split(' ').map((e) => e[0]).join(''),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            title: Text(
              player.name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '${player.team} · ${player.position}',
              style: const TextStyle(fontSize: 10),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: player.status == 'Active' 
                    ? Colors.green.withOpacity(0.1) 
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                player.status == 'Active' ? '✅' : '⚠️',
                style: const TextStyle(fontSize: 10),
              ),
            ),
            onTap: () => _selectPlayer(player),
          ),
        );
      },
    );
  }

  // ============================================================================
  // RESEARCH DETAIL
  // ============================================================================

  Widget _buildResearchDetail(PropResearch research) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Player Header
          _buildPlayerHeader(research),
          const SizedBox(height: 16),
          
          // Main Stats Row
          _buildStatsRow(research),
          const SizedBox(height: 16),
          
          // Projection Card
          _buildProjectionCard(research),
          const SizedBox(height: 16),
          
          // Odds Comparison
          _buildOddsComparison(research),
          const SizedBox(height: 16),
          
          // Line Movement Chart
          _buildLineMovementChart(research),
          const SizedBox(height: 16),
          
          // Game Log
          _buildGameLog(research),
          const SizedBox(height: 16),
          
          // Splits
          _buildSplits(research),
          const SizedBox(height: 16),
          
          // Hit Rate
          _buildHitRate(research),
          const SizedBox(height: 16),
          
          // AI Insight
          _buildAIInsight(research),
        ],
      ),
    );
  }

  // ============================================================================
  // PLAYER HEADER
  // ============================================================================

  Widget _buildPlayerHeader(PropResearch research) {
    final player = research.player;
    final game = research.game;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                player.name.split(' ').map((e) => e[0]).join(''),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${player.team} @ ${game.awayTeam}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    research.market.marketType,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: research.recommendationColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: research.recommendationColor.withOpacity(0.3),
              ),
            ),
            child: Text(
              research.recommendationDisplay,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: research.recommendationColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // STATS ROW
  // ============================================================================

  Widget _buildStatsRow(PropResearch research) {
    return Row(
      children: [
        _buildStatCard('Projected', research.projectedValue.toStringAsFixed(1)),
        _buildStatCard('Market', research.marketLine.toStringAsFixed(1)),
        _buildStatCard('Difference', 
          '${research.difference > 0 ? "+" : ""}${research.difference.toStringAsFixed(1)}',
          color: research.difference > 0 ? Colors.green : Colors.red,
        ),
        _buildStatCard('Edge', research.edgeDisplay,
          color: research.edge > 3 ? Colors.green : research.edge > 1 ? Colors.orange : Colors.red,
        ),
        _buildStatCard('Confidence', '${(research.projection.confidence * 100).toInt()}%'),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, {Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color ?? Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // PROJECTION CARD
  // ============================================================================

  Widget _buildProjectionCard(PropResearch research) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Projection',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProjectionItem('Model', research.projectedValue.toStringAsFixed(1)),
              _buildProjectionItem('Sportsbook', research.marketLine.toStringAsFixed(1)),
              _buildProjectionItem('Edge', research.edgeDisplay),
              _buildProjectionItem('Confidence', '${(research.projection.confidence * 100).toInt()}%'),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Recommendation: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  research.recommendationDisplay,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: research.recommendationColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectionItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // ODDS COMPARISON
  // ============================================================================

  Widget _buildOddsComparison(PropResearch research) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💰 Odds Comparison',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.5),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                children: [
                  _buildTableHeader('Sportsbook'),
                  _buildTableHeader('Line'),
                  _buildTableHeader('Over'),
                  _buildTableHeader('Under'),
                ],
              ),
              ...research.competingOdds.map((odds) {
                return TableRow(
                  children: [
                    _buildTableCell(odds.sportsbookId),
                    _buildTableCell(odds.line.toStringAsFixed(1)),
                    _buildTableCell(
                      odds.overOdds.toString(),
                      color: odds.overOdds < 0 ? Colors.red : Colors.green,
                    ),
                    _buildTableCell(
                      odds.underOdds.toString(),
                      color: odds.underOdds < 0 ? Colors.red : Colors.green,
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOddsTag('🏆 Best Over', '-115'),
              _buildOddsTag('🎯 Best Under', '-105'),
              _buildOddsTag('📊 Lowest Vig', '3.5%'),
              _buildOddsTag('📈 Fastest Moving', 'DraftKings'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: color ?? Colors.black,
          fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildOddsTag(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // LINE MOVEMENT CHART
  // ============================================================================

  Widget _buildLineMovementChart(PropResearch research) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📈 Line Movement',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 0.5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = ['8AM', '11AM', '2PM', '5PM', '7PM'];
                        if (value >= 0 && value < labels.length) {
                          return Text(
                            labels[value.toInt()],
                            style: const TextStyle(fontSize: 8),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 20,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: research.oddsHistory.asMap().entries.map((entry) {
                      final index = entry.key;
                      final history = entry.value;
                      return FlSpot(
                        index.toDouble(),
                        history.line,
                      );
                    }).toList(),
                    isCurved: true,
                    color: AppTheme.primary,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primary.withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.black87,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.spotIndex;
                        final history = research.oddsHistory[index];
                        return LineTooltipItem(
                          '${history.timestamp.hour}:${history.timestamp.minute.toString().padLeft(2, '0')}\n${history.line.toStringAsFixed(1)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Open: ${research.oddsHistory.first.line.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                'Current: ${research.oddsHistory.last.line.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (research.oddsHistory.last.line - research.oddsHistory.first.line) > 0
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(research.oddsHistory.last.line - research.oddsHistory.first.line) > 0 ? "+" : ""}${(research.oddsHistory.last.line - research.oddsHistory.first.line).toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: (research.oddsHistory.last.line - research.oddsHistory.first.line) > 0
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // GAME LOG
  // ============================================================================

  Widget _buildGameLog(PropResearch research) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📋 Game Log (Last 20 Games)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 12,
              columns: const [
                DataColumn(label: Text('Date', style: TextStyle(fontSize: 10))),
                DataColumn(label: Text('Opp', style: TextStyle(fontSize: 10))),
                DataColumn(label: Text('Min', style: TextStyle(fontSize: 10))),
                DataColumn(label: Text('Pts', style: TextStyle(fontSize: 10))),
                DataColumn(label: Text('Reb', style: TextStyle(fontSize: 10))),
                DataColumn(label: Text('Ast', style: TextStyle(fontSize: 10))),
              ],
              rows: research.stats.take(10).map((stat) {
                final isHit = stat.points > research.market.line;
                return DataRow(
                  color: WidgetStateProperty.resolveWith(
                    (_) => isHit 
                        ? Colors.green.withOpacity(0.05) 
                        : Colors.red.withOpacity(0.05),
                  ),
                  cells: [
                    DataCell(Text(
                      '${stat.date.month}/${stat.date.day}',
                      style: const TextStyle(fontSize: 11),
                    )),
                    DataCell(Text(stat.opponent, style: const TextStyle(fontSize: 11))),
                    DataCell(Text(stat.minutes.toString(), style: const TextStyle(fontSize: 11))),
                    DataCell(Text(
                      stat.points.toString(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isHit ? Colors.green : Colors.red,
                      ),
                    )),
                    DataCell(Text(stat.rebounds.toString(), style: const TextStyle(fontSize: 11))),
                    DataCell(Text(stat.assists.toString(), style: const TextStyle(fontSize: 11))),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // SPLITS
  // ============================================================================

  Widget _buildSplits(PropResearch research) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Splits',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSplitItem('Home', research.splits['Home'] ?? 0),
              _buildSplitItem('Away', research.splits['Away'] ?? 0),
              _buildSplitItem('vs Winning', research.splits['vs Winning'] ?? 0),
              _buildSplitItem('vs Losing', research.splits['vs Losing'] ?? 0),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSplitItem('Back-to-Back', research.splits['Back-to-Back'] ?? 0),
              _buildSplitItem('1 Day Rest', research.splits['1 Day Rest'] ?? 0),
              _buildSplitItem('Last 5', research.splits['Last 5'] ?? 0),
              _buildSplitItem('Last 10', research.splits['Last 10'] ?? 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSplitItem(String label, double value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          value.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // HIT RATE
  // ============================================================================

  Widget _buildHitRate(PropResearch research) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎯 Hit Rate',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHitRateItem('Last 5', 5, 5),
              _buildHitRateItem('Last 10', 8, 10),
              _buildHitRateItem('Season', 34, 48),
              _buildHitRateItem('Home', 18, 22),
              _buildHitRateItem('Away', 16, 26),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHitRateItem(String label, int hits, int attempts) {
    final rate = hits / attempts;
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          '$hits/$attempts',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${(rate * 100).toInt()}%',
          style: TextStyle(
            fontSize: 11,
            color: rate > 0.6 ? Colors.green : Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // AI INSIGHT
  // ============================================================================

  Widget _buildAIInsight(PropResearch research) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                '🧠 AI Insight',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            research.insight,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
