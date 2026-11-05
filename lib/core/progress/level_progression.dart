import 'dart:math';

import '../levels.dart';
import 'progress_stats.dart';

/// Suggest stepping back to [to]; the child got [accuracy] right this week.
class StepBackSuggestion {
  const StepBackSuggestion({required this.to, required this.accuracy});
  final CefrLevel to;
  final double accuracy;
}

/// Level progression rules (docs/SPEC.md — Level progression, feat-016).
class LevelProgression {
  const LevelProgression();

  /// Share of the current level's words that must be mastered to move up.
  static const levelUpShare = 0.8;

  /// One new word in this many comes from the next level.
  static const previewEvery = 5;

  /// Below this share right over [struggleWindow], suggest a step back.
  static const struggleAccuracy = 0.5;
  static const struggleWindow = Duration(days: 7);

  /// Days with practice needed in the window before judging.
  static const minActiveDays = 3;

  /// Next-level words among [newWords] new words.
  static int previewSlots(int newWords) => newWords ~/ previewEvery;

  /// The level to move up to: [next] once [mastered] of [total] words at
  /// the current level (those allowed for the child's age) reach
  /// [levelUpShare]. Null when locked by the parent, when there is no next
  /// level with words for this child, or not there yet.
  CefrLevel? levelUp({
    required int mastered,
    required int total,
    required CefrLevel? next,
    required bool locked,
  }) {
    if (locked || next == null || total == 0) return null;
    return mastered >= total * levelUpShare ? next : null;
  }

  /// Today's new words: every [previewEvery]th slot takes a next-level
  /// [preview] word; the rest come from [current]. When one list runs out
  /// the other fills in. At most [count] words.
  List<String> mixPreview(
    List<String> current,
    List<String> preview, {
    required int count,
  }) {
    final slots = previewSlots(count);
    final out = <String>[];
    var c = 0, p = 0;
    for (var i = 0; i < count; i++) {
      final previewTurn = (i + 1) % previewEvery == 0 && p < slots;
      if ((previewTurn || c >= current.length) && p < preview.length) {
        out.add(preview[p++]);
      } else if (c < current.length) {
        out.add(current[c++]);
      } else {
        break;
      }
    }
    return out;
  }

  /// A suggestion for the parent to step back to [lower] when the answers
  /// of the last [struggleWindow], weighted by number of answers, are under
  /// [struggleAccuracy] right, with practice on at least [minActiveDays]
  /// days. Not in the child's first week at the level, not when the level
  /// is locked or lowest, and not within a week of the parent's "not now".
  StepBackSuggestion? stepBack({
    required CefrLevel? lower,
    required bool locked,
    required DateTime levelSince,
    required DateTime? dismissedAt,
    required List<SessionStat> sessions,
    required DateTime now,
  }) {
    if (lower == null || locked) return null;
    if (now.difference(levelSince) < struggleWindow) return null;
    if (dismissedAt != null && now.difference(dismissedAt) < struggleWindow) {
      return null;
    }
    final from = now.subtract(struggleWindow);
    final recent = [
      for (final s in sessions)
        if (s.startedAt.isAfter(from) && s.answered > 0) s,
    ];
    final days = {
      for (final s in recent)
        DateTime(
          s.startedAt.toLocal().year,
          s.startedAt.toLocal().month,
          s.startedAt.toLocal().day,
        ),
    };
    if (days.length < minActiveDays) return null;
    final answered = recent.fold(0, (n, s) => n + s.answered);
    final right = recent.fold(0.0, (n, s) => n + s.accuracy * s.answered);
    final accuracy = right / max(1, answered);
    return accuracy < struggleAccuracy
        ? StepBackSuggestion(to: lower, accuracy: accuracy)
        : null;
  }
}
