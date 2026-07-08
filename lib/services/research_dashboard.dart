class MarketCard extends StatelessWidget {
  final MLBNormalizedMarket market;
  final MLBAnalyticsResult? analytics;
  final VoidCallback onTap;

  const MarketCard({
    super.key,
    required this.market,
    required this.analytics,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isValue = analytics?.isEVPositive ?? false;
    final hitRate = analytics?.hitRate ?? 0;
    final ev = analytics?.ev ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DSColors.deSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DSColors.deBorder),
        ),
        child: Row(
          children: [
            // Player initials
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DSColors.deAccent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  market.playerName.split(' ').map((e) => e[0]).join(''),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: DSColors.deAccent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Player info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    market.playerName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: DSColors.deTextPrimary,
                    ),
                  ),
                  Text(
                    '${market.team} vs ${market.opponent} · ${market.marketType}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: DSColors.deTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Hit rate & EV badge
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: hitRate >= 0.7
                          ? DSColors.deWin.withOpacity(0.15)
                          : hitRate >= 0.5
                              ? DSColors.mid.withOpacity(0.15)
                              : DSColors.deLoss.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${(hitRate * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: hitRate >= 0.7
                            ? DSColors.deWin
                            : hitRate >= 0.5
                                ? DSColors.mid
                                : DSColors.deLoss,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isValue)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: DSColors.deAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '+${ev.toStringAsFixed(1)}% EV',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: DSColors.deAccent,
                        ),
                      ),
                    ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: DSColors.deTextSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
