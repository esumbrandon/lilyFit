import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CalorieRingPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final List<Color> gradientColors;
  final double strokeWidth;
  final Color dotColor;

  CalorieRingPainter({
    required this.progress,
    required this.backgroundColor,
    this.gradientColors = const [AppColors.primary, AppColors.accent],
    this.strokeWidth = 14,
    required this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background track
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0) return;

    final clampedProgress = progress.clamp(0.0, 1.0);
    final sweepAngle = 2 * math.pi * clampedProgress;

    // Glow effect
    final glowPaint = Paint()
      ..color = gradientColors[0].withAlpha(60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, glowPaint);

    // Progress arc with gradient
    final sweepGradient = SweepGradient(
      colors: [gradientColors[0], gradientColors[1], gradientColors[0]],
      stops: const [0.0, 0.5, 1.0],
      transform: const GradientRotation(-math.pi / 2),
    );

    final progressPaint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, progressPaint);

    // End dot
    final dotAngle = -math.pi / 2 + sweepAngle;
    final dotCenter = Offset(
      center.dx + radius * math.cos(dotAngle),
      center.dy + radius * math.sin(dotAngle),
    );
    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(dotCenter, strokeWidth / 3, dotPaint);
  }

  @override
  bool shouldRepaint(CalorieRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class CalorieRingWidget extends StatelessWidget {
  final double consumed;
  final double target;
  final double size;

  const CalorieRingWidget({
    super.key,
    required this.consumed,
    required this.target,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? consumed / target : 0.0;
    final remaining = (target - consumed).clamp(0, double.infinity);
    final isOver = consumed > target;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: CalorieRingPainter(
              progress: value,
              backgroundColor: isDark
                  ? AppColors.darkCardLight
                  : AppColors.cardLight,
              gradientColors: isOver
                  ? [AppColors.accent, AppColors.carbs]
                  : [AppColors.primary, AppColors.accent],
              strokeWidth: 16,
              dotColor: isDark ? AppColors.darkCard : AppColors.card,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    remaining.toInt().toString(),
                    style: TextStyle(
                      fontSize: size * 0.18,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isOver ? 'over limit' : 'kcal left',
                    style: TextStyle(
                      fontSize: size * 0.07,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceMuted
                          : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                    ),
                    child: Text(
                      '${consumed.toInt()} / ${target.toInt()} kcal',
                      style: TextStyle(
                        fontSize: size * 0.055,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
