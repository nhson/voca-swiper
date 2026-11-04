import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/core/srs/sm2_scheduler.dart';
import 'package:voca_swiper/core/srs/word_schedule.dart';
import 'package:voca_swiper/core/srs/word_state.dart';

void main() {
  final now = DateTime.utc(2026, 11, 4, 9);
  const scheduler = Sm2Scheduler();

  WordSchedule answer(WordSchedule s, AnswerQuality q, {DateTime? at}) =>
      scheduler.schedule(s, q, now: at ?? now);

  /// Applies a sequence of answers, each one when the word is next due.
  WordSchedule run(List<AnswerQuality> answers) {
    var s = WordSchedule.initial();
    var at = now;
    for (final q in answers) {
      s = answer(s, q, at: at);
      at = s.nextReviewAt!;
    }
    return s;
  }

  group('initial schedule', () {
    test('is New with default ease and nothing scheduled', () {
      final s = WordSchedule.initial();
      expect(s.state, WordState.newWord);
      expect(s.easeFactor, 2.5);
      expect(s.intervalDays, 0);
      expect(s.repetitions, 0);
      expect(s.nextReviewAt, isNull);
      expect(s.lastAnsweredAt, isNull);
      expect(s.correctCount, 0);
      expect(s.wrongCount, 0);
    });
  });

  group('knew it', () {
    test('first correct answer → 1 day, Learning', () {
      final s = answer(WordSchedule.initial(), AnswerQuality.knew);
      expect(s.intervalDays, 1);
      expect(s.repetitions, 1);
      expect(s.state, WordState.learning);
      expect(s.nextReviewAt, now.add(const Duration(days: 1)));
      expect(s.lastAnsweredAt, now);
      expect(s.correctCount, 1);
      expect(s.wrongCount, 0);
    });

    test('second correct answer → 3 days, Review', () {
      final s = run([AnswerQuality.knew, AnswerQuality.knew]);
      expect(s.intervalDays, 3);
      expect(s.repetitions, 2);
      expect(s.state, WordState.review);
    });

    test('third onward → previous interval × ease, rounded', () {
      final s = run(List.filled(3, AnswerQuality.knew));
      expect(s.intervalDays, 8); // 3 × 2.5 = 7.5 → 8
      expect(s.state, WordState.review);
    });

    test('does not change ease', () {
      final s = run(List.filled(3, AnswerQuality.knew));
      expect(s.easeFactor, 2.5);
    });

    test('Mastered once interval reaches 21 days', () {
      final s = run(List.filled(4, AnswerQuality.knew));
      expect(s.intervalDays, 20); // 8 × 2.5
      expect(s.state, WordState.review);

      final m = run(List.filled(5, AnswerQuality.knew));
      expect(m.intervalDays, 50);
      expect(m.state, WordState.mastered);
    });

    test('Mastered stays Mastered on further correct answers', () {
      final s = run(List.filled(6, AnswerQuality.knew));
      expect(s.state, WordState.mastered);
    });
  });

  group('almost knew it', () {
    test('counts as a pass with a shorter interval than knew it', () {
      final knew = run(List.filled(3, AnswerQuality.knew));
      final almost = run([
        AnswerQuality.knew,
        AnswerQuality.knew,
        AnswerQuality.almost,
      ]);
      expect(almost.intervalDays, lessThan(knew.intervalDays));
      expect(almost.repetitions, 3);
      expect(almost.correctCount, 3);
      expect(almost.state, WordState.review);
    });

    test('interval is never below 1 day', () {
      final s = answer(WordSchedule.initial(), AnswerQuality.almost);
      expect(s.intervalDays, 1);
    });

    test('lowers ease by 0.15', () {
      final s = answer(WordSchedule.initial(), AnswerQuality.almost);
      expect(s.easeFactor, closeTo(2.35, 1e-9));
    });
  });

  group('miss', () {
    for (final miss in [AnswerQuality.didntKnow, AnswerQuality.quizWrong]) {
      group(miss.name, () {
        test('resets to Learning, 1 day, repetitions 0', () {
          final s = answer(
            run(List.filled(5, AnswerQuality.knew)), // Mastered
            miss,
          );
          expect(s.state, WordState.learning);
          expect(s.repetitions, 0);
          expect(s.intervalDays, 1);
          expect(s.wrongCount, 1);
          expect(s.correctCount, 5);
        });

        test('lowers ease by 0.2', () {
          final s = answer(WordSchedule.initial(), miss);
          expect(s.easeFactor, closeTo(2.3, 1e-9));
        });

        test('from New goes to Learning', () {
          final s = answer(WordSchedule.initial(), miss);
          expect(s.state, WordState.learning);
          expect(s.nextReviewAt, now.add(const Duration(days: 1)));
        });
      });
    }

    test('ease never drops below 1.3', () {
      final s = run(List.filled(20, AnswerQuality.didntKnow));
      expect(s.easeFactor, 1.3);
    });

    test('after a miss the 1 → 3 → × ease ladder restarts with lower ease', () {
      final s = run([
        AnswerQuality.didntKnow, // ease 2.3
        AnswerQuality.knew, // 1
        AnswerQuality.knew, // 3
        AnswerQuality.knew, // 3 × 2.3 = 6.9 → 7
      ]);
      expect(s.intervalDays, 7);
    });
  });

  group('resolveAnswer', () {
    test('a wrong quiz answer overrides a "knew it" swipe', () {
      expect(
        resolveAnswer(AnswerQuality.knew, quizCorrect: false),
        AnswerQuality.quizWrong,
      );
    });

    test('a correct quiz keeps the swipe', () {
      expect(
        resolveAnswer(AnswerQuality.almost, quizCorrect: true),
        AnswerQuality.almost,
      );
    });

    test('no quiz keeps the swipe', () {
      expect(resolveAnswer(AnswerQuality.knew), AnswerQuality.knew);
    });
  });

  group('isDue', () {
    test('New words are not due reviews', () {
      expect(WordSchedule.initial().isDue(now), isFalse);
    });

    test('due on or after nextReviewAt', () {
      final s = answer(WordSchedule.initial(), AnswerQuality.knew);
      expect(s.isDue(now), isFalse);
      expect(s.isDue(s.nextReviewAt!), isTrue);
      expect(s.isDue(s.nextReviewAt!.add(const Duration(hours: 1))), isTrue);
    });
  });
}
