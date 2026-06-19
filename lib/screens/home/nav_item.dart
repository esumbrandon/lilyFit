import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

class NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  final AnimationController scaleController;
  final Animation<double> scaleAnimation;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.index,
    required this.currentIndex,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    required this.scaleController,
    required this.scaleAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTapDown: (_) {
        scaleController.forward();
      },
      onTapUp: (_) {
        scaleController.reverse();
      },
      onTapCancel: () {
        scaleController.reverse();
      },
      onTap: () {
        if (currentIndex != index) {
          HapticFeedback.selectionClick();
          onTap();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withAlpha(20)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : inactiveIcon,
                color: isActive
                    ? AppColors.primary
                    : (isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.textTertiary),
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? AppColors.primary
                      : (isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.textTertiary),
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
