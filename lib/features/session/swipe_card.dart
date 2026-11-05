import 'dart:math' as math;

import 'package:flutter/material.dart';

enum SwipeDirection { left, right, up }

/// A card the child drags left, right or up. Past the threshold it flies off
/// and reports the direction; otherwise it springs back. [hintFor] labels the
/// card while dragging (e.g. "Knew it").
class SwipeCard extends StatefulWidget {
  const SwipeCard({
    super.key,
    required this.child,
    required this.onSwiped,
    required this.hintFor,
    this.allowUp = true,
  });

  final Widget child;
  final ValueChanged<SwipeDirection> onSwiped;
  final ({String label, Color color}) Function(SwipeDirection) hintFor;
  final bool allowUp;

  @override
  State<SwipeCard> createState() => SwipeCardState();
}

class SwipeCardState extends State<SwipeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  Offset _drag = Offset.zero;
  Animation<Offset>? _fly;
  Size _size = Size.zero;

  static const _threshold = 0.28; // share of card width/height
  static const _flingVelocity = 900.0;

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Offset get _offset => _fly?.value ?? _drag;

  SwipeDirection? _directionOf(Offset o) {
    if (_size == Size.zero) return null;
    if (widget.allowUp &&
        -o.dy > _size.height * _threshold &&
        o.dy.abs() > o.dx.abs()) {
      return SwipeDirection.up;
    }
    if (o.dx > _size.width * _threshold) return SwipeDirection.right;
    if (o.dx < -_size.width * _threshold) return SwipeDirection.left;
    return null;
  }

  /// Animates the card off-screen in [direction], then reports it. Used by
  /// the answer buttons too, so buttons and swipes look the same.
  Future<void> flyOut(SwipeDirection direction) async {
    final w = _size.width == 0 ? 400.0 : _size.width;
    final h = _size.height == 0 ? 600.0 : _size.height;
    final end = switch (direction) {
      SwipeDirection.right => Offset(w * 1.6, _drag.dy),
      SwipeDirection.left => Offset(-w * 1.6, _drag.dy),
      SwipeDirection.up => Offset(_drag.dx, -h * 1.4),
    };
    await _animateTo(end);
    if (!mounted) return;
    widget.onSwiped(direction);
    // This widget is reused for the next card: bring it back to the centre.
    setState(() => _drag = Offset.zero);
  }

  Future<void> _animateTo(Offset end) async {
    _fly = Tween(begin: _drag, end: end).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOut),
    )..addListener(() => setState(() {}));
    await _anim.forward(from: 0);
    _drag = end;
    _fly = null;
  }

  void _onEnd(DragEndDetails d) {
    final v = d.velocity.pixelsPerSecond;
    var dir = _directionOf(_drag);
    if (dir == null && v.distance > _flingVelocity) {
      if (widget.allowUp && -v.dy > v.dx.abs()) {
        dir = SwipeDirection.up;
      } else if (v.dx.abs() > v.dy.abs()) {
        dir = v.dx > 0 ? SwipeDirection.right : SwipeDirection.left;
      }
    }
    if (dir != null) {
      flyOut(dir);
    } else {
      _animateTo(Offset.zero).then((_) => setState(() => _drag = Offset.zero));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _size = constraints.biggest;
        final o = _offset;
        final dir = _directionOf(o);
        final progress = _size.width == 0
            ? 0.0
            : (math.max(o.dx.abs() / _size.width, -o.dy / _size.height) /
                      _threshold)
                  .clamp(0.0, 1.0);
        final hintDir =
            dir ??
            (o.dx.abs() >= -o.dy || !widget.allowUp
                ? (o.dx >= 0 ? SwipeDirection.right : SwipeDirection.left)
                : SwipeDirection.up);
        final hint = widget.hintFor(hintDir);
        return GestureDetector(
          onPanUpdate: (d) => setState(() => _drag += d.delta),
          onPanEnd: _onEnd,
          child: Transform.translate(
            offset: o,
            child: Transform.rotate(
              angle: _size.width == 0 ? 0 : o.dx / _size.width * 0.35,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  widget.child,
                  if (o != Offset.zero)
                    IgnorePointer(
                      child: Opacity(
                        opacity: progress,
                        child: Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.zero,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: hint.color,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                child: Text(
                                  hint.label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
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
