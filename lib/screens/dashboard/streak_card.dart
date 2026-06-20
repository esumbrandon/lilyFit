import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class StreakCard extends StatelessWidget {
  final int currentStreak;

  const StreakCard({super.key, required this.currentStreak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.carbs.withValues(alpha: 0.25),
            AppColors.carbs.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.carbs.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$currentStreak ${currentStreak == 1 ? "Day" : "Days"}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.carbs,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Streak',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.carbs.withValues(alpha: 0.8),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
