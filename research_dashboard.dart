Widget _buildMarketsTab(BuildContext context, AppState appState) {
  final markets = appState.filteredMarkets;
  return Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Markets (${markets.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: DSColors.deTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: markets.isEmpty
              ? const Center(
                  child: Text(
                    'No markets match your filters.',
                    style: TextStyle(color: DSColors.deTextSecondary),
                  ),
                )
              : ListView.builder(
                  itemCount: markets.length,
                  itemBuilder: (context, index) {
                    final market = markets[index];
                    final analytics = appState.getAnalyticsForMarket(market);
              return HoverTrigger<MLBNormalizedMarket>(
  data: market,
  builder: (context, data) {
    final analytics = appState.getAnalyticsForMarket(data);
    return PlayerHoverCardBuilder.build(data, analytics);
  },
  onTap: () => appState.selectRow(index),
  child: MarketCard(
    market: market,
    analytics: analytics,
  ),
);
