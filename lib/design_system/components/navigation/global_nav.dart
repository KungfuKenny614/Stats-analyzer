import 'package:flutter/material.dart';
import 'package:stats_analyzer/design_system/tokens/colors.dart';
import 'package:stats_analyzer/design_system/tokens/spacing.dart';
import 'package:stats_analyzer/design_system/tokens/typography.dart';
import 'package:stats_analyzer/design_system/tokens/elevation.dart';

class GlobalNav extends StatelessWidget {
  final String title;
  final String league;
  final VoidCallback? onSearch;
  final VoidCallback? onNotifications;
  final VoidCallback? onProfile;
  final Widget? trailing;
  final Widget? userAvatar;
  final VoidCallback? onSignOut;

  const GlobalNav({
    super.key,
    required this.title,
    required this.league,
    this.onSearch,
    this.onNotifications,
    this.onProfile,
    this.trailing,
    this.userAvatar,
    this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xl),
      decoration: BoxDecoration(
        color: DSColors.surface,
        border: Border(
          bottom: BorderSide(
            color: DSColors.border.withOpacity(0.3),
            width: 1,
          ),
        ),
        boxShadow: DSElevation.level1,
      ),
      child: Row(
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: DSColors.info,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.diamond_rounded,
                    color: DSColors.textInverse,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: DSSpacing.md),
              Text(
                title,
                style: DSTypography.headingSM.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          
          const SizedBox(width: DSSpacing.xl),
          
          // League switcher
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.md,
              vertical: DSSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: DSColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  league,
                  style: DSTypography.label.copyWith(
                    color: DSColors.textSecondary,
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 18,
                  color: DSColors.textTertiary,
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Search
          GestureDetector(
            onTap: onSearch,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.md,
                vertical: DSSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: DSColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: DSColors.textTertiary,
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Text(
                    'Search...',
                    style: DSTypography.bodySM.copyWith(
                      color: DSColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: DSColors.surface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: DSColors.border,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '⌘K',
                      style: DSTypography.caption.copyWith(
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: DSSpacing.md),
          
          // Notifications
          GestureDetector(
            onTap: onNotifications,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DSColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_rounded,
                    size: 20,
                    color: DSColors.textSecondary,
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: DSColors.negative,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: DSSpacing.sm),
          
          // User Avatar
          if (userAvatar != null)
            GestureDetector(
              onTap: () {
                _showUserMenu(context);
              },
              child: userAvatar,
            )
          else
            GestureDetector(
              onTap: onProfile,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: DSColors.infoSurface,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'U',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: DSColors.info,
                    ),
                  ),
                ),
              ),
            ),
          
          if (trailing != null) ...[
            const SizedBox(width: DSSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );
  }

  void _showUserMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(DSSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: DSColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: DSSpacing.lg),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: DSColors.infoSurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'U',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: DSColors.info,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User',
                        style: DSTypography.bodyMD.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'user@diamondedge.com',
                        style: DSTypography.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_rounded),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_rounded),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: DSColors.negative),
              title: const Text(
                'Sign Out',
                style: TextStyle(color: DSColors.negative),
              ),
              onTap: () {
                Navigator.pop(context);
                if (onSignOut != null) onSignOut!();
              },
            ),
          ],
        ),
      ),
    );
  }
}
