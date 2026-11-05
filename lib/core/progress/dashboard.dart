import '../srs/word_state.dart';
import 'progress_stats.dart';

/// What the dashboard needs about one word's progress.
class WordRecord {
  const WordRecord({
    required this.wordId,
    required this.state,
    required this.wrongCount,
    required this.correctCount,
  });

  final String wordId;
  final WordState state;
  final int wrongCount;
  final int correctCount;
}

/// One calendar week (Monday start, local time) of practice.
class WeekPoint {
  const WeekPoint({
    required this.start,
    required this.newWords,
    required this.minutes,
    required this.activeDays,
  });

  /// Local Monday 00:00.
  final DateTime start;

  /// Words first seen that week.
  final int newWords;
  final int minutes;
  final int activeDays;
}

/// Practice time against the daily goal over the last 7 days.
class GoalStats {
  const GoalStats({
    required this.goal,
    required this.daysPractised,
    required this.daysAtGoal,
    required this.averageMinutes,
  });

  final int goal;
  final int daysPractised;
  final int daysAtGoal;

  /// Rounded average minutes on the days practised.
  final int averageMinutes;
}

/// Numbers for the parent dashboard (feat-017). Pure Dart; local calendar
/// days and weeks.
abstract final class Dashboard {
  /// Words with at least [minMisses] misses that are not mastered, most
  /// misses first, ties by fewer right answers, then id.
  static List<WordRecord> struggling(
    List<WordRecord> words, {
    int minMisses = 2,
    int limit = 10,
  }) {
    final list = [
      for (final w in words)
        if (w.wrongCount >= minMisses && w.state != WordState.mastered) w,
    ];
    list.sort((a, b) {
      final byWrong = b.wrongCount.compareTo(a.wrongCount);
      if (byWrong != 0) return byWrong;
      final byRight = a.correctCount.compareTo(b.correctCount);
      return byRight != 0 ? byRight : a.wordId.compareTo(b.wordId);
    });
    return list.take(limit).toList();
  }

  static DateTime _day(DateTime t) {
    final l = t.toLocal();
    return DateTime(l.year, l.month, l.day);
  }

  static DateTime _monday(DateTime t) {
    final d = _day(t);
    return DateTime(d.year, d.month, d.day - (d.weekday - 1));
  }

  /// The last [weeks] weeks, oldest first, the current week last.
  static List<WeekPoint> weeklyTrend({
    required List<DateTime> firstSeen,
    required List<SessionStat> sessions,
    required DateTime now,
    int weeks = 8,
  }) {
    final thisWeek = _monday(now);
    final starts = [
      for (var i = weeks - 1; i >= 0; i--)
        DateTime(thisWeek.year, thisWeek.month, thisWeek.day - 7 * i),
    ];
    final newWords = <DateTime, int>{};
    for (final t in firstSeen) {
      final m = _monday(t);
      newWords[m] = (newWords[m] ?? 0) + 1;
    }
    final seconds = <DateTime, int>{};
    final days = <DateTime, Set<DateTime>>{};
    for (final s in sessions) {
      final m = _monday(s.startedAt);
      seconds[m] = (seconds[m] ?? 0) + s.durationSec;
      (days[m] ??= {}).add(_day(s.startedAt));
    }
    return [
      for (final m in starts)
        WeekPoint(
          start: m,
          newWords: newWords[m] ?? 0,
          minutes: ((seconds[m] ?? 0) / 60).round(),
          activeDays: days[m]?.length ?? 0,
        ),
    ];
  }

  /// The last 7 calendar days, today included.
  static GoalStats goal({
    required List<SessionStat> sessions,
    required int dailyMinutes,
    required DateTime now,
  }) {
    final today = _day(now);
    final from = DateTime(today.year, today.month, today.day - 6);
    final seconds = <DateTime, int>{};
    for (final s in sessions) {
      final d = _day(s.startedAt);
      if (d.isBefore(from) || d.isAfter(today)) continue;
      seconds[d] = (seconds[d] ?? 0) + s.durationSec;
    }
    final minutes = [for (final sec in seconds.values) sec / 60];
    return GoalStats(
      goal: dailyMinutes,
      daysPractised: minutes.length,
      daysAtGoal: minutes.where((m) => m >= dailyMinutes).length,
      averageMinutes: minutes.isEmpty
          ? 0
          : (minutes.reduce((a, b) => a + b) / minutes.length).round(),
    );
  }
}
