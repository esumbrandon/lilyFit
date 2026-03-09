import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class WaterTrackerCard extends StatelessWidget {
  final int currentGlasses;
  final int goalGlasses;
  final double progress;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const WaterTrackerCard({
    super.key,
    required this.currentGlasses,
    required this.goalGlasses,
    required this.progress,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💧', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Water Intake',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${currentGlasses * 250} / ${goalGlasses * 250} ml',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
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
                      decoration: BoxDecoration(
                        color: isFilled
                            ? AppColors.secondary.withAlpha(200)
                            : AppColors.cardLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isFilled
                              ? AppColors.secondary.withAlpha(100)
                              : Colors.transparent,
                        ),
                        boxShadow: isFilled
                            ? [
                                BoxShadow(
                                  color: AppColors.secondary.withAlpha(40),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: isFilled
                          ? const Icon(Icons.water_drop, size: 14, color: Colors.white)
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
                  backgroundColor: AppColors.cardLight,
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
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onRemove();
                  },
                  icon: const Icon(Icons.remove, size: 18),
                  label: const Text('Remove'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: Colors.white.withAlpha(20)),
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
                  label: const Text('Add Glass'),
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
