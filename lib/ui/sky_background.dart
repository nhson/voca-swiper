import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'kid_look.dart';

/// Illustrated backdrop for child screens: sky gradient, sun, clouds and
/// rolling hills, all drawn in code (no image assets to license).
class SkyBackground extends ConsumerStatefulWidget {
  const SkyBackground({
    super.key,
    required this.look,
    required this.child,
    this.hills = true,
    this.sun = true,
  });

  final KidLook look;
  final Widget child;
  final bool hills;

  /// Off on busy screens (the session) where it would sit behind controls.
  final bool sun;

  @override
  ConsumerState<SkyBackground> createState() => _SkyBackgroundState();
}

class _SkyBackgroundState extends ConsumerState<SkyBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 60),
  );

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moving = ambientMotion(context, ref);
    if (moving && !_drift.isAnimating) {
      _drift.repeat();
    } else if (!moving && _drift.isAnimating) {
      _drift.stop();
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: CustomPaint(
            painter: _SkyPainter(widget.look, _drift, widget.hills, widget.sun),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _SkyPainter extends CustomPainter {
  _SkyPainter(this.look, this.drift, this.hills, this.sun)
    : super(repaint: drift);

  final KidLook look;
  final Animation<double> drift;
  final bool hills;
  final bool sun;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [look.skyTop, look.skyBottom],
        ).createShader(rect),
    );

    // Sun with a soft glow, right side, below the top bar.
    final sunC = Offset(size.width * 0.88, size.height * 0.14);
    final r = math.min(size.width, size.height) * 0.08;
    if (sun) {
      canvas.drawCircle(
        sunC,
        r * 2.1,
        Paint()..color = look.sun.withValues(alpha: 0.18),
      );
      canvas.drawCircle(
        sunC,
        r * 1.5,
        Paint()..color = look.sun.withValues(alpha: 0.28),
      );
      canvas.drawCircle(sunC, r, Paint()..color = look.sun);
    }

    if (look.sparkles) _sparkles(canvas, size);

    // Clouds drift slowly to the right and wrap around.
    final t = drift.value;
    final unit = size.width / 10;
    for (final (y, scale, speed, phase) in const [
      (0.13, 1.1, 1.0, 0.05),
      (0.27, 0.8, 0.6, 0.55),
      (0.40, 0.65, 1.4, 0.3),
    ]) {
      final span = size.width + unit * 6;
      final x = ((phase + t * speed) % 1) * span - unit * 3;
      _cloud(canvas, Offset(x, size.height * y), unit * scale);
    }

    if (hills) _hills(canvas, size);
  }

  void _cloud(Canvas canvas, Offset c, double u) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: u * 3.2, height: u * 0.9),
        Radius.circular(u * 0.45),
      ),
      p,
    );
    canvas.drawCircle(c.translate(-u * 0.55, -u * 0.35), u * 0.6, p);
    canvas.drawCircle(c.translate(u * 0.45, -u * 0.45), u * 0.75, p);
  }

  void _sparkles(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    final p = Paint()..color = Colors.white.withValues(alpha: 0.7);
    for (var i = 0; i < 18; i++) {
      final c = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height * 0.45,
      );
      final s = 1.5 + rnd.nextDouble() * 2.5;
      final path = Path()
        ..moveTo(c.dx, c.dy - s * 2)
        ..quadraticBezierTo(c.dx, c.dy, c.dx + s * 2, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + s * 2)
        ..quadraticBezierTo(c.dx, c.dy, c.dx - s * 2, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - s * 2);
      canvas.drawPath(path, p);
    }
  }

  void _hills(Canvas canvas, Size size) {
    final h = size.height;
    final w = size.width;
    final far = Path()
      ..moveTo(0, h * 0.86)
      ..quadraticBezierTo(w * 0.25, h * 0.78, w * 0.55, h * 0.85)
      ..quadraticBezierTo(w * 0.8, h * 0.9, w, h * 0.82)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(far, Paint()..color = look.hillFar);
    final near = Path()
      ..moveTo(0, h * 0.92)
      ..quadraticBezierTo(w * 0.35, h * 0.86, w * 0.7, h * 0.93)
      ..quadraticBezierTo(w * 0.88, h * 0.96, w, h * 0.92)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(near, Paint()..color = look.hillNear);
  }

  @override
  bool shouldRepaint(_SkyPainter old) =>
      old.look != look || old.hills != hills || old.sun != sun;
}
