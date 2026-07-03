import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stats_analyzer/design_system/tokens/colors.dart';
import 'package:stats_analyzer/design_system/tokens/spacing.dart';
import 'package:stats_analyzer/design_system/tokens/typography.dart';
import 'package:stats_analyzer/design_system/components/navigation/global_nav.dart';
import 'package:stats_analyzer/design_system/components/navigation/primary_nav.dart';
import 'package:stats_analyzer/design_system/components/cards/metric_card.dart';
import 'package:stats_analyzer/design_system/components/cards/expandable_card.dart';
import 'package:stats_analyzer/design_system/components/tables/data_grid.dart';
import 'package:stats_analyzer/design_system/tokens/elevation.dart';
import 'package:stats_analyzer/providers/app_state.dart';
import 'package:stats_analyzer/providers/auth_provider.dart';
import 'package:stats_analyzer/widgets/performance_chart.dart';
import 'package:stats_analyzer/widgets/hit_rate_heatmap.dart';
import 'package:stats_analyzer/models/mlb_outlier_models.dart';

class ResearchDashboard extends StatelessWidget {
  const ResearchDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 1200;
          final isMobile = constraints.maxWidth <= 800;

          return Consumer2<AppState, AuthProvider>(
            builder: (context, appState, authProvider, child) {
              return Column(
                children: [
                  GlobalNav(
                    title: 'DiamondEdge',
                    league: appState.selectedLeague,
                    onSearch: () => _showCommandPalette(context),
                    onNotifications: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifications coming soon!')),
                      );
                    },
                    userAvatar: authProvider.user != null
                        ? CircleAvatar(
                            backgroundColor: DSColors.infoSurface,
                            radius: 14,
                            child: Text(
                              authProvider.userName.isNotEmpty
                                  ? authProvider.userName.substring(0, 1).toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: DSColors.info,
                              ),
                            ),
                          )
                        : null,
                    onSignOut: () async {
                      await authProvider.signOut();
                    },
                  ),
                  Expanded(
                    child: isMobile
                        ? _buildMobileLayout(context, appState)
                        : _buildDesktopLayout(context, appState, isDesktop),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // Desktop layout
  Widget _buildDesktopLayout(BuildContext context, AppState appState, bool isDesktop) {
    return Row(
      children: [
        Container(
          width: 72,
          decoration: BoxDecoration(
            color: DSColors.surface,
            border: Border(
              right: BorderSide(
                color: DSColors.border.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: PrimaryNav(
            items: _navItems,
            selectedIndex: appState.selectedNavIndex,
          ),
        ),
        Expanded(
          child: appState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : appState.error.isNotEmpty
                  ? _buildErrorWidget(appState)
                  : _buildResearchWorkspace(context, appState),
        ),
        if (isDesktop) _buildInspectorPanel(context, appState),
      ],
    );
  }

  // Mobile layout
  Widget _buildMobileLayout(BuildContext context, AppState appState) {
    return Scaffold(
      body: appState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : appState.error.isNotEmpty
              ? _buildErrorWidget(appState)
              : _buildResearchWorkspace(context, appState),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: appState.selectedNavIndex,
        onTap: (index) => appState.setNavIndex(index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Markets'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Players'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_baseball_rounded), label: 'Games'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded), label: 'Research'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb_rounded), label: 'Insights'),
        ],
      ),
    );
  }

  final List<PrimaryNavItem> _navItems = const [
    PrimaryNavItem(label: 'Markets', icon: Icons.grid_view_rounded),
    PrimaryNavItem(label: 'Players', icon: Icons.person_rounded),
    PrimaryNavItem(label: 'Games', icon: Icons.sports_baseball_rounded),
    PrimaryNavItem(label: 'Research', icon: Icons.analytics_rounded, badgeCount: 3),
    PrimaryNavItem(label: 'Insights', icon: Icons.lightbulb_rounded),
  ];

  // Main research workspace
  Widget _buildResearchWorkspace(BuildContext context, AppState appState) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Row(
            children: [
              Text('Research', style: DSTypography.caption.copyWith(color: DSColors.textTertiary)),
              const Icon(Icons.chevron_right_rounded, size: 16, color: DSColors.textTertiary),
              Text(appState.selectedLeague, style: DSTypography.caption.copyWith(color: DSColors.textTertiary)),
              const Icon(Icons.chevron_right_rounded, size: 16, color: DSColors.textTertiary),
              Text('Props', style: DSTypography.caption.copyWith(color: DSColors.textPrimary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),

          // Feature Pills
          _buildFeaturePills(),
          const SizedBox(height: DSSpacing.md),

          // Secondary Nav
          _buildSecondaryNav(appState),
          const SizedBox(height: DSSpacing.xl),

          // Metrics
          _buildMetricsRow(appState),
          const SizedBox(height: DSSpacing.xl),

          // Team Rankings
          _buildTeamRankings(),
          const SizedBox(height: DSSpacing.xl),

          // Data Grid
          Expanded(child: _buildDataGrid(context, appState)),
        ],
      ),
    );
  }

  // Feature Pills
  Widget _buildFeaturePills() {
    final features = ['EV+', 'Boosts', 'Arbitrage', 'Middle Bets', 'All'];
    final icons = [Icons.trending_up, Icons.flash_on, Icons.swap_horiz, Icons.compare_arrows, Icons.grid_view];
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: features.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return FilterChip(
            label: Text(features[index]),
            selected: index == 0,
            onSelected: (_) {},
            avatar: Icon(icons[index], size: 16),
            selectedColor: DSColors.infoSurface,
            checkmarkColor: DSColors.info,
          );
        },
      ),
    );
  }

  // Secondary Nav
  Widget _buildSecondaryNav(AppState appState) {
    final tabs = ['Overview', 'Odds', 'Splits', 'History', 'Projections', 'Analysis'];
    return Container(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 4),
        itemBuilder: (context, index) {
          final isSelected = appState.selectedTab == tabs[index];
          return GestureDetector(
            onTap: () => appState.setTab(tabs[index]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: DSSpacing.lg, vertical: DSSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected ? DSColors.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isSelected ? DSColors.border : Colors.transparent, width: 1),
                boxShadow: isSelected ? DSElevation.level1 : [],
              ),
              child: Text(
                tabs[index],
                style: DSTypography.label.copyWith(
                  color: isSelected ? DSColors.textPrimary : DSColors.textTertiary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Metrics
  Widget _buildMetricsRow(AppState appState) {
    final total = appState.filteredMarkets.length;
    final evPositive = appState.filteredMarkets.where((m) {
      final a = appState.getAnalyticsForMarket(m);
      return a?.isEVPositive ?? false;
    }).length;
    final avgEv = total > 0
        ? appState.filteredMarkets.map((m) {
            final a = appState.getAnalyticsForMarket(m);
            return a?.ev ?? 0;
          }).reduce((a, b) => a + b) / total
        : 0;

    return Row(
      children: [
        Expanded(
          child: MetricCard(
            label: 'Total Props',
            value: total.toString(),
            subtitle: 'Filtered results',
            icon: Icons.grid_view_rounded,
            iconColor: DSColors.info,
          ),
        ),
        const SizedBox(width: DSSpacing.md),
        Expanded(
          child: MetricCard(
            label: 'EV+ Opportunities',
            value: evPositive.toString(),
            subtitle: 'Avg EV: ${avgEv.toStringAsFixed(1)}%',
            icon: Icons.trending_up_rounded,
            iconColor: DSColors.positive,
          ),
        ),
        const SizedBox(width: DSSpacing.md),
        Expanded(
          child: MetricCard(
            label: 'Hit Rate',
            value: '${(appState.filteredMarkets.map((m) {
              final a = appState.getAnalyticsForMarket(m);
              return a?.hitRate ?? 0;
            }).reduce((a, b) => a + b) / (total > 0 ? total : 1) * 100).toInt()}%',
            subtitle: 'Average across props',
            icon: Icons.flag,
            iconColor: DSColors.warning,
          ),
        ),
        const SizedBox(width: DSSpacing.md),
        Expanded(
          child: MetricCard(
            label: 'Live Alerts',
            value: '${appState.filteredMarkets.where((m) {
              final a = appState.getAnalyticsForMarket(m);
              return (a?.ev ?? 0) > 5;
            }).length}',
            subtitle: 'High EV opportunities',
            icon: Icons.notifications_active_rounded,
            iconColor: DSColors.negative,
          ),
        ),
      ],
    );
  }

  // Team Rankings
  Widget _buildTeamRankings() {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: DSColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DSColors.border.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Team Rankings', style: DSTypography.headingSM),
              const Spacer(),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'defense', label: Text('Defense')),
                  ButtonSegment(value: 'offense', label: Text('Offense')),
                ],
                selected: const {'defense'},
                onSelectionChanged: (_) {},
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          _buildRankingRow('Points', '114.7', '23rd'),
          _buildRankingRow('FG%', '46.6%', '17th'),
          _buildRankingRow('3PT%', '35.2%', '15th'),
        ],
      ),
    );
  }

  Widget _buildRankingRow(String label, String value, String rank) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: DSTypography.bodySM)),
          Expanded(child: Text(value, style: DSTypography.labelStrong)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: DSColors.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(rank, style: DSTypography.caption),
          ),
        ],
      ),
    );
  }

  // Data Grid
  Widget _buildDataGrid(BuildContext context, AppState appState) {
    final markets = appState.filteredMarkets;
    final columns = [
      DataGridColumn(label: 'Player', width: 120, valueBuilder: (row) => '${row.playerName} (${row.team})'),
      DataGridColumn(label: 'Market', width: 80, valueBuilder: (row) => row.marketType),
      DataGridColumn(label: 'Line', width: 60, valueBuilder: (row) => row.line.toStringAsFixed(1)),
      DataGridColumn(
        label: 'Projection',
        width: 80,
        valueBuilder: (row) {
          final a = appState.getAnalyticsForMarket(row);
          return a != null ? (row.line + a.ev / 10).toStringAsFixed(1) : '—';
        },
      ),
      DataGridColumn(
        label: 'EV',
        width: 60,
        alignment: Alignment.center,
        valueBuilder: (row) {
          final a = appState.getAnalyticsForMarket(row);
          return a != null ? '${a.ev > 0 ? "+" : ""}${a.ev.toStringAsFixed(1)}%' : '—';
        },
      ),
      DataGridColumn(
        label: 'Hit Rate',
        width: 60,
        alignment: Alignment.center,
        valueBuilder: (row) {
          final a = appState.getAnalyticsForMarket(row);
          return a != null ? '${(a.hitRate * 100).toInt()}%' : '—';
        },
      ),
      DataGridColumn(
        label: 'Perf',
        width: 80,
        alignment: Alignment.center,
        valueBuilder: (row) {
          final a = appState.getAnalyticsForMarket(row);
          if (a == null) return '—';
          final pct = a.hitRate;
          if (pct >= 0.7) return '🔥';
          if (pct >= 0.5) return '📈';
          return '📉';
        },
      ),
    ];

    return DataGrid(
      columns: columns,
      rows: markets,
      emptyMessage: 'No props match your filters',
      onRowTap: () {
        if (markets.isNotEmpty) {
          appState.selectRow(0);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Selected: ${markets[0].playerName}'), duration: const Duration(seconds: 1)),
          );
        }
      },
    );
  }

  // Error widget
  Widget _buildErrorWidget(AppState appState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 64, color: DSColors.negative),
          const SizedBox(height: 16),
          Text('Error loading data', style: DSTypography.headingSM),
          const SizedBox(height: 8),
          Text(
            appState.error,
            style: DSTypography.bodySM.copyWith(color: DSColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => appState.loadData(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Inspector Panel with Tabs
  Widget _buildInspectorPanel(BuildContext context, AppState appState) {
    final playerName = appState.selectedPlayerName;
    final analytics = appState.selectedAnalytics;
    final market = appState.selectedRowIndex >= 0 && appState.selectedRowIndex < appState.filteredMarkets.length
        ? appState.filteredMarkets[appState.selectedRowIndex]
        : null;

    return Container(
      width: 340,
      decoration: BoxDecoration(
        color: DSColors.surface,
        border: Border(left: BorderSide(color: DSColors.border.withOpacity(0.3), width: 1)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(DSSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Inspector', style: DSTypography.caption),
                const SizedBox(height: 4),
                Text(
                  playerName,
                  style: DSTypography.headingSM.copyWith(fontWeight: FontWeight.w700),
                ),
                if (market != null)
                  Text(
                    '${market.team} vs ${market.opponent} | ${market.marketType}',
                    style: DSTypography.bodySM.copyWith(color: DSColors.textSecondary),
                  ),
                const SizedBox(height: DSSpacing.sm),
                Row(
                  children: [
                    _buildInspectorBadge('Projection', analytics != null ? (market!.line + analytics.ev / 10).toStringAsFixed(1) : '—', DSColors.info),
                    const SizedBox(width: DSSpacing.sm),
                    _buildInspectorBadge('Line', market != null ? market.line.toStringAsFixed(1) : '—', DSColors.textSecondary),
                    const SizedBox(width: DSSpacing.sm),
                    _buildInspectorBadge(
                      'EV',
                      analytics != null ? '${analytics.ev > 0 ? "+" : ""}${analytics.ev.toStringAsFixed(1)}%' : '—',
                      analytics?.isEVPositive ?? false ? DSColors.positive : DSColors.textTertiary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          // Tabs
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    tabs: const [
                      Tab(text: 'Matchup'),
                      Tab(text: 'Injuries'),
                      Tab(text: 'Insights'),
                    ],
                    labelColor: DSColors.info,
                    unselectedLabelColor: DSColors.textTertiary,
                    indicatorColor: DSColors.info,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildMatchupTab(context, market, analytics),
                        _buildInjuriesTab(context, market),
                        _buildInsightsTabContent(context, analytics),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Matchup Tab
  Widget _buildMatchupTab(BuildContext context, MLBNormalizedMarket? market, MLBAnalyticsResult? analytics) {
    if (market == null) return const Center(child: Text('Select a prop'));
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Opponent Splits', style: DSTypography.headingSM),
          const SizedBox(height: DSSpacing.md),
          _buildSplitRow('Home', analytics?.splits['Home'] ?? 0.5, 'Away', analytics?.splits['Away'] ?? 0.5),
          _buildSplitRow('vs LHP', 0.45, 'vs RHP', 0.55),
          _buildSplitRow('Last 5', 0.7, 'Last 10', 0.6),
          const SizedBox(height: DSSpacing.md),
          Text('Team Rankings', style: DSTypography.headingSM),
          const SizedBox(height: DSSpacing.sm),
          _buildRankingRow('Defense', '109.3', '17th'),
          _buildRankingRow('Offense', '114.7', '23rd'),
        ],
      ),
    );
  }

  Widget _buildSplitRow(String label1, double value1, String label2, double value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(label1, style: DSTypography.bodySM.copyWith(color: DSColors.textSecondary)),
                const SizedBox(width: 8),
                Text('${(value1 * 100).toInt()}%', style: DSTypography.labelStrong),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Text(label2, style: DSTypography.bodySM.copyWith(color: DSColors.textSecondary)),
                const SizedBox(width: 8),
                Text('${(value2 * 100).toInt()}%', style: DSTypography.labelStrong),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Injuries Tab
  Widget _buildInjuriesTab(BuildContext context, MLBNormalizedMarket? market) {
    return const Padding(
      padding: EdgeInsets.all(DSSpacing.lg),
      child: Center(child: Text('No injury reports available.')),
    );
  }

  // Insights Tab
  Widget _buildInsightsTabContent(BuildContext context, MLBAnalyticsResult? analytics) {
    if (analytics == null) return const Center(child: Text('No insights'));
    final insights = <String>[
      if (analytics.ev > 3) '🔥 EV+ opportunity: ${analytics.ev.toStringAsFixed(1)}% edge',
      if (analytics.hitRate > 0.7) '📈 Hot streak: ${(analytics.hitRate * 100).toInt()}% hit rate',
      if (analytics.hardHitRate > 0.4) '💪 Hard hit rate: ${(analytics.hardHitRate * 100).toInt()}%',
      if (analytics.barrelRate > 0.15) '💥 Barrel rate: ${(analytics.barrelRate * 100).toInt()}%',
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(DSSpacing.lg),
      itemCount: insights.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: DSSpacing.sm),
          child: ListTile(
            leading: const Icon(Icons.lightbulb_rounded, color: DSColors.warning),
            title: Text(insights[index]),
          ),
        );
      },
    );
  }

  // Inspector helper
  Widget _buildInspectorBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Column(
        children: [
          Text(label, style: DSTypography.caption.copyWith(color: DSColors.textTertiary)),
          Text(value, style: DSTypography.labelStrong.copyWith(color: color)),
        ],
      ),
    );
  }

  // Command Palette
  void _showCommandPalette(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
        child: Container(
          height: 400,
          padding: const EdgeInsets.all(DSSpacing.lg),
          child: Column(
            children: [
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search players, markets, games...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: DSColors.surfaceVariant,
                ),
              ),
              const SizedBox(height: DSSpacing.lg),
              Expanded(
                child: ListView(
                  children: [
                    _buildCommandItem('Shohei Ohtani', 'Player', Icons.person_rounded, context),
                    _buildCommandItem('Points Market', 'Market', Icons.bar_chart_rounded, context),
                    _buildCommandItem('LAD vs NYY', 'Game', Icons.sports_baseball_rounded, context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommandItem(String title, String subtitle, IconData icon, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: DSColors.textTertiary),
      title: Text(title, style: DSTypography.bodyMD),
      subtitle: Text(subtitle, style: DSTypography.caption),
      trailing: Text('⌘↵', style: DSTypography.caption.copyWith(color: DSColors.textTertiary)),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selected: $title')));
      },
    );
  }
}
