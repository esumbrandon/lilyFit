import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/food_database.dart';
import '../../theme/app_theme.dart';

class RegionFilterWidget extends StatelessWidget {
  final String selectedRegion;
  final ValueChanged<String> onRegionSelected;
  final ScrollController scrollController;

  const RegionFilterWidget({
    super.key,
    required this.selectedRegion,
    required this.onRegionSelected,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: FoodDatabase.regions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final region = FoodDatabase.regions[index];
          final selected = selectedRegion == region;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              if (region == selectedRegion) return;
              onRegionSelected(region);
              // Scroll list back to top
              if (scrollController.hasClients) {
                scrollController.jumpTo(0);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: selected ? AppColors.primaryGradient : null,
                color: selected
                    ? null
                    : (isDark ? AppColors.darkCard : AppColors.card),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : (isDark
                            ? AppColors.darkCardLight
                            : AppColors.cardLight),
                  width: 1.5,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(60),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Todo, to add icons uncomment this lines.
                  // Text(
                  //   FoodDatabase.regionEmoji(region),
                  //   style: const TextStyle(fontSize: 18),
                  // ),
                  const SizedBox(width: 7),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    style: TextStyle(
                      color: selected
                          ? AppColors.onPrimary
                          : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary),
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                    child: Text(FoodDatabase.regionLabel(region)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
