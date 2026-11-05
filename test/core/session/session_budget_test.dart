import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/core/session/session_builder.dart';
import 'package:voca_swiper/core/session/study_session.dart';
import 'package:voca_swiper/core/srs/sm2_scheduler.dart';
import 'package:voca_swiper/core/srs/word_schedule.dart';
import 'package:voca_swiper/core/srs/word_state.dart';

/// feat-011: a session never holds more cards than the profile's daily
/// minutes allow; the most overdue reviews go first, the rest wait, and new
/// words pause while reviews fill the session.
void main() {
  final now = DateTime.utc(2026, 11, 4, 9);
  const builder = SessionBuilder();

  WordSchedule dueDaysAgo(int days) => WordSchedule.initial().copyWith(
    state: WordState.review,
    intervalDays: 3,
    repetitions: 2,
    nextReviewAt: now.subtract(Duration(days: days)),
    lastAnsweredAt: now.subtract(Duration(days: days + 3)),
  );

  Map<String, WordSchedule> backlog(int n) => {
    for (var i = 0; i < n; i++)
      'w${i.toString().padLeft(3, '0')}': dueDaysAgo(i),
  };

  final fresh = [for (var i = 0; i < 20; i++) 'new$i'];

  group('cards for minutes', () {
    test('about 2.5 cards a minute', () {
      expect(SessionBuilder.cardsForMinutes(5), 12);
      expect(SessionBuilder.cardsForMinutes(10), 25);
      expect(SessionBuilder.cardsForMinutes(15), 37);
      expect(SessionBuilder.cardsForMinutes(30), 75);
    });

    test('never below a small floor', () {
      expect(SessionBuilder.cardsForMinutes(0), SessionBuilder.minCards);
      expect(SessionBuilder.cardsForMinutes(1), SessionBuilder.minCards);
    });
  });

  group('budget', () {
    test('reviews are capped, most overdue first', () {
      final s = builder.build(
        schedules: backlog(40),
        newWordIds: fresh,
        dailyNewWords: 5,
        maxCards: 25,
        now: now,
      );
      expect(s.queue, hasLength(25));
      // w039 is 39 days overdue, w015 is 15: the 25 oldest come first.
      expect(s.queue.first.wordId, 'w039');
      expect(s.queue.last.wordId, 'w015');
    });

    test('new words pause while reviews fill the session', () {
      final s = builder.build(
        schedules: backlog(25),
        newWordIds: fresh,
        dailyNewWords: 5,
        maxCards: 25,
        now: now,
      );
      expect(s.queue.where((c) => c.isNew), isEmpty);
    });

    test('new words fill only the room that is left', () {
      final s = builder.build(
        schedules: backlog(22),
        newWordIds: fresh,
        dailyNewWords: 5,
        maxCards: 25,
        now: now,
      );
      expect(s.queue, hasLength(25));
      expect(s.queue.where((c) => c.isNew), hasLength(3));
    });

    test('a light day gets the full daily new words', () {
      final s = builder.build(
        schedules: backlog(4),
        newWordIds: fresh,
        dailyNewWords: 5,
        maxCards: 25,
        now: now,
      );
      expect(s.queue, hasLength(9));
      expect(s.queue.where((c) => c.isNew), hasLength(5));
    });

    test('no budget keeps the old uncapped behaviour', () {
      final s = builder.build(
        schedules: backlog(40),
        newWordIds: fresh,
        dailyNewWords: 5,
        now: now,
      );
      expect(s.queue, hasLength(45));
    });
  });

  group('simulation with the real scheduler', () {
    const scheduler = Sm2Scheduler();
    const budget = 25; // 10 minutes a day

    /// Plays [days] days from [start]; [studies] says which days the child
    /// opens the app. 80% "knew it", 20% "didn't know" (fixed seed).
    /// Returns cards per session (0 on days off) and the new words per day.
    ({List<int> cards, List<int> newWords, Map<String, WordSchedule> states})
    play(
      int days, {
      required bool Function(int day) studies,
      Map<String, WordSchedule>? from,
      DateTime? start,
    }) {
      final rng = Random(7);
      final states = Map.of(from ?? <String, WordSchedule>{});
      var nextNew = states.length;
      final cards = <int>[], newWords = <int>[];
      final t0 = start ?? now;
      for (var d = 0; d < days; d++) {
        final today = t0.add(Duration(days: d));
        if (!studies(d)) {
          cards.add(0);
          newWords.add(0);
          continue;
        }
        var session = builder.build(
          schedules: states,
          newWordIds: [for (var i = 0; i < 10; i++) 'n${nextNew + i}'],
          dailyNewWords: 5,
          maxCards: budget,
          now: today,
        );
        cards.add(session.queue.length);
        newWords.add(session.queue.where((c) => c.isNew).length);
        nextNew += newWords.last;
        while (!session.isFinished) {
          final q = rng.nextDouble() < 0.8
              ? AnswerQuality.knew
              : AnswerQuality.didntKnow;
          session = session.answer(q);
        }
        session.firstAnswers.forEach((id, q) {
          states[id] = scheduler.schedule(
            states[id] ?? WordSchedule.initial(),
            q,
            now: today,
          );
        });
      }
      return (cards: cards, newWords: newWords, states: states);
    }

    test('daily use for 8 weeks: never over budget, still learning', () {
      final r = play(56, studies: (_) => true);
      expect(r.cards.reduce(max), lessThanOrEqualTo(budget));
      // New words keep coming in the last two weeks, not stalled forever.
      final lateNew = r.newWords.skip(42).reduce((a, b) => a + b);
      expect(lateNew, greaterThan(0));
    });

    test('school-week use (5 of 7 days): never over budget', () {
      final r = play(56, studies: (d) => d % 7 < 5);
      expect(r.cards.reduce(max), lessThanOrEqualTo(budget));
    });

    test(
      '3-week holiday: capped sessions, backlog drains, new words resume',
      () {
        final before = play(28, studies: (_) => true);
        final back = now.add(const Duration(days: 28 + 21));
        final after = play(
          21,
          studies: (_) => true,
          from: before.states,
          start: back,
        );
        expect(after.cards.reduce(max), lessThanOrEqualTo(budget));
        // First days back are all review.
        expect(after.newWords.first, 0);
        // Within three weeks the pile is gone and new words are back.
        expect(after.newWords.skip(14).reduce((a, b) => a + b), greaterThan(0));
      },
    );
  });

  test('retries are practice on top, not part of the budget', () {
    var s = builder.build(
      schedules: backlog(3),
      newWordIds: const [],
      dailyNewWords: 5,
      maxCards: 3,
      now: now,
    );
    s = s.answer(AnswerQuality.didntKnow);
    expect(s.queue.map((c) => c.isRetry), [false, false, true]);
    expect(s, isA<StudySession>());
  });
}
