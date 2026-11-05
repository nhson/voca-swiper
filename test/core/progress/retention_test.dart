import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/core/progress/retention.dart';

/// feat-013: "remembered after 2 weeks" — quiz accuracy on words first
/// learned 14+ days before the quiz (docs/SPEC.md — Phase 2 gate).
void main() {
  final day0 = DateTime.utc(2026, 10, 1, 9);
  DateTime d(int days, {int hours = 0}) =>
      day0.add(Duration(days: days, hours: hours));

  QuizAnswer a(String word, bool ok, DateTime at) =>
      QuizAnswer(wordId: word, correct: ok, answeredAt: at);

  test('no quiz answers → nothing to show', () {
    final r = Retention.compute(answers: const [], firstSeen: const {});
    expect((r.asked, r.correct, r.words), (0, 0, 0));
    expect(r.rate, isNull);
  });

  test('only answers 14+ days after the word was first seen count', () {
    final r = Retention.compute(
      firstSeen: {'cat': d(0), 'dog': d(0), 'sun': d(10)},
      answers: [
        a('cat', true, d(0)), // same day: too soon
        a('cat', false, d(5)), // too soon
        a('cat', true, d(14)), // exactly 2 weeks: counts
        a('dog', false, d(20)), // counts
        a('sun', true, d(20)), // 10 days after first seen: too soon
      ],
    );
    expect((r.asked, r.correct), (2, 1));
    expect(r.rate, closeTo(0.5, 1e-9));
    expect(r.words, 2);
  });

  test('just under 14 days does not count', () {
    final r = Retention.compute(
      firstSeen: {'cat': d(0)},
      answers: [a('cat', true, d(13, hours: 23))],
    );
    expect(r.asked, 0);
  });

  test('every answer counts; words are counted once', () {
    final r = Retention.compute(
      firstSeen: {'cat': d(0), 'dog': d(0)},
      answers: [
        a('cat', true, d(15)),
        a('cat', true, d(30)),
        a('dog', true, d(40)),
        a('dog', false, d(60)),
      ],
    );
    expect((r.asked, r.correct, r.words), (4, 3, 2));
    expect(r.rate, closeTo(0.75, 1e-9));
  });

  test(
    'answers for words with no progress (e.g. after a reset) are ignored',
    () {
      final r = Retention.compute(
        firstSeen: {'cat': d(0)},
        answers: [a('ghost', true, d(30)), a('cat', true, d(30))],
      );
      expect((r.asked, r.words), (1, 1));
    },
  );

  test('the minimum age can be changed', () {
    final r = Retention.compute(
      firstSeen: {'cat': d(0)},
      answers: [a('cat', true, d(7))],
      minAge: const Duration(days: 7),
    );
    expect(r.asked, 1);
  });
}
