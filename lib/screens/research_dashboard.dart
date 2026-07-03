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

class ResearchDashboard extends StatelessWidget {
  const ResearchDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.background,
      body: Consumer2<AppState, AuthProvider>(
        builder: (context, appState, authProvider, child) {
          return Column(
            children: [
              // Global Navigation
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
              
              // Main workspace
              Expanded(
                child: Row(
                  children: [
                    // Primary Navigation (Left Rail)
                    PrimaryNav(
                      items: _navItems,
                      selectedIndex: appState.selectedNavIndex,
                    ),
                    
                    // Workspace
                    Expanded(
                      child: appState.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : appState.error.isNotEmpty
                              ? _buildErrorWidget(appState)
                              : _buildWorkspace(context, appState),
                    ),
                    
                    // Inspector Panel (Right)
                    _buildInspectorPanel(context, appState),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static const List<PrimaryNavItem> _navItems = [
    const PrimaryNavItem(label: 'Markets', icon: Icons.grid_view_rounded),
    const PrimaryNavItem(label: 'Players', icon: Icons.person_rounded),
    const PrimaryNavItem(label: 'Games', icon: Icons.sports_baseball_rounded),
    const PrimaryNavItem(label: 'Research', icon: Icons.analytics_rounded, badgeCount: 3),
    const PrimaryNavItem(label: 'Alerts', icon: Icons.notifications_rounded),
    const PrimaryNavItem(label: 'Portfolio', icon: Icons.folder_rounded),
  ];

  Widget _buildErrorWidget(AppState appState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 64, color: DSColors.negative),
          const SizedBox(height: 16),
          Text(
            'Error loading data',
            style: DSTypography.headingSM,
          ),
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

  Widget _buildWorkspace(BuildContext context, AppState appState) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Row(
            children: [
              Text(
                'Research',
                style: DSTypography.caption.copyWith(
                  color: DSColors.textTertiary,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: DSColors.textTertiary,
              ),
              Text(
                appState.selectedLeague,
                style: DSTypography.caption.copyWith(
                  color: DSColors.textTertiary,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: DSColors.textTertiary,
              ),
              Text(
                'Props',
                style: DSTypography.caption.copyWith(
                  color: DSColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: DSSpacing.lg),
          
          // Secondary Navigation (Tabs)
          _buildSecondaryNav(appState),
          
          const SizedBox(height: DSSpacing.xl),
          
          // Metrics Row
          _buildMetricsRow(appState),
          
          const SizedBox(height: DSSpacing.xl),
          
          // Data Grid
          Expanded(
            child: _buildDataGrid(context, appState),
          ),
        ],
      ),
    );
  }

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
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.lg,
                vertical: DSSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected 
                    ? DSColors.surface
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected 
                      ? DSColors.border
                      : Colors.transparent,
                  width: 1,
                ),
                boxShadow: isSelected ? DSElevation.level1 : [],
              ),
              child: Text(
                tabs[index],
                style: DSTypography.label.copyWith(
                  color: isSelected 
                      ? DSColors.textPrimary
                      : DSColors.textTertiary,
                  fontWeight: isSelected 
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

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

  Widget _buildDataGrid(BuildContext context, AppState appState) {
    final markets = appState.filteredMarkets;
    
    final columns = [
      DataGridColumn(
        label: 'Player',
        width: 120,
        valueBuilder: (row) => '${row.playerName} (${row.team})',
      ),
      DataGridColumn(
        label: 'Market',
        width: 80,
        valueBuilder: (row) => row.marketType,
      ),
      DataGridColumn(
        label: 'Line',
        width: 60,
        valueBuilder: (row) => row.line.toStringAsFixed(1),
      ),
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
    ];

    return DataGrid(
      columns: columns,
      rows: markets,
      emptyMessage: 'No props match your filters',
      onRowTap: () {
        if (markets.isNotEmpty) {
          appState.selectRow(0);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selected: ${markets[0].playerName}'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
    );
  }

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
        border: Border(
          left: BorderSide(
            color: DSColors.border.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(DSSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inspector',
              style: DSTypography.caption,
            ),
            const SizedBox(height: DSSpacing.md),
            
            // Selected item summary
            Container(
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: DSColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playerName,
                    style: DSTypography.headingSM.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (market != null) ...[
                    Text(
                      '${market.team} vs ${market.opponent} | ${market.marketType}',
                      style: DSTypography.bodySM.copyWith(
                        color: DSColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: DSSpacing.sm),
                    Row(
                      children: [
                        _buildInspectorBadge(
                          'Projection', 
                          analytics != null 
                              ? (market.line + analytics.ev / 10).toStringAsFixed(1)
                              : '—',
                          DSColors.info,
                        ),
                        const SizedBox(width: DSSpacing.sm),
                        _buildInspectorBadge(
                          'Line', 
                          market.line.toStringAsFixed(1),
                          DSColors.textSecondary,
                        ),
                        const SizedBox(width: DSSpacing.sm),
                        _buildInspectorBadge(
                          'EV', 
                          analytics != null 
                              ? '${analytics.ev > 0 ? "+" : ""}${analytics.ev.toStringAsFixed(1)}%'
                              : '—',
                          analytics?.isEVPositive ?? false ? DSColors.positive : DSColors.textTertiary,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: DSSpacing.lg),
            
            // EV Analysis
            ExpandableCard(
              title: 'EV Analysis',
              subtitle: 'Model projection vs market',
              child: Column(
                children: [
                  _buildInsightRow('Model', analytics != null 
                      ? (market!.line + analytics.ev / 10).toStringAsFixed(1)
                      : '—', DSColors.info),
                  _buildInsightRow('Market', market != null ? market.line.toStringAsFixed(1) : '—', DSColors.textSecondary),
                  _buildInsightRow('Edge', analytics != null 
                      ? '${analytics.ev > 0 ? "+" : ""}${analytics.ev.toStringAsFixed(1)}%'
                      : '—', 
                      analytics?.isEVPositive ?? false ? DSColors.positive : DSColors.textTertiary),
                  _buildInsightRow('Confidence', analytics != null 
                      ? '${(analytics.hitRate * 100).toInt()}%'
                      : '—', DSColors.info),
                ],
              ),
            ),
            
            const SizedBox(height: DSSpacing.md),
            
            // Recent Form
            ExpandableCard(
              title: 'Recent Form',
              subtitle: 'Last 10 games',
              child: Column(
                children: [
                  _buildFormRow('Hits', '8/10', DSColors.positive),
                  _buildFormRow('Avg', '26.4', DSColors.info),
                  _buildFormRow('Min', '34.2', DSColors.textSecondary),
                ],
              ),
            ),
            
            const SizedBox(height: DSSpacing.md),
            
            // Splits
            ExpandableCard(
              title: 'Splits',
              subtitle: 'Performance breakdown',
              child: Column(
                children: [
                  _buildSplitRow('Home', '27.2', 'Away', '24.6'),
                  _buildSplitRow('vs Good', '24.1', 'vs Bad', '29.7'),
                  _buildSplitRow('B2B', '22.3', 'Rest', '28.1'),
                ],
              ),
            ),
            
            const SizedBox(height: DSSpacing.lg),
            
            // Action buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Alert added!')),
                  );
                },
                icon: const Icon(Icons.add_alert_rounded, size: 16),
                label: const Text('Add Alert'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DSColors.info,
                  foregroundColor: DSColors.textInverse,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: DSSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to watchlist!')),
                  );
                },
                icon: const Icon(Icons.bookmark_border_rounded, size: 16),
                label: const Text('Add to Watchlist'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: DSColors.textSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(
                    color: DSColors.border,
                    width: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectorBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: DSTypography.caption.copyWith(
              color: DSColors.textTertiary,
            ),
          ),
          Text(
            value,
            style: DSTypography.labelStrong.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: DSTypography.bodySM.copyWith(
              color: DSColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: DSTypography.labelStrong.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: DSTypography.bodySM.copyWith(
              color: DSColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: DSTypography.labelStrong.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitRow(String label1, String value1, String label2, String value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  label1,
                  style: DSTypography.bodySM.copyWith(
                    color: DSColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  value1,
                  style: DSTypography.labelStrong,
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Text(
                  label2,
                  style: DSTypography.bodySM.copyWith(
                    color: DSColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  value2,
                  style: DSTypography.labelStrong,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
      trailing: Text(
        '⌘↵',
        style: DSTypography.caption.copyWith(
          color: DSColors.textTertiary,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected: $title')),
        );
      },
    );
  }
}
