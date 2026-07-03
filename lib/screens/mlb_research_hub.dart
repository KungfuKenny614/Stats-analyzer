import 'package:flutter/material.dart';
import 'package:stats_analyzer/config/premium_theme.dart';
import 'package:stats_analyzer/widgets/sticky_header.dart';
import 'package:stats_analyzer/widgets/premium_filter_panel.dart';
import 'package:stats_analyzer/widgets/premium_prop_card.dart';
import 'package:stats_analyzer/models/mlb_outlier_models.dart';
import 'package:stats_analyzer/services/mlb_outlier_engine.dart';

class MLBResearchHub extends StatefulWidget {
  const MLBResearchHub({super.key});

  @override
  State<MLBResearchHub> createState() => _MLBResearchHubState();
}

class _MLBResearchHubState extends State<MLBResearchHub> {
  final MLBOutlierEngine _engine = MLBOutlierEngine();
  
  // Data
  List<MLBNormalizedMarket> _markets = [];
  List<MLBAnalyticsResult> _analytics = [];
  Map<String, dynamic> _filters = {};
  String _searchQuery = '';
  
  // Selection
  int _selectedIndex = 0;
  
  // Quick stats
  int _totalMarkets = 0;
  int _evPositiveCount = 0;
  double _avgEv = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _markets = _engine.generateSampleMLBMarkets();
    _analytics = _markets.map((market) {
      final stats = _engine.generateSampleMLBStats(
        market.playerId,
        market.playerName,
        market.team,
      );
      return _engine.analyzeMLBMarket(
        marketId: market.playerId,
        market: market,
        stats: stats,
        modelProjection: market.line + (_engine.random.nextDouble() - 0.5) * 2,
        sharpPercentage: 0.3 + _engine.random.nextDouble() * 0.4,
        publicPercentage: 0.3 + _engine.random.nextDouble() * 0.4,
        previousLine: market.line - 0.5,
        previousOdds: -110.0 + _engine.random.nextDouble() * 20,
      );
    }).toList();
    
    _updateStats();
  }

  void _updateStats() {
    _totalMarkets = _markets.length;
    _evPositiveCount = _analytics.where((a) => a.isEVPositive).length;
    _avgEv = _analytics.isEmpty 
        ? 0 
        : _analytics.map((a) => a.ev).reduce((a, b) => a + b) / _analytics.length;
  }

  void _applyFilters(Map<String, dynamic> filters) {
    setState(() {
      _filters = filters;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumTheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Sticky Header
              StickyHeader(
                title: 'MLB Research',
                subtitle: '${_markets.length} props • ${_evPositiveCount} EV+',
                showLiveIndicator: true,
                notificationCount: 3,
                onSearchTap: () {
                  // Show search
                },
                actions: [
                  IconButton(
                    icon: const Icon(Icons.more_vert_rounded),
                    onPressed: () {},
                    style: IconButton.styleFrom(
                      backgroundColor: PremiumTheme.surfaceVariant,
                    ),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              
              // Main content
              Expanded(
                child: Row(
                  children: [
                    // Filter Panel
                    Container(
                      width: 280,
                      constraints: BoxConstraints(
                        maxHeight: constraints.maxHeight,
                      ),
                      child: PremiumFilterPanel(
                        onFilterChange: _applyFilters,
                      ),
                    ),
                    
                    // Main Research Panel
                    Expanded(
                      child: _buildMainPanel(),
                    ),
                    
                    // Right Insights Panel (hidden on smaller screens)
                    if (constraints.maxWidth > 1200)
                      Container(
                        width: 320,
                        decoration: BoxDecoration(
                          color: PremiumTheme.surface,
                          border: Border(
                            left: BorderSide(
                              color: PremiumTheme.divider.withOpacity(0.5),
                            ),
                          ),
                        ),
                        child: _buildInsightsPanel(),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainPanel() {
    return Container(
      padding: const EdgeInsets.all(PremiumTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick stats row
          Row(
            children: [
              _buildQuickStat('Total', _totalMarkets.toString(), Colors.blue),
              const SizedBox(width: PremiumTheme.spacingLg),
              _buildQuickStat('EV+', _evPositiveCount.toString(), PremiumTheme.success),
              const SizedBox(width: PremiumTheme.spacingLg),
              _buildQuickStat('Avg EV', 
                _avgEv > 0 ? '+${_avgEv.toStringAsFixed(1)}%' : '${_avgEv.toStringAsFixed(1)}%',
                _avgEv > 0 ? PremiumTheme.success : PremiumTheme.error,
              ),
              const Spacer(),
              // Sort dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: PremiumTheme.spacingMd),
                decoration: BoxDecoration(
                  color: PremiumTheme.surfaceVariant,
                  borderRadius: PremiumTheme.radiusMd,
                ),
                child: DropdownButton<String>(
                  value: 'ev',
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'ev', child: Text('Sort by EV')),
                    DropdownMenuItem(value: 'hitRate', child: Text('Sort by Hit Rate')),
                    DropdownMenuItem(value: 'player', child: Text('Sort by Player')),
                  ],
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
          
          const SizedBox(height: PremiumTheme.spacingLg),
          
          // Prop cards list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _markets.length,
              itemBuilder: (context, index) {
                final market = _markets[index];
                final analytics = _analytics[index];
                final isSelected = index == _selectedIndex;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: PremiumTheme.spacingMd),
                  child: PremiumPropCard(
                    market: market,
                    analytics: analytics,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumTheme.spacingMd,
        vertical: PremiumTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: PremiumTheme.radiusMd,
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: PremiumTheme.spacingSm),
          Text(
            label,
            style: PremiumTheme.labelSmall.copyWith(
              color: PremiumTheme.textSecondary,
            ),
          ),
          const SizedBox(width: PremiumTheme.spacingSm),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsPanel() {
    return Container(
      padding: const EdgeInsets.all(PremiumTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected prop summary
          if (_selectedIndex < _markets.length) ...[
            Text(
              'Selected Prop',
              style: PremiumTheme.titleSmall,
            ),
            const SizedBox(height: PremiumTheme.spacingSm),
            Text(
              _markets[_selectedIndex].playerName,
              style: PremiumTheme.headlineSmall,
            ),
            Text(
              '${_markets[_selectedIndex].marketType} - ${_markets[_selectedIndex].line.toStringAsFixed(1)}',
              style: PremiumTheme.caption,
            ),
            const SizedBox(height: PremiumTheme.spacingLg),
          ],
          
          // Quick insights sections
          _buildInsightSection(
            title: 'EV Analysis',
            icon: Icons.trending_up_rounded,
            content: _selectedIndex < _analytics.length
                ? '${_analytics[_selectedIndex].ev > 0 ? "+" : ""}${_analytics[_selectedIndex].ev.toStringAsFixed(1)}% EV'
                : '—',
            color: _selectedIndex < _analytics.length && _analytics[_selectedIndex].isEVPositive
                ? PremiumTheme.success
                : PremiumTheme.textSecondary,
          ),
          
          const SizedBox(height: PremiumTheme.spacingMd),
          
          _buildInsightSection(
            title: 'Hit Rate',
            icon: Icons.flag,
            content: _selectedIndex < _analytics.length
                ? '${(_analytics[_selectedIndex].hitRate * 100).toInt()}%'
                : '—',
            color: _selectedIndex < _analytics.length && _analytics[_selectedIndex].hitRate > 0.7
                ? PremiumTheme.success
                : PremiumTheme.textSecondary,
          ),
          
          const SizedBox(height: PremiumTheme.spacingMd),
          
          _buildInsightSection(
            title: 'Hard Hit Rate',
            icon: Icons.speed_rounded,
            content: _selectedIndex < _analytics.length
                ? '${(_analytics[_selectedIndex].hardHitRate * 100).toInt()}%'
                : '—',
            color: PremiumTheme.textSecondary,
          ),
          
          const SizedBox(height: PremiumTheme.spacingMd),
          
          _buildInsightSection(
            title: 'Barrel Rate',
            icon: Icons.rocket_launch_rounded,
            content: _selectedIndex < _analytics.length
                ? '${(_analytics[_selectedIndex].barrelRate * 100).toInt()}%'
                : '—',
            color: PremiumTheme.textSecondary,
          ),
          
          const SizedBox(height: PremiumTheme.spacingLg),
          
          // Recommendation
          if (_selectedIndex < _analytics.length)
            Container(
              padding: const EdgeInsets.all(PremiumTheme.spacingMd),
              decoration: BoxDecoration(
                color: _analytics[_selectedIndex].ev > 0 
                    ? PremiumTheme.successSurface
                    : PremiumTheme.surfaceVariant,
                borderRadius: PremiumTheme.radiusLg,
                border: Border.all(
                  color: _analytics[_selectedIndex].ev > 0 
                      ? PremiumTheme.success.withOpacity(0.3)
                      : PremiumTheme.divider,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _analytics[_selectedIndex].recommendation,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _analytics[_selectedIndex].ev > 0 
                          ? PremiumTheme.success
                          : PremiumTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Based on projection vs market line',
                    style: PremiumTheme.caption,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInsightSection({
    required String title,
    required IconData icon,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumTheme.spacingMd,
        vertical: PremiumTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: PremiumTheme.surfaceVariant,
        borderRadius: PremiumTheme.radiusMd,
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: PremiumTheme.textTertiary),
          const SizedBox(width: PremiumTheme.spacingSm),
          Expanded(
            child: Text(
              title,
              style: PremiumTheme.labelSmall.copyWith(
                color: PremiumTheme.textSecondary,
              ),
            ),
          ),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
