import 'package:flutter/material.dart';
import 'package:stats_analyzer/models/prop_explorer.dart';
import 'package:stats_analyzer/services/prop_explorer_service.dart';
import 'package:stats_analyzer/config/theme.dart';
import 'package:fl_chart/fl_chart.dart';

class PropExplorerScreen extends StatefulWidget {
  const PropExplorerScreen({super.key});

  @override
  State<PropExplorerScreen> createState() => _PropExplorerScreenState();
}

class _PropExplorerScreenState extends State<PropExplorerScreen> {
  final PropExplorerService _service = PropExplorerService();
  List<PropExplorer> _props = [];
  List<PropExplorer> _filteredProps = [];
  
  // Filter state
  String _searchQuery = '';
  String _statType = '';
  double _minEV = 0;
  double _minHitRate = 0;
  String _sortBy = 'ev';
  bool _sortAscending = false;
  
  // Selected prop for detail view
  PropExplorer? _selectedProp;

  @override
  void initState() {
    super.initState();
    _loadProps();
  }

  void _loadProps() {
    _props = _service.generateSampleProps();
    _applyFilters();
  }

  void _applyFilters() {
    _filteredProps = _service.filterProps(
      props: _props,
      searchQuery: _searchQuery,
      statType: _statType.isNotEmpty ? _statType : null,
      minEV: _minEV > 0 ? _minEV : null,
      minHitRate: _minHitRate > 0 ? _minHitRate : null,
    );
    
    _filteredProps = _service.sortProps(
      props: _filteredProps,
      sortBy: _sortBy,
      ascending: _sortAscending,
    );
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statTypes = _props.map((p) => p.statType).toSet().toList();
    statTypes.insert(0, 'All');

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 Prop Research Explorer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadProps,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
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
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _statType.isEmpty ? 'All' : _statType,
                  onChanged: (value) {
                    _statType = value == 'All' ? '' : value!;
                    _applyFilters();
                  },
                  items: statTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Row(
        children: [
          // Main list
          Expanded(
            flex: 3,
            child: _filteredProps.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _filteredProps.length,
                    itemBuilder: (context, index) {
                      final prop = _filteredProps[index];
                      return _buildPropCard(prop, theme);
                    },
                  ),
          ),
          // Detail panel
          if (_selectedProp != null)
            Expanded(
              flex: 2,
              child: _buildDetailPanel(_selectedProp!, theme),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No props found matching your filters',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPropCard(PropExplorer prop, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedProp = _selectedProp?.id == prop.id ? null : prop;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Player initials
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    prop.playerName.split(' ').map((e) => e[0]).join(''),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Player info
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prop.playerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${prop.team} · ${prop.position}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Stat & Line
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prop.statType,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Line: ${prop.line.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Hit Rate
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: prop.isHot ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      prop.hitRateDisplay,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: prop.isHot ? Colors.green : Colors.grey,
                      ),
                    ),
                    Text(
                      'Hit Rate',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // EV
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: prop.ev > 3 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      prop.evDisplay,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: prop.ev > 3 ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      'EV',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (prop.isValue)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '🔥 VALUE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailPanel(PropExplorer prop, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          left: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    prop.playerName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    setState(() {
                      _selectedProp = null;
                    });
                  },
                ),
              ],
            ),
            Text(
              '${prop.team} · ${prop.position}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            
            // Quick stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickStat('Stat', prop.statType),
                _buildQuickStat('Line', prop.line.toStringAsFixed(1)),
                _buildQuickStat('Hit Rate', prop.hitRateDisplay),
                _buildQuickStat('EV', prop.evDisplay),
              ],
            ),
            const SizedBox(height: 16),
            
            // Hit Rate Visualization (Last 10)
            _buildHitRateChart(prop),
            const SizedBox(height: 16),
            
            // Splits
            _buildSplitsSection(prop),
            const SizedBox(height: 16),
            
            // Matchup
            _buildMatchupSection(prop),
            const SizedBox(height: 16),
            
            // Injury Context
            _buildInjurySection(prop),
            const SizedBox(height: 16),
            
            // Usage Trend
            _buildUsageTrend(prop),
            const SizedBox(height: 16),
            
            // Book Odds
            _buildBookOdds(prop),
            const SizedBox(height: 16),
            
            // Recommendation
            _buildRecommendation(prop),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHitRateChart(PropExplorer prop) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Last 10 Games',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
                        if (value >= 0 && value < labels.length) {
                          return Text(
                            labels[value.toInt()],
                            style: const TextStyle(fontSize: 8),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 16,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                barGroups: prop.history.asMap().entries.map((entry) {
                  final index = entry.key;
                  final history = entry.value;
                  final isHit = history.hit;
                  
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: history.value,
                        color: isHit ? Colors.green : Colors.red,
                        width: 12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('Hit', style: TextStyle(fontSize: 10)),
                  const SizedBox(width: 12),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('Miss', style: TextStyle(fontSize: 10)),
                ],
              ),
              Text(
                'Hit Rate: ${prop.hitRateDisplay}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: prop.hitRate > 0.7 ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSplitsSection(PropExplorer prop) {
    final splits = prop.splits;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '📊 Splits Analysis',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                splits.getSplitAdvantage(),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSplitItem('🏠 Home', splits.homeAway['home'] ?? 0),
              _buildSplitItem('✈️ Away', splits.homeAway['away'] ?? 0),
              _buildSplitItem('☀️ Day', splits.dayNight['day'] ?? 0),
              _buildSplitItem('🌙 Night', splits.dayNight['night'] ?? 0),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSplitItem('↔️ vs L', splits.vsLeftRight['vsLeft'] ?? 0),
              _buildSplitItem('↔️ vs R', splits.vsLeftRight['vsRight'] ?? 0),
              _buildSplitItem('📈 Best Month', _getBestMonth(splits)),
              _buildSplitItem('📉 Worst Month', _getWorstMonth(splits)),
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
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${(value * 100).toInt()}%',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getBestMonth(SplitsData splits) {
    String bestMonth = 'Jun';
    double bestValue = 0;
    for (final entry in splits.monthByMonth.entries) {
      if (entry.value > bestValue) {
        bestValue = entry.value;
        bestMonth = entry.key;
      }
    }
    return bestMonth;
  }

  String _getWorstMonth(SplitsData splits) {
    String worstMonth = 'Apr';
    double worstValue = 1;
    for (final entry in splits.monthByMonth.entries) {
      if (entry.value < worstValue) {
        worstValue = entry.value;
        worstMonth = entry.key;
      }
    }
    return worstMonth;
  }

  Widget _buildMatchupSection(PropExplorer prop) {
    final matchup = prop.matchup;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '⚔️ Opponent Matchup',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                matchup.matchupRating,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: matchup.avg > 0.300 ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMatchupStat('Opponent', matchup.opponent),
              _buildMatchupStat('PA', matchup.plateAppearances.toString()),
              _buildMatchupStat('AVG', matchup.avg.toStringAsFixed(3)),
              _buildMatchupStat('OPS', matchup.ops.toStringAsFixed(3)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMatchupStat('XBH', matchup.extraBaseHits.toString()),
              _buildMatchupStat('Opp ERA', matchup.opponentEra.toStringAsFixed(2)),
              _buildMatchupStat('Pitcher', matchup.pitcher ?? 'TBD'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatchupStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInjurySection(PropExplorer prop) {
    final injury = prop.injury;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: injury.isHealthy ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: injury.isHealthy ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            injury.isHealthy ? Icons.health_and_safety_rounded : Icons.medical_services_rounded,
            color: injury.isHealthy ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  injury.isHealthy ? '✅ Healthy' : '⚠️ Injury Concern',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: injury.isHealthy ? Colors.green : Colors.orange,
                  ),
                ),
                Text(
                  injury.notes,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (injury.opponentInjury != 'None')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Opp: ${injury.opponentInjury}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUsageTrend(PropExplorer prop) {
    final trend = prop.usageTrend;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            trend.trendEmoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📈 Usage Trend',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${trend.trendDisplay} (${trend.percentChange.abs().toStringAsFixed(1)}% ${trend.direction})',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Last ${trend.gamesTracked} games tracked',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: trend.direction == 'up' 
                  ? Colors.green.withOpacity(0.1) 
                  : trend.direction == 'down' 
                      ? Colors.red.withOpacity(0.1) 
                      : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              trend.direction == 'up' ? '🟢 Increasing' : 
              trend.direction == 'down' ? '🔴 Decreasing' : '⚪ Stable',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: trend.direction == 'up' 
                    ? Colors.green 
                    : trend.direction == 'down' 
                        ? Colors.red 
                        : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookOdds(PropExplorer prop) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💰 Best Odds',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...prop.odds.map((book) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      book.bookName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    book.oddsDisplay,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: book.oddsColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: book.impliedProbability < 0.5 
                          ? Colors.green.withOpacity(0.1) 
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${(book.impliedProbability * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 10,
                        color: book.impliedProbability < 0.5 ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRecommendation(PropExplorer prop) {
    final isValue = prop.ev > 3;
    final isHot = prop.hitRate > 0.7;
    
    String recommendation;
    Color recommendationColor;
    String icon;
    
    if (isValue && isHot) {
      recommendation = '🔥 STRONG BUY - EV+ with hot streak';
      recommendationColor = Colors.green;
      icon = '🚀';
    } else if (isValue) {
      recommendation = '✅ VALUE BET - Positive EV opportunity';
      recommendationColor = Colors.green;
      icon = '💰';
    } else if (isHot) {
      recommendation = '📈 HOT STREAK - Momentum on your side';
      recommendationColor = Colors.orange;
      icon = '🔥';
    } else if (prop.ev < -3) {
      recommendation = '⚠️ AVOID - Negative EV';
      recommendationColor = Colors.red;
      icon = '❌';
    } else {
      recommendation = '📊 NEUTRAL - Monitor for changes';
      recommendationColor = Colors.grey;
      icon = '⚖️';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: recommendationColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: recommendationColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎯 Recommendation',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  recommendation,
                  style: TextStyle(
                    color: recommendationColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filters'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // EV filter
            Row(
              children: [
                const Text('Min EV: '),
                Expanded(
                  child: Slider(
                    min: 0,
                    max: 10,
                    divisions: 20,
                    value: _minEV,
                    onChanged: (value) {
                      setState(() {
                        _minEV = value;
                      });
                    },
                  ),
                ),
                Text('${_minEV.toStringAsFixed(1)}%'),
              ],
            ),
            // Hit Rate filter
            Row(
              children: [
                const Text('Min Hit Rate: '),
                Expanded(
                  child: Slider(
                    min: 0,
                    max: 1,
                    divisions: 10,
                    value: _minHitRate,
                    onChanged: (value) {
                      setState(() {
                        _minHitRate = value;
                      });
                    },
                  ),
                ),
                Text('${(_minHitRate * 100).toInt()}%'),
              ],
            ),
            // Sort by
            Row(
              children: [
                const Text('Sort by:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _sortBy,
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: 'ev', child: Text('EV')),
                    DropdownMenuItem(value: 'hitRate', child: Text('Hit Rate')),
                    DropdownMenuItem(value: 'playerName', child: Text('Player')),
                  ],
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                  onPressed: () {
                    setState(() {
                      _sortAscending = !_sortAscending;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _applyFilters();
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
