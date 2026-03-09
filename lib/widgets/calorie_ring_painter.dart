import 'dart:math' as math;
import 'package:flutter/material.dart';

class CalorieRingPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final List<Color> gradientColors;
  final double strokeWidth;

  CalorieRingPainter({
    required this.progress,
    this.backgroundColor = const Color(0xFF1C1C3C),
    this.gradientColors = const [Color(0xFF4ADE80), Color(0xFF22D3EE)],
    this.strokeWidth = 14,
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
      ..color = Colors.white
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
              gradientColors: isOver
                  ? [const Color(0xFFEF4444), const Color(0xFFFBBF24)]
                  : [const Color(0xFF4ADE80), const Color(0xFF22D3EE)],
              strokeWidth: 16,
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
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isOver ? 'over limit' : 'kcal left',
                    style: TextStyle(
                      fontSize: size * 0.07,
                      color: Colors.white.withAlpha(150),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${consumed.toInt()} / ${target.toInt()} kcal',
                      style: TextStyle(
                        fontSize: size * 0.055,
                        color: Colors.white.withAlpha(200),
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
