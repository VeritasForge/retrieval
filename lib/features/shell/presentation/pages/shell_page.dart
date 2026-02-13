import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../category/presentation/pages/category_management_page.dart';
import '../../../review/presentation/pages/home_page.dart';
import '../../../statistics/presentation/pages/statistics_page.dart';
import '../../../strategy/presentation/pages/strategy_page.dart';

/// 현재 선택된 탭 인덱스
final selectedTabProvider = StateProvider<int>((ref) => 0);

/// 앱 셸 페이지 (Bottom Navigation + IndexedStack)
class ShellPage extends ConsumerWidget {
  const ShellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: [
          const HomePage(),
          const StrategyPage(),
          const CategoryManagementPage(),
          const StatisticsPage(),
          const _PlaceholderPage(title: 'Settings'),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.95),
              border: const Border(
                top: BorderSide(
                  color: AppColors.surfaceVariant,
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.home,
                      label: 'HOME',
                      isSelected: selectedIndex == 0,
                      onTap: () => ref
                          .read(selectedTabProvider.notifier)
                          .state = 0,
                    ),
                    _NavItem(
                      icon: Icons.tune,
                      label: 'STRATEGIES',
                      isSelected: selectedIndex == 1,
                      onTap: () => ref
                          .read(selectedTabProvider.notifier)
                          .state = 1,
                    ),
                    _NavItem(
                      icon: Icons.category,
                      label: 'CATEGORIES',
                      isSelected: selectedIndex == 2,
                      onTap: () => ref
                          .read(selectedTabProvider.notifier)
                          .state = 2,
                    ),
                    _NavItem(
                      icon: Icons.bar_chart_rounded,
                      label: 'STATS',
                      isSelected: selectedIndex == 3,
                      onTap: () => ref
                          .read(selectedTabProvider.notifier)
                          .state = 3,
                    ),
                    _NavItem(
                      icon: Icons.settings,
                      label: 'GEAR',
                      isSelected: false,
                      isDisabled: true,
                      onTap: null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.isDisabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDisabled
        ? AppColors.textQuaternary.withValues(alpha: 0.2)
        : isSelected
            ? AppColors.indigo
            : AppColors.textQuaternary;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: isDisabled ? 0.2 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: AppColors.textQuaternary,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
