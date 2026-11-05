import '../progress/progress_stats.dart';
import '../srs/word_state.dart';

/// What the recap needs about one word the child has met.
class RecapWord {
  const RecapWord({
    required this.id,
    required this.state,
    required this.firstSeen,
    required this.correctCount,
    required this.lastAnsweredAt,
    required this.hasPicture,
  });

  final String id;
  final WordState state;
  final DateTime firstSeen;
  final int correctCount;
  final DateTime? lastAnsweredAt;
  final bool hasPicture;
}

/// The week in words (docs/SPEC.md — Knowledge reminders, feat-019): the
/// last 7 days up to now.
class WeeklyRecap {
  const WeeklyRecap({
    required this.newWords,
    required this.minutes,
    required this.wordOfWeek,
    required this.recall,
  });

  static const window = Duration(days: 7);
  static const recallCount = 2;

  /// - [newWords]: words first seen in the window.
  /// - [minutes]: practice time in the window.
  /// - [wordOfWeek]: among this week's new words, one with a picture if
  ///   any, then most right answers, then first learned.
  /// - [recall]: up to [recallCount] mastered words answered longest ago,
  ///   to bring back so they don't fade.
  factory WeeklyRecap.compute({
    required List<RecapWord> words,
    required List<SessionStat> sessions,
    required DateTime now,
  }) {
    final from = now.subtract(window);
    bool inWindow(DateTime t) => t.isAfter(from) && !t.isAfter(now);

    final fresh =
        [
          for (final w in words)
            if (inWindow(w.firstSeen)) w,
        ]..sort((a, b) {
          if (a.hasPicture != b.hasPicture) return a.hasPicture ? -1 : 1;
          final byRight = b.correctCount.compareTo(a.correctCount);
          if (byRight != 0) return byRight;
          return a.firstSeen.compareTo(b.firstSeen);
        });
    final seconds = sessions
        .where((s) => inWindow(s.startedAt))
        .fold(0, (n, s) => n + s.durationSec);
    final mastered =
        [
          for (final w in words)
            if (w.state == WordState.mastered) w,
        ]..sort((a, b) {
          final at = a.lastAnsweredAt ?? a.firstSeen;
          final bt = b.lastAnsweredAt ?? b.firstSeen;
          final byTime = at.compareTo(bt);
          return byTime != 0 ? byTime : a.id.compareTo(b.id);
        });
    return WeeklyRecap(
      newWords: fresh.length,
      minutes: (seconds / 60).round(),
      wordOfWeek: fresh.isEmpty ? null : fresh.first.id,
      recall: [for (final w in mastered.take(recallCount)) w.id],
    );
  }

  final int newWords;
  final int minutes;
  final String? wordOfWeek;
  final List<String> recall;

  bool get isEmpty =>
      newWords == 0 && minutes == 0 && wordOfWeek == null && recall.isEmpty;
}
