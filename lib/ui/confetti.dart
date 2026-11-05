import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'kid_look.dart';

/// One burst of confetti falling over its area, then gone. Skipped when the
/// OS asks for reduced motion.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key, this.pieces = 70, this.seed = 1});

  final int pieces;
  final int seed;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  late final List<_Piece> _pieces;

  static const _colors = [
    KidColors.star,
    KidColors.knew,
    KidColors.notYet,
    Color(0xFF7B5CFF),
    Color(0xFF4FC3F7),
    Color(0xFFFF8FB1),
  ];

  @override
  void initState() {
    super.initState();
    final rnd = math.Random(widget.seed);
    _pieces = [
      for (var i = 0; i < widget.pieces; i++)
        _Piece(
          x: rnd.nextDouble(),
          delay: rnd.nextDouble() * 0.25,
          speed: 0.7 + rnd.nextDouble() * 0.6,
          sway: 0.02 + rnd.nextDouble() * 0.05,
          spin: (rnd.nextDouble() - 0.5) * 14,
          size: 7 + rnd.nextDouble() * 7,
          color: _colors[rnd.nextInt(_colors.length)],
          round: rnd.nextBool(),
        ),
    ];
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!flourishes(context)) return const SizedBox.shrink();
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => _c.isCompleted
            ? const SizedBox.shrink()
            : CustomPaint(
                key: const Key('confetti'),
                size: Size.infinite,
                painter: _ConfettiPainter(_pieces, _c.value),
              ),
      ),
    );
  }
}

class _Piece {
  const _Piece({
    required this.x,
    required this.delay,
    required this.speed,
    required this.sway,
    required this.spin,
    required this.size,
    required this.color,
    required this.round,
  });

  final double x, delay, speed, sway, spin, size;
  final Color color;
  final bool round;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.t);

  final List<_Piece> pieces;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in pieces) {
      final local = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final y = -0.1 + local * p.speed * 1.2;
      final x = p.x + math.sin(local * 10 + p.x * 20) * p.sway;
      final fade = local > 0.8 ? (1 - local) / 0.2 : 1.0;
      final paint = Paint()..color = p.color.withValues(alpha: fade);
      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.rotate(local * p.spin);
      if (p.round) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size,
              height: p.size * 0.55,
            ),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
