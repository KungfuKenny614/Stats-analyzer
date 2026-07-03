import 'package:flutter/material.dart';
import 'package:stats_analyzer/config/premium_theme.dart';

class StickyHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showLiveIndicator;
  final int notificationCount;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;

  const StickyHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
    this.actions,
    this.showLiveIndicator = true,
    this.notificationCount = 0,
    this.onSearchTap,
    this.onNotificationTap,
  });

  @override
  State<StickyHeader> createState() => _StickyHeaderState();
}

class _StickyHeaderState extends State<StickyHeader> {
  double _scrollOffset = 0;
  bool _isScrolled = false;
  bool _isSearchExpanded = false;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          setState(() {
            _scrollOffset = notification.metrics.pixels;
            _isScrolled = _scrollOffset > 20;
          });
        }
        return true;
      },
      child: Container(
        decoration: BoxDecoration(
          color: PremiumTheme.background,
          boxShadow: _isScrolled ? PremiumTheme.shadowSm : [],
          border: Border(
            bottom: BorderSide(
              color: _isScrolled 
                  ? PremiumTheme.divider.withOpacity(0.5)
                  : Colors.transparent,
            ),
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: PremiumTheme.spacingLg,
          vertical: _isScrolled 
              ? PremiumTheme.spacingSm
              : PremiumTheme.spacingLg,
        ),
        child: AnimatedContainer(
          duration: PremiumTheme.animationMedium,
          height: _isScrolled ? 56 : 72,
          child: Row(
            children: [
              // Leading
              if (widget.leading != null)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: widget.leading,
                ),
              
              // Title & subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      style: _isScrolled
                          ? PremiumTheme.titleLarge
                          : PremiumTheme.headlineMedium,
                    ),
                    if (!_isScrolled && widget.subtitle.isNotEmpty)
                      Text(
                        widget.subtitle,
                        style: PremiumTheme.caption,
                      ),
                  ],
                ),
              ),
              
              // Live indicator
              if (widget.showLiveIndicator)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: PremiumTheme.successSurface,
                    borderRadius: PremiumTheme.radiusLg,
                    border: Border.all(
                      color: PremiumTheme.success.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 1000),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: PremiumTheme.success,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: PremiumTheme.success.withOpacity(0.5),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'LIVE',
                        style: PremiumTheme.labelSmall.copyWith(
                          color: PremiumTheme.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(width: 12),
              
              // Search
              GestureDetector(
                onTap: widget.onSearchTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PremiumTheme.surfaceVariant,
                    borderRadius: PremiumTheme.radiusLg,
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: PremiumTheme.textSecondary,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Notifications
              GestureDetector(
                onTap: widget.onNotificationTap,
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: PremiumTheme.surfaceVariant,
                        borderRadius: PremiumTheme.radiusLg,
                      ),
                      child: const Icon(
                        Icons.notifications_rounded,
                        size: 20,
                        color: PremiumTheme.textSecondary,
                      ),
                    ),
                    if (widget.notificationCount > 0)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: PremiumTheme.error,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: PremiumTheme.surface,
                              width: 2,
                            ),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            widget.notificationCount > 9 
                                ? '9+' 
                                : widget.notificationCount.toString(),
                            style: const TextStyle(
                              color: PremiumTheme.textInverse,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Actions
              if (widget.actions != null) ...[
                const SizedBox(width: 8),
                ...widget.actions!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
