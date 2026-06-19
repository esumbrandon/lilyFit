import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../dashboard/dashboard_screen.dart';
import '../food_search/food_search_screen.dart';
import '../progress/progress_screen.dart';
import '../profile/profile_screen.dart';
import 'nav_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  double _navBarScale = 0.9;
  double _lastScrollOffset = 0;

  final _screens = const [
    DashboardScreen(),
    FoodSearchScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  void _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final currentOffset = notification.metrics.pixels;
      final delta = currentOffset - _lastScrollOffset;

      // Adjust the bottom nav bar scale based on scroll direction and amount.
      if (delta.abs() > 5) {
        if (delta > 0 && _navBarScale != 0.81) {
          setState(() => _navBarScale = 0.81);
        } else if (delta < 0 && _navBarScale != 0.9) {
          setState(() => _navBarScale = 0.9);
        }
      }
      _lastScrollOffset = currentOffset;
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBody: true,
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _handleScrollNotification(notification);
          return false;
        },
        child: IndexedStack(index: _currentIndex, children: _screens),
      ),
      bottomNavigationBar: AnimatedScale(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        scale: _navBarScale,
        child: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkNavBarBackground
                  : AppColors.navBarBackground,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isDark
                    ? AppColors.darkNavBarBorder
                    : AppColors.navBarBorder,
              ),
              boxShadow: isDark
                  ? AppColors.darkNavBarShadow
                  : AppColors.navBarShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      NavItem(
                        index: 0,
                        currentIndex: _currentIndex,
                        activeIcon: Icons.dashboard_rounded,
                        inactiveIcon: Icons.dashboard_outlined,
                        label: l10n.home,
                        scaleController: _scaleController,
                        scaleAnimation: _scaleAnimation,
                        onTap: () => setState(() => _currentIndex = 0),
                      ),
                      NavItem(
                        index: 1,
                        currentIndex: _currentIndex,
                        activeIcon: Icons.search_rounded,
                        inactiveIcon: Icons.search_rounded,
                        label: l10n.food,
                        scaleController: _scaleController,
                        scaleAnimation: _scaleAnimation,
                        onTap: () => setState(() => _currentIndex = 1),
                      ),
                      NavItem(
                        index: 2,
                        currentIndex: _currentIndex,
                        activeIcon: Icons.insights_rounded,
                        inactiveIcon: Icons.insights_outlined,
                        label: l10n.progress,
                        scaleController: _scaleController,
                        scaleAnimation: _scaleAnimation,
                        onTap: () => setState(() => _currentIndex = 2),
                      ),
                      NavItem(
                        index: 3,
                        currentIndex: _currentIndex,
                        activeIcon: Icons.person_rounded,
                        inactiveIcon: Icons.person_outline_rounded,
                        label: l10n.profile,
                        scaleController: _scaleController,
                        scaleAnimation: _scaleAnimation,
                        onTap: () => setState(() => _currentIndex = 3),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
