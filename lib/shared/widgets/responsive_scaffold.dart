import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_constants.dart';
import '../../core/theme/app_colors.dart';

/// Adaptive layout shell: bottom nav on mobile, side rail on tablet/desktop.
class ResponsiveScaffold extends StatelessWidget {
  final Widget child;

  const ResponsiveScaffold({super.key, required this.child});

  static const _navItems = [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard', path: '/'),
    _NavItem(icon: Icons.bolt_rounded, label: 'Activities', path: '/activities'),
    _NavItem(icon: Icons.insights_rounded, label: 'Skills', path: '/skills'),
    _NavItem(icon: Icons.code_rounded, label: 'Projects', path: '/projects'),
    _NavItem(icon: Icons.web_rounded, label: 'Portfolio', path: '/portfolio'),
    _NavItem(icon: Icons.description_rounded, label: 'Resume', path: '/resume'),
    _NavItem(icon: Icons.settings_rounded, label: 'Settings', path: '/settings'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _navItems.length; i++) {
      if (_navItems[i].path == location) return i;
    }
    // Match sub-routes
    if (location.startsWith('/activities')) return 1;
    if (location.startsWith('/projects')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;
    final currentIdx = _currentIndex(context);

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            _SideNav(
              items: _navItems,
              currentIndex: currentIdx,
              onTap: (i) => context.go(_navItems[i].path),
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNav(
        items: _navItems.take(5).toList(), // Show first 5 on mobile
        currentIndex: currentIdx > 4 ? 0 : currentIdx,
        onTap: (i) => context.go(_navItems[i].path),
      ),
    );
  }
}

// ── Side Navigation for Desktop/Tablet ──

class _SideNav extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _SideNav({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: AppConstants.sideNavWidth,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.glassBorder : Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.track_changes,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Nav items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = index == currentIndex;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => onTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.15),
                                    AppColors.primary.withValues(alpha: 0.05),
                                  ],
                                )
                              : null,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              color: isSelected
                                  ? AppColors.primary
                                  : isDark
                                      ? AppColors.textTertiaryDark
                                      : AppColors.textTertiaryLight,
                              size: 22,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              item.label,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.primary
                                    : isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Bottom brand text
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'v1.0.0',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Navigation for Mobile ──

class _BottomNav extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.glassBorder : Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;

              return GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.15),
                              AppColors.primary.withValues(alpha: 0.05),
                            ],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        color: isSelected
                            ? AppColors.primary
                            : isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiaryLight,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : isDark
                                  ? AppColors.textTertiaryDark
                                  : AppColors.textTertiaryLight,
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Nav Item model ──

class _NavItem {
  final IconData icon;
  final String label;
  final String path;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.path,
  });
}
