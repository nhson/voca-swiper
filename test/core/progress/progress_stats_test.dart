import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/core/progress/progress_stats.dart';
import 'package:voca_swiper/core/srs/word_state.dart';

void main() {
  // Thursday 5 Nov 2026, 20:00 local.
  final now = DateTime(2026, 11, 5, 20);

  SessionStat s(DateTime at, int sec, int answered, double acc) => SessionStat(
    startedAt: at,
    durationSec: sec,
    answered: answered,
    accuracy: acc,
  );

  test('empty profile: all zero, no accuracy yet', () {
    final p = ProgressStats.compute(
      states: const [],
      sessions: const [],
      now: now,
    );
    expect(p.mastered, 0);
    expect(p.review, 0);
    expect(p.learning, 0);
    expect(p.accuracy, isNull);
    expect(p.minutesByDay.map((d) => d.minutes), List.filled(7, 0));
    expect(p.minutesThisWeek, 0);
  });

  test('counts words by state; new words are not counted', () {
    final p = ProgressStats.compute(
      states: const [
        WordState.mastered,
        WordState.mastered,
        WordState.review,
        WordState.learning,
        WordState.learning,
        WordState.learning,
        WordState.newWord,
      ],
      sessions: const [],
      now: now,
    );
    expect((p.mastered, p.review, p.learning), (2, 1, 3));
    expect(p.wordsSeen, 6);
  });

  test('accuracy is weighted by answers, not averaged per session', () {
    final p = ProgressStats.compute(
      states: const [],
      sessions: [
        s(DateTime(2026, 11, 5, 8), 300, 10, 0.9), // 9 right
        s(DateTime(2026, 11, 4, 8), 120, 2, 0.5), // 1 right
      ],
      now: now,
    );
    expect(p.accuracy, closeTo(10 / 12, 1e-9));
    expect(p.answered, 12);
  });

  test('minutes per local day for the last 7 days, oldest first', () {
    final p = ProgressStats.compute(
      states: const [],
      sessions: [
        s(DateTime(2026, 11, 5, 8), 300, 5, 1), // today 5 min
        s(DateTime(2026, 11, 5, 18), 150, 5, 1), // + 2.5 min
        s(DateTime(2026, 11, 3, 23, 50), 90, 5, 1), // Tue 1.5 min
        s(DateTime(2026, 10, 29, 9), 600, 5, 1), // 7 days ago: outside
      ],
      now: now,
    );
    final days = p.minutesByDay;
    expect(days, hasLength(7));
    expect(days.first.day, DateTime(2026, 10, 30));
    expect(days.last.day, DateTime(2026, 11, 5));
    expect(days.last.minutes, 8, reason: '450 s rounds to 8 min');
    expect(days[4].day, DateTime(2026, 11, 3));
    expect(days[4].minutes, 2);
    expect(days.where((d) => d.minutes > 0), hasLength(2));
    expect(
      p.minutesThisWeek,
      10,
      reason: 'sum of the daily bars, so the numbers agree',
    );
  });

  test('a short session still shows as at least one minute', () {
    final p = ProgressStats.compute(
      states: const [],
      sessions: [s(DateTime(2026, 11, 5, 8), 20, 3, 1)],
      now: now,
    );
    expect(p.minutesByDay.last.minutes, 1);
  });
}
