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
    return Expanded(
      child: InkWell(
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
        borderRadius: BorderRadius.circular(50),
        hoverColor: AppColors.primary.withValues(alpha: 1),
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<Color?>(
                  duration: const Duration(milliseconds: 250),
                  tween: ColorTween(
                    end: isActive
                        ? Colors.white
                        : (isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.textTertiary),
                  ),
                  builder: (context, color, child) {
                    return Icon(
                      isActive ? activeIcon : inactiveIcon,
                      color: color,
                      size: 22,
                    );
                  },
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : (isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.textTertiary),
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
