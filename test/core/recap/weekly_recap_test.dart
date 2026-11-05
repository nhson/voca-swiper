import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/core/progress/progress_stats.dart';
import 'package:voca_swiper/core/recap/weekly_recap.dart';
import 'package:voca_swiper/core/srs/word_state.dart';

void main() {
  final now = DateTime.utc(2026, 11, 20, 12);
  DateTime ago(int days, [int hours = 0]) =>
      now.subtract(Duration(days: days, hours: hours));

  RecapWord rw(
    String id, {
    required DateTime firstSeen,
    WordState state = WordState.learning,
    int right = 1,
    DateTime? lastAnswered,
    bool picture = true,
  }) => RecapWord(
    id: id,
    state: state,
    firstSeen: firstSeen,
    correctCount: right,
    lastAnsweredAt: lastAnswered ?? firstSeen,
    hasPicture: picture,
  );

  SessionStat s(DateTime at, int minutes) => SessionStat(
    startedAt: at,
    durationSec: minutes * 60,
    answered: 10,
    accuracy: 0.8,
  );

  test('words first seen and minutes in the last 7 days', () {
    final r = WeeklyRecap.compute(
      words: [
        rw('cat', firstSeen: ago(1)),
        rw('dog', firstSeen: ago(6, 23)),
        rw('sun', firstSeen: ago(7, 1)), // just over a week
      ],
      sessions: [s(ago(0, 2), 10), s(ago(3), 7), s(ago(8), 20)],
      now: now,
    );
    expect(r.newWords, 2);
    expect(r.minutes, 17);
    expect(r.isEmpty, isFalse);
  });

  test('word of the week: most right answers, a picture preferred', () {
    final r = WeeklyRecap.compute(
      words: [
        rw('the', firstSeen: ago(2), right: 5, picture: false),
        rw('cat', firstSeen: ago(3), right: 3),
        rw('dog', firstSeen: ago(1), right: 3),
        rw('old', firstSeen: ago(20), right: 9),
      ],
      sessions: const [],
      now: now,
    );
    // Pictured words first; among them most right, then first learned.
    expect(r.wordOfWeek, 'cat');
  });

  test('no picture this week → the best word anyway', () {
    final r = WeeklyRecap.compute(
      words: [
        rw('the', firstSeen: ago(2), right: 1, picture: false),
        rw('and', firstSeen: ago(2), right: 4, picture: false),
      ],
      sessions: const [],
      now: now,
    );
    expect(r.wordOfWeek, 'and');
  });

  test('recall: the 2 mastered words answered longest ago', () {
    final r = WeeklyRecap.compute(
      words: [
        rw(
          'a',
          firstSeen: ago(90),
          state: WordState.mastered,
          lastAnswered: ago(10),
        ),
        rw(
          'b',
          firstSeen: ago(90),
          state: WordState.mastered,
          lastAnswered: ago(40),
        ),
        rw(
          'c',
          firstSeen: ago(90),
          state: WordState.mastered,
          lastAnswered: ago(25),
        ),
        rw(
          'd',
          firstSeen: ago(90),
          state: WordState.review,
          lastAnswered: ago(60),
        ),
      ],
      sessions: const [],
      now: now,
    );
    expect(r.recall, ['b', 'c']);
  });

  test('a quiet week is empty', () {
    final r = WeeklyRecap.compute(
      words: const [],
      sessions: const [],
      now: now,
    );
    expect(r.newWords, 0);
    expect(r.minutes, 0);
    expect(r.wordOfWeek, isNull);
    expect(r.recall, isEmpty);
    expect(r.isEmpty, isTrue);
  });
}
