import 'package:flutter/material.dart';
import 'package:stats_analyzer/config/premium_theme.dart';
import 'package:stats_analyzer/models/mlb_outlier_models.dart';

class PremiumPropCard extends StatefulWidget {
  final MLBNormalizedMarket market;
  final MLBAnalyticsResult analytics;
  final VoidCallback onTap;
  final bool isSelected;

  const PremiumPropCard({
    super.key,
    required this.market,
    required this.analytics,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  State<PremiumPropCard> createState() => _PremiumPropCardState();
}

class _PremiumPropCardState extends State<PremiumPropCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PremiumTheme.animationFast,
      decoration: BoxDecoration(
        color: widget.isSelected 
            ? PremiumTheme.primarySurface
            : PremiumTheme.surface,
        borderRadius: PremiumTheme.radiusLg,
        border: Border.all(
          color: widget.isSelected
              ? PremiumTheme.primary.withOpacity(0.5)
              : PremiumTheme.divider.withOpacity(0.3),
          width: widget.isSelected ? 2 : 1,
        ),
        boxShadow: _isHovered 
            ? PremiumTheme.shadowLg
            : PremiumTheme.shadowSm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: PremiumTheme.radiusLg,
          onHover: (hovered) {
            setState(() {
              _isHovered = hovered;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(PremiumTheme.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Player + Team + Status
                Row(
                  children: [
                    // Player initials avatar
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: PremiumTheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          widget.market.playerName.split(' ').map((e) => e[0]).join(''),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: PremiumTheme.primary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: PremiumTheme.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.market.playerName,
                            style: PremiumTheme.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${widget.market.team} @ ${widget.market.opponent}',
                            style: PremiumTheme.caption,
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    _buildStatusBadge(),
                  ],
                ),
                const SizedBox(height: PremiumTheme.spacingMd),
                
                // Middle row: Market + Line + Projection
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricChip(
                        label: widget.market.marketType,
                        value: widget.market.line.toStringAsFixed(1),
                        color: PremiumTheme.textPrimary,
                      ),
                    ),
                    Expanded(
                      child: _buildMetricChip(
                        label: 'Projection',
                        value: (widget.market.line + widget.analytics.ev / 10)
                            .toStringAsFixed(1),
                        color: PremiumTheme.primary,
                      ),
                    ),
                    Expanded(
                      child: _buildMetricChip(
                        label: 'Edge',
                        value: '${widget.analytics.ev > 0 ? "+" : ""}${widget.analytics.ev.toStringAsFixed(1)}%',
                        color: widget.analytics.ev > 3 
                            ? PremiumTheme.success
                            : widget.analytics.ev > 1 
                                ? PremiumTheme.warning
                                : PremiumTheme.error,
                      ),
                    ),
                    Expanded(
                      child: _buildMetricChip(
                        label: 'Confidence',
                        value: '${(widget.analytics.hitRate * 100).toInt()}%',
                        color: widget.analytics.hitRate > 0.7 
                            ? PremiumTheme.success
                            : widget.analytics.hitRate > 0.5 
                                ? PremiumTheme.warning
                                : PremiumTheme.error,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: PremiumTheme.spacingSm),
                
                // Bottom row: Best book + Odds
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          size: 14,
                          color: PremiumTheme.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Best: ${widget.market.bestOverBook}',
                          style: PremiumTheme.labelSmall.copyWith(
                            color: PremiumTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'O ${widget.market.line.toStringAsFixed(1)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: PremiumTheme.spacingSm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: widget.market.bestOverOdds > 0 
                                ? PremiumTheme.successSurface
                                : PremiumTheme.errorSurface,
                            borderRadius: PremiumTheme.radiusSm,
                          ),
                          child: Text(
                            widget.market.bestOverOdds > 0 
                                ? '+${widget.market.bestOverOdds.toInt()}'
                                : widget.market.bestOverOdds.toInt().toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: widget.market.bestOverOdds > 0 
                                  ? PremiumTheme.success
                                  : PremiumTheme.error,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: PremiumTheme.spacingSm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: PremiumTheme.surfaceVariant,
                            borderRadius: PremiumTheme.radiusSm,
                          ),
                          child: Text(
                            widget.market.bestOverBook,
                            style: TextStyle(
                              fontSize: 10,
                              color: PremiumTheme.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Expand indicator on hover
                if (_isHovered)
                  Padding(
                    padding: const EdgeInsets.only(top: PremiumTheme.spacingSm),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'View Details →',
                          style: PremiumTheme.labelSmall.copyWith(
                            color: PremiumTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    if (widget.analytics.isEVPositive) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PremiumTheme.spacingSm,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: PremiumTheme.successSurface,
          borderRadius: PremiumTheme.radiusSm,
          border: Border.all(
            color: PremiumTheme.success.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.trending_up_rounded,
              size: 12,
              color: PremiumTheme.success,
            ),
            const SizedBox(width: 4),
            Text(
              'EV+',
              style: PremiumTheme.labelSmall.copyWith(
                color: PremiumTheme.success,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildMetricChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: PremiumTheme.labelSmall.copyWith(
            color: PremiumTheme.textTertiary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
