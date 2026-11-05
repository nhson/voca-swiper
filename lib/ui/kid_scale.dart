import 'package:flutter/material.dart';

/// Grows a child screen on tablets so it isn't a phone layout floating in
/// empty space. Lays [child] out at a phone-like size, then scales the
/// result (vector text and shapes stay crisp; touches map through).
class KidScale extends StatelessWidget {
  const KidScale({super.key, required this.child});

  final Widget child;

  /// 1 on phones; grows with the short side on tablets, capped so a 13"
  /// iPad still shows a sensible amount of content.
  static double factorFor(Size size) {
    final s = size.shortestSide;
    if (s < 600) return 1;
    return (s / 440).clamp(1.0, 1.75);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final size = box.biggest;
        final f = factorFor(size);
        if (f == 1) return child;
        final mq = MediaQuery.of(context);
        final inner = size / f;
        return FittedBox(
          fit: BoxFit.fill,
          child: SizedBox.fromSize(
            size: inner,
            child: MediaQuery(
              data: mq.copyWith(
                size: inner,
                padding: mq.padding / f,
                viewPadding: mq.viewPadding / f,
                viewInsets: mq.viewInsets / f,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
