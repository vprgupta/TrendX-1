import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A custom pull-to-refresh wrapper that shows a TrendX arc spinner
/// instead of the default CircularProgressIndicator.
class TrendXRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const TrendXRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: Colors.transparent,
      color: Colors.transparent,
      strokeWidth: 0,
      displacement: 60,
      notificationPredicate: (notification) => notification.depth == 0,
      child: Stack(
        children: [
          child,
        ],
      ),
    );
  }
}

/// Animated arc painter for the TrendX pull-to-refresh
class _TrendXArcPainter extends CustomPainter {
  final double progress;
  final double rotation;

  _TrendXArcPainter({required this.progress, required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, bgPaint);

    // Gradient arc
    final arcPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF22D3EE), Color(0xFF6366F1), Color(0xFFEC4899)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final sweepAngle = math.pi * 1.6 * progress.clamp(0, 1);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      rotation - math.pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );

    // Center TX text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'TX',
        style: TextStyle(
          color: Colors.white.withOpacity(0.6 + 0.4 * progress),
          fontSize: radius * 0.6,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(_TrendXArcPainter old) =>
      old.progress != progress || old.rotation != rotation;
}

/// Standalone spinning loader (used during refresh)
class TrendXLoader extends StatefulWidget {
  final double size;
  const TrendXLoader({super.key, this.size = 48});

  @override
  State<TrendXLoader> createState() => _TrendXLoaderState();
}

class _TrendXLoaderState extends State<TrendXLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _rotation = Tween<double>(begin: 0, end: math.pi * 2).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _rotation,
        builder: (_, __) => CustomPaint(
          painter: _TrendXArcPainter(
            progress: 0.75,
            rotation: _rotation.value,
          ),
        ),
      ),
    );
  }
}
