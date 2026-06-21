import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class WaterTrackerCard extends StatelessWidget {
  final int currentGlasses;
  final int goalGlasses;
  final double progress;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final double currentMl;
  final double goalMl;

  const WaterTrackerCard({
    super.key,
    required this.currentGlasses,
    required this.goalGlasses,
    required this.progress,
    required this.onAdd,
    required this.onRemove,
    required this.currentMl,
    required this.goalMl,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkCard : AppColors.card).withValues(
          alpha: 0.65,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💧', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.waterIntake,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(currentMl / 1000).toStringAsFixed(2)} / ${(goalMl / 1000).toStringAsFixed(2)} L',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${currentMl.toInt()} / ${goalMl.toInt()} ml',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Water glasses
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: List.generate(goalGlasses, (index) {
                    final isFilled = index < currentGlasses;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 28,
                      height: 36,
                      decoration: isFilled
                          ? BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.secondary,
                                  AppColors.secondaryDark,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            )
                          : BoxDecoration(
                              color:
                                  (isDark
                                          ? AppColors.darkCardLight
                                          : AppColors.cardLight)
                                      .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: (isDark ? Colors.white : Colors.black)
                                    .withValues(alpha: 0.05),
                                width: 1,
                              ),
                            ),
                      child: isFilled
                          ? const Icon(
                              Icons.water_drop,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: value,
                  backgroundColor: isDark
                      ? AppColors.darkCardLight.withValues(alpha: 0.5)
                      : AppColors.cardLight.withValues(alpha: 0.5),
                  valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
                  minHeight: 6,
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: currentGlasses > 0
                      ? () {
                          HapticFeedback.lightImpact();
                          onRemove();
                        }
                      : null,
                  icon: const Icon(Icons.remove, size: 18),
                  label: Text(AppLocalizations.of(context)!.removeGlass),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    disabledForegroundColor:
                        (isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.textTertiary)
                            .withAlpha(100),
                    side: BorderSide(
                      color: currentGlasses > 0
                          ? (isDark ? AppColors.darkBorder : AppColors.border)
                          : (isDark ? AppColors.darkBorder : AppColors.border)
                                .withAlpha(50),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onAdd();
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(AppLocalizations.of(context)!.addGlass),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
