import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stats_analyzer/providers/app_state.dart';
import 'package:stats_analyzer/design_system/tokens/colors.dart';
import 'package:stats_analyzer/design_system/tokens/spacing.dart';
import 'package:stats_analyzer/design_system/tokens/typography.dart';
import 'package:stats_analyzer/services/ai_service.dart';
import 'dart:async';

// (The Insight, BookOdds, FormBar, EdgeBadge, OddsRow, InsightCard classes
//  are kept exactly as they were – they use DSColors and the shared design tokens.)

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  // Filter state
  String _selectedCategory = 'All Sports';
  final List<String> _categories = ['All Sports', 'Spreads', 'Totals', 'Moneylines', 'Props'];
  bool _sortByEdge = true;

  List<Insight> _insights = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    setState(() => _loading = true);

    // Get markets and analytics from the app state
    final appState = context.read<AppState>();
    final markets = appState.markets;
    final analytics = appState.analytics;

    // Use AI service to generate insights from real data
    // If the AI service returns empty, fallback to a simple generated set
    List<Insight> generated = [];
    if (markets.isNotEmpty && analytics.isNotEmpty) {
      generated = AIService.generateInsightsFromMarkets(markets, analytics);
    }

    // If no insights were generated, create a fallback empty state
    _insights = generated;

    setState(() => _loading = false);
  }

  List<Insight> _getFilteredInsights() {
    var list = _insights;
    if (_selectedCategory != 'All Sports') {
      list = list.where((i) => i.category == _selectedCategory).toList();
    }
    if (_sortByEdge) {
      list.sort((a, b) => b.edgePct.compareTo(a.edgePct));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredInsights();

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
                        Icon(Icons.lightbulb_rounded, color: DSColors.deAccent, size: 20),
                        const SizedBox(width: 8),
                        Text('Insights', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: DSColors.deTextPrimary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Auto-surfaced angles with the best current odds and highest edge, ranked top to bottom',
                      style: const TextStyle(fontSize: 13, color: DSColors.deTextSecondary),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((cat) {
                    final isActive = _selectedCategory == cat;
                    return FilterChip(
                      label: Text(cat),
                      selected: isActive,
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                      selectedColor: DSColors.deAccent.withOpacity(0.2),
                      backgroundColor: DSColors.inputBg,
                      labelStyle: TextStyle(
                        color: isActive ? DSColors.deAccent : DSColors.deTextPrimary,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: isActive ? DSColors.deAccent : DSColors.deBorder),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    );
                  }).toList(),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Text('Sort by Edge', style: TextStyle(fontSize: 12, color: DSColors.deTextSecondary)),
                    Switch(
                      value: _sortByEdge,
                      onChanged: (v) => setState(() => _sortByEdge = v),
                      activeColor: DSColors.deAccent,
                    ),
                  ],
                ),
              ),
            ),
            if (_loading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (filtered.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: DSColors.deTextSecondary),
                      const SizedBox(height: 16),
                      Text('No insights match your filters.', style: TextStyle(color: DSColors.deTextSecondary)),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: _buildInsightCard(filtered[index]),
                  ),
                  childCount: filtered.length,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Reuse the same InsightCard widget from the earlier version
  Widget _buildInsightCard(Insight insight) {
    return Container(
      decoration: BoxDecoration(
        color: DSColors.deSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DSColors.deBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              border: Border.all(color: DSColors.deBorder),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              insight.category.toUpperCase(),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: DSColors.deAccent),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            insight.matchup,
                            style: const TextStyle(fontSize: 11, color: DSColors.deTextSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        insight.headline,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: DSColors.deTextPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        insight.subline,
                        style: const TextStyle(fontSize: 12, color: DSColors.deTextSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildEdgeBadge(insight.edgePct),
              ],
            ),
          ),
          // Form bar and stat
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormBar(insight.trend),
                Text(
                  insight.stat,
                  style: const TextStyle(fontSize: 12, color: DSColors.deTextSecondary),
                ),
              ],
            ),
          ),
          // Odds row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: _buildOddsRow(insight.odds),
          ),
        ],
      ),
    );
  }

  Widget _buildFormBar(List<String> results) {
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

  Widget _buildEdgeBadge(double pct) {
    final pctDisplay = (pct * 100).toInt();
    final color = pct >= 0.75 ? DSColors.deWin : pct >= 0.55 ? DSColors.mid : DSColors.deLoss;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$pctDisplay',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color, height: 1),
        ),
        Text(
          'EDGE SCORE',
          style: TextStyle(fontSize: 10, color: DSColors.deTextSecondary, letterSpacing: 0.05),
        ),
      ],
    );
  }

  Widget _buildOddsRow(List<BookOdds> odds) {
    if (odds.isEmpty) return const SizedBox.shrink();
    final bestPrice = odds.map((o) => o.price).reduce((a, b) => a > b ? a : b);
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      children: odds.map((o) {
        final isBest = o.price == bestPrice;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isBest ? DSColors.deAccent : DSColors.deBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                o.book,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: DSColors.deTextSecondary),
              ),
              const SizedBox(width: 4),
              Text(
                o.price > 0 ? '+${o.price.toInt()}' : o.price.toInt().toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isBest ? FontWeight.w700 : FontWeight.w500,
                  color: isBest ? DSColors.deTextPrimary : DSColors.deTextSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
