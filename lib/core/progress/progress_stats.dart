import '../srs/word_state.dart';

/// One logged session, as needed for progress numbers.
class SessionStat {
  const SessionStat({
    required this.startedAt,
    required this.durationSec,
    required this.answered,
    required this.accuracy,
  });

  final DateTime startedAt;
  final int durationSec;

  /// First answers in the session (reviewed + new).
  final int answered;

  /// Share of [answered] that were passes, 0–1.
  final double accuracy;
}

class DayMinutes {
  const DayMinutes(this.day, this.minutes);

  /// Local midnight.
  final DateTime day;
  final int minutes;
}

/// Numbers for the progress screen (docs/SPEC.md — Phase 1 "simple progress
/// screen"): words by state, accuracy and minutes per day. Pure Dart.
class ProgressStats {
  const ProgressStats._({
    required this.mastered,
    required this.review,
    required this.learning,
    required this.answered,
    required this.accuracy,
    required this.minutesByDay,
  });

  /// [now] and session times are compared in local time; the last [days]
  /// calendar days (today included) get a minutes bar each.
  factory ProgressStats.compute({
    required List<WordState> states,
    required List<SessionStat> sessions,
    required DateTime now,
    int days = 7,
  }) {
    int count(WordState s) => states.where((x) => x == s).length;

    var answered = 0;
    var correct = 0.0;
    for (final s in sessions) {
      answered += s.answered;
      correct += s.accuracy * s.answered;
    }

    final local = now.toLocal();
    final today = DateTime(local.year, local.month, local.day);
    final seconds = <DateTime, int>{};
    for (final s in sessions) {
      final t = s.startedAt.toLocal();
      final d = DateTime(t.year, t.month, t.day);
      seconds[d] = (seconds[d] ?? 0) + s.durationSec;
    }
    final byDay = <DayMinutes>[];
    for (var i = days - 1; i >= 0; i--) {
      final d = DateTime(today.year, today.month, today.day - i);
      final sec = seconds[d] ?? 0;
      // Nearest minute, but any practice shows as at least 1.
      final m = sec == 0 ? 0 : (sec / 60).round();
      byDay.add(DayMinutes(d, sec > 0 && m == 0 ? 1 : m));
    }

    return ProgressStats._(
      mastered: count(WordState.mastered),
      review: count(WordState.review),
      learning: count(WordState.learning),
      answered: answered,
      accuracy: answered == 0 ? null : correct / answered,
      minutesByDay: byDay,
    );
  }

  final int mastered;

  /// Remembered at least twice, interval still under 21 days.
  final int review;
  final int learning;
  final int answered;

  /// Null until the child has answered something.
  final double? accuracy;
  final List<DayMinutes> minutesByDay;

  int get wordsSeen => mastered + review + learning;
  int get minutesThisWeek => minutesByDay.fold(0, (a, d) => a + d.minutes);
}
