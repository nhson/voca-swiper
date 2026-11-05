import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/core/progress/dashboard.dart';
import 'package:voca_swiper/core/progress/progress_stats.dart';
import 'package:voca_swiper/core/srs/word_state.dart';

void main() {
  group('struggling words', () {
    WordRecord r(String id, int wrong, int right, [WordState? s]) => WordRecord(
      wordId: id,
      state: s ?? WordState.learning,
      wrongCount: wrong,
      correctCount: right,
    );

    test('most misses first, ties by fewer right answers', () {
      final list = Dashboard.struggling([
        r('a', 2, 5),
        r('b', 4, 1),
        r('c', 2, 1),
        r('d', 3, 0),
      ]);
      expect(list.map((w) => w.wordId), ['b', 'd', 'c', 'a']);
    });

    test('needs 2+ misses; mastered words are not struggling', () {
      final list = Dashboard.struggling([
        r('once', 1, 0),
        r('done', 5, 6, WordState.mastered),
        r('hard', 2, 0, WordState.review),
      ]);
      expect(list.map((w) => w.wordId), ['hard']);
    });

    test('at most [limit]', () {
      final list = Dashboard.struggling([
        for (var i = 0; i < 20; i++) r('w$i', 2 + i, 0),
      ], limit: 5);
      expect(list.map((w) => w.wordId), ['w19', 'w18', 'w17', 'w16', 'w15']);
    });
  });

  group('weekly trend', () {
    // Thursday 2026-11-19, local time.
    final now = DateTime(2026, 11, 19, 18);
    SessionStat s(DateTime at, int minutes) => SessionStat(
      startedAt: at.toUtc(),
      durationSec: minutes * 60,
      answered: 10,
      accuracy: 0.8,
    );

    test('weeks start Monday, oldest first, current week last', () {
      final weeks = Dashboard.weeklyTrend(
        firstSeen: [
          DateTime(2026, 11, 16, 9), // this week (Mon)
          DateTime(2026, 11, 19, 9),
          DateTime(2026, 11, 15, 20), // last week (Sun)
          DateTime(2026, 9, 1), // too old
        ].map((d) => d.toUtc()).toList(),
        sessions: [
          s(DateTime(2026, 11, 16, 17), 10),
          s(DateTime(2026, 11, 18, 17), 7),
          s(DateTime(2026, 11, 10, 17), 12),
        ],
        now: now.toUtc(),
        weeks: 4,
      );
      expect(weeks.map((w) => w.start), [
        DateTime(2026, 10, 26),
        DateTime(2026, 11, 2),
        DateTime(2026, 11, 9),
        DateTime(2026, 11, 16),
      ]);
      expect(weeks.map((w) => w.newWords), [0, 0, 1, 2]);
      expect(weeks.map((w) => w.minutes), [0, 0, 12, 17]);
      expect(weeks.map((w) => w.activeDays), [0, 0, 1, 2]);
    });
  });

  group('minutes vs goal', () {
    final now = DateTime(2026, 11, 19, 18);
    SessionStat s(DateTime at, int minutes) => SessionStat(
      startedAt: at.toUtc(),
      durationSec: minutes * 60,
      answered: 10,
      accuracy: 0.8,
    );

    test('last 7 days: days at goal, average on days practised', () {
      final g = Dashboard.goal(
        sessions: [
          s(DateTime(2026, 11, 19, 8), 6),
          s(DateTime(2026, 11, 19, 17), 5), // same day: 11
          s(DateTime(2026, 11, 17, 17), 4),
          s(DateTime(2026, 11, 13, 17), 12),
          s(DateTime(2026, 11, 12, 17), 30), // 8 days ago: out
        ],
        dailyMinutes: 10,
        now: now.toUtc(),
      );
      expect(g.daysPractised, 3);
      expect(g.daysAtGoal, 2);
      expect(g.averageMinutes, 9); // (11 + 4 + 12) / 3
      expect(g.goal, 10);
    });

    test('nothing practised', () {
      final g = Dashboard.goal(
        sessions: const [],
        dailyMinutes: 10,
        now: now.toUtc(),
      );
      expect(g.daysPractised, 0);
      expect(g.averageMinutes, 0);
    });
  });
}
