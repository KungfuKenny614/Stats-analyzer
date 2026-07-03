import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stats_analyzer/providers/watchlist_provider.dart';
import 'package:stats_analyzer/design_system/tokens/colors.dart';
import 'package:stats_analyzer/design_system/tokens/spacing.dart';
import 'package:stats_analyzer/design_system/tokens/typography.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final watchlist = context.watch<WatchlistProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Watchlist')),
      body: watchlist.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border_rounded, size: 64, color: DSColors.textTertiary),
                  const SizedBox(height: 16),
                  Text('Your watchlist is empty', style: DSTypography.headingSM),
                  const SizedBox(height: 8),
                  Text('Add players from the research dashboard', style: DSTypography.caption),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(DSSpacing.lg),
              itemCount: watchlist.items.length,
              itemBuilder: (context, index) {
                final item = watchlist.items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: DSSpacing.sm),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: DSColors.infoSurface,
                      child: Text(
                        (item['name'] as String).split(' ').map((e) => e[0]).join(''),
                        style: const TextStyle(color: DSColors.info),
                      ),
                    ),
                    title: Text(item['name'] ?? 'Unknown'),
                    subtitle: Text(item['team'] ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded, color: DSColors.negative),
                      onPressed: () => watchlist.removeItem(item['id']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
