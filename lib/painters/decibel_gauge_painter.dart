import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/ulvex_theme.dart';

class DecibelGaugePainter extends CustomPainter {
  final double dbValue;

  DecibelGaugePainter({required this.dbValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.85);
    final radius = min(size.width / 2, size.height * 0.8) - 16;

    // Track arc (pi arc from -pi to 0)
    final trackPaint = Paint()
      ..color = UlvexTheme.edge
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      trackPaint,
    );

    // Colored Arc: 30dB (0.0) to 120dB (1.0)
    final fraction = ((dbValue - 30) / (120 - 30)).clamp(0.0, 1.0);
    final activeAngle = pi * fraction;

    final arcPaint = Paint()
      ..shader = SweepGradient(
        colors: const [
          UlvexTheme.accent,
          UlvexTheme.warning,
          UlvexTheme.danger,
        ],
        stops: const [0.0, 0.6, 1.0],
        transform: const GradientRotation(pi),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 14;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      activeAngle,
      false,
      arcPaint,
    );

    // Gauge Needle
    final needleAngle = pi + activeAngle;
    final needleEnd = Offset(
      center.dx + (radius - 12) * cos(needleAngle),
      center.dy + (radius - 12) * sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleEnd, needlePaint);

    final centerHubPaint = Paint()..color = UlvexTheme.accent;
    canvas.drawCircle(center, 8, centerHubPaint);
    canvas.drawCircle(center, 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant DecibelGaugePainter oldDelegate) {
    return oldDelegate.dbValue != dbValue;
  }
}
