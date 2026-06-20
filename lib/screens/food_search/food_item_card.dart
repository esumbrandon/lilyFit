import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/food_item.dart';
import '../../theme/app_theme.dart';
import '../../data/food_database.dart';

class FoodItemCard extends StatefulWidget {
  final FoodItem food;
  final VoidCallback onTap;
  final int index;

  const FoodItemCard({
    super.key,
    required this.food,
    required this.onTap,
    required this.index,
  });

  @override
  State<FoodItemCard> createState() => _FoodItemCardState();
}

class _FoodItemCardState extends State<FoodItemCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    // Stagger first ~9 items; beyond that animate immediately
    final delay = (widget.index * 30).clamp(0, 240);
    if (delay == 0) {
      _entrance.forward();
    } else {
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted) _entrance.forward();
      });
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final opacity = CurvedAnimation(parent: _entrance, curve: Curves.easeOut);
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic));

    return FadeTransition(
      opacity: opacity,
      child: SlideTransition(
        position: slide,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 80),
          curve: Curves.easeOut,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: (isDark ? AppColors.darkCard : AppColors.card).withValues(alpha: 0.6),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onTap();
                },
                onTapDown: (_) => setState(() => _pressed = true),
                onTapUp: (_) => setState(() => _pressed = false),
                onTapCancel: () => setState(() => _pressed = false),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      // Emoji
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: (isDark
                              ? AppColors.darkCardLight
                              : AppColors.cardLight).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          widget.food.emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.food.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${widget.food.servingSize} · ${FoodDatabase.regionLabel(widget.food.region)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      // Calories badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${widget.food.calories.toInt()} kcal',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
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
