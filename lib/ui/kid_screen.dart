import 'package:flutter/material.dart';

import 'kid_look.dart';
import 'kid_scale.dart';
import 'sky_background.dart';

/// Frame for every child-facing screen: illustrated sky, tablet scaling,
/// safe area.
class KidScreen extends StatelessWidget {
  const KidScreen({
    super.key,
    required this.look,
    required this.child,
    this.hills = true,
    this.sun = true,
  });

  final KidLook look;
  final Widget child;
  final bool hills;
  final bool sun;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: look.skyBottom,
      body: SkyBackground(
        look: look,
        hills: hills,
        sun: sun,
        child: KidScale(child: SafeArea(child: child)),
      ),
    );
  }
}
