import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/core/session/session_builder.dart';
import 'package:voca_swiper/core/session/study_session.dart';
import 'package:voca_swiper/core/srs/word_schedule.dart';
import 'package:voca_swiper/core/srs/word_state.dart';

void main() {
  final now = DateTime.utc(2026, 11, 4, 9);
  const builder = SessionBuilder();

  WordSchedule dueAt(DateTime at, {WordState state = WordState.review}) =>
      WordSchedule.initial().copyWith(
        state: state,
        intervalDays: 3,
        repetitions: 2,
        nextReviewAt: at,
        lastAnsweredAt: at.subtract(const Duration(days: 3)),
      );

  List<String> ids(StudySession s) => s.queue.map((c) => c.wordId).toList();

  group('ordering', () {
    test('due reviews first, oldest first, then new words in given order', () {
      final s = builder.build(
        schedules: {
          'cat': dueAt(now.subtract(const Duration(days: 1))),
          'dog': dueAt(now.subtract(const Duration(days: 5))),
          'sun': dueAt(now),
        },
        newWordIds: ['red', 'blue'],
        dailyNewWords: 10,
        now: now,
      );
      expect(ids(s), ['dog', 'cat', 'sun', 'red', 'blue']);
      expect(s.queue.map((c) => c.isNew), [false, false, false, true, true]);
    });

    test('ties on due date are broken by word id for determinism', () {
      final s = builder.build(
        schedules: {'b': dueAt(now), 'a': dueAt(now)},
        newWordIds: const [],
        dailyNewWords: 5,
        now: now,
      );
      expect(ids(s), ['a', 'b']);
    });

    test('words not yet due are left out', () {
      final s = builder.build(
        schedules: {'later': dueAt(now.add(const Duration(hours: 1)))},
        newWordIds: const [],
        dailyNewWords: 5,
        now: now,
      );
      expect(s.queue, isEmpty);
      expect(s.isFinished, isTrue);
    });

    test('due Mastered words resurface as reviews', () {
      final s = builder.build(
        schedules: {'apple': dueAt(now, state: WordState.mastered)},
        newWordIds: const [],
        dailyNewWords: 5,
        now: now,
      );
      expect(ids(s), ['apple']);
    });
  });

  group('daily goal', () {
    final candidates = List.generate(20, (i) => 'w$i');

    test('caps new words at the daily goal', () {
      final s = builder.build(
        schedules: const {},
        newWordIds: candidates,
        dailyNewWords: 5,
        now: now,
      );
      expect(ids(s), ['w0', 'w1', 'w2', 'w3', 'w4']);
    });

    test('subtracts new words already introduced today', () {
      final s = builder.build(
        schedules: const {},
        newWordIds: candidates,
        dailyNewWords: 5,
        newIntroducedToday: 3,
        now: now,
      );
      expect(ids(s), ['w0', 'w1']);
    });

    test('goal already met → no new words', () {
      final s = builder.build(
        schedules: const {},
        newWordIds: candidates,
        dailyNewWords: 5,
        newIntroducedToday: 7,
        now: now,
      );
      expect(s.queue, isEmpty);
    });

    test('reviews are not capped by the new-word goal', () {
      final s = builder.build(
        schedules: {for (var i = 0; i < 8; i++) 'r$i': dueAt(now)},
        newWordIds: candidates,
        dailyNewWords: 2,
        now: now,
      );
      expect(s.queue.where((c) => !c.isNew), hasLength(8));
      expect(s.queue.where((c) => c.isNew), hasLength(2));
    });

    test('skips "new" candidates that already have progress', () {
      final s = builder.build(
        schedules: {'cat': dueAt(now.add(const Duration(days: 2)))},
        newWordIds: ['cat', 'dog'],
        dailyNewWords: 5,
        now: now,
      );
      expect(ids(s), ['dog']);
    });

    test('skips duplicate candidates', () {
      final s = builder.build(
        schedules: const {},
        newWordIds: ['dog', 'dog', 'cat'],
        dailyNewWords: 5,
        now: now,
      );
      expect(ids(s), ['dog', 'cat']);
    });
  });

  group('StudySession', () {
    StudySession session(List<String> words) => builder.build(
      schedules: const {},
      newWordIds: words,
      dailyNewWords: 10,
      now: now,
    );

    test('walks the queue card by card', () {
      var s = session(['a', 'b']);
      expect(s.current!.wordId, 'a');
      s = s.answer(AnswerQuality.knew);
      expect(s.current!.wordId, 'b');
      s = s.answer(AnswerQuality.knew);
      expect(s.current, isNull);
      expect(s.isFinished, isTrue);
    });

    test('a missed word comes back at the end of the session', () {
      var s = session(['a', 'b', 'c']);
      s = s.answer(AnswerQuality.didntKnow); // a
      expect(ids(s), ['b', 'c', 'a']);
      expect(s.queue.last.isRetry, isTrue);
    });

    test('"almost" and "knew" are not re-queued', () {
      var s = session(['a', 'b']);
      s = s.answer(AnswerQuality.almost);
      s = s.answer(AnswerQuality.knew);
      expect(s.isFinished, isTrue);
    });

    test('a quiz-wrong answer is re-queued like a miss', () {
      var s = session(['a']);
      s = s.answer(AnswerQuality.quizWrong);
      expect(ids(s), ['a']);
    });

    test('a word is re-queued at most once per session', () {
      var s = session(['a']);
      s = s.answer(AnswerQuality.didntKnow); // first try
      s = s.answer(AnswerQuality.didntKnow); // retry, missed again
      expect(s.isFinished, isTrue);
    });

    test('only the first answer per word counts for scheduling', () {
      var s = session(['a', 'b']);
      s = s.answer(AnswerQuality.didntKnow); // a
      s = s.answer(AnswerQuality.knew); // b
      s = s.answer(AnswerQuality.knew); // a retry
      expect(s.firstAnswers, {
        'a': AnswerQuality.didntKnow,
        'b': AnswerQuality.knew,
      });
      expect(s.isFinished, isTrue);
    });

    test('answering a finished session throws', () {
      final s = session(const []);
      expect(() => s.answer(AnswerQuality.knew), throwsStateError);
    });

    test('answer returns a new session and leaves the old one unchanged', () {
      final s = session(['a', 'b']);
      final next = s.answer(AnswerQuality.didntKnow);
      expect(ids(s), ['a', 'b']);
      expect(s.firstAnswers, isEmpty);
      expect(ids(next), ['b', 'a']);
    });
  });
}
