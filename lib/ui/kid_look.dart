import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared colours for the child-facing screens.
abstract final class KidColors {
  static const ink = Color(0xFF2B2140);
  static const inkSoft = Color(0xFF6B6385);
  static const knew = Color(0xFF22C48A);
  static const almost = Color(0xFFFFA62B);
  static const notYet = Color(0xFFFF6F61);
  static const star = Color(0xFFFFC83D);
  static const paper = Colors.white;

  /// Soft tints behind card pictures, picked per word so cards vary.
  static const pastels = [
    Color(0xFFFFE3D3),
    Color(0xFFDDF4FF),
    Color(0xFFE6F9DC),
    Color(0xFFF1E4FF),
    Color(0xFFFFF2C6),
    Color(0xFFFFDDE8),
  ];

  static Color pastelFor(String id) =>
      pastels[id.codeUnits.fold(0, (a, b) => a + b) % pastels.length];

  /// A darker edge for chunky buttons and borders.
  static Color shade(Color c, [double amount = 0.18]) {
    final h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}

/// Age-banded look (docs/SPEC.md: age controls visuals). Ages 4–6 get the
/// bright, bigger "sunny" look; 7+ a cooler "adventure" look that isn't
/// babyish. Level never changes the look.
class KidLook {
  const KidLook._({
    required this.skyTop,
    required this.skyBottom,
    required this.hillFar,
    required this.hillNear,
    required this.sun,
    required this.accent,
    required this.pictureScale,
    required this.wordScale,
    required this.sparkles,
  });

  static const sunny = KidLook._(
    skyTop: Color(0xFF79C8FF),
    skyBottom: Color(0xFFE3F5FF),
    hillFar: Color(0xFFA6E59A),
    hillNear: Color(0xFF72CE76),
    sun: Color(0xFFFFD23F),
    accent: Color(0xFF7B5CFF),
    pictureScale: 1,
    wordScale: 1,
    sparkles: false,
  );

  static const adventure = KidLook._(
    skyTop: Color(0xFF5A63E8),
    skyBottom: Color(0xFFE0E4FF),
    hillFar: Color(0xFF8AD9CF),
    hillNear: Color(0xFF3DB5A6),
    sun: Color(0xFFFFC45C),
    accent: Color(0xFFFF7A4D),
    pictureScale: 0.85,
    wordScale: 0.9,
    sparkles: true,
  );

  static KidLook forAge(int? age) =>
      age == null || age <= 6 ? sunny : adventure;

  final Color skyTop;
  final Color skyBottom;
  final Color hillFar;
  final Color hillNear;
  final Color sun;

  /// Main call-to-action colour (Start, Done).
  final Color accent;
  final double pictureScale;
  final double wordScale;

  /// Twinkles in the sky instead of drifting clouds only.
  final bool sparkles;
}

/// Looping "idle" motion (drifting clouds, mascot blinking and bobbing).
/// Off in widget tests, where endless animations would stop pumpAndSettle.
final ambientMotionProvider = Provider<bool>((ref) => true);

/// Whether looping motion should run: app setting and the OS
/// reduce-motion switch.
bool ambientMotion(BuildContext context, WidgetRef ref) =>
    ref.watch(ambientMotionProvider) &&
    !MediaQuery.disableAnimationsOf(context);

/// Whether one-shot flourishes (confetti, bouncy entrances) should run.
bool flourishes(BuildContext context) =>
    !MediaQuery.disableAnimationsOf(context);
