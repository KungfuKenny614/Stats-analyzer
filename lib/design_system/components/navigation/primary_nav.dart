import 'package:flutter/material.dart';
import 'package:stats_analyzer/design_system/tokens/colors.dart';
import 'package:stats_analyzer/design_system/tokens/spacing.dart';
import 'package:stats_analyzer/design_system/tokens/typography.dart';

class PrimaryNavItem {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final int badgeCount;

  const PrimaryNavItem({
    required this.label,
    required this.icon,
    this.onTap,
    this.badgeCount = 0,
  });
}

class PrimaryNav extends StatefulWidget {
  final List<PrimaryNavItem> items;
  final int selectedIndex;

  const PrimaryNav({
    super.key,
    required this.items,
    this.selectedIndex = 0,
  });

  @override
  State<PrimaryNav> createState() => _PrimaryNavState();
}

class _PrimaryNavState extends State<PrimaryNav> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          const SizedBox(height: DSSpacing.lg),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final isSelected = _selectedIndex == index;
                return _buildNavItem(
                  item: item,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                    item.onTap?.call();
                  },
                );
              },
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: DSColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.settings_rounded,
                size: 18,
                color: DSColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: DSSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required PrimaryNavItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        margin: const EdgeInsets.symmetric(
          horizontal: DSSpacing.sm,
          vertical: DSSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? DSColors.infoSurface
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? DSColors.info.withOpacity(0.3)
                : Colors.transparent,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.icon,
                    size: 22,
                    color: isSelected 
                        ? DSColors.info
                        : DSColors.textTertiary,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.label,
                    style: DSTypography.caption.copyWith(
                      color: isSelected 
                          ? DSColors.info
                          : DSColors.textTertiary,
                      fontWeight: isSelected 
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (item.badgeCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: DSColors.negative,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    item.badgeCount > 9 ? '9+' : item.badgeCount.toString(),
                    style: const TextStyle(
                      color: DSColors.textInverse,
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
    );
  }
}
