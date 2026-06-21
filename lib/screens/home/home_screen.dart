import 'dart:ui' show ImageFilter;
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
  bool _isDraggingNav = false;
  double? _dragPositionX;
  int? _draggedHighlightIndex;

  int get _activeHighlightIndex =>
      _isDraggingNav ? (_draggedHighlightIndex ?? _currentIndex) : _currentIndex;

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
              borderRadius: BorderRadius.circular(50),
              boxShadow: isDark
                  ? AppColors.darkNavBarShadow
                  : AppColors.navBarShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: (isDark
                            ? AppColors.darkNavBarBackground
                            : AppColors.navBarBackground)
                        .withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: (isDark
                              ? AppColors.darkNavBarBorder
                              : AppColors.navBarBorder)
                          .withValues(alpha: 0.4),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final totalWidth = constraints.maxWidth;
                        final itemWidth = totalWidth / 4;
                        final l10n = AppLocalizations.of(context)!;
                        return GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onHorizontalDragStart: (details) {
                            setState(() {
                              _isDraggingNav = true;
                              _dragPositionX = details.localPosition.dx;
                              _draggedHighlightIndex =
                                  (_dragPositionX! / itemWidth).floor().clamp(0, 3);
                            });
                          },
                          onHorizontalDragUpdate: (details) {
                            setState(() {
                              _dragPositionX = details.localPosition.dx;
                              final newHighlightIndex =
                                  (_dragPositionX! / itemWidth).floor().clamp(0, 3);
                              if (newHighlightIndex != _draggedHighlightIndex) {
                                _draggedHighlightIndex = newHighlightIndex;
                                HapticFeedback.selectionClick();
                              }
                            });
                          },
                          onHorizontalDragEnd: (_) {
                            setState(() {
                              _isDraggingNav = false;
                              if (_draggedHighlightIndex != null) {
                                _currentIndex = _draggedHighlightIndex!;
                              }
                              _dragPositionX = null;
                              _draggedHighlightIndex = null;
                            });
                          },
                          onHorizontalDragCancel: () {
                            setState(() {
                              _isDraggingNav = false;
                              _dragPositionX = null;
                              _draggedHighlightIndex = null;
                            });
                          },
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Sliding liquid glass highlight
                              AnimatedPositioned(
                                duration: _isDraggingNav
                                    ? Duration.zero
                                    : const Duration(milliseconds: 350),
                                curve: Curves.easeInOutCubic,
                                left: _isDraggingNav
                                    ? (_dragPositionX! - itemWidth / 2).clamp(0.0, totalWidth - itemWidth)
                                    : _currentIndex * itemWidth,
                                width: itemWidth,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primaryDark,
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: const BorderRadius.all(Radius.circular(40)),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.35),
                                      width: 1.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.25),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(Radius.circular(40)),
                                    child: Stack(
                                      children: [
                                        // Top Glare
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          right: 0,
                                          height: 14,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white.withValues(alpha: 0.35),
                                                  Colors.white.withValues(alpha: 0.0),
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Bottom reflection
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          height: 8,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white.withValues(alpha: 0.0),
                                                  Colors.white.withValues(alpha: 0.15),
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Navigation Items Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  NavItem(
                                    index: 0,
                                    currentIndex: _activeHighlightIndex,
                                    activeIcon: Icons.dashboard_rounded,
                                    inactiveIcon: Icons.dashboard_outlined,
                                    label: l10n.home,
                                    scaleController: _scaleController,
                                    scaleAnimation: _scaleAnimation,
                                    onTap: () => setState(() => _currentIndex = 0),
                                  ),
                                  NavItem(
                                    index: 1,
                                    currentIndex: _activeHighlightIndex,
                                    activeIcon: Icons.search_rounded,
                                    inactiveIcon: Icons.search_rounded,
                                    label: l10n.food,
                                    scaleController: _scaleController,
                                    scaleAnimation: _scaleAnimation,
                                    onTap: () => setState(() => _currentIndex = 1),
                                  ),
                                  NavItem(
                                    index: 2,
                                    currentIndex: _activeHighlightIndex,
                                    activeIcon: Icons.insights_rounded,
                                    inactiveIcon: Icons.insights_outlined,
                                    label: l10n.progress,
                                    scaleController: _scaleController,
                                    scaleAnimation: _scaleAnimation,
                                    onTap: () => setState(() => _currentIndex = 2),
                                  ),
                                  NavItem(
                                    index: 3,
                                    currentIndex: _activeHighlightIndex,
                                    activeIcon: Icons.person_rounded,
                                    inactiveIcon: Icons.person_outline_rounded,
                                    label: l10n.profile,
                                    scaleController: _scaleController,
                                    scaleAnimation: _scaleAnimation,
                                    onTap: () => setState(() => _currentIndex = 3),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}