import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'kid_look.dart';

enum MascotMood { happy, cheer, encourage, sleepy }

/// "Sunny", the app's guide: a round sun-blob drawn in code. Blinks and
/// bobs gently when ambient motion is on; reacts with [mood].
class Mascot extends ConsumerStatefulWidget {
  const Mascot({super.key, this.mood = MascotMood.happy, this.size = 120});

  final MascotMood mood;
  final double size;

  @override
  ConsumerState<Mascot> createState() => _MascotState();
}

class _MascotState extends ConsumerState<Mascot>
    with SingleTickerProviderStateMixin {
  // One 4 s loop drives both the bob and an occasional blink.
  late final AnimationController _idle = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );

  @override
  void dispose() {
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moving = ambientMotion(context, ref);
    if (moving && !_idle.isAnimating) {
      _idle.repeat();
    } else if (!moving && _idle.isAnimating) {
      _idle.stop();
    }
    return Semantics(
      label: 'Sunny',
      image: true,
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, a) => ScaleTransition(
            scale: Tween(
              begin: 0.85,
              end: 1.0,
            ).animate(CurvedAnimation(parent: a, curve: Curves.elasticOut)),
            child: child,
          ),
          child: CustomPaint(
            key: ValueKey(widget.mood),
            size: Size.square(widget.size),
            painter: _MascotPainter(widget.mood, _idle),
          ),
        ),
      ),
    );
  }
}

class _MascotPainter extends CustomPainter {
  _MascotPainter(this.mood, this.idle) : super(repaint: idle);

  final MascotMood mood;
  final Animation<double> idle;

  static const _body = Color(0xFFFFC93C);
  static const _bodyLight = Color(0xFFFFE27A);
  static const _ray = Color(0xFFFFA62B);
  static const _cheek = Color(0xFFFF8A80);

  @override
  void paint(Canvas canvas, Size size) {
    final t = idle.value;
    final s = size.width;
    final bob = math.sin(t * 2 * math.pi) * s * 0.025;
    final c = Offset(s / 2, s / 2 + bob);
    final r = s * 0.33;

    // Rays: rounded triangles around the body; spin a little when cheering.
    final spin = mood == MascotMood.cheer ? 0.12 : 0.0;
    final rayPaint = Paint()..color = _ray;
    for (var i = 0; i < 10; i++) {
      final a = i / 10 * 2 * math.pi + spin + t * 0.3;
      final tip = c + Offset(math.cos(a), math.sin(a)) * r * 1.42;
      final l = c + Offset(math.cos(a - 0.2), math.sin(a - 0.2)) * r * 0.98;
      final rr = c + Offset(math.cos(a + 0.2), math.sin(a + 0.2)) * r * 0.98;
      canvas.drawPath(
        Path()
          ..moveTo(l.dx, l.dy)
          ..quadraticBezierTo(tip.dx, tip.dy, rr.dx, rr.dy)
          ..close(),
        rayPaint,
      );
    }

    // Body with a soft highlight.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 1,
          colors: const [_bodyLight, _body],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );

    final ink = Paint()
      ..color = KidColors.ink
      ..strokeCap = StrokeCap.round
      ..strokeWidth = s * 0.03
      ..style = PaintingStyle.stroke;
    final inkFill = Paint()..color = KidColors.ink;
    final eyeY = c.dy - r * 0.12;
    final eyeDx = r * 0.36;

    // Eyes: blink briefly once per loop.
    final blink = (t > 0.92 && t < 0.97);
    for (final dx in [-eyeDx, eyeDx]) {
      final e = Offset(c.dx + dx, eyeY);
      if (mood == MascotMood.cheer) {
        // Happy closed eyes: ^ ^
        canvas.drawArc(
          Rect.fromCenter(center: e, width: r * 0.3, height: r * 0.26),
          math.pi,
          math.pi,
          false,
          ink,
        );
      } else if (mood == MascotMood.sleepy || blink) {
        canvas.drawLine(
          e.translate(-r * 0.12, 0),
          e.translate(r * 0.12, 0),
          ink,
        );
      } else {
        canvas.drawOval(
          Rect.fromCenter(center: e, width: r * 0.2, height: r * 0.28),
          inkFill,
        );
        canvas.drawCircle(
          e.translate(r * 0.035, -r * 0.06),
          r * 0.045,
          Paint()..color = Colors.white,
        );
      }
    }

    // Cheeks.
    final cheek = Paint()..color = _cheek.withValues(alpha: 0.55);
    for (final dx in [-r * 0.6, r * 0.6]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(c.dx + dx, c.dy + r * 0.16),
          width: r * 0.28,
          height: r * 0.17,
        ),
        cheek,
      );
    }

    // Mouth.
    final m = Offset(c.dx, c.dy + r * 0.24);
    switch (mood) {
      case MascotMood.cheer:
        final mouth = Path()
          ..moveTo(m.dx - r * 0.3, m.dy - r * 0.06)
          ..quadraticBezierTo(
            m.dx,
            m.dy + r * 0.5,
            m.dx + r * 0.3,
            m.dy - r * 0.06,
          )
          ..close();
        canvas.drawPath(mouth, inkFill);
        canvas.drawCircle(
          m.translate(0, r * 0.16),
          r * 0.09,
          Paint()..color = const Color(0xFFFF6F61),
        );
      case MascotMood.encourage:
        canvas.drawArc(
          Rect.fromCenter(center: m, width: r * 0.36, height: r * 0.22),
          0.2,
          math.pi - 0.4,
          false,
          ink,
        );
      case MascotMood.sleepy:
        canvas.drawCircle(m.translate(0, r * 0.04), r * 0.06, inkFill);
      case MascotMood.happy:
        canvas.drawArc(
          Rect.fromCenter(center: m, width: r * 0.5, height: r * 0.36),
          0.15,
          math.pi - 0.3,
          false,
          ink,
        );
    }
  }

  @override
  bool shouldRepaint(_MascotPainter old) => old.mood != mood;
}

/// A rounded speech bubble that points down-left toward the mascot.
class SpeechBubble extends StatelessWidget {
  const SpeechBubble({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BubblePainter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
        child: child,
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height - 12),
      const Radius.circular(22),
    );
    final tail = Path()
      ..moveTo(size.width * 0.5 - 14, size.height - 13)
      ..lineTo(size.width * 0.5, size.height)
      ..lineTo(size.width * 0.5 + 14, size.height - 13)
      ..close();
    final shadow = Paint()..color = KidColors.ink.withValues(alpha: 0.12);
    canvas.drawRRect(body.shift(const Offset(0, 4)), shadow);
    final p = Paint()..color = Colors.white;
    canvas.drawRRect(body, p);
    canvas.drawPath(tail, p);
  }

  @override
  bool shouldRepaint(_BubblePainter old) => false;
}
